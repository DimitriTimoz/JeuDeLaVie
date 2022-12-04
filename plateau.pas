unit plateau;

interface
uses utils, sysutils, crt, parcelle, structures, logSys, math;
type 
    TParcelles = array of TParcelle;
    TPlateau = object
        public
            parcelles : array of TParcelle;
            procedure ajouterCellule(x, y: integer);
            procedure supprimerCellule(x, y: integer);
            procedure sauvegarder();
            procedure charger();
            procedure simuler();
            procedure afficher(camera: TCamera);
            procedure simuleBordInexistant(var nouvelles_parcelles: TParcelles);
    end;

    function simulerZone(zone: TZone): boolean;
    procedure ajouterNouvelleParcelle(var nouvelles_parcelles: TParcelles; x, y: Int32);

implementation
    
procedure TPlateau.ajouterCellule(x, y: integer);
var 
    i, len: integer;
    nx, ny, ni: Int32;
    n_voisins: TVoisins;
    trouve: boolean;
begin
    trouve := false;
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
            ni := i;
            trouve := true;
        end;
        // Vérification des voisins
        if estVoisin(parcelles[i].x, nx, parcelles[i].y, ny) then
        begin
            n_voisins.ajouter(parcelles[i].x, parcelles[i].y, i);
        end;
    end;

    (* Sinon on crée une nouvelle parcelle *)
    if not trouve then
    begin
        setLength(parcelles, len + 1);
        parcelles[len].init(nx, ny, n_voisins);
    
        x := negmod(x, TAILLE_PARCELLE);
        y := negmod(y, TAILLE_PARCELLE);

        parcelles[len].definir_cellule(x, y, true);

        // On ajoute aux parcelles voisines existantes la présence de cette nouvelle parcelle
        for i := 0 to 7 do
        begin
            if n_voisins.voisins[i].existe then
                parcelles[n_voisins.voisins[i].index].voisins.ajouter(parcelles[len].x, parcelles[len].y, len);
        end;
    end
    else
    begin
        x := x - parcelles[ni].x;
        y := y - parcelles[ni].y;
        parcelles[ni].definir_cellule(x, y, true);
    end;
end;

procedure TPlateau.supprimerCellule(x, y: integer);
var 
    i, len, nx, ny: Int32;
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
    i, p, n_parcelles: Int32;
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

    (* Calcul des voisins *)
    for i := 0 to length(self.parcelles) - 1 do
    begin
        // On cherche les voisins de la parcelle
        for p := i to length(self.parcelles) - 1 do
        begin
            if estVoisin(self.parcelles[i].x, self.parcelles[i].y, self.parcelles[p].x, self.parcelles[p].y) then
            begin
                // On ajoute les voisins
                self.parcelles[p].voisins.ajouter(self.parcelles[p].x, self.parcelles[p].y, p);
                self.parcelles[p].voisins.ajouter(self.parcelles[i].x, self.parcelles[i].y, i);
            end;
        end
    end;
end;


procedure ajouterNouvelleParcelle(var nouvelles_parcelles: TParcelles; x, y: Int32);
var 
    n_npar: Int32;
    nouveau_voisins: TVoisins;
begin
    n_npar := length(nouvelles_parcelles);
    setLength(nouvelles_parcelles, n_npar + 1);
    nouveau_voisins.init(x, y);
    nouvelles_parcelles[n_npar].init(x, y, nouveau_voisins);
end;

procedure TPlateau.simuleBordInexistant(var nouvelles_parcelles: TParcelles);
var 
    x, y, i, hg_i, hd_i, bd_i, bg_i, n1, n2: Int32;
    h, b, g, d, hg, hd, bg, bd: Boolean;
    zone: TZone;

begin
    for i := 0 to length(self.parcelles) - 1 do
    begin
        // On récupère les voisins
        x := self.parcelles[i].voisins.indexVoisin(h, 0, -1);
        x := self.parcelles[i].voisins.indexVoisin(b, 0, 1);
        x := self.parcelles[i].voisins.indexVoisin(g, -1, 0);
        x := self.parcelles[i].voisins.indexVoisin(d, 1, 0);

        hg_i := self.parcelles[i].voisins.indexVoisin(hg, -1, -1);
        hd_i := self.parcelles[i].voisins.indexVoisin(hd, 1, -1);
        bg_i := self.parcelles[i].voisins.indexVoisin(bg, -1, 1);
        bd_i := self.parcelles[i].voisins.indexVoisin(bd, 1, 1);

        // On simule les bords inexistant
        n1 := -1; n2 := -1;
        if not h or not b then
        begin
            for x := 1 to TAILLE_PARCELLE - 2 do
            begin
                if not h then
                begin
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenir_cellule(x - 1, 0); zone[2, 1] := self.parcelles[i].obtenir_cellule(x, 0); zone[2, 2] := self.parcelles[i].obtenir_cellule(x + 1, 0);
                    if simulerZone(zone) then
                    begin
                        if n1 = -1 then
                        begin
                            log('Ajout d''une nouvelle parcelle ');
                            n1 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x, self.parcelles[i].y - TAILLE_PARCELLE);
                        end;
                        nouvelles_parcelles[n1].definir_cellule(x, TAILLE_PARCELLE - 1, true);
                    end;
                end;
                if not b then
                begin
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 1); zone[2, 1] := self.parcelles[i].obtenir_cellule(x, TAILLE_PARCELLE - 1); zone[2, 2] := self.parcelles[i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 1);
                    if simulerZone(zone) then
                    begin
                        if n2 = -1 then
                        begin
                            log('Ajout d''une nouvelle parcelle ');
                            n2 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x, self.parcelles[i].y + TAILLE_PARCELLE);
                        end;
                        nouvelles_parcelles[n2].definir_cellule(x, 0, true);
                    end;
                end;
            end;
        end;

        n1 := -1; n2 := -1;
        if not h or not b then
        begin
            for y := 1 to TAILLE_PARCELLE - 2 do
            begin
                if not g then
                begin
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenir_cellule(0, y - 1); zone[2, 1] := self.parcelles[i].obtenir_cellule(0, y); zone[2, 2] := self.parcelles[i].obtenir_cellule(0, y + 1);
                    if simulerZone(zone) then
                    begin
                        if n1 = -1 then
                        begin
                            log('Ajout d''une nouvelle parcelle ');
                            n1 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x - TAILLE_PARCELLE, self.parcelles[i].y);
                        end;
                        nouvelles_parcelles[n1].definir_cellule(TAILLE_PARCELLE - 1, y, true);
                    end;
                end;
                if not d then
                begin
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y - 1); zone[2, 1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y); zone[2, 2] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y + 1);
                    if simulerZone(zone) then
                    begin
                        if n2 = -1 then
                        begin
                            log('Ajout d''une nouvelle parcelle ');
                            n2 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x + TAILLE_PARCELLE, self.parcelles[i].y);
                        end;
                        nouvelles_parcelles[n2].definir_cellule(0, y, true);
                    end;
                end;
            end;
        end;

        // On simule les coins
        // Une cellule nait si



    end;
end;

procedure TPlateau.simuler();
var 
    y, x, i, j, h_i, b_i, g_i, d_i, hg_i, hd_i, bg_i, bd_i: Int32;
    h, b, g, d, hg, hd, bg, bd, vide, cree1, cree2: Boolean;
    nouvelles_parcelles: array of TParcelle;
    n_npar: Int32;
    zone: TZone;
    nouveau_voisins: TVoisins;
begin
    n_npar := 0;
    vide := false;
    log('--------- Simulation de  ' + IntToStr(length(parcelles)) + ' parcelles ---------');
    for i := 0 to length(parcelles) - 1 do
    begin
        log('## Parcelle ' + IntToStr(i) + ' : ' + IntToStr(parcelles[i].x) + ' ' + IntToStr(parcelles[i].y));
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
        h_i := self.parcelles[i].voisins.indexVoisin(h, 0, -1);
        b_i := self.parcelles[i].voisins.indexVoisin(b, 0, 1);
        g_i := self.parcelles[i].voisins.indexVoisin(g, -1, 0);
        d_i := self.parcelles[i].voisins.indexVoisin(d, 1, 0);

        hg_i := self.parcelles[i].voisins.indexVoisin(hg, -1, -1);
        hd_i := self.parcelles[i].voisins.indexVoisin(hd, 1, -1);
        bg_i := self.parcelles[i].voisins.indexVoisin(bg, -1, 1);
        bd_i := self.parcelles[i].voisins.indexVoisin(bd, 1, 1);
        
        log(booltostr(hg) + ' ' + booltostr(h) + ' ' + booltostr(hd));
        log(booltostr(g) + ' # ' + booltostr(d));
        log(booltostr(bg) + ' ' + booltostr(b) + ' ' + booltostr(bd));
        log('-----');
        log(inttostr(hg_i) + ' ' + inttostr(h_i) + ' ' + inttostr(hd_i));
        log(inttostr(g_i) + ' # ' + inttostr(d_i));
        log(inttostr(bg_i) + ' ' + inttostr(b_i) + ' ' + inttostr(bd_i));
        self.parcelles[i].voisins.logVoisins();

        // On simule les bords haut et bas
        for x := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Haut
            // Récupération de la zone
            zone[0][0] := self.parcelles[i].obtenir_cellule(x - 1, 1); zone[0][1] := self.parcelles[i].obtenir_cellule(x, 1); zone[0][2] := self.parcelles[i].obtenir_cellule(x + 1, 1);
            zone[1][0] := self.parcelles[i].obtenir_cellule(x - 1, 0); zone[1][1] := self.parcelles[i].obtenir_cellule(x, 0); zone[1][2] := self.parcelles[i].obtenir_cellule(x + 1, 0);
            if h then 
            begin
                zone[2][0] := self.parcelles[h_i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 1); zone[2][1] := self.parcelles[h_i].obtenir_cellule(x, TAILLE_PARCELLE - 1); zone[2][2] := self.parcelles[h_i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 1);
            end
            else
            begin
                nettoieLigne(zone, 2, true);
            end;
            // Simulation
            nouvelles_parcelles[n_npar - 1].definir_cellule(x, 0, simulerZone(zone));
            
            // Bas
            // Récupération de la zone
            zone[0][0] := self.parcelles[i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 2); zone[0][1] := self.parcelles[i].obtenir_cellule(x, TAILLE_PARCELLE - 2); zone[0][2] := self.parcelles[i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 2);
            zone[1][0] := self.parcelles[i].obtenir_cellule(x - 1, TAILLE_PARCELLE - 1); zone[1][1] := self.parcelles[i].obtenir_cellule(x, TAILLE_PARCELLE - 1); zone[1][2] := self.parcelles[i].obtenir_cellule(x + 1, TAILLE_PARCELLE - 1);
            if b then
            begin
                zone[2][0] := self.parcelles[b_i].obtenir_cellule(x - 1, 0); zone[2][1] := self.parcelles[b_i].obtenir_cellule(x, 0); zone[2][2] := self.parcelles[b_i].obtenir_cellule(x + 1, 0);
            end
            else
            begin
                nettoieLigne(zone, 2, true);
            end;
            // Simulation
            nouvelles_parcelles[n_npar - 1].definir_cellule(x, TAILLE_PARCELLE - 1, simulerZone(zone));
        end;

        // On simule les bords gauches et droits
        for y := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Gauche
            // Récupération de la zone
            zone[1][0] := self.parcelles[i].obtenir_cellule(0, y - 1); zone[1][1] := self.parcelles[i].obtenir_cellule(0, y); zone[1][2] := self.parcelles[i].obtenir_cellule(0, y + 1);
            zone[2][0] := self.parcelles[i].obtenir_cellule(1, y - 1); zone[2][1] := self.parcelles[i].obtenir_cellule(1, y); zone[2][2] := self.parcelles[i].obtenir_cellule(1, y + 1);
            if g then
            begin
                zone[0][0] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, y - 1); zone[0][1] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, y); zone[0][2] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, y + 1);                
            end
            else 
            begin
                nettoieLigne(zone, 0, false);
            end;
            nouvelles_parcelles[n_npar - 1].definir_cellule(0, y, simulerZone(zone));
           
            // Droit
            // Récupération de la zone
            zone[0][0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, y - 1); zone[0][1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, y); zone[0][2] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, y + 1);
            zone[1][0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y - 1); zone[1][1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y); zone[1][2] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, y + 1);
            if d then 
            begin
                zone[2][0] := self.parcelles[d_i].obtenir_cellule(0, y - 1); zone[2][1] := self.parcelles[d_i].obtenir_cellule(0, y); zone[2][2] := self.parcelles[d_i].obtenir_cellule(0, y + 1);
            end
            else
            begin
                nettoieLigne(zone, 2, false);
            end;
            nouvelles_parcelles[n_npar - 1].definir_cellule(TAILLE_PARCELLE - 1, y, simulerZone(zone));
        end;

        // On simule les coins
        // Haut gauche
        if hg then zone[0][0] := self.parcelles[hg_i].obtenir_cellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1) else zone[0][0] := false;
        if h then begin zone[0][1] := self.parcelles[h_i].obtenir_cellule(0, TAILLE_PARCELLE - 1); zone[0][2] := self.parcelles[h_i].obtenir_cellule(1, TAILLE_PARCELLE - 1); end else begin zone[0][1] := false; zone[0][2] := false; end;
        if g then zone[1][0] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, 0) else zone[1][0] := false;
        zone[1][1] := self.parcelles[i].obtenir_cellule(0, 0); zone[1][2] := self.parcelles[i].obtenir_cellule(1, 0);
        if g then zone[2][0] := self.parcelles[g_i].obtenir_cellule(TAILLE_PARCELLE - 1, 1) else zone[2][0] := false;
        zone[2][1] := self.parcelles[i].obtenir_cellule(0, 1); zone[2][2] := self.parcelles[i].obtenir_cellule(1, 1);
        // Simulation
        nouvelles_parcelles[n_npar - 1].definir_cellule(0, 0, simulerZone(zone));

        // Haut droit
        if hd then zone[0][2] := self.parcelles[hd_i].obtenir_cellule(0, TAILLE_PARCELLE - 1) else zone[0][0] := false;
        if h then begin zone[0][0] := self.parcelles[h_i].obtenir_cellule(TAILLE_PARCELLE - 2, TAILLE_PARCELLE - 1); zone[0][1] := self.parcelles[h_i].obtenir_cellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1); end else begin zone[0][0] := false; zone[0][1] := false; end;
        if d then zone[1][2] := self.parcelles[d_i].obtenir_cellule(0, 0) else zone[1][2] := false;
        zone[1][0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, 0); zone[1][1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, 0);
        if d then zone[2][2] := self.parcelles[d_i].obtenir_cellule(0, 1) else zone[2][2] := false;
        zone[2][0] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 2, 1); zone[2][1] := self.parcelles[i].obtenir_cellule(TAILLE_PARCELLE - 1, 1);
        // Simulation
        nouvelles_parcelles[n_npar - 1].definir_cellule(TAILLE_PARCELLE - 1, 0, simulerZone(zone));
        
        
       
        vide := nouvelles_parcelles[n_npar - 1].estVide();
    end;

    if vide then
    begin
        setLength(nouvelles_parcelles, n_npar - 1);
        n_npar := n_npar - 1;
    end;
    // On simule les bords inexistants
    self.simuleBordInexistant(nouvelles_parcelles);

    n_npar := length(nouvelles_parcelles);
    // On cherche les voisins
    for i := 0 to n_npar - 1 do
    begin
        // On cherche les voisins de la parcelle
        for j := i + 1 to n_npar - 1 do
        begin
            if estVoisin(nouvelles_parcelles[i].x, nouvelles_parcelles[i].y, nouvelles_parcelles[j].x, nouvelles_parcelles[j].y) then
            begin
                // On ajoute les voisins
                log('Ajout du voisin x = ' + IntToStr(nouvelles_parcelles[j].x) + ' y = ' + IntToStr(nouvelles_parcelles[j].y) + ' à la parcelle x = ' + IntToStr(nouvelles_parcelles[i].x) + ' y = ' + IntToStr(nouvelles_parcelles[i].y));
                nouvelles_parcelles[i].voisins.ajouter(nouvelles_parcelles[j].x, nouvelles_parcelles[j].y, j);
                log('Ajout du voisin x = ' + IntToStr(nouvelles_parcelles[i].x) + ' y = ' + IntToStr(nouvelles_parcelles[i].y) + ' à la parcelle x = ' + IntToStr(nouvelles_parcelles[j].x) + ' y = ' + IntToStr(nouvelles_parcelles[j].y));
                nouvelles_parcelles[j].voisins.ajouter(nouvelles_parcelles[i].x, nouvelles_parcelles[i].y, i);
            end;
        end;
    end;
    self.parcelles := nouvelles_parcelles;

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