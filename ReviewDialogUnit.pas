unit ReviewDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

// Zeigt die Review-Tabelle mit Filtern. Liefert den Index des Kapitels, zu
// dem der Nutzer springen will, oder -1 wenn nur geschlossen wurde.
// Wortzahl, offene Aufgaben und Dateialter werden vom Aufrufer geliefert,
// damit die Datei-Logik im MainForm bleibt.
type
  TReviewRow = record
    ItemIndex: Integer;     // Index in TStructuraProject
    Number: string;         // formatierte Kapitelnummer, leer für Trenner
    Title: string;
    Status: string;
    WordCount: Integer;     // -1 für Trenner
    HasNotes: Boolean;
    OpenTasks: Integer;
    StaleDays: Integer;     // Tage seit letzter Änderung, -1 unbekannt/Trenner
  end;
  TReviewRows = array of TReviewRow;

function ShowReviewDialog(const ARows: TReviewRows): Integer;

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Graphics;

const
  StaleThreshold = 30;

type
  TReviewForm = class(TForm)
  private
    FRows: TReviewRows;
    FList: TListView;
    FFilter: TComboBox;
    FCountLabel: TLabel;
    procedure ApplyFilter(Sender: TObject);
    procedure ListDblClick(Sender: TObject);
    function RowMatches(const ARow: TReviewRow): Boolean;
  public
    constructor CreateDialog(const ARows: TReviewRows);
  end;

function TReviewForm.RowMatches(const ARow: TReviewRow): Boolean;
begin
  // Trenner nur im Filter „Alle" zeigen
  if ARow.WordCount < 0 then
  begin
    Result := FFilter.ItemIndex = 0;
    Exit;
  end;
  case FFilter.ItemIndex of
    1: Result := SameText(ARow.Status, 'Problem');
    2: Result := ARow.OpenTasks > 0;
    3: Result := not SameText(ARow.Status, 'Final');
    4: Result := (ARow.StaleDays >= 0) and (ARow.StaleDays > StaleThreshold);
  else
    Result := True; // Alle
  end;
end;

procedure TReviewForm.ApplyFilter(Sender: TObject);
var
  I: Integer;
  Item: TListItem;
begin
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to High(FRows) do
    begin
      if not RowMatches(FRows[I]) then
        Continue;
      Item := FList.Items.Add;
      Item.Data := Pointer(PtrInt(FRows[I].ItemIndex));
      if FRows[I].WordCount < 0 then
      begin
        Item.Caption := '';
        Item.SubItems.Add('— ' + FRows[I].Title + ' —');
        Item.SubItems.Add(''); Item.SubItems.Add('');
        Item.SubItems.Add(''); Item.SubItems.Add('');
        Continue;
      end;
      Item.Caption := FRows[I].Number;
      Item.SubItems.Add(FRows[I].Title);
      Item.SubItems.Add(FRows[I].Status);
      Item.SubItems.Add(IntToStr(FRows[I].WordCount));
      if FRows[I].OpenTasks > 0 then
        Item.SubItems.Add(IntToStr(FRows[I].OpenTasks))
      else
        Item.SubItems.Add('—');
      if FRows[I].StaleDays >= 0 then
        Item.SubItems.Add(IntToStr(FRows[I].StaleDays) + ' T')
      else
        Item.SubItems.Add('—');
    end;
  finally
    FList.Items.EndUpdate;
  end;
  if FList.Items.Count > 0 then
    FList.ItemIndex := 0;
  FCountLabel.Caption := Format('%d Kapitel', [FList.Items.Count]);
end;

procedure TReviewForm.ListDblClick(Sender: TObject);
begin
  if Assigned(FList.Selected) then
    ModalResult := mrOk;
end;

constructor TReviewForm.CreateDialog(const ARows: TReviewRows);
var
  Lbl: TLabel;
  CloseButton, JumpButton: TButton;
begin
  inherited CreateNew(nil);
  FRows := ARows;

  Caption := 'Review-Ansicht';
  Position := poScreenCenter;
  ClientWidth := 880;
  ClientHeight := 540;
  Constraints.MinWidth := 640;
  Constraints.MinHeight := 360;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.SetBounds(16, 16, 40, 18);
  Lbl.Caption := 'Filter:';

  FFilter := TComboBox.Create(Self);
  FFilter.Parent := Self;
  FFilter.SetBounds(60, 12, 240, 26);
  FFilter.Style := csDropDownList;
  FFilter.Items.Add('Alle');
  FFilter.Items.Add('Problemkapitel');
  FFilter.Items.Add('Offene Aufgaben');
  FFilter.Items.Add('Nicht final');
  FFilter.Items.Add('Lange nicht bearbeitet (30+ Tage)');
  FFilter.ItemIndex := 0;
  FFilter.OnChange := @ApplyFilter;

  FCountLabel := TLabel.Create(Self);
  FCountLabel.Parent := Self;
  FCountLabel.SetBounds(ClientWidth - 180, 16, 164, 18);
  FCountLabel.Anchors := [akTop, akRight];
  FCountLabel.Alignment := taRightJustify;
  FCountLabel.Font.Color := clGrayText;

  FList := TListView.Create(Self);
  FList.Parent := Self;
  FList.SetBounds(16, 48, 848, 444);
  FList.Anchors := [akTop, akLeft, akRight, akBottom];
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.GridLines := True;
  FList.HideSelection := False;
  with FList.Columns.Add do begin Caption := 'Nr.';     Width := 56;  end;
  with FList.Columns.Add do begin Caption := 'Kapitel'; Width := 340; end;
  with FList.Columns.Add do begin Caption := 'Status';  Width := 150; end;
  with FList.Columns.Add do begin Caption := 'Wörter';  Width := 80;  Alignment := taRightJustify; end;
  with FList.Columns.Add do begin Caption := 'Aufgaben'; Width := 90; Alignment := taRightJustify; end;
  with FList.Columns.Add do begin Caption := 'Geändert'; Width := 90; Alignment := taRightJustify; end;
  FList.OnDblClick := @ListDblClick;

  JumpButton := TButton.Create(Self);
  JumpButton.Parent := Self;
  JumpButton.Caption := 'Zum Kapitel';
  JumpButton.ModalResult := mrOk;
  JumpButton.Default := True;
  JumpButton.Anchors := [akBottom, akRight];
  JumpButton.SetBounds(ClientWidth - 230, ClientHeight - 36, 110, 27);

  CloseButton := TButton.Create(Self);
  CloseButton.Parent := Self;
  CloseButton.Caption := 'Schließen';
  CloseButton.ModalResult := mrCancel;
  CloseButton.Cancel := True;
  CloseButton.Anchors := [akBottom, akRight];
  CloseButton.SetBounds(ClientWidth - 110, ClientHeight - 36, 94, 27);

  ApplyFilter(nil);
end;

function ShowReviewDialog(const ARows: TReviewRows): Integer;
var
  Dlg: TReviewForm;
begin
  Result := -1;
  Dlg := TReviewForm.CreateDialog(ARows);
  try
    if (Dlg.ShowModal = mrOk) and Assigned(Dlg.FList.Selected) then
      Result := PtrInt(Dlg.FList.Selected.Data);
  finally
    Dlg.Free;
  end;
end;

end.
