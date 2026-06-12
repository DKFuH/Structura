unit AboutDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

const
  STRUCTURA_VERSION = '0.8.1';

procedure ShowAboutDialog;

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Graphics, LCLIntf,
  StructuraTypes;

type
  TLinkLabelHelper = class
  public
    class procedure LinkClick(Sender: TObject);
  end;

class procedure TLinkLabelHelper.LinkClick(Sender: TObject);
begin
  if Sender is TLabel then
    OpenURL(TLabel(Sender).Hint);
end;

procedure ShowAboutDialog;
var
  Dialog: TForm;
  Scroll: TScrollBox;
  TextLeft, Y: Integer;

  function AddText(const ACaption: string; ABold: Boolean = False;
    AGray: Boolean = False): TLabel;
  begin
    Result := TLabel.Create(Dialog);
    Result.Parent := Scroll;
    Result.Left := TextLeft;
    Result.Top := Y;
    Result.Caption := ACaption;
    if ABold then
      Result.Font.Style := [fsBold];
    if AGray then
      Result.Font.Color := clGrayText;
    Inc(Y, 22);
  end;

  function AddLink(const ACaption, AUrl: string): TLabel;
  begin
    Result := AddText(ACaption);
    Result.Hint := AUrl;
    Result.Cursor := crHandPoint;
    Result.Font.Color := TColor($00B05A1E);
    Result.OnClick := @TLinkLabelHelper.LinkClick;
  end;

var
  OwlImage: TImage;
  OwlPath: string;
  CloseButton: TButton;
  ButtonPanel: TPanel;
begin
  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := 'Über Structura';
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poScreenCenter;
    Dialog.ClientWidth := 580;
    Dialog.ClientHeight := 400;

    ButtonPanel := TPanel.Create(Dialog);
    ButtonPanel.Parent := Dialog;
    ButtonPanel.Align := alBottom;
    ButtonPanel.Height := 44;
    ButtonPanel.BevelOuter := bvNone;

    CloseButton := TButton.Create(Dialog);
    CloseButton.Parent := ButtonPanel;
    CloseButton.Caption := 'Schließen';
    CloseButton.ModalResult := mrOk;
    CloseButton.Anchors := [akTop, akRight];
    CloseButton.SetBounds(ButtonPanel.ClientWidth - 110, 8, 86, 27);

    // Klassische ScrollBox: wächst der Inhalt, erscheint ein Scrollbalken
    Scroll := TScrollBox.Create(Dialog);
    Scroll.Parent := Dialog;
    Scroll.Align := alClient;
    Scroll.BorderStyle := bsNone;
    Scroll.Color := clWindow;
    Scroll.ParentBackground := False;
    Scroll.ParentColor := False;

    TextLeft := 24;
    OwlPath := AssetPath('assets\owl.png');
    if FileExists(OwlPath) then
    begin
      OwlImage := TImage.Create(Dialog);
      OwlImage.Parent := Scroll;
      OwlImage.SetBounds(24, 24, 150, 100);
      OwlImage.Proportional := True;
      OwlImage.Stretch := True;
      try
        OwlImage.Picture.LoadFromFile(OwlPath);
        TextLeft := 200;
      except
        OwlImage.Free;
      end;
    end;

    Y := 24;
    with AddText('Structura', True) do
      Font.Height := -21;
    Inc(Y, 6);
    AddText('Version ' + STRUCTURA_VERSION, False, True);
    Inc(Y, 12);
    AddText('Macht große Buchprojekte überschaubar — Kapitel, Status,');
    AddText('Notizen und Fortschritt, ohne die Dateien aus der Hand zu geben.');
    Inc(Y, 16);
    AddText('Lizenz', True);
    AddText('MIT-Lizenz · Copyright © 2025 Daniel Klas');
    AddLink('github.com/DKFuH/Structura', 'https://github.com/DKFuH/Structura');
    Inc(Y, 16);
    AddText('Icons', True);
    AddText('Button-Icons: Streamline Ultimate Color, Lizenz CC BY 4.0');
    AddLink('streamlinehq.com', 'https://www.streamlinehq.com/');
    AddLink('Lizenztext: creativecommons.org/licenses/by/4.0',
      'https://creativecommons.org/licenses/by/4.0/');

    Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

end.
