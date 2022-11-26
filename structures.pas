unit structures;

interface

const LARGEUR_CAM = 32; // Doit être paire
const HAUTEUR_CAM = 32; // Doit être paire

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
    TParcelle = record
        px, py : integer;
        lignes : array[0..63] of QWord (* 64 bits *);
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

end.
