program BxxTest;

uses BxxEnDec,
     Process,   {** RunCommand **}
     SysUtils;  {** IntToStr **}

type Converter = function(const s: string): string;

procedure Check(numbits: integer; const a: string; encoder, decoder: Converter);
var b, c, d, external_program: string;
    external_result: AnsiString;
begin
    b := encoder(a);
    c := decoder(b);

    external_program := 'base' + IntToStr(numbits);
    RunCommand('/bin/sh -c "echo -n ' + a + ' | ' + external_program + '"', external_result);
    d := TrimRight(external_result);

    if (a = c) and (b = d)
       then writeln('success/', numbits, ': in = "',a,'", out = "',b,'"')
       else writeln('FAILURE/', numbits, ': in = "',a,'", out = "',b, '", ext = "',d,'", dec = "', c, '"');
end;

procedure CheckAll(const a: string);
begin
{** Check(16, a, @Base16encode, @Base16decode); **}
    Check(32, a, @Base32encode, @Base32decode);
    Check(64, a, @Base64encode, @Base64decode);
end;

const random_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789' + '_=+-/';

var n, k, numchecks, len, maxlen : integer;
    s: string;

begin
    if ParamCount < 1 then begin
        writeln('Usage: ',ParamStr(0),' str1 ...');
        exit;
    end;

    if (ParamCount = 3) and (ParamStr(1) = 'random') then
    begin
        NumChecks := StrToInt(ParamStr(2));
        MaxLen    := StrToInt(ParamStr(3));
        Randomize;  {** ..initialize random generator **}
        for Len:=1 to MaxLen do
        begin
            for n:=1 to NumChecks do
            begin
                SetLength(s, Len);
                for k:=1 to Len do s[k] := random_chars[1 + random(length(random_chars))];
                CheckAll(s);
            end;
        end;
    end else for n:=1 to ParamCount do CheckAll(ParamStr(n));
end.
