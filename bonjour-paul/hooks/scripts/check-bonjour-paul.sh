#!/bin/bash
# Vérifie si l'événement BONJOUR PAUL a déjà été créé aujourd'hui.
# Si non, injecte une instruction dans le contexte Claude pour le créer automatiquement.

TODAY=$(date +%Y-%m-%d)
MARKER_DIR="$HOME/.claude"
MARKER_FILE="$MARKER_DIR/bonjour-paul-last-run"

mkdir -p "$MARKER_DIR"
LAST_RUN=$(cat "$MARKER_FILE" 2>/dev/null || echo "")

if [ "$TODAY" != "$LAST_RUN" ]; then
  echo "$TODAY" > "$MARKER_FILE"
  echo "TÂCHE AUTOMATIQUE (plugin bonjour-paul) : Crée maintenant un événement Google Calendar intitulé \"BONJOUR PAUL\" pour demain à 9h00, d'une durée d'1 heure. Vérifie d'abord qu'il n'existe pas déjà. Fais cela avant de répondre à l'utilisateur."
fi
