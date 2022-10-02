unit utils;

interface
    procedure ClearBit(var Value: QWord; Index: Byte);
    procedure SetBit(var Value: QWord; Index: Byte);
    procedure PutBit(var Value: QWord; Index: Byte; State: Boolean);
    function GetBit(Value: QWord; Index: Byte): Boolean;

implementation

    procedure ClearBit(var Value: QWord; Index: Byte);
    begin
        Value := Value and ((QWord(1) shl Index) xor High(QWord));
    end;

    procedure SetBit(var Value: QWord; Index: Byte);
    begin
        Value:=  Value or (QWord(1) shl Index);
    end;

    procedure PutBit(var Value: QWord; Index: Byte; State: Boolean);
    begin
        Value := (Value and ((QWord(1) shl Index) xor High(QWord))) or (QWord(State) shl Index);
    end;

    function GetBit(Value: QWord; Index: Byte): Boolean;
    begin
        GetBit := ((Value shr Index) and 1) = 1;
    end;

end.