TELEPORTMENU - WOW 1.12 / 2.4.3 / 3.3.5
============================================================

Installation
------------
1. Utilise le dossier correspondant a ton client.
2. Copie le dossier "TeleportMenu" dans Interface\AddOns\.
3. Redemarre le jeu ou utilise /reload.

Ouverture
---------
- Bouton autour de la mini-carte.
- Bouton "TP" dans FuBar si FuBar et Ace2 sont installes.
- Raccourci configurable dans le menu des raccourcis du jeu,
  section "Teleportation GM".
- Commandes /tpui ou /teleportmenu.

Utilisation
-----------
- Type "Fly" : envoie .go taxinode ID.
- Type "Ville" : envoie .tele NomTechnique.
- Type "Tous" : un nombre saisi manuellement est considere comme un
  ID de fly ; un texte est considere comme un nom .tele.
- Tu peux aussi saisir directement une commande complete :
  .go taxinode 23 ou .tele Orgrimmar.
- La recherche accepte les noms francais, les ID, les noms techniques
  anglais, les regions et les factions. Les accents ne sont pas obligatoires.

Persistance
-----------
La destination saisie, les filtres, la position de la fenetre, l'etat de la
liste et la position du bouton de mini-carte sont conserves entre les sessions.

Remarques importantes
----------------------
- Le personnage doit avoir le niveau de securite GM requis par le serveur.
- Les destinations .tele proviennent de la table game_tele. Les noms peuvent
  differer sur une base personnalisee. Dans ce cas, utilise .lookup tele nom,
  puis saisis librement la cle retournee dans l'addon.
- Les trois paquets utilisent le meme code Lua. Seul le numero "Interface"
  du fichier .toc change pour que chaque client charge correctement l'addon.

