unit SearchDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

{ Globale Projektsuche als eigenständiges Modal. Der Aufrufer (MainForm)
  stellt den Suchkorpus zusammen (Titel, Notizen, Aufgaben, DOCX-Text),
  damit Datei-/Projektlogik dort bleibt. Rückgabe: Index des Kapitels, zu
  dem gesprungen werden soll, oder -1. }

interface

type
  TSearchDoc = record
    ItemIndex: Integer;   // Index in TStructuraProject
    Number:    string;    // formatierte Kapitelnummer, leer für Trenner
    Title:     string;
    IsDivider: Boolean;
    Notes:     string;
    Tasks:     string;    // offene/erledigte Aufgabenzeilen, zusammengefügt
    BodyText:  string;    // extrahierter DOCX-Text (kann leer sein)
  end;
  TSearchDocs = array of TSearchDoc;

function ShowSearchDialog(const ADocs: TSearchDocs): Integer;

implementation

uses
  Classes, SysUtils, StrUtils, Forms, Controls, StdCtrls, ComCtrls, Graphics,
  LCLType;

type
  TSearchForm = class(TForm)
  private
    FDocs: TSearchDocs;
    FEdit: TEdit;
    FScopeTitle, FScopeNotes, FScopeTasks, FScopeText: TCheckBox;
    FList: TListView;
    FCountLabel: TLabel;
    procedure DoSearch(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListDblClick(Sender: TObject);
    procedure AddHit(const ADoc: TSearchDoc; const AArea, AField, ATerm: string);
  public
    constructor CreateDialog(const ADocs: TSearchDocs);
  end;

// Kurzen Auszug rund um den Treffer bilden, Whitespace geglättet.
function Snippet(const AField, ATerm: string): string;
const
  Pad = 30;
var
  P, StartPos, Len: Integer;
  S: string;
begin
  P := Pos(LowerCase(ATerm), LowerCase(AField));
  if P = 0 then
    Exit('');
  StartPos := P - Pad;
  if StartPos < 1 then
    StartPos := 1;
  Len := Length(ATerm) + 2 * Pad;
  S := Copy(AField, StartPos, Len);
  S := StringReplace(S, LineEnding, ' ', [rfReplaceAll]);
  S := StringReplace(S, #9, ' ', [rfReplaceAll]);
  while Pos('  ', S) > 0 do
    S := StringReplace(S, '  ', ' ', [rfReplaceAll]);
  S := Trim(S);
  if StartPos > 1 then
    S := '… ' + S;
  if StartPos + Len <= Length(AField) then
    S := S + ' …';
  Result := S;
end;

constructor TSearchForm.CreateDialog(const ADocs: TSearchDocs);

  function MakeScope(ALeft: Integer; const ACaption: string): TCheckBox;
  begin
    Result := TCheckBox.Create(Self);
    Result.Parent := Self;
    Result.SetBounds(ALeft, 44, 130, 22);
    Result.Caption := ACaption;
    Result.Checked := True;
    Result.OnClick := @DoSearch;
  end;

var
  Lbl: TLabel;
  CloseButton: TButton;
begin
  inherited CreateNew(nil);
  FDocs := ADocs;

  Caption := 'Projektsuche';
  Position := poScreenCenter;
  ClientWidth := 820;
  ClientHeight := 540;
  Constraints.MinWidth := 560;
  Constraints.MinHeight := 360;
  KeyPreview := True;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.SetBounds(16, 14, 80, 18);
  Lbl.Caption := 'Suchbegriff:';

  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetBounds(100, 12, 704, 24);
  FEdit.Anchors := [akTop, akLeft, akRight];
  FEdit.OnChange := @DoSearch;
  FEdit.OnKeyDown := @EditKeyDown;

  FScopeTitle := MakeScope(16, 'Titel/Teile');
  FScopeNotes := MakeScope(150, 'Notizen');
  FScopeTasks := MakeScope(284, 'Aufgaben');
  FScopeText  := MakeScope(418, 'Kapiteltext');

  FCountLabel := TLabel.Create(Self);
  FCountLabel.Parent := Self;
  FCountLabel.SetBounds(560, 46, 244, 18);
  FCountLabel.Anchors := [akTop, akRight];
  FCountLabel.Alignment := taRightJustify;
  FCountLabel.Font.Color := clGrayText;

  FList := TListView.Create(Self);
  FList.Parent := Self;
  FList.SetBounds(16, 76, 788, 416);
  FList.Anchors := [akTop, akLeft, akRight, akBottom];
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.GridLines := True;
  FList.HideSelection := False;
  with FList.Columns.Add do begin Caption := 'Kapitel'; Width := 220; end;
  with FList.Columns.Add do begin Caption := 'Bereich'; Width := 110; end;
  with FList.Columns.Add do begin Caption := 'Treffer'; Width := 450; end;
  FList.OnDblClick := @ListDblClick;

  CloseButton := TButton.Create(Self);
  CloseButton.Parent := Self;
  CloseButton.Caption := 'Schließen';
  CloseButton.ModalResult := mrCancel;
  CloseButton.Cancel := True;
  CloseButton.Anchors := [akBottom, akRight];
  CloseButton.SetBounds(ClientWidth - 110, ClientHeight - 36, 94, 27);

  DoSearch(nil);
end;

procedure TSearchForm.AddHit(const ADoc: TSearchDoc;
  const AArea, AField, ATerm: string);
var
  Item: TListItem;
  CapText: string;
begin
  if Trim(AField) = '' then
    Exit;
  if Pos(LowerCase(ATerm), LowerCase(AField)) = 0 then
    Exit;
  Item := FList.Items.Add;
  Item.Data := Pointer(PtrInt(ADoc.ItemIndex));
  if ADoc.IsDivider then
    CapText := '— ' + ADoc.Title + ' —'
  else if ADoc.Number <> '' then
    CapText := ADoc.Number + '  ' + ADoc.Title
  else
    CapText := ADoc.Title;
  Item.Caption := CapText;
  Item.SubItems.Add(AArea);
  Item.SubItems.Add(Snippet(AField, ATerm));
end;

procedure TSearchForm.DoSearch(Sender: TObject);
var
  Term: string;
  I: Integer;
begin
  if not Assigned(FList) then
    Exit;
  Term := Trim(FEdit.Text);
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    if Term = '' then
    begin
      FCountLabel.Caption := '';
      Exit;
    end;
    for I := 0 to High(FDocs) do
    begin
      if FScopeTitle.Checked then
        AddHit(FDocs[I], 'Titel', FDocs[I].Title, Term);
      if FScopeNotes.Checked and not FDocs[I].IsDivider then
        AddHit(FDocs[I], 'Notizen', FDocs[I].Notes, Term);
      if FScopeTasks.Checked and not FDocs[I].IsDivider then
        AddHit(FDocs[I], 'Aufgaben', FDocs[I].Tasks, Term);
      if FScopeText.Checked and not FDocs[I].IsDivider then
        AddHit(FDocs[I], 'Kapiteltext', FDocs[I].BodyText, Term);
    end;
  finally
    FList.Items.EndUpdate;
  end;
  if FList.Items.Count = 0 then
    FCountLabel.Caption := 'Keine Treffer'
  else
    FCountLabel.Caption := Format('%d Treffer', [FList.Items.Count]);
  if FList.Items.Count > 0 then
    FList.ItemIndex := 0;
end;

procedure TSearchForm.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Enter springt zum ersten/markierten Treffer
  if (Key = VK_RETURN) and Assigned(FList.Selected) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TSearchForm.ListDblClick(Sender: TObject);
begin
  if Assigned(FList.Selected) then
    ModalResult := mrOk;
end;

function ShowSearchDialog(const ADocs: TSearchDocs): Integer;
var
  Dlg: TSearchForm;
begin
  Result := -1;
  Dlg := TSearchForm.CreateDialog(ADocs);
  try
    if (Dlg.ShowModal = mrOk) and Assigned(Dlg.FList.Selected) then
      Result := PtrInt(Dlg.FList.Selected.Data);
  finally
    Dlg.Free;
  end;
end;

end.
