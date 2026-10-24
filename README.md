Cooperating Screen

> Open-Source Cross-Device Screen Sharing – Flutter App + WebRTC + Node.js Signaling Server. Docker-ready.

Entstanden am 15.01. – first commit `411edc7` mit nur 3 Dateien: `LICENSE` (damals noch MIT 2026 Daniel), `Readme.md` und `detailed_plan.md`. +6.074 Zeilen.

### Entstehung

Die Idee kam vor etlichen Jahren im Sommerurlaub auf der Insel Nordee mit meiner Schwester. Sie wollte Marketing Head werden und ich Dev/Infra/Implementierer/Sklave/etc pp... Damals haben wir alle noch GPT 3.5 mit unlimited usage genutzt – crazy, heutzutage hat OpenAI ein Limit von 512 MB Speicher für Bilder/Dateien xD.

Ich hatte einen Chat dazu, finde ihn nicht mehr – habe auch eine lokale Kopie die ich nicht finde XD. Aber ein "Gemini Gem" hat all meine ChatGPT Chats die ich nicht exportieren kann – DANKE GOOGLE – deswegen konnte ich Gemini fragen.

Als OpenAI Codex gut genug und free wurde (zu geizig für $20 XD) habe ich die Idee einfach mal in Codex eingegeben und geschaut was rauskommt. Dann ein Repo draus gemacht. Kurzzeitig hieß es mal "LinkScreen – Cross-Device Sharing" als ich alle Repos umbenennen wollte XD – habe es aber schnell zurück umbenannt weil LinkScreen nach AI-generated Name klingt.

**Was es wirklich ist:** Kein stumpfes Teams/Zoom Screen-Sharing, sondern echtes Co-Working: Multi-User Control, App-Level Sharing statt ganzer Desktop, Shared Workspace. Technisch: Flutter für App, WebRTC für fast latenzfreies P2P, Node.js Signaling.

### Was drin ist

- Flutter App für Device Setup, Pairing, WebRTC Session Management
- Node.js Signaling Server für WebSocket Peer Signaling (Docker-ready für VPS)
- Leichter Web Client im Browser für Rooms
- Supabase-kompatible Backend Punkte

### Features

- Device Registrierung & Pairing Flow
- WebRTC Offer/Answer + ICE Candidate Relay
- Health & Stats Endpoints für Signaling
- Docker Deployment
- Supabase Integration

### Installation

**Voraussetzungen:**
- Flutter SDK 3.0+
- Node.js 18+
- npm
- Docker (optional)

```bash
git clone <repo-url>
cd cooperating-screen
```

### Nutzung

**Flutter App:**
```bash
cd cosc
flutter pub get
flutter run
```

**Signaling Server:**
```bash
cd signaling_server
npm install
npm run dev
```
Default: `ws://localhost:3000`

### Development Setup

1. Templates kopieren:
   - Root: `.env.example`
   - Signaling: `signaling_server/.env.example`
2. Config anlegen:
```bash
cp signaling_server/.env.example signaling_server/.env
```
3. Supabase Werte eintragen.

### Konfiguration

Wichtigste ENV Vars für Signaling Server:

- `PORT` (default: `3000`)
- `NODE_ENV` (`development` / `production`)
- `LOG_LEVEL`
- `SUPABASE_URL`
- `SUPABASE_KEY`

Flutter Config in `cosc/lib/main.dart` – für Prod durch sichere Runtime Config ersetzen.

### Build / Run

**Docker Compose (Backend + Web UI):**
```bash
docker-compose up --build
```
- Signaling: `ws://localhost:3000`
- Web UI: `http://localhost:8080`

**Prod Signaling:**
```bash
cd signaling_server
npm install
npm start
```

**Flutter Release:**
```bash
cd cosc
flutter build apk
# oder
flutter build ios
```

### Troubleshooting

- **WebSocket Probleme**: Port 3000 frei? URL korrekt? Firewall?
- **Flutter Dependencies**: `flutter clean` + `flutter pub get`
- **Server startet nicht**: `.env` checken, `npm install` nochmal, Logs via `npm run dev`

### Warum ich es heute auf Eis lege

Ist ein geiles Konzept für Pair Programming / Remote Support für meine geplante Hosting-Firma, aber aktuell Fokus auf `infra-pilot` und FISI 2. Lehrjahr. Als One-Man-Show aus Codex generiert – perfekt um zu zeigen dass ich auch Flutter + WebRTC kann, aber kein aktives Produkt.

### Lizenz

Ab 24.10.2026 MIT – siehe [LICENSE](LICENSE). Ältere Stände bleiben GPLv3.
