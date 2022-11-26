unit Moteur;

interface
uses structures, utils, sysutils, crt;

procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);

procedure sauvegarder_plateau(plateau: TPlateau);
procedure charger_plateau(var plateau: TPlateau);
procedure simuler(var plateau: TPlateau);
procedure appliquerSimulation(var plateau: TPlateau);
procedure nettoyerParcelle(var parcelle: TParcelle; taille: integer);

implementation

procedure ajouterCellulePlateau(var plateau: TPlateau; x, y: integer);
var 
    i , len: integer;
    nx, ny: integer;
    n_voisins: array[0..7] of TVoisin;
    n_voisin: integer;
begin
    len := length(plateau.parcelles);
    // Coordonnées de la parcelle
    ny := y - negmod(y, plateau.tailleParcelle);
    nx := x - negmod(x, plateau.tailleParcelle);
    n_voisin := 0;
    for i := 0 to len - 1 do 
    begin
        (* Si la parcelle existe on ajoute la cellule *)
        if  (plateau.parcelles[i].x = nx) and (plateau.parcelles[i].y = ny) then
        begin
            x := x - plateau.parcelles[i].x;
            y := y - plateau.parcelles[i].y;
            plateau.parcelles[i].definir_cellule(x, y, true);
            Exit;
        end;
        // Vérification des voisins
        if (plateau.parcelles[i].x = nx - plateau.tailleParcelle) and (plateau.parcelles[i].y = ny) then
        begin
        end;
    end;

    (* Sinon on crée une nouvelle parcelle *)
    setLength(plateau.parcelles, len + 1);
    plateau.parcelles[len].init(nx, ny, n_voisins);
   
    x := negmod(x, plateau.tailleParcelle);
    y := negmod(y, plateau.tailleParcelle);

    plateau.parcelles[len].definir_cellule(x, y, true);

end;


procedure supprimerCellulePlateau(var plateau: TPlateau; x, y: integer);
var 
    i, len, nx, ny: integer;
begin
    len := length(plateau.parcelles);

    // Coordonnées de la parcelle
    ny := y - negmod(y, plateau.tailleParcelle);
    nx := x - negmod(x, plateau.tailleParcelle);

    for i := 0 to len do 
    begin
        (* Si la parcelle existe on supprime la cellule *)
        if (plateau.parcelles[i].x = nx) and (plateau.parcelles[i].y = ny) then
        begin
            x := x - plateau.parcelles[i].x;
            y := y - plateau.parcelles[i].y;
            plateau.parcelles[i].definir_cellule(x, y, false);
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
        write(f, plateau.parcelles[p].x);
        write(f, ' ');
        writeln(f, plateau.parcelles[p].y);
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
        plateau.parcelles[p].x := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
        Delete(ligne, 1, Pos(' ', ligne));
        plateau.parcelles[p].y := StrToInt(ligne);

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
    for i := 0 to length(plateau.parcelles) - 1 do
    begin
        nettoyerParcelle(plateau.tmpParcelles[i], plateau.tailleParcelle);
    end;
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
                plateau.tmpParcelles[0].definir_cellule(x, y, true);
        end;
    end;
    nettoyerParcelle(plateau.parcelles[0], plateau.tailleParcelle);
    appliquerSimulation(plateau);
end;



end.