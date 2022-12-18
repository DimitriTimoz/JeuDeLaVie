program main;

uses structures, crt, jeu, logSys;

var 
    partie: TJeu;
begin
    clearLog(); // On vide le fichier de log
    
    partie.init();
    repeat
        partie.miseAJour();
    until False; // On boucle infiniment mais des 'Halt' sont placés dans le code pour arrêter le programme
end.

