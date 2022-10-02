unit Moteur;

interface
uses structures, utils;

procedure initialisation(var jeu: TJeu);
procedure ajouterCellule(var plateau: TPlateau; x, y: integer);
procedure supprimerCellule(var plateau: TPlateau; x, y: integer);

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
    jeu.plateau.tailleParcelle := 16;
    for i := 1 to jeu.plateau.tailleParcelle do
    begin
        jeu.plateau.parcelles[0].lignes[i] := 0;
    end;

    jeu.plateau.hauteur := 1;
    jeu.plateau.largeur := 1;

    jeu.tour := 0;
end;


procedure ajouterCellule(var plateau: TPlateau; x, y: integer);
begin
    SetBit(plateau.parcelles[0].lignes[y+1], x);
end;

procedure supprimerCellule(var plateau: TPlateau; x, y: integer);
begin
    ClearBit(plateau.parcelles[0].lignes[y+1], x);
end;


end.

