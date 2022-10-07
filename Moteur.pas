unit Moteur;

interface
uses structures, utils;

procedure ajouterCellule(var parcelle: TParcelle; x, y: integer);
procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure supprimerCellule(var parcelle: TParcelle; x, y: integer);
procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure simuler(var plateau: TPlateau);

implementation

procedure ajouterCellule(var parcelle: TParcelle; x, y: integer);
begin
    SetBit(parcelle.lignes[y+1], x);
end;

procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
begin
   ajouterCellule(plateau.parcelles[0], x,y);
end;

procedure supprimerCellule(var parcelle: TParcelle; x, y: integer);
begin
    ClearBit(parcelle.lignes[y+1], x);
end;

procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
begin
   supprimerCellule(plateau.parcelles[0], x,y);
end;


procedure simuler(var plateau: TPlateau);
var 
    y,x,i,j, compteur: Integer;

begin
    compteur := 0;

    for x:= 0 to plateau.largeur - 1 do
    begin
        
        for y := 0 to plateau.hauteur - 1 do
        begin
            for i := x - 1 to x + 1 do
            begin
                for j := y - 1 to y + 1 do
                begin
                    if (j > 0) or (j >= plateau.hauteur) or (i > 0) or (i >= plateau.largeur) then
                        continue;
                    if GetBit(plateau.tmpParcelles[1].lignes[x], y) then
                        compteur := compteur + 1;
                end;

            if (compteur = 3) then ajouterCellule(plateau.tmpParcelles[1], x,y) else
            if (compteur > 3) then supprimerCellule(plateau.tmpParcelles[1], x,y) else
            if (compteur < 2) then supprimerCellule(plateau.tmpParcelles[1], x,y);
        end;
    end;

end;
end;

end.