

# Règles de Gestion — IHM Gestion d'Événements

## 1. Cycle de vie d'un événement

| Statut | Description | Transition |
| --- | --- | --- |
| `planifie` | Événement créé, en attente de validation ou de démarrage | → `valide` (par l'Admin) ou `annule` |
| `valide` | Approuvé par l'administrateur, visible par les clients | → `en_cours` (auto le jour J à 06:00) |
| `en_cours` | Événement actif, en cours de déroulement | → `termine` (automatique après la date de fin) |
| `termine` | Événement passé, archivé | Statut final irréversible |
| `annule` | Annulé par l'organisateur ou l'admin (avec motif obligatoire) | Depuis `planifie` ou `valide` ou `en_cours` |
| `suspendu` | Masqué temporairement aux clients en cas de litige admin | Depuis n'importe quel statut sauf `termine` |

> **Règle :** Un script planifié exécuté toutes les heures bascule automatiquement en `termine` tout événement dont `dateFinEvenement < Instant.now()`.

---

## 2. Utilisateurs, rôles et sécurité

### 2.1 Hiérarchie des rôles et restrictions

* L'application restreint la gestion dynamique à deux profils métiers principaux : `CLIENT` et `ORGANISATEUR`.
* Le rôle `ADMINISTRATEUR` possède une visibilité totale sur l'écosystème (modération globale, statistiques transverses, CRUD de la structure physique).
* **Sécurité Critique :** Dans l'interface de modification des utilisateurs, **l'option de rôle `ADMINISTRATEUR` est strictement retirée de la liste sélectionnable**. Un utilisateur ou organisateur ne peut en aucun cas s'attribuer ou attribuer des privilèges Admin.

### 2.2 Processus de connexion et sécurité technique

* Un nouvel utilisateur possède l'attribut `premiere_connexion = true`. Il est immédiatement redirigé vers un écran obligatoire lui imposant de modifier son email de contact et son mot de passe initial avant toute autre action.
* L'authentification est sécurisée via Spring Security avec des jetons **JWT** signés.
* Les mots de passe sont obligatoirement hachés à l'aide de l'algorithme **BCrypt**.
* Côté frontend mobile (Flutter), le token JWT est stocké de manière sécurisée dans les `SharedPreferences` (ou `FlutterSecureStorage`). Les endpoints d'API sont protégés côté backend par les annotations `@PreAuthorize("hasRole('ORGANISATEUR')")` et `@PreAuthorize("hasRole('ADMINISTRATEUR')")`.

---

## 3. Lieux, Salles, Places et Réservations

### 3.1 Structure physique et Identifiant Unique Combiné

* La hiérarchie physique descendante est stricte : **Lieu ➔ Salle ➔ Place**.
* Une place (`Place`) appartient à une `Salle`, qui est rattachée à un `Lieu`.
* **Règle Anti-Doublon :** Pour éviter définitivement l'erreur critique de collision en base de données (ex: `La place A-1 existe déjà`), la clé primaire ou l'identifiant unique d'une place est une chaîne combinée générée séquentiellement selon le pattern suivant :

$$\text{ID\_COMBINÉ} = \text{[Nom du Lieu]} - \text{[Nom de la Salle]} - \text{[Code du Rang]} - \text{[Numéro de Place]}$$


* Le formulaire d'ajout d'une salle exige la complétion obligatoire des champs : `Numéro`, `Nom`, `Lien`, `Rang`, `Type` (type de salle), et `Lieu Parent`.

### 3.2 Tarification événementielle et Surcharges

* La table physique d'origine `PLACE` n'est **jamais modifiée** lors de la création d'un événement. L'administrateur système ne configure que l'ossature physique.
* C'est l'**Organisateur** qui détient la logique métier tarifaire lors de l'ajout de son événement via la table pivot `EVENEMENT_PLACE_CONFIG`. Deux modes d'attribution sont disponibles :
* **Mode Rangée :** Sélection d'une rangée complète (ex: Rangée B) pour lui appliquer un Type de place (VIP, Standard, etc.) et un prix unitaire de ticket en un seul clic.
* **Mode Individuel :** Sélection unitaire d'une place sur une grille interactive. Ce mode surcharge la place choisie et écrase la règle par défaut de la rangée (ex: modifier uniquement la place `B-1` en *Ultra-VIP*).


* Résolution de la valeur effective du ticket : `typePlaceOverride` (Spécifique à la place dans l'événement) ➔ `typePlaceRangee` (Spécifique à la rangée de l'événement) ➔ `Place.typePlace` (Valeur de base de la structure admin) ➔ `'Standard'`.

### 3.3 Processus de Réservation

* Une réservation (`Reservation`) est initialisée dès qu'un client ajoute des places à son panier.
* Un ticket (`Ticket`) est généré à la validation finale et lié à la réservation via l'entité relationnelle `CorrespondA`.
* Le ticket est lié de manière unique à sa place et à son événement via la table `Concerner`.
* **Contrainte d'unicité absolue :** La clé composite de la table `Concerner` (`idEvenement` + `codeTicket` + `idPlaceCombine`) empêche qu'une place physique soit réservée plus d'une fois pour un même événement.

### 3.4 États d'une Place

* `DISPONIBLE` : Siège libre, ouvert à l'achat.
* `EN_ATTENTE` : Siège verrouillé temporairement dans le panier d'un utilisateur (expiration du panier après 10 minutes).
* `RESERVEE` : Siège payé avec succès, lié à un ticket valide.
* `INDISPONIBLE` : Siège bloqué manuellement par l'organisateur ou l'admin (raison technique, distanciation, ou sécurité).

---

## 4. Flux des Paiements et Règlements

### 4.1 Passerelle et Simulations de Tests

L'application intègre des modes de transactions réels et des modes de débogage pour tester la résilience du système :

* `CARTE`, `MOBILE_MONEY`, `PAYPAL` : Déclenchent les workflows de traitement réels.
* `SIMULATION_FONDS_INSUFFISANTS` : Simule un rejet bancaire et lève l'exception `FondsInsuffisantsException` (Transaction avortée, place libérée).
* `SIMULATION_ECHEC` : Simule une coupure réseau ou une erreur interne après la tentative d'achat. La réservation n'est pas confirmée.

### 4.2 Workflow d'Achat Unifié et Concurrence

Toute tentative d'achat frappe un endpoint unique : `POST /api/achat` transmettant un objet `PurchaseRequest`.

1. **Verrouillage et Vérification Concurrence :** Le système vérifie l'état de chaque place sélectionnée sous un verrou transactionnel (Pessimistic Lock). Si une place est déjà `RESERVEE` ou `EN_ATTENTE` par un tiers, le processus est stoppé immédiatement et renvoie une exception claire au client.
2. **Création des Objets :** Initialisation des entités `Ticket` et `Reservation`.
3. **Paiement et Gestion des Exceptions :** Exécution du débit. En cas d'erreur (*Montant incohérent*, *Fonds insuffisants*), un rollback complet de la transaction est opéré en base de données.
4. **Validation :** Si le paiement réussit, le statut des places bascule immédiatement à `RESERVEE`.

---

## 5. Contraintes d'Intégrité et Diagnostics

### 5.1 Détection automatique des incohérences

Le système intègre un module de vérification de l'intégrité des données capable de lever des alertes ou de réparer les états suivants :

* Événements dont la date est échue mais n'ayant pas le statut `termine`.
* Tickets d'achats orphelins (sans référence de réservation parente).
* Places marquées au statut `RESERVEE` sans aucune ligne d'association correspondante dans la table `Concerner`.
* Réservations validées ne disposant d'aucune preuve ou journal de paiement associé.
* Événements validés configurés dans une salle ne contenant physiquement aucune place générée.

### 5.2 Formats de Références Standards

* `codeTicket` : Index unique mondialisé structuré comme suit : `TKT-{eventId}-{idPlaceCombine}-{timestamp}`.
* `codeUtilisateur` : Chaîne UUID v4 générée exclusivement côté serveur à la création du compte.

---

## 6. Règles d'Affichage et Expérience Utilisateur (IHM)

### 6.1 Gestion des États Vides (Empty States)

**Règle d'or ergonomique :** Pour toutes les listes ou tables de l'application (Lieux, Salles, Places, Événements), si la source de données ne renvoie aucun enregistrement, l'écran ne doit jamais afficher une page blanche ou un tableau vide.

* *IHM exigée :* Affichage d'une illustration ou d'un message textuel explicite (ex: *"Aucune salle enregistrée pour le moment"*) accompagné de manière systématique d'un bouton d'action direct (ex: `[ + Ajouter une Salle ]`).

### 6.2 Organisation Spécifique des Panels IHM

#### A. Panel Administrateur : Navigation en Cascade et Compteurs

L'administration de la structure respecte le principe de divulgation progressive à travers deux menus distincts :

1. **Menu "Lieux" :** Affiche la liste des complexes. Chaque ligne intègre un **Compteur dynamique du nombre de salles rattachées**. Le bouton **'Info'** ouvre une pop-up modale listant brièvement ses salles avec un bouton d'accès rapide.
2. **Menu "Salles / Places" (Fusionné) :**
* *Zone Supérieure :* Intègre une barre de recherche en temps réel et liste les salles. Chaque ligne affiche un badge avec le **Nombre exact de places générées**.
* *Zone Inférieure (Dynamique) :* S'active au clic sur **'Gérer les places'**. Elle affiche le module de génération en masse (par Rang et par Plage numérique numérique) ainsi qu'une grille de badges individuels disposant d'une icône de suppression rapide (`x`) et de modification unitaire.



#### B. Panel Admin : Modération des Événements

* Un sous-menu regroupe tous les événements de la plateforme.
* Le bouton **'Info'** dédié ouvre une vue d'ensemble centralisant : *Infos de base, Logistique (Lieu, Salle, Heure début/fin)* et *Jauge de remplissage*.
* Ce panneau propose à l'admin les actions exclusives de modération : `[Valider / Approuver]`, `[Suspendre / Masquer]`, et `[Annuler définitivement]` (avec saisie de motif obligatoire).

#### C. Panel Organisateur : Dashboard & Tarification

* **Dashboard dédié :** Présentation graphique et analytique affichant le *Chiffre d'affaires global*, le *Taux de remplissage des salles*, un *Graphique temporel de l'évolution des ventes journalières* et le *Top 5 des événements les plus rentables*.
* **Formulaire Événement :** Permet à l'organisateur de lier un Lieu et une Salle, puis d'accéder aux interfaces d'assignation tarifaire (Mode Rangée et Grille interactive pour sélection individuelle de type et de prix).

#### D. Interface Client : Menu "Mes Tickets" & QR Code

* Affichage des billets acquis sous forme de cartes claires.
* Chaque carte intègre un **QR Code unique** généré dynamiquement. Ce QR Code chiffre les données d'authentification (`idTicket`, `idClient`, `idEvenement`, `idPlaceCombine`).
* Mentions textuelles obligatoires affichées : *Nom de l'événement, Nom complet du client, Lieu, Salle, Numéro de Rang, Numéro de Place, Date et Heure précise*.
* **Bouton d'export :** Permet le téléchargement instantané du ticket au format **PDF** intégrant le QR Code pour un accès hors-ligne.

### 6.3 Code Couleur de la Grille des Places

Les places s'affichent dynamiquement selon une charte graphique stricte basée sur leur type configuré pour l'événement :

* **Standard :** Gris (`#9E9E9E`)
* **VIP :** Violet (`#9C27B0`)
* **Premium :** Orange (`#FF9800`)
* **Ultra-VIP :** Rose (`#E91E63`)

---

## 7. Plan de Validation et Tests Obligatoires

Avant toute livraison ou arrêt de tâche, l'agent IA doit obligatoirement écrire et valider la réussite des tests d'intégration suivants :

1. **Test de non-régression d'API (Dashboard) :** Validation que l'endpoint du Dashboard renvoie un statut `HTTP 200 OK` avec un payload JSON valide (fin de l'erreur 500).
2. **Test de Concurrence de Génération :** Validation de l'intégrité de la contrainte d'identifiant combiné unique ; vérification qu'une double tentative d'insertion de places identiques rejette proprement le doublon sans corrompre la table.
3. **Test IHM (Flutter UI) :** Validation structurelle que le composant `TabBar` s'exécute au sein d'un arbre de widgets pourvu d'un `TabController` adéquat (fin du crash de rendu).