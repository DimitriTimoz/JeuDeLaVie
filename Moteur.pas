unit Moteur;

interface
uses structures, utils;

procedure ajouterCellule(var plateau: TPlateau; x, y: integer);
procedure supprimerCellule(var plateau: TPlateau; x, y: integer);

implementation

procedure ajouterCellule(var plateau: TPlateau; x, y: integer);
begin
    SetBit(plateau.parcelles[0].lignes[y+1], x);
end;

procedure supprimerCellule(var plateau: TPlateau; x, y: integer);
begin
    ClearBit(plateau.parcelles[0].lignes[y+1], x);
end;


end.

