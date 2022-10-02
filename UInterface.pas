unit UInterface;

interface
    uses crt, Moteur, structures, utils, sysutils;

    CONST UP = #72;
        DOWN = #80;
        LEFT = #75;
        RIGHT = #77;
        ENTR = #13;
        DEL = #8;
        ESC = #27;
    procedure afficherPlateau(plateau: TPlateau);
    procedure afficher(jeu: TJeu);
    procedure modifierPlateau(var jeu: TJeu);
implementation
    procedure afficherPlateau(plateau: TPlateau);
    var
        x, y: integer;
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

        (* Affiche le plateau *)
        for x := 0 to plateau.tailleParcelle - 1 do
        begin
            for y := 1 to plateau.tailleParcelle  do
            begin
                GotoXY(x+1, y);
                if GetBit(plateau.parcelles[0].lignes[y], x) then
                    writeln('█')
                else
                    write(' ');
            end;
        end;
    end;

    procedure afficher(jeu: TJeu);
    begin
        clrScr(); (* efface l'écran *)

        afficherPlateau(jeu.plateau);

        (* affiche les informations *)
        GotoXY(1, jeu.plateau.tailleParcelle * jeu.plateau.hauteur + 1);
        write('Tour : ');
        write(jeu.tour);
    end;


    procedure modifierPlateau(var jeu: TJeu);
    var
        touche_pressee : Char;
        x, y: integer;
        nx, ny: integer;
    begin
        x := 0;
        y := 0;
        nx := 0;
        ny := 0;
        repeat
        begin
            clrScr();
            afficherPlateau(jeu.plateau);
            GotoXY(x+1, y+1);
            write('╳');

            (*Debug infos*)
            GotoXY(1, jeu.plateau.tailleParcelle * jeu.plateau.hauteur + 2);
            writeln('x : ', x, ' y : ', y);
            writeln('tailleParcelle : ', jeu.plateau.tailleParcelle);
            writeln('touchepressee : ', ord(touche_pressee));
            (* Gestion des touches *)
            touche_pressee := readkey;
            case touche_pressee of
                #0: begin
                    touche_pressee := readkey;
                    case touche_pressee of
                        UP: ny := y - 1;
                        DOWN: ny := y + 1;
                        LEFT: nx := x - 1;
                        RIGHT: nx := x + 1;
                    end;
                end;
                DEL: supprimerCellule(jeu.plateau, x, y);
                ENTR: ajouterCellule(jeu.plateau, x, y);
                ESC : break;
            end;

            if (ny >= 0) and (ny < jeu.plateau.tailleParcelle) then
                y := ny;
            if (nx >= 0) and (nx < jeu.plateau.tailleParcelle) then
                x := nx;
        end;
        until (touche_pressee = ESC);
    end;
end.