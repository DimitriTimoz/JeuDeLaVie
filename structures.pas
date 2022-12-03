unit structures;

interface

uses utils, logSys, crt, sysutils, math;

const LARGEUR_CAM = 32; // Doit être paire
const HAUTEUR_CAM = 32; // Doit être paire
const TAILLE_PARCELLE = 64; // Doit <= 64
type
    TZone = array[0..2] of array[0..2] of boolean;
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
    TVoisin = object
        public
            x, y : integer;
            index : integer;
            existe : boolean;
            constructor init(px, py, ind : integer);
    end;
    TVoisins = object
        public
            voisins : array[0..7] of TVoisin;
            procedure init(px, py : integer);
            procedure ajouter(px, py, ind : integer);
            procedure supprimer(px, py : integer);
            function indexVoisin(var existe: boolean; px, py : integer) : integer;
    end;

        function estVoisin(px, py, p2x, p2y : integer) : boolean;
    
    
implementation

    constructor TVoisin.init(px, py, ind : integer);
    begin
        self.x := px;
        self.y := py;
        self.index := ind;
        self.existe := false;
    end;

    function estVoisin(px, py, p2x, p2y : integer) : boolean;
    begin
        estVoisin := intpower(px - p2x, 2) + intpower(py - p2y, 2) <= intpower(TAILLE_PARCELLE, 2);
    end;

    procedure TVoisins.init(px, py : integer);
    var
        x, y, i: integer;
    begin
        i := 0;
        for x := px - 1 to px + 1 do
        begin
            for y := py - 1 to py + 1 do
                if (x = px) and (y = py) then
                    continue
                else
                begin
                    self.voisins[i].init(x, y, 0);
                    i := i + 1;
                end;
        end;
    end;

    procedure TVoisins.ajouter(px, py, ind : integer);
    var 
        i : integer;
    begin
        for i := 0 to 7 do
        begin
            if (self.voisins[i].x = px) and (self.voisins[i].y = py) then
            begin
                self.voisins[i].existe := true;
                self.voisins[i].index := ind;
                break;
            end;
        end;
    end;

    procedure TVoisins.supprimer(px, py : integer);
    var 
        i : integer;
    begin
        for i := 0 to 7 do
        begin
            if (self.voisins[i].x = px) and (self.voisins[i].y = py) then
            begin
                self.voisins[i].existe := false;
                break;
            end;
        end;
    end;

    function TVoisins.indexVoisin(var existe: boolean; px, py : integer) : integer;
    var 
        i : integer;
        refx, refy : integer;
    begin
        // Coordonnées du voisin souhaité
        refx := (self.voisins[0].x + self.voisins[7].x) + px;
        refy := (self.voisins[0].y + self.voisins[7].y) + py;
        // Recherche du voisin
        for i := 0 to 7 do
        begin
            if (self.voisins[i].x = refx) and (self.voisins[i].y = refy) then
            begin
                indexVoisin := self.voisins[i].index;
                existe := self.voisins[i].existe;
                break;
            end;
        end;
    end;
end.
