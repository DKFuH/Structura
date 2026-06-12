unit MainFormUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ComCtrls, CheckLst, Menus, IpHtml, StructuraTypes, OfficeDetection,
  AppSettings;

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
    FProjectBackLabel: TLabel;
    FProjectExportLabel: TLabel;
    FContinueLabel: TLabel;
    FContinueIndex: Integer;
    FAppMenu: TPopupMenu;
    FAppMenuImage: TImage;
    FWelcomeImage: TImage;
    FProjectCards: array of TPanel;
    FDeferredProjectFolder: string;
    FDashboardBox: TPaintBox;
    FStatusCounts: array[0..High(STRUCTURA_STATUSES)] of Integer;
    FOpenTaskCount: Integer;
    FNextStepText: string;
    FHintText: string;
    FDashboardLinks: array of TLabel;
    FNotesHtmlPanel: TIpHtmlPanel;
    FNotesToggleLabel: TLabel;
    FNotesPreviewActive: Boolean;
    FTaskLabel: TLabel;
    FTaskList: TCheckListBox;
    FTaskEdit: TEdit;
    FTaskAddButton: TButton;
    FTaskLineIndex: array of Integer;
    procedure ConfigureUi;
    procedure LayoutChapterView(Sender: TObject);
    procedure RefreshChapterTasks;
    procedure UpdateChapterTaskCount;
    procedure TaskListClickCheck(Sender: TObject);
    procedure AddChapterTaskClick(Sender: TObject);
    procedure TaskEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    function FormatChapterNumber(ASequence: Integer): string;
    function ChapterSequenceForIndex(AIndex: Integer): Integer;
    function ChapterSequenceForItem(AItem: TStructuraItem): Integer;
    function BuildChapterFileName(AItem: TStructuraItem; AListIndex: Integer): string;
    function BuildChapterListCaption(AIndex: Integer; AItem: TStructuraItem): string;
    function StatusColor(const AStatus: string): TColor;
    procedure ComputeDashboardData;
    procedure DashboardPaint(Sender: TObject);
    function CountOpenTasksInNotes(const AFileName: string): Integer;
    function ChapterStaleDays(AItem: TStructuraItem): Integer;
    function MostRecentlyEditedChapter: Integer;
    procedure ContinueClick(Sender: TObject);
    procedure ClearDashboardLinks;
    procedure RebuildDashboardLinks;
    procedure DashboardLinkClick(Sender: TObject);
    procedure FormKeyDownHandler(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AboutLinkClick(Sender: TObject);
    procedure CloseProjectClick(Sender: TObject);
    procedure AppMenuClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure AddAppMenuItem(const ACaption: string; AHandler: TNotifyEvent);
    procedure ProjectExportClick(Sender: TObject);
    procedure ProjectSearchClick(Sender: TObject);
    function ConfirmFinalChange(AItem: TStructuraItem; const AAction: string): Boolean;
    procedure OpenBackupsClick(Sender: TObject);
    procedure ReviewLinkClick(Sender: TObject);
    procedure NotesToggleClick(Sender: TObject);
    procedure UpdateNotesPreviewState;
    procedure NavigateChapter(ADelta: Integer);
    procedure NavigateToNextWithStatus(AProblemOnly: Boolean);
    function EnsureUniqueRelativeFileName(const ARelative: string): string;
    function MakeSafeFileNamePart(const AValue: string): string;
    function CreateBackupCopy(const AAbsoluteFileName: string): Boolean;
    procedure EnsureDailyZipBackup(AForceUpdate: Boolean = False);
    procedure BackupCurrentProjectOnClose;
    function RenameChapterFile(AItem: TStructuraItem; AListIndex: Integer): Boolean;
    function RenumberChapterFiles: Boolean;
    function ChapterWordCount(AItem: TStructuraItem): Integer;
    function ProjectWordCount: Integer;
    function FileModifiedText(const AFileName: string): string;
    function ProjectStatusSummary: string;
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
    procedure ItemListDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
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
  LCLIntf, LCLType, FileUtil, Process, Clipbrd, StrUtils, Math, DateUtils, Zipper,
  ProjectStore, ProjectDialogUnit, ElementDialogUnit, DocumentWorkflow,
  DocxPreview, SettingsStore, SettingsDialogUnit, FirstRunWizardUnit,
  ImportProjectDialogUnit, AboutDialogUnit, ReviewDialogUnit, MarkdownPreview,
  ExportDialogUnit, SearchDialogUnit;

function NormalizeStoredPathForCompare(const APath: string): string;
begin
  Result := StringReplace(APath, '\', '/', [rfReplaceAll]);
end;

function FileIsLockedForRename(const AFileName: string): Boolean;
var
  Handle: THandle;
begin
  if not FileExists(AFileName) then
    Exit(False);
  Handle := FileOpen(AFileName, fmOpenReadWrite or fmShareExclusive);
  Result := Handle = THandle(-1);
  if not Result then
    FileClose(Handle);
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
  // Einstellungen sind ins Header-Menü gewandert
  SettingsButton.Visible := False;
  CopyTextButton.Visible := False;
  OpenChapterButton.Caption := 'Öffnen mit ▼';
  WordButton.Caption := 'Prüfen mit ▼';
  LibreButton.Caption := 'Kopieren ▼';
  ExportButton.Caption := 'Export ▼';
  WordButton.Visible := True;
  LibreButton.Visible := True;

  // Markdown-Vorschau für Kapitelnotizen: HTML-Panel deckungsgleich über dem
  // Memo, Umschalter neben der Notizen-Überschrift
  FNotesPreviewActive := False;
  FNotesHtmlPanel := TIpHtmlPanel.Create(Self);
  FNotesHtmlPanel.Parent := ChapterPanel;
  FNotesHtmlPanel.SetBounds(NotesMemo.Left, NotesMemo.Top, NotesMemo.Width, NotesMemo.Height);
  FNotesHtmlPanel.Visible := False;

  FNotesToggleLabel := TLabel.Create(Self);
  FNotesToggleLabel.Parent := ChapterPanel;
  FNotesToggleLabel.Left := NotesLabel.Left + 130;
  FNotesToggleLabel.Top := NotesLabel.Top;
  FNotesToggleLabel.Caption := 'Vorschau';
  FNotesToggleLabel.Cursor := crHandPoint;
  FNotesToggleLabel.Font.Color := TColor($00B05A1E);
  FNotesToggleLabel.OnClick := @NotesToggleClick;

  // Offene Aufgaben: Checkliste über den `- [ ]`-Zeilen der Kapitelnotizen
  FTaskLabel := TLabel.Create(Self);
  FTaskLabel.Parent := ChapterPanel;
  FTaskLabel.Caption := 'Offene Aufgaben';
  FTaskLabel.Font.Style := [fsBold];

  FTaskList := TCheckListBox.Create(Self);
  FTaskList.Parent := ChapterPanel;
  FTaskList.OnClickCheck := @TaskListClickCheck;

  FTaskEdit := TEdit.Create(Self);
  FTaskEdit.Parent := ChapterPanel;
  FTaskEdit.TextHint := 'Neue Aufgabe – Enter zum Hinzufügen';
  FTaskEdit.OnKeyDown := @TaskEditKeyDown;

  FTaskAddButton := TButton.Create(Self);
  FTaskAddButton.Parent := ChapterPanel;
  FTaskAddButton.Caption := '+';
  FTaskAddButton.OnClick := @AddChapterTaskClick;

  // Größenabhängiges Layout der Kapitelansicht
  ChapterPanel.OnResize := @LayoutChapterView;

  // Header-Menü für seltene/globale Aktionen (Einstellungen, Hilfe, Über).
  // Häufige Workflow-Aktionen bleiben als sichtbare Buttons.
  FAppMenu := TPopupMenu.Create(Self);
  AddAppMenuItem('Projektsuche  (Strg+F)', @ProjectSearchClick);
  AddAppMenuItem('Sicherungen öffnen', @OpenBackupsClick);
  AddAppMenuItem('-', nil);
  AddAppMenuItem('Einstellungen', @SettingsClick);
  AddAppMenuItem('Erste Schritte (Hilfe)', @HelpClick);
  AddAppMenuItem('-', nil);
  AddAppMenuItem('Über Structura', @AboutLinkClick);

  FAppMenuImage := TImage.Create(Self);
  FAppMenuImage.Parent := HeaderPanel;
  FAppMenuImage.Anchors := [akTop, akRight];
  FAppMenuImage.SetBounds(HeaderPanel.ClientWidth - 40, 12, 24, 24);
  FAppMenuImage.Proportional := True;
  FAppMenuImage.Stretch := True;
  FAppMenuImage.Cursor := crHandPoint;
  FAppMenuImage.Hint := 'Menü';
  FAppMenuImage.ShowHint := True;
  FAppMenuImage.OnClick := @AppMenuClick;
  if FileExists(AssetPath('assets\buttons\menu.png')) then
    try
      FAppMenuImage.Picture.LoadFromFile(AssetPath('assets\buttons\menu.png'));
    except
      // Ohne Icon bleibt das Menü dennoch klickbar (24×24-Fläche)
    end;

  // Tastaturnavigation: Alt+←/→ Kapitel, Alt+O nächstes offenes, Alt+P nächstes Problem
  KeyPreview := True;
  OnKeyDown := @FormKeyDownHandler;

  // Status-Dashboard in der Projektübersicht
  FDashboardBox := TPaintBox.Create(Self);
  FDashboardBox.Parent := ProjectPanel;
  FDashboardBox.SetBounds(316, 244, 720, 172);
  FDashboardBox.OnPaint := @DashboardPaint;
  FDashboardBox.Visible := False;
  ProjectStatusLabel.Visible := False;

  // Zurück zur Projektliste („Zuletzt geöffnet") aus dem offenen Projekt
  FProjectBackLabel := TLabel.Create(Self);
  FProjectBackLabel.Parent := ProjectPanel;
  FProjectBackLabel.Left := 24;
  FProjectBackLabel.Top := 4;
  FProjectBackLabel.Caption := '← Zur Projektliste';
  FProjectBackLabel.Cursor := crHandPoint;
  FProjectBackLabel.Font.Color := TColor($006B3D1E);
  FProjectBackLabel.Visible := False;
  FProjectBackLabel.OnClick := @CloseProjectClick;

  // Export direkt aus der Projektübersicht (gleiche Aktion wie in der Kapitelansicht)
  FProjectExportLabel := TLabel.Create(Self);
  FProjectExportLabel.Parent := ProjectPanel;
  FProjectExportLabel.Anchors := [akTop, akRight];
  FProjectExportLabel.Left := ProjectPanel.ClientWidth - 90;
  FProjectExportLabel.Top := 4;
  FProjectExportLabel.Caption := 'Export ▼';
  FProjectExportLabel.Cursor := crHandPoint;
  FProjectExportLabel.Font.Color := TColor($006B3D1E);
  FProjectExportLabel.Font.Style := [fsBold];
  FProjectExportLabel.Visible := False;
  FProjectExportLabel.OnClick := @ProjectExportClick;

  // „Weiterarbeiten" — zuletzt bearbeitetes Kapitel, ganz oben in der Übersicht
  FContinueIndex := -1;
  FContinueLabel := TLabel.Create(Self);
  FContinueLabel.Parent := ProjectPanel;
  FContinueLabel.Left := 316;
  FContinueLabel.Top := 6;
  FContinueLabel.Cursor := crHandPoint;
  FContinueLabel.Font.Color := TColor($006B3D1E);
  FContinueLabel.Font.Style := [fsBold];
  FContinueLabel.Visible := False;
  FContinueLabel.OnClick := @ContinueClick;

  // Begrüßungsbild für die leere Startansicht (noch keine Projekte vorhanden)
  FWelcomeImage := TImage.Create(Self);
  FWelcomeImage.Parent := ProjectPanel;
  FWelcomeImage.SetBounds(24, 120, 480, 320);
  FWelcomeImage.Proportional := True;
  FWelcomeImage.Stretch := True;
  FWelcomeImage.Center := False;
  FWelcomeImage.Visible := False;
  if FileExists(AssetPath('assets\owl.png')) then
    try
      FWelcomeImage.Picture.LoadFromFile(AssetPath('assets\owl.png'));
    except
      // Bild fehlt oder defekt — Startansicht bleibt einfach ohne Bild
    end;

  FBackLabel := TLabel.Create(Self);
  FBackLabel.Parent := ChapterPanel;
  FBackLabel.Left := 24;
  FBackLabel.Top := 12;
  FBackLabel.Caption := '← Projektübersicht';
  FBackLabel.Cursor := crHandPoint;
  FBackLabel.Font.Color := $006B3D1E;
  FBackLabel.Font.Height := -17;
  FBackLabel.OnClick := @BackToOverviewClick;

  // Dezenter Hinweis auf die Tastaturnavigation
  with TLabel.Create(Self) do
  begin
    Parent := ChapterPanel;
    Left := 240;
    Top := 16;
    Caption := 'Alt+←/→ Kapitel wechseln · Alt+O nächstes offenes · Alt+P nächstes Problem';
    Font.Color := clGrayText;
  end;
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
  LoadButtonGlyph(NewButton, 'assets\buttons\new_project.png');
  LoadButtonGlyph(OpenButton, 'assets\buttons\open_project.png');
  LoadButtonGlyph(SettingsButton, 'assets\buttons\settings.png');
  LoadButtonGlyph(AddButton, 'assets\buttons\add_item.png');
  LoadButtonGlyph(EditButton, 'assets\buttons\edit_item.png');
  LoadButtonGlyph(DeleteButton, 'assets\buttons\delete_item.png');
  LoadButtonGlyph(OpenChapterButton, 'assets\buttons\open_chapter.png');
  LoadButtonGlyph(OpenFolderButton, 'assets\buttons\open_folder.png');
  LoadButtonGlyph(PdfPreviewButton, 'assets\buttons\pdf_preview.png');
  LoadButtonGlyph(ExportButton, 'assets\buttons\export_master.png');
end;

procedure TMainForm.LoadButtonGlyph(AButton: TBitBtn; const AFileName: string);
var
  Picture: TPicture;
  FullPath: string;
begin
  FullPath := AssetPath(AFileName);
  if not FileExists(FullPath) then
    Exit;
  Picture := TPicture.Create;
  try
    try
      Picture.LoadFromFile(FullPath);
      AButton.Glyph.Assign(Picture.Graphic);
      AButton.NumGlyphs := 1;
      AButton.Layout := blGlyphLeft;
      AButton.Spacing := 6;
    except
      AButton.Glyph.Clear;
    end;
  finally
    Picture.Free;
  end;
end;

procedure TMainForm.SetProject(AProject: TStructuraProject);
begin
  // Beim Wechsel das bisherige Projekt noch sichern (Tagesbackup aktualisieren)
  if Assigned(FProject) and (AProject <> FProject) then
    EnsureDailyZipBackup(True);
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
  EnsureDailyZipBackup;
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
    if Assigned(FDashboardBox) then
      FDashboardBox.Visible := False;
    if Assigned(FProjectBackLabel) then
      FProjectBackLabel.Visible := False;
    if Assigned(FProjectExportLabel) then
      FProjectExportLabel.Visible := False;
    if Assigned(FContinueLabel) then
      FContinueLabel.Visible := False;
    ClearDashboardLinks;
    RebuildProjectCards;
    // Eule nur zeigen, solange es noch keine Projektkacheln gibt
    if Assigned(FWelcomeImage) then
      FWelcomeImage.Visible := (Length(FProjectCards) = 0) and
        Assigned(FWelcomeImage.Picture.Graphic);
    Exit;
  end;
  ClearProjectCards;
  if Assigned(FWelcomeImage) then
    FWelcomeImage.Visible := False;
  if Assigned(FProjectBackLabel) then
    FProjectBackLabel.Visible := True;
  if Assigned(FProjectExportLabel) then
  begin
    FProjectExportLabel.Left := ProjectPanel.ClientWidth - 90;
    FProjectExportLabel.Visible := True;
  end;
  if Assigned(FContinueLabel) then
  begin
    FContinueIndex := MostRecentlyEditedChapter;
    if FContinueIndex >= 0 then
    begin
      FContinueLabel.Caption := Format('▶ Weiterarbeiten: %s  %s',
        [FormatChapterNumber(ChapterSequenceForIndex(FContinueIndex)),
         FProject[FContinueIndex].Title]);
      FContinueLabel.Visible := True;
    end
    else
      FContinueLabel.Visible := False;
  end;
  ComputeDashboardData;
  if Assigned(FDashboardBox) then
  begin
    FDashboardBox.Visible := True;
    FDashboardBox.Invalidate;
  end;
  RebuildDashboardLinks;

  CoverImage.Visible := True;
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
  ComboIndex: Integer;
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
      ChapterHeadingLabel.Caption := Format('%s  %s', [FormatChapterNumber(Sequence), Item.Title]);
      Meta.Add('Datei: ' + Item.FileName);
      Meta.Add('Geändert: ' + FileModifiedText(FileName));
      Meta.Add('Wortzahl: ' + IntToStr(ChapterWordCount(Item)));
      ChapterMetaLabel.Caption := Meta.Text;

      FCurrentPreviewText := TDocxPreview.LoadPreviewText(FileName);
      FUpdatingUi := True;
      try
        PreviewMemo.Text := FCurrentPreviewText;
        NotesMemo.Text := LoadTextFileSafe(AbsoluteItemNotesFileName(Item));
        ComboIndex := ChapterStatusCombo.Items.IndexOf(Item.Status);
        if ComboIndex < 0 then
        begin
          if Trim(Item.Status) <> '' then
            ChapterStatusCombo.Items.Add(Item.Status);
          ComboIndex := ChapterStatusCombo.Items.IndexOf(Item.Status);
        end;
        ChapterStatusCombo.ItemIndex := ComboIndex;
      finally
        FUpdatingUi := False;
      end;
      ChapterStatusLabel.Enabled := True;
      ChapterStatusCombo.Enabled := True;
      NotesMemo.Enabled := True;
      PreviewMemo.Enabled := True;
      NotesLabel.Caption := 'Kapitelnotizen (.md)';
      PreviewLabel.Caption := 'Textvorschau';
      UpdateNotesPreviewState;
      RefreshChapterTasks;
      FTaskLabel.Visible := True;
      FTaskList.Visible := True;
      FTaskEdit.Visible := True;
      FTaskAddButton.Visible := True;
      LayoutChapterView(nil);
    end
    else
    begin
      FTaskLabel.Visible := False;
      FTaskList.Visible := False;
      FTaskEdit.Visible := False;
      FTaskAddButton.Visible := False;
      ChapterHeadingLabel.Caption := 'Trenner: ' + Item.Title;
      ChapterMetaLabel.Caption := 'Dieser Eintrag gliedert das Buch in Teile und besitzt keine Kapiteldatei.';
      FCurrentPreviewText := '';
      FUpdatingUi := True;
      try
        PreviewMemo.Text := 'Kein Kapitel ausgewählt.';
        NotesMemo.Text := '';
        ChapterStatusCombo.ItemIndex := -1;
        UpdateNotesPreviewState;
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

function TMainForm.FormatChapterNumber(ASequence: Integer): string;
var
  Digits: Integer;
begin
  Digits := 2;
  if Assigned(FSettings) and (FSettings.ChapterNumberDigits >= 1) and
     (FSettings.ChapterNumberDigits <= 3) then
    Digits := FSettings.ChapterNumberDigits;
  Result := Format('%.*d', [Digits, ASequence]);
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
    Format('%s_%s%s', [FormatChapterNumber(Sequence), MakeSafeFileNamePart(AItem.Title), Extension])
  ]);
end;

function TMainForm.BuildChapterListCaption(AIndex: Integer; AItem: TStructuraItem): string;
begin
  // Status erscheint als farbiger Punkt (ItemListDrawItem), Trenner werden
  // dort optisch abgesetzt — der Caption-Text bleibt deshalb schlicht.
  if AItem.ItemType = sitDivider then
    Exit(AItem.Title);

  Result := Format('%s  %s', [FormatChapterNumber(ChapterSequenceForIndex(AIndex)), AItem.Title]);
end;

function TMainForm.StatusColor(const AStatus: string): TColor;
begin
  if SameText(AStatus, 'In Bearbeitung') then
    Result := TColor($0000B4FF)   // Amber
  else if SameText(AStatus, 'Grammarly geprüft') then
    Result := TColor($00FFB464)   // Hellblau
  else if SameText(AStatus, 'Sprachlich geprüft') then
    Result := TColor($00DC781E)   // Blau
  else if SameText(AStatus, 'Fachlich geprüft') then
    Result := TColor($00A0A000)   // Petrol
  else if SameText(AStatus, 'Final') then
    Result := TColor($0050AA28)   // Grün
  else if SameText(AStatus, 'Problem') then
    Result := TColor($00323CDC)   // Rot
  else
    Result := clSilver;           // Rohfassung / unbekannt
end;

function TMainForm.ChapterStaleDays(AItem: TStructuraItem): Integer;
var
  FileName: string;
  FileDate: TDateTime;
begin
  Result := -1;
  if not Assigned(AItem) or (AItem.ItemType <> sitChapter) then
    Exit;
  FileName := AbsoluteItemFileName(AItem);
  if FileExists(FileName) and FileAge(FileName, FileDate) then
    Result := Trunc(Now) - Trunc(FileDate);
end;

// Index des zuletzt geänderten Kapitels (jüngste Kapiteldatei), oder -1.
function TMainForm.MostRecentlyEditedChapter: Integer;
var
  I: Integer;
  Item: TStructuraItem;
  FileName: string;
  FileDate, Newest: TDateTime;
begin
  Result := -1;
  Newest := 0;
  if not Assigned(FProject) then
    Exit;
  for I := 0 to FProject.Count - 1 do
  begin
    Item := FProject[I];
    if Item.ItemType <> sitChapter then
      Continue;
    FileName := AbsoluteItemFileName(Item);
    if FileExists(FileName) and FileAge(FileName, FileDate) then
      if (Result < 0) or (FileDate > Newest) then
      begin
        Newest := FileDate;
        Result := I;
      end;
  end;
end;

procedure TMainForm.ContinueClick(Sender: TObject);
begin
  if (FContinueIndex >= 0) and Assigned(FProject) and
     (FContinueIndex < FProject.Count) then
    SelectItem(FContinueIndex);
end;

function TMainForm.CountOpenTasksInNotes(const AFileName: string): Integer;
var
  Lines: TStringList;
  I: Integer;
  Line: string;
begin
  Result := 0;
  if not FileExists(AFileName) then
    Exit;
  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(AFileName);
    except
      Exit;
    end;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := TrimLeft(Lines[I]);
      if AnsiStartsStr('- [ ]', Line) or AnsiStartsStr('* [ ]', Line) then
        Inc(Result);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TMainForm.ComputeDashboardData;
const
  StaleDays = 30;
var
  I, NextIndex, BestRank, Rank, TasksHere: Integer;
  ChaptersWithTasks, StaleChapters: Integer;
  Item, NextItem: TStructuraItem;
  FileName: string;
  FileDate: TDateTime;
  Hints: TStringList;
begin
  for I := Low(FStatusCounts) to High(FStatusCounts) do
    FStatusCounts[I] := 0;
  FOpenTaskCount := 0;
  FNextStepText := '';
  FHintText := '';
  if not Assigned(FProject) then
    Exit;

  ChaptersWithTasks := 0;
  StaleChapters := 0;
  NextItem := nil;
  NextIndex := -1;
  BestRank := MaxInt;
  for I := 0 to FProject.Count - 1 do
  begin
    Item := FProject[I];
    if Item.ItemType <> sitChapter then
      Continue;
    Inc(FStatusCounts[StatusIndex(Item.Status)]);
    TasksHere := CountOpenTasksInNotes(AbsoluteItemNotesFileName(Item));
    Inc(FOpenTaskCount, TasksHere);
    if TasksHere > 0 then
      Inc(ChaptersWithTasks);

    // „lange nicht bearbeitet": Dateialter, nur für noch nicht finale Kapitel
    if StatusIndex(Item.Status) <> STATUS_FINAL_INDEX then
    begin
      FileName := AbsoluteItemFileName(Item);
      if FileExists(FileName) and FileAge(FileName, FileDate) then
        if Trunc(Now) - Trunc(FileDate) > StaleDays then
          Inc(StaleChapters);
    end;

    // Nächster Schritt: Problemkapitel zuerst, sonst das Kapitel mit dem
    // niedrigsten Bearbeitungsstand. Finale Kapitel brauchen nichts mehr.
    Rank := StatusIndex(Item.Status);
    if Rank = STATUS_PROBLEM_INDEX then
      Rank := -1
    else if Rank = STATUS_FINAL_INDEX then
      Rank := MaxInt;
    if Rank < BestRank then
    begin
      BestRank := Rank;
      NextItem := Item;
      NextIndex := I;
    end;
  end;

  if Assigned(NextItem) then
  begin
    if BestRank = -1 then
      FNextStepText := Format('Nächster Schritt: Kapitel %s „%s" — Problem beheben',
        [FormatChapterNumber(ChapterSequenceForIndex(NextIndex)), NextItem.Title])
    else if BestRank <= 1 then
      FNextStepText := Format('Nächster Schritt: Kapitel %s „%s" weiterschreiben',
        [FormatChapterNumber(ChapterSequenceForIndex(NextIndex)), NextItem.Title])
    else
      FNextStepText := Format('Nächster Schritt: Kapitel %s „%s" prüfen',
        [FormatChapterNumber(ChapterSequenceForIndex(NextIndex)), NextItem.Title]);
  end
  else if FStatusCounts[STATUS_FINAL_INDEX] > 0 then
    FNextStepText := 'Alle Kapitel final — bereit für den Export.';

  // Dezente Hinweise (Prinzip 5: mitdenken, nicht bevormunden) — eine ruhige
  // Zeile aus Fakten, die schon vorliegen, mittendrin getrennt durch „·".
  Hints := TStringList.Create;
  try
    if FStatusCounts[0] > 0 then
      Hints.Add(Format('%d noch Rohfassung', [FStatusCounts[0]]));
    if ChaptersWithTasks > 0 then
      Hints.Add(Format('%d mit offenen Aufgaben', [ChaptersWithTasks]));
    if StaleChapters > 0 then
      Hints.Add(Format('%d seit über %d Tagen unbearbeitet',
        [StaleChapters, StaleDays]));
    for I := 0 to Hints.Count - 1 do
    begin
      if FHintText <> '' then
        FHintText := FHintText + '   ·   ';
      FHintText := FHintText + Hints[I];
    end;
  finally
    Hints.Free;
  end;
end;

procedure TMainForm.AboutLinkClick(Sender: TObject);
begin
  ShowAboutDialog;
end;

procedure TMainForm.AddAppMenuItem(const ACaption: string; AHandler: TNotifyEvent);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(FAppMenu);
  Item.Caption := ACaption;
  Item.OnClick := AHandler;
  FAppMenu.Items.Add(Item);
end;

procedure TMainForm.AppMenuClick(Sender: TObject);
var
  P: TPoint;
begin
  // Menü unterhalb des Icons öffnen
  P := FAppMenuImage.ClientToScreen(Point(0, FAppMenuImage.Height));
  FAppMenu.PopUp(P.X, P.Y);
end;

procedure TMainForm.ProjectExportClick(Sender: TObject);
begin
  if not Assigned(FProject) then
    Exit;
  RebuildExportPopupMenu;
  ShowPopupMenuBelow(FProjectExportLabel, FExportPopupMenu);
end;

procedure TMainForm.OpenBackupsClick(Sender: TObject);
var
  BackupRoot, DailyFolder, LastZip, Info: string;
  Zips: TStringList;
begin
  if not Assigned(FProject) then
  begin
    UpdateStatus('Sicherungen: Bitte zuerst ein Projekt öffnen.');
    Exit;
  end;
  BackupRoot := IncludeTrailingPathDelimiter(FProject.FolderPath) + 'backup';
  DailyFolder := IncludeTrailingPathDelimiter(BackupRoot) + 'daily';

  // Letzte Tagessicherung ermitteln
  LastZip := '';
  if DirectoryExists(DailyFolder) then
  begin
    Zips := TStringList.Create;
    try
      FindAllFiles(Zips, DailyFolder, '*.zip', False);
      Zips.Sort;
      if Zips.Count > 0 then
        LastZip := ExtractFileName(Zips[Zips.Count - 1]);
    finally
      Zips.Free;
    end;
  end;

  if not DirectoryExists(BackupRoot) then
  begin
    MessageDlg('Sicherungen',
      'Für dieses Projekt gibt es noch keine Sicherungen.' + LineEnding +
      'Tägliche ZIP-Sicherungen entstehen automatisch beim Öffnen und Schließen.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  Info := 'Tägliche ZIP-Sicherungen liegen unter backup\daily\.';
  if LastZip <> '' then
    Info := Info + LineEnding + 'Letzte Sicherung: ' + LastZip;
  Info := Info + LineEnding + LineEnding + 'Sicherungsordner jetzt öffnen?';
  if MessageDlg('Sicherungen', Info, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    ShowInFileManager(BackupRoot);
end;

procedure TMainForm.ProjectSearchClick(Sender: TObject);
var
  Docs: TSearchDocs;
  I, J, JumpTo: Integer;
  Item: TStructuraItem;
  NotesText, TasksText, Line: string;
  Lines: TStringList;
begin
  if not Assigned(FProject) then
  begin
    UpdateStatus('Suche: Bitte zuerst ein Projekt öffnen.');
    Exit;
  end;

  // Suchkorpus zusammenstellen — DOCX-Text-Extraktion kann dauern
  Screen.Cursor := crHourGlass;
  try
    SetLength(Docs, FProject.Count);
    Lines := TStringList.Create;
    try
      for I := 0 to FProject.Count - 1 do
      begin
        Item := FProject[I];
        Docs[I].ItemIndex := I;
        Docs[I].Title := Item.Title;
        Docs[I].IsDivider := Item.ItemType = sitDivider;
        Docs[I].Number := '';
        Docs[I].Notes := '';
        Docs[I].Tasks := '';
        Docs[I].BodyText := '';
        if Item.ItemType = sitDivider then
          Continue;

        Docs[I].Number := FormatChapterNumber(ChapterSequenceForIndex(I));
        // Notizen in Fließtext und Aufgabenzeilen trennen
        NotesText := '';
        TasksText := '';
        Lines.Text := LoadTextFileSafe(AbsoluteItemNotesFileName(Item));
        for J := 0 to Lines.Count - 1 do
        begin
          Line := TrimLeft(Lines[J]);
          if AnsiStartsStr('- [', Line) or AnsiStartsStr('* [', Line) then
            TasksText := TasksText + Lines[J] + LineEnding
          else
            NotesText := NotesText + Lines[J] + LineEnding;
        end;
        Docs[I].Notes := NotesText;
        Docs[I].Tasks := TasksText;
        Docs[I].BodyText := TDocxPreview.LoadPreviewText(AbsoluteItemFileName(Item));
      end;
    finally
      Lines.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  JumpTo := ShowSearchDialog(Docs);
  if JumpTo >= 0 then
    SelectItem(JumpTo);
end;

procedure TMainForm.HelpClick(Sender: TObject);
begin
  OpenURL('https://github.com/DKFuH/Structura/blob/main/docs/first-steps.md');
end;

procedure TMainForm.NotesToggleClick(Sender: TObject);
begin
  FNotesPreviewActive := not FNotesPreviewActive;
  UpdateNotesPreviewState;
end;

procedure TMainForm.UpdateNotesPreviewState;
begin
  if not Assigned(FNotesHtmlPanel) then
    Exit;
  if FNotesPreviewActive then
  begin
    try
      FNotesHtmlPanel.SetHtmlFromStr(MarkdownToHtml(NotesMemo.Text));
    except
      // Render-Fehler: stillschweigend zurück in den Bearbeiten-Modus
      FNotesPreviewActive := False;
    end;
  end;
  FNotesHtmlPanel.Visible := FNotesPreviewActive;
  NotesMemo.Visible := not FNotesPreviewActive;
  if FNotesPreviewActive then
    FNotesToggleLabel.Caption := 'Bearbeiten'
  else
    FNotesToggleLabel.Caption := 'Vorschau';
end;

procedure TMainForm.LayoutChapterView(Sender: TObject);
const
  Margin = 24;
  Gap = 26;
  RowTop = 316;       // Höhe der Spaltenüberschriften
  ColTop = 344;       // Beginn der Inhalte
  TaskListH = 120;
  InputH = 27;
  LabelH = 28;
var
  W, H, ColW, LeftX, RightX, Bottom: Integer;
  NotesLabelY, NotesMemoY, NotesMemoH, InputY: Integer;
begin
  if not Assigned(FTaskList) then
    Exit;
  W := ChapterPanel.ClientWidth;
  H := ChapterPanel.ClientHeight;

  ColW := (W - 2 * Margin - Gap) div 2;
  if ColW < 220 then
    ColW := 220;
  LeftX := Margin;
  RightX := Margin + ColW + Gap;
  Bottom := H - Margin;

  // Kopfbereich (volle Breite)
  ChapterMetaLabel.Width := W - 2 * Margin;
  ChapterActionPanel.Width := W - 2 * Margin;

  // Linke Spalte: Aufgaben oben, Notizen darunter
  FTaskLabel.SetBounds(LeftX, RowTop, ColW, 15);
  FTaskList.SetBounds(LeftX, ColTop, ColW, TaskListH);
  InputY := ColTop + TaskListH + 6;
  FTaskAddButton.SetBounds(LeftX + ColW - 36, InputY, 36, InputH);
  FTaskEdit.SetBounds(LeftX, InputY, ColW - 36 - 6, InputH);

  NotesLabelY := InputY + InputH + 14;
  NotesMemoY := NotesLabelY + LabelH;
  NotesMemoH := Bottom - NotesMemoY;
  if NotesMemoH < 80 then
    NotesMemoH := 80;
  NotesLabel.SetBounds(LeftX, NotesLabelY, 200, 15);
  FNotesToggleLabel.Left := LeftX + ColW - 70;
  FNotesToggleLabel.Top := NotesLabelY;
  NotesMemo.SetBounds(LeftX, NotesMemoY, ColW, NotesMemoH);
  if Assigned(FNotesHtmlPanel) then
    FNotesHtmlPanel.SetBounds(LeftX, NotesMemoY, ColW, NotesMemoH);

  // Rechte Spalte: Textvorschau über die volle Höhe
  PreviewLabel.SetBounds(RightX, RowTop, ColW, 15);
  PreviewMemo.SetBounds(RightX, ColTop, ColW, Bottom - ColTop);
end;

// Wandelt eine Notizzeile in eine Aufgabe um bzw. erkennt deren Status.
// Liefert True, wenn die Zeile eine Markdown-Checkbox ist.
function ParseTaskLine(const ALine: string; out ADone: Boolean;
  out AText: string): Boolean;
var
  Trimmed: string;
begin
  Result := False;
  Trimmed := TrimLeft(ALine);
  if (AnsiStartsStr('- [', Trimmed) or AnsiStartsStr('* [', Trimmed)) and
     (Length(Trimmed) >= 5) and (Trimmed[5] = ']') then
  begin
    ADone := (Trimmed[4] = 'x') or (Trimmed[4] = 'X');
    AText := Trim(Copy(Trimmed, 6, MaxInt));
    Result := True;
  end;
end;

procedure TMainForm.RefreshChapterTasks;
var
  I: Integer;
  Done: Boolean;
  TaskText: string;
begin
  if not Assigned(FTaskList) then
    Exit;
  FTaskList.Items.BeginUpdate;
  try
    FTaskList.Items.Clear;
    SetLength(FTaskLineIndex, 0);
    for I := 0 to NotesMemo.Lines.Count - 1 do
      if ParseTaskLine(NotesMemo.Lines[I], Done, TaskText) then
      begin
        FTaskList.Items.Add(TaskText);
        FTaskList.Checked[FTaskList.Items.Count - 1] := Done;
        SetLength(FTaskLineIndex, Length(FTaskLineIndex) + 1);
        FTaskLineIndex[High(FTaskLineIndex)] := I;
      end;
  finally
    FTaskList.Items.EndUpdate;
  end;
  UpdateChapterTaskCount;
end;

procedure TMainForm.UpdateChapterTaskCount;
var
  I, Open: Integer;
begin
  if not Assigned(FTaskList) then
    Exit;
  Open := 0;
  for I := 0 to FTaskList.Items.Count - 1 do
    if not FTaskList.Checked[I] then
      Inc(Open);
  if FTaskList.Items.Count = 0 then
    FTaskLabel.Caption := 'Offene Aufgaben'
  else
    FTaskLabel.Caption := Format('Offene Aufgaben (%d von %d)',
      [Open, FTaskList.Items.Count]);
end;

procedure TMainForm.TaskListClickCheck(Sender: TObject);
var
  Idx, LineIdx: Integer;
  Line, Trimmed, Indent: string;
  BoxPos: Integer;
begin
  Idx := FTaskList.ItemIndex;
  if (Idx < 0) or (Idx > High(FTaskLineIndex)) then
    Exit;
  LineIdx := FTaskLineIndex[Idx];
  if (LineIdx < 0) or (LineIdx >= NotesMemo.Lines.Count) then
    Exit;

  // `[ ]` ↔ `[x]` in der Originalzeile umschalten, Einrückung erhalten
  Line := NotesMemo.Lines[LineIdx];
  Trimmed := TrimLeft(Line);
  Indent := Copy(Line, 1, Length(Line) - Length(Trimmed));
  BoxPos := 4; // Position des Status-Zeichens in "- [ ]"
  if Length(Trimmed) >= 5 then
  begin
    if FTaskList.Checked[Idx] then
      Trimmed[BoxPos] := 'x'
    else
      Trimmed[BoxPos] := ' ';
    FUpdatingUi := True;
    try
      NotesMemo.Lines[LineIdx] := Indent + Trimmed;
    finally
      FUpdatingUi := False;
    end;
    PersistChapterNotes;
    UpdateChapterTaskCount;
    if FNotesPreviewActive then
      UpdateNotesPreviewState;
  end;
end;

procedure TMainForm.AddChapterTaskClick(Sender: TObject);
var
  TaskText: string;
begin
  TaskText := Trim(FTaskEdit.Text);
  if TaskText = '' then
    Exit;
  if not Assigned(CurrentChapter) then
    Exit;

  // Aufgabe als Markdown-Checkbox an die Notizen anhängen
  FUpdatingUi := True;
  try
    NotesMemo.Lines.Add('- [ ] ' + TaskText);
  finally
    FUpdatingUi := False;
  end;
  FTaskEdit.Clear;
  PersistChapterNotes;
  RefreshChapterTasks;
  UpdateChapterTaskCount;
  if FNotesPreviewActive then
    UpdateNotesPreviewState;
  FTaskEdit.SetFocus;
end;

procedure TMainForm.TaskEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    AddChapterTaskClick(Sender);
    Key := 0;
  end;
end;

procedure TMainForm.ReviewLinkClick(Sender: TObject);
var
  Rows: TReviewRows;
  I, RowIndex, JumpTo: Integer;
  Item: TStructuraItem;
begin
  if not Assigned(FProject) then
    Exit;
  SetLength(Rows, FProject.Count);
  RowIndex := 0;
  for I := 0 to FProject.Count - 1 do
  begin
    Item := FProject[I];
    Rows[RowIndex].ItemIndex := I;
    Rows[RowIndex].Title := Item.Title;
    if Item.ItemType = sitDivider then
    begin
      Rows[RowIndex].Number := '';
      Rows[RowIndex].Status := '';
      Rows[RowIndex].WordCount := -1;
      Rows[RowIndex].HasNotes := False;
      Rows[RowIndex].OpenTasks := 0;
      Rows[RowIndex].StaleDays := -1;
    end
    else
    begin
      Rows[RowIndex].Number := FormatChapterNumber(ChapterSequenceForIndex(I));
      Rows[RowIndex].Status := Item.Status;
      Rows[RowIndex].WordCount := ChapterWordCount(Item);
      Rows[RowIndex].HasNotes :=
        Trim(LoadTextFileSafe(AbsoluteItemNotesFileName(Item))) <> '';
      Rows[RowIndex].OpenTasks :=
        CountOpenTasksInNotes(AbsoluteItemNotesFileName(Item));
      Rows[RowIndex].StaleDays := ChapterStaleDays(Item);
    end;
    Inc(RowIndex);
  end;

  JumpTo := ShowReviewDialog(Rows);
  if JumpTo >= 0 then
    SelectItem(JumpTo);
end;

procedure TMainForm.NavigateChapter(ADelta: Integer);
var
  I: Integer;
begin
  if not Assigned(FProject) or (FProject.Count = 0) then
    Exit;
  I := FSelectedIndex + ADelta;
  while (I >= 0) and (I < FProject.Count) do
  begin
    if FProject[I].ItemType = sitChapter then
    begin
      SelectItem(I);
      Exit;
    end;
    I := I + ADelta;
  end;
end;

procedure TMainForm.NavigateToNextWithStatus(AProblemOnly: Boolean);
var
  I, Steps, Index: Integer;
  Item: TStructuraItem;
  Matches: Boolean;
begin
  if not Assigned(FProject) or (FProject.Count = 0) then
    Exit;
  // Ringsuche ab dem aktuellen Kapitel, damit man sich durchklicken kann
  for Steps := 1 to FProject.Count do
  begin
    Index := (FSelectedIndex + Steps + FProject.Count) mod FProject.Count;
    Item := FProject[Index];
    if Item.ItemType <> sitChapter then
      Continue;
    I := StatusIndex(Item.Status);
    if AProblemOnly then
      Matches := I = STATUS_PROBLEM_INDEX
    else
      Matches := I <> STATUS_FINAL_INDEX;
    if Matches then
    begin
      SelectItem(Index);
      Exit;
    end;
  end;
  if AProblemOnly then
    UpdateStatus('Keine Problemkapitel vorhanden.')
  else
    UpdateStatus('Keine offenen Kapitel — alles final.');
end;

procedure TMainForm.FormKeyDownHandler(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Strg+F öffnet die Projektsuche
  if (ssCtrl in Shift) and (Key = VK_F) then
  begin
    ProjectSearchClick(nil);
    Key := 0;
    Exit;
  end;
  if not (ssAlt in Shift) or not Assigned(FProject) then
    Exit;
  case Key of
    VK_RIGHT:
      begin
        NavigateChapter(1);
        Key := 0;
      end;
    VK_LEFT:
      begin
        NavigateChapter(-1);
        Key := 0;
      end;
    VK_O:
      begin
        NavigateToNextWithStatus(False);
        Key := 0;
      end;
    VK_P:
      begin
        NavigateToNextWithStatus(True);
        Key := 0;
      end;
  end;
end;

procedure TMainForm.ClearDashboardLinks;
var
  I: Integer;
begin
  for I := 0 to High(FDashboardLinks) do
    FDashboardLinks[I].Free;
  SetLength(FDashboardLinks, 0);
end;

procedure TMainForm.DashboardLinkClick(Sender: TObject);
begin
  if Sender is TLabel then
    SelectItem(TLabel(Sender).Tag);
end;

procedure TMainForm.RebuildDashboardLinks;
const
  MaxEntries = 4;
  LinksTop = 424;
  RowHeight = 20;
  ProblemLeft = 316;
  RecentLeft = 676;

  function AddLinkLabel(ALeft, ATop: Integer; const ACaption: string;
    AItemIndex: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := ProjectPanel;
    Result.Left := ALeft;
    Result.Top := ATop;
    Result.Caption := ACaption;
    if AItemIndex >= 0 then
    begin
      Result.Tag := AItemIndex;
      Result.Cursor := crHandPoint;
      Result.Font.Color := TColor($00B05A1E); // Blau, wie ein Link
      Result.OnClick := @DashboardLinkClick;
    end
    else
    begin
      Result.Font.Color := clGrayText;
      Result.Font.Style := [fsBold];
    end;
    SetLength(FDashboardLinks, Length(FDashboardLinks) + 1);
    FDashboardLinks[High(FDashboardLinks)] := Result;
  end;

var
  I, Row: Integer;
  Item: TStructuraItem;
  RecentIndices: array of Integer;
  RecentAges: array of TDateTime;
  FileName: string;
  Age: TDateTime;
  J, InsertAt: Integer;
begin
  ClearDashboardLinks;
  if not Assigned(FProject) then
    Exit;

  // Problemkapitel, klickbar
  Row := 0;
  for I := 0 to FProject.Count - 1 do
  begin
    Item := FProject[I];
    if (Item.ItemType <> sitChapter) or
       (StatusIndex(Item.Status) <> STATUS_PROBLEM_INDEX) then
      Continue;
    if Row = 0 then
      AddLinkLabel(ProblemLeft, LinksTop, 'Problemkapitel', -1);
    if Row < MaxEntries then
      AddLinkLabel(ProblemLeft, LinksTop + (Row + 1) * RowHeight,
        Format('%s  %s', [FormatChapterNumber(ChapterSequenceForIndex(I)), Item.Title]), I)
    else if Row = MaxEntries then
      AddLinkLabel(ProblemLeft, LinksTop + (MaxEntries + 1) * RowHeight, '…', -1);
    Inc(Row);
  end;

  // Zuletzt bearbeitete Kapitel (nach Dateiänderungsdatum, neueste zuerst)
  SetLength(RecentIndices, 0);
  SetLength(RecentAges, 0);
  for I := 0 to FProject.Count - 1 do
  begin
    Item := FProject[I];
    if Item.ItemType <> sitChapter then
      Continue;
    FileName := AbsoluteItemFileName(Item);
    if not FileExists(FileName) then
      Continue;
    if not FileAge(FileName, Age) then
      Continue;
    InsertAt := Length(RecentIndices);
    for J := 0 to High(RecentIndices) do
      if Age > RecentAges[J] then
      begin
        InsertAt := J;
        Break;
      end;
    if InsertAt >= MaxEntries then
      Continue;
    SetLength(RecentIndices, Min(Length(RecentIndices) + 1, MaxEntries));
    SetLength(RecentAges, Length(RecentIndices));
    for J := High(RecentIndices) downto InsertAt + 1 do
    begin
      RecentIndices[J] := RecentIndices[J - 1];
      RecentAges[J] := RecentAges[J - 1];
    end;
    RecentIndices[InsertAt] := I;
    RecentAges[InsertAt] := Age;
  end;

  if Length(RecentIndices) > 0 then
  begin
    AddLinkLabel(RecentLeft, LinksTop, 'Zuletzt bearbeitet', -1);
    for I := 0 to High(RecentIndices) do
    begin
      Item := FProject[RecentIndices[I]];
      AddLinkLabel(RecentLeft, LinksTop + (I + 1) * RowHeight,
        Format('%s  %s', [FormatChapterNumber(ChapterSequenceForIndex(RecentIndices[I])), Item.Title]),
        RecentIndices[I]);
    end;
  end;

  // Einstieg in die Review-Tabelle, links unter dem Cover
  with AddLinkLabel(24, LinksTop, 'Review-Ansicht öffnen →', -1) do
  begin
    Cursor := crHandPoint;
    Font.Color := TColor($00B05A1E);
    Font.Style := [];
    OnClick := @ReviewLinkClick;
  end;
end;

procedure TMainForm.DashboardPaint(Sender: TObject);
const
  BarHeight = 14;
  RowHeight = 20;
  ColWidth = 240;
var
  C: TCanvas;
  Total, I, X, SegWidth, LegendTop, Col, Row, DotY: Integer;
  InfoText: string;
begin
  if not Assigned(FProject) then
    Exit;
  C := FDashboardBox.Canvas;
  C.Brush.Color := clWindow;
  C.FillRect(0, 0, FDashboardBox.Width, FDashboardBox.Height);

  Total := 0;
  for I := Low(FStatusCounts) to High(FStatusCounts) do
    Inc(Total, FStatusCounts[I]);
  if Total = 0 then
  begin
    C.Font.Color := clGrayText;
    C.TextOut(0, 0, 'Noch keine Kapitel angelegt.');
    Exit;
  end;

  // Segmentierter Fortschrittsbalken: Anteile je Status
  X := 0;
  for I := Low(FStatusCounts) to High(FStatusCounts) do
  begin
    if FStatusCounts[I] = 0 then
      Continue;
    SegWidth := Round(FDashboardBox.Width * FStatusCounts[I] / Total);
    if SegWidth < 2 then
      SegWidth := 2;
    if X + SegWidth > FDashboardBox.Width then
      SegWidth := FDashboardBox.Width - X;
    C.Brush.Color := StatusColor(STRUCTURA_STATUSES[I]);
    C.FillRect(X, 0, X + SegWidth, BarHeight);
    X := X + SegWidth;
  end;
  // Rundungsrest mit letzter Farbe auffüllen
  if X < FDashboardBox.Width then
    C.FillRect(X, 0, FDashboardBox.Width, BarHeight);

  // Legende in zwei Spalten: Punkt + Anzahl + Statusname
  LegendTop := BarHeight + 10;
  Col := 0;
  Row := 0;
  C.Font.Color := clWindowText;
  C.Pen.Color := clGray;
  for I := Low(FStatusCounts) to High(FStatusCounts) do
  begin
    if FStatusCounts[I] = 0 then
      Continue;
    DotY := LegendTop + Row * RowHeight + (RowHeight - 10) div 2;
    C.Brush.Color := StatusColor(STRUCTURA_STATUSES[I]);
    C.Ellipse(Col * ColWidth, DotY, Col * ColWidth + 10, DotY + 10);
    C.Brush.Style := bsClear;
    C.TextOut(Col * ColWidth + 16, LegendTop + Row * RowHeight,
      Format('%d %s', [FStatusCounts[I], STRUCTURA_STATUSES[I]]));
    C.Brush.Style := bsSolid;
    Inc(Row);
    if Row >= 4 then
    begin
      Row := 0;
      Inc(Col);
    end;
  end;

  // Offene Aufgaben und nächster Schritt
  C.Brush.Style := bsClear;
  InfoText := '';
  if FOpenTaskCount > 0 then
    InfoText := Format('%d offene Aufgaben in den Notizen', [FOpenTaskCount]);
  if InfoText <> '' then
  begin
    C.Font.Color := clGrayText;
    C.TextOut(0, LegendTop + 4 * RowHeight + 6, InfoText);
  end;
  if FNextStepText <> '' then
  begin
    C.Font.Color := clWindowText;
    C.Font.Style := [fsBold];
    C.TextOut(0, LegendTop + 4 * RowHeight + 26, FNextStepText);
    C.Font.Style := [];
  end;
  if FHintText <> '' then
  begin
    C.Font.Color := clGrayText;
    C.TextOut(0, LegendTop + 4 * RowHeight + 48, FHintText);
  end;
  C.Brush.Style := bsSolid;
end;

procedure TMainForm.ItemListDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  Item: TStructuraItem;
  TextRect: TRect;
  TextStyle: TTextStyle;
  CenterY, Radius: Integer;
  IsSelected, IsDivider: Boolean;
begin
  ListBox := TListBox(Control);
  IsSelected := odSelected in State;

  Item := nil;
  if Assigned(FProject) and (Index >= 0) and (Index < FProject.Count) then
    Item := FProject[Index];
  IsDivider := Assigned(Item) and (Item.ItemType = sitDivider);

  if IsSelected then
  begin
    ListBox.Canvas.Brush.Color := clHighlight;
    ListBox.Canvas.Font.Color := clHighlightText;
  end
  else if IsDivider then
  begin
    ListBox.Canvas.Brush.Color := clBtnFace;
    ListBox.Canvas.Font.Color := clGrayText;
  end
  else
  begin
    ListBox.Canvas.Brush.Color := clWindow;
    ListBox.Canvas.Font.Color := clWindowText;
  end;
  ListBox.Canvas.FillRect(ARect);

  TextRect := ARect;
  TextRect.Right := TextRect.Right - 4;

  if IsDivider then
  begin
    ListBox.Canvas.Font.Style := [fsBold];
    TextRect.Left := TextRect.Left + 8;
  end
  else
  begin
    ListBox.Canvas.Font.Style := [];
    // Statuspunkt links vor dem Kapiteltitel
    if Assigned(Item) then
    begin
      CenterY := (ARect.Top + ARect.Bottom) div 2;
      Radius := 5;
      ListBox.Canvas.Pen.Color := clGray;
      ListBox.Canvas.Brush.Color := StatusColor(Item.Status);
      ListBox.Canvas.Ellipse(ARect.Left + 8, CenterY - Radius,
        ARect.Left + 8 + 2 * Radius, CenterY + Radius);
    end;
    TextRect.Left := TextRect.Left + 26;
  end;

  ListBox.Canvas.Brush.Style := bsClear;
  TextStyle := ListBox.Canvas.TextStyle;
  TextStyle.Layout := tlCenter;
  TextStyle.SingleLine := True;
  TextStyle.EndEllipsis := True;
  ListBox.Canvas.TextRect(TextRect, TextRect.Left, TextRect.Top,
    ListBox.Items[Index], TextStyle);
  ListBox.Canvas.Brush.Style := bsSolid;
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

procedure TMainForm.EnsureDailyZipBackup(AForceUpdate: Boolean);

  // Datum aus Dateinamen der Form JJJJ-MM-TT.zip lesen; False bei Fremddateien.
  function TryDateFromZipName(const AFileName: string; out ADate: TDateTime): Boolean;
  var
    Base: string;
    Y, M, D: Integer;
  begin
    Result := False;
    Base := ChangeFileExt(ExtractFileName(AFileName), '');
    if Length(Base) <> 10 then
      Exit;
    if not TryStrToInt(Copy(Base, 1, 4), Y) then Exit;
    if not TryStrToInt(Copy(Base, 6, 2), M) then Exit;
    if not TryStrToInt(Copy(Base, 9, 2), D) then Exit;
    Result := TryEncodeDate(Y, M, D, ADate);
  end;

  procedure PruneOldDailyBackups(const ADailyFolder: string);
  var
    Zips: TStringList;
    I, KeepDays: Integer;
    ZipDate: TDateTime;
  begin
    KeepDays := 14;
    if Assigned(FSettings) and (FSettings.DailyBackupKeepDays >= 1) then
      KeepDays := FSettings.DailyBackupKeepDays;
    Zips := TStringList.Create;
    try
      FindAllFiles(Zips, ADailyFolder, '*.zip', False);
      for I := 0 to Zips.Count - 1 do
        if TryDateFromZipName(Zips[I], ZipDate) then
          if Trunc(Now) - Trunc(ZipDate) > KeepDays then
            DeleteFile(Zips[I]);
    finally
      Zips.Free;
    end;
  end;

var
  DailyFolder, ZipFileName, ProjectRoot, BackupRoot, Relative: string;
  Files: TStringList;
  Zip: TZipper;
  I: Integer;
begin
  if not Assigned(FProject) then
    Exit;

  ProjectRoot := IncludeTrailingPathDelimiter(FProject.FolderPath);
  BackupRoot := ProjectRoot + 'backup';
  DailyFolder := BackupRoot + PathDelim + 'daily';
  ZipFileName := DailyFolder + PathDelim + FormatDateTime('yyyy-mm-dd', Now) + '.zip';

  // Beim Öffnen genügt ein Backup pro Tag. Beim Schließen (AForceUpdate)
  // wird das heutige Backup auf den aktuellen Stand gebracht, damit die
  // Arbeit der Sitzung gesichert ist.
  if FileExists(ZipFileName) then
  begin
    if not AForceUpdate then
      Exit;
    DeleteFile(ZipFileName);
  end;

  Files := TStringList.Create;
  Zip := TZipper.Create;
  try
    try
      FindAllFiles(Files, FProject.FolderPath, '*', True);
      Zip.FileName := ZipFileName;
      for I := 0 to Files.Count - 1 do
      begin
        // Den Backup-Ordner selbst nie mitsichern, sonst wächst jedes Backup
        // um alle vorherigen.
        if AnsiStartsText(BackupRoot + PathDelim, Files[I]) then
          Continue;
        Relative := ExtractRelativePath(ProjectRoot, Files[I]);
        Zip.Entries.AddFileEntry(Files[I],
          StringReplace(Relative, '\', '/', [rfReplaceAll]));
      end;
      if Zip.Entries.Count > 0 then
      begin
        ForceDirectories(DailyFolder);
        Zip.ZipAllFiles;
        PruneOldDailyBackups(DailyFolder);
        UpdateStatus('Tagesbackup erstellt: backup\daily\' +
          ExtractFileName(ZipFileName));
      end;
    except
      on E: Exception do
        UpdateStatus('Tagesbackup fehlgeschlagen: ' + E.Message);
    end;
  finally
    Zip.Free;
    Files.Free;
  end;
end;

// Vor dem Schließen/Wechseln: Notizen sichern und das heutige Tagesbackup
// auf den aktuellen Stand bringen.
procedure TMainForm.BackupCurrentProjectOnClose;
begin
  if not Assigned(FProject) then
    Exit;
  PersistCurrentNotes;
  PersistProjectNotes;
  SaveProject;
  EnsureDailyZipBackup(True);
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

  if FileIsLockedForRename(OldAbsolute) then
  begin
    MessageDlg('Datei ist in Verwendung',
      'Die Kapiteldatei "' + ExtractFileName(OldAbsolute) + '" ist gerade in einem ' +
      'anderen Programm geöffnet oder schreibgeschützt.' + LineEnding +
      'Bitte schließe die Datei und versuche es erneut.',
      mtError, [mbOK], 0);
    Exit(False);
  end;

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

  // Vorab prüfen, ob eine der Kapiteldateien gesperrt ist, bevor irgendetwas
  // umbenannt wird — sonst bliebe das Projekt halb umbenannt zurück.
  for I := 0 to FProject.Count - 1 do
  begin
    Item := FProject[I];
    if Item.ItemType <> sitChapter then
      Continue;
    OldAbsolute := AbsoluteItemFileName(Item);
    if FileIsLockedForRename(OldAbsolute) then
    begin
      MessageDlg('Datei ist in Verwendung',
        'Die Kapiteldatei "' + ExtractFileName(OldAbsolute) + '" ist gerade in einem ' +
        'anderen Programm geöffnet oder schreibgeschützt.' + LineEnding +
        'Bitte schließe die Datei und starte die Umbenennung erneut. ' +
        'Es wurde noch keine Datei verändert.',
        mtError, [mbOK], 0);
      Exit(False);
    end;
  end;

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
      // Bild-Platzhalter; wenn er fehlt, graues Panel hinter dem TImage
      if FileExists(AssetPath('assets\cover_placeholder.png')) then
        try
          CoverImg.Picture.LoadFromFile(AssetPath('assets\cover_placeholder.png'));
        except
        end;
      if (not Assigned(CoverImg.Picture.Graphic)) or CoverImg.Picture.Graphic.Empty then
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

procedure TMainForm.CloseProjectClick(Sender: TObject);
begin
  // Offene Notizen sichern, Tagesbackup aktualisieren und zur Startliste zurück
  BackupCurrentProjectOnClose;
  FSelectedIndex := -1;
  ItemListBox.ItemIndex := -1;
  FreeAndNil(FProject);
  RefreshItemList;
  SelectProjectOverview;
end;

procedure TMainForm.DrawCoverPlaceholder;
var
  Bmp: TBitmap;
  W, H: Integer;
  PlaceholderPath: string;
begin
  // Hübscher Bild-Platzhalter, wenn vorhanden
  PlaceholderPath := AssetPath('assets\cover_placeholder.png');
  if FileExists(PlaceholderPath) then
    try
      CoverImage.Picture.LoadFromFile(PlaceholderPath);
      Exit;
    except
      // fällt unten auf den gezeichneten Platzhalter zurück
    end;

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
  RootFolder, TargetFolder, BaseName, SourceRoot, CoverExt: string;
  Project: TStructuraProject;
  I, Seq, ChapterCount: Integer;
  ChapterTitle, SourceFile, TargetRel, TargetAbs: string;
  Item: TStructuraItem;
begin
  // Hauptordner (Projekt-Wurzel), unter dem das importierte Projekt entsteht
  RootFolder := '';
  if Assigned(FSettings) then
    RootFolder := Trim(FSettings.DefaultProjectFolder);
  if RootFolder = '' then
    RootFolder := GetUserDir;

  Res := ShowImportDialog(Self, '');
  if not Res.Confirmed then
  begin
    FreeAndNil(Res.SelectedFiles);
    Exit;
  end;

  try
    SourceRoot := IncludeTrailingPathDelimiter(Res.FolderPath);

    // Zielordner = Wurzel + Unterordner aus dem Projekttitel, Kollision vermeiden
    BaseName := MakeSafeFileNamePart(Res.Title);
    TargetFolder := IncludeTrailingPathDelimiter(RootFolder) + BaseName;
    Seq := 2;
    while DirectoryExists(TargetFolder) and
          FileExists(TProjectStore.ProjectFileName(TargetFolder)) do
    begin
      TargetFolder := IncludeTrailingPathDelimiter(RootFolder) +
        BaseName + '_' + IntToStr(Seq);
      Inc(Seq);
    end;

    TProjectStore.EnsureProjectFolders(TargetFolder);

    Project := TStructuraProject.Create;
    try
      Project.FolderPath := TargetFolder;
      Project.Title      := Res.Title;
      Project.Author     := Res.Author;

      // Cover aus dem Quellordner übernehmen, falls vorhanden
      CoverExt := '';
      if FileExists(SourceRoot + 'cover.png') then
        CoverExt := 'png'
      else if FileExists(SourceRoot + 'cover.jpg') then
        CoverExt := 'jpg'
      else if FileExists(SourceRoot + 'cover.jpeg') then
        CoverExt := 'jpeg';
      if CoverExt <> '' then
      begin
        CopyFile(SourceRoot + 'cover.' + CoverExt,
          IncludeTrailingPathDelimiter(TargetFolder) + 'cover.' + CoverExt,
          [cffOverwriteFile]);
        Project.CoverImagePath := 'cover.' + CoverExt;
      end;

      // Kapitel und Teile in der gewählten Reihenfolge übernehmen; die DOCX
      // werden in den chapters/-Ordner des neuen Projekts kopiert (Originale
      // bleiben unangetastet) und sauber nummeriert.
      ChapterCount := 0;
      for I := 0 to High(Res.Entries) do
      begin
        if Res.Entries[I].Kind = iekDivider then
        begin
          Project.AddDivider(Res.Entries[I].Data);
        end
        else
        begin
          SourceFile := SourceRoot +
            StringReplace(Res.Entries[I].Data, '/', PathDelim, [rfReplaceAll]);
          if not FileExists(SourceFile) then
            Continue;
          Inc(ChapterCount);
          ChapterTitle := TrimLeft(ChangeFileExt(ExtractFileName(SourceFile), ''));
          TargetRel := RelativeProjectPath(['chapters',
            Format('%s_%s.docx', [FormatChapterNumber(ChapterCount),
              MakeSafeFileNamePart(ChapterTitle)])]);
          TargetAbs := TProjectStore.AbsolutePath(TargetFolder, TargetRel);
          if not CopyFile(SourceFile, TargetAbs, [cffOverwriteFile]) then
            Continue;
          Item := Project.AddChapter(ChapterTitle, TargetRel);
          Item.Status := 'Rohfassung';
        end;
      end;

      SaveTextFileSafe(
        TProjectStore.AbsolutePath(TargetFolder,
          RelativeProjectPath(['notes', 'project.md'])),
        '# Projektnotizen' + LineEnding + LineEnding);

      TProjectStore.SaveToFolder(Project);
      SetProject(Project);

      if Assigned(FSettings) then
      begin
        FSettings.DefaultProjectFolder := RootFolder;
        FSettings.AddRecentProject(TargetFolder);
        TSettingsStore.Save(FSettings);
      end;

      UpdateStatus(Format('Projekt importiert: %s (%d Kapitel) → %s',
        [Res.Title, ChapterCount, TargetFolder]));
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

// Sanfter Schutz für finale Kapitel: nicht sperren, nur nachfragen.
function TMainForm.ConfirmFinalChange(AItem: TStructuraItem;
  const AAction: string): Boolean;
begin
  Result := True;
  if not Assigned(AItem) or (AItem.ItemType <> sitChapter) then
    Exit;
  if StatusIndex(AItem.Status) <> STATUS_FINAL_INDEX then
    Exit;
  Result := MessageDlg('Finales Kapitel',
    Format('Das Kapitel „%s" ist als final markiert.' + LineEnding +
      'Trotzdem %s?', [AItem.Title, AAction]),
    mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TMainForm.EditItemClick(Sender: TObject);
var
  Item: TStructuraItem;
  ResultData: TElementDialogResult;
begin
  Item := CurrentItem;
  if not Assigned(Item) then
    Exit;
  if not ConfirmFinalChange(Item, 'bearbeiten') then
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
  if not ConfirmFinalChange(Item, 'löschen') then
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
  if (FromIndex < FProject.Count) and
     not ConfirmFinalChange(FProject[FromIndex], 'verschieben') then
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
var
  OldDigits: Integer;
begin
  if not Assigned(FSettings) then
    Exit;
  OldDigits := FSettings.ChapterNumberDigits;
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

    // Formatwechsel benennt niemals stillschweigend Dateien um — immer nachfragen.
    if Assigned(FProject) and (FSettings.ChapterNumberDigits <> OldDigits) then
    begin
      if MessageDlg('Nummerierungsformat geändert',
        'Das Nummerierungsformat wurde geändert.' + LineEnding +
        'Sollen die vorhandenen Kapiteldateien jetzt an das neue Format ' +
        'angepasst werden?' + LineEnding + LineEnding +
        'Vor der Umbenennung wird ein Backup erstellt.',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        if RenumberChapterFiles then
        begin
          SaveProject;
          RefreshAll;
          UpdateStatus('Kapiteldateien an das neue Nummerierungsformat angepasst.');
        end
        else
          MessageDlg('Umbenennung unvollständig',
            'Einige Kapiteldateien konnten nicht umbenannt werden.',
            mtWarning, [mbOK], 0);
      end
      else
        UpdateStatus('Neues Format wird erst bei der nächsten Umbenennung angewendet.');
    end;
  end;
end;

procedure TMainForm.ExportClick(Sender: TObject);
var
  InfoText: string;
  Options: TExportOptions;
  Digits: Integer;
  MasterDocx, ExportFolder: string;
begin
  if not Assigned(FProject) then
    Exit;
  PersistCurrentNotes;
  Digits := 2;
  if Assigned(FSettings) and (FSettings.ChapterNumberDigits >= 1) and
     (FSettings.ChapterNumberDigits <= 3) then
    Digits := FSettings.ChapterNumberDigits;
  if not ShowExportDialog(FProject, Digits, Options) then
    Exit;
  if not TDocumentWorkflow.ExportMasterDocument(FProject, Options, InfoText) then
  begin
    MessageDlg('Export fehlgeschlagen', InfoText, mtError, [mbOK], 0);
    Exit;
  end;

  ExportFolder := IncludeTrailingPathDelimiter(FProject.FolderPath) + 'export';
  MasterDocx := IncludeTrailingPathDelimiter(ExportFolder) + 'master.docx';

  // Nach erfolgreichem Export anbieten, das Ergebnis zu öffnen
  if MessageDlg('Export abgeschlossen',
    InfoText + LineEnding + LineEnding +
    'Exportierte DOCX-Datei jetzt öffnen?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if FileExists(MasterDocx) then
      OpenDocument(MasterDocx)
    else
      ShowInFileManager(ExportFolder);
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  try
    PersistCurrentNotes;
    SaveProject;
    EnsureDailyZipBackup(True);
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
