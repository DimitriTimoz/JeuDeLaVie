unit structures;

interface

uses utils, logSys, crt, sysutils, math;

const LARGEUR_CAM = 32; // Doit être paire
const HAUTEUR_CAM = 32; // Doit être paire
const TAILLE_PARCELLE = 64; // Doit <= 64
type
    TZone = array[0..2] of array[0..2] of boolean;
    TCamera = record
        px, py : Int32;
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
            x, y : Int32;
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
            function indexVoisin(var voisinExiste: boolean; px, py : integer) : integer;
            procedure logVoisins();
    end;

    function estVoisin(px, py, p2x, p2y : integer) : boolean;
    procedure nettoieLigne(var zone : TZone; ligne : integer; horizontale : boolean);

    
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
    begin
        self.voisins[0].init(px - TAILLE_PARCELLE, py - TAILLE_PARCELLE, 0);
        self.voisins[1].init(px, py - TAILLE_PARCELLE, 0);
        self.voisins[2].init(px + TAILLE_PARCELLE, py - TAILLE_PARCELLE, 0);
        self.voisins[3].init(px - TAILLE_PARCELLE, py, 0);
        self.voisins[4].init(px + TAILLE_PARCELLE, py, 0);
        self.voisins[5].init(px - TAILLE_PARCELLE, py + TAILLE_PARCELLE, 0);
        self.voisins[6].init(px, py + TAILLE_PARCELLE, 0);
        self.voisins[7].init(px + TAILLE_PARCELLE, py + TAILLE_PARCELLE, 0);
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

    function TVoisins.indexVoisin(var voisinExiste: boolean; px, py : integer) : integer;
    var 
        i : integer;
        refx, refy : integer;
    begin
        px := px * TAILLE_PARCELLE;
        py := py * TAILLE_PARCELLE;
        // Coordonnées du voisin souhaité
        refx := ((self.voisins[0].x + self.voisins[7].x) div 2 ) + px;
        refy := ((self.voisins[0].y + self.voisins[7].y) div 2 ) + py;

        // Recherche du voisin
        for i := 0 to 7 do
        begin
            if (self.voisins[i].x = refx) and (self.voisins[i].y = refy) then
            begin
                indexVoisin := self.voisins[i].index;
                voisinExiste := self.voisins[i].existe;
                exit;
            end;
        end;

        voisinExiste := false;
    end;

    procedure TVoisins.logVoisins();
    var 
        i : integer;
    begin
        for i := 0 to 7 do
        begin
            log('Voisin ' + inttostr(i) + ' : ' + inttostr(self.voisins[i].x) + ' ' + inttostr(self.voisins[i].y) + ' ' + inttostr(self.voisins[i].index) + ' existe: ' + booltostr(self.voisins[i].existe));
        end;
    end;

    procedure nettoieLigne(var zone : TZone; ligne : integer; horizontale : boolean);
    var 
        i: integer;
    begin
        for i := 0 to 2 do
        begin
            if horizontale then
            begin
                zone[ligne][i] := false;
            end
            else
            begin
                zone[i][ligne] := false;
            end;
        end;
    end;
end.
