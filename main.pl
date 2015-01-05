:- dynamic graphe/2.
:- dynamic sauvegarde/3.


%% Menu général, on doit le lancer pour démarrer le programme. Et ainsi pouvoir faire des intaractions machine -- utilisateur.
menu :- 
    repeat,
    nl,
    writeln('1 : Charger le fichier contenant le graphes'),
    writeln('2 : Sauvegarder le ficher'),
    writeln('3 : Faire des manipulations sur les graphes'),
    writeln('4 : Afficher le graphe (fichier graphe.dot)'),
    writeln('5 : Quitter'),
    read(X),
    between(1,5,X),
    choix(X),
    finimenu(X),!.


%% Menu de chargement d'un fichier.
menuChargement:- writeln('Veuillez entrer le nom du fichier txt (sans extension txt) que vous voulez charger'), 
		 read(X),
		 choix(1,X),
		 finimenu(3),!.


%% Menu d'affichage d'un graphe.
menuAffichage :- 
    writeln('Veuillez entrer le nom du fichier dot (sans extension dot) du graphe que vous voulez afficher'),
    read(X),
    choix(2,X),
    finimenu(3),!.


%% Prédicat pour les différentes actions du menu.
choix(1):- retractall(graphe(_,_)), menuChargement.
choix(2):- sauverTxt, sauverDot, !.
choix(3):- [predicats_manip],!.
choix(4):- menuAffichage.
choix(5):-retractall(graphe(_,_)), retractall(sauvegarde(_,_,_)), !.


%% Prédicat pour le menuChargement.
choix(1,X):- charger(X), !.


%% Prédicat pour le menuAffichage.
choix(2,X):- afficher_graphe(X),!.


%% Break de la boucle infini dans les menus.
finimenu(X):- X=3.
finimenu(X):- X=4.
finimenu(X):- X=5.


%% Prédicat qui va charger un fichier donné en paramètre.
charger(X):- 
    chargerTxt(X,NomFichier),
    open(NomFichier, read, S),
    read(S,H1),
    close(S),
    writeln(''),
    writeln('Voici le graphe que nous vous proposons :'),
    writeln(H1),
    assert(H1),
    nl,
    writeln('').


%% Récupération du nom de fichier avec l'extension .txt.
chargerTxt(X,NomFichier):- 
    string_to_atom(X,S1),
    string_to_atom('.txt',S2),
    string_concat(S1,S2,N),
    name(NomFichier,N).


%% Prédicat qui va sauvegarder dans un fichier .txt le graphe que nous avons dans la base de connaissance à l'aide des prédicats dynamiques.
sauverTxt:- 
    sauvegarderTxt(X,Y,NomGraphe),
    open(Y, write, SO),
    write(SO,'graphe('),
    close(SO),
    open(Y, append, S),
    write(S,NomGraphe),
    write(S,','),
    write(S,X),
    write(S,').'),
    close(S),
    writeln(''),
    writeln('Vous avez sauvegarder votre graphe en .txt :'),
    writeln(X).


%% Prédicat qui recupère l'instance du prédicat dynamique et qui récupère le nom du fichier avec l'extension .txt. On récupère également le nom et la représentation du graphe.
sauvegarderTxt(X,Y,YTemp):- 
    sauvegarde(sousgraphetxt,NomFichier,X),
    name(YTemp,NomFichier),
    string_to_atom('.txt',S2),
    string_to_atom(NomFichier,S1),
    string_concat(S1,S2,Nom),
    name(Y,Nom).


%% Prédicat qui va sauvegarder dans un fichier .dot le graphe que nous avons dans la base de connaissance à l'aide des prédicats dynamiques.
sauverDot:- 
    sauvegarderDot(X,NomFichier),
    open(NomFichier, write, SO),
    write(SO,'graph G{'),
    close(SO),
    open(NomFichier, append, S),
    recupererFormatDot(X,FormatDot),
    write(S,FormatDot),
    write(S,'}'),
    close(S),
    writeln(''),
    writeln('Vous avez sauvegarder votre graphe en .dot :'),
    writeln(FormatDot).


%% Prédicat qui récupère l'instance du predicat dynamique et qui récupère le nom du fichier avec l'extension .dot. On récupère également la représentation du graphe associé au nom de fichier.
sauvegarderDot(X,Y):- 
    sauvegarde(sousgraphedot,NomFichier,X),
    string_to_atom(NomFichier,S1),
    string_to_atom('.dot',S2),
    string_concat(S1,S2,Nom),
    name(Y,Nom).


%% Prédicat qui met en forme le texte contenu dans le .dot. Partie successeur d'un sommet.
recupererFormatDotSucc(_,[],''):- !.

recupererFormatDotSucc(X,[H|T],FormatDotSucc):-
    string_to_atom(X, S1),
    string_to_atom('--', S2),
    string_to_atom(H,S3),
    string_to_atom(';', S4),
    string_concat(S1,S2,Liaison1),
    string_concat(Liaison1,S3,Liaison),
    string_concat(Liaison,S4,LigneLiaison),
    recupererFormatDotSucc(X,T,NewFormatSucc),
    string_concat(LigneLiaison,NewFormatSucc, FormatDotSucc).


%% Prédicat qui met en forme le texte contenu dans le .dot.
recupererFormatDot([],''):- !.

recupererFormatDot([Sommet|TG],FormatDot):-
    Sommet = [_,[NomS|Succ]],
    string_to_atom(NomS, S1),
    string_to_atom(';', S2),
    string_concat(S1,S2, LigneSommet),
    recupererFormatDotSucc(NomS,Succ,Liaison),
    string_concat(LigneSommet,Liaison, DataSommet),
    supprimer_sommet_succ(NomS, TG, NewTG),
    recupererFormatDot(NewTG,NewFormatDot),
    string_concat(DataSommet, NewFormatDot, FormatDot),!.


%% Prédicat qui supprime un sommet d'une liste.
supprimer_liste(_,[],[]):- !.

supprimer_liste(X,[X|T], T):- !.

supprimer_liste(X,[H|T], [H|TL]):- 
    \+ H=X,
    supprimer_liste(X,T,TL).


%% Prédicat qui supprime un sommet dans la liste des successeurs de chacun des autres sommets du graphe (pour éviter les doublons ex: a--b, b--a).
supprimer_sommet_succ(_,[],[]):- !.

supprimer_sommet_succ(X,[H|T], NG):- 
    H = [_,[X|_]],
    supprimer_sommet_succ(X,T,NG), !.

supprimer_sommet_succ(X,[H|T], [HNG|TNG]):- 
    H = [A,[B|Succ]],
    member(X,Succ),
    supprimer_liste(X,Succ, NewSucc),
    HNG = [A,[B|NewSucc]],
    supprimer_sommet_succ(X,T,TNG), !.

supprimer_sommet_succ(X,[H|T], [H|TNG]):-
    H = [_,[_|Succ]],
    \+ member(X,Succ),
    supprimer_sommet_succ(X,T,TNG), !.


%% Prédicat qui permet d'afficher un graphe associé à un fichier .dot. (erreur lors de la lecture du fichier end_of_file).
afficher_graphe(X):-
    afficherDot(X,NomFichier),
    open(NomFichier, read, S),
    read(S,H1),
    close(S),
    writeln(''),
    writeln('Voici votre graphe :'),
    writeln(H1),
    nl,
    writeln('').

%% Prédicat qui récupère le nom du fichier avec l'extension .dot pour pouvoir ouvrir celui-ci ensuite.
afficherDot(X,NomFichier):- 
    string_to_atom(X,S1),
    string_to_atom('.dot',S2),
    string_concat(S1,S2,N),
    name(NomFichier,N).
