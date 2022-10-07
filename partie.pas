Unit partie;

interface

uses structures, Moteur, UInterface;

procedure initialisation(var jeu: TJeu);

implementation

    procedure initialisation(var jeu: TJeu);
    var
        i: integer;
    begin
        (* Créer une parcelle en mémoire *)
        GetMem(jeu.plateau.parcelles, SizeOf(TParcelle));

        jeu.plateau.parcelles[0].px := 0;
        jeu.plateau.parcelles[0].py := 0;

        (* Initialise une parcelle vide *)
        jeu.plateau.tailleParcelle := 32;
        for i := 0 to jeu.plateau.tailleParcelle do
        begin
            jeu.plateau.parcelles[0].lignes[i] := 0;
        end;

        jeu.plateau.hauteur := 1;
        jeu.plateau.largeur := 1;

        jeu.tour := 0;

        afficherMenu(jeu);
    end;

end.