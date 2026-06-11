unit MarkdownPreview;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

// Bewusst kleiner Markdown-Konverter für die Notizvorschau.
// Unterstützt: Überschriften (#, ##, ###), Listen (-, *), Checklisten
// (- [ ] / - [x]), **fett**, *kursiv*, `Code`, Codeblöcke (```),
// Absätze und Trennlinien (---). Alles andere wird als Text gezeigt.
function MarkdownToHtml(const AMarkdown: string): string;

implementation

uses
  Classes, SysUtils, StrUtils;

function EscapeHtml(const S: string): string;
begin
  Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;

// Inline-Auszeichnungen: **fett**, *kursiv*, `code`
function InlineMarkup(const S: string): string;

  function ReplacePairs(const AText, AMarker, AOpenTag, ACloseTag: string): string;
  var
    StartPos, EndPos: Integer;
    MarkerLen: Integer;
  begin
    Result := AText;
    MarkerLen := Length(AMarker);
    StartPos := Pos(AMarker, Result);
    while StartPos > 0 do
    begin
      EndPos := PosEx(AMarker, Result, StartPos + MarkerLen);
      if EndPos = 0 then
        Break;
      Result := Copy(Result, 1, StartPos - 1) + AOpenTag +
        Copy(Result, StartPos + MarkerLen, EndPos - StartPos - MarkerLen) +
        ACloseTag + Copy(Result, EndPos + MarkerLen, MaxInt);
      StartPos := Pos(AMarker, Result);
    end;
  end;

begin
  Result := ReplacePairs(S, '**', '<b>', '</b>');
  Result := ReplacePairs(Result, '`', '<tt>', '</tt>');
  Result := ReplacePairs(Result, '*', '<i>', '</i>');
end;

function MarkdownToHtml(const AMarkdown: string): string;
var
  Lines: TStringList;
  Html: TStringList;
  I: Integer;
  Line, Trimmed: string;
  InList, InCode: Boolean;

  procedure CloseList;
  begin
    if InList then
    begin
      Html.Add('</ul>');
      InList := False;
    end;
  end;

begin
  Lines := TStringList.Create;
  Html := TStringList.Create;
  try
    Lines.Text := AMarkdown;
    Html.Add('<html><body>');
    InList := False;
    InCode := False;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      Trimmed := Trim(Line);

      // Codeblöcke beginnen/beenden
      if AnsiStartsStr('```', Trimmed) then
      begin
        CloseList;
        if InCode then
          Html.Add('</pre>')
        else
          Html.Add('<pre>');
        InCode := not InCode;
        Continue;
      end;
      if InCode then
      begin
        Html.Add(EscapeHtml(Line));
        Continue;
      end;

      if Trimmed = '' then
      begin
        CloseList;
        Continue;
      end;

      if (Trimmed = '---') or (Trimmed = '***') then
      begin
        CloseList;
        Html.Add('<hr>');
        Continue;
      end;

      if AnsiStartsStr('### ', Trimmed) then
      begin
        CloseList;
        Html.Add('<h3>' + InlineMarkup(EscapeHtml(Copy(Trimmed, 5, MaxInt))) + '</h3>');
        Continue;
      end;
      if AnsiStartsStr('## ', Trimmed) then
      begin
        CloseList;
        Html.Add('<h2>' + InlineMarkup(EscapeHtml(Copy(Trimmed, 4, MaxInt))) + '</h2>');
        Continue;
      end;
      if AnsiStartsStr('# ', Trimmed) then
      begin
        CloseList;
        Html.Add('<h1>' + InlineMarkup(EscapeHtml(Copy(Trimmed, 3, MaxInt))) + '</h1>');
        Continue;
      end;

      // Checklisten vor normalen Listen prüfen
      if AnsiStartsStr('- [ ]', Trimmed) or AnsiStartsStr('* [ ]', Trimmed) then
      begin
        if not InList then
        begin
          Html.Add('<ul>');
          InList := True;
        end;
        Html.Add('<li>&#9744; ' + InlineMarkup(EscapeHtml(Trim(Copy(Trimmed, 6, MaxInt)))) + '</li>');
        Continue;
      end;
      if AnsiStartsStr('- [x]', Trimmed) or AnsiStartsStr('* [x]', Trimmed) or
         AnsiStartsStr('- [X]', Trimmed) or AnsiStartsStr('* [X]', Trimmed) then
      begin
        if not InList then
        begin
          Html.Add('<ul>');
          InList := True;
        end;
        Html.Add('<li>&#9745; ' + InlineMarkup(EscapeHtml(Trim(Copy(Trimmed, 6, MaxInt)))) + '</li>');
        Continue;
      end;
      if AnsiStartsStr('- ', Trimmed) or AnsiStartsStr('* ', Trimmed) then
      begin
        if not InList then
        begin
          Html.Add('<ul>');
          InList := True;
        end;
        Html.Add('<li>' + InlineMarkup(EscapeHtml(Copy(Trimmed, 3, MaxInt))) + '</li>');
        Continue;
      end;

      CloseList;
      Html.Add('<p>' + InlineMarkup(EscapeHtml(Trimmed)) + '</p>');
    end;

    CloseList;
    if InCode then
      Html.Add('</pre>');
    Html.Add('</body></html>');
    Result := Html.Text;
  finally
    Html.Free;
    Lines.Free;
  end;
end;

end.
