program main;

uses Moteur, UInterface, structures;

var 
    jeu: TJeu;

begin
    initialisation(jeu);
    modifierPlateau(jeu);
    affichage(jeu);
end.