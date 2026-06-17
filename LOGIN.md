# Page de connexion — LoginPage

Écran d'authentification principal avec animation d'entrée, formulaire Material 3 et gestion des rôles.

## Structure

```
┌──────────────────────────────────────┐
│                                      │
│         🎫 (icône 80px)             │
│         Ontik                        │
│    Event & Ticket Management         │
│                                      │
│   ┌────────────────────────────┐     │
│   │ Welcome back               │     │
│   │ Sign in to continue        │     │
│   │                            │     │
│   │ ✉  Email                   │     │
│   │    your@email.com          │     │
│   │                            │     │
│   │ 🔒  Password               │     │
│   │    ••••••••          👁    │     │
│   │                            │     │
│   │         Forgot password?   │     │
│   │                            │     │
│   │   ┌────────────────────┐   │     │
│   │   │     Sign In        │   │     │
│   │   └────────────────────┘   │     │
│   └────────────────────────────┘     │
│                                      │
│   Don't have an account?  Register   │
│                                      │
└──────────────────────────────────────┘
```

## Animation d'entrée

- `SlideTransition` : décalage vertical `Offset(0, 0.15)` → `Offset.zero`
- `FadeTransition` : opacité 0 → 1
- Courbe `Curves.easeOutCubic`, durée 800ms
- `AnimationController` avec `SingleTickerProviderStateMixin`

## Contrôleurs et état

```dart
final _emailCtrl = TextEditingController();
final _passwordCtrl = TextEditingController();
bool _obscurePassword = true;
bool _loading = false;
String? _error;
```

## Header

| Élément | Détail |
|---------|--------|
| Icône | `confirmation_number_rounded`, 40px, `AppColors.primary` sur fond primary 10%, borderRadius 20 |
| Titre | "Ontik", headlineMedium, bold, letterSpacing -0.5 |
| Sous-titre | "Event & Ticket Management", bodyMedium, `AppColors.textSecondary` |

## Formulaire (`_buildFormCard`)

Carte `Card` avec borderRadius 16, bordure `divider` 0.5 alpha, padding 24.

### Champs

| Champ | Validation | Particularité |
|-------|-----------|---------------|
| Email | Requis + regex email | `email_outlined` prefix, hint "your@email.com" |
| Password | Requis + min 6 car. | `lock_outlined` prefix, toggle visibilité 👁 |

- Champs `filled` avec `AppColors.fieldFill`
- `focusedBorder` : primary 1.5px
- `errorBorder` : error 1px
- Label flottant primary au focus

### Lien "Forgot password?"
- Aligné à droite
- `TextButton` compact (padding 8/4, shrinkWrap)
- Navigue vers `AuthRoutes.forgotPassword`

### Bouton Sign In
- Hauteur 52px, primary, borderRadius 12
- `CircularProgressIndicator` 22px quand `_loading`
- Désactivé pendant le chargement

## Gestion d'erreur

Bannière avec `AppColors.error` 8% fond + bordure 20% + icône `error_outline` + message.
Appel `apiErrorString(e)` pour traduire les exceptions.

## Soumission (`_handleLogin`)

```dart
final data = await AuthService().login(email, password);
```

1. Valide le formulaire
2. Appelle `AuthService().login()`
3. Redirige selon le rôle (`data['role']`):

| Rôle | Destination |
|------|-------------|
| ADMINISTRATEUR + `firstLogin == true` | `AuthRoutes.forgotPassword` |
| ADMINISTRATEUR | `AdminRoutes.layout` |
| ORGANISATEUR | `OrganizerRoutes.layout` |
| CLIENT (autre) | `ClientRoutes.home` |

## Footer

`"Don't have an account?"` + lien **Register** → `AuthRoutes.register`

## Dépendances

- `auth_service.dart` — `AuthService().login()`
- `app_colors.dart` — `AppColors.*`
- `auth_routes.dart` / `client_routes.dart` / `organizer_routes.dart` / `admin_routes.dart`
- `error_helper.dart` — `apiErrorString()`
