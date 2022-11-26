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
    procedure dessinerParcelle(parcelle: TParcelle; tailleParcelle: integer; camera: TCamera);

implementation

    procedure dessinerParcelle(parcelle: TParcelle; tailleParcelle: integer; camera: TCamera);
    var 
        debut_x, debut_y, offset_x, offset_y, fin_x, fin_y, x, y: integer;
    begin
        offset_x := parcelle.px - camera.px;
        offset_y := parcelle.py - camera.py;
        // Vérification que la parcelle est dans la zone d'affichage
        if (offset_x + tailleParcelle < 0) or (offset_y + tailleParcelle < 0) then
            exit
        else if (offset_x > LARGEUR_CAM) or (offset_y > HAUTEUR_CAM) then
            exit;

        // Calcul des coordonnées de fin d'affichage dans la parcelle
        if offset_x + tailleParcelle > LARGEUR_CAM then
            fin_x := LARGEUR_CAM - offset_x
        else
            fin_x := tailleParcelle;
        
        if offset_y + tailleParcelle > HAUTEUR_CAM then
            fin_y := HAUTEUR_CAM - offset_y
        else
            fin_y := tailleParcelle;

        // Calcul des coordonnées de début d'affichage dans la parcelle
        if offset_x < 0 then
        begin
            debut_x := -offset_x;
        end
        else
            debut_x := 0;

        if offset_y < 0 then
        begin
            debut_y := -(offset_y);
        end
        else
            debut_y := 0;

        // Affichage de la parcelle
        GotoXY(1, HAUTEUR_CAM + 9);
        writeln('debut: ', debut_x, ' ', debut_y, ' fin: ', fin_x, ' ', fin_y, ' offset: ', offset_x, ' ', offset_y);
        log('debut: ' + IntToStr(debut_x) + ' ' + IntToStr(debut_y) + ' fin: ' + IntToStr(fin_x) + ' ' + IntToStr(fin_y) + ' offset: ' + IntToStr(offset_x) + ' ' + IntToStr(offset_y));
        TextColor(0);       
        
        for y := debut_y to fin_y - 1 do
        begin
            for x := debut_x to fin_x - 1 do
            begin
                GotoXY(x + 1 + offset_x, y + offset_y + 1);
                if GetBit(parcelle.lignes[y], x) then
                begin
                    write('#');
                end
              
            end;
        end;

    end;

    procedure afficherPlateau(plateau: TPlateau; camera: TCamera);
    var
       cpx, cpy, x, y, i, ix, iy, prem_p_x, prem_p_y: integer;
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
            dessinerParcelle(plateau.parcelles[i], plateau.tailleParcelle, camera);
        end;
            
    end;

    procedure afficher(jeu: TJeu);
    begin
        //clrScr(); (* efface l'écran *)

        afficherPlateau(jeu.plateau, jeu.camera);

        (* affiche les informations *)
        GotoXY(1, jeu.plateau.tailleParcelle * jeu.plateau.hauteur + 1);
        write('Tour : ');
        write(jeu.tour);
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
            writeln('tailleParcelle : ', jeu.plateau.tailleParcelle);
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
                DEL: supprimerCellule(jeu.plateau, jeu.camera.px + (LARGEUR_CAM div 2) - 1, jeu.camera.py + (HAUTEUR_CAM div 2) - 1);
                ENTR: ajouterCellule(jeu.plateau, jeu.camera.px + (LARGEUR_CAM div 2) - 1, jeu.camera.py + (HAUTEUR_CAM div 2) - 1);
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
