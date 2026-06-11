unit ImportProjectDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

{ Import-Dialog: scannt einen bestehenden Ordner auf DOCX-Dateien und legt
  daraus automatisch ein Structura-Projekt an. Kein LFM – rein programmatisch. }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, FileCtrl, CheckLst;

type

  { TImportResult enthält alles was der Aufrufer nach OK braucht }
  TImportResult = record
    Confirmed:    Boolean;
    FolderPath:   string;
    Title:        string;
    Author:       string;
    SelectedFiles: TStringList;  // relative Pfade; Aufrufer muss freigeben
  end;

  TImportProjectDialog = class(TForm)
  private
    FFolderEdit:    TEdit;
    FTitleEdit:     TEdit;
    FAuthorEdit:    TEdit;
    FFileList:      TCheckListBox;
    FStatusLabel:   TLabel;

    procedure BrowseClick(Sender: TObject);
    procedure FolderEditExit(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure SelectNoneClick(Sender: TObject);
    procedure OKClick(Sender: TObject);

    procedure ScanFolder;
    function  CleanChapterTitle(const AFileName: string): string;
  public
    constructor CreateDialog(AOwner: TComponent; const ADefaultFolder: string = '');
    function    Execute: TImportResult;
  end;

{ Convenience-Funktion – erstellt den Dialog und gibt TImportResult zurück. }
function ShowImportDialog(AOwner: TComponent;
  const ADefaultFolder: string = ''): TImportResult;

implementation

uses
  LCLIntf, StrUtils, Math;

const
  DLG_W = 640;
  DLG_H = 520;
  MARGIN = 16;
  COLOR_MUTED = $00888888;

{ ─── Kapitelname aus Dateiname ableiten ───────────────────────────────────── }

function TImportProjectDialog.CleanChapterTitle(const AFileName: string): string;
var
  Base: string;
  I: Integer;
begin
  Base := ChangeFileExt(ExtractFileName(AFileName), '');

  // Führende Kapitel-Kennung entfernen: K00_, k00_, 00_, 00 , 00-
  // Muster: optionales K/k, dann Ziffern, dann optionaler Trenner
  I := 1;
  if (Length(Base) > 0) and (UpCase(Base[1]) = 'K') then
    Inc(I);
  while (I <= Length(Base)) and (Base[I] in ['0'..'9']) do
    Inc(I);
  if (I > 1) and (I <= Length(Base)) and (Base[I] in ['_', '-', ' ', '.']) then
    Inc(I);
  if I > 2 then
    Base := Copy(Base, I, MaxInt);

  // Unterstriche in Leerzeichen
  Result := StringReplace(Base, '_', ' ', [rfReplaceAll]);
  // Doppelte Leerzeichen bereinigen
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
  Result := Trim(Result);
  if Result = '' then
    Result := ChangeFileExt(ExtractFileName(AFileName), '');
end;

{ ─── Ordner scannen ──────────────────────────────────────────────────────── }

procedure TImportProjectDialog.ScanFolder;
var
  Dir: string;
  SR: TSearchRec;
  Files: TStringList;
  I: Integer;
begin
  FFileList.Items.Clear;
  Dir := Trim(FFolderEdit.Text);
  if (Dir = '') or not DirectoryExists(Dir) then
  begin
    FStatusLabel.Caption := 'Ordner nicht gefunden.';
    Exit;
  end;

  Files := TStringList.Create;
  try
    // Direkt im Projektordner
    if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*.docx', faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory) = 0 then
            Files.Add(SR.Name);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;

    // Auch im chapters/-Unterordner suchen
    if DirectoryExists(IncludeTrailingPathDelimiter(Dir) + 'chapters') then
    begin
      if FindFirst(IncludeTrailingPathDelimiter(Dir) + 'chapters' + PathDelim + '*.docx',
                   faAnyFile, SR) = 0 then
      begin
        try
          repeat
            if (SR.Attr and faDirectory) = 0 then
              Files.Add('chapters' + PathDelim + SR.Name);
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      end;
    end;

    Files.Sort;

    for I := 0 to Files.Count - 1 do
    begin
      FFileList.Items.Add(CleanChapterTitle(Files[I]) +
        '   [' + Files[I] + ']');
      FFileList.Checked[I] := True;
    end;

    if Files.Count = 0 then
      FStatusLabel.Caption := 'Keine DOCX-Dateien gefunden.'
    else
      FStatusLabel.Caption := IntToStr(Files.Count) + ' DOCX-Datei(en) gefunden.';

    // Titelfeld aus Ordnernamen vorbelegen falls noch leer
    if Trim(FTitleEdit.Text) = '' then
      FTitleEdit.Text := ExtractFileName(ExcludeTrailingPathDelimiter(Dir));
  finally
    Files.Free;
  end;
end;

{ ─── Event-Handler ───────────────────────────────────────────────────────── }

procedure TImportProjectDialog.BrowseClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := FFolderEdit.Text;
  if SelectDirectory('Projektordner wählen', '', Dir) then
  begin
    FFolderEdit.Text := Dir;
    ScanFolder;
  end;
end;

procedure TImportProjectDialog.FolderEditExit(Sender: TObject);
begin
  ScanFolder;
end;

procedure TImportProjectDialog.SelectAllClick(Sender: TObject);
var I: Integer;
begin
  for I := 0 to FFileList.Count - 1 do
    FFileList.Checked[I] := True;
end;

procedure TImportProjectDialog.SelectNoneClick(Sender: TObject);
var I: Integer;
begin
  for I := 0 to FFileList.Count - 1 do
    FFileList.Checked[I] := False;
end;

procedure TImportProjectDialog.OKClick(Sender: TObject);
begin
  if Trim(FFolderEdit.Text) = '' then
  begin
    MessageDlg('Bitte einen Ordner auswählen.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if Trim(FTitleEdit.Text) = '' then
  begin
    MessageDlg('Bitte einen Projekttitel eingeben.', mtWarning, [mbOK], 0);
    Exit;
  end;
  ModalResult := mrOK;
end;

{ ─── Konstruktor (programmatisches Layout) ───────────────────────────────── }

constructor TImportProjectDialog.CreateDialog(AOwner: TComponent;
  const ADefaultFolder: string);
var
  Y: Integer;
  Lbl: TLabel;
  BrowseBtn: TButton;
  AllBtn, NoneBtn: TButton;
  OkBtn, CancelBtn: TButton;
  Sep: TBevel;
  NavPanel: TPanel;
begin
  inherited CreateNew(AOwner);

  Caption := 'Projekt aus Ordner importieren';
  Width   := DLG_W;
  Height  := DLG_H;
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;

  Y := MARGIN;

  // ─── Ordner ───
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := MARGIN; Lbl.Top := Y;
  Lbl.Caption := 'Projektordner (mit DOCX-Dateien)';
  Inc(Y, 18);

  FFolderEdit := TEdit.Create(Self);
  FFolderEdit.Parent := Self;
  FFolderEdit.Left := MARGIN;
  FFolderEdit.Top := Y;
  FFolderEdit.Width := DLG_W - MARGIN * 2 - 48;
  FFolderEdit.Height := 28;
  FFolderEdit.Text := ADefaultFolder;
  FFolderEdit.OnExit := @FolderEditExit;

  BrowseBtn := TButton.Create(Self);
  BrowseBtn.Parent := Self;
  BrowseBtn.Caption := '...';
  BrowseBtn.Left := FFolderEdit.Left + FFolderEdit.Width + 4;
  BrowseBtn.Top := Y;
  BrowseBtn.Width := 40; BrowseBtn.Height := 28;
  BrowseBtn.OnClick := @BrowseClick;
  Inc(Y, 36);

  // ─── Titel ───
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := MARGIN; Lbl.Top := Y;
  Lbl.Caption := 'Projekttitel';
  Inc(Y, 18);

  FTitleEdit := TEdit.Create(Self);
  FTitleEdit.Parent := Self;
  FTitleEdit.Left := MARGIN; FTitleEdit.Top := Y;
  FTitleEdit.Width := DLG_W div 2 - MARGIN - 4;
  FTitleEdit.Height := 28;
  Inc(Y, 0);

  // ─── Autor (neben Titel) ───
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Left := DLG_W div 2 + 4; Lbl.Top := Y - 18;
  Lbl.Caption := 'Autor';

  FAuthorEdit := TEdit.Create(Self);
  FAuthorEdit.Parent := Self;
  FAuthorEdit.Left := DLG_W div 2 + 4; FAuthorEdit.Top := Y;
  FAuthorEdit.Width := DLG_W div 2 - MARGIN - 4;
  FAuthorEdit.Height := 28;
  Inc(Y, 36);

  // ─── Dateiliste ───
  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := Self;
  FStatusLabel.Left := MARGIN; FStatusLabel.Top := Y;
  FStatusLabel.Font.Color := COLOR_MUTED;
  FStatusLabel.Caption := 'Noch kein Ordner ausgewählt.';
  Inc(Y, 20);

  FFileList := TCheckListBox.Create(Self);
  FFileList.Parent := Self;
  FFileList.Left := MARGIN; FFileList.Top := Y;
  FFileList.Width := DLG_W - MARGIN * 2;
  FFileList.Height := DLG_H - Y - 96;
  FFileList.ItemHeight := 22;
  Inc(Y, FFileList.Height + 8);

  AllBtn := TButton.Create(Self);
  AllBtn.Parent := Self;
  AllBtn.Caption := 'Alle';
  AllBtn.Left := MARGIN; AllBtn.Top := Y;
  AllBtn.Width := 70; AllBtn.Height := 26;
  AllBtn.OnClick := @SelectAllClick;

  NoneBtn := TButton.Create(Self);
  NoneBtn.Parent := Self;
  NoneBtn.Caption := 'Keine';
  NoneBtn.Left := MARGIN + 76; NoneBtn.Top := Y;
  NoneBtn.Width := 70; NoneBtn.Height := 26;
  NoneBtn.OnClick := @SelectNoneClick;

  // ─── Nav-Bar unten ───
  NavPanel := TPanel.Create(Self);
  NavPanel.Parent := Self;
  NavPanel.Align := alBottom;
  NavPanel.Height := 52;
  NavPanel.BevelOuter := bvNone;

  Sep := TBevel.Create(NavPanel);
  Sep.Parent := NavPanel; Sep.Align := alTop; Sep.Height := 1;
  Sep.Shape := bsTopLine;

  CancelBtn := TButton.Create(NavPanel);
  CancelBtn.Parent := NavPanel;
  CancelBtn.Caption := 'Abbrechen';
  CancelBtn.Width := 100; CancelBtn.Height := 30;
  CancelBtn.Left := DLG_W - 220; CancelBtn.Top := 11;
  CancelBtn.Cancel := True;
  CancelBtn.ModalResult := mrCancel;

  OkBtn := TButton.Create(NavPanel);
  OkBtn.Parent := NavPanel;
  OkBtn.Caption := 'Importieren';
  OkBtn.Width := 110; OkBtn.Height := 30;
  OkBtn.Left := DLG_W - 112; OkBtn.Top := 11;
  OkBtn.Default := True;
  OkBtn.OnClick := @OKClick;

  // Initiales Scannen wenn Ordner bereits vorgegeben
  if ADefaultFolder <> '' then
    ScanFolder;
end;

{ ─── Ergebnis auslesen ───────────────────────────────────────────────────── }

function TImportProjectDialog.Execute: TImportResult;
var
  I: Integer;
  RawEntry, FilePart: string;
  BracketPos: Integer;
begin
  Result.Confirmed    := False;
  Result.SelectedFiles := TStringList.Create;

  if ShowModal <> mrOK then
    Exit;

  Result.Confirmed  := True;
  Result.FolderPath := Trim(FFolderEdit.Text);
  Result.Title      := Trim(FTitleEdit.Text);
  Result.Author     := Trim(FAuthorEdit.Text);

  for I := 0 to FFileList.Count - 1 do
  begin
    if not FFileList.Checked[I] then
      Continue;
    // Eintrag hat Format "Kapitelname   [relativerPfad]"
    RawEntry := FFileList.Items[I];
    BracketPos := LastDelimiter('[', RawEntry);
    if BracketPos > 0 then
    begin
      FilePart := Copy(RawEntry, BracketPos + 1, MaxInt);
      FilePart := StringReplace(FilePart, ']', '', [rfReplaceAll]);
      FilePart := Trim(FilePart);
    end
    else
      FilePart := RawEntry;
    Result.SelectedFiles.Add(FilePart);
  end;
end;

{ ─── Convenience ─────────────────────────────────────────────────────────── }

function ShowImportDialog(AOwner: TComponent;
  const ADefaultFolder: string): TImportResult;
var
  Dlg: TImportProjectDialog;
begin
  Dlg := TImportProjectDialog.CreateDialog(AOwner, ADefaultFolder);
  try
    Result := Dlg.Execute;
  finally
    Dlg.Free;
    if not Result.Confirmed then
      FreeAndNil(Result.SelectedFiles);
  end;
end;

end.
