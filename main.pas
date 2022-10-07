program main;

uses Moteur, UInterface, structures, partie, crt;

var 
    jeu: TJeu;

begin
    initialisation(jeu);
    repeat
        jeu.tour := jeu.tour + 1;
        simuler(jeu.plateau);
        Delay(100);
        afficher(jeu);
    until (False);
end.