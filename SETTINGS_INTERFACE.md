# Interface Paramètres — SettingsPage

Page partagée accessible depuis :
- ⚙ Icône dans l'AppBar (tous les rôles)
- Menu "Paramètres" dans l'onglet Compte (organisateur, admin)

## Structure (4 sections)

### 1. Préférences (icône `tune`)
Regroupe Langue + Apparence.

#### 1a. Langue
| Élément | État |
|---------|------|
| Français | Radio sélectionné si `appLanguage == 'fr'` |
| English | Radio sélectionné si `appLanguage == 'en'` |

- Radio buttons `radio_button_unchecked` / `check_circle`
- Carte avec bordure colorée si sélectionné
- Persistance via `SharedPreferences` (clé `pref_language`)
- Appel à `setAppLanguage(code)`

#### 1b. Apparence
| Élément | Valeur | Icône |
|---------|--------|-------|
| Clair | `light` | `light_mode` |
| Sombre | `dark` | `dark_mode` |
| Système | `system` | `settings_brightness` |

- Même système radio que la langue
- Persistance via `SharedPreferences` (clé `pref_theme`)
- Appel à `setAppTheme(value)`
- Résolution système via `resolveTheme()` → `platformDispatcher.platformBrightness`

### 2. Sécurité (icône `shield_outlined`)
| Élément | Icône | Action | Trailing |
|---------|-------|--------|----------|
| Mot de passe & 2FA | `lock_outline` | `showPasswordAnd2FABottomSheet()` | Badge vert "Sécurisé" |
| Appareils connectés | `devices_outlined` | Bottom sheet plateforme + déconnexion | Chevron `>` |

- Badge "Sécurisé" avec fond vert 10% + texte vert
- État `_is2faEnabled` géré localement

### 3. Compte (icône `person_outline`)
| Élément | Icône | Couleur | Action |
|---------|-------|---------|--------|
| Déconnexion | `logout` | Rouge | Dialog confirmation → `clearSession()` + `AuthRoutes.login` |
| Supprimer le compte | `delete_forever` | Rouge | Dialog confirmation + stub |

- Sous-titre "Cette action est irréversible" pour suppression
- Widget `_showConfirmDialog(title, message, onConfirm)` réutilisable

## Widgets internes

| Widget | Rôle |
|--------|------|
| `_sectionHeader(IconData, String)` | Titre de section avec icône + texte primaire |
| `_sectionSubHeader(String)` | Sous-titre grisé (ex: "Langue", "Apparence") |
| `_langTile(code, label, isSelected)` | Carte radio pour langue |
| `_themeTile(value, label, isSelected, icon)` | Carte radio pour thème |
| `_actionTile({icon, title, subtitle, trailing, destructive, onTap})` | Carte d'action générique avec badge ou chevron |
| `_buildBadge(text, color)` | Badge stylé (ex: "Sécurisé") |
| `_showConfirmDialog(title, message, onConfirm)` | Dialog de confirmation générique |

## Dépendances

- `app_config.dart` — `appLanguage`, `appThemeMode`, `appConfigNotifier`
- `app_localizations.dart` — `tr()` pour les libellés localisés
- `two_factor_widget.dart` — `showPasswordAnd2FABottomSheet()`
- `dio_config.dart` — `clearSession()`, `userCode`
- `auth_routes.dart` — `AuthRoutes.login`
- `app_colors.dart` — `AppColors.*`, `AppTheme.*`

## Comportement

- Changement langue → notification via `appConfigNotifier` → rebuild immédiat de toutes les pages qui écoutent
- Changement thème → notification via `appConfigNotifier` → rebuild immédiat
- Toutes les préférences persistées automatiquement dans `SharedPreferences`
- Aucun reload manuel requis
