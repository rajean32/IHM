# Barre de navigation inférieure — NavigationBar (OrganizerLayout)

Barre à 4 onglets avec `NavigationBar` Material 3, préservant l'état via `IndexedStack`.

## Onglets

| Index | Onglet | Icône | Widget | Description |
|-------|--------|-------|--------|-------------|
| 0 | Dashboard | `dashboard` | `DashboardPage` | Vue stratégique : KPIs, graphiques, top événements |
| 1 | Événements | `event` | `EventPage` | Gestion : liste, recherche, création, modification |
| 2 | Réservations | `receipt_long` | `ReservationsPage` | Liste filtrée avec recherche client et statut |
| 3 | Compte | `person` | `ProfilePage` | Profil organisateur : infos, revenus, déconnexion |

## Comportement

- **`selectedIndex`** : état local `_currentIndex` (int)
- **`onDestinationSelected`** : `setState(() => _currentIndex = i)`
- **Navigation externe** : `DashboardPage` et `EventPage` peuvent basculer vers l'onglet Réservations via le callback `_navigateToReservation(eventId)` → `setState(() => _currentIndex = 2)`

## Code

```dart
bottomNavigationBar: NavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (i) => setState(() => _currentIndex = i),
  destinations: const [
    NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.event), label: 'Événements'),
    NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Réservations'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Compte'),
  ],
),
```

## Remarques

- Le 4e onglet était "Tickets" initialement → remplacé par "Compte" (Profil) lors de la restructuration UX
- La navigation programmatique (callback) évite la duplication des boutons d'action
