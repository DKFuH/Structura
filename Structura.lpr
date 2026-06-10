program Structura;

{$mode objfpc}{$H+}
{$IFDEF WINDOWS}
{$APPTYPE GUI}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  SysUtils,
  MainFormUnit in 'MainFormUnit.pas';

{$R structura_icon.res}

begin
  Application.Title := 'Structura';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
