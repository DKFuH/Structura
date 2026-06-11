# Structura - Vollständige Arbeitsliste

## 0. Erledigt

- [x] `.gitignore` angelegt / bereinigt
- [x] Lizenz festgelegt: MIT (ursprünglich MPL-2.0, nach 0.1.0 auf MIT umgestellt)
- [x] Grundidee festgelegt: Structura ist ein Buch-Cockpit, kein Word-Ersatz
- [x] Projekt läuft grundsätzlich bereits
- [x] Ziel: lokale Windows-Anwendung für Buchprojekte mit DOCX-Kapiteln

---

## 1. Projekt vollständig und sauber machen

### 1.1 Fehlende oder referenzierte Dateien prüfen

- [x] Prüfen, ob alle in Lazarus referenzierten Units im Repository vorhanden sind
- [x] Fehlende `.pas`-Dateien ergänzen
- [x] Fehlende `.lfm`-Dateien ergänzen
- [x] Projektdatei `.lpi` auf tote Referenzen prüfen
- [x] Projektdatei `.lpr` prüfen
- [x] Package-Abhängigkeiten dokumentieren

Ziel: Das Projekt muss nach einem frischen Clone vollständig kompilierbar sein.

---

## 2. README überarbeiten

- [x] README an aktuellen Stand anpassen
- [x] Kurzbeschreibung ergänzen
- [x] Funktionsumfang ehrlich beschreiben
- [x] Noch nicht vorhandene Funktionen nicht als fertig darstellen
- [x] Installationshinweise ergänzen
- [x] Build-Hinweise für Lazarus ergänzen
- [x] Lizenzhinweis MIT ergänzen
- [ ] Screenshots ergänzen
- [x] Roadmap ergänzen

Kurzbeschreibung:

Structura ist ein lokales Windows-Tool zur Verwaltung von Buchprojekten mit einzelnen DOCX-Kapiteln. Es organisiert Kapitel, Teile, Reihenfolge, Notizen, Status und Vorschau. Die eigentliche Bearbeitung erfolgt weiterhin in Word, LibreOffice, SoftMaker Office oder dem Standard-DOCX-Programm.

---

## 3. Projektverwaltung

### 3.1 Projektordner

- [x] Projekt ist immer ein echter Ordner
- [x] Neues Projekt anlegen
- [x] Bestehendes Projekt öffnen
- [x] Projektordner im Explorer öffnen
- [x] Projektdatei im Projektordner speichern
- [x] Fehlermeldung bei ungültigem Projektordner

### 3.2 Projektdatei

- [x] `structura.json` laden
- [x] `structura.json` speichern
- [x] beschädigte JSON-Datei erkennen
- [x] Backup vor Überschreiben der Projektdatei erstellen
- [x] Projektversion in JSON speichern
- [ ] spätere Migrationen ermöglichen

---

## 4. Buchstruktur

### 4.1 Seitenleiste

- [x] Linke Seitenleiste mit Buchstruktur
- [x] Kapitel anzeigen
- [x] Trenner / Teile anzeigen
- [x] Reihenfolge sichtbar machen
- [x] Status je Kapitel anzeigen
- [x] aktive Auswahl klar markieren
- [x] lange Kapitelnamen sauber kürzen oder umbrechen

### 4.2 Kapitel

- [x] Kapitel hinzufügen
- [x] Kapitel löschen
- [x] Kapitel umbenennen
- [x] Kapitel verschieben
- [x] Kapitelnummer automatisch berechnen
- [x] Kapitelstatus speichern
- [x] Kapiteldatei zuordnen

### 4.3 Trenner / Teile

- [x] Trenner hinzufügen
- [x] Trenner löschen
- [x] Trenner umbenennen
- [x] Trenner verschieben
- [x] Trenner ohne DOCX-Datei speichern
- [x] Trenner optisch anders darstellen als Kapitel

Beispiele:

- Teil I - Grundlagen
- Teil II - Anwendung
- Teil III - Vertiefung

---

## 5. Nummerierung und Dateinamen

### 5.1 Automatische Nummerierung

- [x] Nummerierung ergibt sich aus Reihenfolge
- [x] Nummerierung wird nach Verschieben aktualisiert
- [x] Kapitelname bleibt beim Verschieben erhalten
- [x] Trenner werden nicht als Kapitel gezählt
- [x] Nummerierungsformat konfigurierbar machen

Beispiele:

- `01_Farbe.docx`
- `02_Licht.docx`
- `03_Material.docx`

### 5.2 Dateiname bei Titeländerung

- [x] Wenn Kapiteltitel geändert wird, DOCX-Datei ebenfalls umbenennen
- [x] Ungültige Zeichen aus Dateinamen entfernen
- [x] Umlaute sauber behandeln
- [x] Doppelte Dateinamen verhindern
- [x] Vor Umbenennung Backup erstellen
- [x] Prüfen, ob Datei gerade geöffnet oder gesperrt ist

### 5.3 Dateiname bei Positionsänderung

- [x] Optional: Nummer im Dateinamen nach Sortierung aktualisieren
- [ ] Vorher Konfliktprüfung durchführen
- [x] Niemals Dateien stillschweigend überschreiben
- [ ] Rückmeldung nach erfolgreicher Umbenennung anzeigen

---

## 6. Kapitelansicht

Wenn ein Kapitel ausgewählt ist, zeigt die Hauptansicht:

- [x] Kapitelnummer
- [x] Kapiteltitel
- [x] Dateiname
- [x] Status
- [x] Änderungsdatum
- [x] Wortzahl
- [x] Textvorschau
- [x] Kapitelnotizen
- [x] Buttons für externe Bearbeitung
- [x] frei konfigurierbare Workflow-Buttons

---

## 7. Textvorschau

### 7.1 Pflichtfunktion

Die Textvorschau muss ohne Word, LibreOffice oder SoftMaker funktionieren.

- [x] DOCX-Text extrahieren
- [x] Absätze erhalten
- [x] Text schreibgeschützt anzeigen
- [x] Wortzahl berechnen
- [x] Vorschau aktualisieren
- [x] Fehlermeldung bei defekter DOCX-Datei
- [x] Fehlermeldung bei fehlender Datei
- [x] Platzhalter anzeigen, wenn keine Vorschau möglich ist

### 7.2 Kein perfektes Layout in Version 0.1

Nicht erforderlich für v0.1:

- [ ] exakte Seitenansicht
- [ ] perfekte Tabellenansicht
- [ ] Bilddarstellung
- [ ] Fußnotenlayout
- [ ] Kopf- und Fußzeilenlayout

---

## 8. PDF und Vorschau

### 8.1 PDF nicht als Pflichtfunktion

- [x] Structura darf nicht von LibreOffice abhängen
- [x] PDF-Vorschau nur optional anbieten
- [x] Textvorschau bleibt Hauptvorschau
- [ ] Wenn kein PDF-Export verfügbar ist, Hinweis anzeigen
- [x] Nutzung der App darf ohne PDF-Funktion nicht eingeschränkt sein

### 8.2 Optionale PDF-Wege

- [ ] PDF über Microsoft Word prüfen
- [x] PDF über LibreOffice prüfen
- [ ] PDF über SoftMaker Office prüfen
- [x] manuelle PDF-Erzeugung durch Nutzer erlauben
- [ ] später optional PDF-Vorschau anzeigen

Regel:

Structura bleibt auch ohne LibreOffice vollständig nutzbar.

---

## 9. Externe Office-Programme

### 9.1 Standardprogramm

- [x] DOCX mit Windows-Standardprogramm öffnen
- [x] Datei im Explorer anzeigen
- [x] Fehlermeldung bei fehlender Datei
- [x] Button immer anbieten, wenn DOCX-Datei vorhanden ist

### 9.2 Word

- [x] Microsoft Word erkennen
- [x] Word-Pfad automatisch suchen
- [x] Word-Pfad manuell einstellbar machen
- [x] Button nur aktivieren, wenn Word gefunden wurde
- [x] Kapitel direkt in Word öffnen

### 9.3 LibreOffice

- [x] LibreOffice erkennen
- [x] LibreOffice-Pfad automatisch suchen
- [x] LibreOffice-Pfad manuell einstellbar machen
- [x] Button nur aktivieren, wenn LibreOffice gefunden wurde
- [x] Kapitel direkt in LibreOffice Writer öffnen

### 9.4 SoftMaker Office / TextMaker

- [x] SoftMaker TextMaker erkennen
- [x] TextMaker-Pfad automatisch suchen
- [x] TextMaker-Pfad manuell einstellbar machen
- [x] Button nur aktivieren, wenn SoftMaker gefunden wurde
- [x] Kapitel direkt in TextMaker öffnen

---

## 10. Frei konfigurierbare Workflow-Buttons

### 10.1 Grundidee

Statt eines fest eingebauten Grammarly-Buttons soll Structura frei beschreibbare Workflow-Buttons unterstützen.

Ein Workflow-Button besteht aus:

- Button-Name
- Link oder Programmpfad
- Zwischenablage-Inhalt
- optionaler Prefix
- optionaler Suffix
- optionaler Hinweistext

### 10.2 Beispiele

Beispiel Grammarly:

- Name: Grammarly
- Link: `https://app.grammarly.com/`
- Aktion: Kapiteltext in Zwischenablage kopieren
- Hinweis: Text in Grammarly einfügen und korrigierte Fassung zurück in die DOCX übernehmen

Beispiel LanguageTool:

- Name: LanguageTool
- Link: `https://languagetool.org/de`
- Aktion: Kapiteltext in Zwischenablage kopieren

Beispiel ChatGPT-Tiefenprüfung:

- Name: ChatGPT Tiefenprüfung
- Link: `https://chatgpt.com/`
- Aktion: Prüfauftrag plus Kapiteltext in Zwischenablage kopieren

### 10.3 Anforderungen

- [x] Workflow-Buttons in Einstellungen verwalten
- [x] Button-Name frei editierbar
- [x] URL frei eintragbar
- [x] Programmpfad frei eintragbar
- [x] mehrere Buttons möglich
- [x] aktueller Kapiteltext wird kopiert
- [x] optional Kapiteltitel mitkopieren
- [x] optional Prefix vor Kapiteltext setzen
- [x] optional Suffix nach Kapiteltext setzen
- [x] Link oder Programm nach dem Kopieren öffnen
- [ ] Hinweisdialog optional anzeigen
- [x] Grammarly nur als Standardvorlage mitliefern
- [x] keine feste Abhängigkeit zu Grammarly

---

## 11. Zwischenablage-Funktionen

- [x] reinen Kapiteltext kopieren
- [x] Kapiteltitel plus Text kopieren
- [x] Prüfprompt plus Text kopieren
- [x] Markdown-Version kopieren
- [x] Hinweis anzeigen: Text wurde kopiert
- [x] Fehler anzeigen, wenn kein Kapitel ausgewählt ist
- [x] Fehler anzeigen, wenn Text nicht extrahiert werden kann

---

## 12. Notizen

### 12.1 Kapitelnotizen

- [x] pro Kapitel eigene Markdown-Notiz speichern
- [x] Notiz beim Kapitelwechsel laden
- [x] Notizänderungen speichern
- [x] Autosave einbauen
- [ ] ungespeicherte Änderungen markieren
- [ ] Notizdatei im Explorer öffnen
- [ ] Notizdatei extern öffnen

### 12.2 Projektnotizen

- [x] `notes/project.md` unterstützen
- [x] Projektnotizen in Projektansicht anzeigen
- [x] Projektnotizen autospeichern
- [x] Projektnotizen extern bearbeitbar halten

---

## 13. Projektansicht

Wenn kein Kapitel ausgewählt ist, zeigt Structura eine Projektübersicht.

- [x] Cover anzeigen
- [x] Buchtitel anzeigen
- [x] Untertitel anzeigen
- [x] Autor anzeigen
- [x] Kapitelanzahl anzeigen
- [x] Gesamtwortzahl anzeigen
- [x] Projektstatus anzeigen
- [ ] letzte Änderung anzeigen
- [x] Projektnotizen anzeigen

---

## 14. Cover

- [x] Cover beim Projektstart wählbar machen
- [x] Blanco-Cover verwenden, wenn kein Cover gewählt wurde
- [x] Cover nachträglich ändern können
- [x] Coverbild in Projektordner kopieren
- [x] fehlendes Cover erkennen
- [x] saubere Skalierung in der Projektansicht
- [ ] kleines Cover in Seitenleiste optional anzeigen

---

## 15. Einstellungen

### 15.1 Allgemeine Einstellungen

- [x] Einstellungsdialog anlegen
- [x] Standard-Projektordner
- [ ] bevorzugter DOCX-Editor
- [x] Nummerierungsformat
- [x] Backup-Verhalten (Aufbewahrungsdauer der Tagesbackups)
- [ ] Autosave-Verhalten
- [ ] Sprache der Oberfläche optional vorbereiten

### 15.2 Programmpfade

- [x] Pfad zu Microsoft Word
- [x] Pfad zu LibreOffice
- [x] Pfad zu SoftMaker TextMaker
- [ ] Standardbrowser / Browserverhalten
- [x] Programmpfade automatisch suchen
- [x] manuelle Pfadangabe erlauben
- [ ] Pfade testen

### 15.3 Workflow-Buttons

- [x] Workflow-Button hinzufügen
- [x] Workflow-Button bearbeiten
- [x] Workflow-Button löschen
- [x] Workflow-Button sortieren
- [ ] Standardbuttons wiederherstellen

---

## 16. Backup

### 16.1 Automatische Backups

Backups sollen erstellt werden vor:

- [x] Kapitel umbenennen
- [x] DOCX-Datei umbenennen
- [x] Nummerierung im Dateinamen ändern
- [ ] Kapitel löschen
- [x] Projektdatei überschreiben
- [ ] externer Bearbeitung optional

### 16.2 Backup-Struktur

- [x] tägliches ZIP-Backup beim Projektöffnen (`backup/daily/JJJJ-MM-TT.zip`)
- [x] alte Tagesbackups automatisch löschen (Aufbewahrungsdauer einstellbar, Standard 14 Tage)
- [x] Backupordner im Projektordner
- [x] Zeitstempelordner pro Sicherung
- [x] betroffene Dateien kopieren
- [x] Projektdatei mitsichern
- [ ] Wiederherstellung später vorbereiten

Beispiel:

`backup/2026-06-11_2015/`

---

## 17. Fehlerbehandlung

Structura soll klare Fehlermeldungen anzeigen bei:

- [x] Projektdatei fehlt
- [x] Projektdatei beschädigt
- [x] Kapiteldatei fehlt
- [x] Kapiteldatei ist geöffnet
- [x] Kapiteldatei ist schreibgeschützt
- [x] Ziel-Dateiname existiert bereits
- [ ] Projektordner ist nicht beschreibbar
- [ ] Notizdatei fehlt
- [x] Coverbild fehlt
- [x] Word nicht gefunden
- [x] LibreOffice nicht gefunden
- [x] SoftMaker nicht gefunden
- [ ] Browser/URL kann nicht geöffnet werden
- [ ] DOCX-Text kann nicht extrahiert werden

Regel:

Keine stillen Fehler. Der Nutzer muss verstehen, was passiert ist.

---

## 18. Windows-UI verbessern

### 18.1 Responsives Verhalten

- [x] Fenster frei skalierbar
- [x] Seitenleiste mit Splitter
- [x] Mindestbreiten setzen
- [x] Hauptbereich wächst mit
- [x] Textvorschau nutzt verfügbaren Platz
- [ ] Notizenbereich einklappbar oder als Tab
- [ ] keine abgeschnittenen Buttons
- [ ] lange Dateinamen sinnvoll anzeigen

### 18.2 DPI und Darstellung

- [ ] Darstellung bei 100 % DPI prüfen
- [ ] Darstellung bei 125 % DPI prüfen
- [ ] Darstellung bei 150 % DPI prüfen
- [ ] Schriftgrößen lesbar halten
- [x] Statusleiste unten ergänzen
- [ ] klare Toolbar-Struktur

---

## 19. Statussystem

### 19.1 Statuswerte

- [x] Rohfassung
- [x] In Bearbeitung
- [x] Grammarly geprüft
- [x] Sprachlich geprüft
- [x] Fachlich geprüft
- [x] Final
- [x] Problem

### 19.2 Darstellung

- [x] Status in Kapitelansicht anzeigen
- [x] Status in Seitenleiste anzeigen
- [x] Status im Projekt speichern
- [x] Statusänderung sofort speichern
- [x] Statusfarben als farbige Punkte in der Seitenleiste

---

## 20. Statistiken

- [x] Wortzahl pro Kapitel
- [x] Gesamtwortzahl
- [x] Anzahl Kapitel
- [x] Anzahl Teile
- [x] Anzahl finaler Kapitel
- [x] Anzahl problematischer Kapitel
- [x] letzte Änderung pro Kapitel
- [ ] letzte Projektänderung

---

## 21. Sample-Projekt

- [x] `SampleProject/` vorhanden
- [x] Beispiel-`structura.json`
- [ ] Beispielcover oder Blanco-Cover
- [x] 2-3 Beispielkapitel
- [x] Beispiel-Trenner
- [x] Beispielnotizen
- [x] README-Hinweis zum Sample-Projekt

---

## 22. Release-Vorbereitung

### 22.1 Repository

- [x] Quellcode vollständig
- [x] Build-Dateien entfernt
- [x] README aktuell
- [x] LICENSE vorhanden
- [x] `.gitignore` aktiv
- [x] Beispielprojekt vorhanden
- [ ] Screenshots vorhanden
- [x] Roadmap vorhanden

### 22.2 Versionierung

- [x] Version `0.1.0` festlegen
- [x] `CHANGELOG.md` anlegen
- [x] erster Release-Text
- [x] bekannte Einschränkungen dokumentieren

### 22.3 Bekannte Einschränkungen dokumentieren

- [x] Structura ist kein DOCX-Editor
- [x] Textvorschau ist keine perfekte Layoutvorschau
- [x] PDF ist optional
- [x] Grammarly wird nicht automatisiert
- [x] Office-Programme müssen extern installiert sein

---

## 23. Nicht-Ziele für Version 0.1

Diese Punkte sollen bewusst nicht in Version 0.1 umgesetzt werden:

- [ ] vollständiger DOCX-Editor
- [ ] perfektes DOCX-Rendering
- [ ] automatische Grammarly-Steuerung
- [ ] Cloud-Synchronisation
- [ ] Mehrbenutzerbetrieb
- [ ] komplexes Satzsystem
- [ ] vollständiger PDF-Workflow als Pflichtfunktion
- [ ] eigener KI-Dienst
- [ ] eigenes Lektoratssystem

---

## 24. Priorisierte Reihenfolge

### Phase 1 - Projekt stabil machen

- [x] fehlende Dateien ergänzen
- [x] Projekt kompilierbar machen
- [x] README korrigieren
- [x] Projekt öffnen/speichern stabilisieren
- [x] Projektstruktur zuverlässig laden

### Phase 2 - Buchstruktur stabil machen

- [x] Kapitel anzeigen
- [x] Trenner anzeigen
- [x] Kapitel verschieben
- [x] Nummerierung aktualisieren
- [x] Kapitel umbenennen
- [x] DOCX-Datei sicher umbenennen
- [x] Backups vor riskanten Aktionen

### Phase 3 - Arbeiten mit Kapiteln verbessern

- [x] Textvorschau stabilisieren
- [x] Wortzählung
- [x] Kapitelnotizen
- [x] Projektnotizen
- [x] Statussystem
- [x] Projektübersicht mit Cover

### Phase 4 - externe Workflows

- [x] Standardprogramm öffnen
- [x] Word erkennen
- [x] LibreOffice erkennen
- [x] SoftMaker erkennen
- [x] frei konfigurierbare Workflow-Buttons
- [x] Kapiteltext in Zwischenablage kopieren
- [x] Link oder Programm öffnen

### Phase 5 - Komfort und Release

- [x] Einstellungen
- [x] Sample-Projekt
- [ ] Screenshots
- [x] Changelog
- [x] Version `0.1.0`
- [x] erstes GitHub-Release (0.1.0)

### Phase 6 - später

- [ ] PDF-Vorschau optional
- [x] Gesamtmanuskript-Export
- [ ] Exportprofile
- [ ] Installer
- [ ] erweiterte Layoutvorschau

---

## Kurzfazit

Version 0.1.0 ist released. Die Kernfunktionen sind stabil: Projektverwaltung, Kapitelstruktur, Textvorschau, Notizen, Statussystem, frei konfigurierbare Workflow-Buttons, Office-Erkennung.

Der nächste Meilenstein ist 0.1.1: UI-Bereinigung, offene Komfortlücken schließen, Doku schärfen.
