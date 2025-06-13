#!/bin/bash

LOG_FILE="modifications.log"
ARCHIVE_FILE="modifications.archive.log"
TEMP_FILE="modifications.tmp.log"
TEMP_ARCHIVE="modifications.archive.tmp.log"

# Vérifie que le fichier log principal existe
if [ ! -f "$LOG_FILE" ]; then
  echo "Erreur : fichier $LOG_FILE introuvable."
  exit 1
fi

touch "$ARCHIVE_FILE"
: > "$TEMP_FILE"
: > "$TEMP_ARCHIVE"

# Seuil de 90 jours en secondes
three_months_ago=$(date -d "90 days ago" +%s)

# Archivage depuis le fichier principal
while IFS= read -r line; do
  log_date=$(echo "$line" | cut -d '|' -f1 | xargs)
  log_timestamp=$(date -d "$log_date" +%s 2>/dev/null)

  if [ -z "$log_timestamp" ]; then
    echo "Date invalide dans la ligne : $line"
    continue
  fi

  if [ "$log_timestamp" -lt "$three_months_ago" ]; then
    echo "$line" >> "$ARCHIVE_FILE"
  else
    echo "$line" >> "$TEMP_FILE"
  fi
done < "$LOG_FILE"

# Remplace le fichier log actif
mv "$TEMP_FILE" "$LOG_FILE"

# Nettoyage de l'archive : ne garder que les logs < 3 mois
while IFS= read -r line; do
  log_date=$(echo "$line" | cut -d '|' -f1 | xargs)
  log_timestamp=$(date -d "$log_date" +%s 2>/dev/null)

  if [ -z "$log_timestamp" ]; then
    echo "Date invalide dans la ligne archive : $line"
    continue
  fi

  if [ "$log_timestamp" -ge "$three_months_ago" ]; then
    echo "$line" >> "$TEMP_ARCHIVE"
  fi
done < "$ARCHIVE_FILE"

# Remplace l'archive
mv "$TEMP_ARCHIVE" "$ARCHIVE_FILE"

echo "Archivage terminé."
echo "Lignes de plus de 3 mois archivées et purgées."