program main;

uses structures, crt, jeu;

var 
    partie: TJeu;

begin
    partie.init();
    repeat
        partie.miseAJour();
    until (partie.tour > 20);
end.
