unit SettingsDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
  AppSettings, OfficeDetection;

type
  TSettingsDialogForm = class(TForm)
    AddWorkflowButton: TButton;
    CancelButton: TButton;
    DefaultProjectFolderEdit: TEdit;
    DefaultProjectFolderLabel: TLabel;
    DeleteWorkflowButton: TButton;
    DownWorkflowButton: TButton;
    EditWorkflowButtonBtn: TButton;
    GeneralTab: TTabSheet;
    LibreOfficeEdit: TEdit;
    LibreOfficeLabel: TLabel;
    LibreOfficeStateLabel: TLabel;
    LibreOfficeTestButton: TButton;
    MainPageControl: TPageControl;
    OkButton: TButton;
    PreferredEditorEdit: TEdit;
    PreferredEditorLabel: TLabel;
    ProgramStatusLabel: TLabel;
    RescanProgramsButton: TButton;
    SettingsPanel: TPanel;
    TextMakerEdit: TEdit;
    TextMakerLabel: TLabel;
    TextMakerStateLabel: TLabel;
    TextMakerTestButton: TButton;
    UpWorkflowButton: TButton;
    WordEdit: TEdit;
    WordLabel: TLabel;
    WordStateLabel: TLabel;
    WordTestButton: TButton;
    WorkflowHintLabel: TLabel;
    WorkflowListBox: TListBox;
    WorkflowTab: TTabSheet;
    procedure AddWorkflowButtonClick(Sender: TObject);
    procedure DeleteWorkflowButtonClick(Sender: TObject);
    procedure DownWorkflowButtonClick(Sender: TObject);
    procedure EditWorkflowButtonBtnClick(Sender: TObject);
    procedure RescanProgramsButtonClick(Sender: TObject);
    procedure TestProgramButtonClick(Sender: TObject);
    procedure UpWorkflowButtonClick(Sender: TObject);
  private
    FSettings: TAppSettings;
    FWorkingCopy: TAppSettings;
    FDetectedTargets: TOfficeTargets;
    procedure RefreshWorkflowList;
    procedure SyncDetectedTargetsToWorkingCopy;
    procedure RefreshProgramState;
    function ProgramStateText(const CurrentValue, DetectedValue: string): string;
  public
    function Execute(ASettings: TAppSettings): Boolean;
  end;

function EditAppSettings(ASettings: TAppSettings): Boolean;

implementation

{$R *.lfm}

uses
  WorkflowButtonDialogUnit, FileUtil, StrUtils;

procedure TSettingsDialogForm.RefreshWorkflowList;
var
  I: Integer;
begin
  WorkflowListBox.Items.BeginUpdate;
  try
    WorkflowListBox.Items.Clear;
    for I := 0 to FWorkingCopy.WorkflowButtonCount - 1 do
      WorkflowListBox.Items.Add(FWorkingCopy.WorkflowButtons[I].Name + ' -> ' +
        FWorkingCopy.WorkflowButtons[I].Target);
  finally
    WorkflowListBox.Items.EndUpdate;
  end;
end;

function TSettingsDialogForm.ProgramStateText(const CurrentValue,
  DetectedValue: string): string;
begin
  if Trim(CurrentValue) = '' then
  begin
    if Trim(DetectedValue) <> '' then
      Exit('automatisch gefunden')
    else
      Exit('nicht gefunden');
  end;

  if (Trim(DetectedValue) <> '') and SameText(ExpandFileName(CurrentValue),
    ExpandFileName(DetectedValue)) then
    Result := 'automatisch gefunden'
  else
    Result := 'manuell gesetzt';
end;

procedure TSettingsDialogForm.SyncDetectedTargetsToWorkingCopy;
begin
  if Trim(FWorkingCopy.WordPathOverride) = '' then
    FWorkingCopy.WordPathOverride := FDetectedTargets.WordPath;
  if Trim(FWorkingCopy.LibreOfficePathOverride) = '' then
    FWorkingCopy.LibreOfficePathOverride := FDetectedTargets.LibreOfficePath;
  if Trim(FWorkingCopy.TextMakerPathOverride) = '' then
    FWorkingCopy.TextMakerPathOverride := FDetectedTargets.TextMakerPath;
end;

procedure TSettingsDialogForm.RefreshProgramState;
var
  PdfStatus: string;
begin
  WordStateLabel.Caption := ProgramStateText(WordEdit.Text, FDetectedTargets.WordPath);
  LibreOfficeStateLabel.Caption := ProgramStateText(LibreOfficeEdit.Text, FDetectedTargets.LibreOfficePath);
  TextMakerStateLabel.Caption := ProgramStateText(TextMakerEdit.Text, FDetectedTargets.TextMakerPath);

  if Trim(WordEdit.Text) <> '' then
    PdfStatus := 'PDF-Export potenziell über Word'
  else if Trim(LibreOfficeEdit.Text) <> '' then
    PdfStatus := 'PDF-Export verfügbar über LibreOffice'
  else if Trim(TextMakerEdit.Text) <> '' then
    PdfStatus := 'PDF-Export potenziell über TextMaker'
  else
    PdfStatus := 'PDF-Export aktuell nicht verfügbar';

  ProgramStatusLabel.Caption :=
    'Standard-DOCX: über Betriebssystem verfügbar' + LineEnding +
    'Word: ' + IfThen(Trim(WordEdit.Text) <> '', 'verfügbar', 'nicht gefunden') + LineEnding +
    'LibreOffice: ' + IfThen(Trim(LibreOfficeEdit.Text) <> '', 'verfügbar', 'nicht gefunden') + LineEnding +
    'SoftMaker TextMaker: ' + IfThen(Trim(TextMakerEdit.Text) <> '', 'verfügbar', 'nicht gefunden') + LineEnding +
    PdfStatus;
end;

procedure TSettingsDialogForm.AddWorkflowButtonClick(Sender: TObject);
var
  Button: TWorkflowButtonConfig;
begin
  Button := FWorkingCopy.AddWorkflowButton;
  Button.Name := 'Neuer Workflow';
  Button.Target := 'https://';
  if not EditWorkflowButton(Button) then
  begin
    FWorkingCopy.DeleteWorkflowButton(FWorkingCopy.WorkflowButtonCount - 1);
    Exit;
  end;
  RefreshWorkflowList;
  WorkflowListBox.ItemIndex := FWorkingCopy.WorkflowButtonCount - 1;
end;

procedure TSettingsDialogForm.DeleteWorkflowButtonClick(Sender: TObject);
begin
  if WorkflowListBox.ItemIndex < 0 then
    Exit;
  FWorkingCopy.DeleteWorkflowButton(WorkflowListBox.ItemIndex);
  RefreshWorkflowList;
end;

procedure TSettingsDialogForm.DownWorkflowButtonClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := WorkflowListBox.ItemIndex;
  if (Index < 0) or (Index >= FWorkingCopy.WorkflowButtonCount - 1) then
    Exit;
  FWorkingCopy.MoveWorkflowButton(Index, Index + 1);
  RefreshWorkflowList;
  WorkflowListBox.ItemIndex := Index + 1;
end;

procedure TSettingsDialogForm.EditWorkflowButtonBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := WorkflowListBox.ItemIndex;
  if Index < 0 then
    Exit;
  if EditWorkflowButton(FWorkingCopy.WorkflowButtons[Index]) then
    RefreshWorkflowList;
end;

procedure TSettingsDialogForm.RescanProgramsButtonClick(Sender: TObject);
begin
  FDetectedTargets := DetectOfficeTargets;
  SyncDetectedTargetsToWorkingCopy;
  WordEdit.Text := FWorkingCopy.WordPathOverride;
  LibreOfficeEdit.Text := FWorkingCopy.LibreOfficePathOverride;
  TextMakerEdit.Text := FWorkingCopy.TextMakerPathOverride;
  RefreshProgramState;
end;

procedure TSettingsDialogForm.TestProgramButtonClick(Sender: TObject);
var
  PathToTest: string;
begin
  case TComponent(Sender).Tag of
    1: PathToTest := Trim(WordEdit.Text);
    2: PathToTest := Trim(LibreOfficeEdit.Text);
    3: PathToTest := Trim(TextMakerEdit.Text);
  else
    PathToTest := '';
  end;

  if PathToTest = '' then
  begin
    MessageDlg('Pfad testen', 'Für dieses Programm ist aktuell kein Pfad gesetzt.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if FileExists(PathToTest) then
    MessageDlg('Pfad testen', 'Pfad gefunden:' + LineEnding + PathToTest, mtInformation, [mbOK], 0)
  else
    MessageDlg('Pfad testen', 'Datei nicht gefunden:' + LineEnding + PathToTest, mtError, [mbOK], 0);
end;

procedure TSettingsDialogForm.UpWorkflowButtonClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := WorkflowListBox.ItemIndex;
  if Index <= 0 then
    Exit;
  FWorkingCopy.MoveWorkflowButton(Index, Index - 1);
  RefreshWorkflowList;
  WorkflowListBox.ItemIndex := Index - 1;
end;

function TSettingsDialogForm.Execute(ASettings: TAppSettings): Boolean;
begin
  FSettings := ASettings;
  FWorkingCopy := ASettings.Clone;
  try
    FDetectedTargets := DetectOfficeTargets;
    SyncDetectedTargetsToWorkingCopy;
    DefaultProjectFolderEdit.Text := FWorkingCopy.DefaultProjectFolder;
    PreferredEditorEdit.Text := FWorkingCopy.PreferredDocxEditor;
    WordEdit.Text := FWorkingCopy.WordPathOverride;
    LibreOfficeEdit.Text := FWorkingCopy.LibreOfficePathOverride;
    TextMakerEdit.Text := FWorkingCopy.TextMakerPathOverride;
    RefreshWorkflowList;
    RefreshProgramState;

    Result := ShowModal = mrOk;
    if not Result then
      Exit(False);

    FWorkingCopy.DefaultProjectFolder := Trim(DefaultProjectFolderEdit.Text);
    FWorkingCopy.PreferredDocxEditor := Trim(PreferredEditorEdit.Text);
    FWorkingCopy.WordPathOverride := Trim(WordEdit.Text);
    FWorkingCopy.LibreOfficePathOverride := Trim(LibreOfficeEdit.Text);
    FWorkingCopy.TextMakerPathOverride := Trim(TextMakerEdit.Text);
    FWorkingCopy.EnsureDefaultWorkflowButtons;
    FSettings.Assign(FWorkingCopy);
  finally
    FWorkingCopy.Free;
    FWorkingCopy := nil;
  end;
end;

function EditAppSettings(ASettings: TAppSettings): Boolean;
var
  Dialog: TSettingsDialogForm;
begin
  Dialog := TSettingsDialogForm.Create(nil);
  try
    Result := Dialog.Execute(ASettings);
  finally
    Dialog.Free;
  end;
end;

end.
