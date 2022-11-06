program BxxTest;

uses BxxEnDec;

type Converter = function(const s: string): string;

procedure Check(numbits: integer; const a: string; encoder, decoder: Converter);
var b, c: string;
begin
    b := encoder(a);
    c := decoder(b);
    if a = c
       then writeln('success/', numbits, ': in = "',a,'", out = "',b,'"')
       else writeln('FAILURE/', numbits, ': in = "',a,'", out = "',b,'", dec = "', c, '"');
end;

procedure TestBase16(const a: string); begin Check(16, a, @Base16encode, @Base16decode); end;
procedure TestBase32(const a: string); begin Check(32, a, @Base32encode, @Base32decode); end;
procedure TestBase64(const a: string); begin Check(64, a, @Base64encode, @Base64decode); end;

var n : integer;

begin
    if ParamCount < 1 then begin
        writeln('Usage: ',ParamStr(0),' str1 ...');
        exit;
    end;
    for n:=1 to ParamCount do
    begin
//      TestBase16(ParamStr(n));
        TestBase32(ParamStr(n));
        TestBase64(ParamStr(n));
    end;
end.
