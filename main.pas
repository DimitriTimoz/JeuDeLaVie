program main;

uses structures, crt, jeu;

var 
    partie: TJeu;

begin
    partie.init();
    repeat
        partie.tour := partie.tour + 1;
        partie.plateau.simuler();
        partie.afficher();
        Delay(300);
    until (partie.tour > 5);
end.
