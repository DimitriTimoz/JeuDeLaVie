Unit partie;

interface

uses structures, Moteur, UInterface, crt;

procedure initialisation(var jeu: TJeu);

implementation

    procedure initialisation(var jeu: TJeu);
    var
        i: integer;
        voisins: array[0..7] of TVoisin;
    begin
        (* Créer une parcelle en mémoire *)
        TextBackground(White);
        TextColor(0);
        setLength(jeu.plateau.parcelles, 1);

        jeu.plateau.parcelles[0].init(0, 0, voisins);

        (* Initialise une parcelle vide *)
        jeu.plateau.tailleParcelle := 64;
        for i := 0 to jeu.plateau.tailleParcelle - 1 do
        begin
            jeu.plateau.parcelles[0].lignes[i] := 0;
        end;

        jeu.plateau.hauteur := 1;
        jeu.plateau.largeur := 1;
        
        jeu.camera.px := -LARGEUR_CAM div 2;
        jeu.camera.py := -HAUTEUR_CAM div 2;
        jeu.camera.hauteur := HAUTEUR_CAM;
        jeu.camera.largeur := LARGEUR_CAM;

        jeu.tour := 0;

        menuAction(jeu);
    end;

end.
