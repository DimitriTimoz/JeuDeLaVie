program main;

uses structures, crt, jeu, logSys;

var 
    partie: TJeu;
    paterne: TPaterne;
begin
    clearLog();
    partie.init();
    repeat
        partie.miseAJour();
    until False;
end.
