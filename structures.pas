unit structures;

interface

uses utils;

const LARGEUR_CAM = 32; // Doit être paire
const HAUTEUR_CAM = 32; // Doit être paire
const TAILLE_PARCELLE = 64; // Doit <= 64
type
    TCamera = record
        px, py : integer;
        hauteur, largeur : integer;
    end;
    PQword = ^Qword;
    PPQword =^PQword;
    TPaterne = record
        tx, ty : integer;
        tableau : PPQword;
        n : integer;
    end;
    TVoisin = record
        px, py : integer;
        index : integer;
        existe : boolean;
    end;
    TParcelle = object
        public
            x, y : integer;
            lignes : array[0..63] of QWord (* 64 bits *);
            voisins : array[0..7] of TVoisin;
            constructor init(nx, ny: integer; n_voisins: array of TVoisin);
            function obtenir_cellule(px, py: integer): Boolean;
            procedure definir_cellule(px, py: integer; valeur: Boolean);
    end; 
    TPlateau = record
        parcelles : array of TParcelle;
        tmpParcelles : array[0..8] of TParcelle;
        cx, cy : integer;
        tailleParcelle : integer;
        largeur, hauteur : integer;
    end;
    TJeu = record
        plateau : TPlateau;
        camera : TCamera;
        paterne : TPaterne;
        vitesse: integer;
        tour : integer;
        enCours : boolean;
    end;

implementation

constructor TParcelle.init(nx, ny: integer; n_voisins: array of TVoisin);
var
    i : integer;
begin
    // Initialisation des coordonnées
    x := nx;
    y := ny;
    // Initialisation des cases
    for i := 0 to TAILLE_PARCELLE - 1 do
        lignes[i] := 0;

    // Initialisation des voisins
    for i := 0 to 7 do
        voisins[i] := n_voisins[i];

end;

function TParcelle.obtenir_cellule(px, py: integer): Boolean;
begin
    obtenir_cellule := GetBit(lignes[py], px)
end;

procedure TParcelle.definir_cellule(px, py: integer; valeur: Boolean);
begin
    if valeur then
        SetBit(lignes[py], px)
    else
        ClearBit(lignes[py], px);
end;

end.
