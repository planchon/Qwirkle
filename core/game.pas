UNIT game;
INTERFACE
USES constants, structures,crt,
	console in 'uix/consoleUI/console.pas';

PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
FUNCTION remplirGrille(): grille;
PROCEDURE initPioche;
PROCEDURE shufflePioche;
FUNCTION creerMain: mainJoueur;


IMPLEMENTATION
VAR
	globalPioche : typePioche;
	globalIndexPioche : INTEGER;

	PROCEDURE initPioche;
	VAR
		piocheIndex, i, j, k : INTEGER;
	BEGIN
		piocheIndex := 0;
		// tous les pions sont en triple
		FOR i := 0 TO 2 DO
		BEGIN
			FOR j := 1 TO 6 DO
			BEGIN
				FOR k := 1 TO 6 DO
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

	PROCEDURE shufflePioche;
	VAR
		i : INTEGER;
	BEGIN
		Randomize;
		FOR i := 0 TO SHUFFLE_PRECISION DO
		BEGIN
			swap(random(107), random(107));
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
