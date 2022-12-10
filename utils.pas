unit utils;

interface
    procedure ClearBit(var Value: Int64; Index: Byte);
    procedure SetBit(var Value: Int64; Index: Byte);
    procedure PutBit(var Value: Int64; Index: Byte; State: Boolean);
    function GetBit(Value: Int64; Index: Byte): Boolean;
    function negmod(x, m: Integer): Integer;
implementation

    procedure ClearBit(var Value: Int64; Index: Byte);
    begin
        Value := Value and ((Int64(1) shl Index) xor High(Int64));
    end;

    procedure SetBit(var Value: Int64; Index: Byte);
    begin
        Value:=  Value or (Int64(1) shl Index);
    end;

    procedure PutBit(var Value: Int64; Index: Byte; State: Boolean);
    begin
        Value := (Value and ((Int64(1) shl Index) xor High(Int64))) or (Int64(State) shl Index);
    end;

    function GetBit(Value: Int64; Index: Byte): Boolean;
    begin
        GetBit := ((Value shr Index) and 1) = 1;
    end;

    function negmod(x, m: Integer): Integer;
    begin
        if x < 0 then
            negmod := x mod m + m
        else
            negmod := x mod m;
    end;

end.
