# Page d'inscription — RegisterPage

Écran d'inscription avec formulaire complet, animations d'entrée, sélecteurs de genre/type et validation.

## Structure

```
┌──────────────────────────────────────┐
│  ← (back)                            │
│                                      │
│  Create Account                      │
│  Fill in your details to get started │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ Last Name     First Name     │    │
│  │ [Doe        ] [John        ] │    │
│  │                              │    │
│  │ Gender        Account Type   │    │
│  │ [Male ▼     ] [Client ▼    ] │    │
│  │                              │    │
│  │ 📅 Date of Birth             │    │
│  │    10/05/1990           >   │    │
│  │                              │    │
│  │ ✉ Email                     │    │
│  │    john@example.com         │    │
│  │                              │    │
│  │ 📞 Phone                     │    │
│  │    +261 34 00 000 00        │    │
│  │                              │    │
│  │ 🔒 Password                  │    │
│  │    ••••••••            👁   │    │
│  │                              │    │
│  │   ┌────────────────────┐     │    │
│  │   │  Create Account    │     │    │
│  │   └────────────────────┘     │    │
│  └──────────────────────────────┘    │
│                                      │
│  Already have an account?  Login     │
│                                      │
└──────────────────────────────────────┘
```

## Animation d'entrée

Identique à `LoginPage` : `SlideTransition` + `FadeTransition`, 800ms, `Curves.easeOutCubic`.

## Contrôleurs et état

```dart
final _nomCtrl, _prenomsCtrl, _emailCtrl, _telCtrl, _passwordCtrl;
String _sexe = 'M';
String _type = 'client';
DateTime? _dateDeNaissance;
bool _obscurePassword = true;
bool _loading = false;
String? _error;
```

## Header

- **Bouton retour** : `arrow_back_rounded`, fond `fieldFill`, borderRadius 12
- **Titre** : "Create Account", 28px bold, letterSpacing -0.5
- **Sous-titre** : "Fill in your details to get started", 15px, `textSecondary`

## Formulaire (`_buildFormCard`)

Carte `Card` avec borderRadius 20, élévation 2, ombre primary 8% alpha.

### Champs (ordre)

| Champ | Widget | Validation |
|-------|--------|-----------|
| Nom & Prénoms | `Row` de 2 `_buildTextField` | Required |
| Sexe (M/F) | `_buildDropdown` | — |
| Type (client/organisateur) | `_buildDropdown` | — |
| Date de naissance | `_buildDateField` → `showDatePicker` | Required (SnackBar si null) |
| Email | `_buildTextField` | Required + regex email |
| Téléphone | `_buildTextField`, clavier phone | Required |
| Password | `_buildPasswordField` avec toggle visibilité | Required + min 6 car. |

### Widgets réutilisables

| Widget | Description |
|--------|-------------|
| `_buildTextField({controller, label, hint, icon, keyboardType, validator})` | TextFormField standard avec remplissage, bordure arrondie 14, icône préfixe |
| `_buildDropdown({label, icon, value, items, onChanged})` | DropdownButtonFormField avec `keyboard_arrow_down` icône |
| `_buildDateField()` | InkWell + InputDecorator → `showDatePicker` avec thème primary |
| `_buildPasswordField()` | TextFormField avec toggle visibilité suffix |
| `_buildErrorBanner()` | Bannière rouge identique à LoginPage |
| `_buildRegisterButton()` | ElevatedButton 52px, primary, disabled pendant chargement |

### DatePicker

- `initialDate` : -18 ans (`Duration(days: 6570)`)
- `firstDate` : 1900
- `lastDate` : -1 an (`Duration(days: 365)`)
- Format affiché : `dd/MM/yyyy`

## Soumission (`_handleRegister`)

```dart
await AuthService().register({
  'nom': ...,
  'prenoms': ...,
  'sexe': ...,
  'dateDeNaissance': DateFormat('yyyy-MM-dd').format(...),
  'email': ...,
  'tel': ...,
  'motDePasse': ...,
  'type': ...,
});
```

1. Valide le formulaire + vérifie `_dateDeNaissance != null`
2. Appelle `AuthService().register()` avec les données formatées
3. SnackBar "Inscription réussie. Connectez-vous." + redirection vers `AuthRoutes.login`
4. Erreur → bannière via `apiErrorString(e)`

## Footer

`"Already have an account?"` + lien **Login** → `Navigator.pop(context)`

## Dépendances

- `auth_service.dart` — `AuthService().register()`
- `app_colors.dart` — `AppColors.*`
- `auth_routes.dart` — `AuthRoutes.login`
- `error_helper.dart` — `apiErrorString()`
- `intl` — `DateFormat`
