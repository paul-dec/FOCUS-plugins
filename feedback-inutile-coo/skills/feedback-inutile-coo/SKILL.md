---
name: feedback-inutile-coo
description: >
  Ce skill doit être utilisé quand Robin marque une alerte comme "inutile" via
  une réaction emoji sur Slack, ou quand l'utilisateur demande de "traiter les
  feedbacks inutile", "ajuster la sensibilité de l'agent", "consulter les
  alertes marquées inutile". Il alimente l'apprentissage de l'agent en ajustant
  les seuils de sensibilité.
metadata:
  version: "0.1.0"
---

Traiter les feedbacks emoji "inutile" laissés par Robin sur les alertes Slack envoyées par l'agent COO, et **ajuster la sensibilité de l'agent** sur les types d'alertes concernés.

> Pour la liste des bases Notion disponibles (notamment "Feedbacks inutile" et "Alertes émises"), lire la page Notion **NOTION CLAUDE** (`https://www.notion.so/wearefocus/NOTION-CLAUDE-3501716df23c809aa8e7f7a7ef9245c7`) via le MCP Notion.

⚠️ **Pas de feedback "utile" requis** — seul le marquage négatif est pris en compte (sinon trop de friction pour Robin).

## Étape 1 — Convention de feedback

Robin marque une alerte comme inutile en ajoutant une réaction emoji **`:thumbsdown:`** (👎) ou **`:no_entry_sign:`** (🚫) sur le message Slack contenant l'alerte.

Toute autre réaction (👍, 🙏, etc.) est ignorée — le système n'attend pas de feedback positif.

## Étape 2 — Détection des nouveaux feedbacks

Ce skill est déclenché de manière **continue** (par exemple chaque heure) ou en début d'exécution des skills de rapport.

1. Interroger Slack via MCP pour récupérer les réactions emoji posées par Robin (et uniquement Robin) sur les messages envoyés par l'agent depuis la dernière exécution de ce skill.
2. Filtrer sur les emoji `:thumbsdown:` et `:no_entry_sign:`.
3. Pour chaque réaction détectée, identifier l'alerte concernée :
   - Récupérer le contenu du message Slack.
   - Extraire le client/CS et le motif de l'alerte (parsing du format standardisé des rapports).
   - Retrouver la ligne correspondante dans la base Notion "Alertes émises".

## Étape 3 — Enregistrer le feedback

Pour chaque feedback détecté, créer une ligne dans la base "Feedbacks inutile" :

- `Date du feedback` (date)
- `Alerte concernée` (relation vers la ligne dans "Alertes émises")
- `Niveau de l'alerte` (rollup depuis "Alertes émises")
- `Motif de l'alerte` (rollup depuis "Alertes émises")
- `Client / CS` (rollup depuis "Alertes émises")
- `Commentaire libre` (texte) — si Robin a ajouté un message dans le thread, le copier ici

En parallèle, marquer l'alerte concernée dans "Alertes émises" avec `Statut = obsolète` (via `historique-alertes-coo` Mode 6).

## Étape 4 — Calculer les ajustements de sensibilité

À la fin de chaque mois (ou au déclenchement de `rapport-mensuel-coo`), agréger les feedbacks par **motif d'alerte**.

Pour chaque motif :

1. Compter le nombre d'alertes émises sur ce motif sur les 3 derniers mois.
2. Compter le nombre de feedbacks "inutile" sur ce motif sur la même fenêtre.
3. Calculer le **taux d'inutilité** : feedbacks / alertes émises.

### Logique d'ajustement

| Taux d'inutilité | Action |
|---|---|
| **< 10 %** | Pas de changement (l'agent est bien calibré sur ce motif). |
| **10 % – 30 %** | Ajustement léger : durcir le seuil de 10 à 20 %. Exemple : silence radio passé de 3 à 4 jours ouvrés ; révisions infinies passées de 4 à 5 ; baisse volume de −30 % à −35 %. |
| **> 30 %** | Ajustement franc : durcir le seuil de 30 à 50 %, ou demander à Robin (au prochain mensuel) si on doit désactiver le motif. |

⚠️ **Ne jamais ajuster automatiquement les seuils des alertes 🔴 URGENT critiques pour la sécurité opérationnelle** (friction nouveau client, multi-signal cumulé). Pour ces motifs, se contenter de **lister** le taux d'inutilité dans le mensuel et laisser Robin trancher.

## Étape 5 — Persister les seuils ajustés

Maintenir une base Notion "Seuils dynamiques" (ou un bloc dédié dans la page de configuration de l'agent) avec :

- `Motif d'alerte` (titre)
- `Seuil par défaut` (texte — ex : "3 jours ouvrés")
- `Seuil actuel` (texte — ex : "4 jours ouvrés")
- `Date de dernière modification` (date)
- `Justification` (texte — ex : "Taux inutilité 18 % sur 3 mois")

Ces seuils sont relus par les skills de rapport (`rapport-quotidien-coo`, `rapport-hebdo-lundi-coo`) au début de leur exécution **à la place** des seuils par défaut codés dans leurs documentations.

## Étape 6 — Reporting au mensuel

Au déclenchement de `rapport-mensuel-coo`, ce skill fournit la synthèse suivante (intégrée au Bloc G "Suggestions d'amélioration") :

- Liste des motifs ayant un taux d'inutilité > 10 % sur les 3 derniers mois.
- Pour chaque motif : seuil par défaut, seuil ajusté, taux d'inutilité.
- Pour les motifs URGENT critiques (taux > 30 % mais ajustement bloqué), présenter à Robin sous la forme :

```
💡 Motif "[motif]" : [N] alertes émises sur 3 mois, dont [X] marquées inutiles ([Y] %).
   → Voulez-vous que je durcisse le seuil ou que je désactive ce motif ?
```

## Mode erreur

Si la base "Feedbacks inutile" ou "Seuils dynamiques" est inaccessible, retourner à l'appelant :

```
⚠️ Apprentissage agent indisponible — feedbacks non traités. Les seuils par défaut restent appliqués.
```

L'agent **revient aux seuils par défaut** définis dans les briefs des skills de rapport — pas de blocage.

## Critères de succès

- Seuls les feedbacks de Robin (et personne d'autre) sont pris en compte.
- Seuls les emoji `:thumbsdown:` et `:no_entry_sign:` déclenchent un enregistrement.
- Aucun feedback "utile" n'est requis (pas d'attente, pas de friction).
- Les ajustements de seuils ne dépassent jamais 50 % du seuil par défaut.
- Les alertes URGENT critiques (friction nouveau client, multi-signal cumulé) ne sont jamais ajustées sans validation explicite de Robin.
- Les alertes marquées "inutile" passent en `Statut = obsolète` dans "Alertes émises".
- En cas d'indisponibilité Notion, retour automatique aux seuils par défaut.
