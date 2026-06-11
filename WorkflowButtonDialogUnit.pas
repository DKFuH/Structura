unit WorkflowButtonDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, ExtCtrls, AppSettings;

type
  TWorkflowButtonDialogForm = class(TForm)
    CancelButton: TButton;
    CopyModeCombo: TComboBox;
    CopyModeLabel: TLabel;
    HintEdit: TEdit;
    HintLabel: TLabel;
    MainPanel: TPanel;
    NameEdit: TEdit;
    NameLabel: TLabel;
    OkButton: TButton;
    PrefixLabel: TLabel;
    PrefixMemo: TMemo;
    SuffixLabel: TLabel;
    SuffixMemo: TMemo;
    TargetEdit: TEdit;
    TargetLabel: TLabel;
  private
    function ValidateInput: Boolean;
  public
    function Execute(AConfig: TWorkflowButtonConfig): Boolean;
  end;

function EditWorkflowButton(AConfig: TWorkflowButtonConfig): Boolean;

implementation

{$R *.lfm}

function CopyModeCaption(AMode: TWorkflowCopyMode): string;
begin
  case AMode of
    wcmTitleAndChapterText: Result := 'Kapiteltitel + Kapiteltext';
    wcmPromptPlusChapter: Result := 'Prefix/Suffix + Kapiteltext';
  else
    Result := 'Nur Kapiteltext';
  end;
end;

function TWorkflowButtonDialogForm.ValidateInput: Boolean;
begin
  Result := False;
  if Trim(NameEdit.Text) = '' then
  begin
    MessageDlg('Bitte einen Button-Namen eingeben.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if Trim(TargetEdit.Text) = '' then
  begin
    MessageDlg('Bitte ein Ziel als URL oder Programmpfad eingeben.', mtWarning, [mbOK], 0);
    Exit;
  end;
  Result := True;
end;

function TWorkflowButtonDialogForm.Execute(AConfig: TWorkflowButtonConfig): Boolean;
begin
  NameEdit.Text := AConfig.Name;
  TargetEdit.Text := AConfig.Target;
  HintEdit.Text := AConfig.Hint;
  PrefixMemo.Text := AConfig.Prefix;
  SuffixMemo.Text := AConfig.Suffix;
  CopyModeCombo.Items.Clear;
  CopyModeCombo.Items.Add(CopyModeCaption(wcmChapterText));
  CopyModeCombo.Items.Add(CopyModeCaption(wcmTitleAndChapterText));
  CopyModeCombo.Items.Add(CopyModeCaption(wcmPromptPlusChapter));
  CopyModeCombo.ItemIndex := Ord(AConfig.CopyMode);

  Result := ShowModal = mrOk;
  if not Result then
    Exit(False);
  if not ValidateInput then
    Exit(Execute(AConfig));

  AConfig.Name := Trim(NameEdit.Text);
  AConfig.Target := Trim(TargetEdit.Text);
  AConfig.Hint := Trim(HintEdit.Text);
  AConfig.Prefix := PrefixMemo.Text;
  AConfig.Suffix := SuffixMemo.Text;
  AConfig.CopyMode := TWorkflowCopyMode(CopyModeCombo.ItemIndex);
end;

function EditWorkflowButton(AConfig: TWorkflowButtonConfig): Boolean;
var
  Dialog: TWorkflowButtonDialogForm;
begin
  Dialog := TWorkflowButtonDialogForm.Create(nil);
  try
    Result := Dialog.Execute(AConfig);
  finally
    Dialog.Free;
  end;
end;

end.
