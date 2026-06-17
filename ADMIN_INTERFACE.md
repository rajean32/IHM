# Interface Administrateur — Application Flutter Ontik

Page d'administration accessible depuis le sélecteur de rôle après connexion avec un compte `ADMINISTRATEUR`.

## Architecture

```
lib/pages/admin/
├── admin_layout.dart           — Shell NavigationRail + 10 onglets IndexedStack
├── dashboard_page.dart         — Stats + graphiques
├── users_page.dart             — CRUD utilisateurs + audit log
├── events_page.dart            — Liste lecture seule
├── categories_page.dart        — CRUD catégories + sous-page caractéristiques
├── lieux_page.dart             — CRUD lieux + modal salles
├── places_page.dart            — CRUD salles + places (batch, grille, bulk)
├── tickets_page.dart           — Liste lecture seule
├── reservations_page.dart      — Liste + annulation
├── payments_page.dart          — Liste lecture seule
├── profile_page.dart           — Compte admin (ProfileBody partagé)
└── action_history_page.dart    — Audit log avec undo
```

## Structure générale — `AdminLayout`

Barre supérieure : logo Ontik (`Image.asset`) + `Text("Panneau d'administration")` + `NotificationBell()`.

**NavigationRail** (gauche, `labelType: all`, `AppColors.card` bg, `AppColors.primary` 15% indicator) :

| # | Onglet | Icône | Widget |
|---|--------|-------|--------|
| 0 | Tableau de bord | `dashboard` | `DashboardPage` |
| 1 | Utilisateurs | `people` | `UsersPage` |
| 2 | Événements | `event` | `EventsPage` |
| 3 | Catégories | `category` | `CategoriesPage` |
| 4 | Lieux | `location_city` | `LieuxPage` |
| 5 | Places | `meeting_room` | `PlacesPage` |
| 6 | Tickets | `confirmation_number` | `TicketsPage` |
| 7 | Réservations | `book_online` | `ReservationsPage` |
| 8 | Paiements | `payment` | `PaymentsPage` |
| 9 | Compte | `person` | `ProfilePage` |

`IndexedStack` préserve l'état de chaque onglet. Callback `navigateToPlaces(String? salleFilter)` : passage depuis Lieux vers Places avec filtre salle. En quittant l'onglet Places, `_placesSalleFilter` est remis à null.

### États globaux du layout
| État | Comportement |
|------|-------------|
| Initial | `_selectedIndex = 0`, affiche Dashboard |
| Changement onglet | `setState` → reconstruction de l'`IndexedStack` |
| Navigation cross-tab | `navigateToPlaces()` → définit filtre + bascule index 5 |

### Dépendances
- `NotificationService` / `NotificationManager` — connexion STOMP au `/ws` avec JWT
- `NotificationBell` widget
- Tous les 10 widgets de page importés
- `AppColors`, `dio_config`

---

## 1. Dashboard (`DashboardPage`)

**API** : `GET /api/admin/dashboard` → `AdminDashboardStats`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `ErrorState(message:, onRetry:)` avec bouton Réessayer |
| Succès | `RefreshIndicator` > `SingleChildScrollView` > grille + graphiques + événements récents |

### Grille de statistiques (2×3, `GridView.count`, aspect 1.5)

| Carte | Valeur | Icône | Couleur |
|-------|--------|-------|---------|
| Événements | `totalEvents` | `event` | `primary` |
| Clients | `totalClients` | `people` | `secondary` |
| Organisateurs | `totalOrganisateurs` | `badge` | `accent` |
| Revenus | `totalRevenue` Ar | `attach_money` | `#7B1FA2` |
| Lieux | `totalLieux` | `location_city` | `#00897B` |
| Salles | `totalSalles` | `meeting_room` | `#0D47A1` |

Chaque stat : `Card` > `Column` > `Icon` (size 32) + `Text` valeur (size 24, bold) + `Text` label (size 12, `textSecondary`).

### Analytiques (Row, 2 cartes expansées)

**PieChart** (gauche) — "Par statut"
- Données : `eventsByStatus` mappé vers `PieChartSectionData`
- Couleurs : bleu, vert, orange, violet, teal, rouge, indigo (jusqu'à 7)
- Affiche `label\nvaleur` par section
- `centerSpaceRadius: 20`

**BarChart** (droite) — "Par catégorie"
- Données : `eventsByCategorie` mappé vers `BarChartGroupData` / `BarChartRodData`
- Bottom titles tronqués à 6 caractères + ".."
- Axe gauche visible; axes top/right cachés
- Grille visible, pas de bordure

### Événements récents
- Section title "Événements récents" (20 bold)
- `_buildEventRow` : `Card` > `ListTile` avec `Icons.event` + titre + date formatée (fr) + badge statut (`Container` rounded rect, couleur `AppConstants.statutColors` à 20% alpha, texte pleine opacité)

### Widgets internes
| Widget | Rôle |
|--------|------|
| `_buildStatsGrid()` | Grille 2×3 des cartes statistiques |
| `_statCard(label, value, icon, color)` | Carte statistique réutilisable |
| `_buildChartsSection()` | Row PieChart + BarChart |
| `_buildEventRow(Evenement)` | Carte événement récent |

### Dépendances
- `DashboardService.getDashboard()`
- `AdminDashboardStats`, `Evenement` models
- `fl_chart` (PieChart, BarChart)
- `intl` (DateFormat fr)
- `ErrorState`, `AppColors`, `apiErrorString`

---

## 2. Utilisateurs (`UsersPage`)

**API** : `UserService.getUsers()` (`GET /api/auth/users`), `Endpoints.usersAuditLog`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `ErrorState(message:, onRetry:)` |
| Vide (recherche) | `Icons.search_off` + "Aucun utilisateur trouvé" |
| Vide (liste) | `Icons.people_outline` + message vide |
| Succès | `RefreshIndicator` > `ListView.builder` > `_buildUserCard` |

### Barre d'en-tête
- `Text("Gestion utilisateurs")` (18 bold)
- `TextButton.icon` bascule `Icons.history` / `Icons.people` — alterne vue Liste / Audit
- `Icons.refresh` (rechargement)

### Recherche
`TextField` avec `Icons.search` préfixe, `Icons.clear` suffixe (quand requête non vide), `filled: true`, `fillColor: AppColors.fieldFill`, border radius 12.

### Carte utilisateur (`_buildUserCard`)
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` avec couleur du rôle (15% alpha) + icône rôle
  - ADMIN : `admin_panel_settings`, erreur (rouge)
  - ORGANISATEUR : `badge`, accent (violet)
  - CLIENT : `person`, primary (bleu)
- **Title** : `"$prenoms $nom"` (600 weight)
- **Subtitle** : `"$email  •  $role"` (size 12)
- **Trailing** : badge actif/inactif (`Container` secondary/error) + badge "Nouveau" si `premiereConnexion` (accent) + `IconButton` (`Icons.info_outline`) pour ouvrir le modal
- `onTap` → `_showUserInfoModal(user)`

### Modal informations utilisateur (`_showUserInfoModal`)
`DraggableScrollableSheet` (0.85 initial, 0.5-0.95 range) :

**En-tête** : `CircleAvatar` (radius 30, initiale prénom, couleur rôle) + nom (22 bold) + badge rôle (icône + texte) + `IconButton` fermeture (`Icons.close`)

**Statut** : Row chips actif/inactif + "Première connexion" (coloré)

**Section "Informations personnelles"** (`Icons.person_outline`) :
| Champ | Valeur |
|-------|--------|
| Code | Badge stylé |
| Email | Texte |
| Téléphone | Texte |
| Sexe | Texte |
| Date naissance | Texte formaté |

**Section "Informations du compte"** (`Icons.account_circle`) :
| Champ | Valeur |
|-------|--------|
| Rôle | Texte |
| Statut | Badge coloré (actif = vert, inactif = rouge) |
| Première connexion | Badge coloré |
| Type | Texte |

**Section "Actions"** (`Icons.settings`) — 4 `OutlinedButton.icon` full-width :
| Action | Icône | Couleur | Comportement |
|--------|-------|---------|-------------|
| Changer le rôle | `swap_horiz` | Primary | `SimpleDialog` ORGANISATEUR / CLIENT → `PUT .../role` |
| Activer / Désactiver | `block` / `check_circle` | Error / Secondary | `PUT .../toggle-active` |
| Réinitialiser mot de passe | `lock_reset` | Accent | Dialog 2 étapes (confirmer → saisir nouveau mot de passe) |
| Supprimer l'utilisateur | `delete` | Error | `AlertDialog` confirmation + gestion erreur FK |

### Vue Audit
`ListView.builder` > `Card` > `ListTile` : `CircleAvatar` (`Icons.history`) + titre action + code utilisateur + détails. Vide : "Aucune activité".

### Widgets internes
| Widget | Rôle |
|--------|------|
| `_sectionTitle(title, icon)` | Titre de section avec icône |
| `_infoCard(children)` | Carte fond surface, bord radius 12 |
| `_infoRow(icon, label, value, {color})` | Ligne info avec icône, label 120px, valeur |
| `_actionButton({icon, label, color, onTap})` | Bouton plein largeur avec bordure colorée |
| `_getRoleColor(role)` | ADMIN→error, ORGANISATEUR→accent, CLIENT→primary |
| `_getRoleIcon(role)` | Icône par rôle |
| `_toggleActive(user)` | PUT activation/désactivation |
| `_changeRole(user)` | Dialog sélection rôle + PUT |
| `_resetPassword(user)` | Dialog confirmation + saisie mot de passe |
| `_deleteUser(user)` | Confirmation + DELETE + gestion FK |

### Dépendances
- `UserService`, `dio_config`, `Endpoints`
- `UserDetail`, `AuditLogEntry` models
- `ErrorState`, `AppColors`, `apiErrorString`
- `AppConstants` (roleOrganisateur, roleClient)

---

## 3. Événements (`EventsPage`)

**API** : `EvenementService.getEvents()` (`GET /api/evenements`)

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `ErrorState(message:, onRetry:)` |
| Vide | `Icons.event_busy` (48, 40% opacity) + "Aucun événement trouvé" |
| Succès | `RefreshIndicator` > `ListView.builder` > `Card` par événement |

### Barre d'en-tête
- `Text("Événements")` (18 bold)
- `Icons.refresh`

### Recherche
`TextField` avec `Icons.search` préfixe, `OutlineInputBorder`, `isDense`.

### Carte événement
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (couleur statut 20% alpha, icône statut ou `Icons.event`)
- **Title** : `event.titre` (600 weight)
- **Subtitle** : `"${date}  •  ${organisateur}"` (size 12)
- **Trailing** : badge statut (`Container` rounded rect, couleur 20% alpha) + `IconButton` info (`Icons.info_outline`, tooltip "Détails")

### Modal informations (`_showInfoModal`)
`DraggableScrollableSheet` (0.85, 0.5-0.95) :
- **Header** : titre (22 bold) + `Icons.close`
- **Chip statut** : icône + texte sur fond 15% alpha
- **Bannière annulation** (si `statut == 'annule'` et motif présent) : fond rouge teinté, `Icons.warning_amber` + motif
- **Section "Informations"** : description (`Icons.description`), catégorie (`Icons.category`), organisateur (`Icons.person`)
- **Section "Logistique"** : lieu (`Icons.location_on`), date (`Icons.calendar_today`), heure (`Icons.access_time`)
- **Section "Jauge"** : `LinearProgressIndicator` (height 12, rounded) — vert < 50%, orange 50-80%, rouge > 80% — texte `"$reserved / $total réservées"`
- **Section "Caractéristiques"** (si présentes) : paires nom → valeur

### Widgets internes
| Widget | Rôle |
|--------|------|
| `_sectionTitle(title)` | Titre uppercase 14px textSecondary |
| `_infoRow(icon, label, value)` | Ligne avec icône 18, label 100px, valeur |

### Dépendances
- `EvenementService`, `dio_config`, `Endpoints`
- `Evenement` model
- `ErrorState`, `AppColors`, `AppConstants.statutColors`, `AppConstants.statutIcons`, `apiErrorString`

---

## 4. Catégories (`CategoriesPage`)

**API** : `CategorieService`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `Center(child: Text(_error!))` |
| Vide | `Icons.category` (48, 40% opacity) + "Aucune catégorie trouvée" |
| Succès | `RefreshIndicator` > `ListView.builder` > `Card` par catégorie |

### Barre d'en-tête
- `Text("Catégories")` (18 bold)
- `Icons.refresh`

### Recherche
`TextField` avec `Icons.search` préfixe, `OutlineInputBorder`, `isDense`.

### FAB
`Icons.add` → `_showAddDialog()`

### Carte catégorie
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (primary 10% alpha, première lettre du code, uppercase, bold)
- **Title** : `cat.nomCategorie` (500 weight)
- **Subtitle** : `"Code: ${code}"` (size 12) + description optionnelle (size 11, single line ellipsis)
- **Trailing** : `TextButton.icon` (`Icons.list_alt` / "Caract.", size 11) → `_CaracteristiquesPage` + `IconButton` edit (`Icons.edit`) + `IconButton` delete (`Icons.delete`, error)

### Dialog ajouter/éditer catégorie
`DraggableScrollableSheet` (0.7, 0.5-0.9) :
- Code (max 10, désactivé en édition)
- Nom (max 100)
- Description (max 500, 3 lignes)
- Boutons Cancel / Add (ou Modifier)

### Suppression
`AlertDialog` avec Cancel + "Supprimer" (erreur). Gestion erreur FK : reformulation "Cette catégorie est utilisée par des événements...".

### Gestion des caractéristiques (`_CaracteristiquesPage`)
Sous-page plein écran dédiée, encapsulée dans le même fichier.

**États** :
| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Vide | `Icons.list_alt` (48, 40% opacity) + "Aucune caractéristique" |
| Succès | `RefreshIndicator` > `ListView.builder` > `Card` |

**AppBar** : retour + `"Caractéristiques - ${nomCategorie}"`
**Recherche** : identique au parent
**FAB** : `Icons.add`

**Carte caractéristique** :
- `CircleAvatar` (primary 10%, première lettre du nom)
- Title : `"${nom}${obligatoire ? ' *' : ''}"` (500 weight)
- Subtitle : `"Type: ${typeDonnee}${options}  •  Ordre: ${ordre}"`
- Trailing : `Icons.edit` + `Icons.delete` (error)

**Dialog ajout/édition** (`DraggableScrollableSheet` 0.85, 0.5-0.95) :
| Champ | Type |
|-------|------|
| Nom | `TextField` |
| Type | Dropdown : texte / nombre / date / liste déroulante / Oui/Non |
| Ordre d'affichage | `TextField` clavier numérique |
| Options | `TextField` (visible si type = liste), "séparées par virgule" |
| Obligatoire | `SwitchListTile` avec `Container` borduré |

**Suppression** : `AlertDialog` + gestion FK.

### Dépendances
- `CategorieService`, `CaracteristiqueService`, `LieuService`
- `Categorie`, `Caracteristique` models
- `apiErrorString`, `AppColors`

---

## 5. Lieux (`LieuxPage`)

**API** : `LieuService`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `Center(child: Text(_error!))` |
| Vide | `Icons.location_city` (48, 40% opacity) + "Aucun lieu trouvé" |
| Succès | `RefreshIndicator` > `ListView.builder` > `Card` par lieu |

### Barre d'en-tête
- `Text("Lieux")` (18 bold)
- `Icons.refresh`

### Recherche
`TextField` avec `Icons.search` préfixe, `OutlineInputBorder`, `isDense`.

### FAB
`Icons.add` → `_showAddDialog()`

### Carte lieu
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (primary 10% alpha, première lettre code uppercase)
- **Title** : `lieu.nomLieu` (500 weight)
- **Subtitle** : adresse + `"${ville}  •  ${salles.length} salle(s)"` (size 12)
- **Trailing** : `TextButton.icon` (`Icons.info_outline` / "Info", size 11) → `_showSallesModal()` + `Icons.edit` + `Icons.delete` (error)

### Dialog ajout/édition lieu
`DraggableScrollableSheet` (0.75, 0.5-0.9) :
- Code (max 10, désactivé en édition)
- Nom (max 100)
- Adresse (max 200)
- Ville (max 100)
- Validation : code + nom + ville non vides

### Suppression lieu
`AlertDialog` avec gestion FK : "Ce lieu est encore utilisé par des salles...".

### Modal salles (`_showSallesModal`)
`DraggableScrollableSheet` (0.6, 0.3-0.9) :
- **Header** : `"Salles — ${nomLieu}"` + `Icons.close`
- **Vide** : `Icons.meeting_room` (48) + "Aucune salle pour ce lieu" + `ElevatedButton.icon` (`Icons.add` / "Ajouter une salle")
- **Liste** : chaque salle → `Card` avec :
  - `CircleAvatar` : nombre de places
  - Title : `"${nomSalle} — ${nomLieu}"`
  - Subtitle : `"${nPlaces} place(s)"`
  - Trailing : `TextButton` "Gérer les places" → `onGestionPlaces(numeroSalle)` (callback navigation)
- **Pied** : `OutlinedButton.icon` full-width (`Icons.add` / "Ajouter une salle")

### Dialog ajout salle
`DraggableScrollableSheet` (0.5, 0.3-0.7) : champ nom + Cancel/Add → `_api.createSalle()`

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_sallesForLieu(codeLieu)` | Filtre `_allSalles` par codeLieu |
| `_placeCountForSalle(numeroSalle)` | Compte les places d'une salle |

### Dépendances
- `LieuService`, `dio_config`, `Endpoints`
- `Lieu`, `Salle`, `Place` models
- `apiErrorString`, `AppColors`

---

## 6. Places (`PlacesPage`)

**API** : `PlaceService`, `LieuService`

Accepte `initialSalleFilter` optionnel pour filter directement une salle.

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `ErrorState(message:, onRetry:)` |
| Vide (salles) | `_emptyState("Aucune salle trouvée", Icons.meeting_room)` |
| Vide (places) | `_emptyState("Aucune place pour cette salle", Icons.event_seat)` |
| Succès | Salles section + Places section |

### Barre d'en-tête
- `Text("Salles & Places")` (18 bold)
- `Icons.refresh`

### Première ligne : Recherche + Filtre
- Gauche : `TextField` recherche salle (`Icons.search`)
- Droite : `DropdownButtonFormField<String>` filtre lieu ("Tous" + tous les lieux)

### Section Salles
Section title `"Salles (${count})"` (18 bold).
Chaque salle : `Card` > `ListTile` (dense) :
- **Leading** : `CircleAvatar` avec nombre de places (selected = primary, unselected = textSecondary)
- **Title** : `s.nomSalle` (500 weight)
- **Subtitle** : `"${lieu.nomLieu}  •  ${count} place(s)"`
- **Trailing** : `TextButton` "Gérer" / "Fermer" (toggle sélection) + `Icons.edit` + `Icons.delete` (erreur, confirmation dialog)

### Section Places
Apparaît quand une salle est sélectionnée.

**Header** : `"Places — ${salle.nomSalle}"` (16 bold) + bouton mode bulk (`Icons.checklist` / `Icons.close`)

#### Génération en masse (`_generateBatch()`)
Carte "Génération en masse" :
- `_rangCtrl` : `TextFormField` (hint "B", label "Rang", requis)
- Row : `_debutCtrl` ("N° début", clavier numérique) + `Icon(Icons.arrow_forward)` + `_finCtrl` ("N° fin", valide >= début)
- `ElevatedButton.icon` (`Icons.auto_awesome` / "Générer")

#### Recherche place
`_buildPlaceSearchBar()` : `TextField` avec `Icons.search`, `Icons.clear` suffixe

#### Grille des places
Groupées par rang. Chaque rang : header `"Rang ${rang}"` (13, 600 weight) + bouton select-all/deselect-all (mode bulk) + `Wrap` de `_buildPlaceBadge`.

**Place Badge** (`_buildPlaceBadge`) :
- Mode normal : numéro (tap → edit), small `Icons.close` (tap → delete dialog), long-press → `PopupMenu` (Modifier `Icons.edit` / Supprimer `Icons.delete` erreur)
- Mode bulk : checkbox (`Icons.check_box` / `Icons.check_box_outline_blank`) + numéro (tap toggle sélection)
- Style : selected = primary bg 15%, border 1.5px primary; unselected = textSecondary bg 8%, border 1px

#### Suppression groupée
Bouton full-width `ElevatedButton.icon` (`Icons.delete_sweep`, fond erreur, texte blanc) quand `_bulkMode && _selectedPlaceIds.isNotEmpty`. Confirmation dialog → `_bulkDeletePlaces()`.

### Dialog ajout salle
`DraggableScrollableSheet` (0.6, 0.4-0.8) : champ nom + dropdown lieu + validation + Cancel/Add.

### Dialog édition salle
Même formulaire, `numeroSalle` désactivé. Sauvegarde : supprime + recrée.

### Dialog édition place
Modal bottom sheet : champ numéro (validé) + champ rang + Cancel/Enregistrer. Supprime + recrée.

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_filteredSalles` getter | Filtre par lieu + recherche |
| `_placesForSelectedSalle` getter | Places filtrées par salle + recherche |
| `_placeCount(salleNum)` | Compte places d'une salle |
| `_buildSallesSection()` | Liste des salles |
| `_buildPlacesSection()` | Batch + recherche + grille |
| `_buildPlaceSearchBar()` | Champ recherche place |
| `_emptyState(message, icon)` | État vide centré |
| `_buildPlaceBadge(place)` | Badge place individuel |
| `_deleteSalle(id)`, `_deletePlace(id)` | Suppression avec gestion FK |
| `_bulkDeletePlaces()` | Suppression groupée avec confirmation |
| `_generateBatch()` | Génération par lot |
| `_editPlace(place)` | Modal édition place |

### Dépendances
- `LieuService`, `PlaceService`, `dio_config`, `Endpoints`
- `Lieu`, `Salle`, `Place` models
- `ErrorState`, `AppColors`, `apiErrorString`

---

## 7. Tickets (`TicketsPage`)

**API** : `TicketService.getTickets()`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `Center(child: Text(_error!))` |
| Vide | `Icons.confirmation_number` (48, 40% opacity) + "Aucun ticket trouvé" |
| Succès | `RefreshIndicator` > `ListView.builder` |

### Barre d'en-tête
- `Text("Tickets")` (18 bold)
- `Icons.refresh`

### Recherche
`TextField` hint "Rechercher par code, place, événement...", `Icons.search` préfixe, `OutlineInputBorder`, `isDense`.

### Carte ticket
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (accent 20% alpha, `Icons.confirmation_number` accent, size 20)
- **Title** : `t.codeTicket` (500 weight)
- **Subtitle** : `Column` — `"Place: ${numeroPlace}"` + `"Événement #${idEvenement}"` (size 12)
- **Trailing** : badge prix si non null — `Container` secondary 15% alpha, rounded rect, `"Ar ${prix}"` bold secondary

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_filterTickets(query)` | Filtre par codeTicket, numeroPlace, idEvenement, prix |

### Dépendances
- `TicketService`
- `Ticket` model
- `AppColors`, `apiErrorString`

---

## 8. Réservations (`ReservationsPage`)

**API** : `ReservationService.getReservations()`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `Center(child: Text(_error!))` |
| Vide | `Icons.book_online` (48, 40% opacity) + "Aucune réservation trouvée" |
| Succès | `RefreshIndicator` > `ListView.builder` |

### Barre d'en-tête
- `Text("Réservations")` (18 bold)
- `Icons.refresh`

### Recherche
`TextField` hint "Rechercher par ID, client, date...", `Icons.search` préfixe, `OutlineInputBorder`, `isDense`.

### Carte réservation
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (couleur statut 20% alpha, `Icons.cancel` si annulé / `Icons.book_online` si actif, size 20)
- **Title** : `"Réservation #${idReservation}"` (500 weight)
- **Subtitle** : `Column` — `"Client: ${codeClient}"` + `"${date}  •  ${ticketCount} ticket(s)"` (size 12)
- **Trailing** : badge statut (`Container` 20% alpha, "Annulée" / "Active") + `IconButton` annulation (`Icons.cancel`, error, tooltip "Annuler") — visible seulement si non annulé

### Dialog annulation
`AlertDialog` : titre "Annuler la réservation", content avec ID réservation, Cancel + "Annuler" (rouge). Confirmation → `PUT /api/reservations/{id}/cancel`

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_filterReservations(query)` | Filtre par id, codeClient, codeTickets (concaténés), date |
| `_cancel(id)` | PUT annulation + message succès |
| `_showCancelDialog(reservation)` | Dialog confirmation annulation |

### Dépendances
- `ReservationService`, `dio_config`, `Endpoints`
- `Reservation` model
- `AppColors`, `apiErrorString`

---

## 9. Paiements (`PaymentsPage`)

**API** : `PaiementService.getAllPayments()`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `Center(child: Text(_error!))` |
| Vide | `Icons.payment` (48, 40% opacity) + "Aucun paiement trouvé" |
| Succès | `RefreshIndicator` > `ListView.builder` |

### Barre d'en-tête
- `Text("Paiements")` (18 bold)
- `Icons.refresh`

### Recherche
`TextField` hint "Rechercher par ID, montant, mode...", `Icons.search` préfixe, `OutlineInputBorder`, `isDense`.

### Carte paiement
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (couleur mode 20% alpha) :
  - CARTE : `Icons.credit_card`, primary
  - MVOLA : `Icons.phone_android`, accent
  - défaut : `Icons.payment`, secondary
- **Title** : `"Ar ${montant}"` (500 weight)
- **Subtitle** : `Column` — `"Réservation #${idReservation}"` + `"${modePaiement}  •  ${date}"` (size 12)
- **Trailing** : badge mode (`Container` couleur mode 20% alpha, rounded rect, texte mode)

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_filterPayments(query)` | Filtre par idPaiement, montant, modePaiement, idReservation |

### Dépendances
- `PaiementService`
- `Paiement` model (depuis `reservation_model.dart`)
- `AppColors`, `apiErrorString`

---

## 10. Compte (`ProfilePage`)

**API** : `UserService.getUsers()` filtré par `userCode`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` |
| Succès | Widget `ProfileBody` partagé |
| Fallback | nom = `userNom ?? 'Administrateur'`, email = `userCode ?? '--'` |

### ProfileBody
Widget réutilisable (`lib/widgets/profile_body.dart`) configuré avec :
- `name` : `"$_prenoms $_nom"`
- `email` : `$_email` ou fallback
- `badge` : `"ADMINISTRATEUR"`
- `badgeColor` : `Color(0xFF1565C0)` (bleu foncé)
- `onEditProfile` : `_showEditInfo`
- `onLogout` : `_logout`

### Menu "Compte"

| Élément | Icône | Action |
|---------|-------|--------|
| Informations personnelles | `person` | `_showEditInfo()` — modal bottom sheet édition |
| Historique des actions | `history` | Push `ActionHistoryPage` dans un nouveau Scaffold |

### Menu "Sécurité"

| Élément | Icône | Statut | Action |
|---------|-------|--------|--------|
| Mot de passe & 2FA | `lock` | "Sécurisé" | `showPasswordAnd2FABottomSheet(context, is2faEnabled, callback)` |
| Appareils connectés | `devices` | — | `_showConnectedDevices()` |

### Modal édition informations (`_showEditInfo`)
`StatefulBuilder` dans `ModalBottomSheet` (scroll contrôlé, haut arrondi) :
- Title "Informations personnelles" (18, 700 weight)
- 3 `TextField`s : Nom, Prénoms, Email (clavier email)
- Tous désactivés initialement, toggle "Modifier" pour activer
- Sauvegarde : confirmation dialog → `PUT UserService().updateUser()`
- État saving : `CircularProgressIndicator` inline (20×20, stroke 2)
- Résultat : `SnackBar` succès/erreur

### Modal appareils connectés (`_showConnectedDevices`)
`ModalBottomSheet` :
- Title "Appareils connectés" (18, 700 weight)
- Appareil courant : `Icons.phone_android` (32, primary) + plateforme + "Appareil actuel" + badge "Actif" (secondary 15% alpha)
- `Divider`
- `OutlinedButton.icon` (`Icons.logout` / "Déconnecter les autres appareils", error) → confirmation → `POST .../disconnect-others`

### Déconnexion (`_logout`)
`AlertDialog` confirmation → `AuthService().logout()` → `pushNamedAndRemoveUntil(AuthRoutes.login)`

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_loadProfile()` | Charge profil via API, extrait nom/prénoms/email |
| `_showEditInfo()` | Modal bottom sheet édition |
| `_showPasswordAnd2FA()` | Délégue au widget partagé |
| `_showActionHistory()` | Push ActionHistoryPage |
| `_showConnectedDevices()` | Modal appareils connectés |
| `_logout()` | Confirmation + déconnexion + redirection |

### Dépendances
- `AuthService`, `UserService`, `dio_config`
- `AuthRoutes`, `AppColors`, `apiErrorString`
- `ProfileBody`, `ProfileMenuGroup`, `ProfileMenuItem` (`lib/widgets/profile_body.dart`)
- `showPasswordAnd2FABottomSheet` (`lib/widgets/two_factor_widget.dart`)
- `ActionHistoryPage` (même dossier)
- `dart:io` (Platform)

---

## 11. Historique des actions (`ActionHistoryPage`)

**API** : `GET /api/audit-log`, `POST /api/audit-log/{id}/undo`

### États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `Text(error)` + `ElevatedButton` "Réessayer" |
| Vide | `Center(child: Text("Aucune action enregistrée"))` |
| Succès | `RefreshIndicator` > `ListView.builder` > `Card` par entrée |

### Header
`Text("Historique des actions")` (16, 700 weight) + `Text("${n} action(s)")` (12, textMuted) + `Divider`.

### Carte action
`Card` > `ListTile` :
- **Leading** : `CircleAvatar` (couleur action 15% alpha, icône spécifique size 20)
- **Title** : `Row` — `_actionLabel(entry.action)` (14, 500 weight) + badge "Annulée" si `entry.reverted` (orange 15% alpha, orange 10px)
- **Subtitle** : `Column` — `"${codeUtilisateur}  •  ${details}"` (size 12) + `dateAction` (size 11, textMuted)
- **Trailing** : si non révoqué — `TextButton.icon` (`Icons.undo` / "Annuler", rouge, size 12) → `_undoAction(entry)`; si undo en cours — `CircularProgressIndicator` (20×20, strokeWidth 2)

### Types d'actions

| Code action | Libellé français | Icône | Couleur |
|-------------|------------------|-------|---------|
| CREATE_USER | Création d'utilisateur | `person_add` | Vert |
| UPDATE_USER | Modification d'utilisateur | `edit` | Bleu |
| CHANGE_ROLE | Changement de rôle | `swap_horiz` | Orange |
| DEACTIVATE_USER | Désactivation d'utilisateur | `block` | Rouge |
| ACTIVATE_USER | Activation d'utilisateur | `check_circle` | Vert |
| RESET_PASSWORD | Réinitialisation mot de passe | `lock_reset` | Violet |
| DELETE_USER | Suppression d'utilisateur | `person_remove` | Rouge |
| PAIEMENT_EFFECTUE | Paiement effectué | `payment` | Teal |
| REMBOURSEMENT | Remboursement | `replay` | Ambre |

### Undo
Double confirmation dialog → `POST /api/audit-log/{id}/undo` → SnackBar succès/erreur → rechargement logs.

### Widgets internes
| Helper | Rôle |
|--------|------|
| `_loadLogs()` | GET audit-log |
| `_actionLabel(action)` | Mapping code action → libellé français |
| `_actionIcon(action)` | Mapping code action → icône |
| `_actionColor(action)` | Mapping code action → couleur |
| `_undoAction(entry)` | Confirmation → POST undo → reload |

### Dépendances
- `dio_config`, `Endpoints`
- `AuditLogEntry` model (`user_model.dart`)
- `AppColors`, `apiErrorString`

---

## Patterns transversaux

### Pattern : Toast notifications
Toutes les pages CRUD partagent une implémentation identique :
- `OverlayEntry` à `top: 55`, `left: 16`, `right: 16`
- Succès : fond `AppColors.secondary`, `Icons.check_circle` blanc, 2s auto-dismiss
- Erreur : fond `AppColors.error`, `Icons.error_outline` blanc, 3s auto-dismiss

### Pattern : Mise en page des listes
Toutes les pages de liste suivent :
1. Header : title (18 bold) + Spacer + `IconButton` refresh (`Icons.refresh`)
2. `TextField` recherche avec `Icons.search` préfixe, `OutlineInputBorder`, `isDense`
3. `Expanded` : loading / erreur / vide / `RefreshIndicator` > `ListView.builder`

### Pattern : Modals CRUD
- Add/Edit : `ModalBottomSheet` > `DraggableScrollableSheet` > `SingleChildScrollView` > titre + fermeture + champs + Cancel/Save
- Delete : `AlertDialog` avec gestion erreur FK (reformulation française)

### Pattern : Gestion erreurs FK
Test sur sous-chaînes : `'foreign key'`, `'constraint'`, `'integrity'`, `'utilisée'`, `'used'`, `'cannot delete'`, `'referenced'` → message français lisible.

---

## Flux de navigation

```
AdminLayout (NavigationRail 10 onglets, IndexedStack)
│
├── [0] DashboardPage
│     └── (RefreshIndicator → stats + PieChart + BarChart + événements récents)
│
├── [1] UsersPage
│     ├── UserCard → bottom sheet info + actions
│     │     ├── Changer rôle → SimpleDialog → PUT
│     │     ├── Activer/Désactiver → PUT toggle-active
│     │     ├── Reset password → dialog 2 étapes
│     │     └── Supprimer → AlertDialog → DELETE + gestion FK
│     └── Vue Audit → ListView audit-log
│
├── [2] EventsPage
│     └── EventCard → modal info (jauge, caractéristiques)
│
├── [3] CategoriesPage
│     ├── FAB → DraggableSheet ajout catégorie
│     ├── Edit → DraggableSheet édition
│     └── Caract. → _CaracteristiquesPage (plein écran CRUD)
│           ├── FAB → DraggableSheet ajout caractéristique
│           ├── Edit → DraggableSheet édition
│           └── Delete → AlertDialog + gestion FK
│
├── [4] LieuxPage
│     ├── FAB → DraggableSheet ajout lieu
│     ├── Edit → DraggableSheet édition
│     └── Info → modal salles
│           ├── Gérer places → navigateToPlaces(salleFilter)
│           └── Ajouter salle → DraggableSheet
│
├── [5] PlacesPage
│     ├── Section salles (filtre lieu + recherche + liste)
│     │     ├── Tap → sélectionne salle → section places
│     │     ├── Edit → DraggableSheet édition (suppr+recréation)
│     │     └── Delete → AlertDialog + FK
│     └── Section places
│           ├── Génération batch (rang + début + fin → POST)
│           ├── Grille groupée par rang avec Wrap
│           │     ├── Tap → edit place (modal + suppr+recréation)
│           │     ├── Long-press → PopupMenu (Modifier/Supprimer)
│           │     └── X inline → delete dialog
│           └── Mode bulk (checkboxes → sélection groupée → suppression)
│
├── [6] TicketsPage
│     └── (lecture seule)
│
├── [7] ReservationsPage
│     └── ReservationCard → bouton Annuler → AlertDialog → PUT cancel
│
├── [8] PaymentsPage
│     └── (lecture seule)
│
├── [9] ProfilePage (ProfileBody)
│     ├── Infos personnelles → bottom sheet edit (toggle Modifier/Save)
│     ├── Historique → ActionHistoryPage
│     │     └── Undo → double confirmation → POST undo
│     ├── Mot de passe & 2FA → bottom sheet partagé
│     ├── Appareils connectés → modal + déconnecter autres
│     └── Déconnexion → AlertDialog → AuthService.logout → login
```
