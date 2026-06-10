unit StructuraTypes;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, Contnrs, SysUtils;

type
  TStructuraItemType = (sitChapter, sitDivider);

  TStructuraItem = class
  public
    Id: string;
    ItemType: TStructuraItemType;
    Title: string;
    FileName: string;
    NotesFileName: string;
    Status: string;
    constructor Create(AType: TStructuraItemType);
    function DisplayTitle(Index: Integer): string;
  end;

  TStructuraProject = class
  private
    FItems: TObjectList;
    function GetItem(Index: Integer): TStructuraItem;
  public
    Title: string;
    Author: string;
    Subtitle: string;
    FolderPath: string;
    CoverImagePath: string;
    ProjectNotesFileName: string;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddChapter(const ATitle, AFileName: string): TStructuraItem;
    function AddDivider(const ATitle: string): TStructuraItem;
    procedure MoveItem(FromIndex, ToIndex: Integer);
    procedure DeleteItem(Index: Integer);
    function Count: Integer;
    property Items[Index: Integer]: TStructuraItem read GetItem; default;
  end;

function NewItemId(const Prefix: string): string;
function RelativeProjectPath(const Parts: array of string): string;
function DefaultChapterStatus: string;

const
  STRUCTURA_STATUSES: array[0..6] of string = (
    'Rohfassung',
    'In Bearbeitung',
    'Grammarly geprüft',
    'Sprachlich geprüft',
    'Fachlich geprüft',
    'Final',
    'Problem'
  );

implementation

function RelativeProjectPath(const Parts: array of string): string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(Parts) to High(Parts) do
  begin
    if Parts[I] = '' then
      Continue;
    if Result = '' then
      Result := Parts[I]
    else
      Result := IncludeTrailingPathDelimiter(Result) + Parts[I];
  end;
end;

constructor TStructuraItem.Create(AType: TStructuraItemType);
begin
  inherited Create;
  ItemType := AType;
  Status := DefaultChapterStatus;
end;

function TStructuraItem.DisplayTitle(Index: Integer): string;
begin
  if ItemType = sitChapter then
    Result := Format('%0.2d  %s', [Index + 1, Title])
  else
    Result := '--- ' + Title + ' ---';
end;

constructor TStructuraProject.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
  ProjectNotesFileName := RelativeProjectPath(['notes', 'project.md']);
end;

destructor TStructuraProject.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TStructuraProject.Clear;
begin
  FItems.Clear;
  Title := '';
  Author := '';
  Subtitle := '';
  FolderPath := '';
  CoverImagePath := '';
  ProjectNotesFileName := RelativeProjectPath(['notes', 'project.md']);
end;

function TStructuraProject.AddChapter(const ATitle, AFileName: string): TStructuraItem;
begin
  Result := TStructuraItem.Create(sitChapter);
  Result.Id := NewItemId('k');
  Result.Title := ATitle;
  Result.FileName := AFileName;
  Result.NotesFileName := RelativeProjectPath(['notes', Result.Id + '.md']);
  FItems.Add(Result);
end;

function TStructuraProject.AddDivider(const ATitle: string): TStructuraItem;
begin
  Result := TStructuraItem.Create(sitDivider);
  Result.Id := NewItemId('part');
  Result.Title := ATitle;
  Result.Status := '';
  FItems.Add(Result);
end;

procedure TStructuraProject.MoveItem(FromIndex, ToIndex: Integer);
begin
  if (FromIndex < 0) or (FromIndex >= FItems.Count) then
    Exit;
  if (ToIndex < 0) or (ToIndex >= FItems.Count) then
    Exit;
  FItems.Move(FromIndex, ToIndex);
end;

procedure TStructuraProject.DeleteItem(Index: Integer);
begin
  if (Index < 0) or (Index >= FItems.Count) then
    Exit;
  FItems.Delete(Index);
end;

function TStructuraProject.GetItem(Index: Integer): TStructuraItem;
begin
  Result := TStructuraItem(FItems[Index]);
end;

function TStructuraProject.Count: Integer;
begin
  Result := FItems.Count;
end;

function NewItemId(const Prefix: string): string;
begin
  Result := Prefix + FormatDateTime('yyyymmddhhnnsszzz', Now);
end;

function DefaultChapterStatus: string;
begin
  Result := STRUCTURA_STATUSES[0];
end;

end.
