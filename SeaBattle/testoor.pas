program Test_OutOfRange;

{$IFDEF FPC}
{$MODE OBJFPC}   { Result variable }
{$ENDIF}

uses seabmap;

function Test(x, y: integer; retval: boolean) : boolean;
begin
    Result := True;
    if OutOfRange(x, y) = retval then Exit;
    Result := False;
    Writeln('Failed: x = ',x,', y = ',y,', should be ',retval);
end;

begin
    if true { .."true" is used here simply for nice identation }
        and Test(1, 1, False)
        and Test(MapSize, MapSize, False)
        and Test(round(MapSize / 2), round(MapSize / 2), False)
        and Test(1, -1, True)
        and Test(-1, 1, True)
        and Test(1, MapSize + 1, True)
        and Test(MapSize + 1, -1, True)
      { and Test(1,1,True)    }  { ..cause false positive }
      { and Test(-1,-1,False) }  { ..cause false positive }
    then Writeln('All ok.');
end.
