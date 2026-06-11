unit ReviewDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

// Zeigt die Review-Tabelle. Liefert den Index des Kapitels, zu dem der
// Nutzer springen will, oder -1 wenn der Dialog nur geschlossen wurde.
// Wortzahl und offene Aufgaben werden vom Aufrufer geliefert, damit die
// Datei-Logik (DOCX-Vorschau, Notizpfade) im MainForm bleibt.
type
  TReviewRow = record
    ItemIndex: Integer;     // Index in TStructuraProject
    Number: string;         // formatierte Kapitelnummer, leer für Trenner
    Title: string;
    Status: string;
    WordCount: Integer;     // -1 für Trenner
    HasNotes: Boolean;
    OpenTasks: Integer;
  end;
  TReviewRows = array of TReviewRow;

function ShowReviewDialog(const ARows: TReviewRows): Integer;

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Graphics;

type
  TReviewDialogHelper = class
  public
    class procedure ListDblClick(Sender: TObject);
  end;

class procedure TReviewDialogHelper.ListDblClick(Sender: TObject);
var
  ParentForm: TCustomForm;
begin
  ParentForm := GetParentForm(TControl(Sender));
  if Assigned(ParentForm) then
    ParentForm.ModalResult := mrOk;
end;

function ShowReviewDialog(const ARows: TReviewRows): Integer;
var
  Dialog: TForm;
  ListView: TListView;
  ButtonPanel: TPanel;
  CloseButton, JumpButton: TButton;
  HintLabel: TLabel;
  I: Integer;
  Item: TListItem;
begin
  Result := -1;
  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := 'Review-Ansicht';
    Dialog.Position := poScreenCenter;
    Dialog.ClientWidth := 860;
    Dialog.ClientHeight := 520;
    Dialog.Constraints.MinWidth := 640;
    Dialog.Constraints.MinHeight := 360;

    ButtonPanel := TPanel.Create(Dialog);
    ButtonPanel.Parent := Dialog;
    ButtonPanel.Align := alBottom;
    ButtonPanel.Height := 44;
    ButtonPanel.BevelOuter := bvNone;

    HintLabel := TLabel.Create(Dialog);
    HintLabel.Parent := ButtonPanel;
    HintLabel.Left := 12;
    HintLabel.Top := 14;
    HintLabel.Caption := 'Doppelklick springt zum Kapitel.';
    HintLabel.Font.Color := clGrayText;

    JumpButton := TButton.Create(Dialog);
    JumpButton.Parent := ButtonPanel;
    JumpButton.Caption := 'Zum Kapitel';
    JumpButton.ModalResult := mrOk;
    JumpButton.Default := True;
    JumpButton.Anchors := [akTop, akRight];
    JumpButton.SetBounds(Dialog.ClientWidth - 230, 8, 110, 27);

    CloseButton := TButton.Create(Dialog);
    CloseButton.Parent := ButtonPanel;
    CloseButton.Caption := 'Schließen';
    CloseButton.ModalResult := mrCancel;
    CloseButton.Cancel := True;
    CloseButton.Anchors := [akTop, akRight];
    CloseButton.SetBounds(Dialog.ClientWidth - 110, 8, 86, 27);

    ListView := TListView.Create(Dialog);
    ListView.Parent := Dialog;
    ListView.Align := alClient;
    ListView.ViewStyle := vsReport;
    ListView.ReadOnly := True;
    ListView.RowSelect := True;
    ListView.GridLines := True;
    ListView.HideSelection := False;

    with ListView.Columns.Add do begin Caption := 'Nr.';            Width := 60;  end;
    with ListView.Columns.Add do begin Caption := 'Kapitel';        Width := 330; end;
    with ListView.Columns.Add do begin Caption := 'Status';         Width := 150; end;
    with ListView.Columns.Add do begin Caption := 'Wörter';         Width := 90;  Alignment := taRightJustify; end;
    with ListView.Columns.Add do begin Caption := 'Notizen';        Width := 80;  end;
    with ListView.Columns.Add do begin Caption := 'Offene Aufgaben'; Width := 120; Alignment := taRightJustify; end;

    for I := 0 to High(ARows) do
    begin
      Item := ListView.Items.Add;
      Item.Data := Pointer(PtrInt(ARows[I].ItemIndex));
      if ARows[I].WordCount < 0 then
      begin
        // Trenner: nur als Gliederungszeile zeigen
        Item.Caption := '';
        Item.SubItems.Add('— ' + ARows[I].Title + ' —');
        Item.SubItems.Add('');
        Item.SubItems.Add('');
        Item.SubItems.Add('');
        Item.SubItems.Add('');
        Continue;
      end;
      Item.Caption := ARows[I].Number;
      Item.SubItems.Add(ARows[I].Title);
      Item.SubItems.Add(ARows[I].Status);
      Item.SubItems.Add(IntToStr(ARows[I].WordCount));
      if ARows[I].HasNotes then
        Item.SubItems.Add('ja')
      else
        Item.SubItems.Add('—');
      if ARows[I].OpenTasks > 0 then
        Item.SubItems.Add(IntToStr(ARows[I].OpenTasks))
      else
        Item.SubItems.Add('—');
    end;

    if ListView.Items.Count > 0 then
      ListView.ItemIndex := 0;

    // Doppelklick = Sprung: gleiche Wirkung wie der Zum-Kapitel-Button
    ListView.OnDblClick := @TReviewDialogHelper.ListDblClick;

    if (Dialog.ShowModal = mrOk) and Assigned(ListView.Selected) then
      Result := PtrInt(ListView.Selected.Data);
  finally
    Dialog.Free;
  end;
end;

end.
