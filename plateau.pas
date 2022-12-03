unit plateau;

interface
uses utils, sysutils, crt, parcelle, structures, logSys, math;
type 
    TPlateau = object
        public
            parcelles : array of TParcelle;
            procedure ajouterCellule(x, y: integer);
            procedure supprimerCellule(x, y: integer);
            procedure sauvegarder();
            procedure charger();
            procedure simuler();
            procedure afficher(camera: TCamera);
    end;

    function simulerZone(zone: TZone): boolean;
implementation
    
procedure TPlateau.ajouterCellule(x, y: integer);
var 
    i, len: integer;
    nx, ny: Int32;
    n_voisins: TVoisins;
begin
    len := length(parcelles);
    // Coordonnées de la parcelle
    ny := y - negmod(y, TAILLE_PARCELLE);
    nx := x - negmod(x, TAILLE_PARCELLE);
    n_voisins.init(nx, ny);

    for i := 0 to len - 1 do 
    begin
        (* Si la parcelle existe on ajoute la cellule *)
        if  (parcelles[i].x = nx) and (parcelles[i].y = ny) then
        begin
            x := x - parcelles[i].x;
            y := y - parcelles[i].y;
            parcelles[i].definir_cellule(x, y, true);
            Exit;
        end;
        // Vérification des voisins
        if intpower(parcelles[i].x - nx, 2) + intpower(parcelles[i].x - ny, 2) <= intpower(TAILLE_PARCELLE, 2) then
            n_voisins.ajouter(parcelles[i].x, parcelles[i].y, i);
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



procedure TPlateau.simuler();
var 
    y, x, i, j, h_i, b_i, g_i, d_i : Integer;
    h, b, g, d, vide: Boolean;
    nouvelles_parcelles: array of TParcelle;
    n_npar: integer;
    zone: TZone;
    nouveau_voisins: TVoisins;
begin
    n_npar := 0;
    vide := false;

    for i := 0 to length(parcelles) - 1 do
    begin
        // On créé la nouvelle parcelle
        if not(vide) then
        begin
            n_npar := n_npar + 1;
            setLength(nouvelles_parcelles, n_npar);
        end;
        nouveau_voisins.init(parcelles[i].x, parcelles[i].y);
        nouvelles_parcelles[n_npar - 1].init(parcelles[i].x, parcelles[i].y, nouveau_voisins);

        vide := true;

        // On simule le centre de la parcelle
        for y := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Vérification utilité de la ligne
            if (self.parcelles[i].lignes[y] <> 0) or (self.parcelles[i].lignes[y - 1] <> 0) or (self.parcelles[i].lignes[y + 1] <> 0) then
            begin
                for x := 1 to TAILLE_PARCELLE - 2 do
                begin
                    if self.parcelles[i].simulerCellule(x, y) then
                    begin
                        nouvelles_parcelles[n_npar - 1].definir_cellule(x, y, true);
                    end;
                end;
            end;
        end;
        // On récupère les voisins
        h_i := self.parcelles[i].voisins.indexVoisin(h, 0, 1);
        b_i := self.parcelles[i].voisins.indexVoisin(b, 0, -1);
        g_i := self.parcelles[i].voisins.indexVoisin(g, -1, 0);
        d_i := self.parcelles[i].voisins.indexVoisin(d, 1, 0);

        // On simule les bords haut et bas
        for x := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Haut
            // Récupération de la zone
            if h then 
            begin
                zone[0][0] := self.parcelles[i].obtenir_cellule(x - 1, 1); zone[0][1] := self.parcelles[i].obtenir_cellule(x, 1); zone[0][2] := self.parcelles[i].obtenir_cellule(x + 1, 1);
                zone[1][0] := self.parcelles[i].obtenir_cellule(x - 1, 0); zone[1][1] := self.parcelles[i].obtenir_cellule(x, 0); zone[1][2] := self.parcelles[i].obtenir_cellule(x + 1, 0);
                zone[2][0] := self.parcelles[h_i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 1); zone[2][1] := self.parcelles[h_i].obtenir_cellule(x, TAILLE_PARCELLE - 1); zone[2][2] := self.parcelles[h_i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 1);

                // Simulation
                nouvelles_parcelles[n_npar - 1].definir_cellule(x, 0, simulerZone(zone));
            end;
            
            // Bas
            // Récupération de la zone
            if b then
            begin
                zone[0][0] := self.parcelles[i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 2); zone[0][1] := self.parcelles[i].obtenir_cellule(x, TAILLE_PARCELLE - 2); zone[0][2] := self.parcelles[i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 2);
                zone[1][0] := self.parcelles[i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 1); zone[1][1] := self.parcelles[i].obtenir_cellule(x, TAILLE_PARCELLE - 1); zone[1][2] := self.parcelles[i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 1);
                zone[2][0] := self.parcelles[b_i].obtenir_cellule(x - 1, 0); zone[2][1] := self.parcelles[b_i].obtenir_cellule(x, 0); zone[2][2] := self.parcelles[b_i].obtenir_cellule(x + 1, 0);

                // Simulation
                nouvelles_parcelles[n_npar - 1].definir_cellule(x, TAILLE_PARCELLE - 1, simulerZone(zone));
            end;
        end;

        // On simule les bords gauche et droit
        for y := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Gauche
            // Récupération de la zone
            if g then
            begin
                zone[0][0] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, y - 1); zone[0][1] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, y); zone[0][2] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, y + 1);
                zone[1][0] := self.parcelles[i].obtenir_cellule(0, y - 1); zone[1][1] := self.parcelles[i].obtenir_cellule(0, y); zone[1][2] := self.parcelles[i].obtenir_cellule(0, y + 1);
                zone[2][0] := self.parcelles[i].obtenir_cellule(1, y - 1); zone[2][1] := self.parcelles[i].obtenir_cellule(1, y); zone[2][2] := self.parcelles[i].obtenir_cellule(1, y + 1);
                
                nouvelles_parcelles[n_npar - 1].definir_cellule(x, 0, simulerZone(zone));
            end;
            // Droit
            // Récupération de la zone
            if d then 
            begin
                zone[0][0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, y - 1); zone[0][1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, y); zone[0][2] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, y + 1);
                zone[1][0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y - 1); zone[1][1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y); zone[1][2] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y + 1);
                zone[2][0] := self.parcelles[d_i].obtenir_cellule(0, y - 1); zone[2][1] := self.parcelles[d_i].obtenir_cellule(0, y); zone[2][2] := self.parcelles[d_i].obtenir_cellule(0, y + 1);

                nouvelles_parcelles[n_npar - 1].definir_cellule(x, TAILLE_PARCELLE - 1, simulerZone(zone));
            end;
        end;
        
        vide := nouvelles_parcelles[n_npar - 1].estVide();

    end;

    // On cherche les voisins
    for i := 0 to n_npar - 1 do
    begin
        // On cherche les voisins de la parcelle
        for j := i to n_npar - 1 do
        begin
            if estVoisin(nouvelles_parcelles[i].x, nouvelles_parcelles[i].y, nouvelles_parcelles[j].x, nouvelles_parcelles[j].y) then
            begin
                // On ajoute les voisins
                nouvelles_parcelles[i].voisins.ajouter(nouvelles_parcelles[j].x, nouvelles_parcelles[j].y, j);
                nouvelles_parcelles[j].voisins.ajouter(nouvelles_parcelles[i].x, nouvelles_parcelles[i].y, i);
            end;
        end
    end;
    self.parcelles := nouvelles_parcelles;
    setLength(self.parcelles, 0);
    setLength(self.parcelles, length(nouvelles_parcelles));
    // Application des changements
    log('Application des changements :' + IntToStr(length(nouvelles_parcelles)));
    for i := 0 to length(nouvelles_parcelles) - 1 do
    begin
        self.parcelles[i] := nouvelles_parcelles[i];
        log('Parcelle ' + IntToStr(i));
    end; 

end;

procedure TPlateau.afficher(camera: TCamera);
var
    i: integer;
begin
    (* Affichage du plateau *)
    for i := 0 to length(parcelles) - 1 do
    begin
        parcelles[i].afficher(camera);
    end;
        
end;

function simulerZone(zone: TZone): boolean;
var
    i, j, compteur: integer;
begin
    compteur := 0;
    for i := 0 to 2 do
    begin
        for j := 0 to 2 do
        begin
            if ((j <> 1 ) or (i <> 1)) and zone[i][j] then
                compteur := compteur + 1;
        end;
    end;

    simulerZone := (compteur = 3) or ((compteur = 2) and (zone[1][1]));
end;

end.