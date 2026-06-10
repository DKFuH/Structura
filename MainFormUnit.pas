unit MainFormUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ComCtrls, Menus, StructuraTypes, OfficeDetection;

type
  TMainForm = class(TForm)
  private
    FProject: TStructuraProject;
    FSelectedIndex: Integer;
    FUpdatingUi: Boolean;
    FOfficeTargets: TOfficeTargets;
    FLastProjectFolder: string;
    FCurrentPreviewText: string;
    procedure ConfigureUi;
    procedure LoadButtonGlyph(AButton: TBitBtn; const AFileName: string);
    procedure SetProject(AProject: TStructuraProject);
    procedure LoadProjectFromFolder(const AFolder: string);
    procedure SaveProject;
    procedure PersistCurrentNotes;
    procedure PersistProjectNotes;
    procedure PersistChapterNotes;
    procedure RefreshAll;
    procedure RefreshItemList;
    procedure RefreshProjectView;
    procedure RefreshChapterView;
    procedure RefreshActionButtons;
    procedure PopulateStatusChoices;
    procedure SelectProjectOverview;
    procedure SelectItem(Index: Integer);
    function CurrentItem: TStructuraItem;
    function CurrentChapter: TStructuraItem;
    function AbsoluteItemFileName(AItem: TStructuraItem): string;
    function AbsoluteItemNotesFileName(AItem: TStructuraItem): string;
    function AbsoluteProjectNotesFileName: string;
    function LoadTextFileSafe(const AFileName: string): string;
    procedure SaveTextFileSafe(const AFileName, AText: string);
    function ChapterSequenceForIndex(AIndex: Integer): Integer;
    function ChapterSequenceForItem(AItem: TStructuraItem): Integer;
    function BuildChapterFileName(AItem: TStructuraItem; AListIndex: Integer): string;
    function BuildChapterListCaption(AIndex: Integer; AItem: TStructuraItem): string;
    function EnsureUniqueRelativeFileName(const ARelative: string): string;
    function MakeSafeFileNamePart(const AValue: string): string;
    function CreateBackupCopy(const AAbsoluteFileName: string): Boolean;
    function RenameChapterFile(AItem: TStructuraItem; AListIndex: Integer): Boolean;
    function RenumberChapterFiles: Boolean;
    function ChapterWordCount(AItem: TStructuraItem): Integer;
    function ProjectWordCount: Integer;
    function FileModifiedText(const AFileName: string): string;
    function ProjectStatusSummary: string;
    function OfficeAvailabilitySummary: string;
    procedure OpenCurrentChapterWithExecutable(const AExecutable: string);
    procedure ShowInFileManager(const AFileName: string);
    procedure UpdateStatus(const AText: string);
  published
    LeftPanel: TPanel;
    HeaderPanel: TPanel;
    ActionPanel: TPanel;
    ListPanel: TPanel;
    RightPanel: TPanel;
    Splitter: TSplitter;
    ItemListBox: TListBox;
    StatusBar: TStatusBar;
    NewButton: TBitBtn;
    OpenButton: TBitBtn;
    AddButton: TBitBtn;
    EditButton: TBitBtn;
    DeleteButton: TBitBtn;
    ProjectPanel: TScrollBox;
    ChapterPanel: TScrollBox;
    CoverImage: TImage;
    ProjectTitleLabel: TLabel;
    ProjectSubtitleLabel: TLabel;
    ProjectAuthorLabel: TLabel;
    ProjectStatsLabel: TLabel;
    ProjectStatusLabel: TLabel;
    OfficeSummaryLabel: TLabel;
    ProjectNotesLabel: TLabel;
    ProjectNotesMemo: TMemo;
    ChapterHeadingLabel: TLabel;
    ChapterMetaLabel: TLabel;
    ChapterStatusLabel: TLabel;
    ChapterStatusCombo: TComboBox;
    ChapterActionPanel: TFlowPanel;
    OpenChapterButton: TBitBtn;
    OpenFolderButton: TBitBtn;
    PdfPreviewButton: TBitBtn;
    WordButton: TButton;
    LibreButton: TButton;
    TextMakerButton: TButton;
    CopyTextButton: TButton;
    GrammarlyButton: TButton;
    ExportButton: TBitBtn;
    NotesLabel: TLabel;
    NotesMemo: TMemo;
    PreviewLabel: TLabel;
    PreviewMemo: TMemo;
    procedure ConfigureButtonGlyphs;
    procedure FormCreate(Sender: TObject);
    procedure NewProjectClick(Sender: TObject);
    procedure OpenProjectClick(Sender: TObject);
    procedure AddItemClick(Sender: TObject);
    procedure EditItemClick(Sender: TObject);
    procedure DeleteItemClick(Sender: TObject);
    procedure ItemListSelectionChange(Sender: TObject; User: boolean);
    procedure ItemListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ItemListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ProjectNotesExit(Sender: TObject);
    procedure NotesExit(Sender: TObject);
    procedure StatusChanged(Sender: TObject);
    procedure OpenChapterClick(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure PdfPreviewClick(Sender: TObject);
    procedure WordClick(Sender: TObject);
    procedure LibreClick(Sender: TObject);
    procedure TextMakerClick(Sender: TObject);
    procedure CopyTextClick(Sender: TObject);
    procedure GrammarlyClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  LCLIntf, LCLType, FileUtil, Process, Clipbrd, StrUtils, Math,
  ProjectStore, ProjectDialogUnit, ElementDialogUnit, DocumentWorkflow,
  DocxPreview;

function NormalizeStoredPathForCompare(const APath: string): string;
begin
  Result := StringReplace(APath, '\', '/', [rfReplaceAll]);
end;

procedure TMainForm.ConfigureUi;
begin
  Constraints.MinWidth := 1120;
  Constraints.MinHeight := 720;
  Position := poScreenCenter;
  ProjectPanel.Visible := True;
  ChapterPanel.Visible := False;
  ChapterActionPanel.AutoWrap := True;
  ChapterActionPanel.FlowStyle := fsLeftRightTopBottom;
  StatusBar.SimplePanel := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FSelectedIndex := -1;
  FOfficeTargets := DetectOfficeTargets;
  ConfigureUi;
  PopulateStatusChoices;
  ConfigureButtonGlyphs;
  SelectProjectOverview;
  UpdateStatus('Bereit. Bitte ein Projekt anlegen oder öffnen.');
end;

destructor TMainForm.Destroy;
begin
  FProject.Free;
  inherited Destroy;
end;

procedure TMainForm.ConfigureButtonGlyphs;
begin
  LoadButtonGlyph(NewButton, 'assets\buttons\new_project.bmp');
  LoadButtonGlyph(OpenButton, 'assets\buttons\open_project.bmp');
  LoadButtonGlyph(AddButton, 'assets\buttons\add_item.bmp');
  LoadButtonGlyph(EditButton, 'assets\buttons\edit_item.bmp');
  LoadButtonGlyph(DeleteButton, 'assets\buttons\delete_item.bmp');
  LoadButtonGlyph(OpenChapterButton, 'assets\buttons\open_chapter.bmp');
  LoadButtonGlyph(OpenFolderButton, 'assets\buttons\open_folder.bmp');
  LoadButtonGlyph(PdfPreviewButton, 'assets\buttons\pdf_preview.bmp');
  LoadButtonGlyph(ExportButton, 'assets\buttons\export_master.bmp');
end;

procedure TMainForm.LoadButtonGlyph(AButton: TBitBtn; const AFileName: string);
var
  Bitmap: TBitmap;
  FullPath: string;
begin
  FullPath := ExpandFileName(AFileName);
  if not FileExists(FullPath) then
    Exit;
  Bitmap := TBitmap.Create;
  try
    try
      Bitmap.LoadFromFile(FullPath);
      AButton.Glyph.Assign(Bitmap);
      AButton.NumGlyphs := 1;
      AButton.Layout := blGlyphLeft;
      AButton.Spacing := 6;
    except
      AButton.Glyph.Clear;
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure TMainForm.SetProject(AProject: TStructuraProject);
begin
  FreeAndNil(FProject);
  FProject := AProject;
  if Assigned(FProject) then
    FLastProjectFolder := FProject.FolderPath;
  FSelectedIndex := -1;
  RefreshAll;
end;

procedure TMainForm.LoadProjectFromFolder(const AFolder: string);
begin
  if not FileExists(TProjectStore.ProjectFileName(AFolder)) then
    raise Exception.Create('Im gewählten Ordner wurde keine structura.json gefunden.');
  SetProject(TProjectStore.LoadFromFolder(AFolder));
  UpdateStatus('Projekt geöffnet: ' + FProject.Title);
end;

procedure TMainForm.SaveProject;
begin
  if not Assigned(FProject) then
    Exit;
  TProjectStore.SaveToFolder(FProject);
end;

procedure TMainForm.PersistCurrentNotes;
begin
  PersistProjectNotes;
  PersistChapterNotes;
end;

procedure TMainForm.PersistProjectNotes;
begin
  if (not Assigned(FProject)) or FUpdatingUi then
    Exit;
  SaveTextFileSafe(AbsoluteProjectNotesFileName, ProjectNotesMemo.Text);
end;

procedure TMainForm.PersistChapterNotes;
var
  Item: TStructuraItem;
begin
  if FUpdatingUi then
    Exit;
  Item := CurrentChapter;
  if not Assigned(Item) then
    Exit;
  SaveTextFileSafe(AbsoluteItemNotesFileName(Item), NotesMemo.Text);
end;

procedure TMainForm.RefreshAll;
begin
  RefreshItemList;
  if FSelectedIndex >= 0 then
    SelectItem(FSelectedIndex)
  else
    SelectProjectOverview;
  RefreshActionButtons;
  RefreshProjectView;
end;

procedure TMainForm.RefreshItemList;
var
  I: Integer;
begin
  ItemListBox.Items.BeginUpdate;
  try
    ItemListBox.Items.Clear;
    if not Assigned(FProject) then
      Exit;
    for I := 0 to FProject.Count - 1 do
      ItemListBox.Items.Add(BuildChapterListCaption(I, FProject[I]));
  finally
    ItemListBox.Items.EndUpdate;
  end;
end;

procedure TMainForm.RefreshProjectView;
var
  CoverPath: string;
  ChapterCount: Integer;
begin
  if not Assigned(FProject) then
  begin
    ProjectTitleLabel.Caption := 'Kein Projekt geladen';
    ProjectSubtitleLabel.Caption := '';
    ProjectAuthorLabel.Caption := '';
    ProjectStatsLabel.Caption := 'Lege ein neues Projekt an oder öffne einen vorhandenen Ordner.';
    ProjectStatusLabel.Caption := '';
    OfficeSummaryLabel.Caption := OfficeAvailabilitySummary;
    ProjectNotesMemo.Text := '';
    CoverImage.Picture.Clear;
    Exit;
  end;

  ChapterCount := 0;
  if FProject.CoverImagePath <> '' then
  begin
    CoverPath := TProjectStore.AbsolutePath(FProject.FolderPath, FProject.CoverImagePath);
    if FileExists(CoverPath) then
      CoverImage.Picture.LoadFromFile(CoverPath)
    else
      CoverImage.Picture.Clear;
  end
  else
    CoverImage.Picture.Clear;

  ProjectTitleLabel.Caption := FProject.Title;
  ProjectSubtitleLabel.Caption := FProject.Subtitle;
  if Trim(FProject.Author) <> '' then
    ProjectAuthorLabel.Caption := 'Autor: ' + FProject.Author
  else
    ProjectAuthorLabel.Caption := 'Autor: -';

  ChapterCount := ChapterSequenceForIndex(FProject.Count - 1);
  if ChapterCount = 0 then
    ProjectStatsLabel.Caption := Format(
      'Projektordner: %s%sNoch keine Kapitel angelegt. Klicke auf "Anlegen", um zu starten.',
      [FProject.FolderPath, LineEnding])
  else
    ProjectStatsLabel.Caption := Format(
      'Projektordner: %s%sKapitel: %d%sGesamtwortzahl: %d',
      [FProject.FolderPath, LineEnding, ChapterCount, LineEnding, ProjectWordCount]);
  ProjectStatusLabel.Caption := 'Projektstatus: ' + ProjectStatusSummary;
  OfficeSummaryLabel.Caption := OfficeAvailabilitySummary;

  FUpdatingUi := True;
  try
    ProjectNotesMemo.Text := LoadTextFileSafe(AbsoluteProjectNotesFileName);
  finally
    FUpdatingUi := False;
  end;
end;

procedure TMainForm.RefreshChapterView;
var
  Item: TStructuraItem;
  FileName: string;
  Meta: TStringList;
  Sequence: Integer;
  StatusIndex: Integer;
begin
  Item := CurrentItem;
  if not Assigned(Item) then
    Exit;

  Meta := TStringList.Create;
  try
    if Item.ItemType = sitChapter then
    begin
      Sequence := ChapterSequenceForItem(Item);
      FileName := AbsoluteItemFileName(Item);
      ChapterHeadingLabel.Caption := Format('%0.2d  %s', [Sequence, Item.Title]);
      Meta.Add('Datei: ' + Item.FileName);
      Meta.Add('Geändert: ' + FileModifiedText(FileName));
      Meta.Add('Wortzahl: ' + IntToStr(ChapterWordCount(Item)));
      ChapterMetaLabel.Caption := Meta.Text;

      FCurrentPreviewText := TDocxPreview.LoadPreviewText(FileName);
      FUpdatingUi := True;
      try
        PreviewMemo.Text := FCurrentPreviewText;
        NotesMemo.Text := LoadTextFileSafe(AbsoluteItemNotesFileName(Item));
        StatusIndex := ChapterStatusCombo.Items.IndexOf(Item.Status);
        if StatusIndex < 0 then
        begin
          if Trim(Item.Status) <> '' then
            ChapterStatusCombo.Items.Add(Item.Status);
          StatusIndex := ChapterStatusCombo.Items.IndexOf(Item.Status);
        end;
        ChapterStatusCombo.ItemIndex := StatusIndex;
      finally
        FUpdatingUi := False;
      end;
      ChapterStatusLabel.Enabled := True;
      ChapterStatusCombo.Enabled := True;
      NotesMemo.Enabled := True;
      PreviewMemo.Enabled := True;
      NotesLabel.Caption := 'Kapitelnotizen (.md)';
      PreviewLabel.Caption := 'Textvorschau';
    end
    else
    begin
      ChapterHeadingLabel.Caption := 'Trenner: ' + Item.Title;
      ChapterMetaLabel.Caption := 'Dieser Eintrag gliedert das Buch in Teile und besitzt keine Kapiteldatei.';
      FCurrentPreviewText := '';
      FUpdatingUi := True;
      try
        PreviewMemo.Text := 'Kein Kapitel ausgewählt.';
        NotesMemo.Text := '';
        ChapterStatusCombo.ItemIndex := -1;
      finally
        FUpdatingUi := False;
      end;
      ChapterStatusLabel.Enabled := False;
      ChapterStatusCombo.Enabled := False;
      NotesMemo.Enabled := False;
      PreviewMemo.Enabled := False;
      NotesLabel.Caption := 'Keine Notizen für Trenner';
      PreviewLabel.Caption := 'Keine Vorschau';
    end;
  finally
    Meta.Free;
  end;

  RefreshActionButtons;
end;

procedure TMainForm.RefreshActionButtons;
var
  ChapterAvailable: Boolean;
begin
  ChapterAvailable := Assigned(CurrentChapter);
  AddButton.Enabled := Assigned(FProject);
  EditButton.Enabled := Assigned(CurrentItem);
  DeleteButton.Enabled := Assigned(CurrentItem);
  OpenChapterButton.Enabled := ChapterAvailable;
  OpenFolderButton.Enabled := ChapterAvailable;
  PdfPreviewButton.Enabled := ChapterAvailable and (FOfficeTargets.LibreOfficePath <> '');
  WordButton.Enabled := ChapterAvailable and (FOfficeTargets.WordPath <> '');
  LibreButton.Enabled := ChapterAvailable and (FOfficeTargets.LibreOfficePath <> '');
  TextMakerButton.Enabled := ChapterAvailable and (FOfficeTargets.TextMakerPath <> '');
  CopyTextButton.Enabled := ChapterAvailable and (Trim(FCurrentPreviewText) <> '');
  GrammarlyButton.Enabled := ChapterAvailable and (Trim(FCurrentPreviewText) <> '');
  ExportButton.Enabled := Assigned(FProject);
end;

procedure TMainForm.PopulateStatusChoices;
var
  StatusValue: string;
begin
  ChapterStatusCombo.Items.Clear;
  for StatusValue in STRUCTURA_STATUSES do
    ChapterStatusCombo.Items.Add(StatusValue);
end;

procedure TMainForm.SelectProjectOverview;
begin
  FSelectedIndex := -1;
  FUpdatingUi := True;
  try
    ItemListBox.ItemIndex := -1;
    ProjectPanel.Visible := True;
    ChapterPanel.Visible := False;
  finally
    FUpdatingUi := False;
  end;
  RefreshProjectView;
  RefreshActionButtons;
end;

procedure TMainForm.SelectItem(Index: Integer);
begin
  if not Assigned(FProject) then
  begin
    SelectProjectOverview;
    Exit;
  end;
  if (Index < 0) or (Index >= FProject.Count) then
  begin
    SelectProjectOverview;
    Exit;
  end;

  FSelectedIndex := Index;
  FUpdatingUi := True;
  try
    ItemListBox.ItemIndex := Index;
    ProjectPanel.Visible := False;
    ChapterPanel.Visible := True;
  finally
    FUpdatingUi := False;
  end;
  RefreshChapterView;
end;

function TMainForm.CurrentItem: TStructuraItem;
begin
  Result := nil;
  if Assigned(FProject) and (FSelectedIndex >= 0) and (FSelectedIndex < FProject.Count) then
    Result := FProject[FSelectedIndex];
end;

function TMainForm.CurrentChapter: TStructuraItem;
begin
  Result := CurrentItem;
  if Assigned(Result) and (Result.ItemType <> sitChapter) then
    Result := nil;
end;

function TMainForm.AbsoluteItemFileName(AItem: TStructuraItem): string;
begin
  if not Assigned(FProject) or not Assigned(AItem) then
    Exit('');
  Result := TProjectStore.AbsolutePath(FProject.FolderPath, AItem.FileName);
end;

function TMainForm.AbsoluteItemNotesFileName(AItem: TStructuraItem): string;
begin
  if not Assigned(FProject) or not Assigned(AItem) then
    Exit('');
  if Trim(AItem.NotesFileName) = '' then
    AItem.NotesFileName := RelativeProjectPath(['notes', AItem.Id + '.md']);
  Result := TProjectStore.AbsolutePath(FProject.FolderPath, AItem.NotesFileName);
end;

function TMainForm.AbsoluteProjectNotesFileName: string;
begin
  if not Assigned(FProject) then
    Exit('');
  if Trim(FProject.ProjectNotesFileName) = '' then
    FProject.ProjectNotesFileName := RelativeProjectPath(['notes', 'project.md']);
  Result := TProjectStore.AbsolutePath(FProject.FolderPath, FProject.ProjectNotesFileName);
end;

function TMainForm.LoadTextFileSafe(const AFileName: string): string;
begin
  if (AFileName = '') or (not FileExists(AFileName)) then
    Exit('');
  Result := TrimRight(ReadFileToString(AFileName));
end;

procedure TMainForm.SaveTextFileSafe(const AFileName, AText: string);
var
  Content: TStringList;
begin
  if AFileName = '' then
    Exit;
  ForceDirectories(ExtractFileDir(AFileName));
  Content := TStringList.Create;
  try
    Content.Text := AText;
    Content.SaveToFile(AFileName);
  finally
    Content.Free;
  end;
end;

function TMainForm.ChapterSequenceForIndex(AIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  if not Assigned(FProject) then
    Exit;
  for I := 0 to Min(AIndex, FProject.Count - 1) do
    if FProject[I].ItemType = sitChapter then
      Inc(Result);
end;

function TMainForm.ChapterSequenceForItem(AItem: TStructuraItem): Integer;
var
  I: Integer;
begin
  Result := 0;
  if not Assigned(FProject) or not Assigned(AItem) then
    Exit;
  for I := 0 to FProject.Count - 1 do
  begin
    if FProject[I].ItemType = sitChapter then
      Inc(Result);
    if FProject[I] = AItem then
      Exit;
  end;
end;

function TMainForm.BuildChapterFileName(AItem: TStructuraItem; AListIndex: Integer): string;
var
  Extension: string;
  Sequence: Integer;
begin
  Extension := ExtractFileExt(AItem.FileName);
  if Extension = '' then
    Extension := '.docx';
  Sequence := ChapterSequenceForIndex(AListIndex);
  Result := RelativeProjectPath([
    'chapters',
    Format('%0.2d_%s%s', [Sequence, MakeSafeFileNamePart(AItem.Title), Extension])
  ]);
end;

function TMainForm.BuildChapterListCaption(AIndex: Integer; AItem: TStructuraItem): string;
begin
  if AItem.ItemType = sitDivider then
    Exit('--- ' + AItem.Title + ' ---');

  Result := Format('%0.2d  %s', [ChapterSequenceForIndex(AIndex), AItem.Title]);
  if Trim(AItem.Status) <> '' then
    Result := Result + '  [' + AItem.Status + ']';
end;

function TMainForm.EnsureUniqueRelativeFileName(const ARelative: string): string;
var
  Folder, BaseName, Extension, Candidate: string;
  Counter: Integer;
begin
  Folder := ExtractFilePath(ARelative);
  BaseName := ChangeFileExt(ExtractFileName(ARelative), '');
  Extension := ExtractFileExt(ARelative);
  Counter := 1;
  Candidate := ARelative;
  while FileExists(TProjectStore.AbsolutePath(FProject.FolderPath, Candidate)) do
  begin
    Candidate := Folder + BaseName + '_' + IntToStr(Counter) + Extension;
    Inc(Counter);
  end;
  Result := Candidate;
end;

function TMainForm.MakeSafeFileNamePart(const AValue: string): string;
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

function TMainForm.CreateBackupCopy(const AAbsoluteFileName: string): Boolean;
var
  BackupFolder: string;
  TargetFile: string;
begin
  Result := True;
  if (AAbsoluteFileName = '') or (not FileExists(AAbsoluteFileName)) or
     (not Assigned(FProject)) then
    Exit;
  BackupFolder := IncludeTrailingPathDelimiter(FProject.FolderPath) + 'backup' +
    PathDelim + FormatDateTime('yyyy-mm-dd_hh-nn', Now);
  ForceDirectories(BackupFolder);
  TargetFile := IncludeTrailingPathDelimiter(BackupFolder) + ExtractFileName(AAbsoluteFileName);
  Result := CopyFile(AAbsoluteFileName, TargetFile, [cffOverwriteFile]);
end;

function TMainForm.RenameChapterFile(AItem: TStructuraItem; AListIndex: Integer): Boolean;
var
  OldAbsolute: string;
  NewRelative: string;
  NewAbsolute: string;
begin
  Result := True;
  if not Assigned(AItem) or (AItem.ItemType <> sitChapter) then
    Exit;
  OldAbsolute := AbsoluteItemFileName(AItem);
  if not FileExists(OldAbsolute) then
  begin
    AItem.FileName := BuildChapterFileName(AItem, AListIndex);
    Exit;
  end;

  NewRelative := BuildChapterFileName(AItem, AListIndex);
  if SameText(NormalizeStoredPathForCompare(AItem.FileName),
    NormalizeStoredPathForCompare(NewRelative)) then
    Exit;

  NewAbsolute := TProjectStore.AbsolutePath(FProject.FolderPath, NewRelative);
  if FileExists(NewAbsolute) then
    NewRelative := EnsureUniqueRelativeFileName(NewRelative);
  NewAbsolute := TProjectStore.AbsolutePath(FProject.FolderPath, NewRelative);

  if not CreateBackupCopy(OldAbsolute) then
  begin
    MessageDlg('Backup fehlgeschlagen',
      'Vor dem Umbenennen konnte kein Backup erstellt werden.',
      mtError, [mbOK], 0);
    Exit(False);
  end;

  ForceDirectories(ExtractFileDir(NewAbsolute));
  if not RenameFile(OldAbsolute, NewAbsolute) then
  begin
    MessageDlg('Datei konnte nicht umbenannt werden',
      'Bitte prüfe, ob die Kapiteldatei gerade in einem anderen Programm geöffnet ist.',
      mtError, [mbOK], 0);
    Exit(False);
  end;

  AItem.FileName := NewRelative;
end;

function TMainForm.RenumberChapterFiles: Boolean;
var
  I, ChapterNo: Integer;
  Item: TStructuraItem;
  OldAbsolute, TempAbsolute, FinalRelative, FinalAbsolute: string;
  TempNames, FinalNames: TStringList;
begin
  Result := True;
  if not Assigned(FProject) then
    Exit;

  TempNames := TStringList.Create;
  FinalNames := TStringList.Create;
  try
    ChapterNo := 0;
    for I := 0 to FProject.Count - 1 do
    begin
      Item := FProject[I];
      if Item.ItemType <> sitChapter then
        Continue;
      Inc(ChapterNo);
      FinalRelative := BuildChapterFileName(Item, I);
      FinalNames.Add(FinalRelative);

      OldAbsolute := AbsoluteItemFileName(Item);
      if FileExists(OldAbsolute) then
      begin
        if not CreateBackupCopy(OldAbsolute) then
          Exit(False);
        TempAbsolute := IncludeTrailingPathDelimiter(ExtractFileDir(OldAbsolute)) +
          '__renumber_' + IntToStr(ChapterNo) + '_' + ExtractFileName(OldAbsolute);
        if not RenameFile(OldAbsolute, TempAbsolute) then
          Exit(False);
        TempNames.Add(TempAbsolute);
      end
      else
        TempNames.Add('');
    end;

    ChapterNo := 0;
    for I := 0 to FProject.Count - 1 do
    begin
      Item := FProject[I];
      if Item.ItemType <> sitChapter then
        Continue;
      FinalRelative := FinalNames[ChapterNo];
      FinalAbsolute := TProjectStore.AbsolutePath(FProject.FolderPath, FinalRelative);
      if TempNames[ChapterNo] <> '' then
      begin
        ForceDirectories(ExtractFileDir(FinalAbsolute));
        if not RenameFile(TempNames[ChapterNo], FinalAbsolute) then
          Exit(False);
      end;
      Item.FileName := FinalRelative;
      Inc(ChapterNo);
    end;
  finally
    TempNames.Free;
    FinalNames.Free;
  end;
end;

function WordCountFromText(const AText: string): Integer;
var
  I: Integer;
  InWord: Boolean;
begin
  Result := 0;
  InWord := False;
  for I := 1 to Length(AText) do
  begin
    if AText[I] > ' ' then
    begin
      if not InWord then
      begin
        Inc(Result);
        InWord := True;
      end;
    end
    else
      InWord := False;
  end;
end;

function TMainForm.ChapterWordCount(AItem: TStructuraItem): Integer;
begin
  if not Assigned(AItem) or (AItem.ItemType <> sitChapter) then
    Exit(0);
  Result := WordCountFromText(TDocxPreview.LoadPreviewText(AbsoluteItemFileName(AItem)));
end;

function TMainForm.ProjectWordCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if not Assigned(FProject) then
    Exit;
  for I := 0 to FProject.Count - 1 do
    if FProject[I].ItemType = sitChapter then
      Inc(Result, ChapterWordCount(FProject[I]));
end;

function TMainForm.FileModifiedText(const AFileName: string): string;
var
  Age: LongInt;
begin
  if (AFileName = '') or (not FileExists(AFileName)) then
    Exit('Datei fehlt');
  Age := FileAge(AFileName);
  if Age = -1 then
    Exit('Unbekannt');
  Result := FormatDateTime('dd.mm.yyyy hh:nn', FileDateToDateTime(Age));
end;

function TMainForm.ProjectStatusSummary: string;
var
  I: Integer;
  FinalCount, ProblemCount, WorkingCount: Integer;
begin
  FinalCount := 0;
  ProblemCount := 0;
  WorkingCount := 0;
  if not Assigned(FProject) then
    Exit('Kein Projekt geladen');
  for I := 0 to FProject.Count - 1 do
  begin
    if FProject[I].ItemType <> sitChapter then
      Continue;
    if SameText(FProject[I].Status, 'Final') then
      Inc(FinalCount)
    else if SameText(FProject[I].Status, 'Problem') then
      Inc(ProblemCount)
    else
      Inc(WorkingCount);
  end;
  Result := Format('%d final, %d in Arbeit, %d mit Problemstatus',
    [FinalCount, WorkingCount, ProblemCount]);
end;

function TMainForm.OfficeAvailabilitySummary: string;
begin
  Result := 'Verfügbare Programme:' + LineEnding +
    'Standard-DOCX: über Betriebssystem' + LineEnding +
    'Word: ' + IfThen(FOfficeTargets.WordPath <> '', 'gefunden', 'nicht gefunden') + LineEnding +
    'LibreOffice: ' + IfThen(FOfficeTargets.LibreOfficePath <> '', 'gefunden', 'nicht gefunden') + LineEnding +
    'TextMaker: ' + IfThen(FOfficeTargets.TextMakerPath <> '', 'gefunden', 'nicht gefunden');
end;

procedure TMainForm.OpenCurrentChapterWithExecutable(const AExecutable: string);
var
  Proc: TProcess;
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit;
  if AExecutable = '' then
    Exit;
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := AExecutable;
    Proc.Parameters.Add(AbsoluteItemFileName(Chapter));
    Proc.Options := [];
    Proc.Execute;
  finally
    Proc.Free;
  end;
end;

procedure TMainForm.ShowInFileManager(const AFileName: string);
var
  Proc: TProcess;
begin
  if AFileName = '' then
    Exit;
  Proc := TProcess.Create(nil);
  try
    {$IFDEF WINDOWS}
    Proc.Executable := 'explorer.exe';
    Proc.Parameters.Add('/select,' + AFileName);
    {$ELSE}
    Proc.Executable := 'xdg-open';
    Proc.Parameters.Add(ExtractFileDir(AFileName));
    {$ENDIF}
    Proc.Execute;
  finally
    Proc.Free;
  end;
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  StatusBar.SimpleText := AText;
end;

procedure TMainForm.NewProjectClick(Sender: TObject);
var
  DialogResult: TProjectDialogResult;
  Project: TStructuraProject;
  CoverSource, CoverTarget, CoverRelative: string;
begin
  DialogResult := ExecuteProjectDialog(FLastProjectFolder);
  if not DialogResult.Confirmed then
    Exit;

  ForceDirectories(DialogResult.FolderPath);
  Project := TStructuraProject.Create;
  TProjectStore.CreateBlankProject(Project, DialogResult.FolderPath, DialogResult.Title);
  Project.Title := DialogResult.Title;
  Project.Subtitle := DialogResult.Subtitle;
  Project.Author := DialogResult.Author;

  if Trim(DialogResult.CoverImagePath) <> '' then
  begin
    CoverSource := DialogResult.CoverImagePath;
    CoverRelative := 'cover' + LowerCase(ExtractFileExt(CoverSource));
    CoverTarget := IncludeTrailingPathDelimiter(DialogResult.FolderPath) + CoverRelative;
    CopyFile(CoverSource, CoverTarget, [cffOverwriteFile]);
    Project.CoverImagePath := CoverRelative;
  end;

  SaveTextFileSafe(TProjectStore.AbsolutePath(DialogResult.FolderPath,
    RelativeProjectPath(['notes', 'project.md'])),
    '# Projektnotizen' + LineEnding + LineEnding);
  TProjectStore.SaveToFolder(Project);
  SetProject(Project);
  UpdateStatus('Projekt angelegt: ' + DialogResult.Title);
end;

procedure TMainForm.OpenProjectClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := FLastProjectFolder;
  if not SelectDirectory('Projektordner wählen', '', Folder) then
    Exit;
  try
    PersistCurrentNotes;
    LoadProjectFromFolder(Folder);
  except
    on E: Exception do
      MessageDlg('Projekt konnte nicht geladen werden', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TMainForm.AddItemClick(Sender: TObject);
var
  ResultData: TElementDialogResult;
  NewItem: TStructuraItem;
  RelativeFileName, ErrorText: string;
  AbsoluteFileName: string;
begin
  if not Assigned(FProject) then
  begin
    MessageDlg('Projekt fehlt', 'Bitte zuerst ein Projekt anlegen oder öffnen.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  ResultData := ExecuteElementDialog(edmCreate, 'Element anlegen', 'Neues Kapitel',
    sitChapter, csmCreateDocx);
  if not ResultData.Confirmed then
    Exit;

  if ResultData.ItemType = sitDivider then
  begin
    FProject.AddDivider(ResultData.Title);
    SaveProject;
    RefreshAll;
    SelectItem(FProject.Count - 1);
    Exit;
  end;

  NewItem := FProject.AddChapter(ResultData.Title, '');
  NewItem.Status := DefaultChapterStatus;
  NewItem.FileName := BuildChapterFileName(NewItem, FProject.Count - 1);
  AbsoluteFileName := AbsoluteItemFileName(NewItem);
  ForceDirectories(ExtractFileDir(AbsoluteFileName));

  if ResultData.ChapterSource = csmImportDocx then
  begin
    if not TDocumentWorkflow.ImportChapterFile(ResultData.ImportFileName,
      FProject.FolderPath, ResultData.Title, RelativeFileName, ErrorText) then
    begin
      FProject.DeleteItem(FProject.Count - 1);
      MessageDlg('Import fehlgeschlagen', ErrorText, mtError, [mbOK], 0);
      Exit;
    end;
    NewItem.FileName := RelativeFileName;
  end
  else
  begin
    if not TDocumentWorkflow.CreateBlankDocx(AbsoluteFileName, ResultData.Title, ErrorText) then
    begin
      FProject.DeleteItem(FProject.Count - 1);
      MessageDlg('Kapitel konnte nicht angelegt werden', ErrorText, mtError, [mbOK], 0);
      Exit;
    end;
  end;

  SaveTextFileSafe(AbsoluteItemNotesFileName(NewItem), '');
  SaveProject;
  RefreshAll;
  SelectItem(FProject.Count - 1);
end;

procedure TMainForm.EditItemClick(Sender: TObject);
var
  Item: TStructuraItem;
  ResultData: TElementDialogResult;
begin
  Item := CurrentItem;
  if not Assigned(Item) then
    Exit;

  ResultData := ExecuteElementDialog(edmEdit, 'Element bearbeiten',
    Item.Title, Item.ItemType, csmCreateDocx);
  if not ResultData.Confirmed then
    Exit;

  Item.Title := ResultData.Title;
  if Item.ItemType = sitChapter then
    if not RenameChapterFile(Item, FSelectedIndex) then
      Exit;

  SaveProject;
  RefreshAll;
  SelectItem(FSelectedIndex);
  UpdateStatus('Element aktualisiert.');
end;

procedure TMainForm.DeleteItemClick(Sender: TObject);
var
  Item: TStructuraItem;
  NotesFileName: string;
begin
  Item := CurrentItem;
  if not Assigned(Item) then
    Exit;

  if MessageDlg('Eintrag löschen',
    'Soll "' + Item.Title + '" wirklich aus der Struktur entfernt werden?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  NotesFileName := AbsoluteItemNotesFileName(Item);
  if (NotesFileName <> '') and FileExists(NotesFileName) then
    DeleteFile(NotesFileName);
  FProject.DeleteItem(FSelectedIndex);
  SaveProject;
  RefreshAll;
  SelectProjectOverview;
  UpdateStatus('Eintrag entfernt.');
end;

procedure TMainForm.ItemListSelectionChange(Sender: TObject; User: boolean);
begin
  if FUpdatingUi then
    Exit;
  PersistCurrentNotes;
  if ItemListBox.ItemIndex >= 0 then
    SelectItem(ItemListBox.ItemIndex)
  else
    SelectProjectOverview;
end;

procedure TMainForm.ItemListDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Source = ItemListBox;
end;

procedure TMainForm.ItemListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  FromIndex, ToIndex: Integer;
begin
  if not Assigned(FProject) then
    Exit;
  FromIndex := ItemListBox.ItemIndex;
  ToIndex := ItemListBox.ItemAtPos(Point(X, Y), True);
  if ToIndex < 0 then
    ToIndex := FProject.Count - 1;
  if (FromIndex < 0) or (ToIndex < 0) or (FromIndex = ToIndex) then
    Exit;

  PersistCurrentNotes;
  FProject.MoveItem(FromIndex, ToIndex);
  if MessageDlg('Dateinummern aktualisieren',
    'Sollen die Kapiteldateien passend zur neuen Reihenfolge umbenannt werden?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    if not RenumberChapterFiles then
      MessageDlg('Umbenennung unvollständig',
        'Einige Kapiteldateien konnten nicht sauber umbenannt werden.',
        mtWarning, [mbOK], 0);
  SaveProject;
  RefreshAll;
  SelectItem(ToIndex);
  UpdateStatus('Reihenfolge aktualisiert.');
end;

procedure TMainForm.ProjectNotesExit(Sender: TObject);
begin
  PersistProjectNotes;
  SaveProject;
end;

procedure TMainForm.NotesExit(Sender: TObject);
begin
  PersistChapterNotes;
  SaveProject;
end;

procedure TMainForm.StatusChanged(Sender: TObject);
var
  Item: TStructuraItem;
begin
  if FUpdatingUi then
    Exit;
  Item := CurrentChapter;
  if not Assigned(Item) then
    Exit;
  Item.Status := ChapterStatusCombo.Text;
  SaveProject;
  RefreshItemList;
  ItemListBox.ItemIndex := FSelectedIndex;
  RefreshProjectView;
end;

procedure TMainForm.OpenChapterClick(Sender: TObject);
var
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit;
  if not OpenDocument(AbsoluteItemFileName(Chapter)) then
    MessageDlg('Datei konnte nicht geöffnet werden',
      'Das Standardprogramm für diese Kapiteldatei konnte nicht gestartet werden.',
      mtError, [mbOK], 0);
end;

procedure TMainForm.OpenFolderClick(Sender: TObject);
var
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit;
  ShowInFileManager(AbsoluteItemFileName(Chapter));
end;

procedure TMainForm.PdfPreviewClick(Sender: TObject);
var
  PdfFileName, ErrorText: string;
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit;
  if not TDocumentWorkflow.GenerateChapterPdf(FProject.FolderPath, Chapter,
    PdfFileName, ErrorText) then
  begin
    MessageDlg('PDF-Vorschau fehlgeschlagen', ErrorText, mtError, [mbOK], 0);
    Exit;
  end;
  OpenDocument(PdfFileName);
end;

procedure TMainForm.WordClick(Sender: TObject);
begin
  OpenCurrentChapterWithExecutable(FOfficeTargets.WordPath);
end;

procedure TMainForm.LibreClick(Sender: TObject);
begin
  OpenCurrentChapterWithExecutable(FOfficeTargets.LibreOfficePath);
end;

procedure TMainForm.TextMakerClick(Sender: TObject);
begin
  OpenCurrentChapterWithExecutable(FOfficeTargets.TextMakerPath);
end;

procedure TMainForm.CopyTextClick(Sender: TObject);
begin
  Clipboard.AsText := FCurrentPreviewText;
  UpdateStatus('Kapiteltext in die Zwischenablage kopiert.');
end;

procedure TMainForm.GrammarlyClick(Sender: TObject);
begin
  if Trim(FCurrentPreviewText) <> '' then
    Clipboard.AsText := FCurrentPreviewText;
  OpenURL('https://app.grammarly.com/');
  UpdateStatus('Grammarly geöffnet. Der Kapiteltext liegt in der Zwischenablage.');
end;

procedure TMainForm.ExportClick(Sender: TObject);
var
  InfoText: string;
begin
  if not Assigned(FProject) then
    Exit;
  PersistCurrentNotes;
  if TDocumentWorkflow.ExportMasterDocument(FProject, InfoText) then
    MessageDlg('Export abgeschlossen', InfoText, mtInformation, [mbOK], 0)
  else
    MessageDlg('Export fehlgeschlagen', InfoText, mtError, [mbOK], 0);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  try
    PersistCurrentNotes;
    SaveProject;
  except
    on E: Exception do
    begin
      CanClose := False;
      MessageDlg('Speichern fehlgeschlagen', E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

end.
