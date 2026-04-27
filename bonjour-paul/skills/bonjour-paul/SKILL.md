---
name: bonjour-paul
description: >
  Ce skill doit être utilisé quand l'utilisateur mentionne "BONJOUR PAUL",
  veut créer l'événement du matin pour Paul, dit "crée l'event Paul",
  "rappelle-moi BONJOUR PAUL demain", "ajoute BONJOUR PAUL à mon calendrier",
  ou demande la création de l'événement quotidien du lendemain à 9h.
metadata:
  version: "0.1.0"
---

Créer un événement Google Calendar avec les paramètres suivants :

- **Titre** : `BONJOUR PAUL`
- **Date** : le lendemain de la date actuelle (jamais aujourd'hui)
- **Heure de début** : 09:00
- **Heure de fin** : 10:00 (durée 1 heure)
- **Calendrier** : calendrier principal de l'utilisateur

## Processus

1. Calculer la date de demain au format ISO 8601 (`YYYY-MM-DD`).
2. Vérifier que l'événement n'existe pas déjà pour cette date avec le titre "BONJOUR PAUL" (éviter les doublons).
3. Si l'événement n'existe pas, le créer via l'outil Google Calendar MCP.
4. Confirmer à l'utilisateur que l'événement a été créé, en indiquant la date et l'heure.
5. Si l'événement existe déjà, informer l'utilisateur qu'il est déjà planifié.

## Gestion des doublons

Avant de créer, rechercher les événements du lendemain dont le titre contient "BONJOUR PAUL". Si un tel événement est trouvé, ne pas en créer un deuxième — informer simplement l'utilisateur.

## Format de confirmation

Répondre de manière concise :
- Succès : "Événement 'BONJOUR PAUL' créé pour demain [date] à 9h00."
- Doublon détecté : "L'événement 'BONJOUR PAUL' existe déjà pour demain [date]."
