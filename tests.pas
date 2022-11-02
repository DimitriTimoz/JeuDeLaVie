program tests;

uses Moteur, UInterface, structures;

var 
    jeu: TJeu;

begin
    initialisation(jeu);
    modifierPlateau(jeu);
    afficher(jeu);
end.
