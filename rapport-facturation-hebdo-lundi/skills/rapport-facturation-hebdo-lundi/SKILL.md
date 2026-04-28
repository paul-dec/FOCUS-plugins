---
name: rapport-facturation-hebdo-lundi
description: >
  Ce skill doit être utilisé quand l'utilisateur demande le "point facturation
  hebdo", "POINT FACTURATION HEBDO LUNDI", "envoie le suivi des factures à Robin",
  "point factures en retard", "rapport facturation lundi", ou veut envoyer
  le bilan des impayés à Robin sur Slack.
metadata:
  version: "0.1.0"
---

Exécuter le point de facturation hebdomadaire et envoyer le résultat en DM Slack à Robin (robin@wearefocus.co).

> Pour la liste des membres, leurs emails et les bases Notion disponibles, lire `NOTION.md` à la racine du projet.

## Étape 1 — Localiser la base Notion et la vue "Factures en retard"

Utiliser `mcp__bd831d95-075e-4c78-8282-1fdd76756c46__notion-search` avec la query `"ADMIN - SUIVI TEAM"` pour trouver la base de données.

Une fois la base localisée, identifier la vue (onglet) intitulée **"Factures en retard"** et récupérer son ID.

Interroger cette vue avec `mcp__bd831d95-075e-4c78-8282-1fdd76756c46__notion-query-database-view` en passant l'ID de la vue **et** en ajoutant un filtre de sécurité `RÈGLEMENT = "2 - LATE"` dans la requête, pour garantir l'exhaustivité même si la vue était modifiée côté Notion.

En cas d'échec à cette étape, aller directement à l'**Étape 4 — Mode erreur**.

## Étape 2 — Traiter les résultats

Toutes les lignes retournées sont par définition en retard.

Calculer :
- Le **montant total en retard** : somme des montants TTC de toutes les lignes.
- La **liste des clients avec plus de 90 jours de retard** : lignes dont `date d'échéance + 90 jours < date du jour`.

Pour chaque ligne en retard > 90 jours, extraire :
- Nom du client
- Numéro de facture (FAC...)
- Montant TTC
- Date d'échéance
- Nombre de jours de retard (date du jour − date d'échéance)

## Étape 3 — Composer le message Slack

Utiliser le format suivant **exactement** (ne jamais ajouter de section "Détail des X factures") :

```
📊 Suivi factures en retard – Semaine du [date lundi courant au format DD/MM/YYYY]

💰 Montant total en retard : [X] €

⏰ Clients impayés depuis +90 jours :
• [Client A] (FAC...) – [montant] € – échéance [date] – [N] jours de retard
• [Client B] (FAC...) – [montant] € – échéance [date] – [N] jours de retard
...

Source : Notion – ADMIN - SUIVI TEAM / vue "Factures en retard"
```

**Règles de formatage des chiffres** : format français — espace comme séparateur de milliers, virgule comme séparateur décimal, symbole € après le montant. Exemple : `12 450,00 €`.

**Cas particuliers :**

- Si le montant total en retard est **supérieur à 100 000 €**, ajouter en haut du message, avant tout autre contenu :
  ```
  🚨 ALERTE : montant en retard supérieur à 100K€ — action requise
  ```

- Si **aucune ligne n'a un retard > 90 jours**, remplacer la liste par :
  ```
  Aucun client n'est en retard de plus de 90 jours. ✅
  ```

- Si la vue **ne renvoie aucune ligne**, envoyer tout de même le message avec :
  ```
  Aucune facture en retard cette semaine. ✅
  ```

## Étape 4 — Envoyer le message en DM Slack à Robin

Chercher l'utilisateur Robin avec `mcp__e62dae6d-7b12-4f84-9653-75c6d59dcf26__slack_search_users` (email `robin@wearefocus.co` ou nom `Robin`).

Envoyer le message composé à l'étape 3 via `mcp__e62dae6d-7b12-4f84-9653-75c6d59dcf26__slack_send_message`, en utilisant l'ID utilisateur Robin comme `channel` (DM direct).

## Mode erreur

Si une étape échoue (vue Notion introuvable, données inaccessibles, Slack indisponible), envoyer quand même un message Slack court à Robin signalant l'erreur avec le détail technique, afin qu'il puisse intervenir manuellement :

```
⚠️ Point facturation hebdo – Erreur d'exécution

Une erreur est survenue lors de la génération automatique du rapport :
[description de l'erreur]

Merci de vérifier manuellement la vue "Factures en retard" dans Notion.
```

## Critères de succès

- La vue Notion "Factures en retard" a été utilisée comme source.
- Un filtre `RÈGLEMENT = "2 - LATE"` a été appliqué dans la requête en plus de la vue.
- Le message Slack a été envoyé à Robin en DM.
- Le message contient : montant total + liste des +90 jours uniquement (pas de détail exhaustif des factures).
- L'alerte 100K€ apparaît si et seulement si le seuil est dépassé.
- Tout est rédigé en français.
