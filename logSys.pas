Unit logSys;

interface
    procedure log( s : string );
    procedure clearLog();

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

    procedure clearLog();
    var 
        f : text;
    begin
        assign( f, 'log.txt' );
        rewrite( f );
        close( f );
    end;


end.