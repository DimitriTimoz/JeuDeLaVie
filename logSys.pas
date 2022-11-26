Unit logSys;

interface
    procedure log( s : string );

implementation
    procedure log( s : string );
    var 
        f : text;
    begin
        assign( f, 'log.txt' );
        append( f );
        writeln( f, s );
        close( f );
    end;


end.