unit MainFormUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ComCtrls, Menus, StructuraTypes, OfficeDetection, AppSettings;

type
  TMainForm = class(TForm)
  private
    FProject: TStructuraProject;
    FSelectedIndex: Integer;
    FUpdatingUi: Boolean;
    FOfficeTargets: TOfficeTargets;
    FSettings: TAppSettings;
    FLastProjectFolder: string;
    FCurrentPreviewText: string;
    FWorkflowButtons: array of TMenuItem;
    FOpenPopupMenu: TPopupMenu;
    FReviewPopupMenu: TPopupMenu;
    FCopyPopupMenu: TPopupMenu;
    FExportPopupMenu: TPopupMenu;
    FBackLabel: TLabel;
    FProjectCards: array of TPanel;
    FDeferredProjectFolder: string;
    procedure ConfigureUi;
    procedure RebuildProjectCards;
    procedure ClearProjectCards;
    procedure ProjectCardClick(Sender: TObject);
    procedure LoadProjectDeferred(Data: PtrInt);
    procedure LoadButtonGlyph(AButton: TBitBtn; const AFileName: string);
    procedure ApplyOfficeOverrides;
    procedure SyncDetectedTargetsToSettings;
    procedure RefreshWorkflowButtons;
    procedure BuildPopupMenus;
    procedure RebuildOpenPopupMenu;
    procedure RebuildCopyPopupMenu;
    procedure RebuildExportPopupMenu;
    procedure ShowPopupMenuBelow(AControl: TControl; AMenu: TPopupMenu);
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
    function BuildWorkflowCopyText(AConfig: TWorkflowButtonConfig): string;
    function BuildMarkdownCopyText: string;
    procedure OpenCurrentChapterWithExecutable(const AExecutable: string);
    procedure ShowInFileManager(const AFileName: string);
    procedure UpdateStatus(const AText: string);
    procedure WorkflowButtonClick(Sender: TObject);
    procedure CopyTitleAndTextClick(Sender: TObject);
    procedure CopyPromptAndTextClick(Sender: TObject);
    procedure CopyMarkdownClick(Sender: TObject);
    procedure ExportFolderClick(Sender: TObject);
    procedure OpenProjectFolderClick(Sender: TObject);
    procedure BackToOverviewClick(Sender: TObject);
    procedure DrawCoverPlaceholder;
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
    ImportButton: TBitBtn;
    SettingsButton: TBitBtn;
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
    procedure ProjectNotesChanged(Sender: TObject);
    procedure NotesExit(Sender: TObject);
    procedure NotesChanged(Sender: TObject);
    procedure StatusChanged(Sender: TObject);
    procedure OpenChapterClick(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure PdfPreviewClick(Sender: TObject);
    procedure WordClick(Sender: TObject);
    procedure LibreClick(Sender: TObject);
    procedure TextMakerClick(Sender: TObject);
    procedure CopyTextClick(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure ReviewMenuClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);
    procedure ExportMenuClick(Sender: TObject);
    procedure ImportProjectClick(Sender: TObject);
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
  DocxPreview, SettingsStore, SettingsDialogUnit, FirstRunWizardUnit,
  ImportProjectDialogUnit;

function NormalizeStoredPathForCompare(const APath: string): string;
begin
  Result := StringReplace(APath, '\', '/', [rfReplaceAll]);
end;

function TryLaunchDetachedProcess(const AExecutable: string;
  const AParameters: array of string; out ErrorText: string): Boolean;
var
  Proc: TProcess;
  I: Integer;
begin
  Result := False;
  ErrorText := '';
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := AExecutable;
    for I := Low(AParameters) to High(AParameters) do
      Proc.Parameters.Add(AParameters[I]);
    Proc.Options := [];
    try
      Proc.Execute;
      Result := True;
    except
      on E: Exception do
        ErrorText := E.Message;
    end;
  finally
    Proc.Free;
  end;
end;

procedure TMainForm.ConfigureUi;
begin
  Constraints.MinWidth := 900;
  Constraints.MinHeight := 600;
  WindowState := wsMaximized;
  ProjectPanel.Visible := True;
  ChapterPanel.Visible := False;
  ChapterActionPanel.AutoWrap := True;
  ChapterActionPanel.FlowStyle := fsLeftRightTopBottom;
  StatusBar.SimplePanel := True;
  WordButton.Visible := False;
  LibreButton.Visible := False;
  TextMakerButton.Visible := False;
  OpenFolderButton.Visible := False;
  PdfPreviewButton.Visible := False;
  CopyTextButton.Visible := False;
  OpenChapterButton.Caption := 'Öffnen mit ▼';
  WordButton.Caption := 'Prüfen mit ▼';
  LibreButton.Caption := 'Kopieren ▼';
  ExportButton.Caption := 'Export ▼';
  WordButton.Visible := True;
  LibreButton.Visible := True;

  FBackLabel := TLabel.Create(Self);
  FBackLabel.Parent := ChapterPanel;
  FBackLabel.Left := 24;
  FBackLabel.Top := 2;
  FBackLabel.Caption := '← Projektübersicht';
  FBackLabel.Cursor := crHandPoint;
  FBackLabel.Font.Color := $006B3D1E;
  FBackLabel.OnClick := @BackToOverviewClick;
end;

procedure TMainForm.ApplyOfficeOverrides;
begin
  if not Assigned(FSettings) then
    Exit;

  if Trim(FSettings.WordPathOverride) <> '' then
    FOfficeTargets.WordPath := FSettings.WordPathOverride;
  if Trim(FSettings.LibreOfficePathOverride) <> '' then
    FOfficeTargets.LibreOfficePath := FSettings.LibreOfficePathOverride;
  if Trim(FSettings.TextMakerPathOverride) <> '' then
    FOfficeTargets.TextMakerPath := FSettings.TextMakerPathOverride;
end;

procedure TMainForm.SyncDetectedTargetsToSettings;
var
  SettingsChanged: Boolean;
begin
  if not Assigned(FSettings) then
    Exit;

  SettingsChanged := False;
  if (Trim(FSettings.WordPathOverride) = '') and (Trim(FOfficeTargets.WordPath) <> '') then
  begin
    FSettings.WordPathOverride := FOfficeTargets.WordPath;
    SettingsChanged := True;
  end;
  if (Trim(FSettings.LibreOfficePathOverride) = '') and (Trim(FOfficeTargets.LibreOfficePath) <> '') then
  begin
    FSettings.LibreOfficePathOverride := FOfficeTargets.LibreOfficePath;
    SettingsChanged := True;
  end;
  if (Trim(FSettings.TextMakerPathOverride) = '') and (Trim(FOfficeTargets.TextMakerPath) <> '') then
  begin
    FSettings.TextMakerPathOverride := FOfficeTargets.TextMakerPath;
    SettingsChanged := True;
  end;

  if SettingsChanged then
    TSettingsStore.Save(FSettings);
end;

procedure TMainForm.RefreshWorkflowButtons;
var
  I: Integer;
  Item: TMenuItem;
begin
  if Assigned(FReviewPopupMenu) then
    FReviewPopupMenu.Items.Clear;
  SetLength(FWorkflowButtons, 0);

  if not Assigned(FSettings) then
    Exit;

  SetLength(FWorkflowButtons, FSettings.WorkflowButtonCount);
  for I := 0 to FSettings.WorkflowButtonCount - 1 do
  begin
    Item := TMenuItem.Create(Self);
    Item.Caption := FSettings.WorkflowButtons[I].Name;
    Item.Hint := FSettings.WorkflowButtons[I].Hint;
    Item.Tag := I;
    Item.OnClick := @WorkflowButtonClick;
    FReviewPopupMenu.Items.Add(Item);
    FWorkflowButtons[I] := Item;
  end;
end;

procedure TMainForm.BuildPopupMenus;
begin
  FOpenPopupMenu := TPopupMenu.Create(Self);
  FReviewPopupMenu := TPopupMenu.Create(Self);
  FCopyPopupMenu := TPopupMenu.Create(Self);
  FExportPopupMenu := TPopupMenu.Create(Self);
  RebuildOpenPopupMenu;
  RebuildCopyPopupMenu;
  RebuildExportPopupMenu;
end;

procedure TMainForm.RebuildOpenPopupMenu;
var
  Item: TMenuItem;
begin
  FOpenPopupMenu.Items.Clear;

  Item := TMenuItem.Create(FOpenPopupMenu);
  Item.Caption := 'Standardprogramm';
  Item.OnClick := @OpenChapterClick;
  FOpenPopupMenu.Items.Add(Item);

  if Trim(FOfficeTargets.WordPath) <> '' then
  begin
    Item := TMenuItem.Create(FOpenPopupMenu);
    Item.Caption := 'Word';
    Item.OnClick := @WordClick;
    FOpenPopupMenu.Items.Add(Item);
  end;

  if Trim(FOfficeTargets.LibreOfficePath) <> '' then
  begin
    Item := TMenuItem.Create(FOpenPopupMenu);
    Item.Caption := 'LibreOffice';
    Item.OnClick := @LibreClick;
    FOpenPopupMenu.Items.Add(Item);
  end;

  if Trim(FOfficeTargets.TextMakerPath) <> '' then
  begin
    Item := TMenuItem.Create(FOpenPopupMenu);
    Item.Caption := 'TextMaker';
    Item.OnClick := @TextMakerClick;
    FOpenPopupMenu.Items.Add(Item);
  end;

  Item := TMenuItem.Create(FOpenPopupMenu);
  Item.Caption := '-';
  FOpenPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FOpenPopupMenu);
  Item.Caption := 'Im Explorer anzeigen';
  Item.OnClick := @OpenFolderClick;
  FOpenPopupMenu.Items.Add(Item);
end;

procedure TMainForm.RebuildCopyPopupMenu;
var
  Item: TMenuItem;
begin
  FCopyPopupMenu.Items.Clear;

  Item := TMenuItem.Create(FCopyPopupMenu);
  Item.Caption := 'Nur Kapiteltext';
  Item.OnClick := @CopyTextClick;
  FCopyPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FCopyPopupMenu);
  Item.Caption := 'Titel + Kapiteltext';
  Item.OnClick := @CopyTitleAndTextClick;
  FCopyPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FCopyPopupMenu);
  Item.Caption := 'Prüfprompt + Kapiteltext';
  Item.OnClick := @CopyPromptAndTextClick;
  FCopyPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FCopyPopupMenu);
  Item.Caption := 'Markdown kopieren';
  Item.OnClick := @CopyMarkdownClick;
  FCopyPopupMenu.Items.Add(Item);
end;

procedure TMainForm.RebuildExportPopupMenu;
var
  Item: TMenuItem;
begin
  FExportPopupMenu.Items.Clear;

  Item := TMenuItem.Create(FExportPopupMenu);
  Item.Caption := 'Gesamtmanuskript exportieren';
  Item.OnClick := @ExportClick;
  FExportPopupMenu.Items.Add(Item);

  if Trim(FOfficeTargets.LibreOfficePath) <> '' then
  begin
    Item := TMenuItem.Create(FExportPopupMenu);
    Item.Caption := 'PDF über LibreOffice';
    Item.OnClick := @PdfPreviewClick;
    FExportPopupMenu.Items.Add(Item);
  end;

  Item := TMenuItem.Create(FExportPopupMenu);
  Item.Caption := '-';
  FExportPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FExportPopupMenu);
  Item.Caption := 'Projektordner öffnen';
  Item.OnClick := @OpenProjectFolderClick;
  FExportPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FExportPopupMenu);
  Item.Caption := 'Exportordner öffnen';
  Item.OnClick := @ExportFolderClick;
  FExportPopupMenu.Items.Add(Item);
end;

procedure TMainForm.ShowPopupMenuBelow(AControl: TControl; AMenu: TPopupMenu);
var
  PointOnScreen: TPoint;
begin
  PointOnScreen := AControl.ClientToScreen(Point(0, AControl.Height));
  AMenu.PopUp(PointOnScreen.X, PointOnScreen.Y);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  IsFirstRun: Boolean;
begin
  FSelectedIndex := -1;
  IsFirstRun := not FileExists(TSettingsStore.SettingsFileName);
  FSettings := TSettingsStore.Load;
  FOfficeTargets := DetectOfficeTargets;
  SyncDetectedTargetsToSettings;
  ApplyOfficeOverrides;
  ConfigureUi;
  BuildPopupMenus;
  PopulateStatusChoices;
  ConfigureButtonGlyphs;
  RebuildOpenPopupMenu;
  RebuildCopyPopupMenu;
  RebuildExportPopupMenu;
  RefreshWorkflowButtons;
  SelectProjectOverview;
  UpdateStatus('Bereit. Bitte ein Projekt anlegen oder öffnen.');

  // First-Run-Wizard beim allerersten Start
  if IsFirstRun then
  begin
    if RunFirstRunWizard(Self, FSettings) then
    begin
      TSettingsStore.Save(FSettings);
      // Kacheln neu aufbauen falls ein Projektordner gesetzt wurde
      SelectProjectOverview;
    end;
  end;
end;

destructor TMainForm.Destroy;
begin
  FSettings.Free;
  FProject.Free;
  inherited Destroy;
end;

procedure TMainForm.ConfigureButtonGlyphs;
begin
  LoadButtonGlyph(NewButton, 'assets\buttons\new_project.bmp');
  LoadButtonGlyph(OpenButton, 'assets\buttons\open_project.bmp');
  LoadButtonGlyph(SettingsButton, 'assets\buttons\edit_item.bmp');
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
  if Assigned(FSettings) then
  begin
    FSettings.AddRecentProject(AFolder);
    TSettingsStore.Save(FSettings);
  end;
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
    CoverImage.Visible := False;
    ProjectAuthorLabel.Caption := '';
    ProjectStatsLabel.Caption := '';
    ProjectStatusLabel.Caption := '';
    OfficeSummaryLabel.Visible := False;
    ProjectNotesLabel.Visible := False;
    ProjectNotesMemo.Visible := False;
    ProjectNotesMemo.Text := '';
    CoverImage.Picture.Clear;
    if Assigned(FSettings) and (FSettings.RecentProjectCount > 0) then
    begin
      ProjectTitleLabel.Caption := 'Zuletzt geöffnet';
      ProjectSubtitleLabel.Caption := '';
    end
    else
    begin
      ProjectTitleLabel.Caption := 'Willkommen bei Structura';
      ProjectSubtitleLabel.Caption := 'Lege ein neues Projekt an oder öffne einen vorhandenen Ordner.';
    end;
    RebuildProjectCards;
    Exit;
  end;
  ClearProjectCards;

  CoverImage.Visible := True;
  OfficeSummaryLabel.Visible := False;
  ProjectNotesLabel.Visible := True;
  ProjectNotesMemo.Visible := True;
  ChapterCount := 0;
  if FProject.CoverImagePath <> '' then
  begin
    CoverPath := TProjectStore.AbsolutePath(FProject.FolderPath, FProject.CoverImagePath);
    if FileExists(CoverPath) then
      CoverImage.Picture.LoadFromFile(CoverPath)
    else
      DrawCoverPlaceholder;
  end
  else
    DrawCoverPlaceholder;

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
  I: Integer;
begin
  ChapterAvailable := Assigned(CurrentChapter);
  AddButton.Enabled := Assigned(FProject);
  EditButton.Enabled := Assigned(CurrentItem);
  DeleteButton.Enabled := Assigned(CurrentItem);
  OpenChapterButton.Enabled := ChapterAvailable;
  WordButton.Enabled := ChapterAvailable and (FSettings.WorkflowButtonCount > 0);
  LibreButton.Enabled := ChapterAvailable and (Trim(FCurrentPreviewText) <> '');
  ExportButton.Enabled := Assigned(FProject);
  if not ChapterAvailable then
    ExportButton.Enabled := Assigned(FProject);
  for I := 0 to High(FWorkflowButtons) do
    FWorkflowButtons[I].Enabled := ChapterAvailable and
      (Trim(FCurrentPreviewText) <> '');
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
  S := StringReplace(S, 'ä', 'ae', [rfReplaceAll]);
  S := StringReplace(S, 'ö', 'oe', [rfReplaceAll]);
  S := StringReplace(S, 'ü', 'ue', [rfReplaceAll]);
  S := StringReplace(S, 'Ä', 'Ae', [rfReplaceAll]);
  S := StringReplace(S, 'Ö', 'Oe', [rfReplaceAll]);
  S := StringReplace(S, 'Ü', 'Ue', [rfReplaceAll]);
  S := StringReplace(S, 'ß', 'ss', [rfReplaceAll]);
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
    'TextMaker: ' + IfThen(FOfficeTargets.TextMakerPath <> '', 'gefunden', 'nicht gefunden') + LineEnding +
    'PDF-Vorschau: nur über LibreOffice verfügbar';
end;

function TMainForm.BuildWorkflowCopyText(AConfig: TWorkflowButtonConfig): string;
var
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit('');

  case AConfig.CopyMode of
    wcmTitleAndChapterText:
      Result := Chapter.Title + LineEnding + LineEnding + FCurrentPreviewText;
    wcmPromptPlusChapter:
      Result := AConfig.Prefix + FCurrentPreviewText + AConfig.Suffix;
  else
    Result := FCurrentPreviewText;
  end;
end;

function TMainForm.BuildMarkdownCopyText: string;
var
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit('');
  Result := '# ' + Chapter.Title + LineEnding + LineEnding + FCurrentPreviewText;
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

procedure TMainForm.WorkflowButtonClick(Sender: TObject);
var
  Index: Integer;
  Config: TWorkflowButtonConfig;
  Payload: string;
  ErrorText: string;
  Opened: Boolean;
begin
  if not ((Sender is TButton) or (Sender is TMenuItem)) then
    Exit;
  if Sender is TButton then
    Index := TButton(Sender).Tag
  else
    Index := TMenuItem(Sender).Tag;
  if (not Assigned(FSettings)) or (Index < 0) or
     (Index >= FSettings.WorkflowButtonCount) then
    Exit;

  Config := FSettings.WorkflowButtons[Index];
  Payload := BuildWorkflowCopyText(Config);
  if Trim(Payload) <> '' then
    Clipboard.AsText := Payload;

  if Trim(Config.Target) <> '' then
  begin
    if Pos('://', Config.Target) > 0 then
      Opened := OpenURL(Config.Target)
    else
      Opened := TryLaunchDetachedProcess(Config.Target, [], ErrorText);

    if not Opened then
    begin
      if ErrorText = '' then
        ErrorText := 'Ziel konnte nicht geöffnet werden.';
      MessageDlg('Workflow konnte nicht gestartet werden', ErrorText, mtError, [mbOK], 0);
      Exit;
    end;
  end;

  UpdateStatus(Config.Name + ' geöffnet. Der vorbereitete Text liegt in der Zwischenablage.');
end;

procedure TMainForm.OpenMenuClick(Sender: TObject);
begin
  RebuildOpenPopupMenu;
  ShowPopupMenuBelow(OpenChapterButton, FOpenPopupMenu);
end;

procedure TMainForm.ReviewMenuClick(Sender: TObject);
begin
  RefreshWorkflowButtons;
  ShowPopupMenuBelow(WordButton, FReviewPopupMenu);
end;

procedure TMainForm.CopyMenuClick(Sender: TObject);
begin
  RebuildCopyPopupMenu;
  ShowPopupMenuBelow(LibreButton, FCopyPopupMenu);
end;

procedure TMainForm.ExportMenuClick(Sender: TObject);
begin
  RebuildExportPopupMenu;
  ShowPopupMenuBelow(ExportButton, FExportPopupMenu);
end;

procedure TMainForm.CopyTitleAndTextClick(Sender: TObject);
var
  Chapter: TStructuraItem;
begin
  Chapter := CurrentChapter;
  if not Assigned(Chapter) then
    Exit;
  Clipboard.AsText := Chapter.Title + LineEnding + LineEnding + FCurrentPreviewText;
  UpdateStatus('Kapiteltitel und Kapiteltext in die Zwischenablage kopiert.');
end;

procedure TMainForm.CopyPromptAndTextClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FSettings.WorkflowButtonCount - 1 do
    if FSettings.WorkflowButtons[I].CopyMode = wcmPromptPlusChapter then
    begin
      Clipboard.AsText := BuildWorkflowCopyText(FSettings.WorkflowButtons[I]);
      UpdateStatus('Prüfprompt und Kapiteltext in die Zwischenablage kopiert.');
      Exit;
    end;
  Clipboard.AsText := FCurrentPreviewText;
  UpdateStatus('Kein Prüfprompt konfiguriert. Kapiteltext wurde normal kopiert.');
end;

procedure TMainForm.CopyMarkdownClick(Sender: TObject);
begin
  Clipboard.AsText := BuildMarkdownCopyText;
  UpdateStatus('Markdown-Version des Kapitels in die Zwischenablage kopiert.');
end;

procedure TMainForm.ExportFolderClick(Sender: TObject);
var
  ExportFolder: string;
begin
  if not Assigned(FProject) then
    Exit;
  ExportFolder := IncludeTrailingPathDelimiter(FProject.FolderPath) + 'export';
  ForceDirectories(ExportFolder);
  ShowInFileManager(ExportFolder);
end;

procedure TMainForm.OpenProjectFolderClick(Sender: TObject);
begin
  if not Assigned(FProject) then
    Exit;
  ShowInFileManager(FProject.FolderPath);
end;

procedure TMainForm.ClearProjectCards;
var
  I: Integer;
begin
  for I := 0 to High(FProjectCards) do
    if Assigned(FProjectCards[I]) then
    begin
      FProjectCards[I].Parent := nil;
      FreeAndNil(FProjectCards[I]);
    end;
  SetLength(FProjectCards, 0);
end;

procedure TMainForm.ProjectCardClick(Sender: TObject);
begin
  // Sender kann TPanel, TLabel oder TImage sein – Hint enthält immer den Pfad.
  // WICHTIG: Projektp-Laden wird via QueueAsyncCall verzögert, damit LCL den
  // Click-Event vollständig abschließen kann, bevor ClearProjectCards die
  // Sender-Kachel freigibt (sonst: Access Violation $FFFFFFFFFFFFFFFF).
  if not (Sender is TControl) then
    Exit;
  FDeferredProjectFolder := TControl(Sender).Hint;
  if FDeferredProjectFolder = '' then
    Exit;
  Application.QueueAsyncCall(@LoadProjectDeferred, 0);
end;

procedure TMainForm.LoadProjectDeferred(Data: PtrInt);
begin
  if FDeferredProjectFolder = '' then
    Exit;
  try
    LoadProjectFromFolder(FDeferredProjectFolder);
  except
    on E: Exception do
      MessageDlg('Projekt konnte nicht geöffnet werden:' + LineEnding + E.Message,
        mtError, [mbOK], 0);
  end;
  FDeferredProjectFolder := '';
end;

procedure TMainForm.RebuildProjectCards;
var
  I: Integer;
  Summary: TProjectSummary;
  Card: TPanel;
  CoverImg: TImage;
  TitleLbl, SubLbl, InfoLbl: TLabel;
  Col, Row, ColCount, CardW, CardH, ColSpacing, RowSpacing, StartTop, StartLeft: Integer;
  CoverPath: string;
  FolderPaths: TStringList;
  SubDir: string;
  SearchRec: TSearchRec;
begin
  ClearProjectCards;
  if not Assigned(FSettings) then
    Exit;

  // Projektliste aufbauen: Standardordner scannen + RecentProjects (dedupliziert)
  FolderPaths := TStringList.Create;
  try
    // 1. Standardordner scannen
    if (Trim(FSettings.DefaultProjectFolder) <> '') and
       DirectoryExists(FSettings.DefaultProjectFolder) then
    begin
      if FindFirst(IncludeTrailingPathDelimiter(FSettings.DefaultProjectFolder) + '*',
                   faDirectory, SearchRec) = 0 then
      begin
        try
          repeat
            if ((SearchRec.Attr and faDirectory) <> 0) and
               (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
              SubDir := IncludeTrailingPathDelimiter(FSettings.DefaultProjectFolder) +
                        SearchRec.Name;
              if FileExists(TProjectStore.ProjectFileName(SubDir)) then
                FolderPaths.Add(SubDir);
            end;
          until FindNext(SearchRec) <> 0;
        finally
          FindClose(SearchRec);
        end;
      end;
    end;

    // 2. RecentProjects ergänzen (nur wenn noch nicht im Scan enthalten)
    for I := 0 to FSettings.RecentProjectCount - 1 do
    begin
      if FolderPaths.IndexOf(FSettings.RecentProjects[I]) < 0 then
        FolderPaths.Add(FSettings.RecentProjects[I]);
    end;

    if FolderPaths.Count = 0 then
      Exit;

    CardW := 280;
    CardH := 90;
    ColSpacing := 16;
    RowSpacing := 12;
    StartLeft := 24;
    StartTop := 110;

    // Spaltenanzahl dynamisch nach verfügbarer Breite
    ColCount := Max(1, (ProjectPanel.ClientWidth - StartLeft) div (CardW + ColSpacing));

    SetLength(FProjectCards, FolderPaths.Count);
    for I := 0 to FolderPaths.Count - 1 do
    begin
      Summary := TProjectStore.LoadSummaryFromFolder(FolderPaths[I]);
      if not Summary.Valid then
        Summary.Title := ExtractFileName(FolderPaths[I]);

      Col := I mod ColCount;
      Row := I div ColCount;

      Card := TPanel.Create(Self);
      Card.Parent := ProjectPanel;
      Card.Left := StartLeft + Col * (CardW + ColSpacing);
      Card.Top := StartTop + Row * (CardH + RowSpacing);
      Card.Width := CardW;
      Card.Height := CardH;
      Card.BevelOuter := bvRaised;
      Card.BevelInner := bvNone;
      Card.Color := $00FAF8F5;
      Card.Cursor := crHandPoint;
      Card.Hint := FolderPaths[I];
      Card.OnClick := @ProjectCardClick;

    // Mini-Cover
    CoverImg := TImage.Create(Card);
    CoverImg.Parent := Card;
    CoverImg.Left := 6;
    CoverImg.Top := 6;
    CoverImg.Width := 54;
    CoverImg.Height := 78;
    CoverImg.Proportional := True;
    CoverImg.Stretch := True;
    CoverImg.Center := True;
    CoverImg.Cursor := crHandPoint;
    CoverImg.OnClick := @ProjectCardClick;
    // Hint mit Pfad damit der Click-Handler greift
    CoverImg.Hint := FolderPaths[I];

    if Summary.CoverImagePath <> '' then
    begin
      CoverPath := TProjectStore.AbsolutePath(Summary.FolderPath, Summary.CoverImagePath);
      if FileExists(CoverPath) then
        try
          CoverImg.Picture.LoadFromFile(CoverPath);
        except
          // Bild laden fehlgeschlagen – bleibt leer
        end;
    end;
    if (not Assigned(CoverImg.Picture.Graphic)) or CoverImg.Picture.Graphic.Empty then
    begin
      // TImage zeigt keine Hintergrundfarbe — kleines Panel als Platzhalter dahinter
      with TPanel.Create(Card) do
      begin
        Parent := Card;
        Left := CoverImg.Left;
        Top := CoverImg.Top;
        Width := CoverImg.Width;
        Height := CoverImg.Height;
        Color := $00D4D0CC;
        BevelOuter := bvNone;
        Caption := '';
        Cursor := crHandPoint;
        Hint := FolderPaths[I];
        OnClick := @ProjectCardClick;
      end;
    end;

    // Titel
    TitleLbl := TLabel.Create(Card);
    TitleLbl.Parent := Card;
    TitleLbl.Left := 68;
    TitleLbl.Top := 8;
    TitleLbl.Width := 204;
    TitleLbl.AutoSize := False;
    TitleLbl.WordWrap := True;
    TitleLbl.Caption := Summary.Title;
    TitleLbl.Font.Style := [fsBold];
    TitleLbl.Font.Size := 9;
    TitleLbl.Cursor := crHandPoint;
    TitleLbl.OnClick := @ProjectCardClick;
    TitleLbl.Hint := FolderPaths[I];

    // Untertitel
    SubLbl := TLabel.Create(Card);
    SubLbl.Parent := Card;
    SubLbl.Left := 68;
    SubLbl.Top := 34;
    SubLbl.Width := 204;
    SubLbl.Height := 28;
    SubLbl.AutoSize := False;
    SubLbl.WordWrap := True;
    SubLbl.Caption := Summary.Subtitle;
    SubLbl.Font.Color := $00666666;
    SubLbl.Font.Size := 8;
    SubLbl.Cursor := crHandPoint;
    SubLbl.OnClick := @ProjectCardClick;
    SubLbl.Hint := FolderPaths[I];

    // Kapitelzahl
    InfoLbl := TLabel.Create(Card);
    InfoLbl.Parent := Card;
    InfoLbl.Left := 68;
    InfoLbl.Top := 68;
    InfoLbl.Caption := IntToStr(Summary.ChapterCount) + ' Kapitel';
    InfoLbl.Font.Color := $00999999;
    InfoLbl.Font.Size := 8;
    InfoLbl.Cursor := crHandPoint;
    InfoLbl.OnClick := @ProjectCardClick;
    InfoLbl.Hint := FolderPaths[I];

    FProjectCards[I] := Card;
    end;
  finally
    FolderPaths.Free;
  end;
end;

procedure TMainForm.BackToOverviewClick(Sender: TObject);
begin
  ItemListBox.ItemIndex := -1;
  SelectProjectOverview;
end;

procedure TMainForm.DrawCoverPlaceholder;
var
  Bmp: TBitmap;
  W, H: Integer;
begin
  W := CoverImage.Width;
  H := CoverImage.Height;
  if (W <= 0) or (H <= 0) then
    W := 260;
  if H <= 0 then
    H := 360;
  Bmp := TBitmap.Create;
  try
    Bmp.Width := W;
    Bmp.Height := H;
    Bmp.Canvas.Brush.Color := $00D4D0CC;
    Bmp.Canvas.Pen.Color := $00D4D0CC;
    Bmp.Canvas.Rectangle(0, 0, W, H);
    Bmp.Canvas.Font.Color := $00999999;
    Bmp.Canvas.Font.Size := 9;
    Bmp.Canvas.Brush.Style := bsClear;
    Bmp.Canvas.TextOut(W div 2 - 36, H div 2 - 8, 'Kein Cover');
    CoverImage.Picture.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

procedure TMainForm.ImportProjectClick(Sender: TObject);
var
  Res: TImportResult;
  DefaultDir: string;
  Project: TStructuraProject;
  I: Integer;
  ChapterTitle, RelFile: string;
  Item: TStructuraItem;
begin
  DefaultDir := '';
  if Assigned(FSettings) then
    DefaultDir := FSettings.DefaultProjectFolder;

  Res := ShowImportDialog(Self, DefaultDir);
  if not Res.Confirmed then
  begin
    FreeAndNil(Res.SelectedFiles);
    Exit;
  end;

  try
    // Warnen falls structura.json schon existiert
    if FileExists(TProjectStore.ProjectFileName(Res.FolderPath)) then
    begin
      if MessageDlg(
        'Im gewählten Ordner existiert bereits ein Structura-Projekt.' +
        LineEnding + 'Trotzdem importieren und überschreiben?',
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Exit;
    end;

    TProjectStore.EnsureProjectFolders(Res.FolderPath);

    Project := TStructuraProject.Create;
    try
      Project.FolderPath := Res.FolderPath;
      Project.Title      := Res.Title;
      Project.Author     := Res.Author;

      // Cover suchen
      if FileExists(IncludeTrailingPathDelimiter(Res.FolderPath) + 'cover.png') then
        Project.CoverImagePath := 'cover.png'
      else if FileExists(IncludeTrailingPathDelimiter(Res.FolderPath) + 'cover.jpg') then
        Project.CoverImagePath := 'cover.jpg'
      else if FileExists(IncludeTrailingPathDelimiter(Res.FolderPath) + 'cover.jpeg') then
        Project.CoverImagePath := 'cover.jpeg';

      // Kapitel aus gewählten Dateien anlegen
      for I := 0 to Res.SelectedFiles.Count - 1 do
      begin
        RelFile := Res.SelectedFiles[I];
        // Kapitelname: Dateiname ohne Pfad und ohne Erweiterung, bereinigt
        ChapterTitle := ChangeFileExt(ExtractFileName(RelFile), '');
        // Führende Kapitelkennung entfernen (K00_, 01_, …)
        ChapterTitle := TrimLeft(ChapterTitle);
        Item := Project.AddChapter(ChapterTitle, RelFile);
        Item.Status := 'Rohfassung';
      end;

      // Notiz-Platzhalter anlegen
      SaveTextFileSafe(
        TProjectStore.AbsolutePath(Res.FolderPath,
          RelativeProjectPath(['notes', 'project.md'])),
        '# Projektnotizen' + LineEnding + LineEnding);

      TProjectStore.SaveToFolder(Project);
      SetProject(Project);

      if Assigned(FSettings) then
      begin
        FSettings.AddRecentProject(Res.FolderPath);
        TSettingsStore.Save(FSettings);
      end;

      UpdateStatus('Projekt importiert: ' + Res.Title +
        ' (' + IntToStr(Res.SelectedFiles.Count) + ' Kapitel)');
    except
      Project.Free;
      raise;
    end;
  finally
    FreeAndNil(Res.SelectedFiles);
  end;
end;

procedure TMainForm.NewProjectClick(Sender: TObject);
var
  DialogResult: TProjectDialogResult;
  Project: TStructuraProject;
  CoverSource, CoverTarget, CoverRelative: string;
  RootFolder: string;
begin
  // Hauptordner bestimmen – niemals den Unterordner eines Projekts weitergeben
  RootFolder := '';
  if Assigned(FSettings) then
    RootFolder := Trim(FSettings.DefaultProjectFolder);
  if RootFolder = '' then
    RootFolder := GetUserDir;

  DialogResult := ExecuteProjectDialog(RootFolder);
  if not DialogResult.Confirmed then
    Exit;

  ForceDirectories(DialogResult.FolderPath);
  Project := TStructuraProject.Create;
  TProjectStore.CreateBlankProject(Project, DialogResult.FolderPath, DialogResult.Title);
  Project.Title    := DialogResult.Title;
  Project.Subtitle := DialogResult.Subtitle;
  Project.Author   := DialogResult.Author;

  if Trim(DialogResult.CoverImagePath) <> '' then
  begin
    CoverSource   := DialogResult.CoverImagePath;
    CoverRelative := 'cover' + LowerCase(ExtractFileExt(CoverSource));
    CoverTarget   := IncludeTrailingPathDelimiter(DialogResult.FolderPath) + CoverRelative;
    CopyFile(CoverSource, CoverTarget, [cffOverwriteFile]);
    Project.CoverImagePath := CoverRelative;
  end;

  SaveTextFileSafe(TProjectStore.AbsolutePath(DialogResult.FolderPath,
    RelativeProjectPath(['notes', 'project.md'])),
    '# Projektnotizen' + LineEnding + LineEnding);
  TProjectStore.SaveToFolder(Project);
  SetProject(Project);
  if Assigned(FSettings) then
  begin
    // Hauptordner merken (nicht den Unterordner des neuen Projekts)
    FSettings.DefaultProjectFolder := ExtractFileDir(ExcludeTrailingPathDelimiter(DialogResult.FolderPath));
    FSettings.AddRecentProject(DialogResult.FolderPath);
    TSettingsStore.Save(FSettings);
  end;
  UpdateStatus('Projekt angelegt: ' + DialogResult.Title);
end;

procedure TMainForm.OpenProjectClick(Sender: TObject);
var
  Folder: string;
begin
  if Assigned(FSettings) and (Trim(FSettings.DefaultProjectFolder) <> '') then
    Folder := FSettings.DefaultProjectFolder
  else
    Folder := FLastProjectFolder;
  if not SelectDirectory('Projektordner wählen', '', Folder) then
    Exit;
  try
    PersistCurrentNotes;
    LoadProjectFromFolder(Folder);
    if Assigned(FSettings) then
    begin
      FSettings.DefaultProjectFolder := Folder;
      TSettingsStore.Save(FSettings);
    end;
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
  NotesFileName, ChapterFile: string;
begin
  Item := CurrentItem;
  if not Assigned(Item) then
    Exit;

  if MessageDlg('Eintrag löschen',
    'Soll "' + Item.Title + '" wirklich aus der Struktur entfernt werden?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  if (Item.ItemType = sitChapter) and (Trim(Item.FileName) <> '') then
  begin
    ChapterFile := TProjectStore.AbsolutePath(FProject.FolderPath, Item.FileName);
    if FileExists(ChapterFile) then
      CreateBackupCopy(ChapterFile);
  end;

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

procedure TMainForm.ProjectNotesChanged(Sender: TObject);
begin
  if FUpdatingUi then
    Exit;
  PersistProjectNotes;
end;

procedure TMainForm.NotesExit(Sender: TObject);
begin
  PersistChapterNotes;
  SaveProject;
end;

procedure TMainForm.NotesChanged(Sender: TObject);
begin
  if FUpdatingUi then
    Exit;
  PersistChapterNotes;
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
    FOfficeTargets.LibreOfficePath,
    PdfFileName, ErrorText) then
  begin
    MessageDlg('PDF über LibreOffice fehlgeschlagen', ErrorText, mtError, [mbOK], 0);
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

procedure TMainForm.SettingsClick(Sender: TObject);
begin
  if not Assigned(FSettings) then
    Exit;
  if EditAppSettings(FSettings) then
  begin
    FOfficeTargets := DetectOfficeTargets;
    ApplyOfficeOverrides;
    RebuildOpenPopupMenu;
    RebuildExportPopupMenu;
    RefreshWorkflowButtons;
    RefreshActionButtons;
    RefreshProjectView;
    TSettingsStore.Save(FSettings);
    UpdateStatus('Einstellungen gespeichert.');
  end;
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
    if Assigned(FSettings) then
      TSettingsStore.Save(FSettings);
  except
    on E: Exception do
    begin
      CanClose := False;
      MessageDlg('Speichern fehlgeschlagen', E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

end.
