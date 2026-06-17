# Interface des notifications — NotificationsPage

Page de liste des notifications in-app, accessible depuis le `NotificationBell` (cloche) dans l'AppBar. Supporte les filtres, le marquage individuel/masse, la suppression par glissement, et la navigation contextuelle au clic.

## Architecture

```
lib/pages/shared/notifications_page.dart
lib/models/notification_model.dart          — InAppNotification
lib/core/services/notification_service.dart  — NotificationService + NotificationManager
lib/core/api/endpoints.dart                  — Endpoints.notifications
backend: NotificationController              — GET/PATCH/DELETE /api/notifications
backend: InAppNotificationRepository         — JPQL + Spring Data queries
```

## États de la page

| État | Affichage |
|------|-----------|
| Chargement | `CircularProgressIndicator` centré |
| Erreur | `ErrorState` avec message et bouton "Réessayer" |
| Vide | Icône `notifications_off` + "Aucune notification" |
| Succès | Liste déroulante (`SliverList`) avec `RefreshIndicator` |

## Barre de filtres

Deux groupes de chips toujours visibles dans un `SingleChildScrollView` horizontal :

### Statut de lecture (ChoiceChip)
| Chip | Valeur de `_filterIsRead` |
|------|--------------------------|
| Toutes | `null` |
| Non lues | `false` |
| Lues | `true` |

### Type de notification (FilterChip)
Types supportés : `PAYMENT_CONFIRMED`, `PAYMENT_FAILED`, `RESERVATION_CONFIRMED`, `RESERVATION_CANCELLED`, `EVENT_CANCELLED`, `EVENT_APPROVED`, `EVENT_UPDATED`, `EVENT_SUSPENDED`, `TICKET_VALIDATED`, `TICKET_ALREADY_USED`, `REFUND_PROCESSED`

Le filtre `null` = "Tous les types". Les chips sont séparés des chips de lecture par un trait vertical.

## Bannière "non lues"

Quand il y a des notifications non lues, une bannière s'affiche au-dessus des chips :
- Icône `mark_email_unread`
- Texte : "X notification(s) non lue(s)"
- Bouton "Tout lire" → appelle `_markAllRead()` (PATCH `/api/notifications/read-all`)

Un bouton "Tout lire" est aussi présent dans l'AppBar (visible uniquement s'il y a des non lues).

## Liste des notifications

Chaque notification est rendue dans un `Dismissible` (swipe → suppression) contenant un `ListTile` :

| Élément | Détail |
|---------|--------|
| Leading | `CircleAvatar` avec fond teinté et icône spécifique au type |
| Titre | Gras si non lue, normal si lue |
| Sous-titre | Message (2 lignes max) + timestamp relatif ("Il y a 5 min") |
| Fond | Léger fond `primary` si non lue |
| Clic | `_onNotificationTap` → marque comme lue + navigation |

### Navigation au clic

```dart
_onNotificationTap(InAppNotification n)
```

1. Marque la notification comme lue via `PATCH /api/notifications/{id}/read`
2. Si `idCible` est présent (parse en int comme eventId) :
   - **ORGANISATEUR / ADMINISTRATEUR** : `Navigator.pop(context)` + `setActiveEvent(eventId, title)` (contexte événement global)
   - **CLIENT** : `Navigator.pushNamed(ClientRoutes.homeDetail, arguments: {'id': eventId})`

### Icônes par type

| Type | Icône | Couleur |
|------|-------|---------|
| PAYMENT_CONFIRMED | `payment` | `secondary` |
| PAYMENT_FAILED | `payment` | `error` |
| RESERVATION_CONFIRMED | `receipt_long` | `primary` |
| RESERVATION_CANCELLED | `event_busy` | `accent` |
| EVENT_CANCELLED | `cancel` | `error` |
| EVENT_APPROVED | `check_circle` | `secondary` |
| EVENT_UPDATED | `update` | `primary` |
| EVENT_SUSPENDED | `pause_circle` | `accent` |
| TICKET_VALIDATED | `qr_code_scanner` | `statusPlanned` |
| TICKET_ALREADY_USED | `warning` | `error` |
| REFUND_PROCESSED | `undo` | `statusPlanned` |
| (défaut) | `notifications` | `textSecondary` |

## Actions

| Action | Déclencheur | API |
|--------|-------------|-----|
| Marquer comme lu | Clic sur notification | `PATCH /api/notifications/{id}/read` |
| Marquer tout comme lu | Bouton "Tout lire" (AppBar + bannière) | `PATCH /api/notifications/read-all` |
| Supprimer | Swipe gauche | `DELETE /api/notifications/{id}` |

## Modèle de données

```dart
class InAppNotification {
  int? id;
  String userId;
  String title;
  String message;
  String type;         // EVENT_CANCELLED, RESERVATION_CONFIRMED, etc.
  bool isRead;
  String? idCible;    // eventId (utilisé pour la navigation)
  DateTime? createdAt;
}
```

## Endpoints backend

| Méthode | URL | Description |
|---------|-----|-------------|
| GET | `/api/notifications?userId={id}&type=&isRead=&dateFrom=&dateTo=` | Liste filtrée |
| GET | `/api/notifications/unread-count?userId={id}` | Compteur non lues |
| PATCH | `/api/notifications/{id}/read` | Marquer une comme lue |
| PATCH | `/api/notifications/read-all` | Marquer tout comme lu |
| DELETE | `/api/notifications/{id}` | Supprimer une notification |
| DELETE | `/api/notifications?userId={id}` | Supprimer toutes |

## NotificationManager (WebSocket + polling)

- Connexion STOMP au `/ws` avec token JWT
- Souscription `/user/{userId}/queue/notifications` pour les notifications push
- Polling de fallback toutes les 30s : `GET /api/notifications/unread-count`
- `ValueNotifier<int> unreadCount` mis à jour → consommé par `NotificationBell`
