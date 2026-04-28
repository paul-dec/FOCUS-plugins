---
name: baseline-clients-coo
description: >
  Ce skill doit être utilisé quand l'utilisateur demande de "recalculer les
  baselines clients", "mettre à jour les baselines", "rafraîchir le profil
  habituel des clients", ou quand un autre skill (rapport-quotidien-coo,
  rapport-hebdo-lundi-coo, rapport-mensuel-coo) doit charger ou mettre à jour
  les baselines pour détecter les anomalies relatives (silence révélateur,
  dégradation de tonalité, baisse de volume).
metadata:
  version: "0.1.0"
---

Maintenir et fournir, pour chaque client (en priorité les Top 10 comptes clés), une **baseline** de son comportement habituel sur Slack. Les baselines servent à détecter les **anomalies relatives** (écart à la normale du client), pas des seuils absolus.

> Pour la liste des bases Notion disponibles et la base "Baselines clients" dédiée, lire la page Notion **NOTION CLAUDE** (`https://www.notion.so/wearefocus/NOTION-CLAUDE-3501716df23c809aa8e7f7a7ef9245c7`) via le MCP Notion.

⚠️ **Exclusion stricte** : ne pas calculer de baseline pour Anton Naimi, Amélie, Lisa, Stella si présents dans des données historiques.

## Étape 1 — Localiser la base Notion "Baselines clients"

Utiliser le MCP Notion pour rechercher la base de données dédiée au stockage des baselines (créée par Robin).

En cas d'échec, retourner une erreur explicite à l'appelant : `⚠️ Base Baselines clients introuvable dans Notion.`

## Étape 2 — Définir les 4 dimensions de la baseline

Pour chaque client, maintenir 4 indicateurs :

| Dimension | Définition |
|---|---|
| **Temps de réponse moyen** | Délai médian entre un message FOCUS sur le canal client et la réponse client (en heures ouvrées) |
| **Tonalité habituelle** | Caractérisation qualitative du ton (cordial / direct / chaleureux / formel / froid…) sur les 30 derniers jours |
| **Volume d'activité moyen** | Nombre moyen de messages échangés par semaine sur le canal client (FOCUS + client cumulés) |
| **Cadence habituelle de réunions/calls** | Fréquence des réunions/calls hebdo (ex : 1× par semaine le mardi, 1× toutes les 2 semaines, ad hoc…) |

## Étape 3 — Mode "lecture" (chargement par un autre skill)

Quand un skill appelant demande la baseline d'un client :

1. Interroger la base Notion "Baselines clients" via MCP avec un filtre sur le nom du client.
2. Retourner les 4 dimensions au format structuré, avec la **date de dernière mise à jour**.
3. Si la baseline n'existe pas (nouveau client de < 30 jours), retourner un objet vide avec le flag `baseline_pending: true` — l'appelant saura qu'il ne peut pas faire de comparaison relative pour ce client.

## Étape 4 — Mode "recalcul" (déclenchement périodique)

Le recalcul complet est **mensuel** (déclenché par `rapport-mensuel-coo` ou à la demande). Le recalcul partiel d'un client peut aussi être déclenché si l'agent observe une dérive forte.

Pour recalculer la baseline d'un client :

1. Charger les 30 derniers jours de Slack pour le canal client (via MCP Slack).
2. Charger les récaps d'appels weekly de la même fenêtre.
3. Calculer les 4 dimensions :
   - **Temps de réponse moyen** : médiane des délais de réponse client sur la fenêtre.
   - **Tonalité habituelle** : analyse LLM de l'ensemble des messages client → caractérisation en 1-3 mots-clés.
   - **Volume d'activité moyen** : nombre de messages / 4,3 semaines.
   - **Cadence de réunions** : fréquence et jour habituel détectés depuis les récaps weekly.
4. Comparer aux valeurs précédentes en base. Si écart > 30 % sur une dimension, marquer un flag `dérive_détectée` (utile pour le mensuel, Bloc H).
5. Écrire la nouvelle baseline dans Notion avec horodatage.

## Étape 5 — Stockage Notion : structure attendue

Chaque ligne de la base "Baselines clients" représente un client à un instant T. Champs :

- `Client` (titre)
- `Date de calcul` (date)
- `Temps de réponse médian (h ouvrées)` (nombre)
- `Tonalité habituelle` (texte court, 1-3 mots-clés)
- `Volume hebdo moyen (messages)` (nombre)
- `Cadence réunions` (texte court)
- `État de santé` (select : `healthy` / `glisse` / `risque`) — calculé automatiquement (voir Étape 6)
- `Dérive détectée` (checkbox)
- `Notes` (texte) — pour les commentaires libres

## Étape 6 — Calcul de l'état de santé

À partir des 4 dimensions et de leurs dérives :

- **healthy** : aucune dimension n'a dérivé de plus de 30 % depuis le dernier calcul ET la tonalité reste positive ou neutre.
- **glisse** : 1 dimension a dérivé OU la tonalité s'est dégradée mais pas catastrophique.
- **risque** : 2+ dimensions ont dérivé OU la tonalité est franchement négative OU silence radio cumulé sur le mois.

Cet état de santé alimente le Bloc H du rapport mensuel ("Évolution baselines comptes clés").

## Mode erreur

Si Notion est inaccessible : retourner à l'appelant `⚠️ Baselines clients indisponibles — Notion inaccessible.` L'appelant signalera la donnée manquante dans son rapport.

Si un client n'a pas assez d'historique (< 30 jours) : retourner `baseline_pending: true`, ne pas inventer de valeurs.

## Critères de succès

- Les 4 dimensions sont calculées de manière cohérente sur 30 jours.
- L'état de santé est mis à jour à chaque recalcul.
- Le flag `dérive_détectée` permet à `rapport-mensuel-coo` de remplir le Bloc H.
- Les nouveaux clients (< 30 jours) sont correctement gérés via `baseline_pending`.
- Anton Naimi, Amélie, Lisa, Stella ne sont jamais traités même si présents dans Slack/Notion historique.
- Aucune valeur inventée si la donnée manque.
