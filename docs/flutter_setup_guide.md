# Flutter Installation Guide (Windows)

Folge diesen Schritten, um AdvisorMate lokal auf deinem Rechner zum Laufen zu bringen.

## Schritt 1: Flutter SDK herunterladen
1. Gehe auf die offizielle [Flutter Download Seite](https://docs.flutter.dev/get-started/install/windows/mobile?tab=download).
2. Lade das neueste **Windows Flutter SDK** (zip) herunter.
3. Erstelle einen Ordner ohne Sonderzeichen/Leerzeichen im Pfad, z.B. `C:\src\`.
4. Entpacke die Zip-Datei dorthin, sodass du den Ordner `C:\src\flutter` hast.

## Schritt 2: PATH Umgebungsvariable setzen
Damit Windows den Befehl `flutter` überall erkennt:
1. Drücke die Windows-Taste und tippe **"Umgebungsvariablen"** -> Wähle "Systemumgebungsvariablen bearbeiten".
2. Klicke auf den Button **"Umgebungsvariablen..."**.
3. Suche unter "Benutzervariablen" den Eintrag **Path** und klicke auf "Bearbeiten".
4. Klicke auf "Neu" und füge den Pfad zum `bin`-Ordner von Flutter hinzu: `C:\src\flutter\bin`.
5. Bestätige alles mit OK und starte deine PowerShell/Terminal neu.

## Schritt 3: Flutter Doctor ausführen
Prüfe im Terminal, ob alles bereit ist:
```powershell
flutter doctor
```
> [!NOTE]
> Wenn Chrome installiert ist, kannst du die App sofort im Web testen. Für Android/Windows Desktop müssten noch Android Studio bzw. Visual Studio installiert werden (die Details zeigt dir `flutter doctor`).

## Schritt 4: VS Code vorbereiten (Empfohlen)
1. Installiere [VS Code](https://code.visualstudio.com/).
2. Gehe zu den Extensions (Strg+Umschalt+X).
3. Suche und installiere die **"Flutter"** Extension (von Dart Code).

## Schritt 5: App starten
1. Öffne den Projektordner `fin-app-coolify` in VS Code.
2. Öffne ein Terminal in VS Code (Strg+ö).
3. Führe aus:
   ```powershell
   flutter pub get
   flutter run -d chrome
   ```

---

## Probleme?
Falls `flutter doctor` Fehler anzeigt, kopiere sie einfach hier in den Chat, und ich helfe dir beim Fixen!
