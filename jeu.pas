unit Jeu;


interface
uses structures, plateau, crt, sysutils, dateutils, math;

type 
    TJeu = object
        private
            plateau : TPlateau;
            camera : TCamera;
            paterne : TPaterne;
            vitesse: integer;
            lastTime: TDateTime;
        public
            enCours : boolean;  
            tour : integer;
            constructor init();
            procedure miseAJour();
            procedure afficher();
            procedure modifierPlateau();
            procedure afficherMenu();
            procedure menuAction();
    end;

    CONST UP = #72;
        DOWN = #80;
        LEFT = #75;
        RIGHT = #77;
        ENTR = #13;
        DEL = #8;
        SAVE = #115; // 's'
        LOAD = #108; // 'l'
        ESC = #27;

implementation

    constructor TJeu.init();
    var
        voisins: TVoisins;
    begin
        (* Créer une parcelle en mémoire *)
        TextBackground(White);
        TextColor(0);
        setLength(self.plateau.parcelles, 1);

        voisins.init(0, 0);
        self.plateau.parcelles[0].init(0, 0, voisins);

        (* Initialise une parcelle vide *)
        self.plateau.parcelles[0].nettoyer();
        
        self.camera.px := -LARGEUR_CAM div 2;
        self.camera.py := -HAUTEUR_CAM div 2;
        self.camera.hauteur := HAUTEUR_CAM;
        self.camera.largeur := LARGEUR_CAM;

        self.vitesse := 500;
        self.tour := 0;

        menuAction();
    end;

    procedure TJeu.afficher();
    begin
        clrScr();
        plateau.afficher(camera);

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
        begin
            clrScr();
            plateau.afficher(camera);
            GotoXY(LARGEUR_CAM div 2, HAUTEUR_CAM div 2);
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
                DEL: plateau.supprimerCellule(camera.px + (LARGEUR_CAM div 2) - 1, camera.py + (HAUTEUR_CAM div 2) - 1);
                ENTR: plateau.ajouterCellule(camera.px + (LARGEUR_CAM div 2) - 1, camera.py + (HAUTEUR_CAM div 2) - 1);
                SAVE: plateau.sauvegarder();
                LOAD: plateau.charger();
                ESC : break;
            end;
        end;
        until (touche_pressee = ESC);
    end;

    procedure TJeu.menuAction();
    var 
        c : Char;
        i : integer;
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
				ESC : break;
			end;
			
			if (i > 3) then
				i := 3
			else if (i <= 0) then
				i := 0;
				
		until (c = ENTR);
			
		case i of
			0 : writeln('');
			1 : writeln('');
			2 : modifierPlateau();
			3 : ClrScr;
		end;
			
    end;

    procedure TJeu.afficherMenu();
    begin 
        ClrScr;

        // Pour l'instant je mets juste un clearscreen et j'écris le menu dans le terminal mais après je l'améliorerais avec les flèches, faut juste que je retrouve comment faire //
        writeln('Que voulez vous faire : ');
        writeln('- Charger le plateau');
        writeln('- Sauvegarder le plateau');
        writeln('- Modifier le plateau');
        writeln('- Quitter le menu');

    end;

    procedure TJeu.miseAJour();
    var 
        touche_pressee : Char;
    begin
        if (1000 - min(1000, vitesse) <= MilliSecondsBetween(Now, self.lastTime)) then
        begin
            self.lastTime := Now;
            self.tour := self.tour + 1;
            self.plateau.simuler();
            self.afficher();
        end;

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
            end;

            // On vide le buffer de clavier
            while (keypressed()) do
                readkey();
        end;
    end;
end.