# IHM — monorepo multi-app

## Architecture

```
IHM/
├── backend/     — Spring Boot 3.2.4 (Java 17 pom / JDK 21 Dockerfile)
│   └── com.ihm.{api,model,service,repository,dto}
├── front/       — React 18 + Vite 6, served by Nginx in Docker
├── mobile/      — Flutter app "ontik" (Riverpod, Dio, go_router)
└── docker-compose.yml — PostgreSQL 16 + backend + frontend + Prometheus/Grafana stack
```

- All backend controllers use `@RequestMapping("/api/...")`. The Nginx `proxy_pass` preserves `/api` prefix.
- Hibernate `ddl-auto=update` creates/updates tables but **cannot add NOT NULL to existing columns**. You must `ALTER TABLE ... ALTER COLUMN SET NOT NULL` manually for migrations on production-like DBs.
- The `premiere_connexion` boolean on `Utilisateur` entity is persisted as `premiere_connexion` in PostgreSQL. The Jackson JSON key is `firstLogin` (derived from getter `isFirstLogin()`).

### Data model (key entities)

```
SALLE ──1:N──> PLACE ──N:M (via CONCERNER)── TICKET ──N:M (via CORRESPOND_A)── RESERVATION
```
- `Place`: `numeroPlace` (String PK, ex "A1"), `rang` (row), `typePlace` (category), `prix`, `statut` (enum: DISPONIBLE, RESERVEE, INDISPONIBLE, EN_ATTENTE)
- `Concerner` = lien ternaire Evenement + Ticket + Place; une place est "réservée" si un Concerner existe
- Places créées **individuellement** (POST /api/places) ou par **génération batch** (POST /api/places/batch)
- Prix des places : soit sur `Place.prix` (prix fixe par siege), soit via `Ticket.prix` (prix par ticket lié a un Concerner)
- Réservation flow: ① POST /api/tickets (1 par siege) → ② POST /api/reservations → ③ POST /api/paiements

## Commands

### Backend (Java)
```sh
cd backend
./mvnw clean package -DskipTests    # build JAR
./mvnw spring-boot:run              # dev server on :8080
./mvnw test                         # run tests
```
- Local DB: `localhost:5432`, database `gestion`, user `postgres` / `rajean`
- Docker DB: service `postgres`, port `5433` externally mapped
- Swagger: `http://localhost:8080/swagger-ui.html`

### Frontend (React)
```sh
cd front
npm install          # install deps
npm run dev          # dev server on :5173 (proxies /api → backend:8080)
npm run build        # output to dist/
```
- Docker build output: `dist/` (Vite, not CRA)
- Nginx in container proxies `/api` → `http://backend:8080`
- HTTPS via self-signed `nginx.crt`/`nginx.key` in repo root

### Mobile (Flutter)
```sh
cd mobile/ontik
flutter pub get      # install deps (mobile_scanner, fl_chart require this)
flutter run          # run on connected device/emulator
flutter build apk    # Android release
```
- API base URL: `http://localhost:8080/api` (hardcoded in `core/api_client.dart:6` — change for production)
- State management: Riverpod `StateNotifierProvider` pattern
- Routing: go_router with role-based redirect via `refreshListenable` (`AuthRefreshNotifier`)
- Auth: JWT stored in SharedPreferences, injected via Dio interceptor

### Docker (full stack)
```sh
docker compose down && docker compose build --no-cache && docker compose up -d
```
- Frontend: `http://localhost:3001` (HTTP → HTTPS redirect to port 443)
- Backend: `http://localhost:8080`
- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`
- PostgreSQL: `localhost:5433`

## Business rules

- Three roles: `CLIENT`, `ORGANISATEUR`, `ADMINISTRATEUR` (Java enum, persisted as string)
- New users get `premiere_connexion = true`; forced password+email change on first login
- Login response includes `firstLogin` boolean flag; Flutter redirects to `/first-login`
- Seat pricing is category-based (`typePlace` on `SeatingPlace` model)
- Ticket validation: `POST /api/tickets/validate` (used by Flutter QR scanner)
- Disponibilité des places : calcul dynamique via `GET /api/evenements/{id}/places/available`
- Réservation flow complet (backend) : tickets → réservation → paiement → PDF ticket
- PDF ticket généré avec QR code (ZXing), contient référence, client, événement, siege, prix

## Quirks

- `spring.jpa.open-in-view=false` — LazyInitializationException possible; use `@Transactional` or fetch joins
- Java 17 source compat but Docker builds with JDK 21 (`eclipse-temurin:21-jdk`)
- No dedicated `.gitignore` at workspace root; each subproject has its own
- `chat.json` is a log file, not config — safe to ignore
- `db.json` = schéma DB de référence, pas un fichier de seed
- Frontend: pas de librairie UI, `fetch()` vanilla, pas de react-router
- Flutter bugs connus: `idReservation` hardcodé à 0 dans `/payment/0`; `codeTicket` mappé sur `numeroPlace` dans `ReservationView`
