---
name: historique-alertes-coo
description: >
  Ce skill doit être utilisé quand un autre skill (rapport-quotidien-coo,
  rapport-hebdo-lundi-coo, rapport-mensuel-coo) doit "stocker une alerte émise",
  "vérifier l'anti-doublons URGENT", "enregistrer un pattern découvert",
  "consulter l'historique des alertes du mois", ou quand l'utilisateur demande
  de "purger l'historique" / "consulter les alertes émises". Ce skill est la
  mémoire long terme de l'agent COO.
metadata:
  version: "0.1.0"
---

Gérer la **mémoire long terme** de l'agent COO : alertes émises, patterns découverts, sujets récurrents, anti-doublons URGENT. Ce skill est appelé en lecture et en écriture par les 3 skills de rapport.

> Pour la liste des bases Notion disponibles (et notamment les bases d'historique dédiées à l'agent), lire la page Notion **NOTION CLAUDE** (`https://www.notion.so/wearefocus/NOTION-CLAUDE-3501716df23c809aa8e7f7a7ef9245c7`) via le MCP Notion.

## Bases Notion gérées par ce skill

L'agent maintient 4 bases Notion dédiées (à créer par Robin si elles n'existent pas) :

| Base | Usage |
|---|---|
| **Alertes émises** | Une ligne par alerte 🔴 URGENT ou 🟠 IMPORTANT envoyée à Robin (anti-doublons + récap mensuel) |
| **Patterns découverts** | Récurrences observées par l'agent dans le temps (ex : "client X difficile sur les livraisons du vendredi") |
| **Sujets récurrents internes** | Problèmes internes regroupés par thématique (briefs, technique, validation…) |
| **Feedbacks "inutile"** | Réactions emoji "inutile" de Robin sur des alertes passées (alimente `feedback-inutile-coo`) |

## Mode 1 — Stocker une alerte émise

Appel typique depuis `rapport-quotidien-coo` ou `rapport-hebdo-lundi-coo` après envoi du message Slack.

Pour chaque alerte 🔴 URGENT ou 🟠 IMPORTANT, créer une ligne dans la base "Alertes émises" :

- `Date d'émission` (date)
- `Niveau` (select : `URGENT` / `IMPORTANT`)
- `Client / CS concerné` (texte court)
- `Motif` (select : `silence_radio_actif` / `silence_radio_standby` / `silence_revelateur` / `baisse_volume_compte_cle` / `multi_signal_cumule` / `revisions_infinies` / `friction_nouveau_client` / `sous_activite_cs` / `surcharge_cs` / `epuisement_squad_lead` / `probleme_non_traite_par_squad_lead` / `sujet_non_resolu_client` / `template_non_utilise` / `checklist_doc_incomplete` / `dependance_cs_un_client`)
- `Description` (texte)
- `Rapport source` (select : `quotidien` / `hebdo_lundi` / `mensuel`)
- `Statut` (select : `émise` / `résolue` / `obsolète`) — par défaut `émise`

## Mode 2 — Vérifier l'anti-doublons URGENT

Appel typique depuis `rapport-quotidien-coo` ou `rapport-hebdo-lundi-coo` **avant** d'émettre une alerte URGENT.

Requête à effectuer :

1. Filtrer la base "Alertes émises" sur :
   - `Niveau = URGENT`
   - `Client / CS concerné = [client/CS courant]`
   - `Motif = [motif courant]`
   - `Date d'émission ≥ aujourd'hui − 7 jours`
   - `Statut ≠ obsolète`
2. Si au moins une ligne correspond, retourner `doublon: true` à l'appelant. L'appelant **n'émet pas** l'alerte.
3. Sinon, retourner `doublon: false`. L'appelant émet l'alerte et la persiste via le Mode 1.

⚠️ L'anti-doublons s'applique **uniquement aux URGENT**. Les IMPORTANT et INFO peuvent être réémis.

## Mode 3 — Enregistrer un pattern découvert

Appel typique depuis `rapport-hebdo-lundi-coo` (Module C) ou `rapport-mensuel-coo` (Bloc F).

Avant d'enregistrer un pattern comme "consolidé", l'agent doit avoir observé **au moins 3 occurrences** du même phénomène (vérifiable en interrogeant la base "Alertes émises" ou en analysant l'historique Slack/Notion).

Champs de la base "Patterns découverts" :

- `Pattern` (titre, phrase courte)
- `Première détection` (date)
- `Dernière détection` (date)
- `Nombre d'occurrences` (nombre)
- `Périmètre` (select : `client_specifique` / `cs_specifique` / `squad` / `transversal`)
- `Entité concernée` (texte court — nom du client / CS / squad si applicable)
- `Suggestion d'attention` (texte)
- `Statut` (select : `actif` / `résolu_par_action` / `obsolète`)

À chaque nouvelle détection d'un pattern existant, **mettre à jour** la ligne (incrément `Nombre d'occurrences`, mise à jour `Dernière détection`) plutôt que créer une nouvelle ligne.

## Mode 4 — Enregistrer un sujet récurrent interne

Appel typique depuis `rapport-mensuel-coo` (Bloc C).

Champs de la base "Sujets récurrents internes" :

- `Thématique` (titre — ex : "Problèmes de brief client")
- `Mois` (date — premier jour du mois concerné)
- `Nombre d'occurrences sur le mois` (nombre)
- `Suggestion d'action corrective` (texte)
- `Statut` (select : `ouvert` / `process_créé` / `en_cours` / `résolu`)

## Mode 5 — Consulter l'historique pour le mensuel

Appel typique depuis `rapport-mensuel-coo` (Blocs D, E, F).

Requêtes à effectuer :

- **Bloc D** : interroger "Alertes émises" filtrées sur `Date ∈ mois M-1` et `Motif ∈ {silence_radio_actif, silence_radio_standby, silence_revelateur, baisse_volume_compte_cle}`. Regrouper par client.
- **Bloc E** : interroger "Alertes émises" filtrées sur `Date ∈ mois M-1` et `Motif ∈ {friction_nouveau_client, sujet_non_resolu_client}` + signaux faibles enregistrés sur le mois.
- **Bloc F** : interroger "Patterns découverts" avec `Statut = actif` et `Dernière détection ≥ mois M-1`.

## Mode 6 — Marquer une alerte comme obsolète

Si Robin réagit à une alerte avec un emoji "inutile" (voir `feedback-inutile-coo`), passer la ligne correspondante dans "Alertes émises" en `Statut = obsolète`.

## Mode erreur

Si la base Notion correspondante est inaccessible, retourner à l'appelant :

```
⚠️ Historique alertes indisponible — [raison technique courte].
```

⚠️ Comportement de fallback :
- En **lecture** (Mode 2 anti-doublons) : si l'historique est indisponible, l'appelant **émet quand même** l'alerte URGENT (mieux vaut un doublon qu'une alerte manquée), en signalant la donnée manquante en bas du rapport.
- En **écriture** (Modes 1, 3, 4, 6) : l'appelant signale dans son rapport "alerte émise mais non persistée".

## Critères de succès

- Toute alerte URGENT ou IMPORTANT émise est persistée dans "Alertes émises".
- L'anti-doublons URGENT fonctionne sur fenêtre 7 jours glissants.
- Les patterns ne sont consolidés qu'après ≥ 3 occurrences.
- Les feedbacks "inutile" mettent à jour le statut des alertes existantes.
- En cas d'indisponibilité Notion, le fallback "émettre quand même + signaler" est respecté.
