# Plugin bonjour-paul

Crée automatiquement chaque jour un événement Google Calendar **"BONJOUR PAUL"** pour le lendemain à 9h00, d'une durée d'1 heure.

## Composants

| Composant | Description |
|-----------|-------------|
| Skill `bonjour-paul` | Création manuelle de l'événement à la demande |
| Hook `SessionStart` | Déclenche la création automatique au démarrage de chaque session |

## Fonctionnement automatique

Au démarrage de la première session Claude de la journée, le hook vérifie si l'événement du lendemain a déjà été créé. Si ce n'est pas le cas, il demande à Claude de le créer via Google Calendar. Un fichier marqueur (`~/.claude/bonjour-paul-last-run`) évite les doublons même si plusieurs sessions sont ouvertes dans la journée.

## Prérequis

- Google Calendar doit être connecté comme outil MCP dans Cowork.

## Utilisation manuelle

Dire à Claude :
- "BONJOUR PAUL"
- "Crée l'event du matin pour demain"
- "Ajoute BONJOUR PAUL à mon calendrier"

## Paramètres de l'événement

- **Titre** : BONJOUR PAUL
- **Date** : lendemain
- **Heure** : 09:00 – 10:00
- **Durée** : 1 heure
