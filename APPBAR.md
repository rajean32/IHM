# Barre supérieure — AppBar (OrganizerLayout)

AppBar Material 3 avec sélecteur d'événement global, icône paramètres et cloche de notifications.

## Structure

```
┌─────────────────────────────────────────────────────────────┐
│  [Sélecteur événement (dropdown)]        ⚙  🔔             │
└─────────────────────────────────────────────────────────────┘
```

## Éléments

### Titre — Sélecteur d'événement (dropdown)

Remplace le titre statique "Ontik - Organisateur" par un `DropdownButtonFormField<int?>` lorsque les événements sont chargés.

| Valeur | Label | activeEventId |
|--------|-------|---------------|
| `null` | "Tous les événements" | `null` |
| `idEvenement` | Titre de l'événement | `idEvenement` |

- **Hauteur** : 36px, dense
- **Style** : 14px semibold, couleur `onPrimary`
- **Dropdown** : fond `surface`
- Appel `setActiveEvent(id, titre)` au changement

### Actions (trailing)

1. **⚙ Paramètres** (`Icons.settings`)
   - `onPressed` → `Navigator.pushNamed(context, '/settings')`
   - Mène à `SettingsPage` (4 sections : Préférences, Sécurité, Compte, Informations)

2. **🔔 Notifications** (`NotificationBell`)
   - Widget personnalisé connecté via `NotificationManager`
   - SSE (Server-Sent Events) pour notifications en temps réel

## Chargement initial

```dart
if (userCode != null) {
  NotificationManager.connect(userCode!, null);
  _loadEvents(); // EvenementService().getEvents()
}
```

Les événements sont chargés dans `initState` et stockés dans `_events`. Le dropdown n'apparaît qu'après chargement (`_eventsLoaded`).

## Responsive / Fallback

- **Avant chargement** : titre texte statique `"Ontik - Organisateur"`
- **Aucun événement** : titre texte statique (liste vide)

## Dépendances

- `app_config.dart` — `activeEventId`, `activeEventName`, `setActiveEvent()`
- `EvenementService` — chargement de la liste
- `NotificationBell` — widget cloche
- `SettingsPage` — accessible via `/settings`
