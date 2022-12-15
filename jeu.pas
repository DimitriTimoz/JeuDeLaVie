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
        (* Créer une parcelle en mémoire *)
        TextBackground(White);
        TextColor(0);
        setLength(self.plateau.parcelles, 0);

        self.camera.px := 0;
        self.camera.py := 0;
        self.camera.hauteur := HAUTEUR_CAM;
        self.camera.largeur := LARGEUR_CAM;

        self.vitesse := 900;
        self.tour := 0;
        self.enCours := false;

        menuAction();
    end;

    procedure TJeu.afficher();
    begin
        clrScr();
        self.plateau.afficher(self.camera);

        (* affiche les informations *)
        GotoXY(1, HAUTEUR_CAM + 1);
        write('Tour : ');
        write(tour);
        GotoXY(1, HAUTEUR_CAM + 2);
    end;


    procedure TJeu.modifierPlateau();
    var
        touche_pressee : Char;
    begin
        repeat
            clrScr();
            self.plateau.afficher(camera);
            GotoXY(LARGEUR_CAM div 2 + 1, HAUTEUR_CAM div 2 + 1);
            write('✚');

            (*Debug infos*)
            GotoXY(1, HAUTEUR_CAM + 2);
            writeln('x : ', camera.px + (LARGEUR_CAM div 2), ' y : ', camera.py + (HAUTEUR_CAM div 2));
            writeln('touchepressee : ', ord(touche_pressee));

            (* Gestion des touches *)
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
			GotoXY(1,i+2);
			TextColor(4);       
			write('ʘ');
			TextBackground(White);
			TextColor(0);
			GotoXY(1,10);

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
			
			if (i > 7) then
				i := 0
			else if (i < 0) then
				i := 7;
				
		until (c = ENTR);
			
		case i of
            0 : self.enCours := true;
            1 : self.modifierPlateau();
			2 : self.plateau.charger();
			3 : self.plateau.sauvegarder();
            4 : self.scanPaternes();
            5 : begin
                setLength(self.plateau.parcelles, 1);
                n_voisins.init(0, 0);
                self.plateau.parcelles[0].aleatoire(0, 0, n_voisins);
                self.enCours := true;
            end;
            6 : begin
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
        + 'sauvegarde de la partie en cours depuis l''interface de jeu : touche "s" puis entrer le nom de la sauvegarde (ex : "partie 1.txt")' + LineEnding
        + 'chargement d''une partie depuis l''interface de jeu :touche "l" puis entrer le nom du de la partie souhaitée' + LineEnding
        + 'ajout de cellule vivante : touche "entrée"' + LineEnding
        + 'suppression de cellule vivante : touche "retour"' + LineEnding
        + 'déplacement dans le menu : flèches haut/bas'  + LineEnding
        + 'déplacement de la caméra pour la partie en cours :' + LineEnding
        + 'mise en pause de la partie en cours :' + LineEnding
        + 'lancer la partie :');
    end;

    procedure TJeu.miseAJour();
    var 
        touche_pressee : Char;
    begin
    
        if (1000 - min(1000, vitesse) <= MilliSecondsBetween(Now, self.lastTime)) and self.enCours then
        begin
            self.lastTime := Now;
            self.tour := self.tour + 1;
            self.plateau.simuler();
            self.afficher();
        end;

        if not self.enCours then
            self.menuAction();

        if (keypressed()) then
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
