# Lizenz-Audit: mögliche Umstellung auf MIT (Stand: 2026-10-24)

> Technische Bestandsaufnahme, keine Rechtsberatung.
> Update 24.10.2026: Allein-Autorschaft verifiziert (24 Commits, alle Refs),
> daher auf Wunsch des Inhabers auf MIT umgestellt (dieses Dok. Abschnitt 5
> ist damit überholt); niemand sonst wurde kontaktiert.

## 1. Aktueller Lizenzstatus (Beleglage)

- `LICENSE` = **GPL-3.0** (voller GPLv3-Text, Commit `beed10b`, 2026-04-16).
  Vorher: `411edc7` (2026-01-15) enthielt eine MIT-Lizenz („Copyright (c) 2026 Daniel“).
  Die Umstellung MIT → GPL erfolgte durch denselben GitHub-Account (`DaaanielTV`).
- `signaling_server/package.json`: `"license": "GPL-3.0-only"` — konsistent mit `LICENSE`.
- `cosc/pubspec.yaml`: keine `license`-Angabe (`publish_to: 'none'`).
- Kein `NOTICE`, `COPYING`, `CLA.md`, kein DCO/CLA-Hinweis in `CONTRIBUTING.md`
  oder `CODE_OF_CONDUCT.md`. Keine SPDX-Header in den geprüften Quellen.
  Keine Git-Submodule, keine Lockfiles (`package-lock.json`, `pubspec.lock` fehlen),
  keine mitgelieferten `cosc/assets/` (im `pubspec.yaml` referenziert, im Baum fehlend).
- Ältere Releases/Tags: keine Tags vorhanden. Der GPL-Text gilt für den aktuellen
  Stand; die MIT-Datei aus `411edc7` gilt nur historisch für diesen Stand.

## 2. Abhängigkeiten (ohne installs geprüft, Versionen aus Manifesten)

Legende Bewertung: Angaben aus Manifest + öffentlichem SPDX-Katalogwissen,
**nicht** an der konkret installierten Version verifiziert (keine Lockfiles,
keine `node_modules`/`.dart_tool`). Vor einem MIT-Release je Version prüfen.

| Name | Version | Lizenz (Katalog) | Typ | Verwendung | Quelle | Bewertung | Nächster Schritt |
|---|---|---|---|---|---|---|---|
| express | ^4.18.2 | MIT | direkt | Laufzeit (HTTP) | `signaling_server/package.json` + SPDX | unproblematisch (unbestätigt) | Version pinnen, Lizenzdatei prüfen |
| ws | ^8.14.2 | MIT | direkt | Laufzeit (WebSocket) | wie oben | unproblematisch (unbestätigt) | wie oben |
| cors | ^2.8.5 | MIT | direkt | Laufzeit (Middleware) | wie oben | unproblematisch (unbestätigt) | wie oben |
| dotenv | ^16.3.1 | BSD-2-Clause | direkt | Laufzeit (Konfig) | wie oben | unproblematisch (unbestätigt) | wie oben |
| uuid | ^9.0.0 | MIT | direkt | Laufzeit | wie oben | unproblematisch (unbestätigt) | wie oben |
| pino | ^8.16.2 | MIT | direkt | Laufzeit (Logging) | wie oben | unproblematisch (unbestätigt) | wie oben |
| nodemon | ^3.0.1 | MIT | dev | Build/Dev | wie oben | unproblematisch (unbestätigt) | wie oben |
| node:18-alpine | Image-Tag | MIT-ähnlich (Node) + Alpine-Pakete | Laufzeit-Basis | Docker-Base `signaling_server/Dockerfile` | Dockerfile | bedingt (OS-Pakete separat) | SBOM des Images ziehen |
| nginx:alpine | Image-Tag | BSD-ähnlich (nginx) + Alpine-Pakete | Laufzeit-Auslieferung | Docker-Base `web_client/Dockerfile` | Dockerfile | bedingt (OS-Pakete separat) | SBOM des Images ziehen |
| provider, flutter_webrtc, supabase_flutter, hive, get_storage, flutter_secure_storage, intl, connectivity_plus, permission_handler, pointycastle, cupertino_icons, flutter_lints | Bereiche lt. `cosc/pubspec.yaml` | überwiegend MIT/BSD/Apache-2.0 laut Katalog; `flutter_webrtc` bindet native WebRTC-Binärkomponenten (BSD) ein | direkt/dev | Laufzeit/Build | `cosc/pubspec.yaml` + SPDX-Katalog | unproblematisch (unbestätigt), kein Copyleft-Hinweis | `flutter pubspec lock` + `PUB_CACHE`/Lizenzdateien je Version prüfen |
| Roboto-Fonts | Pfade in `pubspec.yaml`, Dateien fehlen | Apache-2.0 (Katalog) | Asset | mitgelieferte Schrift | `cosc/pubspec.yaml` (Dateien nicht im Baum) | ungeklärt | Herkunft/Lizenzdatei beim Hinzufügen beilegen |

Kein GPL/AGPL/LGPL unter den direkten Abhängigkeiten erkennbar. Transitive
Abhängigkeiten konnten ohne Lockfiles nicht zuverlässig erfasst werden — das ist
der größte offene Punkt in Phase 2. Es wurde **keine Abhängigkeit entfernt**.

## 3. Contributor- und Rechteanalyse (anonymisiert)

Git-Historie (`main`, Stand 2026-10-24): genau **eine natürliche Person**,
auftretend unter zwei E-Mail-Schreibweisen desselben Accounts (privat +
`users.noreply.github.com`). Keine `Co-authored-by`-Trailer, keine fremden
Autoren/Committer außer `GitHub <noreply@github.com>` als Merger bei PR-Merges.
Keine CLA/DCO-Vereinbarung im Repo.

| Person/Organisation | Betroffene Beiträge | Hinweise auf Rechteinhaberschaft | Vorhandene Freigabe | Offener Klärungsbedarf |
|---|---|---|---|---|
| Repository-Inhaber (einzelne Person, Account aus Git-Historie) | alle Commits inkl. GPL-Umstellung `beed10b` | Autorenschaft laut Git, **kein Beleg** für alleinige Inhaberschaft (Arbeitgeber/Auftraggeber möglich) | keine ausdrückliche MIT-Freigabe im Repo | schriftliche Bestätigung: alleinige Rechte + Zustimmung zur MIT-Lizenzierung künftiger Releases (inkl. Umgang mit GPL-Altstand) |
| ggf. Arbeitgeber/Auftraggeber | unbekannt | keine Hinweise im Repo | nein | Klärung, ob Dritt-Rechte bestehen |
| KI-Werkzeuge (Codex/Agenten lt. README/Commit-Nachrichten) | große Codeanteile (u. a. „Agent host session“-Commits) | Tool-Nutzungsbedingungen ungeklärt | nein | Nutzungsbedingungen des verwendeten Tools auf Rechteeinräumung prüfen, Ergebnis dokumentieren |

Keine Aussage über prozentuale Urheberschaft; kleine Beiträge werden weder als
bedeutungslos noch als automatisch zustimmungspflichtig eingestuft.

## 4. Voraussetzungen für MIT (Bewertung)

1. Eigener Code: **ungeklärt** — eine Person als einziger Git-Autor, aber ohne
   Beleg alleiniger Inhaberschaft.
2. Beiträge Dritter: keine fremden Commits gefunden; **offen** bleibt Dritt-Recht
   (Arbeitgeber/Auftraggeber) und Tool-Bedingungen.
3. Übernommmener Code: kein Fork-Hinweis, keine kopierten Snippets mit fremden
   Headern gefunden; generierte Dateien/Assets (Fonts) **ungeklärt**.
4. Abhängigkeiten: keine Copyleft-Blocker erkennbar, aber transitive
   Abhängigkeiten und exakte Versionen **unverifiziert** (keine Lockfiles).
5. Weitere Inhalte: Doku/Assets/Submodule ohne eigene Lizenzvermerke; fehlende
   `assets/` und fehlende Font-Lizenzdatei offen.
6. Metadaten: `LICENSE` und `package.json` konsistent GPL; `pubspec.yaml` ohne
   Lizenzangabe — bei Umstellung anzupassen, **nicht jetzt**.

## 5. Entscheidung: Kategorie B — Freigaben erforderlich

Kein Lizenzblocker (Kategorie C liegt nicht vor), aber die Rechte sind nicht
ausreichend belegt, um `LICENSE`/Metadaten auf MIT umzustellen. Daher: **keine
zentrale Lizenzdatei geändert**, keine fachliche Logik angefasst.

### Erforderliche Maßnahmen (Priorität)

1. Schriftliche MIT-Freigabe des Rechteinhabers für künftige Releases einholen
   (Umfang: gesamtes Repo ab Version/Datum X; Altstand bleibt GPL).
2. Dritt-Rechte (Arbeitgeber/Auftraggeber) und KI-Tool-Bedingungen klären und
   dokumentieren.
3. Lockfiles erzeugen/pinnen (`package-lock.json`, `pubspec.lock`), transitive
   Lizenzen je exakter Version verifizieren (SBOM), Docker-Base-Images per SBOM.
4. Fehlende `assets/` + Font-Lizenzdatei klären oder aus `pubspec.yaml` entfernen.
5. Erst danach: MIT-`LICENSE` mit korrektem Copyright, `README`-Hinweis mit
   Geltungsbeginn, `package.json`/`pubspec.yaml`-Metadaten, THIRD-PARTY-Datei,
   Changelog-Eintrag — als separater, beauftragter Schritt.

### Entwurf Kontaktaufnahme (nicht versendet)

> Betreff: Freigabe MIT-Lizenz für künftige Releases von cooperating-screen
> Hallo […], für das Repository cooperating-screen (aktuell GPL-3.0, `LICENSE`
> + `package.json`) ist eine MIT-Lizenzierung künftiger Releases ab [Version/
> Datum] vorgesehen (Altstände bleiben GPL). Bitte bestätige schriftlich: (1)
> du hältst die dafür nötigen Rechte (keine entgegenstehenden Dritt-Rechte),
> (2) du stimmst der MIT-Lizenzierung künftiger Releases zu. Danke!

## 6. Geänderte Dateien

- `docs/license-audit-mit.md` (diese Datei, neu): Audit-Befund als vorbereitendes
  Dokument. Keine Lizenz-, Metadaten- oder Codeänderung.

## 7. Validierung

- `git status --short` / `git diff --check`: vor dem Schreiben sauber;
  danach nur die neue Audit-Datei als untracked erwartet.
- Keine Tests ausgeführt (Platzhalter-Testskript; keine Codeänderung).
- Alle Lizenzangaben zu Abhängigkeiten als **unbestätigt** markiert.
