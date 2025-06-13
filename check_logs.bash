#!/bin/bash

LOG_FILE="modifications.log"
ARCHIVE_FILE="modifications.archive.log"
TEMP_FILE="modifications.tmp.log"

if [ ! -f "$LOG_FILE" ]; then
  echo "Erreur : fichier $LOG_FILE introuvable."
  exit 1
fi

touch "$ARCHIVE_FILE"

: > "$TEMP_FILE"

while IFS= read -r line; do
  log_date=$(echo "$line" | cut -d '|' -f1 | xargs)

  log_timestamp=$(date -d "$log_date" +%s 2>/dev/null)

  if [ -z "$log_timestamp" ]; then
    echo "Date invalide dans la ligne : $line"
    continue
  fi

  seven_days_ago=$(date -d "7 days ago" +%s)

  if [ "$log_timestamp" -lt "$seven_days_ago" ]; then
    echo "$line" >> "$ARCHIVE_FILE"
  else
    echo "$line" >> "$TEMP_FILE"
  fi
done < "$LOG_FILE"

mv "$TEMP_FILE" "$LOG_FILE"

echo "Archivage terminé. Anciennes entrées déplacées dans $ARCHIVE_FILE."
