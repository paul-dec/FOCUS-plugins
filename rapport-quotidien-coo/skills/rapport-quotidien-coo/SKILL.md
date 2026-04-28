---
name: rapport-quotidien-coo
description: >
  Ce skill doit être utilisé quand l'utilisateur demande le "rapport quotidien
  COO", "rapport ops du jour", "envoie le quotidien à Robin", "point ops
  mardi-vendredi", ou veut envoyer le rapport opérationnel quotidien à Robin
  sur Slack du mardi au vendredi. Pour le lundi, utiliser le skill
  rapport-hebdo-lundi-coo qui intègre le quotidien + modules hebdo.
metadata:
  version: "0.1.0"
---

Exécuter le rapport opérationnel quotidien et envoyer le résultat en DM Slack à Robin (robin@wearefocus.co), du mardi au vendredi à 06h00.

Le rapport est **toujours envoyé**, même sans alerte URGENT. Langue : français. Ton : direct et factuel. Hiérarchie des alertes : 🔴 URGENT / 🟠 IMPORTANT / 🟢 INFO. Actions recommandées **uniquement** sur les alertes URGENT.

> Pour la liste des membres, leurs emails et les bases Notion disponibles, lire la page Notion **NOTION CLAUDE** (`https://www.notion.so/wearefocus/NOTION-CLAUDE-3501716df23c809aa8e7f7a7ef9245c7`) via le MCP Notion.

⚠️ **Exclusion stricte** : Anton Naimi, Amélie, Lisa, Stella ne doivent **jamais** apparaître dans le rapport, même s'ils figurent dans les données historiques.

## Étape 1 — Charger les baselines et l'historique

Charger les baselines clients (temps de réponse moyen, tonalité, volume, cadence) maintenues par le skill `baseline-clients-coo`. Charger la liste des Top 10 comptes clés maintenue par `comptes-cles-top10-coo`. Charger l'historique des alertes URGENT émises sur les 7 derniers jours (anti-doublons) via `historique-alertes-coo`.

En cas d'échec de chargement de l'une de ces sources, **continuer** le rapport en signalant explicitement la donnée manquante dans une section dédiée en bas du rapport (voir Étape 5).

## Étape 2 — Récupérer les données brutes

**Notion (via MCP)** :
- Base projets : projets actifs, en revue, livrés sur les dernières 24h, ventilés par squad (Diana / Axelle) et par CS (Marion, Ines, Sanya / Laura, Maréva, Clement).
- Cartes projets des dashboards client : statut, nombre de révisions, date de dernière mise à jour.
- Page process internes + liste templates : pour les vérifications d'adoption.
- Checklist documentation projets (uniquement projets nouveaux clients < 30 jours).

**Slack (via MCP)** :
- Tous les canaux du workspace FOCUS, fenêtre 24h glissantes (lundi : fenêtre vendredi 06h → lundi 06h pour ne rien manquer du week-end).
- Pour chaque canal client : dernière activité client, dernière activité CS, délai de réponse moyen sur la fenêtre.
- Pour chaque CS : volume de messages envoyés, délai moyen de réponse aux clients.
- Récaps d'appels weekly clients (envoyés via workflow Make existant) : à intégrer dans l'analyse.

## Étape 3 — Calculer les KPI et déclencher les alertes

### KPI à afficher TOUJOURS (même sans URGENT)

**Activité squads/CS du jour précédent** :
- Volume de projets gérés par CS et par squad.
- Nombre de livrables produits.
- Responsiveness Slack par CS (Marion, Ines, Sanya, Laura, Maréva, Clement).

**Pipeline production par squad** :
- Compteurs : projets actifs / en revue / livrés, vue Diana et vue Axelle.
- Comparaison à la **baseline interne de chaque squad** (pas de benchmark inter-squads).

### Alertes à émettre selon les seuils

| Alerte | Niveau | Seuil |
|---|---|---|
| Silence radio client actif (projet en cours) | 🔴 URGENT | aucune activité canal Slack ≥ 3 jours ouvrés |
| Silence radio client stand-by/maintenance | 🟠 IMPORTANT | aucune activité canal Slack ≥ 3 jours ouvrés |
| Silence révélateur (client habituellement réactif) | 🟠 IMPORTANT | délai réponse client > 2× sa baseline |
| Baisse de volume compte clé | 🔴 URGENT | −30 % volume mensuel vs moyenne 3 mois |
| Multi-signal cumulé (silence + signaux négatifs + baisse volume sur même client) | 🔴 URGENT renforcé | 2 signaux ou plus sur la même fenêtre |
| Révisions infinies sur livrable | 🔴 URGENT | > 4 révisions demandées |
| Friction nouveau client (premiers 60 jours) | 🔴 URGENT | mots-clés négatifs renforcés OU révisions multiples sur premières livraisons |
| Sous-activité ou surcharge CS | 🔴 URGENT | écart anormal vs baseline CS (calibré sur 4 premières semaines) |
| Signaux d'épuisement squad lead (Diana ou Axelle) | 🟠 IMPORTANT | baisse responsiveness, activité anormale, ton dégradé |
| Problème CS non traité par squad lead | 🟠 IMPORTANT | > 3 jours ouvrés sans action visible de la squad lead |
| Sujet non résolu côté client | 🟠 IMPORTANT | mention multiple + > 3 jours sans réponse claire |
| Template/process documenté non utilisé | 🟠 IMPORTANT | détecté côté CS |
| Checklist documentation projet incomplète (projet nouveau client < 30 jours) | 🟠 IMPORTANT | manque détecté vs checklist Notion |
| CS trop dépendant d'un client | 🟠 IMPORTANT | > 50 % projets actifs sur 1 client |
| Client champion en phase pivot (60 premiers jours, très satisfait) | 🟢 INFO | candidat upsell |
| Opportunité d'expansion | 🟢 INFO | client > 6 mois sans avoir testé un autre service |
| Sujets internes regroupés par patterns | 🟢 INFO | + suggestion d'action corrective |

### Distinction client actif vs stand-by

Critère technique : un client est **actif** si au moins une carte projet Notion est en statut "actif" sur son dashboard. Sinon il est **stand-by/maintenance**.

### Anti-doublons URGENT

Avant d'émettre une alerte 🔴 URGENT, vérifier dans l'historique sur les 7 derniers jours qu'elle n'a pas déjà été émise pour le même client / CS / motif. Si déjà émise et toujours valide, **ne pas la réémettre**.

### Intuitions de bas niveau

L'agent peut signaler des signaux faibles incertains avec la mention explicite **"j'ai un signal mais je ne suis pas sûr, à vérifier"**. Ne pas confondre avec une alerte URGENT (qui doit rester catégorique).

## Étape 4 — Composer le message Slack

Format **exactement** ainsi :

```
🧭 Rapport COO quotidien – [Mardi/Mercredi/Jeudi/Vendredi] [DD/MM/YYYY]

📊 Activité d'hier
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
[section optionnelle, omettre si rien]
```

### Règles de formatage

- Format français : espace comme séparateur de milliers, virgule décimale, % collé au chiffre. Exemple : `−32 %`, `12 450,00 €`.
- Une alerte = une ligne courte. Pas de paragraphe.
- Action recommandée **uniquement** sur les URGENT.
- Si aucune alerte d'un niveau, écrire la mention "Aucune alerte ..." (ne pas masquer la section).

## Étape 5 — Section "données manquantes" (si applicable)

Si une source était inaccessible à l'Étape 1 ou 2, ajouter en bas du message :

```
⚠️ Données manquantes
• [source] : [raison technique courte]
```

## Étape 6 — Envoyer le message en DM Slack à Robin

Chercher l'utilisateur Robin avec le MCP Slack (email `robin@wearefocus.co` ou nom `Robin`). Envoyer le message composé à l'Étape 4 via le MCP Slack en DM direct (l'ID utilisateur Robin comme `channel`).

## Étape 7 — Stocker les alertes émises

Après envoi, persister chaque alerte 🔴 URGENT et 🟠 IMPORTANT dans la base d'historique Notion via `historique-alertes-coo` (date, client/CS, motif, niveau). Cela alimente l'anti-doublons et le mensuel.

## Mode erreur

Si l'envoi Slack échoue ou si Notion est totalement inaccessible, envoyer un message Slack court à Robin signalant l'erreur :

```
⚠️ Rapport COO quotidien – Erreur d'exécution

Une erreur est survenue lors de la génération automatique du rapport :
[description de l'erreur]

Merci de vérifier manuellement.
```

## Critères de succès

- Le rapport a bien été envoyé à Robin en DM même en l'absence d'alerte URGENT.
- Anton Naimi, Amélie, Lisa, Stella n'apparaissent nulle part.
- Anti-doublons URGENT respecté sur 7 jours glissants.
- Format français pour tous les chiffres.
- Section données manquantes présente uniquement si nécessaire.
- Actions recommandées uniquement sur les URGENT.
- Alertes IMPORTANT et INFO sans actions imposées.
- Tout est rédigé en français.
