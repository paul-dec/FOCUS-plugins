---
name: comptes-cles-top10-coo
description: >
  Ce skill doit être utilisé quand l'utilisateur demande de "recalculer les
  comptes clés", "mettre à jour le Top 10 clients", "rafraîchir la liste des
  comptes stratégiques", ou quand le rapport-mensuel-coo doit recalculer la
  liste des Top 10 clients par CA cumulé historique avant de produire le bilan.
metadata:
  version: "0.1.0"
---

Calculer et maintenir la liste des **Top 10 comptes clés** de FOCUS, définis comme les 10 clients avec le plus gros **CA cumulé historique**. La source unique est Notion (le brief original mentionnait Pennylane mais toutes les informations financières sont en réalité dans Notion).

> Pour la liste des bases Notion disponibles (notamment la base où sont consolidés les CA clients), lire `NOTION.md` à la racine du projet.

⚠️ Recalcul **mensuel uniquement** (pas quotidien) — pour des raisons de performance et parce que le ranking ne bouge pas significativement d'un jour à l'autre.

⚠️ **Exclusion stricte** : si Anton Naimi, Amélie, Lisa, Stella apparaissent comme propriétaires de comptes dans des données historiques, ignorer leur présence (le ranking porte sur les **clients**, pas sur les CS).

## Étape 1 — Localiser la base Notion contenant les CA clients

Utiliser le MCP Notion pour rechercher la base consolidant les revenus / CA par client (ex : base "Clients", "ADMIN - SUIVI TEAM", "Facturation"…).

⚠️ La structure exacte est à confirmer avec Robin. **Si plusieurs bases candidates existent, privilégier celle qui contient un champ explicite de type "CA cumulé" ou "Montant facturé total" par client.**

En cas d'échec à cette étape, aller directement au **Mode erreur**.

## Étape 2 — Extraire les CA cumulés par client

Pour chaque client présent dans la base :

1. Récupérer le CA cumulé historique (somme de toutes les factures émises depuis le début de la collaboration, peu importe le statut de paiement).
2. Si le CA cumulé n'est pas un champ direct mais doit être calculé (somme de factures unitaires liées), agréger côté agent.
3. Exclure les clients dont la collaboration est terminée depuis > 12 mois (sauf si CA cumulé encore très élevé — seuil à valider avec Robin lors de la calibration).

## Étape 3 — Trier et sélectionner le Top 10

1. Trier les clients par CA cumulé décroissant.
2. Sélectionner les 10 premiers.
3. Pour chaque client du Top 10, extraire :
   - Nom du client
   - CA cumulé historique
   - Date de début de collaboration
   - Statut actuel (actif / stand-by / maintenance) — déterminé par la présence d'une carte projet Notion en statut "actif" sur son dashboard
   - CS / squad rattaché(e) si l'info est disponible

## Étape 4 — Stocker la liste Top 10

Écrire la liste dans la base Notion dédiée "Top 10 comptes clés" (à créer si elle n'existe pas) avec horodatage.

Champs par ligne :

- `Client` (titre)
- `Rang` (nombre, 1 à 10)
- `CA cumulé` (nombre, en €)
- `Date début collaboration` (date)
- `Statut` (select : `actif` / `stand-by` / `maintenance`)
- `Squad rattachée` (select : `Diana` / `Axelle` / `mixte` / `n/a`)
- `Date de calcul` (date)

⚠️ **Versionner** : ne pas écraser la liste précédente, conserver l'historique des Top 10 mois par mois pour pouvoir détecter les entrées/sorties de Top 10 dans le mensuel.

## Étape 5 — Mode "lecture" (chargement par un autre skill)

Quand un skill appelant (`rapport-quotidien-coo`, `rapport-hebdo-lundi-coo`, `rapport-mensuel-coo`) demande la liste des comptes clés :

1. Lire la dernière version horodatée de la base "Top 10 comptes clés".
2. Si la dernière version a plus de **35 jours**, alerter l'appelant : `⚠️ Top 10 comptes clés non rafraîchi depuis > 35 jours — recalcul à déclencher.`
3. Retourner la liste des 10 clients au format structuré (nom, CA cumulé, statut, squad).

## Étape 6 — Détection des entrées/sorties de Top 10 (utile au mensuel)

Lors du recalcul, comparer la nouvelle liste à celle du mois précédent. Identifier :

- **Nouvelles entrées** (clients qui entrent dans le Top 10 ce mois-ci).
- **Sorties** (clients qui quittent le Top 10 ce mois-ci).

Retourner cette info à l'appelant (`rapport-mensuel-coo`) pour qu'il l'intègre dans le Bloc A (priorités opérationnelles) ou le Bloc D (alertes baisse de volume) si pertinent.

## Mode erreur

Si la base Notion source est introuvable ou si les données sont incomplètes, retourner à l'appelant :

```
⚠️ Top 10 comptes clés indisponible — [raison technique courte].
```

L'appelant signalera la donnée manquante dans son rapport et utilisera la **dernière liste connue** si elle existe en base.

## Critères de succès

- Le Top 10 est calculé sur le CA cumulé historique (pas le CA du mois).
- La liste est versionnée mois par mois (pas écrasée).
- Le statut actif/stand-by/maintenance est correctement renseigné via le critère "carte projet Notion en statut actif".
- L'alerte "non rafraîchi > 35 jours" se déclenche si le recalcul est en retard.
- Les entrées/sorties de Top 10 sont détectées et fournies à l'appelant mensuel.
- Aucune valeur inventée si Notion est inaccessible.
