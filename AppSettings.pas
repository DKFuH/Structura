unit AppSettings;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson;

type
  TWorkflowCopyMode = (wcmChapterText, wcmTitleAndChapterText, wcmPromptPlusChapter);

  TWorkflowButtonConfig = class
  public
    Name: string;
    Target: string;
    CopyMode: TWorkflowCopyMode;
    Prefix: string;
    Suffix: string;
    Hint: string;
    function ToJson: TJSONObject;
    procedure AssignFromJson(AObject: TJSONObject);
    procedure Assign(Source: TWorkflowButtonConfig);
  end;

  TAppSettings = class
  private
    FWorkflowButtons: TObjectList;
    FRecentProjects: TStringList;
    function GetWorkflowButton(Index: Integer): TWorkflowButtonConfig;
    function GetRecentProject(Index: Integer): string;
  public
    DefaultProjectFolder: string;
    PreferredDocxEditor: string;
    WordPathOverride: string;
    LibreOfficePathOverride: string;
    TextMakerPathOverride: string;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Source: TAppSettings);
    function Clone: TAppSettings;
    procedure AddRecentProject(const AFolder: string);
    function RecentProjectCount: Integer;
    property RecentProjects[Index: Integer]: string read GetRecentProject;
    procedure EnsureDefaultWorkflowButtons;
    function WorkflowButtonCount: Integer;
    function AddWorkflowButton: TWorkflowButtonConfig;
    procedure DeleteWorkflowButton(Index: Integer);
    procedure MoveWorkflowButton(FromIndex, ToIndex: Integer);
    function ToJson: TJSONObject;
    procedure AssignFromJson(AObject: TJSONObject);
    property WorkflowButtons[Index: Integer]: TWorkflowButtonConfig read GetWorkflowButton;
  end;

function WorkflowCopyModeToString(AMode: TWorkflowCopyMode): string;
function WorkflowCopyModeFromString(const AValue: string): TWorkflowCopyMode;

implementation

function WorkflowCopyModeToString(AMode: TWorkflowCopyMode): string;
begin
  case AMode of
    wcmTitleAndChapterText: Result := 'titleAndChapterText';
    wcmPromptPlusChapter: Result := 'promptPlusChapter';
  else
    Result := 'chapterText';
  end;
end;

function WorkflowCopyModeFromString(const AValue: string): TWorkflowCopyMode;
begin
  if SameText(AValue, 'titleAndChapterText') then
    Exit(wcmTitleAndChapterText);
  if SameText(AValue, 'promptPlusChapter') then
    Exit(wcmPromptPlusChapter);
  Result := wcmChapterText;
end;

function TWorkflowButtonConfig.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('name', Name);
  Result.Add('target', Target);
  Result.Add('copyMode', WorkflowCopyModeToString(CopyMode));
  Result.Add('prefix', Prefix);
  Result.Add('suffix', Suffix);
  Result.Add('hint', Hint);
end;

procedure TWorkflowButtonConfig.AssignFromJson(AObject: TJSONObject);
begin
  Name := AObject.Get('name', '');
  Target := AObject.Get('target', '');
  CopyMode := WorkflowCopyModeFromString(AObject.Get('copyMode', 'chapterText'));
  Prefix := AObject.Get('prefix', '');
  Suffix := AObject.Get('suffix', '');
  Hint := AObject.Get('hint', '');
end;

procedure TWorkflowButtonConfig.Assign(Source: TWorkflowButtonConfig);
begin
  if not Assigned(Source) then
    Exit;
  Name := Source.Name;
  Target := Source.Target;
  CopyMode := Source.CopyMode;
  Prefix := Source.Prefix;
  Suffix := Source.Suffix;
  Hint := Source.Hint;
end;

constructor TAppSettings.Create;
begin
  inherited Create;
  FWorkflowButtons := TObjectList.Create(True);
  FRecentProjects := TStringList.Create;
end;

destructor TAppSettings.Destroy;
begin
  FWorkflowButtons.Free;
  FRecentProjects.Free;
  inherited Destroy;
end;

procedure TAppSettings.Clear;
begin
  DefaultProjectFolder := '';
  PreferredDocxEditor := '';
  WordPathOverride := '';
  LibreOfficePathOverride := '';
  TextMakerPathOverride := '';
  FWorkflowButtons.Clear;
  FRecentProjects.Clear;
end;

procedure TAppSettings.Assign(Source: TAppSettings);
var
  I: Integer;
  Button: TWorkflowButtonConfig;
begin
  if not Assigned(Source) then
    Exit;

  Clear;
  DefaultProjectFolder := Source.DefaultProjectFolder;
  PreferredDocxEditor := Source.PreferredDocxEditor;
  WordPathOverride := Source.WordPathOverride;
  LibreOfficePathOverride := Source.LibreOfficePathOverride;
  TextMakerPathOverride := Source.TextMakerPathOverride;

  for I := 0 to Source.RecentProjectCount - 1 do
    FRecentProjects.Add(Source.RecentProjects[I]);

  for I := 0 to Source.WorkflowButtonCount - 1 do
  begin
    Button := AddWorkflowButton;
    Button.Assign(Source.WorkflowButtons[I]);
  end;
end;

procedure TAppSettings.AddRecentProject(const AFolder: string);
var
  I: Integer;
  Normalized: string;
begin
  Normalized := ExcludeTrailingPathDelimiter(AFolder);
  // Duplikate entfernen (case-insensitiv)
  for I := FRecentProjects.Count - 1 downto 0 do
    if SameText(ExcludeTrailingPathDelimiter(FRecentProjects[I]), Normalized) then
      FRecentProjects.Delete(I);
  // Vorne einfügen
  FRecentProjects.Insert(0, Normalized);
  // Auf 8 begrenzen
  while FRecentProjects.Count > 8 do
    FRecentProjects.Delete(FRecentProjects.Count - 1);
end;

function TAppSettings.RecentProjectCount: Integer;
begin
  Result := FRecentProjects.Count;
end;

function TAppSettings.GetRecentProject(Index: Integer): string;
begin
  Result := FRecentProjects[Index];
end;

function TAppSettings.Clone: TAppSettings;
begin
  Result := TAppSettings.Create;
  Result.Assign(Self);
end;

procedure TAppSettings.EnsureDefaultWorkflowButtons;
var
  Button: TWorkflowButtonConfig;
begin
  if FWorkflowButtons.Count > 0 then
    Exit;

  Button := AddWorkflowButton;
  Button.Name := 'Grammarly';
  Button.Target := 'https://app.grammarly.com/';
  Button.CopyMode := wcmChapterText;
  Button.Hint := 'Text in Grammarly einfügen und danach zurück in die DOCX übernehmen.';

  Button := AddWorkflowButton;
  Button.Name := 'LanguageTool';
  Button.Target := 'https://languagetool.org/de';
  Button.CopyMode := wcmChapterText;
  Button.Hint := 'Kapiteltext nach dem Öffnen in LanguageTool einfügen.';

  Button := AddWorkflowButton;
  Button.Name := 'ChatGPT Tiefenprüfung';
  Button.Target := 'https://chatgpt.com/';
  Button.CopyMode := wcmPromptPlusChapter;
  Button.Prefix :=
    'Führe eine Tiefenprüfung dieses Kapitels durch: Sprache, Struktur, Fachlichkeit, Quellen, KI-Risiken, Originalität und Veröffentlichungsreife.' +
    LineEnding + LineEnding;
  Button.Hint := 'Den kopierten Text in ChatGPT einfügen.';
end;

function TAppSettings.WorkflowButtonCount: Integer;
begin
  Result := FWorkflowButtons.Count;
end;

function TAppSettings.AddWorkflowButton: TWorkflowButtonConfig;
begin
  Result := TWorkflowButtonConfig.Create;
  Result.CopyMode := wcmChapterText;
  FWorkflowButtons.Add(Result);
end;

procedure TAppSettings.DeleteWorkflowButton(Index: Integer);
begin
  if (Index < 0) or (Index >= FWorkflowButtons.Count) then
    Exit;
  FWorkflowButtons.Delete(Index);
end;

procedure TAppSettings.MoveWorkflowButton(FromIndex, ToIndex: Integer);
begin
  if (FromIndex < 0) or (FromIndex >= FWorkflowButtons.Count) then
    Exit;
  if (ToIndex < 0) or (ToIndex >= FWorkflowButtons.Count) then
    Exit;
  FWorkflowButtons.Move(FromIndex, ToIndex);
end;

function TAppSettings.GetWorkflowButton(Index: Integer): TWorkflowButtonConfig;
begin
  Result := TWorkflowButtonConfig(FWorkflowButtons[Index]);
end;

function TAppSettings.ToJson: TJSONObject;
var
  Buttons: TJSONArray;
  Recent: TJSONArray;
  I: Integer;
begin
  Result := TJSONObject.Create;
  Result.Add('defaultProjectFolder', DefaultProjectFolder);
  Result.Add('preferredDocxEditor', PreferredDocxEditor);
  Result.Add('wordPathOverride', WordPathOverride);
  Result.Add('libreOfficePathOverride', LibreOfficePathOverride);
  Result.Add('textMakerPathOverride', TextMakerPathOverride);
  Recent := TJSONArray.Create;
  for I := 0 to FRecentProjects.Count - 1 do
    Recent.Add(FRecentProjects[I]);
  Result.Add('recentProjects', Recent);
  Buttons := TJSONArray.Create;
  for I := 0 to FWorkflowButtons.Count - 1 do
    Buttons.Add(WorkflowButtons[I].ToJson);
  Result.Add('workflowButtons', Buttons);
end;

procedure TAppSettings.AssignFromJson(AObject: TJSONObject);
var
  Buttons: TJSONArray;
  ButtonsData: TJSONData;
  RecentData: TJSONData;
  Recent: TJSONArray;
  I: Integer;
  Button: TWorkflowButtonConfig;
begin
  Clear;
  DefaultProjectFolder := AObject.Get('defaultProjectFolder', '');
  PreferredDocxEditor := AObject.Get('preferredDocxEditor', '');
  WordPathOverride := AObject.Get('wordPathOverride', '');
  LibreOfficePathOverride := AObject.Get('libreOfficePathOverride', '');
  TextMakerPathOverride := AObject.Get('textMakerPathOverride', '');

  RecentData := AObject.Find('recentProjects');
  if RecentData is TJSONArray then
  begin
    Recent := TJSONArray(RecentData);
    for I := 0 to Recent.Count - 1 do
      if Recent.Items[I].JSONType = jtString then
        FRecentProjects.Add(Recent.Items[I].AsString);
  end;

  ButtonsData := AObject.Find('workflowButtons');
  if ButtonsData is TJSONArray then
    Buttons := TJSONArray(ButtonsData)
  else
    Buttons := nil;

  if Assigned(Buttons) then
    for I := 0 to Buttons.Count - 1 do
      if Buttons.Items[I] is TJSONObject then
      begin
        Button := AddWorkflowButton;
        Button.AssignFromJson(TJSONObject(Buttons.Items[I]));
      end;

  EnsureDefaultWorkflowButtons;
end;

end.
