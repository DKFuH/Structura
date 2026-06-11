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
  end;

implementation

uses
  zipper, DOM, XMLRead, FileUtil;

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
