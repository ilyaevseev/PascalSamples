program Test_GetRandomPos;

{$IFDEF FPC}
{$MODE OBJFPC}   { ..perform typecast in old-manner style }
{$ENDIF}

uses seabmap;

const NumTests = 1000000;

var
    n, x, y, errcount, min, max, med : integer;
    stats : array[1..MapSize, 1..MapSize] of integer;

begin
    errcount := 0;
    FillChar(stats, sizeof(stats), 0);
    for n := 1 to NumTests do
    begin
        x := 0;
        y := 0;
        GetRandomPos(x, y, 1);
        if (x < 1) or (x > MapSize) or (y < 1) or (y > MapSize)
            then Writeln('Error on iteration ',n,': x = ',x,', y = ',y)
            else inc(stats[x,y]);
    end;

    min := NumTests;
    max := 0;
    med := 0;

    for x := 1 to MapSize do
        for y := 1 to MapSize do
        begin
            if min > stats[x,y] then min := stats[x,y];
            if max < stats[x,y] then max := stats[x,y];
        end;

    { TODO: calculate median! }

    Writeln('Total ',numtests,' tests, ',errcount,' errors.');
    Writeln('Min = ',min,', Max = ',max,', Median = ',med);
end.
