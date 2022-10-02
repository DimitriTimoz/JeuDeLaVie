unit UInterface;

interface
    uses crt, structures, utils;
    procedure afficher(jeu: TJeu);

implementation
    procedure afficher(jeu: TJeu);
    var
        x, y: integer;
    begin
        clrScr(); (* efface l'écran *)

        (* Vérifie l'existence d'un plateau *)
        if jeu.plateau.largeur * jeu.plateau.hauteur <= 0 then
        begin
            writeln('Le plateau n''est pas initialisé');
            exit;
        end
        else if jeu.plateau.largeur * jeu.plateau.hauteur <> 1 then
        begin
            writeln('Le plateau ne contient pas qu''une seule parcelle. Le support de plusieurs parcelles n''est pas encore implémenté');
            exit;
        end;

        (* Affiche le plateau *)
        for x := 0 to jeu.plateau.tailleParcelle - 1 do
        begin
            for y := 1 to jeu.plateau.tailleParcelle  do
            begin
                GotoXY(x+1, y);
                if GetBit(jeu.plateau.parcelles[0].lignes[y], x) then
                    writeln('█')
                else
                    write(' ');
            end;
        end;
    end;
end.