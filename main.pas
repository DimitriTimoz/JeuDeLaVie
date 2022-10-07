program main;

uses Moteur, UInterface, structures, partie;

var 
    jeu: TJeu;

begin
    initialisation(jeu);
    repeat
        simuler(jeu.plateau);
        afficher(jeu);
    until (False);
end.