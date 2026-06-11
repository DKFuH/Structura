unit ExportDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  StructuraTypes, DocumentWorkflow;

// Fragt Kapitelauswahl und Export-Optionen ab. Liefert False bei Abbruch.
// ANumberDigits ist die aktuelle Nummerierungseinstellung des Projekts.
function ShowExportDialog(AProject: TStructuraProject; ANumberDigits: Integer;
  out AOptions: TExportOptions): Boolean;

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, CheckLst, Graphics;

function ShowExportDialog(AProject: TStructuraProject; ANumberDigits: Integer;
  out AOptions: TExportOptions): Boolean;
var
  Dialog: TForm;
  ChapterList: TCheckListBox;
  TitlePageCheck, NumberCheck, DividerCheck, ReviewCheck: TCheckBox;
  OkButton, CancelButton: TButton;
  ListLabel, OptionsLabel, ModeLabel: TLabel;
  ModeCombo: TComboBox;
  I, Sequence: Integer;
  Item: TStructuraItem;
begin
  Result := False;
  AOptions := TDocumentWorkflow.DefaultExportOptions;
  AOptions.NumberDigits := ANumberDigits;

  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := 'Manuskript exportieren';
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poScreenCenter;
    Dialog.ClientWidth := 560;
    Dialog.ClientHeight := 560;

    ListLabel := TLabel.Create(Dialog);
    ListLabel.Parent := Dialog;
    ListLabel.Left := 16;
    ListLabel.Top := 12;
    ListLabel.Caption := 'Kapitel für den Export auswählen:';
    ListLabel.Font.Style := [fsBold];

    ChapterList := TCheckListBox.Create(Dialog);
    ChapterList.Parent := Dialog;
    ChapterList.SetBounds(16, 36, 528, 240);

    Sequence := 0;
    for I := 0 to AProject.Count - 1 do
    begin
      Item := AProject[I];
      if Item.ItemType = sitDivider then
      begin
        ChapterList.Items.AddObject('— ' + Item.Title + ' —', TObject(PtrInt(I)));
        ChapterList.Checked[ChapterList.Count - 1] := False;
        ChapterList.ItemEnabled[ChapterList.Count - 1] := False;
        Continue;
      end;
      Inc(Sequence);
      ChapterList.Items.AddObject(
        Format('%.*d  %s', [ANumberDigits, Sequence, Item.Title]),
        TObject(PtrInt(I)));
      ChapterList.Checked[ChapterList.Count - 1] := True;
    end;

    OptionsLabel := TLabel.Create(Dialog);
    OptionsLabel.Parent := Dialog;
    OptionsLabel.Left := 16;
    OptionsLabel.Top := 290;
    OptionsLabel.Caption := 'Optionen:';
    OptionsLabel.Font.Style := [fsBold];

    TitlePageCheck := TCheckBox.Create(Dialog);
    TitlePageCheck.Parent := Dialog;
    TitlePageCheck.SetBounds(16, 314, 520, 22);
    TitlePageCheck.Caption := 'Titelseite (Titel, Untertitel, Autor)';
    TitlePageCheck.Checked := True;

    NumberCheck := TCheckBox.Create(Dialog);
    NumberCheck.Parent := Dialog;
    NumberCheck.SetBounds(16, 340, 520, 22);
    NumberCheck.Caption := 'Kapitelnummern in Überschriften';
    NumberCheck.Checked := True;

    DividerCheck := TCheckBox.Create(Dialog);
    DividerCheck.Parent := Dialog;
    DividerCheck.SetBounds(16, 366, 520, 22);
    DividerCheck.Caption := 'Trenner als Teil-Überschriften übernehmen';
    DividerCheck.Checked := True;

    ReviewCheck := TCheckBox.Create(Dialog);
    ReviewCheck.Parent := Dialog;
    ReviewCheck.SetBounds(16, 392, 520, 22);
    ReviewCheck.Caption := 'Prüfexport: zusätzlich eine Textdatei pro Kapitel (export\review\)';
    ReviewCheck.Checked := False;

    ModeLabel := TLabel.Create(Dialog);
    ModeLabel.Parent := Dialog;
    ModeLabel.SetBounds(16, 428, 520, 15);
    ModeLabel.Caption := 'Kapitelinhalt im DOCX:';
    ModeLabel.Font.Style := [fsBold];

    ModeCombo := TComboBox.Create(Dialog);
    ModeCombo.Parent := Dialog;
    ModeCombo.SetBounds(16, 448, 528, 26);
    ModeCombo.Style := csDropDownList;
    ModeCombo.Items.Add('Volle Formatierung – Originalkapitel einbetten (für Word)');
    ModeCombo.Items.Add('Formatierung universell – zusammenführen (Word & LibreOffice)');
    ModeCombo.Items.Add('Nur Text – ohne Formatierung (überall)');
    ModeCombo.ItemIndex := 0;

    // Buttons direkt aufs Dialog, an Unterkante/rechts verankert — kein
    // Zwischen-Panel, dessen Breite zum Setzzeitpunkt noch nicht steht.
    OkButton := TButton.Create(Dialog);
    OkButton.Parent := Dialog;
    OkButton.Caption := 'Exportieren';
    OkButton.ModalResult := mrOk;
    OkButton.Default := True;
    OkButton.Anchors := [akBottom, akRight];
    OkButton.SetBounds(Dialog.ClientWidth - 230, Dialog.ClientHeight - 38, 110, 27);

    CancelButton := TButton.Create(Dialog);
    CancelButton.Parent := Dialog;
    CancelButton.Caption := 'Abbrechen';
    CancelButton.ModalResult := mrCancel;
    CancelButton.Cancel := True;
    CancelButton.Anchors := [akBottom, akRight];
    CancelButton.SetBounds(Dialog.ClientWidth - 110, Dialog.ClientHeight - 38, 94, 27);

    if Dialog.ShowModal <> mrOk then
      Exit(False);

    AOptions.IncludeTitlePage := TitlePageCheck.Checked;
    AOptions.NumberChapters := NumberCheck.Checked;
    AOptions.IncludeDividers := DividerCheck.Checked;
    AOptions.ReviewExport := ReviewCheck.Checked;
    case ModeCombo.ItemIndex of
      1: AOptions.ContentMode := cmUniversal;
      2: AOptions.ContentMode := cmText;
    else
      AOptions.ContentMode := cmFidelity;
    end;
    SetLength(AOptions.SelectedItems, AProject.Count);
    for I := 0 to High(AOptions.SelectedItems) do
      AOptions.SelectedItems[I] := False;
    for I := 0 to ChapterList.Count - 1 do
      if ChapterList.Checked[I] then
        AOptions.SelectedItems[PtrInt(ChapterList.Items.Objects[I])] := True;
    Result := True;
  finally
    Dialog.Free;
  end;
end;

end.
