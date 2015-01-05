%% Prédicat de manipulation de graphe.

%% On verifie que la liste des étiquettes du sommet contient une sous liste de la liste des étiquettes demandées.
contientEtiquette([],_):-!.

contientEtiquette([H|T], [H|T1]) :- contientEtiquette(T,T1), !.

contientEtiquette(L1,[_|T1]) :- contientEtiquette(L1, T1).

%%ou

%%contientEtiquette([H1], [H2]) :- H1=H2, !.

%%contientEtiquette([H2|_], LESommet) :- member(H2,LESommet), !.

%%contientEtiquette([H2|T2], LESommet) :- \+ member(H2,LESommet), contientEtiquette(T2,LESommet).


%% On récupère la liste des sommets qui contiennent une sous liste de la liste des étiquettes demandées et la liste des sommets qui ne la contiennent pas.
listeSommets([],_,[],[]):- !.

listeSommets(Graphe,ListeEtiquette, [NomS], []):-
    Graphe = [[ListeEtiquetteS,[NomS|_]]],
    contientEtiquette(ListeEtiquette, ListeEtiquetteS), !.

listeSommets(Graphe,ListeEtiquette, [NomS|TSommets], ListeNonConforme):- 
    Graphe = [[ListeEtiquetteS,[NomS|_]]|TG],
    contientEtiquette(ListeEtiquette,ListeEtiquetteS),
    listeSommets(TG,ListeEtiquette, TSommets, ListeNonConforme), !.

listeSommets(Graphe,ListeEtiquette, ListeSommets, [HListeNonConforme|TListeNonConforme]):-
    Graphe = [[ListeEtiquetteS,[NomS|_]]|TG],
    \+ contientEtiquette(ListeEtiquette,ListeEtiquetteS),
    HListeNonConforme = NomS,
    listeSommets(TG,ListeEtiquette, ListeSommets, TListeNonConforme).


%% On vérifie qu'au moins un élément de la première liste est contenu dans la seconde.
memberListe([H1],L2):- member(H1,L2), !.

memberListe([H1|T1],L2):-
    \+ T1=[],
    member(H1,L2), !.

memberListe([H1|T1],L2):-
    \+ T1=[],
    \+ member(H1,L2),
    memberListe(T1,L2).


%% On parcourt le graphe pour récupérer, dans le graphe, les sommets demandés(contenant les étiquettes voulues)
parcours_graphe([],_,[]):- !.

parcours_graphe(Graphe, Liste, [HGR|TGR]):-
    Graphe = [Sommet|TG],
    Sommet = [_,[NomS|Succ]],
    member(NomS,Liste),
    memberListe(Liste,Succ),
    HGR=Sommet,
    parcours_graphe(TG,Liste,TGR), !.

parcours_graphe(Graphe, Liste, GR):- 
    Graphe = [Sommet|TG],
    Sommet = [_,[NomS|Succ]],
    member(NomS,Liste),
    \+ memberListe(Liste,Succ),
    parcours_graphe(TG,Liste,GR).

parcours_graphe(Graphe, Liste, GR):- 
    Graphe = [Sommet|TG],
    Sommet = [_,[NomS|_]], 
    \+ member(NomS,Liste),
    parcours_graphe(TG,Liste,GR).


%% On renvoie le sous_graphe induit par les étiquettes demandées.
sous_graphe([],_,[]):- !.

sous_graphe(Graphe, ListeEtiquette, []):-
    listeSommets(Graphe,ListeEtiquette,L,_),
    L=[].

sous_graphe(Graphe, ListeEtiquette, Graphe):-
    listeSommets(Graphe,ListeEtiquette,_,LNC),
    LNC=[].

sous_graphe(Graphe, ListeEtiquette, G1):- 
	listeSommets(Graphe,ListeEtiquette,L,LNC),
	\+ L=[],
	\+ LNC = [],
	parcours_graphe(Graphe, L, GTemp),
	supprimer_liste_sommet_succ(LNC,GTemp,G1).

	
%% Prédicat qui supprimer les sommets contenus dans une listes des successeurs de tous les sommets d'un graphe.
supprimer_liste_sommet_succ(_,[],[]).

supprimer_liste_sommet_succ([],Graphe,Graphe).

supprimer_liste_sommet_succ([HL|TL],Graphe,G):- 
	supprimer_sommet_succ(HL, Graphe, TempGraphe),
	supprimer_liste_sommet_succ(TL,TempGraphe,G).


%% Sauvegarde d'un graphe à l'aide d'un prédicat dynamique. Nous pourrons ensuite sauvegarder ce graphe dans un fichier.
sauvegardeGraphe(Nom,GrapheReduit):-
    retractall(sauvegarde(_,_,_)),
    assert(sauvegarde(sousgraphetxt,Nom,GrapheReduit)),
    assert(sauvegarde(sousgraphedot,Nom,GrapheReduit)),!.

%% Prédicat qui récupère le degré d'un sommet donné.
degreSommet(_,[],0):- !.

degreSommet(NomS,[_|T],N):-
    degreSommet(NomS,T,N1),
    N is N1 + 1.


%% Prédicat qui calcule le graphe abstrait du graphe d'origine.
abstraction_graphe(Graphe,Degre,Graphe):- 
    listeSommetsDegre(Graphe,Degre,_, ListeSommetNonConforme),
    ListeSommetNonConforme = [], !.

abstraction_graphe(Graphe,Degre,Resultat):- 
    listeSommetsDegre(Graphe,Degre,ListeSommetDegre, ListeSommetNonConforme),
    ListeSommetNonConforme = [H|_],
    parcours_graphe(Graphe,ListeSommetDegre,NewGraphe),
    supprimer_sommet_succ(H, NewGraphe, NG),
    abstraction_graphe(NG,Degre,Resultat).


%% Prédicat qui retourne la liste des sommets qui ont un degré supérieur ou égal au degré demandé et qui sont présent dans un graphe dans une liste et qui mette les autres sommets dans une autre liste.
listeSommetsDegre([],_,[],[]):- !.

listeSommetsDegre(Graphe,Degre, [NomS],[]):-
    Graphe = [[_,[NomS|Succ]]],
    degreSommet(NomS,Succ, DegreSommet),
    DegreSommet >= Degre, !.

listeSommetsDegre(Graphe,Degre,ListeSommetDegre,[HLNC|TLNC]):-
    Graphe = [Sommet|TG],
    Sommet = [_,[NomS|Succ]],
    degreSommet(NomS,Succ,DegreSommet),
    \+ DegreSommet >= Degre,
    HLNC = NomS,
    listeSommetsDegre(TG, Degre, ListeSommetDegre, TLNC), !.

listeSommetsDegre(Graphe,Degre,[HTLSD|TLSD],ListeNonConforme):-
    Graphe = [Sommet|TG],
    Sommet = [_,[NomS|Succ]],
    degreSommet(NomS,Succ,DegreSommet),
    DegreSommet >= Degre,
    HTLSD = NomS,
    listeSommetsDegre(TG, Degre, TLSD, ListeNonConforme).

