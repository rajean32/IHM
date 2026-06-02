# Architecture Ontik

## Structure `lib/`

```
lib/
├── core/
│   ├── api/                  -- Couche HTTP pure (classes XxxApi)
│   │   ├── dio_config.dart       (Dio partagé + gestion token)
│   │   ├── endpoints.dart        (URLs API)
│   │   ├── auth_api.dart         (AuthApi)
│   │   ├── evenement_api.dart    (EvenementApi)
│   │   ├── reservation_api.dart  (ReservationApi)
│   │   ├── ticket_api.dart       (TicketApi)
│   │   ├── paiement_api.dart     (PaiementApi)
│   │   ├── user_api.dart         (UserApi)
│   │   ├── categorie_api.dart    (CategorieApi)
│   │   ├── lieu_api.dart         (LieuApi)
│   │   ├── place_api.dart        (PlaceApi)
│   │   └── dashboard_api.dart    (DashboardApi)
│   ├── services/             -- Logique métier (classes XxxService)
│   │   ├── auth_service.dart
│   │   ├── evenement_service.dart
│   │   ├── reservation_service.dart
│   │   ├── ticket_service.dart
│   │   ├── paiement_service.dart
│   │   ├── user_service.dart
│   │   ├── categorie_service.dart
│   │   ├── lieu_service.dart
│   │   ├── place_service.dart
│   │   └── dashboard_service.dart
│   ├── assets/               (app_colors, app_icons, app_images)
│   └── routes/               (app_router + routes par rôle)
├── models/                   (Classes métier, suffixe _model)
├── pages/
│   ├── auth/                 (login, register, forgot-password)
│   ├── client/               (home, réservation, paiement, ticket, profil)
│   ├── organizer/            (dashboard, événements, pricing, scan)
│   └── admin/                (dashboard, users, events, lieux, places, etc.)
├── widgets/                  (Composants réutilisables)
└── main.dart
```

## Principe API / Service

**API (`core/api/xxx_api.dart`)** -- classes `XxxApi` :

- Appels HTTP uniquement (`dio.get/post/put/delete`)
- Retournent `List<dynamic>` ou `Map<String, dynamic>` (JSON brut)
- Aucune logique métier
- Ne gèrent pas les tokens

**Service (`core/services/xxx_service.dart`)** -- classes `XxxService` :

- Utilisent les `XxxApi` pour les appels HTTP
- Ajoutent la logique métier (gestion token, validations, transformations)
- Seuls les services sont importés par les pages

## Flux type

```
Page (StatefulWidget)
  └─> AuthService.login(email, password)
        └─> AuthApi.login(email, password)    // HTTP call
              └─> dio.post(Endpoints.login)
        └─> setToken()                        // sauvegarde token
        └─> setUserInfo()                     // sauvegarde infos user
        └─> return data
```

## Règles

- Les pages n'importent jamais `core/api/xxx_api.dart` directement
- Les pages n'importent `core/api/dio_config.dart` que pour les appels HTTP ponctuels non couverts par les services
- Les classes API et Service sont instanciées (pas de singleton), seul Dio est partagé via `dio_config.dart`
- Modèles suffixés `_model.dart` (ex: `evenement_model.dart`)
- Fichiers API suffixés `_api.dart` (ex: `auth_api.dart`)
- Fichiers services suffixés `_service.dart` (ex: `auth_service.dart`)

## Exemple concret

### API (`core/api/auth_api.dart`) -- pur HTTP

```dart
class AuthApi {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await dio.post(Endpoints.login, data: {
      'email': email,
      'motDePasse': password,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }
}
```

### Service (`core/services/auth_service.dart`) -- logique métier

```dart
class AuthService {
  final _authApi = AuthApi();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _authApi.login(email, password);
    await setToken(data['token'] as String?);
    await setUserInfo(data);
    return data;
  }
}
```
