unit UInterface;

interface
    uses crt, Moteur, structures, utils, sysutils, logSys;

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
    procedure afficherPlateau(plateau: TPlateau; camera: TCamera);
    procedure afficher(jeu: TJeu);
    procedure modifierPlateau(var jeu: TJeu);
    procedure afficherMenu(var jeu: Tjeu);
    procedure menuAction(var jeu: TJeu);

implementation

   

    procedure afficherPlateau(plateau: TPlateau; camera: TCamera);
    var
       i: integer;
    begin
        (* Vérifie l'existence d'un plateau *)
        if plateau.largeur * plateau.hauteur <= 0 then
        begin
            writeln('Le plateau n''est pas initialisé');
            exit;
        end
        else if plateau.largeur * plateau.hauteur <> 1 then
        begin
            writeln('Le plateau ne contient pas qu''une seule parcelle. Le support de plusieurs parcelles n''est pas encore implémenté');
            exit;
        end;
        log('new frame');
        (* Affichage du plateau *)
        for i := 0 to length(plateau.parcelles) - 1 do
        begin
            plateau.parcelles[i].afficher(camera);
        end;
            
    end;

    procedure afficher(jeu: TJeu);
    begin
        afficherPlateau(jeu.plateau, jeu.camera);

        (* affiche les informations *)
        GotoXY(1, HAUTEUR_CAM + 1);
        write('Tour : ');
        write(jeu.tour);
        GotoXY(1, HAUTEUR_CAM + 2);
    end;


    procedure modifierPlateau(var jeu: TJeu);
    var
        touche_pressee : Char;
        x, y: integer;
    begin
        repeat
        begin
            clrScr();
            afficherPlateau(jeu.plateau, jeu.camera);
            GotoXY(LARGEUR_CAM div 2, HAUTEUR_CAM div 2);
            write('✚');

            (*Debug infos*)
            GotoXY(1, HAUTEUR_CAM + 2);
            writeln('x : ', jeu.camera.px + (LARGEUR_CAM div 2), ' y : ', jeu.camera.py + (HAUTEUR_CAM div 2));
            writeln('touchepressee : ', ord(touche_pressee));

            (* Gestion des touches *)
            touche_pressee := readkey;
            case touche_pressee of
                #0: begin
                    touche_pressee := readkey;
                    case touche_pressee of
                        UP: jeu.camera.py := jeu.camera.py - 1;
                        DOWN: jeu.camera.py := jeu.camera.py + 1;
                        LEFT: jeu.camera.px := jeu.camera.px - 1;
                        RIGHT: jeu.camera.px := jeu.camera.px + 1;
                    end;
                end;
                DEL: supprimerCellulePlateau(jeu.plateau, jeu.camera.px + (LARGEUR_CAM div 2) - 1, jeu.camera.py + (HAUTEUR_CAM div 2) - 1);
                ENTR: ajouterCellulePlateau(jeu.plateau, jeu.camera.px + (LARGEUR_CAM div 2) - 1, jeu.camera.py + (HAUTEUR_CAM div 2) - 1);
                SAVE: sauvegarder_plateau(jeu.plateau);
                LOAD: charger_plateau(jeu.plateau);
                ESC : break;
            end;
        end;
        until (touche_pressee = ESC);
    end;

    procedure menuAction(var jeu: TJeu);
    var 
        c : Char;
        i : integer;
        
    begin
		i := 0;
		repeat
			afficherMenu(jeu);
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
			2 : modifierPlateau(jeu);
			3 : ClrScr;
		end;
			
    end;

    procedure afficherMenu(var jeu: Tjeu);
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
