unit ElementDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs, Graphics,
  ComCtrls, StructuraTypes;

type
  TElementDialogMode = (edmCreate, edmEdit);
  TChapterSourceMode = (csmCreateDocx, csmImportDocx);

  TElementDialogResult = record
    Confirmed: Boolean;
    ItemType: TStructuraItemType;
    Title: string;
    ChapterSource: TChapterSourceMode;
    ImportFileName: string;
  end;

  TElementDialogForm = class(TForm)
  published
    BackButton: TButton;
    BrowseButton: TButton;
    ButtonPanel: TPanel;
    CancelButton: TButton;
    DetailsPage: TTabSheet;
    ErrorLabel: TLabel;
    HeaderLabel: TLabel;
    HintLabel: TLabel;
    ImportEdit: TEdit;
    ImportLabel: TLabel;
    ImportRow: TPanel;
    NextButton: TButton;
    PageControl: TPageControl;
    SourceGroup: TRadioGroup;
    StepLabel: TLabel;
    TitleEdit: TEdit;
    TitleLabel: TLabel;
    TypeGroup: TRadioGroup;
    TypeHintLabel: TLabel;
    TypePage: TTabSheet;
    procedure BackClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure SourceChanged(Sender: TObject);
    procedure TitleChanged(Sender: TObject);
    procedure TypeChanged(Sender: TObject);
  private
    FMode: TElementDialogMode;
    FCurrentStep: Integer;
    FTitleTouched: Boolean;
    procedure UpdateStepUi;
    procedure UpdateDetailsUi;
    procedure ApplyDefaultTitle(const ADefault: string);
    function ValidateCurrentStep: Boolean;
    function IsChapter: Boolean;
  public
    function Execute(out AResult: TElementDialogResult): Boolean;
    property Mode: TElementDialogMode read FMode write FMode;
  end;

function ExecuteElementDialog(AMode: TElementDialogMode; const ACaption: string;
  const InitialTitle: string; InitialItemType: TStructuraItemType;
  InitialChapterSource: TChapterSourceMode): TElementDialogResult;

implementation

{$R *.lfm}

function TElementDialogForm.IsChapter: Boolean;
begin
  Result := TypeGroup.ItemIndex = 0;
end;

procedure TElementDialogForm.ApplyDefaultTitle(const ADefault: string);
begin
  if not FTitleTouched or (Trim(TitleEdit.Text) = '') then
    TitleEdit.Text := ADefault;
end;

procedure TElementDialogForm.TypeChanged(Sender: TObject);
begin
  if IsChapter then
    ApplyDefaultTitle('Neues Kapitel')
  else
    ApplyDefaultTitle('Neuer Teil');
  ErrorLabel.Caption := '';
  UpdateDetailsUi;
end;

procedure TElementDialogForm.SourceChanged(Sender: TObject);
begin
  ErrorLabel.Caption := '';
  UpdateDetailsUi;
end;

procedure TElementDialogForm.TitleChanged(Sender: TObject);
begin
  FTitleTouched := True;
  ErrorLabel.Caption := '';
end;

procedure TElementDialogForm.BrowseClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Filter := 'Word-Dateien|*.docx';
    Dialog.Options := [ofFileMustExist];
    if Dialog.Execute then
    begin
      ImportEdit.Text := Dialog.FileName;
      if not FTitleTouched or (Trim(TitleEdit.Text) = '') then
        TitleEdit.Text := ChangeFileExt(ExtractFileName(Dialog.FileName), '');
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TElementDialogForm.UpdateDetailsUi;
var
  ImportMode: Boolean;
begin
  ImportMode := IsChapter and (SourceGroup.ItemIndex = 1);
  SourceGroup.Visible := IsChapter;
  ImportLabel.Visible := ImportMode;
  ImportRow.Visible := ImportMode;

  if not IsChapter then
  begin
    TitleLabel.Caption := 'Titel des Trenners';
    HintLabel.Caption := 'Ein Trenner strukturiert dein Buch in Teile. Es wird keine Datei erzeugt.';
  end
  else if ImportMode then
  begin
    TitleLabel.Caption := 'Titel des importierten Kapitels';
    HintLabel.Caption := 'Wähle eine vorhandene DOCX-Datei. Structura kopiert sie in den Projektordner.';
  end
  else
  begin
    TitleLabel.Caption := 'Titel des Kapitels';
    HintLabel.Caption := 'Structura legt ein neues DOCX-Kapitel im Projektordner an.';
  end;
end;

procedure TElementDialogForm.UpdateStepUi;
begin
  if FMode = edmEdit then
  begin
    PageControl.ActivePage := DetailsPage;
    StepLabel.Caption := 'Element bearbeiten';
    BackButton.Visible := False;
    NextButton.Caption := 'Speichern';
    ErrorLabel.Caption := '';
    Exit;
  end;

  PageControl.ActivePageIndex := FCurrentStep;
  case FCurrentStep of
    0:
      begin
        StepLabel.Caption := 'Schritt 1 von 2: Typ wählen';
        BackButton.Enabled := False;
        NextButton.Caption := 'Weiter';
      end;
    1:
      begin
        StepLabel.Caption := 'Schritt 2 von 2: Details eingeben';
        BackButton.Enabled := True;
        NextButton.Caption := 'Anlegen';
      end;
  end;
end;

function TElementDialogForm.ValidateCurrentStep: Boolean;
begin
  Result := False;
  ErrorLabel.Caption := '';
  if (FMode = edmCreate) and (FCurrentStep = 0) then
    Exit(True);

  if Trim(TitleEdit.Text) = '' then
  begin
    ErrorLabel.Caption := 'Bitte einen Titel eingeben.';
    TitleEdit.SetFocus;
    Exit;
  end;
  if IsChapter and (SourceGroup.ItemIndex = 1) and
     ((Trim(ImportEdit.Text) = '') or (not FileExists(ImportEdit.Text))) then
  begin
    ErrorLabel.Caption := 'Bitte eine gültige DOCX-Datei auswählen.';
    ImportEdit.SetFocus;
    Exit;
  end;
  Result := True;
end;

procedure TElementDialogForm.NextClick(Sender: TObject);
begin
  if not ValidateCurrentStep then
    Exit;
  if (FMode = edmCreate) and (FCurrentStep = 0) then
  begin
    Inc(FCurrentStep);
    UpdateStepUi;
  end
  else
    ModalResult := mrOk;
end;

procedure TElementDialogForm.BackClick(Sender: TObject);
begin
  if FCurrentStep > 0 then
  begin
    Dec(FCurrentStep);
    UpdateStepUi;
  end;
end;

function TElementDialogForm.Execute(out AResult: TElementDialogResult): Boolean;
begin
  FillChar(AResult, SizeOf(AResult), 0);
  Result := ShowModal = mrOk;
  if not Result then
    Exit(False);

  AResult.Confirmed := True;
  if IsChapter then
  begin
    AResult.ItemType := sitChapter;
    if SourceGroup.ItemIndex = 0 then
      AResult.ChapterSource := csmCreateDocx
    else
      AResult.ChapterSource := csmImportDocx;
  end
  else
  begin
    AResult.ItemType := sitDivider;
    AResult.ChapterSource := csmCreateDocx;
  end;
  AResult.Title := Trim(TitleEdit.Text);
  AResult.ImportFileName := Trim(ImportEdit.Text);
end;

function ExecuteElementDialog(AMode: TElementDialogMode; const ACaption: string;
  const InitialTitle: string; InitialItemType: TStructuraItemType;
  InitialChapterSource: TChapterSourceMode): TElementDialogResult;
var
  Dialog: TElementDialogForm;
begin
  FillChar(Result, SizeOf(Result), 0);
  Dialog := TElementDialogForm.Create(nil);
  try
    Dialog.Mode := AMode;
    Dialog.Caption := ACaption;
    Dialog.HeaderLabel.Caption := ACaption;
    Dialog.FCurrentStep := 0;
    Dialog.FTitleTouched := False;
    Dialog.TitleEdit.Text := InitialTitle;
    if InitialItemType = sitChapter then
      Dialog.TypeGroup.ItemIndex := 0
    else
      Dialog.TypeGroup.ItemIndex := 1;
    if InitialChapterSource = csmImportDocx then
      Dialog.SourceGroup.ItemIndex := 1
    else
      Dialog.SourceGroup.ItemIndex := 0;

    if AMode = edmEdit then
    begin
      Dialog.TypeGroup.Enabled := False;
      Dialog.SourceGroup.Enabled := False;
      Dialog.HintLabel.Caption := 'Beim Umbenennen wird auch die zugehörige Datei passend umbenannt.';
    end
    else
      Dialog.TypeChanged(nil);

    Dialog.UpdateDetailsUi;
    Dialog.UpdateStepUi;
    Dialog.Execute(Result);
  finally
    Dialog.Free;
  end;
end;

end.
