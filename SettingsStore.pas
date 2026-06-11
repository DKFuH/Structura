unit SettingsStore;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  SysUtils, AppSettings;

type
  TSettingsStore = class
  public
    class function SettingsFileName: string;
    class function Load: TAppSettings;
    class procedure Save(ASettings: TAppSettings);
  end;

implementation

uses
  Classes, FileUtil, fpjson, jsonparser;

class function TSettingsStore.SettingsFileName: string;
var
  SettingsDir: string;
begin
  if FileExists(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'portable.flag') then
    SettingsDir := ExtractFileDir(ParamStr(0))
  else if Trim(GetEnvironmentVariable('APPDATA')) <> '' then
    SettingsDir := IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) + 'Structura'
  else
    SettingsDir := ExtractFileDir(ParamStr(0));

  ForceDirectories(SettingsDir);
  Result := IncludeTrailingPathDelimiter(SettingsDir) + 'structura-settings.json';
end;

class function TSettingsStore.Load: TAppSettings;
var
  Root: TJSONObject;
  Content: string;
begin
  Result := TAppSettings.Create;
  if not FileExists(SettingsFileName) then
  begin
    Result.EnsureDefaultWorkflowButtons;
    Exit;
  end;

  try
    Content := ReadFileToString(SettingsFileName);
    Root := TJSONObject(GetJSON(Content));
    try
      Result.AssignFromJson(Root);
    finally
      Root.Free;
    end;
  except
    Result.Clear;
    Result.EnsureDefaultWorkflowButtons;
  end;
end;

class procedure TSettingsStore.Save(ASettings: TAppSettings);
var
  Root: TJSONObject;
  Buffer: TStringList;
begin
  Root := ASettings.ToJson;
  try
    Buffer := TStringList.Create;
    try
      Buffer.Text := Root.FormatJSON;
      Buffer.SaveToFile(SettingsFileName);
    finally
      Buffer.Free;
    end;
  finally
    Root.Free;
  end;
end;

end.
