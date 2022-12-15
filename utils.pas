unit utils;

interface
    procedure ClearBit(var Value: Int64; Index: Byte);
    procedure SetBit(var Value: Int64; Index: Byte);
    function GetBit(Value: Int64; Index: Byte): Boolean;
    function negmod(x, m: Int32): Int32;
    function estNombre(entree: String): Boolean;
implementation

    procedure ClearBit(var Value: Int64; Index: Byte);
    begin
        Value := Value and ((Int64(1) shl Index) xor High(Int64));
    end;

    procedure SetBit(var Value: Int64; Index: Byte);
    begin
        Value:=  Value or (Int64(1) shl Index);
    end;


    function GetBit(Value: Int64; Index: Byte): Boolean;
    begin
        GetBit := ((Value shr Index) and 1) = 1;
    end;

    function negmod(x, m: Int32): Int32;
    begin
        if x < 0 then
            negmod := x mod m + m
        else
            negmod := x mod m;
    end;

    function estNombre(entree: String): Boolean;
    var
        i: Integer;
    begin
        estNombre := True;
        for i := 1 to Length(entree) do
            if not (entree[i] in ['0'..'9']) then
            begin
                estNombre := False;
                break;
            end;
    end;
end.
