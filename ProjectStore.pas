unit ProjectStore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, StructuraTypes;

type
  TProjectStore = class
  public
    class function LoadFromFolder(const AFolder: string): TStructuraProject;
    class function LoadSummaryFromFolder(const AFolder: string): TProjectSummary;
    class procedure SaveToFolder(AProject: TStructuraProject);
    class procedure EnsureProjectFolders(const AFolder: string);
    class procedure CreateBlankProject(AProject: TStructuraProject; const AFolder,
      ATitle: string);
    class function ProjectFileName(const AFolder: string): string;
    class function AbsolutePath(const AFolder, ARelative: string): string;
    class function RelativePath(const AFolder, AAbsolute: string): string;
    // Robustes, atomares Schreiben einer Textdatei: erst in eine Temp-Datei
    // im selben Ordner, dann atomar über das Ziel verschieben — mit Retry
    // gegen kurzzeitige Sperren (Nextcloud/Dropbox/OneDrive-Sync, Netzlaufwerke).
    // Liefert False, wenn es endgültig nicht klappt; das Ziel bleibt dann
    // unverändert (kein Datenverlust durch halben Schreibvorgang).
    class function SaveTextAtomic(const AFileName, AText: string;
      out AErrorText: string): Boolean;
  end;

implementation

uses
  {$IFDEF WINDOWS}Windows,{$ENDIF} FileUtil;

const
  CURRENT_PROJECT_VERSION = 1;

class function TProjectStore.SaveTextAtomic(const AFileName, AText: string;
  out AErrorText: string): Boolean;
const
  MaxTries = 6;
var
  TempName: string;
  SL: TStringList;
  Attempt: Integer;
  Wrote, Moved: Boolean;
begin
  Result := False;
  AErrorText := '';
  TempName := AFileName + '.tmp';

  // 1) In die Temp-Datei schreiben (Original bleibt unangetastet)
  Wrote := False;
  SL := TStringList.Create;
  try
    SL.Text := AText;
    for Attempt := 1 to MaxTries do
    begin
      try
        SL.SaveToFile(TempName);
        Wrote := True;
        Break;
      except
        on E: Exception do
        begin
          AErrorText := E.Message;
          if Attempt = MaxTries then Break;
          Sleep(250);
        end;
      end;
    end;
  finally
    SL.Free;
  end;
  if not Wrote then
    Exit;

  // 2) Atomar über das Ziel verschieben, mit Retry gegen Sync-Sperren
  Moved := False;
  for Attempt := 1 to MaxTries do
  begin
    {$IFDEF WINDOWS}
    if MoveFileExW(PWideChar(UTF8Decode(TempName)), PWideChar(UTF8Decode(AFileName)),
       MOVEFILE_REPLACE_EXISTING) then
    begin
      Moved := True;
      Break;
    end;
    {$ELSE}
    SysUtils.DeleteFile(AFileName);
    if RenameFile(TempName, AFileName) then
    begin
      Moved := True;
      Break;
    end;
    {$ENDIF}
    AErrorText := 'Zieldatei ist gerade gesperrt (Sync/Netzlaufwerk?).';
    Sleep(250);
  end;

  if Moved then
    Result := True
  else
    // Temp aufräumen — Original ist intakt geblieben
    SysUtils.DeleteFile(TempName);
end;

function IsAbsolutePath(const APath: string): Boolean;
begin
  Result := ((Length(APath) > 2) and (APath[2] = ':')) or
    ((APath <> '') and (APath[1] = PathDelim));
end;

function NormalizeStoredPath(const APath: string): string;
begin
  Result := StringReplace(APath, '\', PathDelim, [rfReplaceAll]);
  Result := StringReplace(Result, '/', PathDelim, [rfReplaceAll]);
end;

class function TProjectStore.ProjectFileName(const AFolder: string): string;
begin
  Result := IncludeTrailingPathDelimiter(AFolder) + 'structura.json';
end;

class procedure TProjectStore.EnsureProjectFolders(const AFolder: string);
begin
  ForceDirectories(IncludeTrailingPathDelimiter(AFolder) + 'chapters');
  ForceDirectories(IncludeTrailingPathDelimiter(AFolder) + 'notes');
  ForceDirectories(IncludeTrailingPathDelimiter(AFolder) + 'backup');
  ForceDirectories(IncludeTrailingPathDelimiter(AFolder) + 'preview');
end;

class procedure TProjectStore.CreateBlankProject(AProject: TStructuraProject;
  const AFolder, ATitle: string);
var
  CoverPath: string;
begin
  EnsureProjectFolders(AFolder);
  AProject.Clear;
  AProject.FolderPath := AFolder;
  AProject.Title := ATitle;
  AProject.Author := '';
  AProject.Subtitle := '';
  CoverPath := IncludeTrailingPathDelimiter(AFolder) + 'cover.png';
  if FileExists(CoverPath) then
    AProject.CoverImagePath := 'cover.png'
  else
    AProject.CoverImagePath := '';
  AProject.AddDivider('Teil I');
  SaveToFolder(AProject);
end;

class function TProjectStore.AbsolutePath(const AFolder, ARelative: string): string;
begin
  if ARelative = '' then
    Exit('');
  if IsAbsolutePath(ARelative) then
    Exit(ARelative);
  Result := ExpandFileName(IncludeTrailingPathDelimiter(AFolder) + NormalizeStoredPath(ARelative));
end;

class function TProjectStore.RelativePath(const AFolder, AAbsolute: string): string;
begin
  if AAbsolute = '' then
    Exit('');
  Result := ExtractRelativePath(IncludeTrailingPathDelimiter(AFolder), AAbsolute);
end;

class function TProjectStore.LoadFromFolder(const AFolder: string): TStructuraProject;
var
  Root: TJSONObject;
  Items: TJSONArray;
  ItemObj: TJSONObject;
  Item: TStructuraItem;
  I: Integer;
  Content: string;
begin
  Result := TStructuraProject.Create;
  try
    Result.FolderPath := AFolder;
    Content := ReadFileToString(ProjectFileName(AFolder));
    Root := TJSONObject(GetJSON(Content));
    try
      Result.Title := Root.Get('title', ExtractFileName(AFolder));
      Result.Author := Root.Get('author', '');
      Result.Subtitle := Root.Get('subtitle', '');
      Result.CoverImagePath := NormalizeStoredPath(Root.Get('coverImage', ''));
      Result.ProjectNotesFileName := NormalizeStoredPath(
        Root.Get('projectNotes', RelativeProjectPath(['notes', 'project.md'])));
      Items := Root.Arrays['items'];
      if Assigned(Items) then
        for I := 0 to Items.Count - 1 do
        begin
          ItemObj := Items.Objects[I];
          if SameText(ItemObj.Get('type', 'chapter'), 'divider') then
            Item := Result.AddDivider(ItemObj.Get('title', 'Neuer Teil'))
          else
            Item := Result.AddChapter(ItemObj.Get('title', 'Neues Kapitel'),
              NormalizeStoredPath(ItemObj.Get('fileName', '')));
          Item.Id := ItemObj.Get('id', Item.Id);
          Item.Status := ItemObj.Get('status', Item.Status);
          Item.NotesFileName := NormalizeStoredPath(ItemObj.Get('notesFileName', Item.NotesFileName));
        end;
    finally
      Root.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Projektdatei konnte nicht gelesen werden: ' + E.Message);
    end;
  end;
end;

class function TProjectStore.LoadSummaryFromFolder(const AFolder: string): TProjectSummary;
var
  FileName, Content: string;
  Root: TJSONObject;
  Items: TJSONData;
  ItemsArr: TJSONArray;
  I: Integer;
  ItemType: string;
begin
  Result.FolderPath := ExcludeTrailingPathDelimiter(AFolder);
  Result.Title := '';
  Result.Subtitle := '';
  Result.Author := '';
  Result.CoverImagePath := '';
  Result.ChapterCount := 0;
  Result.Valid := False;

  FileName := ProjectFileName(AFolder);
  if not FileExists(FileName) then
    Exit;

  try
    Content := ReadFileToString(FileName);
    Root := TJSONObject(GetJSON(Content));
    try
      Result.Title := Root.Get('title', '');
      Result.Subtitle := Root.Get('subtitle', '');
      Result.Author := Root.Get('author', '');
      // Speichert wird unter 'coverImage'; alte/abweichende Dateien mit
      // 'coverImagePath' als Rückfall lesen.
      Result.CoverImagePath := Root.Get('coverImage', Root.Get('coverImagePath', ''));
      Items := Root.Find('items');
      if Items is TJSONArray then
      begin
        ItemsArr := TJSONArray(Items);
        for I := 0 to ItemsArr.Count - 1 do
          if ItemsArr.Items[I] is TJSONObject then
          begin
            ItemType := TJSONObject(ItemsArr.Items[I]).Get('type', '');
            if SameText(ItemType, 'chapter') then
              Inc(Result.ChapterCount);
          end;
      end;
      if Result.Title = '' then
        Result.Title := ExtractFileName(Result.FolderPath);
      Result.Valid := True;
    finally
      Root.Free;
    end;
  except
    // Ungültige JSON — Valid bleibt False
  end;
end;

class procedure TProjectStore.SaveToFolder(AProject: TStructuraProject);
var
  Root: TJSONObject;
  Items: TJSONArray;
  ItemObj: TJSONObject;
  I: Integer;
  ProjectFile: string;
  BackupFile: string;
  ErrorText: string;
begin
  EnsureProjectFolders(AProject.FolderPath);
  ProjectFile := ProjectFileName(AProject.FolderPath);
  if FileExists(ProjectFile) then
  begin
    BackupFile := IncludeTrailingPathDelimiter(AProject.FolderPath) + 'backup' +
      PathDelim + 'structura-' + FormatDateTime('yyyymmdd-hhnnss', Now) + '.json';
    ForceDirectories(ExtractFileDir(BackupFile));
    CopyFile(ProjectFile, BackupFile, [cffOverwriteFile]);
  end;
  Root := TJSONObject.Create;
  try
    Root.Add('projectVersion', CURRENT_PROJECT_VERSION);
    Root.Add('title', AProject.Title);
    Root.Add('author', AProject.Author);
    Root.Add('subtitle', AProject.Subtitle);
    Root.Add('coverImage', AProject.CoverImagePath);
    Root.Add('projectNotes', AProject.ProjectNotesFileName);
    Items := TJSONArray.Create;
    Root.Add('items', Items);
    for I := 0 to AProject.Count - 1 do
    begin
      ItemObj := TJSONObject.Create;
      ItemObj.Add('id', AProject[I].Id);
      if AProject[I].ItemType = sitDivider then
        ItemObj.Add('type', 'divider')
      else
        ItemObj.Add('type', 'chapter');
      ItemObj.Add('title', AProject[I].Title);
      ItemObj.Add('fileName', AProject[I].FileName);
      ItemObj.Add('notesFileName', AProject[I].NotesFileName);
      ItemObj.Add('status', AProject[I].Status);
      Items.Add(ItemObj);
    end;
    if not SaveTextAtomic(ProjectFile, Root.FormatJSON, ErrorText) then
      raise Exception.Create('Projektdatei konnte nicht gespeichert werden: ' +
        ErrorText);
  finally
    Root.Free;
  end;
end;

end.
