Unit partie;

interface

uses structures, Moteur, UInterface, crt;

procedure initialisation(var jeu: TJeu);

implementation

    procedure initialisation(var jeu: TJeu);
    var
        i: integer;
    begin
        (* Créer une parcelle en mémoire *)
        TextBackground(White);
        TextColor(0);

        GetMem(jeu.plateau.parcelles, SizeOf(TParcelle));

        jeu.plateau.parcelles[0].px := 0;
        jeu.plateau.parcelles[0].py := 0;

        (* Initialise une parcelle vide *)
        jeu.plateau.tailleParcelle := 16;
        for i := 0 to jeu.plateau.tailleParcelle - 1 do
        begin
            jeu.plateau.parcelles[0].lignes[i] := 0;
        end;

        jeu.plateau.hauteur := 1;
        jeu.plateau.largeur := 1;

        jeu.tour := 0;

        menuAction(jeu);
    end;

end.
