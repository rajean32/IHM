# Interface Utilisateur — Ontik

## 1. Carte Événement (EventCard)

**Fichier :** `lib/widgets/event/event_card.dart`

### Mode Plein (`_buildFull`)

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │       Image (16:9)         │  │
│  │    (ou dégradé violet)     │  │
│  │              ┌──────────┐  │  │
│  │              │ NOUVEAU  │  │  │
│  │              └──────────┘  │  │
│  └────────────────────────────┘  │
│                                  │
│  Titre événement      ┌────────┐ │
│  (max 2 lignes)       │ Numéro-│ │
│                       │ té     │ │
│                       └────────┘ │
│  📅 18 Juin 2026 • 20:00        │
│  📍 Be-setroka                   │
│                                  │
│  À partir de 25 000 Ar          │
└──────────────────────────────────┘
```

**Champs affichés :**
| Champ | Source | Format |
|---|---|---|
| Image | `event.image` | Affichée via `eventImageWidget` ; fond violet dégradé si null |
| Badge NOUVEAU | `event.isNew == true` | Gradient orange/rose, arrondi |
| Titre | `event.titre` | Bold 16px, max 2 lignes, ellipsis |
| Badge placement | `event.typeAgencement` | Icône + label :
| | `UNIQUEMENT_ASSIS` / `NUMEROTE` → `event_seat` + `"Numéroté"`
| | `ASSIS_DEBOUT` / `MIXTE` → `swap_horiz` + `"Mixte"`
| | `DEBOUT_AVEC_LIMITE` / `DEBOUT_SANS_LIMITE` / `LIBRE` → `people` + `"Libre"`
| Date | `event.dateEvenement` + `event.heureEvenement` | `"d MMMM yyyy • HH:mm"` (ex: "18 Juin 2026 • 20:00") |
| Lieu | `event.lieuNom` | Avec icône `location_on` ; affiche `"Non spécifié"` si null |
| Prix | `event.prixMin ?? event.prix` | `"À partir de X Ar"` ou `"Indisponible"` si null/0 |

### Mode Compact (`_buildCompact`)

```
┌─────────────────────────────────┐
│ ┌──────┐  Titre événement      │
│ │Image │  Be-setroka            │
│ │100x10│  18 Juin 2026          │
│ │ 0    │                  [ > ] │
│ │NOUVEAU│                      │
│ └──────┘                       │
└─────────────────────────────────┘
```

Utilisé pour les sections horizontales (événements populaires, etc.).

---

## 2. Page Détail Événement (HomeDetailPage)

**Fichier :** `lib/pages/client/home_detail_page.dart`

### Structure complète

```
┌──────────────────────────────────┐
│         ═══ HERO BANNER ═══      │
│  ┌────────────────────────────┐  │
│  │     Image pleine largeur   │  │
│  │     (260px, ou fond        │  │
│  │      violet dégradé)       │  │
│  │                            │  │
│  │     ┌──────────────────┐   │  │
│  │     │ UNIQUEMENT ASSIS │   │  │ ← badge typeAgencement (accent)
│  │     └──────────────────┘   │  │
│  │     Concert Assis Numéroté  │  │ ← titre (blanc, 26px)
│  └────────────────────────────┘  │
│                                  │
│  ═══ BANNIÈRE ANNULATION ═══     │ ← si statut == 'ANNULE'
│  ┌────────────────────────────┐  │    + motifAnnulation
│  │ ⚠ Événement annulé        │  │    (fond rouge, flou)
│  │   Raison du motif...       │  │
│  └────────────────────────────┘  │
│                                  │
│  ═══ INFOS LOGISTIQUES ═══       │
│  ┌──────────┐  ┌──────────┐     │
│  │  📅      │  │  🕐      │     │
│  │  Date    │  │  Heure   │     │
│  │  20/12/26│  │  20:00   │     │
│  └──────────┘  └──────────┘     │
│                                  │
│  ═══ LIEU ═══                    │
│  ┌────────────────────────────┐  │
│  │ 📍 Be-setroka              │  │
│  │   ety, Fianarantsoa        │  │
│  └────────────────────────────┘  │
│                                  │
│  ═══ DESCRIPTION ═══             │
│  ┌────────────────────────────┐  │
│  │ Texte de description       │  │
│  │                            │  │
│  │ ● caractéristique : valeur │  │
│  │ ● type : en salle          │  │
│  └────────────────────────────┘  │
│                                  │
│  ═══ ZONES DEBOUT ═══            │ ← si standingZones non vide
│  ┌────────────────────────────┐  │    (DEBOUT_AVEC_LIMITE,
│  │ ♿ Fosse                   │  │     ASSIS_DEBOUT)
│  │   199/200 places           │  │
│  │           15 000 Ar        │  │
│  │  ████████░░░░░░░░░░░  1%  │  │ ← barre de progression
│  └────────────────────────────┘  │    (vert < 50%, orange < 80%,
│  ┌────────────────────────────┐  │     rouge ≥ 80%)
│  │ ♿ Balcon                  │  │
│  │   100/100 places           │  │
│  │           25 000 Ar        │  │
│  │  ████████████████████  0%  │  │
│  └────────────────────────────┘  │
│                                  │
│  ═══ ANNONCES ═══                 │ ← si annonces non vide
│  ┌────────────────────────────┐  │
│  │ Annonce 1                  │  │
│  └────────────────────────────┘  │
│                                  │
│  ═══ AVIS ═══                    │
│  ┌────────────────────────────┐  │
│  │ ⭐⭐⭐⭐☆                    │  │
│  │ Note : 4.2/5               │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │     📋 Réserver            │  │ ← footer fixe (bottom bar)
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## 3. Page Réservation (ReservationPage)

**Fichier :** `lib/pages/client/reservation_page.dart`

La page adapte son affichage selon `event.typeAgencement` :

```dart
bool get _isStandingOnly => type == 'DEBOUT_AVEC_LIMITE' || 'DEBOUT_SANS_LIMITE';
bool get _isMixed      => type == 'ASSIS_DEBOUT';
bool get _isSeated     => type == null || 'UNIQUEMENT_ASSIS' || 'TABLE_ASSIS';
```

### 3a. Mode Assis Numéroté (`UNIQUEMENT_ASSIS`)

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │       🎭 SCÈNE             │  │ ← indicateur de scène
│  └────────────────────────────┘  │
│                                  │
│  ┌─────┐ ┌─────┐ ┌─────┐       │
│  │ VIP │ │Stand│ │Loge │       │ ← blocs de types (sélectionnable)
│  │ 5pl │ │10pl │ │ 3pl │       │
│  │50kAr│ │25kAr│ │40kAr│       │
│  └─────┘ └─────┘ └─────┘       │
│                                  │
│  ● VIP (50 000 Ar)  ● Standard..│ ← légende couleurs
│                                  │
│  ┌────────────────────────────┐  │
│  │     Plan des places         │  │ ← SeatPicker widget
│  │  A1 A2 A3 A4 A5            │  │    (sélection individuelle)
│  │  B1 B2 B3 B4 B5 B6 B7 B8  │  │
│  │  B9 B10                    │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │   Total : 75 000 Ar        │  │ ← footer fixe
│  │         Réserver           │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 3b. Mode Libre Debout (`DEBOUT_AVEC_LIMITE`)

```
┌──────────────────────────────────┐
│  ┌────────────────────────────┐  │
│  │ ♿ Fosse                   │  │
│  │   199/300 restants         │  │ ← carte zone debout
│  │           10 000 Ar        │  │
│  │  ██████░░░░░░░░░░░░  33%  │  │ ← jauge de remplissage
│  │          [-] 0 [+]         │  │ ← sélecteur de quantité
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ ♿ Gradin                  │  │
│  │   199/200 restants         │  │
│  │           15 000 Ar        │  │
│  │  ████████████████████  1%  │  │
│  │          [-] 2 [+]         │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │   Total : 40 000 Ar        │  │
│  │         Réserver           │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 3c. Mode Mixte (`ASSIS_DEBOUT`)

```
┌──────────────────────────────────┐
│       ═══ PARTIE ASSISE ═══      │
│  ┌────────────────────────────┐  │
│  │       🎭 SCÈNE             │  │
│  └────────────────────────────┘  │
│  ┌─────┐ ┌─────┐                │
│  │Stand│ │ VIP │                │ ← blocs assis
│  │10pl │ │ 5pl │                │
│  │30kAr│ │50kAr│                │
│  └─────┘ └─────┘                │
│  ┌────────────────────────────┐  │
│  │    Plan des places assises  │  │
│  └────────────────────────────┘  │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │ ← Divider
│       ═══ ZONES DEBOUT ═══      │
│  ┌────────────────────────────┐  │
│  │ ♿ Fosse                   │  │
│  │   199/200 restants         │  │ ← zones debout avec quantités
│  │           15 000 Ar        │  │
│  │          [-] 1 [+]         │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  Total : 90 000 Ar         │  │
│  │  (1 assis + 1 debout)      │  │
│  │         Réserver           │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## 4. Carte Ticket (Liste — MyTicketsPage)

**Fichier :** `lib/pages/client/tickets_page.dart`

```
┌──────────────────────────────────┐
│  ×××××××××× IMAGE (140px) ××××× │ ← image événement
│  ×××××××××××××××××××××××××××××× │
│                                  │
│  Titre événement       ┌──────┐ │
│  (max 2 lignes)        │  VIP │ │ ← badge typePlace (couleur)
│                        └──────┘ │
│  📅 Lundi, Décembre 2026 • 20:00│
│                                  │
│  ┌────────────────────────────┐  │
│  │  🚪   │  📊  │  💺        │  │ ← si assis (zoneNom == null)
│  │ Salle │ Rang │ Siège      │  │    `meeting_room`, `view_column`,
│  │ Terras│  A   │   A1       │  │    `event_seat`
│  └────────────────────────────┘  │
│         ou                       │
│  ┌────────────────────────────┐  │
│  │  ♿                         │  │ ← si debout (zoneNom != null)
│  │ Zone                       │  │    `accessibility_new`
│  │ Fosse                      │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ ┌──────┐                   │  │
│  │ │ QR   │ Référence         │  │
│  │ │ CODE │ TCK-E31-A1        │  │ → chevron droit
│  │ └──────┘                   │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌─ SI statut expiré ──────────┐ │
│  │      ╔══════════╗          │ │ ← overlay semi-transparent
│  │      ║ EXPIRÉ   ║          │ │
│  │      ╚══════════╝          │ │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

**Couleurs du badge `typePlace` :**
| Type | Couleur |
|---|---|
| VIP | Violet `#9C27B0` |
| PREMIUM | Orange `#FF6F00` |
| ORCHESTRE | Violet foncé `#7B1FA2` |
| BALCON | Teal `#00897B` |
| LOGE | Indigo `#5C6BC0` |
| Standard (défaut) | Vert `AppColors.placeStandard` |

---

## 5. Page Détail Ticket (TicketPage)

**Fichier :** `lib/pages/client/ticket_page.dart`

```
┌──────────────────────────────────┐
│  ←  Mon Billet                   │ ← AppBar
│──────────────────────────────────│
│                                  │
│  ┌────────────────────────────┐  │
│  │      ✅ Valide             │  │ ← badge vert/rouge
│  │                            │  │
│  │     ┌──────────────┐      │  │
│  │     │              │      │  │
│  │     │   QR CODE    │      │  │ ← 200×200, base64
│  │     │              │      │  │
│  │     └──────────────┘      │  │
│  │                            │  │
│  │    [📥 Télécharger PDF]    │  │ ← bouton download
│  │────────────────────────────│  │ ← Divider
│  │  Événement    Concert...   │  │
│  │  Siège        A1           │  │ ← `displayPlace(placeNumero)`
│  │  Rang         A            │  │ ← si présent
│  │  Type         VIP          │  │ ← si présent
│  │  Zone         Fosse        │  │ ← si présent (ticket debout)
│  │  Prix         Ar 50000     │  │ ← si présent
│  │  Titulaire    anjc rajean  │  │
│  │────────────────────────────│  │ ← Divider
│  │  TCK-E31-A1                │  │ ← codeTicket en monospace
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## Résumé : Comportement par Type de Placement

| Type Backend | Mode UI | Carte Événement | Détail Événement | Réservation | Ticket |
|---|---|---|---|---|---|
| **UNIQUEMENT_ASSIS** | `NUMEROTE` | Badge "Numéroté" + icône `event_seat` | Badge "UNIQUEMENT ASSIS" ; pas de zones debout | Plan de salle avec blocs types + sièges | Salle + Rang + Siège |
| **ASSIS_DEBOUT** | `MIXTE` | Badge "Mixte" + icône `swap_horiz` | Badge "ASSIS DEBOUT" + zones debout avec jauge | Plan de salle + zones debout avec quantités | Selon le type : siège ou zone |
| **DEBOUT_AVEC_LIMITE** | `LIBRE` | Badge "Libre" + icône `people` | Badge "DEBOUT AVEC LIMITE" + zones debout avec jauge | Zones debout avec quantités (+/-) | Nom de la zone uniquement |
| **DEBOUT_SANS_LIMITE** | `LIBRE` | Badge "Libre" + icône `people` | Badge "DEBOUT SANS LIMITE" ; zones sans barre de progression | Zones debout sans limite de capacité | Nom de la zone uniquement |

## Fichiers Sources

| Fichier | Description | Lignes |
|---|---|---|
| `lib/widgets/event/event_card.dart` | Carte événement (pleine + compacte) | 220+ |
| `lib/pages/client/home_detail_page.dart` | Détail événement client | 731+ |
| `lib/pages/client/reservation_page.dart` | Sélection de tickets / réservation | 763+ |
| `lib/pages/client/tickets_page.dart` | Liste des tickets de l'utilisateur | 401+ |
| `lib/pages/client/ticket_page.dart` | Détail d'un ticket individuel | 239+ |
| `lib/core/assets/app_colors.dart` | Thème (light + dark), couleurs, constantes | 592 |
| `lib/core/services/app_config.dart` | Configuration app (langue, thème) | 61 |

## Notes d'Implémentation (HCI/IHM)

### Glassmorphism
Tous les badges "NOUVEAU", les cartes de zones debout, les overlays "EXPIRÉ", et la carte ticket utilisent `BackdropFilter` avec `ImageFilter.blur` pour l'effet verre dépoli :
- **sigmaX/Y: 20** — bannière annulation (fond rouge flou)
- **sigmaX/Y: 12** — badge NOUVEAU (mode plein)
- **sigmaX/Y: 8** — badge de placement, carte ticket
- **sigmaX/Y: 6** — zones debout, overlay expiré

### FOMO (Fear Of Missing Out)
Les barres de progression des zones debout changent de couleur selon le taux de remplissage :
- **< 50%** : Vert (`AppColors.secondary`)
- **50-80%** : Orange
- **≥ 80%** : Rouge (`AppColors.error`) + badge "PRESQUE COMPLET"
- Icône `trending_up` pour renforcer l'urgence

### Structure Information
- Regroupement logistique (Date/Heure/Lieu/Organisateur) en blocs distincts et scannables
- Section organizeur affichant le nom + badge typeAgencement
- Divider custom dans le layout mixte avec label "Zones debout" intégré
