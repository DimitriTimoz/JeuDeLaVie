unit structures;

interface

uses utils, logSys, crt, sysutils;

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
    
    
implementation

end.
