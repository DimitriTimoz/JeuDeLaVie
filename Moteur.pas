unit Moteur;

interface
uses structures, utils, sysutils, crt;

procedure ajouterCellule(var parcelle: TParcelle; x, y: integer);
procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure supprimerCellule(var parcelle: TParcelle; x, y: integer);
procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure sauvegarder_plateau(plateau: TPlateau);
procedure charger_plateau(var plateau: TPlateau);
procedure simuler(var plateau: TPlateau);
procedure appliquerSimulation(var plateau: TPlateau);
procedure nettoyerParcelle(var parcelle: TParcelle; taille: integer);


implementation

procedure ajouterCellule(var parcelle: TParcelle; x, y: integer);
begin
    SetBit(parcelle.lignes[y], x);
end;

procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
var 
    i , len: integer;
begin
    len := length(plateau.parcelles);
    for i := 0 to len do 
    begin
        (* Si la parcelle existe on ajoute la cellule *)
        if ((plateau.parcelles[i].px <= x) and (x < plateau.parcelles[i].px + plateau.tailleParcelle)) and ((plateau.parcelles[i].py <= y) and (y < plateau.parcelles[i].py + plateau.tailleParcelle)) then
        begin
            x := x - plateau.parcelles[i].px;
            y := y - plateau.parcelles[i].py;
            ajouterCellule(plateau.parcelles[i], x, y);
            Exit;
        end;
    end;

    (* Sinon on crée une nouvelle parcelle *)
    setLength(plateau.parcelles, len + 1);

    plateau.parcelles[len].py := y - negmod(y, plateau.tailleParcelle);
    plateau.parcelles[len].px := x - negmod(x, plateau.tailleParcelle);
    x := negmod(x, plateau.tailleParcelle);
    y := negmod(y, plateau.tailleParcelle);

    SetBit(plateau.parcelles[len].lignes[y], x);

end;

procedure supprimerCellule(var parcelle: TParcelle; x, y: integer);
begin
    ClearBit(parcelle.lignes[y], x);
end;

procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
var 
    i , len: integer;
begin
    len := length(plateau.parcelles);
    for i := 0 to len do 
    begin
        (* Si la parcelle existe on supprime la cellule *)
        if ((plateau.parcelles[i].px <= x) and (x < plateau.parcelles[i].px + plateau.tailleParcelle)) and ((plateau.parcelles[i].py <= y) and (y < plateau.parcelles[i].py + plateau.tailleParcelle)) then
        begin
            x := x - plateau.parcelles[i].px;
            y := y - plateau.parcelles[i].py;
            supprimerCellule(plateau.parcelles[i], x, y);
            Exit;
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

procedure sauvegarder_plateau(plateau: TPlateau);
var
    nom: String;
    f: Text;
    i, p: integer;
begin
    writeln('Sauvegarde du plateau');
    write('Nom du fichier : ');
    readln(nom);
    assign(f, nom + '.save');
    rewrite(f);

    (* Entête *)
    write(f, length(plateau.parcelles)); // nombre de parcelles 
    write(f, ' ');
    writeln(f, plateau.tailleParcelle); // taille d'une parcelle

    (* Parcelles *)
    for p := 0 to length(plateau.parcelles) - 1 do
    begin
        write(f, plateau.parcelles[p].px);
        write(f, ' ');
        writeln(f, plateau.parcelles[p].py);
        for i := 0 to plateau.tailleParcelle - 1 do
        begin
            writeln(f, plateau.parcelles[p].lignes[i]);
        end;
    end;
    close(f);
end;

procedure charger_plateau(var plateau: TPlateau);
var
    nom, ligne: String;
    f: Text;
    i, p, n_parcelles: integer;
begin
    
    repeat
        writeln('Charger un plateau');
        write('Nom du fichier : ');
        readln(nom);
        nom := nom + '.save';
    until FileExists(nom);
    
    assign(f, nom);
    reset(f);

    (* Entête *)
    // Format: 'nombreParcelles tailleParcelle'
    readln(f, ligne);
    n_parcelles := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
    Delete(ligne, 1, Pos(' ', ligne));
    plateau.tailleParcelle := StrToInt(ligne);

    (* Parcelles *)
    setLength(plateau.parcelles, n_parcelles);
    for p := 0 to n_parcelles - 1 do
    begin
        readln(f, ligne);
        plateau.parcelles[p].px := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
        Delete(ligne, 1, Pos(' ', ligne));
        plateau.parcelles[p].py := StrToInt(ligne);

        for i := 0 to plateau.tailleParcelle - 1 do
        begin
            readln(f, ligne);
            plateau.parcelles[p].lignes[i mod plateau.tailleParcelle] := StrToQWord(ligne);
        end;
    end;
    close(f);
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
            //if (compteur = 3) or ((compteur = 2) and GetBit(plateau.parcelles[0].lignes[y], x)) then
             //   ajouterCellule(plateau.tmpParcelles[0], x, y);
        end;
    end;
    nettoyerParcelle(plateau.parcelles[0], plateau.tailleParcelle);
    appliquerSimulation(plateau);
end;



end.