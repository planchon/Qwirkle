UNIT game;
INTERFACE
USES crt,
	constants  in 'core/constants.pas',
	structures in 'core/structures.pas',
	console    in 'uix/consoleUI/console.pas';

PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
FUNCTION remplirGrille(): grille;
PROCEDURE initPioche(nbrCouleurs, nbrFormes, nbrTuiles : INTEGER);
PROCEDURE shufflePioche;
FUNCTION creerMain: mainJoueur;
FUNCTION hasWon : BOOLEAN;
PROCEDURE removePionFromPioche(VAR main : mainJoueur; p : pion);
PROCEDURE echangerPioche(VAR main : mainJoueur);

IMPLEMENTATION
VAR
	globalPioche : typePioche;
	globalIndexPioche : INTEGER;

	PROCEDURE echangerPioche(VAR main : mainJoueur);
	VAR
		i, rand : INTEGER;
		tmp : pion;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			rand := random(globalIndexPioche);
			tmp := main[i];
			main[i] := globalPioche[rand];
			globalPioche[rand] := tmp;
		END;
	END;

	PROCEDURE initPioche(nbrCouleurs, nbrFormes, nbrTuiles : INTEGER);
	VAR
		piocheIndex, i, j, k : INTEGER;
	BEGIN
		setLength(globalPioche, nbrCouleurs * nbrFormes * nbrTuiles);
		piocheIndex := 0;

		// génération des pions en fonction des paramètres de départ
		FOR i := 0 TO nbrTuiles - 1 DO
		BEGIN
			FOR j := 1 TO nbrFormes DO
			BEGIN
				FOR k := 1 TO nbrCouleurs DO
				BEGIN
					globalPioche[piocheIndex].couleur := k;
					globalPioche[piocheIndex].forme   := j;
					inc(piocheIndex);
				END;
			END;
		END;
	END;

	PROCEDURE swap(a,b : INTEGER);
	VAR
		tmp : pion;
	BEGIN
		tmp := globalPioche[a];
		globalPioche[a] := globalPioche[b];
		globalPioche[b] := tmp;
	END;

	PROCEDURE swapLastMain(VAR main : mainJoueur; a: INTEGER);
	VAR
		tmp : pion;
	BEGIN
		tmp := main[a];
		main[a] := main[length(main) - 1];
		main[length(main) - 1] := tmp;
	END;

	PROCEDURE shufflePioche;
	VAR
		i : INTEGER;
	BEGIN
		Randomize;
		FOR i := 0 TO (length(globalPioche) - 1) * 3 DO
		BEGIN
			swap(random(length(globalPioche) - 1), random(length(globalPioche) - 1));
		END;
	END;

	// Quand on ajoute un pion à la grille on est sur que ce pion peut etre joué;
	PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
	BEGIN
		clrscr;
		g[x,y] := pionAAjouter;
		addToHistorique(pionAAjouter, x, y, joueur);
		renderGame(g);
	END;

	// Fonction qui permet d'initier une grille
	// avec des formes et couleurs nulle
	FUNCTION remplirGrille(): grille;
	VAR
		i , j    : INTEGER;
		g        : grille;
	BEGIN
		FOR i := 0 TO TAILLE_GRILLE -1 DO
		BEGIN
			FOR j := 0 TO TAILLE_GRILLE -1 DO
			BEGIN
				g[i,j].couleur := COULEUR_NULL;
				g[i,j].forme   := FORME_NULL;
			END;
		END;
		remplirGrille := g;
	END;

	PROCEDURE removeFromArray(VAR main : mainJoueur; i : INTEGER);
	BEGIN
		swapLastMain(main, i);
		setLength(main, length(main) - 1);
	END;

	PROCEDURE removePionFromPioche(VAR main : mainJoueur; p : pion);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			IF (p.couleur = main[i].couleur) and (p.forme = main[i].forme) THEN
				removeFromArray(main, i);
		END;
	END;

	FUNCTION hasWon : BOOLEAN;
	BEGIN
		hasWon := False;
	END;

	FUNCTION piocher : pion;
	BEGIN
		inc(globalIndexPioche);
		piocher := globalPioche[globalIndexPioche];
	END;

	FUNCTION creerMain: mainJoueur;
	VAR
		main : mainJoueur;
		i : INTEGER;
	BEGIN
		setLength(main, 6);
		FOR i := 0 TO 5 DO
			main[i] := piocher;
		creerMain := main;
	END;
END.