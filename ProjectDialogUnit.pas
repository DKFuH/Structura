unit ProjectDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs, Graphics;

type
  TProjectDialogResult = record
    Confirmed: Boolean;
    Title: string;
    Subtitle: string;
    Author: string;
    FolderPath: string;
    CoverImagePath: string;
  end;

  TProjectDialogForm = class(TForm)
  published
    AuthorEdit: TEdit;
    CancelButton: TButton;
    CoverBrowseButton: TButton;
    CoverEdit: TEdit;
    ErrorLabel: TLabel;
    FolderBrowseButton: TButton;
    FolderEdit: TEdit;
    HeaderLabel: TLabel;
    OkButton: TButton;
    AuthorLabel: TLabel;
    CoverLabel: TLabel;
    FolderLabel: TLabel;
    SubtitleLabel: TLabel;
    TitleLabel: TLabel;
    MainPanel: TPanel;
    SubtitleEdit: TEdit;
    TitleEdit: TEdit;
    procedure BrowseCoverClick(Sender: TObject);
    procedure BrowseFolderClick(Sender: TObject);
  private
    function ValidateInput: Boolean;
  public
    function Execute(out AResult: TProjectDialogResult): Boolean;
  end;

function ExecuteProjectDialog(const InitialFolder: string): TProjectDialogResult;

implementation

{$R *.lfm}

procedure TProjectDialogForm.BrowseFolderClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := FolderEdit.Text;
  if SelectDirectory('Projektordner wählen', '', Dir) then
    FolderEdit.Text := Dir;
end;

procedure TProjectDialogForm.BrowseCoverClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Filter := 'Bilddateien|*.png;*.jpg;*.jpeg;*.bmp';
    if Dialog.Execute then
      CoverEdit.Text := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

function TProjectDialogForm.ValidateInput: Boolean;
begin
  ErrorLabel.Caption := '';
  Result := False;
  if Trim(TitleEdit.Text) = '' then
  begin
    ErrorLabel.Caption := 'Bitte einen Projekttitel eingeben.';
    Exit;
  end;
  if Trim(FolderEdit.Text) = '' then
  begin
    ErrorLabel.Caption := 'Bitte einen Projektordner wählen.';
    Exit;
  end;
  Result := True;
end;

function TProjectDialogForm.Execute(out AResult: TProjectDialogResult): Boolean;
begin
  FillChar(AResult, SizeOf(AResult), 0);
  repeat
    Result := ShowModal = mrOk;
    if not Result then
      Exit(False);
  until ValidateInput;

  AResult.Confirmed := True;
  AResult.Title := Trim(TitleEdit.Text);
  AResult.Subtitle := Trim(SubtitleEdit.Text);
  AResult.Author := Trim(AuthorEdit.Text);
  AResult.FolderPath := Trim(FolderEdit.Text);
  AResult.CoverImagePath := Trim(CoverEdit.Text);
end;

function ExecuteProjectDialog(const InitialFolder: string): TProjectDialogResult;
var
  Dialog: TProjectDialogForm;
begin
  FillChar(Result, SizeOf(Result), 0);
  Dialog := TProjectDialogForm.Create(nil);
  try
    Dialog.FolderEdit.Text := InitialFolder;
    Dialog.TitleEdit.Text := 'Neues Buch';
    Dialog.Execute(Result);
  finally
    Dialog.Free;
  end;
end;

end.
