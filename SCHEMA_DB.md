# Schéma de la Base de Données — Gestion d'Événements

## Légende

| Notation | Signification |
|----------|---------------|
| `PK` | Primary Key |
| `FK` | Foreign Key |
| `🔑` | Clé primaire |
| `➡️` | Référence (FK) |
| `NOT NULL` | Champ obligatoire |
| `AUTO` | Auto-incrémenté |
| `enum` | Valeur parmi une liste fixe |

---

## Structure Générale des Relations

```
LIEU ──1:N──> SALLE ──1:N──> PLACE
                                 │
LIEU ──1:N──> EVENEMENT           │
  │              │                │
  │              ▼                ▼
  │         TICKET ────N:M──── CONCERNER ──N:M──── RESERVATION
  │           │                                    │
  │           ▼                                    ▼
  │      ZONE_STANDING                       PAIEMENT
  │
  └──> CATEGORIE ──1:N──> CARACTERISTIQUE
                              │
                              ▼
                   EVENEMENT_CARACTERISTIQUE_VALEUR
```

### Héritage Utilisateur (JOINED)

```
UTILISATEUR (table mère)
  ├── CLIENT (table fille)
  └── ORGANISATEUR (table fille)
ADMINISTRATEUR (table séparée)
```

---

## 1. `UTILISATEUR` — Utilisateurs (table mère JOINED)

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeUtilisateur` | `VARCHAR(50)` | `PK` | Code unique généré (ex: `CLI_XXX`, `ORG_XXX`) |
| `Nom` | `VARCHAR(100)` | `NOT NULL` | Nom de famille |
| `Prenoms` | `VARCHAR(150)` | `NOT NULL` | Prénom(s) |
| `Sexe` | `VARCHAR(1)` | `NOT NULL` | `M` ou `F` |
| `DateDeNaissance` | `DATE` | `NOT NULL` | Date de naissance |
| `E_mail` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Adresse email (login) |
| `Tel` | `VARCHAR(20)` | `NOT NULL` | Numéro de téléphone |
| `Ville` | `VARCHAR(100)` | | Ville de résidence |
| `MotDePasse` | `VARCHAR(255)` | `NOT NULL` | Mot de passe hashé (BCrypt) |
| `PremiereConnexion` | `BOOLEAN` | `NOT NULL`, default `true` | Flag premier login |
| `CodeAdministrateur` | `VARCHAR(50)` | `FK ➡️ ADMINISTRATEUR` | Admin qui a créé le compte |

**Relations :**
- `1:N` avec `ADMINISTRATEUR` (via `CodeAdministrateur`)
- `1:1` avec `CLIENT` (jointure par `CodeClient = CodeUtilisateur`)
- `1:1` avec `ORGANISATEUR` (jointure par `CodeOrganisateur = CodeUtilisateur`)

---

## 2. `CLIENT` — Clients (hérite de UTILISATEUR)

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeClient` | `VARCHAR(50)` | `PK`, `FK ➡️ UTILISATEUR.CodeUtilisateur` | Code client |

**Relations :**
- `1:N` avec `RESERVATION` (via `CodeClient`)

---

## 3. `ORGANISATEUR` — Organisateurs (hérite de UTILISATEUR)

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeOrganisateur` | `VARCHAR(50)` | `PK`, `FK ➡️ UTILISATEUR.CodeUtilisateur` | Code organisateur |

**Relations :**
- `1:N` avec `EVENEMENT` (via `CodeOrganisateur`)

---

## 4. `ADMINISTRATEUR` — Administrateurs

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeAdministrateur` | `VARCHAR(50)` | `PK` | Code admin |
| `MotdepasseAdministrateur` | `VARCHAR(255)` | `NOT NULL` | Mot de passe |

**Relations :**
- `1:N` avec `UTILISATEUR` (via `CodeAdministrateur`)

---

## 5. `LIEU` — Lieux d'événements

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `code` | `VARCHAR(50)` | `PK` | Code lieu (ex: `L001`) |
| `NomLieu` | `VARCHAR(150)` | `NOT NULL` | Nom du lieu |
| `adresse` | `VARCHAR(255)` | | Adresse |
| `ville` | `VARCHAR(100)` | | Ville |

**Relations :**
- `1:N` avec `SALLE` (via `codeLieu`)
- `1:N` avec `EVENEMENT` (via `codeLieu`)

---

## 6. `SALLE` — Salles

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `NumeroSalle` | `VARCHAR(50)` | `PK` | Code salle (ex: `L001_RESTO`) |
| `NomSalle` | `VARCHAR(100)` | `NOT NULL` | Nom de la salle |
| `type` | `VARCHAR(50)` | | Type de salle |
| `capacite` | `INTEGER` | | Capacité maximale |
| `RangePlace` | `VARCHAR(50)` | | Préfixe de rangée par défaut |
| `type_agencement` | `VARCHAR(50)` | `NOT NULL`, default `UNIQUEMENT_ASSIS` | `enum: UNIQUEMENT_ASSIS, TABLE_ASSIS, ASSIS_DEBOUT, DEBOUT_AVEC_LIMITE, DEBOUT_SANS_LIMITE` |
| `codeLieu` | `VARCHAR(50)` | `NOT NULL`, `FK ➡️ LIEU.code` | Lieu parent |

**Relations :**
- `N:1` avec `LIEU`
- `1:N` avec `PLACE`
- `N:M` avec `CATEGORIE` (via `SALLE_TYPE_EVENEMENT`)

---

## 7. `PLACE` — Sièges/Places

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `NumeroPlace` | `VARCHAR(50)` | `PK` | Référence unique (ex: `L001_RESTO-A1`) |
| `RangePlace` | `VARCHAR(50)` | | Lettre de rangée (ex: `A`) |
| `NumeroSalle` | `VARCHAR(50)` | `NOT NULL`, `FK ➡️ SALLE.NumeroSalle` | Salle parente |

**Format de `NumeroPlace` :** `{salleNumero}-{rang}{numéro}` → `L001_RESTO-A1`

**Relations :**
- `N:1` avec `SALLE`
- `1:N` avec `CONCERNER` (via `NumeroPlace`)
- `1:N` avec `EVENEMENT_PLACE_CONFIG` (via `NumeroPlace`)

---

## 8. `EVENEMENT` — Événements

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idEvenement` | `INTEGER` | `PK`, `AUTO` | ID auto-incrémenté |
| `titre` | `VARCHAR(150)` | `NOT NULL` | Titre de l'événement |
| `description` | `TEXT` | | Description |
| `dateEvenement` | `DATE` | `NOT NULL` | Date de l'événement |
| `dateFin` | `DATE` | | Date de fin |
| `heureEvenement` | `TIME` | | Heure de début |
| `prix` | `DECIMAL(10,2)` | | Prix par défaut |
| `capacite` | `INTEGER` | | Capacité totale |
| `image` | `BYTEA` | | Image (binaire) |
| `statut` | `VARCHAR(50)` | | Statut (ex: `ACTIF`, `ANNULE`) |
| `motifAnnulation` | `TEXT` | | Motif si annulé |
| `type_agencement` | `VARCHAR(50)` | | `enum: UNIQUEMENT_ASSIS, TABLE_ASSIS, ASSIS_DEBOUT, DEBOUT_AVEC_LIMITE, DEBOUT_SANS_LIMITE` |
| `CodeCategorie` | `VARCHAR(50)` | `FK ➡️ CATEGORIE.CodeCategorie` | Catégorie d'événement |
| `codeLieu` | `VARCHAR(50)` | `FK ➡️ LIEU.code` | Lieu |
| `numeroSalle` | `VARCHAR(50)` | `FK ➡️ SALLE.NumeroSalle` | Salle |
| `CodeOrganisateur` | `VARCHAR(50)` | `NOT NULL`, `FK ➡️ ORGANISATEUR.CodeOrganisateur` | Organisateur |

**Relations :**
- `N:1` avec `CATEGORIE`, `LIEU`, `SALLE`, `ORGANISATEUR`
- `1:N` avec `CONCERNER`, `EVENEMENT_CARACTERISTIQUE_VALEUR`
- `1:N` avec `EVENEMENT_PLACE_CONFIG`
- `1:N` avec `ZONE_STANDING`
- `1:N` avec `TICKET`
- `1:N` avec `REDUCTION`
- `1:1` avec `SEANCE_CINEMA`

---

## 9. `CATEGORIE` — Catégories d'événements

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeCategorie` | `VARCHAR(50)` | `PK` | Code (ex: `CAT005`) |
| `NomCategorie` | `VARCHAR(100)` | `NOT NULL` | Nom (ex: `Concert`) |
| `description` | `TEXT` | | Description |
| `dateCreation` | `TIMESTAMP` | | Date de création |
| `type_agencement` | `VARCHAR(50)` | | Type d'agencement par défaut |
| `specificConfig` | `TEXT` | | Configuration spécifique (JSON) |

**Relations :**
- `1:N` avec `EVENEMENT`
- `1:N` avec `CARACTERISTIQUE`
- `N:M` avec `SALLE` (via `SALLE_TYPE_EVENEMENT`)

---

## 10. `CARACTERISTIQUE` — Caractéristiques de catégorie

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idCaracteristique` | `INTEGER` | `PK`, `AUTO` | ID auto-incrémenté |
| `nom` | `VARCHAR(100)` | `NOT NULL` | Nom (ex: `type evenement`) |
| `typeDonnee` | `VARCHAR(50)` | `NOT NULL` | Type (boolean, text, etc.) |
| `obligatoire` | `BOOLEAN` | `NOT NULL` | Champ obligatoire |
| `ordreAffichage` | `INTEGER` | | Ordre d'affichage |
| `options` | `TEXT` | | Options (JSON) |
| `codeCategorie` | `VARCHAR(50)` | `NOT NULL`, `FK ➡️ CATEGORIE.CodeCategorie` | Catégorie parente |

**Relations :**
- `N:1` avec `CATEGORIE`
- `1:N` avec `EVENEMENT_CARACTERISTIQUE_VALEUR`

---

## 11. `EVENEMENT_CARACTERISTIQUE_VALEUR` — Valeurs des caractéristiques

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idValeur` | `INTEGER` | `PK`, `AUTO` | ID auto-incrémenté |
| `idEvenement` | `INTEGER` | `NOT NULL`, `FK ➡️ EVENEMENT.idEvenement` | Événement |
| `idCaracteristique` | `INTEGER` | `NOT NULL`, `FK ➡️ CARACTERISTIQUE.idCaracteristique` | Caractéristique |
| `valeur` | `TEXT` | | Valeur (ex: `true`, `false`) |

**Relations :**
- `N:1` avec `EVENEMENT`
- `N:1` avec `CARACTERISTIQUE`

---

## 12. `TICKET` — Billets

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeTicket` | `VARCHAR(50)` | `PK` | Code unique du billet |
| `prix` | `DECIMAL(10,2)` | `NOT NULL` | Prix unitaire |
| `id_zone` | `INTEGER` | `FK ➡️ ZONE_STANDING.id_zone` | Zone debout (si applicable) |
| `id_evenement` | `INTEGER` | `FK ➡️ EVENEMENT.idEvenement` | Événement (fallback) |

**Format de `CodeTicket` :** `TKT{eventId}{MMddHH}{seq}` → `TKT26061720001`

**Relations :**
- `1:N` avec `CONCERNER`
- `1:N` avec `CORRESPOND_A`
- `N:1` avec `ZONE_STANDING`
- `N:1` avec `EVENEMENT`

---

## 13. `CONCERNER` — Lien Ticket-Place-Événement (ternaire)

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idEvenement` | `INTEGER` | `PK`, `FK ➡️ EVENEMENT.idEvenement` | Événement |
| `CodeTicket` | `VARCHAR(50)` | `PK`, `FK ➡️ TICKET.CodeTicket` | Billet |
| `NumeroPlace` | `VARCHAR(50)` | `PK`, `FK ➡️ PLACE.NumeroPlace` | Siège |

**PK composite :** `(idEvenement, CodeTicket, NumeroPlace)`

Une place est considérée "réservée" si une entrée `CONCERNER` existe.

---

## 14. `CORRESPOND_A` — Lien Ticket-Réservation

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `CodeTicket` | `VARCHAR(50)` | `PK`, `FK ➡️ TICKET.CodeTicket` | Billet |
| `idReservation` | `INTEGER` | `PK`, `FK ➡️ RESERVATION.idReservation` | Réservation |

**PK composite :** `(CodeTicket, idReservation)`

---

## 15. `RESERVATION` — Réservations

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idReservation` | `INTEGER` | `PK`, `AUTO` | ID auto-incrémenté |
| `dateReservation` | `TIMESTAMP` | `NOT NULL` | Date de réservation |
| `CodeClient` | `VARCHAR(50)` | `NOT NULL`, `FK ➡️ CLIENT.CodeClient` | Client |

**Relations :**
- `N:1` avec `CLIENT`
- `1:1` avec `PAIEMENT`
- `1:N` avec `CORRESPOND_A`

---

## 16. `PAIEMENT` — Paiements

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idPaiement` | `INTEGER` | `PK`, `AUTO` | ID auto-incrémenté |
| `montant` | `DECIMAL(10,2)` | `NOT NULL` | Montant payé |
| `datePaiement` | `TIMESTAMP` | `NOT NULL` | Date du paiement |
| `modePaiement` | `VARCHAR(50)` | `NOT NULL` | Mode (MOBILEMONEY, CARTE) |
| `idReservation` | `INTEGER` | `NOT NULL`, `UNIQUE`, `FK ➡️ RESERVATION.idReservation` | Réservation |

**Relations :**
- `1:1` avec `RESERVATION`
- `1:1` avec `PAIEMENT_TRANSACTION`

---

## 17. `PAIEMENT_TRANSACTION` — Transactions de paiement

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idTransaction` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `idPaiement` | `INTEGER` | `NOT NULL`, `FK ➡️ PAIEMENT.idPaiement` | Paiement |
| `referenceTransaction` | `VARCHAR(100)` | | Référence MVola/Orange |
| `numeroTelephone` | `VARCHAR(20)` | | Numéro du payeur |
| `nomComplet` | `VARCHAR(100)` | | Nom du payeur |
| `statut` | `VARCHAR(50)` | `NOT NULL`, default `EN_ATTENTE` | Statut |
| `messageReponse` | `TEXT` | | Message de l'API paiement |
| `dateTransaction` | `TIMESTAMP` | | Date de la transaction |

---

## 18. `ZONE_STANDING` — Zones debout

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id_zone` | `INTEGER` | `PK`, `AUTO` | ID auto-incrémenté |
| `id_evenement` | `INTEGER` | `NOT NULL`, `FK ➡️ EVENEMENT.idEvenement` | Événement |
| `nom` | `VARCHAR(100)` | `NOT NULL` | Nom de la zone |
| `capacite` | `INTEGER` | | Capacité maximale |
| `prix` | `DECIMAL(10,2)` | `NOT NULL` | Prix par personne |
| `statut` | `VARCHAR(20)` | default `ACTIVE` | Statut |
| `reservations_actuelles` | `INTEGER` | default `0` | Nb de réservations actuelles |

---

## 19. `EVENEMENT_PLACE_CONFIG` — Configuration place par événement

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `idEvenement` | `INTEGER` | `NOT NULL`, `FK ➡️ EVENEMENT.idEvenement` | Événement |
| `NumeroPlace` | `VARCHAR(50)` | `NOT NULL`, `FK ➡️ PLACE.NumeroPlace` | Siège |
| `typePlace` | `VARCHAR(50)` | `NOT NULL` | Catégorie (ex: `Standard`, `VIP`) |
| `prix` | `DECIMAL(10,2)` | `NOT NULL` | Prix pour cet événement |
| `range` | `VARCHAR(10)` | `NOT NULL` | Rangée (ex: `A`) |
| `statut` | `VARCHAR(20)` | `NOT NULL`, default `DISPONIBLE` | `DISPONIBLE`, `RESERVEE`, `INDISPONIBLE`, `EN_ATTENTE` |

**Contrainte unique :** `(idEvenement, NumeroPlace)`

---

## 20. `SALLE_TYPE_EVENEMENT` — Types d'événements par salle (N:M)

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `numeroSalle` | `VARCHAR(50)` | `PK`, `FK ➡️ SALLE.NumeroSalle` | Salle |
| `codeCategorie` | `VARCHAR(50)` | `PK`, `FK ➡️ CATEGORIE.CodeCategorie` | Catégorie |

**PK composite :** `(numeroSalle, codeCategorie)`

---

## 21. `REDUCTION` — Réductions/Codes promo

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idReduction` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `code` | `VARCHAR(50)` | `UNIQUE` | Code promo |
| `mode` | `VARCHAR(50)` | `NOT NULL` | `enum: CODE_PROMO, ETUDIANT, PREMIERES_RESERVATIONS` |
| `tauxReduction` | `DECIMAL(5,2)` | | Taux en % |
| `valeurFixe` | `DECIMAL(10,2)` | | Montant fixe |
| `dateDebut` | `TIMESTAMP` | | Début de validité |
| `dateFin` | `TIMESTAMP` | | Fin de validité |
| `utilisationMax` | `INTEGER` | | Nombre d'utilisations max |
| `utilisationCount` | `INTEGER` | default `0` | Utilisations actuelles |
| `actif` | `BOOLEAN` | default `true` | Actif ou non |
| `idEvenement` | `INTEGER` | `FK ➡️ EVENEMENT.idEvenement` | Événement ciblé |

---

## 22. `IN_APP_NOTIFICATIONS` — Notifications in-app

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `Id` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `user_id` | `VARCHAR(255)` | `NOT NULL` | ID de l'utilisateur |
| `title` | `VARCHAR(100)` | `NOT NULL` | Titre |
| `message` | `VARCHAR(500)` | `NOT NULL` | Message |
| `type` | `VARCHAR(50)` | `NOT NULL` | Type de notification |
| `is_read` | `BOOLEAN` | `NOT NULL`, default `false` | Lue ou non |
| `id_cible` | `VARCHAR(255)` | | ID de l'entité ciblée |
| `created_at` | `TIMESTAMP` | `NOT NULL` | Date de création |

---

## 23. `ACTION_LOG` — Journal d'actions

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `IdAction` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `CodeUtilisateur` | `VARCHAR(50)` | `NOT NULL` | Utilisateur ayant agi |
| `Action` | `VARCHAR(255)` | `NOT NULL` | Action effectuée |
| `EntityType` | `VARCHAR(100)` | | Type d'entité concernée |
| `EntityId` | `VARCHAR(100)` | | ID de l'entité |
| `Details` | `TEXT` | | Détails (JSON) |
| `DateAction` | `TIMESTAMP` | `NOT NULL` | Date de l'action |
| `Reverted` | `BOOLEAN` | `NOT NULL`, default `false` | Action annulée |

---

## 24. `FILM` — Films (cinéma)

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idFilm` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `titre` | `VARCHAR(200)` | `NOT NULL` | Titre du film |
| `synopsis` | `TEXT` | | Synopsis |
| `realisateur` | `VARCHAR(100)` | | Réalisateur |
| `acteurs` | `TEXT` | | Acteurs (JSON) |
| `dureeMinutes` | `INTEGER` | | Durée en minutes |
| `affiche` | `BYTEA` | | Affiche (binaire) |
| `bandeAnnonce` | `VARCHAR(500)` | | URL bande-annonce |

**Relations :**
- `1:N` avec `SEANCE_CINEMA`

---

## 25. `SEANCE_CINEMA` — Séances de cinéma

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `idSeance` | `BIGINT` | `PK`, `AUTO` | ID auto-incrémenté |
| `idFilm` | `BIGINT` | `NOT NULL`, `FK ➡️ FILM.idFilm` | Film |
| `idEvenement` | `INTEGER` | `NOT NULL`, `FK ➡️ EVENEMENT.idEvenement` | Événement lié |
| `dateSeance` | `DATE` | `NOT NULL` | Date de la séance |
| `heureSeance` | `TIME` | `NOT NULL` | Heure de la séance |
| `version` | `VARCHAR(20)` | | Version (VF, VOST, etc.) |
| `langue` | `VARCHAR(50)` | | Langue |
| `sousTitres` | `VARCHAR(50)` | | Langue des sous-titres |

---

## Flux de Réservation (End-to-End)

```
1. CLIENT sélectionne des places → POST /api/tickets (1 par siège)
2. CLIENT crée une réservation → POST /api/reservations
3. CLIENT paie → POST /api/paiements
4. Résultat:
   - TICKET ↔ CONCERNER ↔ PLACE + EVENEMENT
   - TICKET ↔ CORRESPOND_A ↔ RESERVATION
   - RESERVATION ↔ PAIEMENT
   - PAIEMENT ↔ PAIEMENT_TRANSACTION
```

## Types Énumérés

| Enum | Valeurs |
|------|---------|
| `TypeAgencement` | `UNIQUEMENT_ASSIS`, `TABLE_ASSIS`, `ASSIS_DEBOUT`, `DEBOUT_AVEC_LIMITE`, `DEBOUT_SANS_LIMITE` |
| `StatutPlace` | `DISPONIBLE`, `RESERVEE`, `INDISPONIBLE`, `EN_ATTENTE` |
| `ModeReduction` | `CODE_PROMO`, `ETUDIANT`, `PREMIERES_RESERVATIONS` |
| `StatutPaiement` | `EN_ATTENTE`, `CONFIRME`, `ECHOUÉ`, `REMBOURSE`, `ANNULE` |
| `TypePaiement` | `MOBILEMONEY`, `CARTE` |
