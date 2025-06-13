#!/bin/bash

# Vérification que l'utilisateur a passé un argument
if [ -z "$1" ]; then
  echo "Usage : $0 <chemin_du_dossier>"
  exit 1
fi

# Chemin du dossier à parcourir
CHEMIN="$1"

# Vérifie si le chemin est bien un dossier
if [ ! -d "$CHEMIN" ]; then
  echo "Erreur : $CHEMIN n'est pas un dossier valide."
  exit 2
fi

# ajout des droits de lecture uniquement sur le CHEMIN
chmod -R a+r "$CHEMIN"
echo "Droits de lecture ajoutés à $CHEMIN et ses sous-dossiers."

# Parcours récursif pour trouver tous les dossiers
echo "Dossiers trouvés dans $CHEMIN :"
find "$CHEMIN" -type d