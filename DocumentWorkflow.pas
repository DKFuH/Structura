unit DocumentWorkflow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StructuraTypes;

type
  TDocumentWorkflow = class
  public
    class function FindLibreOfficeExecutable: string;
    class function CreateBlankDocx(const TargetFile, Title: string; out ErrorText: string): Boolean;
    class function ImportChapterFile(const SourceFile, ProjectFolder, PreferredTitle: string;
      out RelativeFileName, ErrorText: string): Boolean;
    class function GenerateChapterPdf(const ProjectFolder: string; AItem: TStructuraItem;
      const LibreOfficePath: string;
      out PdfFileName, ErrorText: string): Boolean;
    class function ExportMasterDocument(AProject: TStructuraProject; out InfoText: string): Boolean;
  end;

implementation

uses
  FileUtil, Process, zipper, DocxPreview;

function SaveTextFile(const AFileName, AText: string): Boolean;
var
  Buffer: TStringList;
begin
  Buffer := TStringList.Create;
  try
    Buffer.Text := AText;
    Buffer.SaveToFile(AFileName);
    Result := True;
  finally
    Buffer.Free;
  end;
end;

function SanitizeFileNamePart(const AValue: string): string;
var
  S: string;
  C: Char;
begin
  S := Trim(AValue);
  for C in ['\', '/', ':', '*', '?', '"', '<', '>', '|'] do
    S := StringReplace(S, C, '_', [rfReplaceAll]);
  S := StringReplace(S, ' ', '_', [rfReplaceAll]);
  while Pos('__', S) > 0 do
    S := StringReplace(S, '__', '_', [rfReplaceAll]);
  if S = '' then
    S := 'Kapitel';
  Result := S;
end;

function MakeUniqueFileName(const AFolder, ABaseName, AExtension: string): string;
var
  Candidate: string;
  Counter: Integer;
begin
  Counter := 0;
  repeat
    if Counter = 0 then
      Candidate := ABaseName + AExtension
    else
      Candidate := Format('%s_%d%s', [ABaseName, Counter, AExtension]);
    Inc(Counter);
  until not FileExists(IncludeTrailingPathDelimiter(AFolder) + Candidate);
  Result := Candidate;
end;

function RunProcessAndWait(const Executable: string; const Args: array of string;
  const AWorkDir: string; out ErrorText: string): Boolean;
var
  Proc: TProcess;
  I: Integer;
begin
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := Executable;
    for I := Low(Args) to High(Args) do
      Proc.Parameters.Add(Args[I]);
    Proc.Options := [poWaitOnExit, poUsePipes];
    if AWorkDir <> '' then
      Proc.CurrentDirectory := AWorkDir;
    try
      Proc.Execute;
      Result := Proc.ExitStatus = 0;
      if not Result then
        ErrorText := Format('Prozess fehlgeschlagen (%s), ExitCode=%d', [Executable, Proc.ExitStatus]);
    except
      on E: Exception do
      begin
        Result := False;
        ErrorText := E.Message;
      end;
    end;
  finally
    Proc.Free;
  end;
end;

function HtmlEscape(const AValue: string): string;
begin
  Result := StringReplace(AValue, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;

function BuildHtmlFromText(const AText: string): string;
var
  Lines: TStringList;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := AText;
    Result := '';
    for I := 0 to Lines.Count - 1 do
    begin
      if Trim(Lines[I]) = '' then
        Result := Result + '<p>&nbsp;</p>'
      else
        Result := Result + '<p>' + HtmlEscape(Lines[I]) + '</p>';
    end;
  finally
    Lines.Free;
  end;
end;

procedure AddZipEntry(AZipper: TZipper; const DiskFileName, ArchiveFileName: string);
begin
  AZipper.Entries.AddFileEntry(DiskFileName, ArchiveFileName);
end;

class function TDocumentWorkflow.FindLibreOfficeExecutable: string;
const
  CandidateNames: array[0..2] of string = ('soffice', 'libreoffice', 'soffice.exe');
var
  Candidate: string;
  BaseDirs: array of string;
  I: Integer;
begin
  for Candidate in CandidateNames do
  begin
    Result := FindDefaultExecutablePath(Candidate);
    if Result <> '' then
      Exit;
  end;

  SetLength(BaseDirs, 4);
  BaseDirs[0] := IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES')) +
    RelativeProjectPath(['LibreOffice', 'program', 'soffice.exe']);
  BaseDirs[1] := IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES(X86)')) +
    RelativeProjectPath(['LibreOffice', 'program', 'soffice.exe']);
  BaseDirs[2] := '/usr/bin/soffice';
  BaseDirs[3] := '/snap/bin/libreoffice';
  for I := 0 to High(BaseDirs) do
    if FileExists(BaseDirs[I]) then
      Exit(BaseDirs[I]);
  Result := '';
end;

class function TDocumentWorkflow.CreateBlankDocx(const TargetFile, Title: string;
  out ErrorText: string): Boolean;
var
  TempRoot: string;
  WordDir: string;
  RelsDir: string;
  ZipperObj: TZipper;
begin
  Result := False;
  ErrorText := '';
  TempRoot := GetTempDir(False) + 'structura_docx_' + FormatDateTime('yyyymmddhhnnsszzz', Now);
  WordDir := IncludeTrailingPathDelimiter(TempRoot) + 'word';
  RelsDir := IncludeTrailingPathDelimiter(TempRoot) + '_rels';
  ForceDirectories(IncludeTrailingPathDelimiter(WordDir) + '_rels');
  ForceDirectories(RelsDir);

  SaveTextFile(IncludeTrailingPathDelimiter(TempRoot) + '[Content_Types].xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
    '<Default Extension="xml" ContentType="application/xml"/>' +
    '<Override PartName="/word/document.xml" ' +
    'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>' +
    '<Override PartName="/word/styles.xml" ' +
    'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>' +
    '</Types>');
  SaveTextFile(IncludeTrailingPathDelimiter(RelsDir) + '.rels',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" ' +
    'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" ' +
    'Target="word/document.xml"/></Relationships>');
  SaveTextFile(IncludeTrailingPathDelimiter(WordDir) + 'document.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" ' +
    'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" ' +
    'xmlns:o="urn:schemas-microsoft-com:office:office" ' +
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ' +
    'xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" ' +
    'xmlns:v="urn:schemas-microsoft-com:vml" ' +
    'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" ' +
    'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" ' +
    'xmlns:w10="urn:schemas-microsoft-com:office:word" ' +
    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" ' +
    'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" ' +
    'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" ' +
    'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" ' +
    'xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" ' +
    'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 wp14">' +
    '<w:body><w:p><w:r><w:t>' + HtmlEscape(Title) + '</w:t></w:r></w:p>' +
    '<w:p><w:r><w:t></w:t></w:r></w:p><w:sectPr/></w:body></w:document>');
  SaveTextFile(IncludeTrailingPathDelimiter(WordDir) + 'styles.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>');
  SaveTextFile(IncludeTrailingPathDelimiter(WordDir) + RelativeProjectPath(['_rels', 'document.xml.rels']),
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"></Relationships>');

  ZipperObj := TZipper.Create;
  try
    ZipperObj.FileName := TargetFile;
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(TempRoot) + '[Content_Types].xml', '[Content_Types].xml');
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(RelsDir) + '.rels', RelativeProjectPath(['_rels', '.rels']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(WordDir) + 'document.xml', RelativeProjectPath(['word', 'document.xml']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(WordDir) + 'styles.xml', RelativeProjectPath(['word', 'styles.xml']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(WordDir) + RelativeProjectPath(['_rels', 'document.xml.rels']),
      RelativeProjectPath(['word', '_rels', 'document.xml.rels']));
    ZipperObj.ZipAllFiles;
    Result := FileExists(TargetFile);
    if not Result then
      ErrorText := 'DOCX-Datei konnte nicht erstellt werden.';
  finally
    ZipperObj.Free;
    DeleteDirectory(TempRoot, False);
  end;
end;

class function TDocumentWorkflow.ImportChapterFile(const SourceFile, ProjectFolder,
  PreferredTitle: string; out RelativeFileName, ErrorText: string): Boolean;
var
  ChaptersFolder: string;
  BaseName: string;
  FinalName: string;
  TargetFile: string;
begin
  ChaptersFolder := IncludeTrailingPathDelimiter(ProjectFolder) + 'chapters';
  ForceDirectories(ChaptersFolder);
  BaseName := SanitizeFileNamePart(PreferredTitle);
  FinalName := MakeUniqueFileName(ChaptersFolder, BaseName, ExtractFileExt(SourceFile));
  TargetFile := IncludeTrailingPathDelimiter(ChaptersFolder) + FinalName;
  Result := CopyFile(SourceFile, TargetFile, [cffOverwriteFile]);
  if Result then
    RelativeFileName := RelativeProjectPath(['chapters', FinalName])
  else
    ErrorText := 'Import der Kapiteldatei fehlgeschlagen.';
end;

class function TDocumentWorkflow.GenerateChapterPdf(const ProjectFolder: string;
  AItem: TStructuraItem; const LibreOfficePath: string; out PdfFileName,
  ErrorText: string): Boolean;
var
  LibreOfficeExe: string;
  SourceFile: string;
  PreviewFolder: string;
begin
  LibreOfficeExe := Trim(LibreOfficePath);
  if LibreOfficeExe = '' then
    LibreOfficeExe := FindLibreOfficeExecutable;
  if LibreOfficeExe = '' then
  begin
    ErrorText := 'LibreOffice/soffice wurde nicht gefunden.';
    Exit(False);
  end;

  PreviewFolder := IncludeTrailingPathDelimiter(ProjectFolder) + 'preview';
  ForceDirectories(PreviewFolder);
  SourceFile := IncludeTrailingPathDelimiter(ProjectFolder) + AItem.FileName;
  Result := RunProcessAndWait(LibreOfficeExe,
    ['--headless', '--convert-to', 'pdf', '--outdir', PreviewFolder, SourceFile],
    ProjectFolder, ErrorText);
  if not Result then
    Exit;
  PdfFileName := IncludeTrailingPathDelimiter(PreviewFolder) + ChangeFileExt(ExtractFileName(SourceFile), '.pdf');
  Result := FileExists(PdfFileName);
  if not Result then
    ErrorText := 'PDF-Vorschau wurde nicht erzeugt.';
end;

class function TDocumentWorkflow.ExportMasterDocument(AProject: TStructuraProject;
  out InfoText: string): Boolean;
var
  ExportFolder: string;
  MarkdownFile: string;
  HtmlFile: string;
  Html: TStringList;
  Markdown: TStringList;
  I: Integer;
  Item: TStructuraItem;
  ChapterNumber: Integer;
  SourceFile: string;
  ChapterText: string;
  LibreOfficeExe: string;
  ErrorText: string;
  MasterDocx: string;
  MasterPdf: string;
begin
  Result := False;
  ExportFolder := IncludeTrailingPathDelimiter(AProject.FolderPath) + 'export';
  ForceDirectories(ExportFolder);
  MarkdownFile := IncludeTrailingPathDelimiter(ExportFolder) + 'master.md';
  HtmlFile := IncludeTrailingPathDelimiter(ExportFolder) + 'master.html';
  MasterDocx := IncludeTrailingPathDelimiter(ExportFolder) + 'master.docx';
  MasterPdf := IncludeTrailingPathDelimiter(ExportFolder) + 'master.pdf';

  Html := TStringList.Create;
  Markdown := TStringList.Create;
  try
    Html.Add('<html><head><meta charset="utf-8"><title>' + HtmlEscape(AProject.Title) + '</title></head><body>');
    Html.Add('<h1>' + HtmlEscape(AProject.Title) + '</h1>');
    Markdown.Add('# ' + AProject.Title);
    Markdown.Add('');
    ChapterNumber := 0;
    for I := 0 to AProject.Count - 1 do
    begin
      Item := AProject[I];
      if Item.ItemType = sitDivider then
      begin
        Html.Add('<h1>' + HtmlEscape(Item.Title) + '</h1>');
        Markdown.Add('## ' + Item.Title);
        Markdown.Add('');
        Continue;
      end;

      Inc(ChapterNumber);
      SourceFile := IncludeTrailingPathDelimiter(AProject.FolderPath) + Item.FileName;
      ChapterText := TDocxPreview.LoadPreviewText(SourceFile);
      Html.Add('<h2>' + Format('%0.2d %s', [ChapterNumber, HtmlEscape(Item.Title)]) + '</h2>');
      Html.Add(BuildHtmlFromText(ChapterText));
      Markdown.Add('## ' + Format('%0.2d %s', [ChapterNumber, Item.Title]));
      Markdown.Add('');
      Markdown.Add(ChapterText);
      Markdown.Add('');
    end;
    Html.Add('</body></html>');
    Html.SaveToFile(HtmlFile);
    Markdown.SaveToFile(MarkdownFile);
  finally
    Html.Free;
    Markdown.Free;
  end;

  LibreOfficeExe := FindLibreOfficeExecutable;
  if LibreOfficeExe <> '' then
  begin
    if not RunProcessAndWait(LibreOfficeExe,
      ['--headless', '--convert-to', 'docx', '--outdir', ExportFolder, HtmlFile],
      AProject.FolderPath, ErrorText) then
    begin
      InfoText := 'Master-Markdown exportiert, DOCX-Konvertierung fehlgeschlagen: ' + ErrorText;
      Exit(True);
    end;
    if not RunProcessAndWait(LibreOfficeExe,
      ['--headless', '--convert-to', 'pdf', '--outdir', ExportFolder, HtmlFile],
      AProject.FolderPath, ErrorText) then
    begin
      InfoText := 'Master-Markdown und DOCX exportiert, PDF-Konvertierung fehlgeschlagen: ' + ErrorText;
      Exit(True);
    end;
  end;

  InfoText := 'Export erstellt: ' + MarkdownFile;
  if FileExists(MasterDocx) then
    InfoText := InfoText + LineEnding + 'DOCX: ' + MasterDocx;
  if FileExists(MasterPdf) then
    InfoText := InfoText + LineEnding + 'PDF: ' + MasterPdf;
  Result := True;
end;

end.
