unit DocxPreview;

{$mode objfpc}{$H+}

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
  zipper, DOM, XMLRead, StrUtils, FileUtil, StructuraTypes;

function ExtractNodeText(ANode: TDOMNode): string;
var
  I: Integer;
  ChildText: string;
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
  begin
    ChildText := ExtractNodeText(ANode.ChildNodes.Item[I]);
    if (ANode.NodeName = 'w:p') and (ChildText <> '') then
      Result := Result + ChildText
    else
      Result := Result + ChildText;
  end;
  if (ANode.NodeName = 'w:p') and (Result <> '') then
    Result := Result + LineEnding + LineEnding;
  if (ANode.NodeName = 'w:tr') and (Result <> '') then
    Result := Result + LineEnding;
end;

class function TDocxPreview.LoadPreviewText(const AFileName: string): string;
var
  UnZipper: TUnZipper;
  TempDir: string;
  DocumentXml: string;
  Doc: TXMLDocument;
  FilesToExtract: TStringList;
begin
  if not FileExists(AFileName) then
    Exit('Datei fehlt: ' + AFileName);
  if SameText(ExtractFileExt(AFileName), '.txt') or SameText(ExtractFileExt(AFileName), '.md') then
    Exit(Trim(ReadFileToString(AFileName)));
  if not SameText(ExtractFileExt(AFileName), '.docx') then
    Exit('Vorschau fuer diesen Dateityp ist noch nicht implementiert.');

  TempDir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'structura_preview_' + FormatDateTime('yyyymmddhhnnsszzz', Now) + PathDelim;
  ForceDirectories(TempDir);
  UnZipper := TUnZipper.Create;
  FilesToExtract := TStringList.Create;
  try
    UnZipper.FileName := AFileName;
    UnZipper.OutputPath := TempDir;
    UnZipper.Examine;
    FilesToExtract.Add('word/document.xml');
    UnZipper.UnZipFiles(FilesToExtract);
    DocumentXml := IncludeTrailingPathDelimiter(TempDir) +
      RelativeProjectPath(['word', 'document.xml']);
    if not FileExists(DocumentXml) then
      Exit('Die DOCX-Datei enthaelt kein lesbares word/document.xml.');
    ReadXMLFile(Doc, DocumentXml);
    try
      Result := Trim(ExtractNodeText(Doc.DocumentElement));
      Result := StringReplace(Result, #9#9, #9, [rfReplaceAll]);
      Result := StringReplace(Result, LineEnding + LineEnding + LineEnding,
        LineEnding + LineEnding, [rfReplaceAll]);
      if Result = '' then
        Result := 'Keine Textvorschau verfuegbar.';
    finally
      Doc.Free;
    end;
  finally
    FilesToExtract.Free;
    UnZipper.Free;
    DeleteDirectory(TempDir, True);
  end;
end;

end.
