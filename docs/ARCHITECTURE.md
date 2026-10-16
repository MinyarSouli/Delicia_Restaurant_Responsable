# Contexte du projet : application CLIENT de restaurant

## Présentation

Mini-projet « Groupe 5 » du module Développement Mobile Cross-plateformes.
Enseignante : Mme Bel Haj Sghaier Ghalia. Date limite : 30 novembre 2026, 23h59.
Livrables : lien du dépôt GitHub et présentation PowerPoint.

Ce dépôt contient uniquement l'application CLIENT. L'application RESPONSABLE
est développée par la binôme dans un autre dépôt : ne jamais la modifier.

## Fonctionnalités attendues (côté client)

- Consulter le menu par catégories : Fast-food, Plats, Café, Boissons, Desserts.
- Voir le détail d'un plat : image, description, prix.
- Choisir des suppléments et une quantité.
- Gérer un panier et afficher l'addition avec la TVA.
- Confirmer la commande (identification obligatoire).
- Générer un PDF de la commande.
- Envoyer la commande au Responsable.
- Consulter l'historique de ses commandes.

## Parcours imposé par l'enseignante

Menu -> Détail du plat -> Panier -> « Confirmer la commande ».

- Si le client n'a pas de compte : écran d'inscription (register).
- Sinon : écran de connexion (login).
- Après la connexion : petite boîte de dialogue pour saisir le numéro de table.

## Barème

Fonctionnalités 50 %, qualité du code 20 %, architecture et sécurité 20 %, travail d'équipe 10 %.

## État actuel du code

- Menu avec recherche, catégories (ChoiceChip) et grille responsive.
- Page de détail avec suppléments et quantité (animation Hero).
- Panier géré par CartService (ChangeNotifier, singleton).
- Inscription / connexion avec AuthService (comptes en mémoire, sans base de données).
- Boîte de dialogue du numéro de table.
- Prix affichés au format « 12.500 DT ».

## Règles de travail pour l'agent

1. L'application doit rester fonctionnelle après chaque modification.
2. Faire de petites modifications ciblées. Ne pas réécrire un fichier entier sans raison.
3. Ne jamais toucher au projet de l'application Responsable.
4. Code simple, commenté en français, adapté à une étudiante débutante.
5. Pas de dart:io dans le code partagé : l'application doit tourner sur le web (Chrome).
6. Toute chaîne visible par l'utilisateur est en français.
7. Respecter l'architecture décrite dans docs/ARCHITECTURE.md.
8. Après chaque tâche : indiquer les fichiers modifiés et lancer `flutter analyze`.
9. Ne pas ajouter de dépendance sans l'indiquer et l'expliquer.
10. Ne pas supprimer de fichier sans accord explicite.

## Décisions encore ouvertes

- Nom du restaurant (utilisé par le thème et l'écran d'accueil).
- Prix en HT ou TTC et taux de TVA à confirmer avec l'enseignante (7 % supposé).
- Structure Firebase à coordonner avec la binôme avant d'y brancher l'application.
