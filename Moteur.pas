unit Moteur;

interface
uses structures, utils;

procedure ajouterCellule(var parcelle: TParcelle; x, y: integer);
procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure supprimerCellule(var parcelle: TParcelle; x, y: integer);
procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure simuler(var plateau: TPlateau);
procedure appliquerSimulation(var plateau: TPlateau);
procedure nettoyerParcelle(var parcelle: TParcelle; taille: integer);

implementation

procedure ajouterCellule(var parcelle: TParcelle; x, y: integer);
begin
    SetBit(parcelle.lignes[y], x);
end;

procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
begin
   ajouterCellule(plateau.parcelles[0], x, y);
end;

procedure supprimerCellule(var parcelle: TParcelle; x, y: integer);
begin
    ClearBit(parcelle.lignes[y], x);
end;

procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
begin
   supprimerCellule(plateau.parcelles[0], x, y);
end;

procedure appliquerSimulation(var plateau: TPlateau);
var 
    x, y : integer;
begin
    for x := 0 to plateau.tailleParcelle - 1 do 
    begin
        for y := 0 to plateau.tailleParcelle - 1 do 
        begin
            if GetBit(plateau.tmpParcelles[0].lignes[x], y) then
                SetBit(plateau.parcelles[0].lignes[x], y);
        end;
    end;
end;

procedure nettoyerParcelle(var parcelle: TParcelle; taille: integer);
var
    x: integer;
begin
    for x := 0 to taille - 1 do
        parcelle.lignes[x] := 0;
end;

procedure simuler(var plateau: TPlateau);
var 
    y, x, i, j, compteur: Integer;

begin
    nettoyerParcelle(plateau.tmpParcelles[0], plateau.tailleParcelle);
    for x := 0 to plateau.tailleParcelle - 1 do
    begin
        for y := 0 to plateau.tailleParcelle - 1 do
        begin
            compteur := 0;
            for i := x - 1 to x + 1 do
            begin
                for j := y - 1 to y + 1 do
                begin
                    if ((x = i) and (y = j)) or (j < 0) or (j >= plateau.tailleParcelle) or (i < 0) or (i >= plateau.tailleParcelle) then
                        continue;

                    if GetBit(plateau.parcelles[0].lignes[j], i) then
                       compteur := compteur + 1;
                end;
            end;
            if (compteur = 3) or ((compteur = 2) and GetBit(plateau.parcelles[0].lignes[y], x)) then
                ajouterCellule(plateau.tmpParcelles[0], x, y);
        end;
    end;
    nettoyerParcelle(plateau.parcelles[0], plateau.tailleParcelle);
    appliquerSimulation(plateau);
end;

end.