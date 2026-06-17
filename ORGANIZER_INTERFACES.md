# Interfaces de l'organisateur — Application Flutter Ontik

## Structure générale — `OrganizerLayout`

Barre supérieure : logo Ontik + **sélecteur d'événement global** (dropdown) + icône ⚙ Paramètres + cloche notifications.

Le sélecteur d'événement global permet de choisir un événement actif. Ce choix est partagé entre toutes les pages via `eventContextNotifier` (`app_config.dart`). Les valeurs possibles sont :
- **"Tous les événements"** (valeur par défaut, `activeEventId = null`)
- **Un événement spécifique** (`activeEventId = idEvenement`, `activeEventName = titre`)

**4 onglets** en bas (NavigationBar) :

| # | Onglet | Icône | Widget |
|---|--------|-------|--------|
| 0 | Dashboard | `dashboard` | `DashboardPage` |
| 1 | Événements | `event` | `EventPage` |
| 2 | Réservations | `receipt_long` | `ReservationsPage` |
| 3 | Compte | `person` | `ProfilePage` |

Un `IndexedStack` préserve l'état de chaque onglet.
Callback `_navigateToReservation(eventId)` : Dashboard et Événements → basculent vers l'onglet Réservations.

### Gestion multi-événements (Event Context Global)

Un état global est défini dans `app_config.dart` :
- `activeEventId` (`int?`) — l'événement actuellement sélectionné, ou `null` pour "tous"
- `activeEventName` (`String`) — le nom de l'événement sélectionné
- `eventContextNotifier` — `ValueNotifier<int>` qui notifie tous les écrans lors d'un changement

**Comportement par page :**
| Page | activeEventId = null | activeEventId ≠ null |
|------|---------------------|---------------------|
| **Dashboard** | Affiche tous les événements | Affiche tous les événements + chip du nom actif dans l'en-tête |
| **Événements** | Liste complète (inchangée) | Liste complète (inchangée) |
| **Réservations** | Sélecteur d'événement manuel affiché | Charge auto les réservations de l'événement sélectionné |
| **Détail Réservation** | — | Carte "Événement : [nom]" en haut du détail |

---

## 1. Dashboard (`DashboardPage`)

**API** : `GET /api/organisateurs/{code}/dashboard` → `OrganizerDashboardStats`

### Filtres (carte en haut)
- Dropdown événement (Tous / spécifique)
- Dropdown période (Tout / En cours / À venir / Passés)

### Grille de stats (4 cartes modernes avec dégradé)

| Carte | Valeur | Icône | Couleur |
|-------|--------|-------|---------|
| Recettes | `totalRevenue` Ar | `attach_money` | Vert |
| Remplissage | `fillRate` % | `pie_chart` | Bleu |
| Billets vendus | `totalTicketsSold` | `confirmation_number` | Orange |
| Places dispo. | `placesDisponibles` | `event_seat` | Violet |

### Mes événements (section tapable)
- Pour chaque événement de `myEvents` : titre + badge statut + barre de progression (`places réservées / placesTotal`) + compteur + pourcentage
- Tap → navigue vers l'onglet Réservations filtré pour cet événement

### Chronologie des événements
- 5 événements triés par date
- Icône de statut (UPCOMING / ONGOING / TERMINATED)
- Compte à rebours

### Évolution des ventes
- BarChart (`fl_chart`) des `dailySales` (date, tickets vendus)

### Top événements
- Classement des `topEvents` avec numéro et places disponibles

### Actions rapides (4 boutons)
| Bouton | Icône | Page |
|--------|-------|------|
| Créer | `add` | `CreateEventPage` |
| Scanner | `qr_code_scanner` | `ScanPage` |
| Remboursements | `money_off` | `RefundPage` |
| Export | `download` | `DataExportPage` |

---

## 2. Événements (`EventPage`)

**API** : `GET /api/evenements` filtré par `codeOrganisateur`

- Barre de recherche + filtre période (Tous / À venir / Aujourd'hui / Passés)
- FAB : Créer un événement

### Carte événement
- Avatar circulaire avec icône de statut (horloge / play / check)
- Titre + date
- Badge statut (UPCOMING / ONGOING / TERMINATED) avec couleur
- PopupMenu :
  - **Info** → dialog détaillé (statut, date, heure, compte à rebours, description, catégorie, lieu, organisateur, caractéristiques)
  - **Prix** → `PricingPage` (gestion des prix par zone)
  - **Modifier** → `CreateEventPage` (mode édition)
  - **Supprimer** → confirmation dialog + appel API
- Compte à rebours
- **Expand "Voir les réservations"** (chevron) :
  - **API** : `GET /api/organisateur/evenements/{id}/reservations`
  - Affiche les 5 dernières réservations en mini-cartes :
    - Nom client, email, téléphone
    - Date de réservation
    - Nombre de billets + montant
    - Badge statut paiement (VALIDÉ / EN_ATTENTE)
    - Bouton **Détail** → `ReservationDetailPage`
    - Bouton **Tout voir** → onglet Réservations

---

## 3. Réservations (`ReservationsPage`)

**API** : `GET /api/organisateur/evenements/{id}/reservations`

- Sélecteur d'événement (dropdown)
- Filtre période (Tous / Aujourd'hui / 7 jours / 30 jours)
- Barre récapitulative : nombre de réservations + montant total

### Carte réservation
- `"Réservation #ID"` + nom client + date + montant
- Expandable :
  - Liste des tickets (code, place, prix)
  - Bouton **Détail complet** → `ReservationDetailPage`
  - Bouton **Voir événement** → `CreateEventPage` (mode édition)
- Pull-to-refresh

---

## 4. Compte / Profil (`ProfilePage`)

**API** : `GET /api/organisateurs/{code}` via `UserService.getOrganizerProfile()`

- En-tête : avatar (initiale), nom/prénoms, email, badge "ORGANISATEUR" (violet #673AB7)

### Menu "Compte"
| Élément | Icône | Action |
|---------|-------|--------|
| Informations personnelles | `person` | Bottom sheet d'édition (nom, prénoms, email, téléphone) avec bouton Modifier → Enregistrer + confirmation |
| Revenus | `payments` | Bottom sheet avec données du dashboard : Revenu total, Billets vendus, Taux remplissage, Places dispo., + tableau des 7 dernières ventes quotidiennes |

### Bouton Déconnexion
- Rouge, avec confirmation dialog
- `clearSession()` + redirection vers `AuthRoutes.login`

---

## Pages supplémentaires

| Page | Accès | Description |
|------|-------|-------------|
| `CreateEventPage` | FAB Événements + Créer (dashboard) | Formulaire création / édition d'événement |
| `ScanPage` | Scanner (dashboard) | Scan QR code pour validation de ticket |
| `RefundPage` | Remboursements (dashboard) | Gestion des remboursements |
| `DataExportPage` | Export (dashboard) | Export des données |
| `PricingPage` | Menu Prix (carte événement) | Gestion des prix par zone / type de place |
| `ReservationDetailPage` | Détail (réservation) | Vue détaillée : client, paiement, billets |

### Paramètres (⚙ dans l'AppBar)
Page partagée (`SettingsPage`) avec :
- **Langue** : Français / English
- **Apparence** : Clair / Sombre / Système
- **Sécurité** : Mot de passe & 2FA + Appareils connectés

---

## Flux de navigation

```
OrganizerLayout
├── DashboardPage
│   ├── → CreateEventPage (Créer)
│   ├── → ScanPage (Scanner)
│   ├── → RefundPage (Remboursements)
│   ├── → DataExportPage (Export)
│   └── tap événement → onglet Réservations
├── EventPage
│   ├── FAB → CreateEventPage
│   ├── Popup Info → dialog
│   ├── Popup Prix → PricingPage
│   ├── Popup Modifier → CreateEventPage
│   ├── Popup Supprimer → confirm + API
│   └── expand réservation → ReservationDetailPage
├── ReservationsPage
│   └── Détail → ReservationDetailPage
├── ProfilePage
│   ├── Informations personnelles → bottom sheet edit
│   └── Revenus → bottom sheet revenue
└── SettingsPage (⚙)
    ├── Langue
    ├── Apparence
    └── Sécurité → bottom sheet password/2FA + appareils
```
