program SeaBattle_GenerateMap;

const
  MapSize     = 10;
  MaxShipLen  = 4;
  ShipsCount  : array[1..MaxShipLen] of integer = (4, 3, 2, 1);
  Verbose     = False;
  VerboseFile = 'seabmap.log';

var
  VerboseOut : Text;

type
  MapType = array[1..MapSize, 1..MapSize] of integer;

procedure VerboseInit;
begin
  if not Verbose then Exit;
  Assign(VerboseOut, VerboseFile);
  Rewrite(VerboseOut);
end;


procedure ClearMap(var Map: MapType);
var
  x, y: integer;
begin
  for x := 1 to MapSize do
    for y := 1 to MapSize do
      Map[x,y] := 0;
end;

procedure GetRandomPos(var X, Y: integer);
begin
  X := 1 + Random(MapSize);
  Y := 1 + Random(MapSize);
  { if Verbose then Writeln(VerboseOut, 'GetRandomPos: X = ', X, ' Y = ', Y); }
end;

function PrevPos(var X, Y: integer) : boolean;
begin
  PrevPos := true;
  if (X = 1) and (Y = 1) then
    PrevPos := false
  else if X > 1 then
    Dec(X)
  else begin
    Dec(Y);
    X := MapSize;
  end;
end;

function NextPos(var X, Y: integer) : boolean;
begin
  NextPos := true;
  if (X = MapSize) and (Y = MapSize) then
    NextPos := false
  else if X < MapSize then
    Inc(X)
  else begin
    Inc(Y);
    X := 1;
  end;
end;

function AlreadyUsed1(var Map: MapType; X, Y: integer) : boolean;
begin
  { if Verbose then Writeln(VerboseOut, 'AU1/Check: X = ', X, ' Y = ', Y); }
  AlreadyUsed1 := True;
  if (X < 1) or (X > MapSize) then Exit;
  if (Y < 1) or (Y > MapSize) then Exit;
  if Map[X, Y] > 0 then Exit;
  AlreadyUsed1 := False;
  { if Verbose then Writeln(VerboseOut, 'AU1/False: X = ', X, ' Y = ', Y); }
end;

function AlreadyUsed(var Map: MapType; X0, Y0: integer) : boolean;
var
  X, Y: integer;
begin
  if Verbose then Writeln(VerboseOut, 'AU/Check: X = ', X0, ' Y = ', Y0);
  AlreadyUsed := True;
  for X := (X0 - 1) to (X0 + 1) do
    for Y := (Y0 - 1) to (Y0 + 1) do
      if AlreadyUsed1(Map, X, Y) then Exit;
  AlreadyUsed := False;
  if Verbose then Writeln(VerboseOut, 'AU/False: X = ', X0, ' Y = ', Y0);
end;

function TryCells(var Map: MapType; X0, Y0, ShipLen, ShipID, DX, DY: integer): boolean;
var
  X, Y, N: integer;
begin
  TryCells := False;
  if Verbose then Writeln(VerboseOut,
      'TryCell: X = ', X0, ' Y = ', Y0, ' DX = ', DX, ' DY = ', DY);
  X := X0;
  Y := Y0;
  for N := 1 to ShipLen do
  begin
    if AlreadyUsed(Map, X, Y) then Exit;
    Inc(X, DX);
    Inc(Y, DY);
  end;

  TryCells := True;
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
begin
  TryShip := True;
  if Verbose then Writeln(VerboseOut,
      'TryShip: Len = ', ShipLen, ' ID = ', ShipID, ' X = ', X, ' Y = ',Y);
  { TODO: randomize dx/dy order! }
  if TryCells(Map, X, Y, ShipLen, ShipID,  1,  0) then Exit;
  if TryCells(Map, X, Y, ShipLen, ShipID, -1,  0) then Exit;
  if TryCells(Map, X, Y, ShipLen, ShipID,  0,  1) then Exit;
  if TryCells(Map, X, Y, ShipLen, ShipID,  0, -1) then Exit;
  if Verbose then Writeln(VerboseOut, 'TryShip: False');
  TryShip := False;
end;

function NewShip(var Map: MapType; ShipLen, ShipID: integer) : boolean;
var
  X0, Y0, X, Y: integer;
begin
  NewShip := True;
  GetRandomPos(X0, Y0);
  if Verbose then Writeln(VerboseOut,
      'NewShip: Len = ', ShipLen, ' ID = ', ShipID, ' X = ', X0, ' Y = ', Y0);
  X := X0;  Y := Y0;  repeat if TryShip(Map, X, Y, ShipLen, ShipID) then Exit;  until not NextPos(X, Y);
  X := X0;  Y := Y0;  repeat if TryShip(Map, X, Y, ShipLen, ShipID) then Exit;  until not PrevPos(X, Y);
  NewShip := False;
end;

function FillMap(var Map: MapType) : boolean;
var
  Len, Current, n: integer;
begin
  FillMap := False;
  Current := 0;
  for Len := MaxShipLen downto 1 do
  begin
    for n := 1 to ShipsCount[len] do
    begin
      if not NewShip(Map, Len, Current+1) then Exit;
      inc(Current);
    end;
  end;
  FillMap := True;
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
    WriteLN;
  end;
end;

var
  map: MapType;

begin
  VerboseInit;
  Randomize;
  FillChar(Map, Sizeof(Map), 0);  { ClearMap(map); }
  if not FillMap(map) then Writeln('ERROR: FillMap');
  PrintMap(map);
  if Verbose then Close(VerboseOut);
end.

