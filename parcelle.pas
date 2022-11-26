unit parcelle;

interface
    uses structures, utils, crt, sysutils, logSys;
    type 
        TParcelle = object
            private
                voisins : array[0..7] of TVoisin;
            public
                x, y : integer;
                lignes : array[0..63] of QWord (* 64 bits *);
                constructor init(nx, ny: integer; n_voisins: array of TVoisin);
                function obtenir_cellule(px, py: integer): Boolean;
                procedure definir_cellule(px, py: integer; valeur: Boolean);
                procedure nettoyer();
                procedure afficher(camera: TCamera);
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

procedure TParcelle.nettoyer();
var
    i : integer;
begin
    for i := 0 to TAILLE_PARCELLE - 1 do
        lignes[i] := 0;
end;

procedure TParcelle.afficher(camera: TCamera);
var 
    debut_x, debut_y, offset_x, offset_y, fin_x, fin_y, px, py: integer;
begin
    offset_x := x - camera.px;
    offset_y := y - camera.py;
    // Vérification que la parcelle est dans la zone d'affichage
    if (offset_x + TAILLE_PARCELLE < 0) or (offset_y + TAILLE_PARCELLE < 0) then
        exit
    else if (offset_x > LARGEUR_CAM) or (offset_y > HAUTEUR_CAM) then
        exit;

    // Calcul des coordonnées de fin d'affichage dans la parcelle
    if offset_x + TAILLE_PARCELLE > LARGEUR_CAM then
        fin_x := LARGEUR_CAM - offset_x
    else
        fin_x := TAILLE_PARCELLE;
    
    if offset_y + TAILLE_PARCELLE > HAUTEUR_CAM then
        fin_y := HAUTEUR_CAM - offset_y
    else
        fin_y := TAILLE_PARCELLE;

    // Calcul des coordonnées de début d'affichage dans la parcelle
    if offset_x < 0 then
    begin
        debut_x := -offset_x;
    end
    else
        debut_x := 0;

    if offset_y < 0 then
    begin
        debut_y := -(offset_y);
    end
    else
        debut_y := 0;

    // Affichage de la parcelle
    GotoXY(1, HAUTEUR_CAM + 9);
    writeln('debut: ', debut_x, ' ', debut_y, ' fin: ', fin_x, ' ', fin_y, ' offset: ', offset_x, ' ', offset_y);
    log('debut: ' + IntToStr(debut_x) + ' ' + IntToStr(debut_y) + ' fin: ' + IntToStr(fin_x) + ' ' + IntToStr(fin_y) + ' offset: ' + IntToStr(offset_x) + ' ' + IntToStr(offset_y));
    TextColor(0);       
    
    for py := debut_y to fin_y - 1 do
    begin
        for px := debut_x to fin_x - 1 do
        begin
            GotoXY(px + 1 + offset_x, py + offset_y + 1);
            if GetBit(lignes[py], px) then
            begin
                write('#');
            end
            
        end;
    end;

end;

end.