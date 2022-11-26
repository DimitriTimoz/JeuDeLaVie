unit plateau;

interface
uses utils, sysutils, crt, parcelle, structures, logSys;
type 
    TPlateau = object
        private
            tmpParcelles : array[0..8] of TParcelle;
            largeur, hauteur : integer;
        public
            parcelles : array of TParcelle;
            procedure ajouterCellule(x, y: integer);
            procedure supprimerCellule(x, y: integer);
            procedure sauvegarder();
            procedure charger();
            procedure simuler();
            procedure appliquerSimulation();
            procedure afficher(camera: TCamera);
    end;


implementation
    
procedure TPlateau.ajouterCellule(x, y: integer);
var 
    i, len: integer;
    nx, ny: integer;
    n_voisins: array[0..7] of TVoisin;
    n_voisin: integer;
begin
    len := length(parcelles);
    // Coordonnées de la parcelle
    ny := y - negmod(y, TAILLE_PARCELLE);
    nx := x - negmod(x, TAILLE_PARCELLE);
    n_voisin := 0;
    for i := 0 to len do 
    begin
        (* Si la parcelle existe on ajoute la cellule *)
        if  (parcelles[i].x = nx) and (parcelles[i].y = ny) then
        begin
            x := x - parcelles[i].x;
            y := y - parcelles[i].y;
            log('Ajout de la cellule en ' + inttostr(x) + ' ' + inttostr(y));
            parcelles[i].definir_cellule(x, y, true);
            Exit;
        end;
        // Vérification des voisins
        if (parcelles[i].x = nx - TAILLE_PARCELLE) and (parcelles[i].y = ny) then
        begin
        end;
    end;

    (* Sinon on crée une nouvelle parcelle *)
    setLength(parcelles, len + 1);
    parcelles[len].init(nx, ny, n_voisins);
   
    x := negmod(x, TAILLE_PARCELLE);
    y := negmod(y, TAILLE_PARCELLE);

    parcelles[len].definir_cellule(x, y, true);

end;

procedure TPlateau.supprimerCellule(x, y: integer);
var 
    i, len, nx, ny: integer;
begin
    len := length(parcelles);

    // Coordonnées de la parcelle
    ny := y - negmod(y, TAILLE_PARCELLE);
    nx := x - negmod(x, TAILLE_PARCELLE);

    for i := 0 to len do 
    begin
        (* Si la parcelle existe on supprime la cellule *)
        if (parcelles[i].x = nx) and (parcelles[i].y = ny) then
        begin
            x := x - parcelles[i].x;
            y := y - parcelles[i].y;
            parcelles[i].definir_cellule(x, y, false);
            Exit;
        end;
    end;
end;

procedure TPlateau.sauvegarder();
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
    write(f, length(parcelles)); // nombre de parcelles 
    write(f, ' ');
    writeln(f, TAILLE_PARCELLE); // taille d'une parcelle

    (* Parcelles *)
    for p := 0 to length(parcelles) - 1 do
    begin
        write(f, parcelles[p].x);
        write(f, ' ');
        writeln(f, parcelles[p].y);
        for i := 0 to TAILLE_PARCELLE - 1 do
        begin
            writeln(f, parcelles[p].lignes[i]);
        end;
    end;
    close(f);
end;

procedure TPlateau.charger();
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
    // Format: 'nombreParcelles TAILLE_PARCELLE'
    readln(f, ligne);
    n_parcelles := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
    Delete(ligne, 1, Pos(' ', ligne));
    if StrToInt(ligne) <> TAILLE_PARCELLE then
    begin
        writeln('Erreur : taille de parcelle incorrecte');
        Exit;
    end;

    (* Parcelles *)
    setLength(parcelles, n_parcelles);
    for p := 0 to n_parcelles - 1 do
    begin
        readln(f, ligne);
        parcelles[p].x := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
        Delete(ligne, 1, Pos(' ', ligne));
        parcelles[p].y := StrToInt(ligne);

        for i := 0 to TAILLE_PARCELLE - 1 do
        begin
            readln(f, ligne);
            parcelles[p].lignes[i mod TAILLE_PARCELLE] := StrToQWord(ligne);
        end;
    end;
    close(f);
end;

procedure TPlateau.appliquerSimulation();
var 
    x, y : integer;
begin
    for x := 0 to TAILLE_PARCELLE - 1 do 
    begin
        for y := 0 to TAILLE_PARCELLE - 1 do 
        begin
            parcelles[0].definir_cellule(x, y, tmpParcelles[0].obtenir_cellule(x, y));
        end;
    end;
end;


procedure TPlateau.simuler();
var 
    y, x, i, j, compteur: Integer;

begin
    for i := 0 to length(parcelles) - 1 do
    begin
        tmpParcelles[i].nettoyer();
    end;
    for x := 0 to TAILLE_PARCELLE - 1 do
    begin
        for y := 0 to TAILLE_PARCELLE - 1 do
        begin
            tmpParcelles[0].definir_cellule(x, y, parcelles[0].simulerCellule(x, y));
        end;
    end;
    parcelles[0].nettoyer();
    appliquerSimulation();
end;

procedure TPlateau.afficher(camera: TCamera);
    var
       i: integer;
    begin
        log('new frame');
        (* Affichage du plateau *)
        for i := 0 to length(parcelles) - 1 do
        begin
            parcelles[i].afficher(camera);
        end;
            
    end;

end.