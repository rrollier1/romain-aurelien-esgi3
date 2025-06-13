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

# Fichier de log
LOG_FILE="modifications.log"
: > "$LOG_FILE"  # Réinitialise le log

echo "Parcours des dossiers dans : $CHEMIN"
echo "Fichier de log : $LOG_FILE"
echo

# Parcours récursif de tous les dossiers
find "$CHEMIN" -type d | while read -r dir; do
  # Permissions avant modification (symbolique)
  perms_before=$(stat -c "%A" "$dir")

  # Vérifie si 'others' ont le droit de lecture (bit de lecture = 4)
  other_perms=$(stat -c "%a" "$dir")
  last_digit=${other_perms: -1}  # Dernier chiffre = droits pour "others"

  if [ "$last_digit" -lt 4 ]; then
    # Ajouter le droit de lecture pour tous les utilisateurs (others)
    chmod o+r "$dir"

    perms_after=$(stat -c "%A" "$dir")
    datetime=$(date "+%Y-%m-%d %H:%M:%S")

    # Écrire dans le log
    echo "$datetime | $dir | Avant: $perms_before | Après: $perms_after" >> "$LOG_FILE"
    echo "Droits modifiés : $dir"
  fi
done

echo
echo "Liste des dossiers trouvés dans $CHEMIN :"
find "$CHEMIN" -type d

echo
echo "Script terminé."
