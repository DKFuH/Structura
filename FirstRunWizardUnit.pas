unit FirstRunWizardUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

{ First-Run-Wizard – wird beim ersten Start angezeigt (keine settings-Datei).
  Rein programmatisch gebaut, kein LFM erforderlich. }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, FileCtrl, AppSettings, OfficeDetection;

type
  TFirstRunWizard = class(TForm)
  private
    FSettings: TAppSettings;
    FTargets: TOfficeTargets;
    FCurrentStep: Integer;

    // Container-Panels je Schritt
    FPanels: array[0..2] of TPanel;

    // Schritt 1 – Projektordner
    FFolderEdit: TEdit;

    // Navigation
    FStepLabel: TLabel;
    FBackBtn: TButton;
    FNextBtn: TButton;
    FSkipBtn: TButton;

    procedure BuildStep0(AParent: TPanel);
    procedure BuildStep1(AParent: TPanel);
    procedure BuildStep2(AParent: TPanel);
    procedure BuildNavBar;
    procedure ShowStep(AStep: Integer);
    procedure UpdateNavButtons;
    procedure BrowseFolder(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure BackClick(Sender: TObject);
    procedure SkipClick(Sender: TObject);
    function OfficeStatusLine(const APath, AName: string): string;
  public
    constructor CreateWizard(AOwner: TComponent; ASettings: TAppSettings);
  end;

{ Startet den Wizard modal. Gibt True zurück wenn der Nutzer „Loslegen" geklickt
  hat; False wenn übersprungen. In beiden Fällen wurde ASettings ggf. befüllt. }
function RunFirstRunWizard(AOwner: TComponent; ASettings: TAppSettings): Boolean;

implementation

uses
  LCLIntf;

const
  STEP_WELCOME  = 0;
  STEP_FOLDER   = 1;
  STEP_DONE     = 2;

  COLOR_BG      = $00FAF8F5;   // warmes Off-White
  COLOR_ACCENT  = $006B3D1E;   // Braun
  COLOR_MUTED   = $00888888;

  WIZARD_W = 620;
  WIZARD_H = 460;

{ ─── Hilfs-Label-Fabrik ─────────────────────────────────────────────────── }

function MakeLabel(AParent: TWinControl; const AText: string;
  ALeft, ATop, AWidth: Integer; AFontSize: Integer = 10;
  ABold: Boolean = False; AColor: TColor = clWindowText): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Caption := AText;
  Result.WordWrap := True;
  Result.Font.Size := AFontSize;
  Result.Font.Bold := ABold;
  Result.Font.Color := AColor;
  Result.AutoSize := False;
  Result.Height := 200; // wird durch WordWrap gesteuert
end;

{ ─── Wizard-Schritte ────────────────────────────────────────────────────── }

procedure TFirstRunWizard.BuildStep0(AParent: TPanel);
begin
  MakeLabel(AParent, 'Structura', 40, 50, WIZARD_W - 80,
    28, True, COLOR_ACCENT);
  MakeLabel(AParent, 'Buchprojekte strukturiert verwalten.',
    40, 100, WIZARD_W - 80, 13, False, COLOR_MUTED);
  MakeLabel(AParent,
    'Dieser Assistent hilft dir, Structura in wenigen Schritten einzurichten. '  +
    'Du kannst alles jederzeit in den Einstellungen anpassen.',
    40, 140, WIZARD_W - 80, 11);
  MakeLabel(AParent,
    'Was dich erwartet:' + LineEnding +
    '  1.  Projektordner festlegen – wo deine Buchprojekte liegen' + LineEnding +
    '  2.  Programme erkennen – Word, LibreOffice oder SoftMaker',
    40, 210, WIZARD_W - 80, 11);
end;

procedure TFirstRunWizard.BuildStep1(AParent: TPanel);
var
  Lbl: TLabel;
  BrowseBtn: TButton;
begin
  MakeLabel(AParent, 'Projektordner', 40, 40, WIZARD_W - 80,
    16, True, COLOR_ACCENT);
  MakeLabel(AParent,
    'Wähle den Ordner, in dem deine Buchprojekte liegen. '  +
    'Structura zeigt alle Unterordner mit einer structura.json auf der Startseite.',
    40, 82, WIZARD_W - 80, 11);

  Lbl := MakeLabel(AParent, 'Ordnerpfad', 40, 148, 200, 10, False, COLOR_MUTED);
  Lbl.Height := 18;

  FFolderEdit := TEdit.Create(AParent);
  FFolderEdit.Parent := AParent;
  FFolderEdit.Left := 40;
  FFolderEdit.Top := 168;
  FFolderEdit.Width := WIZARD_W - 140;
  FFolderEdit.Height := 28;
  FFolderEdit.Font.Size := 10;
  if Assigned(FSettings) then
    FFolderEdit.Text := FSettings.DefaultProjectFolder;

  BrowseBtn := TButton.Create(AParent);
  BrowseBtn.Parent := AParent;
  BrowseBtn.Caption := '...';
  BrowseBtn.Left := FFolderEdit.Left + FFolderEdit.Width + 8;
  BrowseBtn.Top := FFolderEdit.Top;
  BrowseBtn.Width := 40;
  BrowseBtn.Height := 28;
  BrowseBtn.OnClick := @BrowseFolder;

  MakeLabel(AParent,
    'Du kannst dieses Feld auch leer lassen und den Ordner später in den Einstellungen eintragen.',
    40, 212, WIZARD_W - 80, 10, False, COLOR_MUTED);
end;

procedure TFirstRunWizard.BuildStep2(AParent: TPanel);
var
  WordLine, LibreLine, TextLine: string;
begin
  MakeLabel(AParent, 'Alles bereit.', 40, 40, WIZARD_W - 80,
    16, True, COLOR_ACCENT);

  // Programme-Ergebnis
  WordLine  := OfficeStatusLine(FTargets.WordPath,        'Microsoft Word');
  LibreLine := OfficeStatusLine(FTargets.LibreOfficePath, 'LibreOffice');
  TextLine  := OfficeStatusLine(FTargets.TextMakerPath,   'SoftMaker TextMaker');

  MakeLabel(AParent, 'Erkannte Programme:', 40, 90, WIZARD_W - 80,
    11, True);
  MakeLabel(AParent,
    WordLine + LineEnding + LibreLine + LineEnding + TextLine,
    40, 116, WIZARD_W - 80, 11);

  MakeLabel(AParent,
    'Alles lässt sich jederzeit über das Zahnrad-Symbol in den Einstellungen anpassen.',
    40, 260, WIZARD_W - 80, 10, False, COLOR_MUTED);
end;

function TFirstRunWizard.OfficeStatusLine(const APath, AName: string): string;
begin
  if Trim(APath) <> '' then
    Result := '✓  ' + AName + '   (' + APath + ')'
  else
    Result := '–  ' + AName + '   (nicht gefunden)';
end;

{ ─── Navigation ─────────────────────────────────────────────────────────── }

procedure TFirstRunWizard.BuildNavBar;
var
  NavPanel: TPanel;
  Sep: TBevel;
begin
  NavPanel := TPanel.Create(Self);
  NavPanel.Parent := Self;
  NavPanel.Align := alBottom;
  NavPanel.Height := 56;
  NavPanel.BevelOuter := bvNone;
  NavPanel.Color := COLOR_BG;

  Sep := TBevel.Create(NavPanel);
  Sep.Parent := NavPanel;
  Sep.Align := alTop;
  Sep.Height := 1;
  Sep.Shape := bsTopLine;

  FStepLabel := TLabel.Create(NavPanel);
  FStepLabel.Parent := NavPanel;
  FStepLabel.Left := 20;
  FStepLabel.Top := 20;
  FStepLabel.Font.Color := COLOR_MUTED;
  FStepLabel.Font.Size := 9;

  FSkipBtn := TButton.Create(NavPanel);
  FSkipBtn.Parent := NavPanel;
  FSkipBtn.Caption := 'Überspringen';
  FSkipBtn.Width := 110;
  FSkipBtn.Height := 30;
  FSkipBtn.Left := WIZARD_W - 340;
  FSkipBtn.Top := 13;
  FSkipBtn.OnClick := @SkipClick;

  FBackBtn := TButton.Create(NavPanel);
  FBackBtn.Parent := NavPanel;
  FBackBtn.Caption := '← Zurück';
  FBackBtn.Width := 90;
  FBackBtn.Height := 30;
  FBackBtn.Left := WIZARD_W - 220;
  FBackBtn.Top := 13;
  FBackBtn.OnClick := @BackClick;

  FNextBtn := TButton.Create(NavPanel);
  FNextBtn.Parent := NavPanel;
  FNextBtn.Caption := 'Weiter →';
  FNextBtn.Width := 100;
  FNextBtn.Height := 30;
  FNextBtn.Left := WIZARD_W - 122;
  FNextBtn.Top := 13;
  FNextBtn.Default := True;
  FNextBtn.OnClick := @NextClick;
end;

procedure TFirstRunWizard.ShowStep(AStep: Integer);
var
  I: Integer;
begin
  FCurrentStep := AStep;
  for I := 0 to High(FPanels) do
    FPanels[I].Visible := (I = AStep);
  UpdateNavButtons;
end;

procedure TFirstRunWizard.UpdateNavButtons;
begin
  FBackBtn.Visible  := FCurrentStep > STEP_WELCOME;
  FSkipBtn.Visible  := FCurrentStep < STEP_DONE;
  if FCurrentStep = STEP_DONE then
    FNextBtn.Caption := 'Loslegen ✓'
  else
    FNextBtn.Caption := 'Weiter →';

  case FCurrentStep of
    STEP_WELCOME: FStepLabel.Caption := 'Schritt 1 von 3';
    STEP_FOLDER:  FStepLabel.Caption := 'Schritt 2 von 3';
    STEP_DONE:    FStepLabel.Caption := 'Schritt 3 von 3';
  end;
end;

{ ─── Events ─────────────────────────────────────────────────────────────── }

procedure TFirstRunWizard.BrowseFolder(Sender: TObject);
var
  SelDir: string;
begin
  SelDir := FFolderEdit.Text;
  if SelectDirectory('Projektordner wählen', '', SelDir) then
    FFolderEdit.Text := SelDir;
end;

procedure TFirstRunWizard.NextClick(Sender: TObject);
begin
  // Daten aus aktuellem Schritt übernehmen
  if (FCurrentStep = STEP_FOLDER) and Assigned(FSettings) then
    FSettings.DefaultProjectFolder := Trim(FFolderEdit.Text);

  if FCurrentStep >= STEP_DONE then
  begin
    ModalResult := mrOK;
    Exit;
  end;
  ShowStep(FCurrentStep + 1);
end;

procedure TFirstRunWizard.BackClick(Sender: TObject);
begin
  if FCurrentStep > STEP_WELCOME then
    ShowStep(FCurrentStep - 1);
end;

procedure TFirstRunWizard.SkipClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{ ─── Konstruktor ─────────────────────────────────────────────────────────── }

constructor TFirstRunWizard.CreateWizard(AOwner: TComponent; ASettings: TAppSettings);
var
  I: Integer;
  ContentPanel: TPanel;
begin
  inherited CreateNew(AOwner);

  FSettings := ASettings;
  FTargets  := DetectOfficeTargets;

  Caption := 'Structura einrichten';
  Width   := WIZARD_W;
  Height  := WIZARD_H;
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;
  Color := COLOR_BG;

  // Gemeinsames Content-Panel (füllt alles außer der NavBar)
  ContentPanel := TPanel.Create(Self);
  ContentPanel.Parent := Self;
  ContentPanel.Align := alClient;
  ContentPanel.BevelOuter := bvNone;
  ContentPanel.Color := COLOR_BG;

  // Schritte als überlagerte Panels
  for I := 0 to High(FPanels) do
  begin
    FPanels[I] := TPanel.Create(ContentPanel);
    FPanels[I].Parent := ContentPanel;
    FPanels[I].Align := alClient;
    FPanels[I].BevelOuter := bvNone;
    FPanels[I].Color := COLOR_BG;
    FPanels[I].Visible := (I = STEP_WELCOME);
  end;

  BuildStep0(FPanels[STEP_WELCOME]);
  BuildStep1(FPanels[STEP_FOLDER]);
  BuildStep2(FPanels[STEP_DONE]);
  BuildNavBar;

  FCurrentStep := STEP_WELCOME;
  UpdateNavButtons;
end;

{ ─── Öffentliche Einstiegsfunktion ──────────────────────────────────────── }

function RunFirstRunWizard(AOwner: TComponent; ASettings: TAppSettings): Boolean;
var
  Wiz: TFirstRunWizard;
begin
  Wiz := TFirstRunWizard.CreateWizard(AOwner, ASettings);
  try
    Result := Wiz.ShowModal = mrOK;
  finally
    Wiz.Free;
  end;
end;

end.
