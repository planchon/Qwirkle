{
* 	CETTE UNIT EST RESPONSABLE DE TOUT L'AFFICHAGE CONSOLE.
*   C'EST ELLE QUI GERE TOUT L'ECRAN DE LA CONSOLE.
*   ELLE NE GERE PAS LES INPUTS OU LE MOTEUR DU JEU.
*   ELLE NE FAIT QUE LE RENDU
* }

UNIT console;
INTERFACE

USES constants  in 'core/constants.pas', crt,
	structures in 'core/structures.pas', sysutils;

TYPE
	// type primitif de tout ce qui peut être affiché à l'écran.
	printable = RECORD
		chr   : CHAR;
		tCol  : BYTE;
		bgCol : BYTE;
	END;

PROCEDURE render;
PROCEDURE renderGame(g : grille);
PROCEDURE renderMenuBorder();
PROCEDURE clearScreen (bgColor :  BYTE);
PROCEDURE renderPionInGrille(x,y : INTEGER; pion : pion);
PROCEDURE addToHistorique(p : pion; x, y : INTEGER; joueur : STRING);
PROCEDURE initConsole;
PROCEDURE renderPion(x,y : INTEGER; pion : pion);

IMPLEMENTATION
	VAR
		// Surface principale
		globalScreen : ARRAY [0..WIDTH - 1, 0..HEIGHT - 1] OF printable;
		historique   : ARRAY [0..12] OF dataHistorique;
		historiqueIndex : INTEGER;

	PROCEDURE initConsole;
	VAR
		i : INTEGER;
	BEGIN
		historiqueIndex := 0;
		FOR i := 0 TO length(historique) - 1 DO
		BEGIN
			historique[i].id := -1;
		END;
	END;

	// Affiche à l'écran le contenue de la surface générale (chez nous globalScreen)
	// en prenant en compte les couleurs et le BG.
	PROCEDURE render();
	VAR
		x,y : INTEGER;
	BEGIN
		FOR y := 0 TO HEIGHT - 1 DO
		BEGIN
			FOR x := 0 TO WIDTH - 1 DO
			BEGIN
				textcolor(globalScreen[x,y].tCol);
				TextBackground(globalScreen[x,y].bgCol);
				write(globalScreen[x,y].chr);
				textcolor(7);
				TextBackground(0);
			END;
			writeln;
		END;
	END;

	// Fais le rendu d'une ligne à la verticale ou à l'horizontale
	// Sont demandés en entrée les coordonnées des deux points des
	// extrémités de la ligne, la couleur de la ligne et son BG.
	PROCEDURE renderLine(x1, y1, x2, y2, tCol, bgCol : INTEGER);
	VAR
		x : INTEGER;
	BEGIN
		// ligne horizontale
		IF (x1 <> x2) and (y1 = y2) THEN
		BEGIN
			FOR x := x1 TO x2 DO
			BEGIN
				globalScreen[x, y1].chr   := '-';
				globalScreen[x, y1].tCol  := tCol;
				globalScreen[x, y1].bgCol := bgCol;
			END;
		END;

		// ligne verticale
		IF (x1 = x2) and (y1 <> y2) THEN
		BEGIN
			FOR x := y1 TO y2 DO
			BEGIN
				globalScreen[x1, x].chr   := '|';
				globalScreen[x1, x].tCol  := tCol;
				globalScreen[x1, x].bgCol := bgCol;
			END;
		END;
	END;

	// Vérifie si les coordonnées demandées sont dans l'écran ou non.
	// RETURN : TRUE si elles sont dans l'écran
	//        : FALSE si elles ne pas dans l'écran
	FUNCTION isInScreen(x,y : INTEGER) : BOOLEAN;
	BEGIN
		isInScreen := NOT((x < 0) or (x > WIDTH) or (y < 0) or (y > HEIGHT));
	END;

	// affiche un charactère à l'écran aux coordonnées x,y avec un texte de
	// couleur tCol et de bg bgCol (voir constantes.pas)
	PROCEDURE plot(chr : CHAR; x,y,tCol,bgCol : INTEGER);
	BEGIN
		IF isInScreen(x,y) THEN
		BEGIN
			globalScreen[x, y].bgCol := bgCol;
			globalScreen[x, y].tCol  := tCol;
			globalScreen[x, y].chr   := chr;
		END;
	END;

	// Créer les bordures du menu. Fait le rendu dans la surface globalScreen
	PROCEDURE renderMenuBorder();
	BEGIN
		renderLine(0, 0, WIDTH - 1, 0, 7, 0);
		renderLine(0, 0,         0, HEIGHT - 1, 7, 0);
		renderLine(0, HEIGHT - 1, WIDTH - 1, HEIGHT - 1, 7, 0);
		renderLine(WIDTH - 1, 0, WIDTH - 1, HEIGHT - 1, 7, 0);
		plot('+',0,0,7,0);
		plot('+',0,HEIGHT - 1,7,0);
		plot('+',WIDTH - 1,0,7,0);
		plot('+',WIDTH - 1,HEIGHT - 1,7,0);
	END;

	// Fais un simple rendu de texte aux coordonnées x,y avec un texte de
	// couleur tCol et de bg bgCol (voir constantes.pas)
	PROCEDURE renderText(text : STRING; x, y, tCol, bgCol : INTEGER);
	VAR
		i   : INTEGER;
		tmp : printable;
	BEGIN
		tmp.tCol  := tCol;
		tmp.bgCol := bgCol;
		FOR i := 1 TO length(text) DO
		BEGIN
			tmp.chr := text[i];
			globalScreen[i + x, y] := tmp;
		END;
	END;

	// ATTENTION !
	// on fait un rendu dans le référentiel de la grille, pas de l'écran.
	PROCEDURE renderPionInGrille(x,y : INTEGER; pion : pion);
	BEGIN
		plot(FOR_TAB[pion.forme,1], 2 * x - 1, y + 2, COL_WHITE, COL_TAB[pion.couleur]);
		plot(FOR_TAB[pion.forme,2],     2 * x, y + 2, COL_WHITE, COL_TAB[pion.couleur]);
	END;

	PROCEDURE renderPion(x,y : INTEGER; pion : pion);
	BEGIN
		plot(FOR_TAB[pion.forme,1],     x, y, COL_WHITE, COL_TAB[pion.couleur]);
		plot(FOR_TAB[pion.forme,2], x + 1, y, COL_WHITE, COL_TAB[pion.couleur]);
	END;

	PROCEDURE renderNodeHistorique(node : dataHistorique; i : INTEGER);
	BEGIN
		IF node.id >= 0 THEN
		BEGIN
			renderText('MOV ' + inttostr(node.id), 53, HEIGHT DIV 2 - 4 + i, COL_WHITE, COL_BLACK );
			CASE node.joueur OF
				'J1' : renderText(node.joueur, 60, HEIGHT DIV 2 - 4 + i, COL_LBLUE, COL_WHITE);
				'J2' : renderText(node.joueur, 60, HEIGHT DIV 2 - 4 + i, COL_LBLUE, COL_RED);
				ELSE renderText(node.joueur, 60, HEIGHT DIV 2 - 4 + i, COL_LBLUE, COL_WHITE);
			END;
			renderPion(64, HEIGHT DIV 2 - 4 + i, node.pion);
			renderText('x: ' + inttostr(node.posX), 67, HEIGHT DIV 2 - 4 + i, COL_GREEN, COL_BLACK);
			renderText(', y: ' + inttostr(node.posY), 73, HEIGHT DIV 2 - 4 + i, COL_GREEN, COL_BLACK);
		END;
	END;

	PROCEDURE renderHistorique;
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO 11 DO
		BEGIN
			renderNodeHistorique(historique[(historiqueIndex + i) MOD 12], i + 4);
		END;
	END;

	// fais le rendu de la grille de jeu dans sa globalité
	PROCEDURE renderGame(g : grille);
	VAR
		pionTest : pion;
		i,j : INTEGER;
	BEGIN
		pionTest.forme := FORME_ROND - 1;

		renderText('Qwirkle par Cyril et Paul :', 1, 1, COL_WHITE,COL_BLACK);

		renderLine(51,1,51, HEIGHT - 2, 7, 0);
		renderLine(0,2,51,2, 7, 0);
		plot('+',51,0,7,0);
		plot('+',51,HEIGHT - 1,7,0);
		plot('+',0,2,7,0);
		plot('+',51,2,7,0);

		renderText('*-* SCORES *-*', 62, 1, COL_WHITE, COL_BLACK);
		renderText('JOUEUR 1:', 53, 3, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 54, 5, COL_RED, COL_WHITE);

		renderText('JOUEUR 2:', 77, 3, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 78, 5, COL_LBLUE, COL_WHITE);

		renderText('JOUEUR 3:', 53, 7, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 54, 9, COL_GREEN, COL_WHITE);

		renderText('JOUEUR 4:', 77, 7, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 78, 9, COL_MAGENTA, COL_WHITE);

		renderLine(52 , 11, WIDTH - 2, 11, COL_WHITE, COL_BLACK);

		renderText('*-* HISTORIQUE *-*', 60,  12, COL_WHITE, COL_BLACK);

		renderHistorique;

		FOR i := 0 TO 24 DO
		BEGIN
			FOR j := 0 TO 24 DO
			BEGIN
				renderPionInGrille(i + 1, j + 1, g[i,j]);
			END;
		END;

		render;
	END;


	PROCEDURE addToHistorique(p : pion; x, y : INTEGER; joueur : STRING);
	BEGIN
		historique[historiqueIndex MOD 12].pion   := p;
		historique[historiqueIndex MOD 12].posX   := x;
		historique[historiqueIndex MOD 12].posY   := y;
		historique[historiqueIndex MOD 12].id     := historiqueIndex;
		historique[historiqueIndex MOD 12].joueur := joueur;
		inc(historiqueIndex);
	END;

	// efface l'écran en appliquant la couleur bgColor à tout l'écran.
	PROCEDURE clearScreen (bgColor :  BYTE);
	VAR
		x,y : INTEGER;
	BEGIN
		FOR x := 0 TO WIDTH - 1 DO
		BEGIN
			FOR y := 0 TO HEIGHT - 1 DO
			BEGIN
				globalScreen[x,y].tCol  := 7;
				globalScreen[x,y].bgCol := bgColor;
				globalScreen[x,y].chr   := ' ';
			END;
		END;
	END;
END.
