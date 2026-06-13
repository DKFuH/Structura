unit UpdateCheckUnit;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

// Holt die neueste veröffentlichte Release von GitHub.
// Liefert True und füllt ALatestTag (z. B. "v0.8.3") und AHtmlUrl, wenn der
// Abruf erfolgreich war. Bei fehlendem Netz / Timeout / Fehler: False, ohne
// Exception — der Aufrufer macht dann einfach nichts.
function FetchLatestRelease(out ALatestTag, AHtmlUrl: string): Boolean;

// True, wenn ALatest eine höhere Version als ACurrent ist. Akzeptiert
// Schreibweisen mit/ohne führendes "v" (z. B. "0.8.3" oder "v0.8.3").
function IsNewerVersion(const ALatest, ACurrent: string): Boolean;

// Normalisiert eine Versionsangabe (führendes "v" entfernt, getrimmt) — für
// den Vergleich „schon weggeklickt?".
function NormalizeVersion(const AValue: string): string;

// Zeigt den einmaligen „Update verfügbar"-Dialog. Bei „Zur Download-Seite"
// wird AHtmlUrl im Browser geöffnet.
procedure ShowUpdateAvailableDialog(const ALatestTag, ACurrentVersion, AHtmlUrl: string);

implementation

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Graphics, LCLIntf, fpjson, jsonparser
  {$IFDEF WINDOWS}, Windows, WinInet{$ENDIF};

const
  RELEASE_API_URL =
    'https://api.github.com/repos/DKFuH/Structura/releases/latest';

function NormalizeVersion(const AValue: string): string;
begin
  Result := Trim(AValue);
  if (Length(Result) > 0) and ((Result[1] = 'v') or (Result[1] = 'V')) then
    Delete(Result, 1, 1);
  Result := Trim(Result);
end;

type
  TVersionTriple = record
    Major, Minor, Patch: Integer;
  end;

// Liest bis zu drei Zahlenblöcke aus einer Versionsangabe (Major.Minor.Patch),
// getrennt durch '.'. Ein Suffix wie "-beta" oder "+build" beendet das Parsen.
function ParseVersionTriple(const AValue: string): TVersionTriple;
var
  Clean, Cur: string;
  I, N: Integer;
  Vals: array[0..2] of Integer;
begin
  Vals[0] := 0; Vals[1] := 0; Vals[2] := 0;
  N := 0;
  Cur := '';
  Clean := NormalizeVersion(AValue);
  for I := 1 to Length(Clean) + 1 do
  begin
    if (I <= Length(Clean)) and (Clean[I] in ['0'..'9']) then
      Cur := Cur + Clean[I]
    else
    begin
      if Cur <> '' then
      begin
        if N <= 2 then
          Vals[N] := StrToIntDef(Cur, 0);
        Inc(N);
        Cur := '';
      end;
      // Punkt = weitere Komponente folgt; alles andere (z. B. '-') beendet.
      if (I <= Length(Clean)) and (Clean[I] <> '.') then
        Break;
    end;
  end;
  Result.Major := Vals[0];
  Result.Minor := Vals[1];
  Result.Patch := Vals[2];
end;

function IsNewerVersion(const ALatest, ACurrent: string): Boolean;
var
  L, C: TVersionTriple;
begin
  L := ParseVersionTriple(ALatest);
  C := ParseVersionTriple(ACurrent);
  if L.Major <> C.Major then Exit(L.Major > C.Major);
  if L.Minor <> C.Minor then Exit(L.Minor > C.Minor);
  Result := L.Patch > C.Patch;
end;

{$IFDEF WINDOWS}
function HttpGet(const AUrl: string; out ABody: string): Boolean;
const
  AGENT = 'Structura-UpdateCheck';
  TIMEOUT_MS: DWORD = 3000;
var
  hNet, hUrl: HINTERNET;
  Buf: array[0..4095] of Byte;
  BytesRead: DWORD;
  Stream: TMemoryStream;
begin
  Result := False;
  ABody := '';
  hNet := InternetOpenA(AGENT, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if hNet = nil then
    Exit;
  try
    // Kurze Timeouts, damit das Schließen der App nie spürbar hängt.
    InternetSetOption(hNet, INTERNET_OPTION_CONNECT_TIMEOUT, @TIMEOUT_MS, SizeOf(TIMEOUT_MS));
    InternetSetOption(hNet, INTERNET_OPTION_SEND_TIMEOUT, @TIMEOUT_MS, SizeOf(TIMEOUT_MS));
    InternetSetOption(hNet, INTERNET_OPTION_RECEIVE_TIMEOUT, @TIMEOUT_MS, SizeOf(TIMEOUT_MS));
    hUrl := InternetOpenUrlA(hNet, PAnsiChar(AnsiString(AUrl)),
      'Accept: application/vnd.github+json'#13#10, DWORD(-1),
      INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_UI or INTERNET_FLAG_SECURE, 0);
    if hUrl = nil then
      Exit;
    try
      Stream := TMemoryStream.Create;
      try
        repeat
          BytesRead := 0;
          if not InternetReadFile(hUrl, @Buf[0], SizeOf(Buf), BytesRead) then
            Break;
          if BytesRead > 0 then
            Stream.Write(Buf[0], BytesRead);
        until BytesRead = 0;
        if Stream.Size > 0 then
        begin
          SetLength(ABody, Stream.Size);
          Move(Stream.Memory^, ABody[1], Stream.Size);
          Result := True;
        end;
      finally
        Stream.Free;
      end;
    finally
      InternetCloseHandle(hUrl);
    end;
  finally
    InternetCloseHandle(hNet);
  end;
end;
{$ELSE}
function HttpGet(const AUrl: string; out ABody: string): Boolean;
begin
  // Update-Check ist derzeit nur unter Windows implementiert.
  ABody := '';
  Result := False;
end;
{$ENDIF}

function FetchLatestRelease(out ALatestTag, AHtmlUrl: string): Boolean;
var
  Body: string;
  Data: TJSONData;
  Obj: TJSONObject;
begin
  Result := False;
  ALatestTag := '';
  AHtmlUrl := '';
  if not HttpGet(RELEASE_API_URL, Body) then
    Exit;
  try
    Data := GetJSON(Body);
  except
    Exit;
  end;
  try
    if Data is TJSONObject then
    begin
      Obj := TJSONObject(Data);
      ALatestTag := Trim(Obj.Get('tag_name', ''));
      AHtmlUrl := Trim(Obj.Get('html_url', ''));
      Result := ALatestTag <> '';
    end;
  finally
    Data.Free;
  end;
end;

procedure ShowUpdateAvailableDialog(const ALatestTag, ACurrentVersion, AHtmlUrl: string);
var
  Dialog: TForm;
  Info: TLabel;
  DownloadBtn, LaterBtn: TButton;
begin
  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := 'Update verfügbar';
    Dialog.BorderStyle := bsDialog;
    Dialog.Position := poScreenCenter;
    Dialog.ClientWidth := 420;
    Dialog.ClientHeight := 150;

    Info := TLabel.Create(Dialog);
    Info.Parent := Dialog;
    Info.Left := 20;
    Info.Top := 24;
    Info.AutoSize := True;
    Info.WordWrap := True;
    Info.Constraints.MaxWidth := 380;
    Info.Caption :=
      Format('Version %s ist verfügbar.', [NormalizeVersion(ALatestTag)]) + LineEnding +
      Format('Installiert ist %s.', [NormalizeVersion(ACurrentVersion)]) + LineEnding + LineEnding +
      'Möchtest du die Download-Seite öffnen?';

    DownloadBtn := TButton.Create(Dialog);
    DownloadBtn.Parent := Dialog;
    DownloadBtn.Caption := 'Zur Download-Seite';
    DownloadBtn.ModalResult := mrYes;
    DownloadBtn.Default := True;
    DownloadBtn.SetBounds(Dialog.ClientWidth - 290, Dialog.ClientHeight - 40, 160, 28);

    LaterBtn := TButton.Create(Dialog);
    LaterBtn.Parent := Dialog;
    LaterBtn.Caption := 'Später';
    LaterBtn.ModalResult := mrCancel;
    LaterBtn.Cancel := True;
    LaterBtn.SetBounds(Dialog.ClientWidth - 120, Dialog.ClientHeight - 40, 100, 28);

    if (Dialog.ShowModal = mrYes) and (AHtmlUrl <> '') then
      OpenURL(AHtmlUrl);
  finally
    Dialog.Free;
  end;
end;

end.
