program main;

uses structures, crt, jeu;

var 
    partie: TJeu;

begin
    partie.init();
    repeat
        partie.miseAJour();
        delay(50);
    until (partie.tour > 20);
end.
