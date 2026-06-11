unit DocumentWorkflow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StructuraTypes;

type
  // Wie der Kapitelinhalt ins Master-DOCX kommt.
  //  cmFidelity = Originalkapitel per altChunk einbetten (volle Treue, Word)
  //  cmUniversal = Absatz-/Tabellen-XML zusammenführen (Word & LibreOffice)
  //  cmText = nur extrahierter Text (einfach, überall)
  TExportContentMode = (cmFidelity, cmUniversal, cmText);

  // Optionen für den Manuskript-Export. SelectedItems ist parallel zu den
  // Projekt-Items indiziert; leeres Array bedeutet: alles exportieren.
  TExportOptions = record
    IncludeTitlePage: Boolean;
    NumberChapters: Boolean;
    NumberDigits: Integer;       // 1..3, Stellen der Kapitelnummer
    IncludeDividers: Boolean;
    ReviewExport: Boolean;       // zusätzlich eine Textdatei pro Kapitel
    ContentMode: TExportContentMode;
    SelectedItems: array of Boolean;
  end;

  TDocumentWorkflow = class
  public
    class function FindLibreOfficeExecutable: string;
    class function CreateBlankDocx(const TargetFile, Title: string; out ErrorText: string): Boolean;
    class function ImportChapterFile(const SourceFile, ProjectFolder, PreferredTitle: string;
      out RelativeFileName, ErrorText: string): Boolean;
    class function GenerateChapterPdf(const ProjectFolder: string; AItem: TStructuraItem;
      const LibreOfficePath: string;
      out PdfFileName, ErrorText: string): Boolean;
    class function DefaultExportOptions: TExportOptions;
    class function ExportMasterDocument(AProject: TStructuraProject;
      const AOptions: TExportOptions; out InfoText: string): Boolean;
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
  // OPC-Pakete (DOCX) verlangen Forward-Slashes in den Eintragsnamen.
  AZipper.Entries.AddFileEntry(DiskFileName,
    StringReplace(ArchiveFileName, '\', '/', [rfReplaceAll]));
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

// Ein DOCX-Absatz mit optionalem Absatz-Style (z. B. Title, Heading1).
function DocxParagraph(const AText, AStyle: string;
  ACenter, APageBreakBefore: Boolean): string;
var
  PPr: string;
begin
  PPr := '';
  if AStyle <> '' then
    PPr := PPr + '<w:pStyle w:val="' + AStyle + '"/>';
  if APageBreakBefore then
    PPr := PPr + '<w:pageBreakBefore/>';
  if ACenter then
    PPr := PPr + '<w:jc w:val="center"/>';
  if PPr <> '' then
    PPr := '<w:pPr>' + PPr + '</w:pPr>';

  Result := '<w:p>' + PPr + '<w:r>' +
    '<w:t xml:space="preserve">' + HtmlEscape(AText) + '</w:t></w:r></w:p>';
end;

// Mehrzeiligen Kapiteltext in DOCX-Absätze umsetzen (eine Zeile = ein Absatz).
function DocxBodyFromText(const AText: string): string;
var
  Lines: TStringList;
  I: Integer;
  Para: TStringList;
begin
  Para := TStringList.Create;
  Lines := TStringList.Create;
  try
    Lines.Text := AText;
    for I := 0 to Lines.Count - 1 do
    begin
      if Trim(Lines[I]) = '' then
        Para.Add('<w:p/>')
      else
        Para.Add(DocxParagraph(Lines[I], '', False, False));
    end;
    Result := Para.Text;
  finally
    Lines.Free;
    Para.Free;
  end;
end;

// Vollständiges, Word-konformes Stylesheet (Normal + Titel/Untertitel/Heading).
function MasterStylesXml: string;
begin
  Result :=
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' +
    '<w:docDefaults><w:rPrDefault><w:rPr>' +
    '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/><w:szCs w:val="22"/>' +
    '</w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>' +
    '<w:spacing w:after="160" w:line="259" w:lineRule="auto"/>' +
    '</w:pPr></w:pPrDefault></w:docDefaults>' +
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>' +
    '<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/>' +
    '<w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="center"/></w:pPr>' +
    '<w:rPr><w:b/><w:sz w:val="48"/><w:szCs w:val="48"/></w:rPr></w:style>' +
    '<w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/>' +
    '<w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="center"/></w:pPr>' +
    '<w:rPr><w:i/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>' +
    '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/>' +
    '<w:basedOn w:val="Normal"/><w:next w:val="Normal"/>' +
    '<w:pPr><w:keepNext/><w:outlineLvl w:val="0"/></w:pPr>' +
    '<w:rPr><w:b/><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr></w:style>' +
    '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/>' +
    '<w:basedOn w:val="Normal"/><w:next w:val="Normal"/>' +
    '<w:pPr><w:keepNext/><w:outlineLvl w:val="1"/></w:pPr>' +
    '<w:rPr><w:b/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>' +
    '</w:styles>';
end;

// Schreibt ein vollständiges, Word-konformes DOCX-Paket (inkl. Styles und
// docProps, damit Word es ohne Reparaturhinweis öffnet).
function WriteMasterDocx(const TargetFile, BodyInner, ATitle, AAuthor: string;
  const AChunkFiles: array of string; out ErrorText: string): Boolean;
var
  TempRoot, WordDir, RelsDir, PropsDir, EmbedDir: string;
  ZipperObj: TZipper;
  Stamp, ChunkOverrides, ChunkRels, EmbedName: string;
  I: Integer;
begin
  Result := False;
  ErrorText := '';
  TempRoot := GetTempDir(False) + 'structura_master_' +
    FormatDateTime('yyyymmddhhnnsszzz', Now);
  WordDir := IncludeTrailingPathDelimiter(TempRoot) + 'word';
  RelsDir := IncludeTrailingPathDelimiter(TempRoot) + '_rels';
  PropsDir := IncludeTrailingPathDelimiter(TempRoot) + 'docProps';
  EmbedDir := IncludeTrailingPathDelimiter(WordDir) + 'embed';
  ForceDirectories(IncludeTrailingPathDelimiter(WordDir) + '_rels');
  ForceDirectories(RelsDir);
  ForceDirectories(PropsDir);
  if Length(AChunkFiles) > 0 then
    ForceDirectories(EmbedDir);
  Stamp := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now);

  // Eingebettete Kapitel (altChunk): Content-Type-Override + Beziehung je Datei
  ChunkOverrides := '';
  ChunkRels := '';
  for I := 0 to High(AChunkFiles) do
  begin
    EmbedName := Format('chapter%d.docx', [I + 1]);
    CopyFile(AChunkFiles[I], IncludeTrailingPathDelimiter(EmbedDir) + EmbedName,
      [cffOverwriteFile]);
    ChunkOverrides := ChunkOverrides +
      Format('<Override PartName="/word/embed/%s" ' +
      'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document"/>',
      [EmbedName]);
    ChunkRels := ChunkRels +
      Format('<Relationship Id="rIdChunk%d" ' +
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/aFChunk" ' +
      'Target="embed/%s"/>', [I + 1, EmbedName]);
  end;

  SaveTextFile(IncludeTrailingPathDelimiter(TempRoot) + '[Content_Types].xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
    '<Default Extension="xml" ContentType="application/xml"/>' +
    '<Override PartName="/word/document.xml" ' +
    'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>' +
    '<Override PartName="/word/styles.xml" ' +
    'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>' +
    '<Override PartName="/docProps/core.xml" ' +
    'ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>' +
    '<Override PartName="/docProps/app.xml" ' +
    'ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>' +
    ChunkOverrides +
    '</Types>');
  SaveTextFile(IncludeTrailingPathDelimiter(RelsDir) + '.rels',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    '<Relationship Id="rId1" ' +
    'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" ' +
    'Target="word/document.xml"/>' +
    '<Relationship Id="rId2" ' +
    'Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" ' +
    'Target="docProps/core.xml"/>' +
    '<Relationship Id="rId3" ' +
    'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" ' +
    'Target="docProps/app.xml"/>' +
    '</Relationships>');
  SaveTextFile(IncludeTrailingPathDelimiter(WordDir) + 'document.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<w:document ' +
    'xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" ' +
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
    'xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" ' +
    'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" ' +
    'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" ' +
    'xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" ' +
    'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" ' +
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" ' +
    'mc:Ignorable="w14 w15 wp14">' +
    '<w:body>' + BodyInner + '<w:sectPr/></w:body></w:document>');
  SaveTextFile(IncludeTrailingPathDelimiter(WordDir) + 'styles.xml', MasterStylesXml);
  SaveTextFile(IncludeTrailingPathDelimiter(WordDir) +
    RelativeProjectPath(['_rels', 'document.xml.rels']),
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
    ChunkRels + '</Relationships>');
  SaveTextFile(IncludeTrailingPathDelimiter(PropsDir) + 'core.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<cp:coreProperties ' +
    'xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" ' +
    'xmlns:dc="http://purl.org/dc/elements/1.1/" ' +
    'xmlns:dcterms="http://purl.org/dc/terms/" ' +
    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
    '<dc:title>' + HtmlEscape(ATitle) + '</dc:title>' +
    '<dc:creator>' + HtmlEscape(AAuthor) + '</dc:creator>' +
    '<cp:lastModifiedBy>Structura</cp:lastModifiedBy>' +
    '<dcterms:created xsi:type="dcterms:W3CDTF">' + Stamp + '</dcterms:created>' +
    '<dcterms:modified xsi:type="dcterms:W3CDTF">' + Stamp + '</dcterms:modified>' +
    '</cp:coreProperties>');
  SaveTextFile(IncludeTrailingPathDelimiter(PropsDir) + 'app.xml',
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">' +
    '<Application>Structura</Application></Properties>');

  ZipperObj := TZipper.Create;
  try
    ZipperObj.FileName := TargetFile;
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(TempRoot) + '[Content_Types].xml', '[Content_Types].xml');
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(RelsDir) + '.rels', RelativeProjectPath(['_rels', '.rels']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(WordDir) + 'document.xml', RelativeProjectPath(['word', 'document.xml']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(WordDir) + 'styles.xml', RelativeProjectPath(['word', 'styles.xml']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(WordDir) + RelativeProjectPath(['_rels', 'document.xml.rels']),
      RelativeProjectPath(['word', '_rels', 'document.xml.rels']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(PropsDir) + 'core.xml', RelativeProjectPath(['docProps', 'core.xml']));
    AddZipEntry(ZipperObj, IncludeTrailingPathDelimiter(PropsDir) + 'app.xml', RelativeProjectPath(['docProps', 'app.xml']));
    for I := 0 to High(AChunkFiles) do
      AddZipEntry(ZipperObj,
        IncludeTrailingPathDelimiter(EmbedDir) + Format('chapter%d.docx', [I + 1]),
        RelativeProjectPath(['word', 'embed', Format('chapter%d.docx', [I + 1])]));
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

class function TDocumentWorkflow.DefaultExportOptions: TExportOptions;
begin
  Result.IncludeTitlePage := True;
  Result.NumberChapters := True;
  Result.NumberDigits := 2;
  Result.IncludeDividers := True;
  Result.ReviewExport := False;
  Result.ContentMode := cmFidelity;
  SetLength(Result.SelectedItems, 0);
end;

class function TDocumentWorkflow.ExportMasterDocument(AProject: TStructuraProject;
  const AOptions: TExportOptions; out InfoText: string): Boolean;

  function ItemSelected(AIndex: Integer): Boolean;
  begin
    Result := (Length(AOptions.SelectedItems) = 0) or
      ((AIndex < Length(AOptions.SelectedItems)) and AOptions.SelectedItems[AIndex]);
  end;

var
  ExportFolder, ReviewFolder: string;
  MarkdownFile: string;
  HtmlFile: string;
  Html: TStringList;
  Markdown: TStringList;
  Docx: TStringList;
  I: Integer;
  Item: TStructuraItem;
  ChapterNumber, ExportedChapters: Integer;
  SourceFile: string;
  ChapterText, Heading, NumberText: string;
  LibreOfficeExe: string;
  ErrorText: string;
  MasterDocx: string;
  MasterPdf: string;
  DocxError, ChapterBodyXml: string;
  ChunkFiles: array of string;
begin
  Result := False;
  SetLength(ChunkFiles, 0);
  ExportFolder := IncludeTrailingPathDelimiter(AProject.FolderPath) + 'export';
  ForceDirectories(ExportFolder);
  MarkdownFile := IncludeTrailingPathDelimiter(ExportFolder) + 'master.md';
  HtmlFile := IncludeTrailingPathDelimiter(ExportFolder) + 'master.html';
  MasterDocx := IncludeTrailingPathDelimiter(ExportFolder) + 'master.docx';
  MasterPdf := IncludeTrailingPathDelimiter(ExportFolder) + 'master.pdf';
  ReviewFolder := IncludeTrailingPathDelimiter(ExportFolder) + 'review';
  if AOptions.ReviewExport then
    ForceDirectories(ReviewFolder);

  Html := TStringList.Create;
  Markdown := TStringList.Create;
  Docx := TStringList.Create;
  try
    Html.Add('<html><head><meta charset="utf-8"><title>' + HtmlEscape(AProject.Title) + '</title></head><body>');
    if AOptions.IncludeTitlePage then
    begin
      Html.Add('<h1>' + HtmlEscape(AProject.Title) + '</h1>');
      if Trim(AProject.Subtitle) <> '' then
        Html.Add('<p><i>' + HtmlEscape(AProject.Subtitle) + '</i></p>');
      if Trim(AProject.Author) <> '' then
        Html.Add('<p>' + HtmlEscape(AProject.Author) + '</p>');
      Html.Add('<hr>');
      Markdown.Add('# ' + AProject.Title);
      if Trim(AProject.Subtitle) <> '' then
        Markdown.Add('*' + AProject.Subtitle + '*');
      if Trim(AProject.Author) <> '' then
        Markdown.Add(AProject.Author);
      Markdown.Add('');
      Markdown.Add('---');
      Markdown.Add('');
      // Titelseite im DOCX über echte Styles
      Docx.Add(DocxParagraph(AProject.Title, 'Title', True, False));
      if Trim(AProject.Subtitle) <> '' then
        Docx.Add(DocxParagraph(AProject.Subtitle, 'Subtitle', True, False));
      if Trim(AProject.Author) <> '' then
        Docx.Add(DocxParagraph(AProject.Author, '', True, False));
    end;

    ChapterNumber := 0;
    ExportedChapters := 0;
    for I := 0 to AProject.Count - 1 do
    begin
      Item := AProject[I];
      if Item.ItemType = sitDivider then
      begin
        if AOptions.IncludeDividers then
        begin
          Html.Add('<h1>' + HtmlEscape(Item.Title) + '</h1>');
          Markdown.Add('# ' + Item.Title);
          Markdown.Add('');
          Docx.Add(DocxParagraph(Item.Title, 'Heading1', False, True));
        end;
        Continue;
      end;

      Inc(ChapterNumber);
      if not ItemSelected(I) then
        Continue;
      Inc(ExportedChapters);

      if AOptions.NumberChapters then
        NumberText := Format('%.*d ', [AOptions.NumberDigits, ChapterNumber])
      else
        NumberText := '';
      Heading := NumberText + Item.Title;

      SourceFile := IncludeTrailingPathDelimiter(AProject.FolderPath) + Item.FileName;
      ChapterText := TDocxPreview.LoadPreviewText(SourceFile);
      Html.Add('<h2>' + HtmlEscape(Heading) + '</h2>');
      Html.Add(BuildHtmlFromText(ChapterText));
      Markdown.Add('## ' + Heading);
      Markdown.Add('');
      Markdown.Add(ChapterText);
      Markdown.Add('');
      // Kapitel im DOCX: Überschrift auf neuer Seite, dann der Inhalt je Modus
      Docx.Add(DocxParagraph(Heading, 'Heading2', False, True));
      case AOptions.ContentMode of
        cmFidelity:
          begin
            // Originalkapitel per altChunk einbetten — Word führt es voll
            // formattreu beim Öffnen zusammen
            SetLength(ChunkFiles, Length(ChunkFiles) + 1);
            ChunkFiles[High(ChunkFiles)] := SourceFile;
            Docx.Add(Format('<w:altChunk r:id="rIdChunk%d"/>',
              [Length(ChunkFiles)]));
          end;
        cmUniversal:
          // Absatz-/Tabellen-XML direkt übernehmen (Word & LibreOffice)
          if TDocxPreview.LoadChapterBodyXml(SourceFile, ChapterBodyXml) and
             (Trim(ChapterBodyXml) <> '') then
            Docx.Add(ChapterBodyXml)
          else
            Docx.Add(DocxBodyFromText(ChapterText));
      else
        // cmText: nur der extrahierte Text
        Docx.Add(DocxBodyFromText(ChapterText));
      end;

      // Prüfexport: reiner Text pro Kapitel, zum Einfügen in Grammarly,
      // LanguageTool oder ChatGPT
      if AOptions.ReviewExport then
        SaveTextFile(IncludeTrailingPathDelimiter(ReviewFolder) +
          Format('%.*d_%s.txt', [AOptions.NumberDigits, ChapterNumber,
            SanitizeFileNamePart(Item.Title)]),
          Item.Title + LineEnding + LineEnding + ChapterText);
    end;
    Html.Add('</body></html>');
    Html.SaveToFile(HtmlFile);
    Markdown.SaveToFile(MarkdownFile);

    if ExportedChapters = 0 then
    begin
      InfoText := 'Kein Kapitel ausgewählt — es wurde nichts exportiert.';
      Exit(False);
    end;

    // DOCX immer nativ erzeugen — unabhängig von LibreOffice
    if not WriteMasterDocx(MasterDocx, Docx.Text, AProject.Title, AProject.Author,
      ChunkFiles, DocxError) then
    begin
      InfoText := 'Export erstellt, aber DOCX fehlgeschlagen: ' + DocxError;
      Exit(True);
    end;
  finally
    Html.Free;
    Markdown.Free;
    Docx.Free;
  end;

  // PDF bleibt optional über LibreOffice. Im Fidelity-Modus enthält das DOCX
  // altChunks, die LibreOffice nicht expandiert — dann keine (leere) PDF erzeugen.
  if AOptions.ContentMode <> cmFidelity then
  begin
    LibreOfficeExe := FindLibreOfficeExecutable;
    if LibreOfficeExe <> '' then
      RunProcessAndWait(LibreOfficeExe,
        ['--headless', '--convert-to', 'pdf', '--outdir', ExportFolder, MasterDocx],
        AProject.FolderPath, ErrorText);
  end;

  InfoText := Format('Export erstellt (%d Kapitel):', [ExportedChapters]);
  InfoText := InfoText + LineEnding + 'DOCX: ' + MasterDocx;
  InfoText := InfoText + LineEnding + 'Markdown: ' + MarkdownFile;
  if FileExists(MasterPdf) then
    InfoText := InfoText + LineEnding + 'PDF: ' + MasterPdf;
  if AOptions.ReviewExport then
    InfoText := InfoText + LineEnding + 'Prüfexport: ' + ReviewFolder;
  Result := True;
end;

end.
