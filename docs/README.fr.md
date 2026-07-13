# BatteryInside

[中文](../README.md) · [English](README.en.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [Italiano](README.it.md)

![Aperçu de BatteryInside dans la barre des menus](images/hero.svg)

BatteryInside est un indicateur macOS léger et non interactif qui affiche le pourcentage, le niveau restant et l'état d'alimentation dans une seule icône compacte.

Auteur : Guo Peng (郭鹏)

## Installation en trois étapes

![Télécharger le DMG, glisser l'app dans Applications et l'ouvrir](images/install.svg)

1. Téléchargez le dernier fichier `BatteryInside-version.dmg` depuis [Releases](/guopengnaivoc/battery-inside/releases/latest).
2. Ouvrez le DMG et glissez BatteryInside dans Applications.
3. Ouvrez BatteryInside depuis Finder → Applications. L'indicateur apparaît dans la barre des menus.

### Si macOS bloque le premier lancement

La version publique actuelle utilise une signature ad hoc et n'est pas notariée avec un identifiant Apple Developer ID. Si macOS indique que le développeur ne peut pas être vérifié :

1. Essayez d'ouvrir l'app une fois, puis fermez l'avertissement.
2. Ouvrez Réglages Système → Confidentialité et sécurité.
3. Dans Sécurité, trouvez le message relatif à BatteryInside et cliquez sur Ouvrir quand même.

Ne le faites que pour un fichier téléchargé depuis la Release GitHub officielle dont la somme SHA-256 correspond. Ne désactivez pas Gatekeeper globalement.

## Comprendre l'état en un coup d'œil

![Couleurs de la batterie et états d'alimentation](images/status.svg)

- 30 % ou plus : barre de remplissage blanche
- 10 % à 29 % : barre de remplissage orange
- 9 % ou moins : barre de remplissage rouge
- En charge : éclair
- Branché mais pas en charge : prise
- Données indisponibles : `--`

La largeur du remplissage suit continuellement le niveau : `20,8 pt × pourcentage`. Chaque 1 % représente environ `0,208 pt`, rendu en sous-pixels par Core Graphics ; 100 pixels entiers ne sont donc pas nécessaires. Le nombre donne la valeur exacte et la barre une estimation visuelle. Le contour et l'embout suivent `labelColor` de macOS ; le texte et les symboles sont noirs sur le remplissage et utilisent la couleur système sur la zone vide.

L'état d'alimentation repose uniquement sur les valeurs macOS explicites `Is Charging`, `Power Source State` et `Is Charged`.

## Réglages et remplacement de l'icône système

![Ouvrir les réglages et masquer éventuellement l'icône Apple](images/settings.svg)

L'indicateur de la barre des menus est non interactif. Pour modifier les réglages, rouvrez BatteryInside depuis Finder → Applications. Vous pouvez activer le lancement à l'ouverture de session, les alertes à 20 % et 10 %, quitter ou désinstaller l'app en toute sécurité.

Pour ne conserver que BatteryInside dans la barre des menus :

- macOS récent : Réglages Système → Barre des menus → Contrôles de la barre des menus → Batterie
- macOS 13–15 : Réglages Système → Centre de contrôle → Batterie → désactiver Afficher dans la barre des menus

Cela ne supprime ni ne modifie les fonctions de batterie de macOS. Réactivez l'option au même endroit pour restaurer l'icône Apple.

### Placer BatteryInside à droite des autres icônes d'apps

![Maintenir Command et faire glisser BatteryInside](images/position.svg)

1. Maintenez la touche `Commande (⌘)` enfoncée.
2. Sans la relâcher, faites glisser BatteryInside dans la barre des menus avec la souris ou le trackpad.
3. Relâchez l'icône à droite des autres apps tierces.

BatteryInside utilise un identifiant stable de mémorisation de position ; macOS restaure donc l'emplacement choisi après la réouverture de l'app, le redémarrage du Mac ou une mise à niveau. Effectuez cette opération une fois après la première installation sur chaque Mac. L'horloge, le Centre de contrôle et les indicateurs de confidentialité occupent des emplacements réservés au système ; une app ne peut pas se placer à leur droite.

## Configuration requise et confidentialité

- macOS 13 ou version ultérieure
- Mac Apple silicon et Intel
- Aucun accès réseau, suivi analytique ou collecte de données

## Copyright

Copyright © 2026 郭鹏. Aucune licence open source n'est actuellement incluse ; la visibilité publique n'accorde pas l'autorisation de copier, modifier ou redistribuer le code.
