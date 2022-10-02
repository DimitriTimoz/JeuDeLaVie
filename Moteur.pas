unit Moteur;

interface
uses structures, utils;

procedure initialisation(var jeu: TJeu);

implementation

procedure initialisation(var jeu: TJeu);
var
    i: integer;
begin
    
    GetMem(jeu.plateau.parcelles, SizeOf(TParcelle));

    jeu.plateau.parcelles[0].px := 0;
    jeu.plateau.parcelles[0].py := 0;

    (* Initialise une parcelle vide *)

    jeu.plateau.tailleParcelle := 16;
    for i := 1 to jeu.plateau.tailleParcelle do
    begin
        jeu.plateau.parcelles[0].lignes[i] := 0;
    end;

    jeu.plateau.hauteur := 1;
    jeu.plateau.largeur := 1;
end;
end.

