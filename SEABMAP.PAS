program SeaBattle_GenerateMap;

{$IFDEF FPC}
{$MODE OBJFPC}   { ..return value from function via Result variable }
{$ENDIF}

const
  MapSize     = 10;
  MaxShipLen  = 4;
{$IFDEF MODERNPASCAL}
  ShipsCount  : array[1..MaxShipLen] of integer = [4, 3, 2, 1];
{$ELSE}
  ShipsCount  : array[1..MaxShipLen] of integer = (4, 3, 2, 1);
{$ENDIF}

type
  MapType = array[1..MapSize] of array[1..MapSize] of integer;

procedure GetRandomPos(var X, Y: integer; ShipLen: integer);
begin
  { TODO: use ShipLen and MaxShipLen for placing big ships at borders }
  if ShipLen < 1 then Exit;
  X := 1 + Random(MapSize);
  Y := 1 + Random(MapSize);
end;

function OutOfRange(X, Y: integer) : boolean;
begin
  Result := (X < 1) or (X > MapSize)
         or (Y < 1) or (Y > MapSize);
end;

function ShiftPos(var X, Y: integer; DX: integer) : boolean;
var Pos: integer;
begin
  Pos := (Y - 1) * MapSize + (X - 1) + DX;
  X := 1 + (Pos mod MapSize);
  Y := 1 + (Pos div MapSize);
  Result := not OutOfRange(X, Y);
end;

function CellUsed(var Map: MapType; X, Y: integer) : boolean;
begin
  Result := False;
  if OutOfRange(X, Y) then Exit;
  if Map[X, Y] = 0    then Exit;
  Result := True;
end;

function RegionUsed(var Map: MapType; X0, Y0: integer) : boolean;
var
  X, Y: integer;
begin
  Result := True;
  for X := (X0 - 1) to (X0 + 1) do
    for Y := (Y0 - 1) to (Y0 + 1) do
      if CellUsed(Map, X, Y) then Exit;
  Result := False;
end;

function TryShipOriented(var Map: MapType; X0, Y0, ShipLen, ShipID, DX, DY: integer): boolean;
var
  X, Y, N: integer;
begin
  Result := False;
  if OutOfRange(X0 + DX * (ShipLen - 1),
                Y0 + DY * (ShipLen - 1)) then Exit;
  X := X0;
  Y := Y0;
  for N := 1 to ShipLen do
  begin
    if RegionUsed(Map, X, Y) then Exit;
    Inc(X, DX);
    Inc(Y, DY);
  end;

  Result := True;
  X := X0;
  Y := Y0;
  for N := 1 to ShipLen do
  begin
    Map[X, Y] := ShipID;
    Inc(X, DX);
    Inc(Y, DY);
  end;
end;

function TryShip(var Map: MapType; X, Y, ShipLen, ShipID: integer): boolean;
var
  n, r: integer;
begin
  Result := True;
  r := random(2);  { 0 or 1 = prefer horizontal or vertical }
  for n := 1 to 2 do
  begin
    if ((n + r) mod 2) > 0 then
    begin
      if TryShipOriented(Map, X, Y, ShipLen, ShipID,  1,  0) then Exit;
      if TryShipOriented(Map, X, Y, ShipLen, ShipID, -1,  0) then Exit;
    end else begin
      if TryShipOriented(Map, X, Y, ShipLen, ShipID,  0,  1) then Exit;
      if TryShipOriented(Map, X, Y, ShipLen, ShipID,  0, -1) then Exit;
    end;
  end;
  Result := False;
end;

function NewShip(var Map: MapType; ShipLen, ShipID: integer) : boolean;
var
  X1, Y1, X2, Y2, Direction: integer;
begin
  Result := True;
  GetRandomPos(X1, Y1, ShipLen);
  if Random(2) > 0 then Direction:=1 else Direction:=-1;
  X2 := X1;
  Y2 := Y1;
  repeat if TryShip(Map, X1, Y1, ShipLen, ShipID) then Exit; until not ShiftPos(X1, Y1,  Direction);
  repeat if TryShip(Map, X2, Y2, ShipLen, ShipID) then Exit; until not ShiftPos(X2, Y2, -Direction);
  Result := False;
end;

function FillMap(var Map: MapType) : boolean;
var
  Len, Current, n: integer;
begin
  Result  := False;
  Current := 0;
  FillChar(Map, Sizeof(Map), #0);
  for Len := MaxShipLen downto 1 do
  begin
    for n := 1 to ShipsCount[len] do
    begin
      if not NewShip(Map, Len, Current+1) then Exit;
      inc(Current);
    end;
  end;
  Result := True;
end;

procedure PrintMap(var Map: MapType);
var
  X, Y: integer;
begin
  for Y := 1 to MapSize do
  begin
    for X := 1 to MapSize do
    begin
      if Map[X, Y] > 0 then Write(Map[X,Y] mod 10) else Write('.');
    end;
    WriteLN('');
  end;
end;

var
  map: MapType;

begin
  Randomize;
  if not FillMap(map) then Writeln('ERROR: FillMap');
  PrintMap(map);
end.
