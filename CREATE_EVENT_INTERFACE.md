# Interface de création d'événement — CreateEventPage

Formulaire multi-étapes (wizard) pour créer ou modifier un événement. Accessible depuis :
- FAB "Créer" sur la page Événements
- Bouton "Créer" dans les actions rapides du Dashboard
- Menu "Modifier" sur une carte événement (mode édition)

## Architecture générale

`CreateEventPage` gère l'état complet du formulaire. Chaque étape est un widget fonction séparé dans `create_event_page/`.

```
create_event_page/
├── step_1_general.dart    — Infos générales + catégorie + caractéristiques
├── step_2_date_time.dart  — Date, heure, durée
├── step_3_location.dart   — Lieu, salle, configuration placement
├── step_4_pricing.dart    — Tarification par type + plan de salle
└── step_5_summary.dart    — Récapitulatif avant soumission
```

## Navigation — Stepper

Barre d'étapes en haut avec 5 étapes :

| Étape | Titre | Validation |
|-------|-------|------------|
| 1 | Infos | Titre + Catégorie + Caractéristiques obligatoires |
| 2 | Date & Heure | Date + Heure de début |
| 3 | Lieu & Places | Lieu + Salle (si sièges) |
| 4 | Prix | Libre (toujours valide) |
| 5 | Récapitulatif | Soumission finale |

- Indicateur circulaire avec numéro (ou check si complété)
- L'utilisateur peut revenir aux étapes précédentes
- Bouton "Retour" / "Suivant" en bas
- Dernière étape : bouton "Publier l'événement" avec loading state

## Étape 1 — Informations générales

### Champs
| Champ | Type | Validation |
|-------|------|------------|
| Titre * | `TextFormField` | Requis |
| Description | `TextFormField` (3 lignes) | Optionnel |
| Image | Image picker (gallery, 1920x1080 max) | Optionnel |
| Catégorie * | `DropdownButtonFormField<String>` | Requis, charge les caractéristiques au changement |
| Type de placement | Radio : LIBRE / NUMÉROTÉ / MIXTE | Définit les étapes 3 et 4 |

### Caractéristiques dynamiques
Chargeées depuis l'API via `CaracteristiqueService.getByCategorie(code)` au changement de catégorie.
Types supportés :
- `texte` / `nombre` → `TextEditingController`
- `select` → `DropdownButtonFormField`
- `boolean` → `Switch` / `Checkbox`

La validation `_requiredCaracteristiquesValid` vérifie que tous les champs obligatoires sont remplis.

## Étape 2 — Date & Heure

### Champs
| Champ | Widget | Contraintes |
|-------|--------|-------------|
| Date * | `showDatePicker` | ≥ aujourd'hui (création), ≥ 2020 (édition) |
| Nombre de jours | `DropdownButtonFormField<int>` (1-7) | Par défaut 1 |
| Heure début * | Time picker `showTimePicker` | Requis |
| Durée heures | `DropdownButtonFormField<int>` (0-12) | Par défaut 2h |
| Durée minutes | `DropdownButtonFormField<int>` (0, 15, 30, 45) | |

- Affichage de la date de fin calculée (date début + nombre jours - 1)
- Durée totale formatée (ex: "2h 30m")

## Étape 3 — Lieu & Configuration

### Lieu
`DropdownButtonFormField<String>` chargé depuis `LieuService.getLieux()`.
Le changement de lieu déclenche le chargement des salles via `LieuService.getSallesByLieu(code)`.

### Configuration selon le type de placement

#### LIBRE (debout)
- `SwitchListTile` : "Sans salle spécifique" (optionnel)
- Si décoché : sélection de salle
- Capacité : `Switch` illimitée / `TextFormField` nombre
- Types de places : Standard, VIP + types personnalisés
- Prix par type de place

#### NUMÉROTÉ (assis numéroté)
- Sélection de salle obligatoire
- Chargement du plan de salle via `PlaceService.getPlacesBySalle(code)`
- Types de places + prix

#### MIXTE (assis-debout)
- Salle obligatoire
- Types de places + prix
- Zones debout personnalisables (nom, capacité, prix)

## Étape 4 — Tarification

### Pour LIBRE
- Cartes de prix pour chaque type de place
- Affichage des zones debout (si MIXTE)

### Pour NUMÉROTÉ / MIXTE
- Prix par type de place (`PlaceService.setTypePricing`)
- **Plan de salle** : sélection par rangée ou place individuelle
  - `selectedRows` : `Set<String>` des rangées cochées
  - `selectedPlaceIds` : `Set<String>` des places individuelles
  - Grille expandable des places
- Assignation de type : `DropdownButtonFormField<String>` avec types disponibles
  - Bouton "Appliquer" → ajoute à `pendingRowAssignments` / `pendingPlaceAssignments`
  - Envoi batch via `PlaceService.assignTypes` à la création

## Étape 5 — Récapitulatif

Carte récapitulative affichant toutes les données saisies :
- Titre + image
- Catégorie + caractéristiques
- Date, heure, durée, date de fin
- Lieu + salle
- Type de placement
- Types de places + prix
- Zones debout (MIXTE)

## Soumission (`_submit`)

1. Construit l'objet `Evenement` avec toutes les données
2. Si mode édition : `EvenementService.updateEvent(id, json)`
3. Si mode création :
   - `EvenementService.createEvent(json)` → `created`
   - Si NUMÉROTÉ/MIXTE : envoi des prix + assignations de type
   - Si MIXTE : création des zones debout
   - Si image : upload via `EvenementService.uploadImage`
4. SnackBar succès + `Navigator.pop(context)`

## Gestion du retour arrière

`PopScope` avec `onPopInvokedWithResult` + `_onWillPop()` :
- Si step > 0 : retour à l'étape précédente
- Si formulaire vide : retour direct
- Si formulaire rempli : dialog "Quitter ? Les modifications seront perdues"

## États

| État | Comportement |
|------|-------------|
| `_dataLoading = true` | `CircularProgressIndicator` centré |
| `_loading = true` | Bouton "Publier" désactivé + spinner |
| Erreur API | SnackBar avec `apiErrorString(e)` |

## Dépendances

- `evenement_service.dart` — CRUD événements + zones debout + upload image
- `lieu_service.dart` — lieux + salles
- `place_service.dart` — configuration places + prix + assignation types
- `categorie_service.dart` — catégories d'événements
- `caracteristique_service.dart` — caractéristiques par catégorie
- `image_picker` — sélection photo
- `event_place_config_model.dart` — `EventPlaceConfig`
- `evenement_model.dart` — `Evenement`, `EvenementCaracteristiqueValeur`
