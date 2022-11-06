unit BxxEnDec;

{$IFDEF FPC}
{$MODE OBJFPC}
{$ENDIF}

interface

function Base16encode(const S: string): string;
function Base16decode(const S: string): string;

function Base32encode(const S: string): string;
function Base32decode(const S: string): string;

function Base64encode(const S: string): string;
function Base64decode(const S: string): string;

implementation

const
   PaddingChar = '=';
   BitsPerByte = 8;
   HighBitMask = $80;  {** $80 hex = 128 decimal = 10000000 binary **}
   LowByteMask = $FF;  {** $FF hex = 255 decimal = 11111111 binary **}

   Base16dict = '0123456789ABCDEF';
   Base32dict = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + '23456789';
   Base64dict = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789' + '+/';

function Encode(const InData, Dictionary: string; OutBits: integer): string;
var
    InLen, InPos, InBit, InByte, OutBit, OutByte, OutPos, MaxPadLen: word;
begin
    Result  := '';
    InLen   := Length(InData);
    OutByte := 0;
    OutBit  := 0;
    OutPos  := 0;
    MaxPadLen := 1;

    while ((MaxPadLen * OutBits) mod BitsPerByte) > 0 do inc(MaxPadLen);

    for InPos := 1 to InLen do
    begin
        InByte := word(InData[InPos]);

        for InBit:=1 to BitsPerByte do
        begin
            {** shl = "shift bits to left" = multiply by 2 **}
            OutByte := OutByte shl 1;

            {** Copy high bit from InByte to low bit of OutByte: **}
            if (InByte and HighBitMask) > 0 then inc(OutByte);

            {** multiply and strip all except first byte **}
            InByte := ((InByte shl 1) and LowByteMask);

            inc(OutBit);
            if OutBit >= OutBits then
            begin
                Result  := Result + Dictionary[OutByte + 1];
                OutBit  := 0;
                OutByte := 0;
                inc(OutPos);
            end;
        end;
    end;

    if (OutBit > 0) and (OutBit < OutBits) then
    begin
        OutByte := OutByte shl (OutBits - OutBit);
        Result := Result + Dictionary[OutByte + 1];
        inc(OutPos);
    end;

    while (OutPos mod MaxPadLen) > 0 do
    begin
        Result := Result + PaddingChar;
        inc(OutPos);
    end;
end;

function Decode(const InData, Dictionary: string; InBits: integer): string;
var
    InPos, InLen, InBit, InByte, OutBit, OutByte, InBitmask: word;
begin
    Result  := '';
    InLen   := Length(InData);
    OutBit  := 0;
    OutByte := 0;

    {** Like HighBitMask, but for shorten values: **}
    InBitmask := (1 shl (InBits - 1));

    {** Strip padding chars: **}
    while (InLen > 0) and (InData[InLen] = '=') do Dec(InLen);

    for InPos := 1 to InLen do
    begin
        InByte := pos(InData[InPos], Dictionary);
        if InByte = 0 then Exit;  {** ERROR **}
        dec(InByte);

        for InBit := 1 to InBits do
        begin
            OutByte := OutByte shl 1;
            if (InByte and InBitMask) > 0 then inc(OutByte);
            InByte  := InByte  shl 1;
            inc(OutBit);
            if OutBit >= BitsPerByte then
            begin
                Result  := Result + char(OutByte);
                OutBit  := 0;
                OutByte := 0;
            end;
        end;
    end;
end;

function Base16encode(const S: string): string; begin Result := Encode(S, Base16dict, 4); end;
function Base16decode(const S: string): string; begin Result := Decode(S, Base16dict, 4); end;
function Base32encode(const S: string): string; begin Result := Encode(S, Base32dict, 5); end;
function Base32decode(const S: string): string; begin Result := Decode(S, Base32dict, 5); end;
function Base64encode(const S: string): string; begin Result := Encode(S, Base64dict, 6); end;
function Base64decode(const S: string): string; begin Result := Decode(S, Base64dict, 6); end;

begin
end.
