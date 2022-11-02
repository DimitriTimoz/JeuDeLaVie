unit Moteur;

interface
uses structures, utils, sysutils;

procedure ajouterCellule(var plateau: TPlateau; x, y: integer);
procedure supprimerCellule(var plateau: TPlateau; x, y: integer);
procedure sauvegarder_plateau(plateau: TPlateau);
procedure charger_plateau(var plateau: TPlateau);

implementation

procedure ajouterCellule(var plateau: TPlateau; x, y: integer);
begin
    SetBit(plateau.parcelles[0].lignes[y], x);
end;

procedure supprimerCellule(var plateau: TPlateau; x, y: integer);
begin
    ClearBit(plateau.parcelles[0].lignes[y], x);
end;

procedure sauvegarder_plateau(plateau: TPlateau);
var
    nom: String;
    f: Text;
    i, p: integer;
begin
    writeln('Sauvegarde du plateau');
    write('Nom du fichier : ');
    readln(nom);
    assign(f, nom + '.save');
    rewrite(f);

    (* Entête *)
    // 'nombre_parcelles'
    write(f, plateau.largeur); // Largeur en nombre de parcelles
    write(f, ' ');
    write(f, plateau.hauteur); // Hauteur en nombre de parcelles
    write(f, ' ');
    writeln(f, plateau.tailleParcelle); // taille d'une parcelle

    (* Parcelles *)
    for p := 0 to plateau.largeur * plateau.hauteur - 1 do
    begin
        write(f, plateau.parcelles[p].px);
        write(f, ' ');
        writeln(f, plateau.parcelles[p].py);
        for i := 0 to plateau.tailleParcelle - 1 do
        begin
            writeln(f, plateau.parcelles[0].lignes[i]);
        end;
    end;
    close(f);
end;

procedure charger_plateau(var plateau: TPlateau);
var
    nom, ligne: String;
    f: Text;
    i, p: integer;
begin
    
    repeat
        writeln('Charger un plateau');
        write('Nom du fichier : ');
        readln(nom);
        nom := nom + '.save';
    until FileExists(nom);
    
    assign(f, nom);
    reset(f);

    (* Entête *)
    // Format: 'largeur hauteur tailleParcelle'
    readln(f, ligne);
    plateau.largeur := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
    Delete(ligne, 1, Pos(' ', ligne));
    plateau.hauteur := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
    Delete(ligne, 1, Pos(' ', ligne));
    plateau.tailleParcelle := StrToInt(ligne);

    (* Parcelles *)
    GetMem(plateau.parcelles, SizeOf(TParcelle)*plateau.largeur*plateau.hauteur);
    for p := 0 to plateau.largeur * plateau.hauteur - 1 do
    begin
        readln(f, ligne);
        plateau.parcelles[p].px := StrToInt(Copy(ligne, 1, Pos(' ', ligne) - 1));
        Delete(ligne, 1, Pos(' ', ligne));
        plateau.parcelles[p].py := StrToInt(ligne);

        for i := 0 to plateau.tailleParcelle - 1 do
        begin
            readln(f, ligne);
            plateau.parcelles[p].lignes[i mod plateau.tailleParcelle] := StrToQWord(ligne);
        end;
    end;
    close(f);
end;
end.

