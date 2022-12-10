unit Jeu;


interface
uses structures, plateau, crt, logSys, sysutils, dateutils, math;

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
        P = #112; // 'p'

implementation

    constructor TJeu.init();
    var
        voisins: TVoisins;
    begin
        (* Créer une parcelle en mémoire *)
        clearLog();
        TextBackground(White);
        TextColor(0);
        setLength(self.plateau.parcelles, 0);

        
        self.camera.px := -LARGEUR_CAM div 2;
        self.camera.py := -HAUTEUR_CAM div 2;
        self.camera.hauteur := HAUTEUR_CAM;
        self.camera.largeur := LARGEUR_CAM;

        self.vitesse := 750;
        self.tour := 0;
        self.enCours := true;

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
        begin
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
                SAVE: plateau.sauvegarder();
                LOAD: plateau.charger();
                ESC : self.menuAction();
            end;
        end;
        until (touche_pressee = ESC);
        self.enCours := true;
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
				ESC : halt;
			end;
			
			if (i > 4) then
				i := 4
			else if (i <= 0) then
				i := 0;
				
		until (c = ENTR);
			
		case i of
            0 : self.enCours := true;
			1 : self.plateau.charger();
			2 : self.plateau.sauvegarder();
			3 : self.modifierPlateau();
			4 : halt;
		end;
			
    end;

    procedure TJeu.afficherMenu();
    begin 
        ClrScr;

        // Pour l'instant je mets juste un clearscreen et j'écris le menu dans le terminal mais après je l'améliorerais avec les flèches, faut juste que je retrouve comment faire //
        writeln('Que voulez vous faire : ');
        writeln('- Reprendre la simulation');
        writeln('- Charger le plateau');
        writeln('- Sauvegarder le plateau');
        writeln('- Modifier le plateau');
        writeln('- Quitter le jeu');

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
                P : begin 
                    self.enCours := false;
                    self.menuAction();
                end;
                ESC: halt;
            end;

            // On vide le buffer de clavier
            while (keypressed()) do
                readkey();
        end;
    end;
end.