unit Jeu;


interface
uses structures, plateau, crt, logSys, sysutils, dateutils, math;

type 
    TJeu = object
        private
            plateau : TPlateau;
            camera : TCamera;
            paterne : TPaterne;
            vitesse: Int32;
            lastTime: TDateTime;
        public
            enCours : boolean;  
            tour : Int32;
            constructor init();
            procedure miseAJour();
            procedure afficher();
            procedure modifierPlateau();
            procedure afficherMenu();
            procedure menuAction();
            procedure scanPaternes();
    end;

    CONST UP = #72;
        DOWN = #80;
        LEFT = #75;
        RIGHT = #77;
        ENTR = #13;
        DEL = #8;
        ESC = #27;
        P = #112; // 'p'

implementation

    constructor TJeu.init();
    var
        voisins: TVoisins;
    begin
        TextBackground(White);
        TextColor(0);

        // Initialisation du tableau de parcelles
        setLength(self.plateau.parcelles, 0);

        // Initialisation de la caméra
        self.camera.px := 0;
        self.camera.py := 0;
        self.camera.hauteur := HAUTEUR_CAM;
        self.camera.largeur := LARGEUR_CAM;

        // Initialisation des paramètres
        self.vitesse := 800;
        self.tour := 0;
        self.enCours := false;
        
        menuAction();
    end;

    procedure TJeu.afficher();
    begin
        clrScr();
        self.plateau.afficher(self.camera);

        // Affiche les informations
        GotoXY(1, HAUTEUR_CAM + 1);
        write('Tour : ');
        write(tour);
    end;


    procedure TJeu.modifierPlateau();
    var
        touche_pressee : Char;
    begin
        repeat
            clrScr();
            self.plateau.afficher(camera);

            // Affiche le curseur
            GotoXY(LARGEUR_CAM div 2 + 1, HAUTEUR_CAM div 2 + 1);
            write('✚');

            // Informations diverses
            GotoXY(1, HAUTEUR_CAM + 2);
            writeln('x : ', camera.px + (LARGEUR_CAM div 2), ' y : ', camera.py + (HAUTEUR_CAM div 2));
            writeln('touchepressee : ', ord(touche_pressee));

            // Gestion des touches
            touche_pressee := readkey;
            case touche_pressee of
                #0: begin
                    touche_pressee := readkey;
                    case touche_pressee of
                        UP: camera.py := camera.py - 1;
                        DOWN: camera.py := camera.py + 1;
                        LEFT: camera.px := camera.px - 1;
                        RIGHT: camera.px := camera.px + 1;
                    end;
                end;
                DEL: plateau.supprimerCellule(camera.px + (LARGEUR_CAM div 2), camera.py + (HAUTEUR_CAM div 2));
                ENTR: plateau.ajouterCellule(camera.px + (LARGEUR_CAM div 2), camera.py + (HAUTEUR_CAM div 2));
                ESC : self.menuAction();
            end;
        until (touche_pressee = ESC);
        self.enCours := true;
    end;

    procedure TJeu.menuAction();
    var 
        c : Char;
        i : Int32;
        n_voisins : TVoisins;
    begin
		i := 0;
		repeat
            afficherMenu();

            // Affiche le curseur
			GotoXY(1,i+2);
			TextColor(4);       
			write('ʘ');
			TextBackground(White);
			TextColor(0);
			GotoXY(1,10);

            // Gestion des touches
			c := readkey;
			case c of
				#0: begin
					c := readkey;
					case c of
						UP: i := i - 1;
						DOWN: i := i + 1;
					end;
				end;
				ENTR: break;
				ESC : halt;
			end;

            // Gestion des erreurs de curseur
			if (i > 7) then
				i := 0
			else if (i < 0) then
				i := 7;
				
		until (c = ENTR);

        // Gestion des actions
		case i of
            0 : self.enCours := true; // Lancer la simulation
            1 : self.modifierPlateau(); // Modifier la simulation
			2 : self.plateau.charger(); // Charger une simulation
			3 : self.plateau.sauvegarder(); // Sauvegarder la simulation
            4 : self.scanPaternes(); // Scan le nombre de paternes
            5 : begin 
                // Créé une parcelle aléatoire
                setLength(self.plateau.parcelles, 1);
                n_voisins.init(0, 0);
                self.plateau.parcelles[0].aleatoire(0, 0, n_voisins);
                self.enCours := true;
            end;
            6 : begin
                // Modifier la vitesse
                ClrScr;
                write('Vitesse : ');
                readln(self.vitesse);
                self.vitesse := max(1, min(self.vitesse, 1000));
            end;  
			7 : halt;
		end;
			
    end;

    procedure TJeu.afficherMenu();
    begin 
        ClrScr;
        // Pour l'instant je mets juste un clearscreen et j'écris le menu dans le terminal mais après je l'améliorerais avec les flèches, faut juste que je retrouve comment faire //
        writeln('Que voulez vous faire : ');
        writeln('- Reprendre la simulation');
        writeln('- Modifier le plateau');
        writeln('- Charger le plateau');
        writeln('- Sauvegarder le plateau');
        writeln('- Scanner un paterne');
        writeln('- Carte aléatoire');
        writeln('- Vitesse de la simulation ( v = ' + IntToStr(self.vitesse) + ' / 1000)');
        writeln('- Quitter le jeu');

        writeln(LineEnding);
        writeln('Guide d''utilisation :' + LineEnding  
        + 'Sauvegarde de la partie en cours depuis le menu puis entrer le nom de la sauvegarde (ex partie1)")' + LineEnding
        + 'Chargement d''une partie depuis le menu  puis entrer le nom du de la partie souhaitée' + LineEnding
        + 'Ajout de cellule vivante : touche ENTREE' + LineEnding
        + 'Suppression de cellule vivante : touche RETOUR' + LineEnding
        + 'Déplacement dans le menu : flèches haut/bas'  + LineEnding
        + 'Déplacement de la caméra pour la partie en cours : flèches' + LineEnding
        + 'Mise en pause de la partie en cours ''P'' ou ENTREE' + LineEnding
        + 'lancer la partie :');
    end;

    procedure TJeu.miseAJour();
    var 
        touche_pressee : Char;
    begin

        // Calcul du temps écoulé depuis la dernière mise à jour pour ne pas bloquer la pile d'exécution
        if (1000 - min(1000, vitesse) <= MilliSecondsBetween(Now, self.lastTime)) and self.enCours then
        begin
            self.lastTime := Now;

            // Nouveau tour
            self.tour := self.tour + 1;
            self.plateau.simuler();
            self.afficher();
        end;

        // Hors simulation
        if not self.enCours then
            self.menuAction();

        // Déplacement de la caméra en jeu
        if keypressed() and self.enCours then
        begin
            touche_pressee := readkey();
            case touche_pressee of
                #0: begin
                    touche_pressee := readkey();
                    case touche_pressee of
                        UP: self.camera.py := self.camera.py - 1;
                        DOWN: self.camera.py := self.camera.py + 1;
                        LEFT: self.camera.px := self.camera.px - 1;
                        RIGHT: self.camera.px := self.camera.px + 1;
                    end;
                end;
                P, ESC: self.enCours := false;
            end;

            // On vide le buffer de clavier
            while (keypressed()) do
                readkey();
        end;
    end;

    procedure TJeu.scanPaternes();
    var 
        nom : String;
    begin
        ClrScr;
        nom := '';
        repeat
            if (nom <> '') then
                writeln('Le paterne n''existe pas.');

            writeln('Nom du paterne (''q'' pour quitter)');
            if (nom = 'q') then
                exit;

            readln(nom);
        until (FileExists('./paternes/' + nom + '.save'));
        writeln('Scan en cours...');
        writeln(self.plateau.scanPaternes('./paternes/' + nom + '.save'), ' résultat(s) trouvé(s) pour le paterne: ' + nom  + '.');
        writeln('Appuyez sur ENTRER pour continuer...');
        readln();
    end;
end.
