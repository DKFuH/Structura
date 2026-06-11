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
  // Eine Importzeile ist entweder ein Kapitel (Datei) oder ein Teil (Trenner).
  TImportEntryKind = (iekChapter, iekDivider);

  TImportEntry = record
    Kind:  TImportEntryKind;
    Data:  string;   // Kapitel: relativer Pfad · Trenner: Titel
  end;

  { TImportResult enthält alles was der Aufrufer nach OK braucht }
  TImportResult = record
    Confirmed:    Boolean;
    FolderPath:   string;
    Title:        string;
    Author:       string;
    SelectedFiles: TStringList;  // relative Pfade; Aufrufer muss freigeben
    Entries:      array of TImportEntry; // geordnete Liste Kapitel/Trenner
  end;

  TImportProjectDialog = class(TForm)
  private
    FFolderEdit:    TEdit;
    FTitleEdit:     TEdit;
    FAuthorEdit:    TEdit;
    FFileList:      TCheckListBox;
    FStatusLabel:   TLabel;
    FRowKind:       array of TImportEntryKind;
    FRowData:       array of string;

    procedure BrowseClick(Sender: TObject);
    procedure FolderEditExit(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure SelectNoneClick(Sender: TObject);
    procedure MoveUpClick(Sender: TObject);
    procedure MoveDownClick(Sender: TObject);
    procedure OKClick(Sender: TObject);

    procedure ScanFolder;
    procedure AddRow(AKind: TImportEntryKind; const AData, ADisplay: string;
      AChecked: Boolean);
    procedure SwapRows(A, B: Integer);
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

// Rekursiv DOCX sammeln (relative Pfade), Structura-eigene Ordner auslassen.
// Begrenzte Tiefe (Schutz vor Junction-Schleifen), überspringt bestehende
// Structura-Projekte (Ordner mit structura.json) und Symlink-Ordner.
procedure CollectDocxFiles(const ARoot, ARelDir: string; AInto: TStringList;
  ADepth: Integer = 0);
const
  MaxDepth = 6;
var
  SR: TSearchRec;
  AbsDir, Name, RelChild, ChildAbs: string;
begin
  if ADepth > MaxDepth then
    Exit;
  AbsDir := IncludeTrailingPathDelimiter(ARoot +
    StringReplace(ARelDir, '/', PathDelim, [rfReplaceAll]));
  if FindFirst(AbsDir + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        Name := SR.Name;
        if (Name = '.') or (Name = '..') then
          Continue;
        if ARelDir = '' then
          RelChild := Name
        else
          RelChild := ARelDir + PathDelim + Name;
        if (SR.Attr and faDirectory) <> 0 then
        begin
          // Eigene Verwaltungsordner nicht als Teile importieren
          if SameText(Name, 'backup') or SameText(Name, 'export') or
             SameText(Name, 'notes') then
            Continue;
          // Symlinks/Junctions nicht verfolgen (Endlosschleifen vermeiden)
          if (SR.Attr and faSymLink) <> 0 then
            Continue;
          // Bestehende Structura-Projekte nicht mit-importieren
          ChildAbs := IncludeTrailingPathDelimiter(AbsDir + Name);
          if FileExists(ChildAbs + 'structura.json') then
            Continue;
          CollectDocxFiles(ARoot, RelChild, AInto, ADepth + 1);
        end
        else if SameText(ExtractFileExt(Name), '.docx') and
                (Copy(Name, 1, 2) <> '~$') then
          AInto.Add(RelChild);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

procedure TImportProjectDialog.AddRow(AKind: TImportEntryKind;
  const AData, ADisplay: string; AChecked: Boolean);
var
  N: Integer;
begin
  N := FFileList.Items.Add(ADisplay);
  FFileList.Checked[N] := AChecked;
  SetLength(FRowKind, N + 1);
  SetLength(FRowData, N + 1);
  FRowKind[N] := AKind;
  FRowData[N] := AData;
end;

procedure TImportProjectDialog.SwapRows(A, B: Integer);
var
  TmpKind: TImportEntryKind;
  TmpData, TmpItem: string;
  TmpChecked: Boolean;
begin
  if (A < 0) or (B < 0) or (A >= FFileList.Count) or (B >= FFileList.Count) then
    Exit;
  TmpKind := FRowKind[A]; FRowKind[A] := FRowKind[B]; FRowKind[B] := TmpKind;
  TmpData := FRowData[A]; FRowData[A] := FRowData[B]; FRowData[B] := TmpData;
  TmpItem := FFileList.Items[A];
  FFileList.Items[A] := FFileList.Items[B];
  FFileList.Items[B] := TmpItem;
  TmpChecked := FFileList.Checked[A];
  FFileList.Checked[A] := FFileList.Checked[B];
  FFileList.Checked[B] := TmpChecked;
end;

// Letztes Pfadsegment eines relativen Verzeichnisses (für Teil-Titel)
function LastFolderSegment(const ARelDir: string): string;
var
  S: string;
  P: Integer;
begin
  S := ExcludeTrailingPathDelimiter(StringReplace(ARelDir, '/', PathDelim, [rfReplaceAll]));
  P := Length(S);
  while (P > 0) and (S[P] <> PathDelim) do
    Dec(P);
  Result := Copy(S, P + 1, MaxInt);
  if Result = '' then
    Result := ARelDir;
end;

procedure TImportProjectDialog.ScanFolder;
var
  Dir, Root, RelPath, RelDir, CurGroup, Display: string;
  Files: TStringList;
  I, ChapterCount: Integer;
  IsMainGroup: Boolean;
begin
  FFileList.Items.Clear;
  SetLength(FRowKind, 0);
  SetLength(FRowData, 0);
  Dir := Trim(FFolderEdit.Text);
  if (Dir = '') or not DirectoryExists(Dir) then
  begin
    FStatusLabel.Caption := 'Ordner nicht gefunden.';
    Exit;
  end;
  Root := IncludeTrailingPathDelimiter(Dir);

  Files := TStringList.Create;
  try
    // Rekursiv alle DOCX einsammeln, Structura-eigene Ordner überspringen
    CollectDocxFiles(Root, '', Files);
    // Nach vollständigem relativem Pfad sortieren → Gruppen bleiben zusammen,
    // Nummerierung innerhalb der Gruppe wird respektiert
    Files.Sort;

    CurGroup := #1; // unmöglicher Startwert
    ChapterCount := 0;
    for I := 0 to Files.Count - 1 do
    begin
      RelPath := Files[I];
      RelDir := ExtractFileDir(RelPath);
      // Wurzel und chapters/ gelten als Hauptgruppe ohne Teil-Trenner
      IsMainGroup := (RelDir = '') or SameText(RelDir, 'chapters');

      if not IsMainGroup and (RelDir <> CurGroup) then
        AddRow(iekDivider, LastFolderSegment(RelDir),
          '──  ' + LastFolderSegment(RelDir) + '  ──', True);
      if IsMainGroup then
        CurGroup := #1
      else
        CurGroup := RelDir;

      AddRow(iekChapter, RelPath,
        CleanChapterTitle(RelPath) + '   [' + RelPath + ']', True);
      Inc(ChapterCount);
    end;

    if ChapterCount = 0 then
      FStatusLabel.Caption := 'Keine DOCX-Dateien gefunden.'
    else
      FStatusLabel.Caption := Format(
        '%d DOCX-Datei(en) gefunden. Reihenfolge bei Bedarf mit ▲▼ anpassen.',
        [ChapterCount]);

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

procedure TImportProjectDialog.MoveUpClick(Sender: TObject);
var I: Integer;
begin
  I := FFileList.ItemIndex;
  if I <= 0 then
    Exit;
  SwapRows(I, I - 1);
  FFileList.ItemIndex := I - 1;
end;

procedure TImportProjectDialog.MoveDownClick(Sender: TObject);
var I: Integer;
begin
  I := FFileList.ItemIndex;
  if (I < 0) or (I >= FFileList.Count - 1) then
    Exit;
  SwapRows(I, I + 1);
  FFileList.ItemIndex := I + 1;
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
  AllBtn, NoneBtn, UpBtn, DownBtn: TButton;
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

  UpBtn := TButton.Create(Self);
  UpBtn.Parent := Self;
  UpBtn.Caption := '▲';
  UpBtn.Hint := 'Markierte Zeile nach oben';
  UpBtn.ShowHint := True;
  UpBtn.Left := DLG_W - MARGIN - 76; UpBtn.Top := Y;
  UpBtn.Width := 34; UpBtn.Height := 26;
  UpBtn.OnClick := @MoveUpClick;

  DownBtn := TButton.Create(Self);
  DownBtn.Parent := Self;
  DownBtn.Caption := '▼';
  DownBtn.Hint := 'Markierte Zeile nach unten';
  DownBtn.ShowHint := True;
  DownBtn.Left := DLG_W - MARGIN - 38; DownBtn.Top := Y;
  DownBtn.Width := 34; DownBtn.Height := 26;
  DownBtn.OnClick := @MoveDownClick;

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

  // Bewusst kein Auto-Scan beim Öffnen: der vorgegebene Ordner ist die
  // Projekt-Wurzel, kein Manuskriptordner. Der Nutzer wählt erst gezielt
  // den zu importierenden Ordner (Durchsuchen), dann wird gescannt.
  FStatusLabel.Caption :=
    'Ordner mit den DOCX-Kapiteln über „...“ auswählen.';
end;

{ ─── Ergebnis auslesen ───────────────────────────────────────────────────── }

function TImportProjectDialog.Execute: TImportResult;
var
  I, N: Integer;
begin
  Result.Confirmed    := False;
  Result.SelectedFiles := TStringList.Create;
  SetLength(Result.Entries, 0);

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
    N := Length(Result.Entries);
    SetLength(Result.Entries, N + 1);
    Result.Entries[N].Kind := FRowKind[I];
    Result.Entries[N].Data := FRowData[I];
    if FRowKind[I] = iekChapter then
      Result.SelectedFiles.Add(FRowData[I]);
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
