# Plan: Reformater les références de places et tickets

## 1. Backend — `PlaceService.java` ligne 33-37
**Ancien** : `{lieuCode}-{salleNumero}-{rang}-{seatNum}` → `L001-L001_TERRASSE-A-1`  
**Nouveau** : `{salleNumero}-{rang}{seatNum}` → `L001_TERRASSE-A1`

```java
// Remplacer buildCombinedKey() par :
private String buildCombinedKey(Salle salle, String rang, String seatNumber) {
    return salle.getNumeroSalle() + "-" + rang + seatNumber;
}
```

## 2. Backend — `EvenementService.java` lignes 248-259
**Adapter l'extraction du rang pour le nouveau format à 2 parties** :

```java
// Remplacer les lignes 249-260 par :
String rang = place.getRangePlace();
if (rang == null || "?".equals(rang) || rang.isBlank()) {
    String np = place.getNumeroPlace();
    String[] parts = np.split("-");
    if (parts.length >= 2) {
        String seatCode = parts[parts.length - 1];
        rang = seatCode.replaceAll("\\d+$", "");
    } else {
        String derived = np.replaceAll("\\d.*$", "");
        if (!derived.isEmpty()) rang = derived;
    }
}
```

## 3. Backend — Compiler
```bash
cd /home/rajean/proIHM/IHM/backend
mvn clean package -DskipTests -q
```

## 4. Migration SQL des données existantes
```sql
-- Mettre à jour place.numero_place
UPDATE place 
SET numero_place = CONCAT(
    SPLIT_PART(numero_place, '-', 2), '-',
    SPLIT_PART(numero_place, '-', 3),
    SPLIT_PART(numero_place, '-', 4)
)
WHERE numero_place LIKE '%-%-%-%';

-- Mettre à jour evenement_place_config
UPDATE evenement_place_config 
SET numero_place = CONCAT(
    SPLIT_PART(numero_place, '-', 2), '-',
    SPLIT_PART(numero_place, '-', 3),
    SPLIT_PART(numero_place, '-', 4)
)
WHERE numero_place LIKE '%-%-%-%';

-- Mettre à jour concerner
UPDATE concerner 
SET numero_place = CONCAT(
    SPLIT_PART(numero_place, '-', 2), '-',
    SPLIT_PART(numero_place, '-', 3),
    SPLIT_PART(numero_place, '-', 4)
)
WHERE numero_place LIKE '%-%-%-%';
```

## 5. Flutter — `payment_page.dart` ligne 91
**Nouveau codeTicket** : `TKT{eventId}{MMddHH}{seq3}`

```dart
// Remplacer ligne 91 par :
final now = DateTime.now();
final dateCompact = '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}';
final seq = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
codeTicket: 'TKT${widget.eventId}$dateCompact$seq',
```

## 6. Flutter — Helper d'affichage `displayPlace`
Créer une fonction utilitaire, par exemple dans `lib/core/utils/place_utils.dart` :

```dart
String displayPlace(String? numeroPlace) {
  if (numeroPlace == null) return '—';
  final parts = numeroPlace.split('-');
  if (parts.length >= 2) return parts.last;
  return numeroPlace;
}
```

## 7. Flutter — Remplacer tous les `numeroPlace` bruts par `displayPlace()`
Rechercher tous les `p.numeroPlace`, `t.numeroPlace`, `seat.numeroPlace` dans les widgets et les envelopper avec `displayPlace()`.

## 8. Flutter — `seat_picker.dart` ligne 126
Remplacer le regex incorrect :
```dart
// Au lieu de : seat.numeroPlace.replaceAll(RegExp(r'^[A-Z]*'), '')
// Utiliser :
final parts = seat.numeroPlace.split('-');
final seatCode = parts.isNotEmpty ? parts.last : seat.numeroPlace;
// ... dans le Text
Text(seatCode.replaceAll(RegExp(r'^[A-Z]*'), '')),
```

## 9. Flutter — `mixed.dart` ligne 303, `numbered.dart` ligne 254, `pricing_page.dart` ligne 585
Remplacer `replaceAll(rang, '')` par extraction via split :
```dart
final parts = p.numeroPlace.split('-');
final seatNum = parts.isNotEmpty ? parts.last.replaceAll(RegExp(r'^[A-Z]*'), '') : p.numeroPlace;
```

## 10. React — `BookingFlow.jsx` ligne 164
```jsx
const now = new Date();
const dateCompact = `${String(now.getMonth()+1).padStart(2,'0')}${String(now.getDate()).padStart(2,'0')}${String(now.getHours()).padStart(2,'0')}`;
const seq = String(Date.now() % 1000).padStart(3, '0');
const codeTicket = `TKT${eventId}${dateCompact}${seq}`;
```

## 11. React — `SeatMap.jsx` lignes 40-41, 144
Remplacer les regex de stripping :
```jsx
// Ligne 40-41 : sorting
const seatNum = parseInt(seat.numeroPlace.split('-').pop().replace(/[A-Za-z]/g, '')) || 0

// Ligne 144 : display  
{seat.numeroPlace.split('-').pop().replace(/[A-Za-z]/g, '')}
```

## 12. React — `SeatMap.jsx` ligne 76
Même changement que BookingFlow.jsx pour le codeTicket.

## 13. Redémarrer le backend + test
```bash
kill $(lsof -t -i:8081) 2>/dev/null
nohup java -jar backend/target/gestion-evenements-1.0.0.jar > /tmp/backend.log 2>&1 &
sleep 30
# Tester création d'une place
curl -s -X POST http://localhost:8081/api/places \
  -H "Content-Type: application/json" \
  -d '{"numeroPlace":"A1","numeroSalle":"L001_RESTO"}' 
# Vérifier que numeroPlace = L001_RESTO-A1
```
