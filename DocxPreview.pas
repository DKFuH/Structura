unit DocxPreview;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils;

type
  TDocxPreview = class
  public
    class function LoadPreviewText(const AFileName: string): string;
    // Liefert den Inhalt von <w:body> (ohne abschließendes sectPr) als XML,
    // Zeichnungen/Objekte entfernt. Für den formattreuen Zusammenführen-Export.
    class function LoadChapterBodyXml(const AFileName: string;
      out ABodyXml: string): Boolean;
  end;

implementation

uses
  zipper, DOM, XMLRead, XMLWrite, FileUtil;

type
  // Leitet die Unzip-Ausgabe in einen vorhandenen Speicherstream um,
  // damit kein Temp-Verzeichnis nötig ist.
  TStreamGrabber = class
  public
    Target: TMemoryStream;
    procedure CreateStream(Sender: TObject; var AStream: TStream;
      AItem: TFullZipFileEntry);
    procedure DoneStream(Sender: TObject; var AStream: TStream;
      AItem: TFullZipFileEntry);
  end;

procedure TStreamGrabber.CreateStream(Sender: TObject; var AStream: TStream;
  AItem: TFullZipFileEntry);
begin
  Target.Clear;
  AStream := Target;
end;

procedure TStreamGrabber.DoneStream(Sender: TObject; var AStream: TStream;
  AItem: TFullZipFileEntry);
begin
  // Stream gehört uns — Zipper darf ihn nicht freigeben
  AStream := nil;
end;

// Hat der Absatz eine Nummerierung (w:pPr/w:numPr)? Dann ist er Teil
// einer Liste und bekommt einen Aufzählungspunkt.
function ParagraphIsListItem(ANode: TDOMNode): Boolean;
var
  PrNode, Child: TDOMNode;
  I: Integer;
begin
  Result := False;
  for I := 0 to ANode.ChildNodes.Count - 1 do
  begin
    PrNode := ANode.ChildNodes.Item[I];
    if PrNode.NodeName <> 'w:pPr' then
      Continue;
    Child := PrNode.FirstChild;
    while Assigned(Child) do
    begin
      if Child.NodeName = 'w:numPr' then
        Exit(True);
      Child := Child.NextSibling;
    end;
  end;
end;

function ExtractNodeText(ANode: TDOMNode): string;
var
  I: Integer;
begin
  Result := '';
  if not Assigned(ANode) then
    Exit;
  if ANode.NodeName = 'w:t' then
    Exit(ANode.TextContent);
  if ANode.NodeName = 'w:tab' then
    Exit(#9);
  if ANode.NodeName = 'w:br' then
    Exit(LineEnding);

  for I := 0 to ANode.ChildNodes.Count - 1 do
    Result := Result + ExtractNodeText(ANode.ChildNodes.Item[I]);

  if (ANode.NodeName = 'w:p') and (Result <> '') then
  begin
    if ParagraphIsListItem(ANode) then
      Result := '• ' + Result;
    Result := Result + LineEnding + LineEnding;
  end;
  // Tabellen: Zellen mit Tab trennen, Zeilen mit Zeilenumbruch
  if (ANode.NodeName = 'w:tc') and (Result <> '') then
    Result := Trim(Result) + #9;
  if ANode.NodeName = 'w:tr' then
    Result := TrimRight(Result) + LineEnding;
  if (ANode.NodeName = 'w:tbl') and (Result <> '') then
    Result := Result + LineEnding;
end;

// Extrahiert word/document.xml in den Speicher. Liefert False, wenn die
// Datei nicht als ZIP lesbar ist (beschädigt oder gesperrt).
function TryExtractDocumentXml(const AFileName: string;
  ATarget: TMemoryStream; out AErrorText: string): Boolean;
var
  UnZipper: TUnZipper;
  Grabber: TStreamGrabber;
  Files: TStringList;
begin
  Result := False;
  AErrorText := '';
  UnZipper := TUnZipper.Create;
  Grabber := TStreamGrabber.Create;
  Files := TStringList.Create;
  try
    try
      Grabber.Target := ATarget;
      UnZipper.FileName := AFileName;
      UnZipper.OnCreateStream := @Grabber.CreateStream;
      UnZipper.OnDoneStream := @Grabber.DoneStream;
      Files.Add('word/document.xml');
      UnZipper.UnZipFiles(Files);
      Result := ATarget.Size > 0;
      if not Result then
        AErrorText := 'Die DOCX-Datei enthält kein lesbares word/document.xml.';
    except
      on E: Exception do
        AErrorText := E.Message;
    end;
  finally
    Files.Free;
    Grabber.Free;
    UnZipper.Free;
  end;
end;

// Entfernt rekursiv Knoten, die externe Beziehungen/Medien referenzieren
// (Zeichnungen, eingebettete Objekte, Bilder), damit der zusammengeführte
// Body keine toten Verweise enthält.
procedure StripDrawings(ANode: TDOMNode);
var
  I: Integer;
  Child: TDOMNode;
begin
  I := 0;
  while I < ANode.ChildNodes.Count do
  begin
    Child := ANode.ChildNodes.Item[I];
    if (Child.NodeName = 'w:drawing') or (Child.NodeName = 'w:object') or
       (Child.NodeName = 'w:pict') or (Child.NodeName = 'mc:AlternateContent') or
       (Child.NodeName = 'v:shape') then
    begin
      ANode.RemoveChild(Child);
      // Index nicht erhöhen — nachfolgende Knoten rücken nach
    end
    else
    begin
      StripDrawings(Child);
      Inc(I);
    end;
  end;
end;

function SerializeNode(ANode: TDOMNode): string;
var
  Stream: TStringStream;
  P: Integer;
begin
  Stream := TStringStream.Create('');
  try
    WriteXML(ANode, Stream);
    Result := Stream.DataString;
    // WriteXML kann eine XML-Deklaration voranstellen — entfernen
    if Pos('<?xml', Result) = 1 then
    begin
      P := Pos('?>', Result);
      if P > 0 then
        Result := Copy(Result, P + 2, MaxInt);
    end;
    Result := Trim(Result);
  finally
    Stream.Free;
  end;
end;

class function TDocxPreview.LoadChapterBodyXml(const AFileName: string;
  out ABodyXml: string): Boolean;
var
  XmlStream: TMemoryStream;
  Doc: TXMLDocument;
  ErrorText, TempCopy: string;
  Extracted: Boolean;
  Body, Child: TDOMNode;
  I: Integer;
begin
  Result := False;
  ABodyXml := '';
  if not FileExists(AFileName) or
     not SameText(ExtractFileExt(AFileName), '.docx') then
    Exit;

  XmlStream := TMemoryStream.Create;
  Doc := nil;
  try
    Extracted := TryExtractDocumentXml(AFileName, XmlStream, ErrorText);
    if not Extracted then
    begin
      TempCopy := IncludeTrailingPathDelimiter(GetTempDir(False)) +
        'structura_merge_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '.docx';
      if CopyFile(AFileName, TempCopy) then
      try
        Extracted := TryExtractDocumentXml(TempCopy, XmlStream, ErrorText);
      finally
        DeleteFile(TempCopy);
      end;
    end;
    if not Extracted then
      Exit;

    try
      XmlStream.Position := 0;
      ReadXMLFile(Doc, XmlStream);
      // <w:body> finden
      Body := nil;
      if Assigned(Doc.DocumentElement) then
        for I := 0 to Doc.DocumentElement.ChildNodes.Count - 1 do
          if Doc.DocumentElement.ChildNodes.Item[I].NodeName = 'w:body' then
          begin
            Body := Doc.DocumentElement.ChildNodes.Item[I];
            Break;
          end;
      if not Assigned(Body) then
        Exit;

      StripDrawings(Body);
      // Kinder serialisieren, sectPr auslassen
      for I := 0 to Body.ChildNodes.Count - 1 do
      begin
        Child := Body.ChildNodes.Item[I];
        if Child.NodeName = 'w:sectPr' then
          Continue;
        ABodyXml := ABodyXml + SerializeNode(Child);
      end;
      Result := True;
    except
      Result := False;
    end;
  finally
    Doc.Free;
    XmlStream.Free;
  end;
end;

class function TDocxPreview.LoadPreviewText(const AFileName: string): string;
var
  XmlStream: TMemoryStream;
  Doc: TXMLDocument;
  ErrorText, TempCopy: string;
  Extracted: Boolean;
begin
  if not FileExists(AFileName) then
    Exit('Datei fehlt: ' + AFileName);
  if SameText(ExtractFileExt(AFileName), '.txt') or
     SameText(ExtractFileExt(AFileName), '.md') then
    Exit(Trim(ReadFileToString(AFileName)));
  if not SameText(ExtractFileExt(AFileName), '.docx') then
    Exit('Vorschau für diesen Dateityp ist noch nicht implementiert.');

  XmlStream := TMemoryStream.Create;
  Doc := nil;
  try
    Extracted := TryExtractDocumentXml(AFileName, XmlStream, ErrorText);

    // Direkter Zugriff gescheitert? Vielleicht hält ein anderes Programm
    // (z. B. Word) die Datei — über eine Kopie erneut versuchen.
    if not Extracted then
    begin
      TempCopy := IncludeTrailingPathDelimiter(GetTempDir(False)) +
        'structura_preview_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '.docx';
      if CopyFile(AFileName, TempCopy) then
      try
        Extracted := TryExtractDocumentXml(TempCopy, XmlStream, ErrorText);
      finally
        DeleteFile(TempCopy);
      end;
    end;

    if not Extracted then
      Exit('Textvorschau konnte nicht geladen werden. Die DOCX-Datei ist ' +
        'beschädigt oder gerade in einem anderen Programm exklusiv geöffnet.' +
        LineEnding + LineEnding + 'Details: ' + ErrorText);

    try
      XmlStream.Position := 0;
      ReadXMLFile(Doc, XmlStream);
      Result := Trim(ExtractNodeText(Doc.DocumentElement));
      Result := StringReplace(Result, #9#9, #9, [rfReplaceAll]);
      Result := StringReplace(Result, LineEnding + LineEnding + LineEnding,
        LineEnding + LineEnding, [rfReplaceAll]);
      if Result = '' then
        Result := 'Keine Textvorschau verfügbar.';
    except
      on E: Exception do
        Result := 'Textvorschau konnte nicht geladen werden. Das Dokument ' +
          'enthält kein gültiges XML.' + LineEnding + LineEnding +
          'Details: ' + E.Message;
    end;
  finally
    Doc.Free;
    XmlStream.Free;
  end;
end;

end.
