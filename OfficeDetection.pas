unit OfficeDetection;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TOfficeTargets = record
    WordPath: string;
    LibreOfficePath: string;
    TextMakerPath: string;
  end;

function DetectOfficeTargets: TOfficeTargets;
function FindExecutableInCommonPlaces(const Names: array of string; const Paths: array of string): string;

implementation

uses
  FileUtil;

function FindExecutableInCommonPlaces(const Names: array of string; const Paths: array of string): string;
var
  Name: string;
  PathCandidate: string;
  I: Integer;
begin
  for Name in Names do
  begin
    Result := FindDefaultExecutablePath(Name);
    if Result <> '' then
      Exit;
  end;
  for I := Low(Paths) to High(Paths) do
  begin
    PathCandidate := Paths[I];
    if (PathCandidate <> '') and FileExists(PathCandidate) then
      Exit(PathCandidate);
  end;
  Result := '';
end;

function DetectOfficeTargets: TOfficeTargets;
begin
  Result.WordPath := FindExecutableInCommonPlaces(
    ['winword', 'winword.exe'],
    [IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES')) + 'Microsoft Office\root\Office16\WINWORD.EXE',
     IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES(X86)')) + 'Microsoft Office\root\Office16\WINWORD.EXE']
  );
  Result.LibreOfficePath := FindExecutableInCommonPlaces(
    ['soffice', 'libreoffice', 'soffice.exe'],
    [IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES')) + 'LibreOffice\program\soffice.exe',
     IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES(X86)')) + 'LibreOffice\program\soffice.exe']
  );
  Result.TextMakerPath := FindExecutableInCommonPlaces(
    ['TextMaker', 'TextMaker.exe', 'textmaker'],
    [IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES')) + 'SoftMaker Office NX\TextMaker.exe',
     IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES')) + 'SoftMaker Office 2024\TextMaker.exe',
     IncludeTrailingPathDelimiter(GetEnvironmentVariable('PROGRAMFILES(X86)')) + 'SoftMaker Office NX\TextMaker.exe']
  );
end;

end.
