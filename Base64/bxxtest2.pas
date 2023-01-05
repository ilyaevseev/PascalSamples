program BxxTest;

uses BxxEnDec,
     base64,
     SysUtils;  {** StrToInt **}

type Converter   = function(const s:     string):     string;
type CheckerFunc = function(const s: AnsiString): AnsiString;

const NumErrors: integer = 0;

procedure Check(numbits: integer; const a: string; encoder, decoder: Converter; checker: CheckerFunc);
var b, c, d: string;
begin
    b := encoder(a);
    c := decoder(b);

    if checker = nil
        then d := b
        else d := checker(a);  {** function from standard library **}

    if (a = c) and (b = d) then Exit;
    inc(NumErrors);
    writeln('FAILURE/', numbits, ', out = "',b,'", std = "',d,'"');
end;

procedure CheckAll(const a: string);
begin
    Check(16, a, @Base16encode, @Base16decode, nil);
    Check(32, a, @Base32encode, @Base32decode, nil);
    Check(64, a, @Base64encode, @Base64decode, @EncodeStringBase64);
end;

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
                for k:=1 to Len do s[k] := char(random(256));
                CheckAll(s);
            end;
        end;
    end else for n:=1 to ParamCount do CheckAll(ParamStr(n));

    if NumErrors = 0 then writeln('ALL OK');
end.
