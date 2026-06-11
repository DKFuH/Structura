unit AboutDialogUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

const
  STRUCTURA_VERSION = '0.2.0-dev';

procedure ShowAboutDialog;

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Graphics, LCLIntf;

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
  Y: Integer;

  function AddText(const ACaption: string; ABold: Boolean = False;
    AGray: Boolean = False): TLabel;
  begin
    Result := TLabel.Create(Dialog);
    Result.Parent := Dialog;
    Result.Left := 24;
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
  I: Integer;
begin
  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := 'Über Structura';
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poScreenCenter;
    Dialog.ClientWidth := 520;

    // Eule links, Text rechts daneben
    OwlPath := ExpandFileName('assets\owl.png');
    if FileExists(OwlPath) then
    begin
      OwlImage := TImage.Create(Dialog);
      OwlImage.Parent := Dialog;
      OwlImage.SetBounds(24, 24, 150, 100);
      OwlImage.Proportional := True;
      OwlImage.Stretch := True;
      try
        OwlImage.Picture.LoadFromFile(OwlPath);
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
    Inc(Y, 20);

    // Textspalte beginnt rechts neben der Eule
    if FileExists(OwlPath) then
      for I := 0 to Dialog.ControlCount - 1 do
        if Dialog.Controls[I] is TLabel then
          Dialog.Controls[I].Left := 200;

    CloseButton := TButton.Create(Dialog);
    CloseButton.Parent := Dialog;
    CloseButton.Caption := 'Schließen';
    CloseButton.ModalResult := mrOk;
    CloseButton.SetBounds(Dialog.ClientWidth - 110, Y, 86, 27);
    Dialog.ClientHeight := Y + 42;
    Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

end.
