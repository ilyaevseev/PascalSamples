program SeaBattle_GenerateMap;

uses seabmap;

var
  map: MapType;

begin
  if not FillMap(map) then Writeln('ERROR: FillMap');
  PrintMap(map);
end.
