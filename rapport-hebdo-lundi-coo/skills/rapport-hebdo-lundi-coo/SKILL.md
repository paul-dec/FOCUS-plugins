---
name: rapport-hebdo-lundi-coo
description: >
  Ce skill doit être utilisé quand l'utilisateur demande le "rapport hebdo COO",
  "rapport COO du lundi", "envoie le hebdo à Robin", "synthèse hebdo ops",
  ou veut envoyer le rapport opérationnel du lundi (qui intègre le quotidien +
  les modules hebdo : signaux faibles, onboardings, patterns) à Robin sur Slack.
metadata:
  version: "0.1.0"
---

Exécuter le rapport opérationnel du lundi (qui combine **le quotidien** + **les modules hebdo**) et envoyer le résultat en DM Slack à Robin (robin@wearefocus.co), tous les lundis à 06h00.

Langue : français. Ton : direct et factuel. Hiérarchie des alertes : 🔴 URGENT / 🟠 IMPORTANT / 🟢 INFO. Actions recommandées **uniquement** sur les alertes URGENT.

> Pour la liste des membres, leurs emails et les bases Notion disponibles, lire la page Notion **NOTION CLAUDE** (`https://www.notion.so/wearefocus/NOTION-CLAUDE-3501716df23c809aa8e7f7a7ef9245c7`) via le MCP Notion.

⚠️ **Exclusion stricte** : Anton Naimi, Amélie, Lisa, Stella ne doivent **jamais** apparaître dans le rapport.

## Étape 1 — Exécuter d'abord la base quotidienne

Exécuter intégralement les **Étapes 1 à 3** du skill `rapport-quotidien-coo` (chargement baselines, récupération données, calcul KPI et alertes du jour).

⚠️ **Fenêtre Slack étendue** : pour le lundi, la fenêtre d'analyse va du **vendredi 06h au lundi 06h** (week-end inclus) au lieu des 24h habituelles, afin de ne rien manquer.

## Étape 2 — Calculer les modules hebdo additionnels

### Module A — Synthèse signaux faibles clients (semaine écoulée)

Analyser tous les canaux Slack clients + les récaps d'appels weekly de la semaine écoulée. Détecter et classer :

- **Insatisfaction / mécontentement** : mots-clés ET tonalité subtile (sarcasme, frustration polie, malaise, passive-agressif).
- **Demandes de modifications/révisions répétées**.
- **Retards de livraison mentionnés par le client**.
- **Problèmes techniques/qualité récurrents**.
- **Mentions de concurrents** (comparaison ou évocation explicite).
- **Dégradations lentes du ton** (érosion sur 2-3 semaines, pas un éclat ponctuel) — comparer à la baseline de tonalité du client.
- **Sujets non résolus côté client** (mention multiple sans réponse claire après 3 jours).
- **Changements de cadence** (client demande des réunions hors cycle habituel = potentielle escalade).
- **Clients champions en phase pivot (60 premiers jours)** : très satisfaits = candidats upsell.

Niveau d'alerte selon gravité (URGENT pour les frictions sur nouveaux clients, IMPORTANT pour la majorité, INFO pour les champions/upsell).

### Module B — Récap onboardings en cours

- **Onboarding équipe** : récap des onboardings d'équipe en cours.
  ⚠️ **Désactivé tant que Robin n'a pas créé le process Notion d'onboarding équipe**. Dans ce cas, afficher : `Module désactivé — process Notion d'onboarding équipe non encore formalisé.`
- **Onboarding clients** : récap des nouveaux clients (< 60 jours) avec leur statut sur la checklist documentation (couverte par la checklist documentation, pas séparée).

### Module C — Patterns découverts

L'agent restitue les **récurrences observées dans le temps** depuis sa base d'historique (ex : "le client X est toujours difficile sur les livraisons du vendredi", "les briefs incomplets viennent majoritairement de tel type de projet").

Format : **observation factuelle + suggestion d'attention**. Ne pas inventer : ne sortir un pattern que s'il est attesté dans la base d'historique avec au moins 3 occurrences.

## Étape 3 — Composer le message Slack

Le message du lundi reprend la structure du quotidien **puis ajoute les modules hebdo en aval**. Format :

```
🧭 Rapport COO – Lundi [DD/MM/YYYY] (synthèse hebdo intégrée)

📊 Activité du week-end + vendredi
• Squad Diana : [N] projets actifs / [N] en revue / [N] livrés
   - Marion : [volume projets] · responsiveness [X]
   - Ines : [volume projets] · responsiveness [X]
   - Sanya : [volume projets] · responsiveness [X]
• Squad Axelle : [N] projets actifs / [N] en revue / [N] livrés
   - Laura : [volume projets] · responsiveness [X]
   - Maréva : [volume projets] · responsiveness [X]
   - Clement : [volume projets] · responsiveness [X]

🔴 URGENT
• [Client/CS] – [motif court]
  → Action recommandée : [phrase actionnable]
[ou : Aucune alerte URGENT aujourd'hui.]

🟠 IMPORTANT
• [Client/CS] – [motif court]
[ou : Aucune alerte IMPORTANT.]

🟢 INFO
• [Client/CS] – [motif court]
[ou : Aucune info à signaler.]

💡 Signaux faibles (à vérifier)
• [description du signal] — j'ai un signal mais je ne suis pas sûr, à vérifier
[section optionnelle]

──────────── Synthèse hebdo ────────────

🎧 Signaux faibles clients (semaine écoulée)
• [Client] – [type de signal : insatisfaction / révisions répétées / retards mentionnés / mention concurrent / dégradation tonalité / sujet non résolu / changement de cadence / champion phase pivot]
[regrouper par client si plusieurs signaux sur le même]

🚀 Onboardings en cours
• Équipe : [récap ou "Module désactivé — process Notion d'onboarding équipe non encore formalisé."]
• Clients (< 60 jours) :
  - [Client A] – jour [N]/60 – checklist documentation : [N/total items] – [statut friction OK / signal négatif détecté]
  - [Client B] – jour [N]/60 – ...

🧠 Patterns découverts
• [observation factuelle, attestée par ≥ 3 occurrences en base]
  → Attention suggérée : [phrase courte]
[ou : Aucun nouveau pattern consolidé cette semaine.]
```

### Règles de formatage

- Format français : espace comme séparateur de milliers, virgule décimale, `−` (signe moins typographique) pour les baisses. Exemple : `−32 %`.
- Section "Synthèse hebdo" toujours présente le lundi, même si peu de contenu (afficher "Aucun élément cette semaine.").
- Anti-doublons URGENT identique au quotidien (vérifier sur 7 jours glissants).

## Étape 4 — Section "données manquantes" (si applicable)

Identique au quotidien : ajouter en bas si une source était inaccessible.

## Étape 5 — Envoyer le message en DM Slack à Robin

Chercher l'utilisateur Robin avec le MCP Slack (email `robin@wearefocus.co` ou nom `Robin`). Envoyer le message composé à l'Étape 3 via le MCP Slack en DM direct.

## Étape 6 — Stocker les alertes émises et les nouveaux patterns

- Persister les alertes URGENT et IMPORTANT dans la base d'historique via `historique-alertes-coo`.
- Persister les nouveaux patterns détectés dans la base "patterns" via `historique-alertes-coo`.

## Mode erreur

Identique au quotidien : envoyer un message court signalant l'erreur technique pour permettre une vérification manuelle.

## Critères de succès

- Le rapport est envoyé à Robin en DM le lundi à 06h00.
- Il contient à la fois la base quotidienne et les 3 modules hebdo (signaux faibles, onboardings, patterns).
- La fenêtre Slack couvre bien vendredi 06h → lundi 06h.
- Le module onboarding équipe est désactivé proprement tant que le process Notion n'existe pas.
- Les patterns affichés sont attestés (≥ 3 occurrences).
- Anti-doublons URGENT respecté.
- Anton Naimi, Amélie, Lisa, Stella n'apparaissent nulle part.
- Tout est rédigé en français.
