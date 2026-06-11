# Structura

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/DKFuH/Structura)](https://github.com/DKFuH/Structura/releases/latest)

→ [English documentation](README.md)

Structura hilft Sachbuchautoren, große Manuskripte kapitelweise zu ordnen, zu prüfen und kontrolliert bis zum Export zu führen – ohne die Hoheit über ihre Dateien zu verlieren.

Es ist eine lokale Windows-Desktop-Anwendung, gebaut mit Free Pascal und Lazarus. Structura bleibt bewusst im Hintergrund: keine DOCX-Bearbeitung, keine Cloud-Synchronisation, alle Projektdaten in normalen Ordnern, die auch ohne die App lesbar bleiben.

## Download

Fertige Windows-Binaries sind auf der [Releases-Seite](https://github.com/DKFuH/Structura/releases) verfügbar.

Aktuelle `Structura-vX.X.X-windows-x64.zip` herunterladen, entpacken und `Structura.exe` starten. Kein Installer nötig.

> **Windows SmartScreen-Warnung:** Da Structura kein kommerzielles Code-Signing besitzt, zeigt Windows beim ersten Start möglicherweise die Meldung „Windows hat Ihren PC geschützt". Das ist bei unsignierter Open-Source-Software üblich. Klicke auf **Weitere Informationen** → **Trotzdem ausführen**, um fortzufahren. Der vollständige Quellcode liegt in diesem Repository zur Überprüfung bereit.

## Erste Schritte

Beim ersten Start führt ein dreistufiger Einrichtungsassistent durch die Konfiguration:

1. **Stammordner** – wähle einen Ordner, der alle Buchprojekt-Unterordner enthält, z. B. `C:\Buecher`. Structura scannt diesen Ordner beim Start nach vorhandenen Projekten.
2. **Office-Programme** – Word, LibreOffice und SoftMaker TextMaker werden automatisch erkannt. Pfade können jederzeit in den Einstellungen geändert werden.
3. **Fertig** – der Assistent zeigt, was gefunden wurde, und du kannst sofort loslegen.

Zum Anlegen des ersten Projekts auf **Neues Projekt** klicken, einen Titel eingeben – Structura erstellt einen benannten Unterordner mit der vollständigen Projektstruktur.

Eine Schritt-für-Schritt-Anleitung gibt es in [`docs/first-steps.md`](docs/first-steps.md).

## Screenshots

![Willkommensbildschirm](docs/screenshots/01_welcome.jpg)

![Neues-Projekt-Dialog](docs/screenshots/05_new_project.jpg)

![Kapitelansicht](docs/screenshots/08_chapter_view.jpg)

## Was Structura kann

- Buchprojektordner anlegen und öffnen
- Kapitel und Trenner verwalten
- Kapitel per Drag-and-Drop umordnen
- Projektnotizen und Kapitelnotizen als Markdown-Dateien speichern
- Textvorschau aus `.docx`-Kapiteldateien extrahieren
- Kapitel in externen Editoren öffnen
- Optionale Office-Programme erkennen (Word, LibreOffice, TextMaker)
- Kombiniertes Master-Dokument exportieren

`0.1.0` ist ein erstes Release, das sich auf lokale Desktop-Workflows konzentriert.

## Was Structura ist

- ein lokales Manuskript-Cockpit für kapitelbasierte Buchprojekte
- ein dateibasierter Organizer, dessen Projektdaten auch außerhalb der App lesbar bleiben
- ein Begleiter für Word, LibreOffice, TextMaker oder andere externe Editoren

## Was Structura nicht ist

- kein DOCX-Editor
- kein Cloud-Synchronisationsdienst
- keine kollaborative Mehrbenutzer-Schreibplattform
- kein pixelgenaues DOCX- oder PDF-Renderer

## Grundprinzip

Jedes Structura-Projekt ist ein normaler Ordner auf der Festplatte. Ein typisches Projekt enthält:

- `structura.json` – Metadaten und Kapitelstruktur
- `chapters/` – Kapitel-DOCX-Dateien
- `notes/` – Projekt- und Kapitelnotizen als Markdown
- `backup/` – automatische Sicherungskopien vor riskanten Aktionen
- `preview/` – generierte Textvorschau
- `export/` – generiertes Master-Exportdokument

Structura kennt zwei Strukturelemente:

- `chapter` – bearbeitbarer Manuskriptabschnitt mit Datei, Status und Notizen
- `divider` – Teiltrenner oder Abschnittsmarkierung ohne DOCX-Datei

## Plattform und Voraussetzungen

- Windows-Desktop-Umgebung
- Lazarus / Free Pascal für lokale Builds
- Lazarus-Paketabhängigkeit: `LCL`
- optionale externe Office-Programme:
  - Microsoft Word
  - LibreOffice
  - SoftMaker TextMaker

Die Textvorschau funktioniert ohne installiertes Office-Programm. PDF-Workflows sind optional und setzen externe Werkzeuge voraus.

## Aus dem Quellcode bauen

1. Lazarus mit passendem Free Pascal Toolchain unter Windows installieren.
2. `Structura.lpi` in Lazarus öffnen.
3. Projekt aus der IDE kompilieren.
4. Bei veralteten Artefakten: Build-Ausgaben bereinigen und neu bauen.

## Roadmap und Planung

- geplante Richtung: [ROADMAP.md](ROADMAP.md)
- Versionshistorie: [CHANGELOG.md](CHANGELOG.md)

## Lizenz

Structura steht unter der MIT-Lizenz.

Vollständiger Lizenztext: [LICENSE](LICENSE)
