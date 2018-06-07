UNIT game;
INTERFACE
USES crt, sysutils, constants, structures, console;

PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
FUNCTION remplirGrille(): grille;
PROCEDURE initPioche(nbrCouleurs, nbrFormes, nbrTuiles : INTEGER);
PROCEDURE shufflePioche;
FUNCTION creerMain: mainJoueur;
FUNCTION hasWon(joueur : typeJoueur) : BOOLEAN;
PROCEDURE removePionFromPioche(VAR main : mainJoueur; p : pion);
PROCEDURE echangerPioche(VAR main : mainJoueur);
PROCEDURE initJoueur(nbrJoueurHumain, nbrJoueurMachine : INTEGER);
FUNCTION piocher : pion;
FUNCTION getPiocheSize : INTEGER;

IMPLEMENTATION
VAR
	globalPioche : typePioche;
	globalIndexPioche : INTEGER;
	globalHumain : INTEGER;
	globalMachine : INTEGER;
	gNbrCouleurs, gNbrFormes, gNbrTuiles : INTEGER;

	FUNCTION getPiocheSize : INTEGER;
	BEGIN
		getPiocheSize := gNbrFormes * gNbrTuiles * gNbrCouleurs - globalIndexPioche;
	END;

	PROCEDURE echangerPioche(VAR main : mainJoueur);
	VAR
		i, rand : INTEGER;
		tmp : pion;
	BEGIN
		IF globalIndexPioche + 6 < gNbrCouleurs * gNbrFormes * gNbrTuiles THEN
		BEGIN
			FOR i := 0 TO length(main) - 1 DO
			BEGIN
				rand := random(globalIndexPioche);
				tmp := main[i];
				main[i] := globalPioche[rand];
				globalPioche[rand] := tmp;
			END;
		END;
	END;

	PROCEDURE initPioche(nbrCouleurs, nbrFormes, nbrTuiles : INTEGER);
	VAR
		piocheIndex, i, j, k : INTEGER;
	BEGIN
		setLength(globalPioche, nbrCouleurs * nbrFormes * nbrTuiles);
		piocheIndex := 0;
		gNbrFormes := nbrFormes;
		gNbrTuiles := nbrTuiles;
		gNbrCouleurs := nbrCouleurs;
		globalIndexPioche := 0;

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

	PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
	BEGIN
		g[x,y] := pionAAjouter;
		addToHistorique(pionAAjouter, x, y, joueur);
	END;

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

	FUNCTION removeFromArray(main : mainJoueur; i : INTEGER) : mainJoueur;
	BEGIN
		swapLastMain(main, i);
		setLength(main, length(main) - 1);
		removeFromArray := main;
	END;

	PROCEDURE removePionFromPioche(VAR main : mainJoueur; p : pion);
	VAR
		i, indexToRemove : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			IF (p.couleur = main[i].couleur) and (p.forme = main[i].forme) THEN
				indexToRemove := i;
		END;
		main := removeFromArray(main, indexToRemove);
	END;

	PROCEDURE initJoueur(nbrJoueurHumain, nbrJoueurMachine : INTEGER);
	BEGIN
		globalHumain  := nbrJoueurHumain;
		globalMachine := nbrJoueurMachine;
		renderJoueurText(nbrJoueurHumain, nbrJoueurMachine);
	END;

	FUNCTION hasWon(joueur : typeJoueur) : BOOLEAN;
	BEGIN
		IF ((length(joueur.main) = 0) AND (globalIndexPioche >= gNbrCouleurs * gNbrFormes * gNbrTuiles)) THEN
		BEGIN
			joueur.score := joueur.score + 6;
			hasWon := TRUE;
		END
		ELSE
			hasWon := FALSE;
	END;

	FUNCTION piocher : pion;
	BEGIN
		IF globalIndexPioche < gNbrCouleurs * gNbrFormes * gNbrTuiles THEN
		BEGIN
			inc(globalIndexPioche);
			piocher := globalPioche[globalIndexPioche];
		END
		ELSE
			piocher := PION_NULL;
	END;

	FUNCTION creerMain: mainJoueur;
	VAR
		main : mainJoueur;
		i : INTEGER;
	BEGIN
		WriteLn('output');
		setLength(main, 6);
		FOR i := 0 TO 5 DO
			main[i] := piocher;
		creerMain := main;
	END;
END.
