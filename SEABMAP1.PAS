program SeaBattle_GenerateMap;

uses SEABMAP;

var
  map: MapType;

begin
  if not FillMap(map) then Writeln('ERROR: FillMap');
  PrintMap(map);
end.
