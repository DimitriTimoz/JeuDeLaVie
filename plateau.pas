unit plateau;

interface
uses utils, sysutils, crt, parcelle, structures, logSys, math;
type 
    TParcelles = array of TParcelle;
    TPlateau = object
        public
            parcelles : TParcelles;
            procedure ajouterCellule(x, y: Int32);
            procedure supprimerCellule(x, y: Int32);
            procedure sauvegarder();
            procedure charger();
            procedure simuler();
            procedure afficher(camera: TCamera);
            procedure simuleBordInexistant(var nouvelles_parcelles: TParcelles);
            function scanPaternes(name: String): Int32;
    end;

    function simulerZone(zone: TZone): boolean;
    procedure ajouterNouvelleParcelle(var nouvelles_parcelles: TParcelles; x, y: Int32);

implementation
    
procedure TPlateau.ajouterCellule(x, y: Int32);
var 
    i, len: Int32;
    nx, ny, ni: Int32;
    n_voisins: TVoisins;
    trouve: boolean;
begin
    trouve := false;
    len := length(parcelles);
    
    // Coordonnées de la parcelle
    ny := y - negmod(y, TAILLE_PARCELLE); // Pas dans l'analyse descendante mais on a une fonction mathématique non importante
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

    if trouve then
    begin
        // On passe les coordonnées relatives à la parcelle
        x := x - parcelles[ni].x;
        y := y - parcelles[ni].y;
        parcelles[ni].definirCellule(x, y, true);
    end
    else
    begin
        setLength(parcelles, len + 1);
        parcelles[len].init(nx, ny, n_voisins);
    
        x := negmod(x, TAILLE_PARCELLE);
        y := negmod(y, TAILLE_PARCELLE);

        parcelles[len].definirCellule(x, y, true);

        // On ajoute aux parcelles voisines existantes la présence de cette nouvelle parcelle
        for i := 0 to 7 do
        begin
            if n_voisins.voisins[i].existe then
                parcelles[n_voisins.voisins[i].index].voisins.ajouter(parcelles[len].x, parcelles[len].y, len);
        end;
    end;
end;

procedure TPlateau.supprimerCellule(x, y: Int32);
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
            parcelles[i].definirCellule(x, y, false);
            Exit;
        end;
    end;
end;

procedure TPlateau.sauvegarder();
var
    nom: String;
    f: Text;
    i, p: Int32;
begin
    ClrScr;
    writeln('Sauvegarde du plateau');
    write('Nom du fichier : ');
    readln(nom);
    assign(f, './saves/' + nom + '.save');
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
    ClrScr;
    repeat
        writeln('Charger un plateau');
        writeln('Vous pouvez charger un plateau sauvegardé ou un plateau par défaut: ');
        writeln('  - infini');
        writeln('  - planeur');
        write('Nom du fichier : (''q'' pour quitter): ');
        readln(nom);
        if nom = 'q' then
            Exit;
        nom := './saves/' + nom + '.save';
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
// Dans cette partie h = haut, b = bas, g = gauche, d = droite
// hd = haut droite, hg = haut gauche, bd = bas droite, bg = bas gauche
// le suffixe _i signifie index
// On simule les bords inexistant en créant des parcelles fictives
var 
    x, y, i, g_i, d_i, h_i, b_i, hg_i, hd_i, bd_i, bg_i, n1, n2, n3, n4: Int32;
    h, b, g, d, hg, hd, bg, bd: Boolean;
    zone: TZone;

begin
    for i := 0 to length(self.parcelles) - 1 do
    begin
        // On récupère les voisins
        h_i := self.parcelles[i].voisins.indexVoisin(h, 0, -1);
        b_i := self.parcelles[i].voisins.indexVoisin(b, 0, 1);
        g_i := self.parcelles[i].voisins.indexVoisin(g, -1, 0);
        d_i := self.parcelles[i].voisins.indexVoisin(d, 1, 0);

        hg_i := self.parcelles[i].voisins.indexVoisin(hg, -1, -1);
        hd_i := self.parcelles[i].voisins.indexVoisin(hd, 1, -1);
        bg_i := self.parcelles[i].voisins.indexVoisin(bg, -1, 1);
        bd_i := self.parcelles[i].voisins.indexVoisin(bd, 1, 1);

        // On simule les bords inexistant
        // Haut et bas
        n1 := -1; n2 := -1; // On initialise les index des nouvelles parcelles à -1 car elles n'existent pas encore
        if not h or not b then
        begin
            for x := 1 to TAILLE_PARCELLE - 2 do
            begin
                // On simule le haut
                if not h then
                begin
                    // On récupère la zone à simuler
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenirCellule(x - 1, 0); zone[2, 1] := self.parcelles[i].obtenirCellule(x, 0); zone[2, 2] := self.parcelles[i].obtenirCellule(x + 1, 0);
                    // On crée la nouvelle parcelle si elle n'existe pas
                    if simulerZone(zone) then
                    begin
                        if n1 = -1 then
                        begin
                            n1 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x, self.parcelles[i].y - TAILLE_PARCELLE);
                        end;
                        nouvelles_parcelles[n1].definirCellule(x, TAILLE_PARCELLE - 1, true);
                    end;
                end;
                // On simule le bas
                if not b then
                begin
                    // Même chose que pour le haut
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenirCellule(x - 1, TAILLE_PARCELLE - 1); zone[2, 1] := self.parcelles[i].obtenirCellule(x, TAILLE_PARCELLE - 1); zone[2, 2] := self.parcelles[i].obtenirCellule(x + 1, TAILLE_PARCELLE - 1);
                    if simulerZone(zone) then
                    begin
                        if n2 = -1 then
                        begin
                            n2 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x, self.parcelles[i].y + TAILLE_PARCELLE);
                        end;
                        nouvelles_parcelles[n2].definirCellule(x, 0, true);
                    end;
                end;
            end;
        end;

        // Gauche et droite
        // On applique la même méthode que pour le haut et le bas
        n3 := -1; n4 := -1;
        if not g or not d then
        begin
            for y := 1 to TAILLE_PARCELLE - 2 do
            begin
                // Gauche
                if not g then
                begin
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenirCellule(0, y - 1); zone[2, 1] := self.parcelles[i].obtenirCellule(0, y); zone[2, 2] := self.parcelles[i].obtenirCellule(0, y + 1);
                    if simulerZone(zone) then
                    begin
                        if n3 = -1 then
                        begin
                            n3 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x - TAILLE_PARCELLE, self.parcelles[i].y);
                        end;
                        nouvelles_parcelles[n3].definirCellule(TAILLE_PARCELLE - 1, y, true);
                    end;
                end;
                // Droite
                if not d then
                begin
                    nettoieLigne(zone, 0, true);
                    nettoieLigne(zone, 1, true);
                    zone[2, 0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, y - 1); zone[2, 1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, y ); zone[2, 2] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, y + 1);
                    if simulerZone(zone) then
                    begin
                        if n4 = -1 then
                        begin
                            n4 := length(nouvelles_parcelles);
                            ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x + TAILLE_PARCELLE, self.parcelles[i].y);
                        end;
                        nouvelles_parcelles[n4].definirCellule(0, y, true);
                    end;
                end;
            end;
        end;

        // On simule les coins
        // Haut
        if not h then
        begin
            // Gauche
            nettoieZone(zone);
            if hg then 
            begin
                zone[0, 0] := self.parcelles[hg_i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 2);
                zone[1, 0] := self.parcelles[hg_i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1);
            end;

            if g then
                zone[2, 0] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, 0);

            zone[2, 1] := self.parcelles[i].obtenirCellule(0, 0); zone[2, 2] := self.parcelles[i].obtenirCellule(1, 0);
            if simulerZone(zone) then
            begin
                ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x, self.parcelles[i].y - TAILLE_PARCELLE);
                nouvelles_parcelles[length(nouvelles_parcelles) - 1].definirCellule(0, TAILLE_PARCELLE - 1, true);
            end;                

            // Droite 
            nettoieZone(zone);
            if hd then
            begin
                zone[0, 0] := self.parcelles[hd_i].obtenirCellule(0, TAILLE_PARCELLE - 2);
                zone[1, 0] := self.parcelles[hd_i].obtenirCellule(0, TAILLE_PARCELLE - 1);
            end;

            if d then
                zone[2, 0] := self.parcelles[d_i].obtenirCellule(0, 0);
        
        end;

        // Bas
        if not g then
        begin
            // Haut
            nettoieZone(zone);
            if hg then 
            begin
                zone[0, 0] := self.parcelles[hg_i].obtenirCellule(TAILLE_PARCELLE - 2, TAILLE_PARCELLE - 1);
                zone[1, 0] := self.parcelles[hg_i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1);
            end;
            zone[1, 2] := self.parcelles[i].obtenirCellule(0, 0);
            zone[2, 2] := self.parcelles[i].obtenirCellule(0, 1);
            if simulerZone(zone) then
            begin
                ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x - TAILLE_PARCELLE, self.parcelles[i].y);
                nouvelles_parcelles[length(nouvelles_parcelles) - 1].definirCellule(TAILLE_PARCELLE - 1, 0, true);
            end;       

            // Bas      
            nettoieZone(zone);
            if bg then
            begin
                zone[0, 0] := self.parcelles[bg_i].obtenirCellule(TAILLE_PARCELLE - 2, 0);
                zone[1, 0] := self.parcelles[bg_i].obtenirCellule(TAILLE_PARCELLE - 1, 0);
            end;
            zone[1, 2] := self.parcelles[i].obtenirCellule(0, TAILLE_PARCELLE - 1);            
        end;
        
        
        if not hg then
        begin
            nettoieZone(zone);
            if h then 
            begin
                zone[0, 2] := self.parcelles[h_i].obtenirCellule(0, TAILLE_PARCELLE - 2);
                zone[1, 2] := self.parcelles[h_i].obtenirCellule(0, TAILLE_PARCELLE - 1);
            end;

            if g then
            begin
                zone[2, 0] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 2, 0);
                zone[2, 1] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, 0);
            end;

            zone[2, 2] := self.parcelles[i].obtenirCellule(0, 0);

            if simulerZone(zone) then
            begin
                ajouterNouvelleParcelle(nouvelles_parcelles, self.parcelles[i].x - TAILLE_PARCELLE, self.parcelles[i].y - TAILLE_PARCELLE);
                nouvelles_parcelles[length(nouvelles_parcelles) - 1].definirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1, true);
            end;                
        end;


    end;
end;

procedure TPlateau.simuler();
// Dans cette partie h = haut, b = bas, g = gauche, d = droite
// hd = haut droite, hg = haut gauche, bd = bas droite, bg = bas gauche
// le suffixe _i signifie index
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
                        nouvelles_parcelles[n_npar - 1].definirCellule(x, y, true);
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
    
        // On simule les bords haut et bas
        for x := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Haut
            // Récupération de la zone
            zone[0][0] := self.parcelles[i].obtenirCellule(x - 1, 1); zone[0][1] := self.parcelles[i].obtenirCellule(x, 1); zone[0][2] := self.parcelles[i].obtenirCellule(x + 1, 1);
            zone[1][0] := self.parcelles[i].obtenirCellule(x - 1, 0); zone[1][1] := self.parcelles[i].obtenirCellule(x, 0); zone[1][2] := self.parcelles[i].obtenirCellule(x + 1, 0);
            if h then 
            begin
                zone[2][0] := self.parcelles[h_i].obtenirCellule(x - 1, TAILLE_PARCELLE - 1); zone[2][1] := self.parcelles[h_i].obtenirCellule(x, TAILLE_PARCELLE - 1); zone[2][2] := self.parcelles[h_i].obtenirCellule(x + 1, TAILLE_PARCELLE - 1);
            end
            else
            begin
                nettoieLigne(zone, 2, true);
            end;
            // Simulation
            nouvelles_parcelles[n_npar - 1].definirCellule(x, 0, simulerZone(zone));
            
            // Bas
            // Récupération de la zone
            zone[0][0] := self.parcelles[i].obtenirCellule(x - 1, TAILLE_PARCELLE - 2); zone[0][1] := self.parcelles[i].obtenirCellule(x, TAILLE_PARCELLE - 2); zone[0][2] := self.parcelles[i].obtenirCellule(x + 1, TAILLE_PARCELLE - 2);
            zone[1][0] := self.parcelles[i].obtenirCellule(x - 1, TAILLE_PARCELLE - 1); zone[1][1] := self.parcelles[i].obtenirCellule(x, TAILLE_PARCELLE - 1); zone[1][2] := self.parcelles[i].obtenirCellule(x + 1, TAILLE_PARCELLE - 1);
            if b then
            begin
                zone[2][0] := self.parcelles[b_i].obtenirCellule(x - 1, 0); zone[2][1] := self.parcelles[b_i].obtenirCellule(x, 0); zone[2][2] := self.parcelles[b_i].obtenirCellule(x + 1, 0);
            end
            else
            begin
                nettoieLigne(zone, 2, true);
            end;
            // Simulation
            nouvelles_parcelles[n_npar - 1].definirCellule(x, TAILLE_PARCELLE - 1, simulerZone(zone));
        end;

        // On simule les bords gauches et droits
        for y := 1 to TAILLE_PARCELLE - 2 do
        begin
            // Gauche
            // Récupération de la zone
            zone[1][0] := self.parcelles[i].obtenirCellule(0, y - 1); zone[1][1] := self.parcelles[i].obtenirCellule(0, y); zone[1][2] := self.parcelles[i].obtenirCellule(0, y + 1);
            zone[2][0] := self.parcelles[i].obtenirCellule(1, y - 1); zone[2][1] := self.parcelles[i].obtenirCellule(1, y); zone[2][2] := self.parcelles[i].obtenirCellule(1, y + 1);
            if g then
            begin
                zone[0][0] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, y - 1); zone[0][1] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, y); zone[0][2] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, y + 1);                
            end
            else 
            begin
                nettoieLigne(zone, 0, true);
            end;
            nouvelles_parcelles[n_npar - 1].definirCellule(0, y, simulerZone(zone));
           
            // Droit
            // Récupération de la zone
            zone[0][0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, y - 1); zone[0][1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, y); zone[0][2] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, y + 1);
            zone[1][0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, y - 1); zone[1][1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, y); zone[1][2] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, y + 1);
            if d then 
            begin
                zone[2][0] := self.parcelles[d_i].obtenirCellule(0, y - 1); zone[2][1] := self.parcelles[d_i].obtenirCellule(0, y); zone[2][2] := self.parcelles[d_i].obtenirCellule(0, y + 1);
            end
            else
            begin
                nettoieLigne(zone, 2, true);
            end;
            nouvelles_parcelles[n_npar - 1].definirCellule(TAILLE_PARCELLE - 1, y, simulerZone(zone));
        end;

        // On simule les coins
        // Haut gauche
        nettoieZone(zone);
        if hg then zone[0][0] := self.parcelles[hg_i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1);
        if h then begin zone[0][1] := self.parcelles[h_i].obtenirCellule(0, TAILLE_PARCELLE - 1); zone[0][2] := self.parcelles[h_i].obtenirCellule(1, TAILLE_PARCELLE - 1); end;
        if g then zone[1][0] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, 0);
        zone[1][1] := self.parcelles[i].obtenirCellule(0, 0); zone[1][2] := self.parcelles[i].obtenirCellule(1, 0);
        if g then zone[2][0] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, 1);
        zone[2][1] := self.parcelles[i].obtenirCellule(0, 1); zone[2][2] := self.parcelles[i].obtenirCellule(1, 1);
        // Simulation
        nouvelles_parcelles[n_npar - 1].definirCellule(0, 0, simulerZone(zone));

        // Haut droit
        nettoieZone(zone);
        if hd then zone[0][2] := self.parcelles[hd_i].obtenirCellule(0, TAILLE_PARCELLE - 1);
        if h then begin zone[0][0] := self.parcelles[h_i].obtenirCellule(TAILLE_PARCELLE - 2, TAILLE_PARCELLE - 1); zone[0][1] := self.parcelles[h_i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1); end;
        if d then zone[1][2] := self.parcelles[d_i].obtenirCellule(0, 0);
        zone[1][0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, 0); zone[1][1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, 0);
        if d then zone[2][2] := self.parcelles[d_i].obtenirCellule(0, 1);
        zone[2][0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, 1); zone[2][1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, 1);
        // Simulation
        nouvelles_parcelles[n_npar - 1].definirCellule(TAILLE_PARCELLE - 1, 0, simulerZone(zone));
        
        // Bas gauche
        nettoieZone(zone);
        if g then begin zone[0][0] := self.parcelles[g_i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 2) end;
        zone[0][1] := self.parcelles[i].obtenirCellule(0, TAILLE_PARCELLE - 2); zone[0][2] := self.parcelles[i].obtenirCellule(1, TAILLE_PARCELLE - 2);
        zone[1][1] := self.parcelles[i].obtenirCellule(0, TAILLE_PARCELLE - 1); zone[1][2] := self.parcelles[i].obtenirCellule(1, TAILLE_PARCELLE - 1);
        if bg then zone[2][0] := self.parcelles[bg_i].obtenirCellule(TAILLE_PARCELLE - 1, 0);
        if b then begin zone[2][1] := self.parcelles[b_i].obtenirCellule(0, 0); zone[2][2] := self.parcelles[b_i].obtenirCellule(1, 0); end;
        vide := nouvelles_parcelles[n_npar - 1].estVide();
        // Simulation
        nouvelles_parcelles[n_npar - 1].definirCellule(0, TAILLE_PARCELLE - 1, simulerZone(zone));
        
        // Bas droit
        nettoieZone(zone);
        zone[0][0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, TAILLE_PARCELLE - 2); zone[0][1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 2);
        zone[1][0] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 2, TAILLE_PARCELLE - 1); zone[1][1] := self.parcelles[i].obtenirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1);
        if d then begin zone[0][2] := self.parcelles[d_i].obtenirCellule(0, TAILLE_PARCELLE - 2); zone[1][2] := self.parcelles[d_i].obtenirCellule(0, TAILLE_PARCELLE - 1); end;
        if b then begin zone[2][0] := self.parcelles[b_i].obtenirCellule(TAILLE_PARCELLE - 2, 0); zone[2][1] := self.parcelles[b_i].obtenirCellule(TAILLE_PARCELLE - 1, 0); end;
        if bd then zone[2][2] := self.parcelles[bd_i].obtenirCellule(0, 0);
        // Simulation
        nouvelles_parcelles[n_npar - 1].definirCellule(TAILLE_PARCELLE - 1, TAILLE_PARCELLE - 1, simulerZone(zone));
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
                nouvelles_parcelles[i].voisins.ajouter(nouvelles_parcelles[j].x, nouvelles_parcelles[j].y, j);
                nouvelles_parcelles[j].voisins.ajouter(nouvelles_parcelles[i].x, nouvelles_parcelles[i].y, i);
            end;
        end;
    end;
    self.parcelles := nouvelles_parcelles;

end;

procedure TPlateau.afficher(camera: TCamera);
var
    i: Int32;
begin
    // Affichage du plateau 
    for i := 0 to length(parcelles) - 1 do
    begin
        parcelles[i].afficher(camera);
    end;
end;

function simulerZone(zone: TZone): boolean;
var
    i, j, compteur: Int32;
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

function TPlateau.scanPaternes(name: string): Int32;
var
    paterne : TPaterne;
    compteur, x, y, xp, yp, i, f, coY, coX, p: Int32;
    existe: boolean;

label
    matchPas, XSuivant, YSuivant;

begin
    scanPaternes := 0;
    paterne.charger(name);
    compteur := 0;
    // Scan du plateau
    for i := 0 to length(parcelles) - 1 do
    begin
        // On scan la frame f
        for f := 0 to paterne.n - 1 do
        begin
            // On scan la parcelle
            for y := 0 to TAILLE_PARCELLE - 1 do
            begin
                // On scan la ligne
                for x := 0 to TAILLE_PARCELLE - 1 do
                begin
                    // On vérifie que le paterne match à partir de la cellule (x, y)
                    for yp := 0 to paterne.ty - 1 do
                    begin
                        p := i;
                        coY := yp + y;
                        existe := true;
                        if coY >= TAILLE_PARCELLE then
                        begin
                            // On continue sur la voisine
                            // On récupère la voisine du bas
                            p := self.parcelles[i].voisins.indexVoisin(existe, 0, 1);
                            coY := coY - TAILLE_PARCELLE;
                        end;
            
                        for xp := 0 to paterne.tx - 1 do
                        begin
                            coX := xp + x;
                            if coX >= TAILLE_PARCELLE then
                            begin
                                // On continue sur la voisine
                                // On récupère la voisine de droite
                                p := self.parcelles[p].voisins.indexVoisin(existe, 1, 0);
                                coX := coX - TAILLE_PARCELLE;
                            end;
                            // Les cases sont différentes ou la case du paterne est vivante mais la case n'existe pas
                            if ((self.parcelles[p].obtenirCellule(coX, coY)) xor (paterne.obtenirCellule(f, xp, yp))) or (not(existe) and (paterne.obtenirCellule(f, xp, yp))) then
                                goto XSuivant;

                        end;
                    end;
                    compteur := compteur + 1;
                    XSuivant:
                end;
                YSuivant:
            end;
        end;
    end;
    scanPaternes := compteur;
end;

end.