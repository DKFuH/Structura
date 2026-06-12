unit ProjectPropsDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

{ Schlanker Dialog zum Bearbeiten der Projekteigenschaften (Titel, Untertitel,
  Autor, Cover) eines bestehenden Projekts. Kein Ordner-Handling. }

interface

type
  TProjectProps = record
    Confirmed:    Boolean;
    Title:        string;
    Subtitle:     string;
    Author:       string;
    NewCoverFile: string;   // '' = Cover unverändert; sonst absoluter Bildpfad
    RemoveCover:  Boolean;  // True = vorhandenes Cover entfernen
  end;

function EditProjectProperties(const ATitle, ASubtitle, AAuthor,
  ACurrentCover: string): TProjectProps;

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Graphics;

type
  TProjectPropsForm = class(TForm)
  private
    FTitle, FSubtitle, FAuthor: TEdit;
    FCoverLabel: TLabel;
    FNewCoverFile: string;
    FRemoveCover: Boolean;
    FHasCover: Boolean;
    procedure BrowseCoverClick(Sender: TObject);
    procedure RemoveCoverClick(Sender: TObject);
    procedure UpdateCoverLabel;
  public
    constructor CreateDialog(const ATitle, ASubtitle, AAuthor, ACurrentCover: string);
  end;

procedure TProjectPropsForm.UpdateCoverLabel;
begin
  if FRemoveCover then
    FCoverLabel.Caption := 'Cover wird entfernt'
  else if FNewCoverFile <> '' then
    FCoverLabel.Caption := 'Neu: ' + ExtractFileName(FNewCoverFile)
  else if FHasCover then
    FCoverLabel.Caption := 'Vorhandenes Cover bleibt'
  else
    FCoverLabel.Caption := 'Kein Cover';
end;

procedure TProjectPropsForm.BrowseCoverClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Coverbild wählen';
    Dlg.Filter := 'Bilder|*.png;*.jpg;*.jpeg|Alle Dateien|*.*';
    if Dlg.Execute then
    begin
      FNewCoverFile := Dlg.FileName;
      FRemoveCover := False;
      UpdateCoverLabel;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TProjectPropsForm.RemoveCoverClick(Sender: TObject);
begin
  FRemoveCover := True;
  FNewCoverFile := '';
  UpdateCoverLabel;
end;

constructor TProjectPropsForm.CreateDialog(const ATitle, ASubtitle, AAuthor,
  ACurrentCover: string);

  function AddLabel(const ACaption: string; AY: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Self;
    Result.SetBounds(24, AY, 200, 16);
    Result.Caption := ACaption;
    Result.Font.Style := [fsBold];
  end;

  function AddEdit(AY: Integer; const AText: string): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := Self;
    Result.SetBounds(24, AY, 472, 26);
    Result.Text := AText;
  end;

var
  BrowseBtn, RemoveBtn, OkBtn, CancelBtn: TButton;
begin
  inherited CreateNew(nil);
  Caption := 'Projekteigenschaften bearbeiten';
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := 520;
  ClientHeight := 320;

  FHasCover := Trim(ACurrentCover) <> '';
  FNewCoverFile := '';
  FRemoveCover := False;

  AddLabel('Titel', 16);
  FTitle := AddEdit(36, ATitle);
  AddLabel('Untertitel', 72);
  FSubtitle := AddEdit(92, ASubtitle);
  AddLabel('Autor', 128);
  FAuthor := AddEdit(148, AAuthor);

  AddLabel('Cover', 184);
  FCoverLabel := TLabel.Create(Self);
  FCoverLabel.Parent := Self;
  FCoverLabel.SetBounds(24, 206, 472, 18);
  FCoverLabel.Font.Color := clGrayText;
  UpdateCoverLabel;

  BrowseBtn := TButton.Create(Self);
  BrowseBtn.Parent := Self;
  BrowseBtn.SetBounds(24, 230, 150, 28);
  BrowseBtn.Caption := 'Coverbild wählen…';
  BrowseBtn.OnClick := @BrowseCoverClick;

  RemoveBtn := TButton.Create(Self);
  RemoveBtn.Parent := Self;
  RemoveBtn.SetBounds(184, 230, 130, 28);
  RemoveBtn.Caption := 'Cover entfernen';
  RemoveBtn.OnClick := @RemoveCoverClick;

  OkBtn := TButton.Create(Self);
  OkBtn.Parent := Self;
  OkBtn.SetBounds(ClientWidth - 230, ClientHeight - 40, 100, 28);
  OkBtn.Caption := 'Speichern';
  OkBtn.ModalResult := mrOk;
  OkBtn.Default := True;

  CancelBtn := TButton.Create(Self);
  CancelBtn.Parent := Self;
  CancelBtn.SetBounds(ClientWidth - 120, ClientHeight - 40, 100, 28);
  CancelBtn.Caption := 'Abbrechen';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.Cancel := True;
end;

function EditProjectProperties(const ATitle, ASubtitle, AAuthor,
  ACurrentCover: string): TProjectProps;
var
  Dlg: TProjectPropsForm;
begin
  Result.Confirmed := False;
  Result.NewCoverFile := '';
  Result.RemoveCover := False;
  Dlg := TProjectPropsForm.CreateDialog(ATitle, ASubtitle, AAuthor, ACurrentCover);
  try
    if Dlg.ShowModal = mrOk then
    begin
      Result.Confirmed := True;
      Result.Title := Trim(Dlg.FTitle.Text);
      Result.Subtitle := Trim(Dlg.FSubtitle.Text);
      Result.Author := Trim(Dlg.FAuthor.Text);
      Result.NewCoverFile := Dlg.FNewCoverFile;
      Result.RemoveCover := Dlg.FRemoveCover;
    end;
  finally
    Dlg.Free;
  end;
end;

end.
