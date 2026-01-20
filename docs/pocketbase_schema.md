# AdvisorMate - PocketBase Schema

Um die App mit PocketBase zu nutzen, erstelle die folgende Collection `clients`.

## Collection: `clients`

Diese Collection speichert alle Kundeninformationen. Sensible Felder werden von der App verschlüsselt, bevor sie übertragen werden.

### Schema (JSON)

Du kannst dieses Schema direkt in PocketBase importieren:

```json
{
  "name": "clients",
  "type": "base",
  "schema": [
    {
      "name": "firstName",
      "type": "text",
      "required": true,
      "options": { "min": 2, "max": 100 }
    },
    {
      "name": "lastName",
      "type": "text",
      "required": true,
      "options": { "min": 2, "max": 255 }
    },
    {
      "name": "email",
      "type": "email",
      "required": true
    },
    {
      "name": "dateOfBirth",
      "type": "date",
      "required": true
    },
    {
      "name": "financialBalance",
      "type": "json",
      "required": false,
      "system": false
    },
    {
      "name": "liquidity",
      "type": "json",
      "required": false
    },
    {
      "name": "riskProfile",
      "type": "number",
      "required": true,
      "options": { "min": 1, "max": 10 }
    },
    {
      "name": "investmentGoal",
      "type": "select",
      "options": {
        "values": ["retirement", "real_estate", "wealth_preservation", "wealth_building", "income_generation"]
      }
    },
    {
      "name": "experienceLevel",
      "type": "select",
      "options": {
        "values": ["none", "basic", "intermediate", "experienced", "expert"]
      }
    },
    {
      "name": "esgPreferences",
      "type": "json",
      "required": false
    },
    {
      "name": "advisorId",
      "type": "relation",
      "options": {
        "collectionId": "_pb_users_auth_",
        "cascadeDelete": false,
        "maxSelect": 1,
        "displayFields": ["username"]
      }
    }
  ],
  "listRule": "@request.auth.id = advisorId",
  "viewRule": "@request.auth.id = advisorId",
  "createRule": "@request.auth.id != ''",
  "updateRule": "@request.auth.id = advisorId",
  "deleteRule": "@request.auth.id = advisorId"
}
```

### DSGVO Hinweis

Die Felder `firstName`, `lastName`, `email`, `financialBalance` und `liquidity` werden von der Flutter-App mittels AES-256 verschlüsselt. In PocketBase sind diese Daten als verschlüsselte Base64-Strings sichtbar.

## API Integration

Um PocketBase in der App zu aktivieren, ändere in `lib/presentation/providers/providers.dart`:

```dart
final databaseServiceProvider = Provider<ClientDatabaseService>((ref) {
  return PocketBaseDatabaseService(baseUrl: ApiConstants.pocketBaseUrl);
});
```
