# Contexte Notion — FOCUS

Ce fichier est la référence commune pour tous les skills qui interagissent avec Notion.
Lire ce fichier en début d'exécution évite de redéfinir le contexte dans chaque skill.

---

## Membres de l'équipe

| Nom | Email |
|-----|-------|
| Diana Holczinger | diana@wearefocus.co |
| Inès Vigneras | ines@wearefocus.co |
| Axelle Delanoë | axelle@wearefocus.co |
| Anton Naimi | anton@wearefocus.co |
| Wesley Ibouroi | wesley@wearefocus.co |
| Lisa Lauri | lisa@wearefocus.co |
| Amélie Oudinot | amelie@wearefocus.co |
| Stella Baruchello | stella@wearefocus.co |
| Robin Berezowa | robin@wearefocus.co |
| Clément Brhr | clement@wearefocus.co |
| Laura Renault | laura@wearefocus.co |
| Maréva Giovannetti | mareva@wearefocus.co |
| Marion Gueutal | marion@wearefocus.co |
| Sanya Lepère | sanya@wearefocus.co |

---

## Squads

Les squads sont les équipes internes de FOCUS. Chaque squad est identifiée par le nom de son lead.

| Squad | Membres |
|-------|---------|
| **Squad Axelle** | Axelle Delanoë, Clément Brhr, Laura Renault, Maréva Giovannetti |
| **Squad Diana** | Diana Holczinger, Inès Vigneras, Marion Gueutal, Sanya Lepère |

Les membres non listés dans une squad (Anton, Wesley, Lisa, Amélie, Stella, Robin) sont considérés hors-squad.

### User IDs Notion

| Membre | User ID Notion |
|--------|---------------|
| Diana Holczinger | `0139b7a3-0008-4060-b881-861897886f23` |
| Inès Vigneras | `272d872b-594c-812e-a9a0-0002d16539a7` |
| Axelle Delanoë | `0285aba8-49db-420b-adad-8809a9cee813` |

Pour les autres membres, le matching se fait via le nom complet ou l'email retourné par Notion.

---

## Bases de données Notion importantes

### Facturation — `ADMIN - SUIVI TEAM`
Suivi de la facturation clients : factures émises, statuts de règlement, retards.
Utiliser ce tableau pour tout ce qui concerne les paiements, les impayés, le chiffre d'affaires.

- **Database ID** : `34f1716d-f23c-80d0-b9e3-e9eb069a148d`
- **Data source URL** : `collection://2e61716d-f23c-80e7-b114-000b8e4ec430`

Schéma des champs :

| Champ | Type | Valeurs / Notes |
|-------|------|-----------------|
| NAME | title | nom de la facture / ligne |
| CLIENT | relation | client lié |
| N° FACTURE | text | numéro de facture (vide = pas encore émise) |
| RÈGLEMENT | select | `À FACTURER` · `0 - TO BE PAID` · `1 - PAID` · `2 - LATE` |
| TYPE | select | `MONTHLY` · `ONE-SHOT` |
| DATE | date | date prévue / d'émission (sert d'échéance pour le calcul du retard) |
| TOTAL CA | euro | montant HT |
| PROJECT MANAGER | person | identifie la squad (voir section Squads) |

### Fiches clients — `ADMIN - DATABASE - CLIENT`
Une fiche par client, avec les informations visibles côté client uniquement.

### Fiches monteurs — `ADMIN - DATABASE - PRODUCTION`
Une fiche par monteur (prestataire de production), avec les informations visibles côté production uniquement.

---

## Fonctionnement des fiches en double

Chaque carte de production existe **en deux exemplaires** :
- une fiche dans `ADMIN - DATABASE - CLIENT` (informations destinées au client)
- une fiche dans `ADMIN - DATABASE - PRODUCTION` (informations destinées au monteur)

Les deux fiches coexistent car certaines données doivent rester confidentielles d'un côté ou de l'autre.
Les membres de l'équipe FOCUS ont accès aux deux fiches et voient donc la vision complète.

---

## Listes de référence

### Clients — base `CLIENTS`
La liste des clients de FOCUS se trouve dans la base Notion intitulée **`CLIENTS`**.
Utiliser cette base pour identifier ou retrouver un client par son nom.

### Monteurs — base `PRODUCTION`
La liste des monteurs (prestataires de production) se trouve dans la base Notion intitulée **`PRODUCTION`**.
Utiliser cette base pour identifier ou retrouver un monteur par son nom.
