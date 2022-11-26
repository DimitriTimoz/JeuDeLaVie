unit Jeu;


interface
uses structures, plateau, crt;

type 
    TJeu = object
        plateau : TPlateau;
        camera : TCamera;
        paterne : TPaterne;
        vitesse: integer;
        tour : integer;
        enCours : boolean;
        constructor init();
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
        {$IFDEF DARWIN}
        ESC = #27;
        {$ELSE}
        ESC = #81;
        {$ENDIF}
implementation

    constructor TJeu.init();
    var
        voisins: array[0..7] of TVoisin;
    begin
        (* Créer une parcelle en mémoire *)
        TextBackground(White);
        TextColor(0);
        setLength(plateau.parcelles, 1);

        plateau.parcelles[0].init(0, 0, voisins);

        (* Initialise une parcelle vide *)
        plateau.parcelles[0].nettoyer();
        
        camera.px := -LARGEUR_CAM div 2;
        camera.py := -HAUTEUR_CAM div 2;
        camera.hauteur := HAUTEUR_CAM;
        camera.largeur := LARGEUR_CAM;

        tour := 0;

        menuAction();
    end;

    procedure TJeu.afficher();
    begin
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
        x, y: integer;
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
end.