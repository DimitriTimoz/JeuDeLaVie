unit structures;

interface

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
        lignes : array[1..64] of QWord (* 64 bits *);
    end; 
    TPlateau = record
        parcelles : ^TParcelle;
        tmpParcelles : array[1..9] of TParcelle;
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