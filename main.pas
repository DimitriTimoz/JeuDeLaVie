program main;

uses structures, crt, jeu, logSys;

var 
    partie: TJeu;
    paterne: TPaterne;
begin
    clearLog();
    paterne.charger('paternes/repetive.save');
    partie.init();
    repeat
        partie.miseAJour();
    until not (partie.enCours);
end.
