---
name: rapport-mensuel-coo
description: >
  Ce skill doit être utilisé quand l'utilisateur demande le "rapport mensuel COO",
  "bilan ops du mois", "envoie le mensuel à Robin", "synthèse mensuelle COO",
  ou veut envoyer le rapport opérationnel mensuel (priorités du mois, top/low
  performers, sujets récurrents, baselines clients) à Robin sur Slack le 1er
  du mois.
metadata:
  version: "0.1.0"
---

Exécuter le rapport opérationnel mensuel sur le mois écoulé et envoyer le résultat en DM Slack à Robin (robin@wearefocus.co), le 1er de chaque mois à 06h00.

Langue : français. Ton : direct et factuel. Hiérarchie des alertes : 🔴 URGENT / 🟠 IMPORTANT / 🟢 INFO. Actions recommandées **uniquement** sur les alertes URGENT. **Pas de forward-looking** : le rapport reste sur le mois écoulé.

> Pour la liste des membres, leurs emails et les bases Notion disponibles, lire la page Notion **NOTION CLAUDE** (`https://www.notion.so/wearefocus/NOTION-CLAUDE-3501716df23c809aa8e7f7a7ef9245c7`) via le MCP Notion.

⚠️ **Exclusion stricte** : Anton Naimi, Amélie, Lisa, Stella ne doivent **jamais** apparaître dans le rapport.

⚠️ **Donnée RH sensible** : le ranking top/low performers est nominatif. **Strictement Slack DM à Robin**, jamais en canal partagé.

## Étape 1 — Délimiter le mois écoulé

Définir la fenêtre temporelle : du 1er jour du mois M-1 (00h00) au dernier jour du mois M-1 (23h59), où M = mois courant.

## Étape 2 — Recalculer les Top 10 comptes clés

Déclencher le skill `comptes-cles-top10-coo` pour recalculer la liste des Top 10 clients par CA cumulé historique (source : Notion). Ce recalcul est **mensuel** uniquement (pas quotidien).

## Étape 3 — Charger les données du mois

**Notion (via MCP)** :
- Toutes les cartes projets actives ou clôturées sur le mois (par squad, par CS, par client).
- Base d'historique : alertes émises sur le mois, patterns enregistrés, baselines clients (états début et fin de mois).
- Page process internes + liste templates (pour vérifications d'adoption sur le mois).

**Slack (via MCP)** :
- Tous les canaux du workspace sur la fenêtre du mois.
- Récaps d'appels weekly clients du mois.
- Réactions emoji "inutile" enregistrées par Robin sur le mois (via `feedback-inutile-coo`).

## Étape 4 — Construire les 8 blocs du mensuel

### Bloc A — Priorités opérationnelles du mois

L'agent identifie **1 ou 2 priorités opérationnelles** à partir des données. Lecture humaine, courte, factuelle. Logique : ce qui mérite l'attention de Robin sur le plan ops (squad en sous-perfo, client à risque renforcé, pattern interne récurrent, etc.).

Format pour chaque priorité : **phrase courte + chiffre clé + recommandation actionnable**.

Exemple : `La squad Axelle a vu sa charge livrables baisser de 22 % sur le mois pendant que la squad Diana progressait de 14 %. Recommandation : creuser la répartition des nouveaux projets avant le prochain comité.`

### Bloc B — Top/low performers du mois

Ranking des CS individuels (Marion, Ines, Sanya, Laura, Maréva, Clement) **et** des squad leads (Diana, Axelle), basé sur les indicateurs continus :
- Volume de projets gérés
- Livrables produits
- Responsiveness Slack moyenne
- Comparaison à la baseline interne

Format : top 3 / bottom 3, avec les chiffres clés. Mention explicite que les indicateurs sont des **proxys imparfaits** sur les 4 premières semaines de calibration.

### Bloc C — Synthèse sujets récurrents internes

Problèmes internes du mois qui sont revenus, **regroupés par patterns thématiques** (ex : "problèmes de brief client", "problèmes techniques", "problèmes de cycles de validation").

Pour chaque pattern : nombre d'occurrences sur le mois + suggestion d'action corrective (process à créer).

### Bloc D — Liste cumulée des alertes silence radio + baisse de volume du mois

Vue mois entier depuis la base d'historique :
- Quels clients ont déclenché une alerte silence radio sur le mois, combien de fois.
- Quels comptes clés ont déclenché une alerte baisse de volume.

### Bloc E — Récap signaux faibles clients du mois

Synthèse des frictions, mécontentements, retards mentionnés sur le mois. Inclut :
- Tonalité subtile (sarcasme, frustration polie, passive-agressif).
- Dégradations lentes du ton.
- Mentions de concurrents.
- Changements de cadence.
- Sujets non résolus côté client.

### Bloc F — Patterns découverts par l'agent

Récurrences observées dans le temps (pas seulement sur le mois). Format : observation + recommandation d'attention.

### Bloc G — Suggestions d'amélioration de l'agent

L'agent peut **proposer de nouvelles métriques à surveiller** basées sur ce qu'il observe.

Format : `j'ai remarqué [signal récurrent] qui n'est pas dans mes alertes actuelles, vaut-il la peine de le surveiller ?`

⚠️ Ce bloc n'apparaît **que dans le mensuel** (pas dans le quotidien ni l'hebdo).

### Bloc H — Évolution des baselines clients

Pour les Top 10 comptes clés, évolution du "health" client mois sur mois (basé sur la baseline maintenue par `baseline-clients-coo`).

Format : `[Client X] : healthy en M-2 → healthy en M-1 → glisse en M (responsiveness ÷2, tonalité dégradée)`.

## Étape 5 — Composer le message Slack

Format **exactement** ainsi :

```
🧭 Rapport COO mensuel – [Mois M-1 YYYY]

🎯 A. Priorités opérationnelles du mois
1. [Phrase courte]. Chiffre clé : [X]. Recommandation : [action].
2. [Phrase courte]. Chiffre clé : [X]. Recommandation : [action].

🏆 B. Top / Low performers
Top 3 :
• [Nom] – [chiffre clé synthétique]
• [Nom] – ...
• [Nom] – ...
Low 3 :
• [Nom] – [chiffre clé synthétique]
• [Nom] – ...
• [Nom] – ...
Squads :
• Diana : [chiffre clé]
• Axelle : [chiffre clé]
(Indicateurs proxys imparfaits — calibration en cours sur les 4 premières semaines.)

🔁 C. Sujets récurrents internes
• [Pattern thématique 1] – [N] occurrences. Suggestion : [process à créer].
• [Pattern thématique 2] – [N] occurrences. Suggestion : [process à créer].

📡 D. Alertes silence radio + baisse de volume du mois
• [Client] – [N] alertes silence radio
• [Client] – baisse de volume −[X] %

🎧 E. Signaux faibles clients du mois
• [Client] – [synthèse des signaux : tonalité, retards, concurrents, cadence, non résolus]

🧠 F. Patterns découverts
• [Observation factuelle].
  → Attention suggérée : [phrase courte].

💡 G. Suggestions d'amélioration de l'agent
• j'ai remarqué [signal récurrent] qui n'est pas dans mes alertes actuelles, vaut-il la peine de le surveiller ?

❤️ H. Évolution baselines comptes clés
• [Client A] : [état M-2] → [état M-1] → [état M] ([détail bref])
• [Client B] : ...
```

### Règles de formatage

- Format français : espace comme séparateur de milliers, virgule décimale, `−` typographique pour les baisses, % collé au chiffre.
- Si un bloc est vide sur le mois (ex : aucun pattern nouveau), écrire explicitement `Aucun élément ce mois-ci.` plutôt que de masquer le bloc.
- Pas de forward-looking : aucune projection sur le mois suivant.

## Étape 6 — Section "données manquantes" (si applicable)

Si une source était inaccessible, ajouter en bas :

```
⚠️ Données manquantes
• [source] : [raison technique courte]
```

## Étape 7 — Envoyer le message en DM Slack à Robin

Chercher Robin avec le MCP Slack (email `robin@wearefocus.co`). Envoyer le message en DM direct.

⚠️ **Ne jamais envoyer ce rapport sur un canal partagé** : il contient des données RH nominatives.

## Mode erreur

Si l'envoi échoue ou si Notion est inaccessible, envoyer un message court signalant l'erreur technique :

```
⚠️ Rapport COO mensuel – Erreur d'exécution

Une erreur est survenue lors de la génération automatique du rapport mensuel :
[description de l'erreur]

Merci de vérifier manuellement.
```

## Critères de succès

- Le rapport est envoyé en DM uniquement à Robin (jamais sur canal partagé).
- Les 8 blocs sont présents (A à H), même si certains contiennent "Aucun élément ce mois-ci."
- Les Top 10 comptes clés ont été recalculés via `comptes-cles-top10-coo`.
- Les priorités du Bloc A respectent le format : phrase + chiffre + recommandation.
- Le ranking top/low performers couvre CS et squad leads (pas juste les squads agrégées).
- Anton Naimi, Amélie, Lisa, Stella n'apparaissent nulle part.
- Aucun forward-looking.
- Tout est rédigé en français.
