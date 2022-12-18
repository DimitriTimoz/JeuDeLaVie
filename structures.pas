unit structures;

interface

uses utils, logSys, crt, sysutils, math;

const LARGEUR_CAM = 54; // Doit être paire
const HAUTEUR_CAM = 54; // Doit être paire
const TAILLE_PARCELLE = 64; // Doit <= 64
type
    TZone = array[0..2] of array[0..2] of boolean;
    TCamera = record
        px, py : Int32;
    end;
    PInt64 = ^Int64;
    PPInt64 =^PInt64;
    TPaterne = object
        public
            tx, ty : Int32;
            tableau : PPInt64;
            n : Int32;
            constructor charger(nom : string);
            destructor Destroy;
            function obtenirCellule(i, x, y : Int32) : boolean;
    end;
    TVoisin = object
        public
            x, y : Int32;
            index : Int32;
            existe : boolean;
            constructor init(px, py, ind : Int32);
    end;
    TVoisins = object
        public
            voisins : array[0..7] of TVoisin;
            procedure init(px, py : Int32);
            procedure ajouter(px, py, ind : Int32);
            procedure supprimer(px, py : Int32);
            function indexVoisin(var voisinExiste: boolean; px, py : Int32) : Int32;
            procedure logVoisins();
    end;

    function estVoisin(px, py, p2x, p2y : Int32) : boolean;
    procedure nettoieLigne(var zone : TZone; ligne : Int32; horizontale : boolean);
    procedure nettoieZone(var zone : TZone);

    
implementation

    constructor TVoisin.init(px, py, ind : Int32);
    begin
        self.x := px;
        self.y := py;
        self.index := ind;
        self.existe := false;
    end;

    function estVoisin(px, py, p2x, p2y : Int32) : boolean;
    begin
        estVoisin := intpower(px - p2x, 2) + intpower(py - p2y, 2) <= intpower(TAILLE_PARCELLE, 2);
    end;

    procedure TVoisins.init(px, py : Int32);
    begin
        // On initialise les voisins avec les coordonnées des parcelles voisines
        self.voisins[0].init(px - TAILLE_PARCELLE, py - TAILLE_PARCELLE, 0);
        self.voisins[1].init(px, py - TAILLE_PARCELLE, 0);
        self.voisins[2].init(px + TAILLE_PARCELLE, py - TAILLE_PARCELLE, 0);
        self.voisins[3].init(px - TAILLE_PARCELLE, py, 0);
        self.voisins[4].init(px + TAILLE_PARCELLE, py, 0);
        self.voisins[5].init(px - TAILLE_PARCELLE, py + TAILLE_PARCELLE, 0);
        self.voisins[6].init(px, py + TAILLE_PARCELLE, 0);
        self.voisins[7].init(px + TAILLE_PARCELLE, py + TAILLE_PARCELLE, 0);
    end;

    procedure TVoisins.ajouter(px, py, ind : Int32);
    var 
        i : Int32;
    begin
        // On ajoute un index
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

    procedure TVoisins.supprimer(px, py : Int32);
    var 
        i : Int32;
    begin
        // On supprime un index
        for i := 0 to 7 do
        begin
            if (self.voisins[i].x = px) and (self.voisins[i].y = py) then
            begin
                self.voisins[i].existe := false;
                break;
            end;
        end;
    end;

    function TVoisins.indexVoisin(var voisinExiste: boolean; px, py : Int32) : Int32;
    var 
        i : Int32;
        refx, refy : Int32;
    begin
        px := px * TAILLE_PARCELLE;
        py := py * TAILLE_PARCELLE;
        // Coordonnées du voisin souhaité
        // On prend le voisin en haut à gauche et en bas à droite en faisant la moyenne on obtient le centre du repère auquel on ajoute un décalage
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
        i : Int32;
    begin
        for i := 0 to 7 do
            log('Voisin ' + inttostr(i) + ' : ' + inttostr(self.voisins[i].x) + ' ' + inttostr(self.voisins[i].y) + ' ' + inttostr(self.voisins[i].index) + ' existe: ' + booltostr(self.voisins[i].existe));
    end;

    procedure nettoieLigne(var zone : TZone; ligne : Int32; horizontale : boolean);
    var 
        i: integer;
    begin
        for i := 0 to 2 do
        begin
            if horizontale then
                zone[ligne][i] := false
            else
                zone[i][ligne] := false;
        end;
    end;

    procedure nettoieZone(var zone : TZone);
    var 
        i, j: Int32;
    begin
        // On initialise la zone à false
        for i := 0 to 2 do
            for j := 0 to 2 do
                zone[i][j] := false;
    end;

    constructor TPaterne.charger(nom : string);
    var
        f : text;
        ligne : string;
        x, y, p : Int32;
    begin
        assign(f, nom);
        reset(f);

        // Entête 
        // Format: 'nombreFrames tailleX tailleY'
        if eof(f) then
            log('Erreur: fichier ' + nom + ' vide');
        // On part du principe que le fichier est correct 
        readln(f, ligne);
        self.n := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
        Delete(ligne, 1, Pos(' ', ligne));
        self.tx := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
        Delete(ligne, 1, Pos(' ', ligne));
        self.ty := StrToInt(ligne);

        // On crée les frames
        self.tableau := GetMem(self.n * SizeOf(PPInt64));
        for p := 0 to self.n - 1 do
        begin
            readln(f, ligne); // Ligne vide
            // On crée les lignes
            self.tableau[p] := GetMem(self.ty * SizeOf(PInt64));
            for y := 0 to self.ty - 1 do
            begin
                readln(f, ligne);
                if length(ligne) <> self.tx then
                begin
                    log('Erreur: ligne ' + inttostr(y) + ' de la frame ' + inttostr(p) + ' du fichier ' + nom + ' incorrecte');
                    Exit;
                end;
                // On créé les colonnes vides pour définir seulement les bits à 1
                self.tableau[p][y] := 0;
                for x := 0 to self.tx - 1 do
                begin
                    if '1' = ligne[x + 1] then
                        SetBit(self.tableau[p][y], x);
                end;
            end;
        end;

        close(f);
    end;

    destructor TPaterne.Destroy();
    var
        p : Int32;
    begin
        // On libère la mémoire
        for p := 0 to self.n - 1 do
        begin
            FreeMem(self.tableau[p]);
        end;
        FreeMem(self.tableau);
    end;

    function TPaterne.obtenirCellule(i, x, y : Int32) : boolean;
    begin
        obtenirCellule := GetBit(self.tableau[i][y], x);
    end;

end.
