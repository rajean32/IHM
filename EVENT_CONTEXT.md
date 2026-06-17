# Event Context Global — Gestion multi-événements

## État global défini dans `app_config.dart`

```dart
int? activeEventId;           // null = "Tous les événements"
String activeEventName = '';  // Nom de l'événement sélectionné

final ValueNotifier<int> eventContextNotifier = ValueNotifier(0);

void setActiveEvent(int? eventId, String eventName) {
  activeEventId = eventId;
  activeEventName = eventName;
  eventContextNotifier.value++;
}
```

## Sélecteur dans l'AppBar (`OrganizerLayout`)

Dropdown dans l'AppBar remplaçant le titre statique :
- **"Tous les événements"** → `activeEventId = null`
- **Liste des événements** → `activeEventId = idEvenement`

Charge les événements au démarrage via `EvenementService().getEvents()`.

## Comportement par page

| Page | activeEventId = null | activeEventId ≠ null |
|------|---------------------|---------------------|
| **Dashboard** | Affiche tous les événements | Affiche tous les événements + chip du nom actif dans l'en-tête (section "Aperçu") |
| **Événements** | Liste complète (inchangée) | Liste complète (inchangée) |
| **Réservations** | Sélecteur d'événement manuel affiché + champ recherche client + filtre statut | Charge automatiquement les réservations de l'événement sélectionné |
| **Détail Réservation** | — | Carte "Événement : [nom]" en haut du détail (header violet) |

## Réactivité

Toutes les pages souscrivent à `eventContextNotifier` via `addListener()` dans `initState` et `removeListener()` dans `dispose`.

- `DashboardPage` → `_onContextChanged()` appelle `setState({})`
- `ReservationsPage` → `_onEventContextChanged()` recharge les réservations si `activeEventId` change
- `ReservationDetailPage` → affiche `widget.eventName ?? activeEventName` dans une carte d'en-tête
