program tests;


var 
    i: integer;
    n : integer;
begin
    n := 10;
    for i := 1 to n do
    begin
        n := n + 1;
        writeln(n);
    end;
end.
