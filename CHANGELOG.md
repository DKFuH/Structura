# Changelog

All notable changes to Structura are documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/)

---

## [Unreleased]

### Changed

- Import now creates a proper new project in your project root instead of writing `structura.json` into the source folder. You pick a source folder anywhere (where your manuscript DOCX live); Structura scans it, copies the selected files into a new project subfolder (numbered `chapters/`), and leaves the originals untouched
- Import is structure-aware: it scans subfolders recursively, turns each subfolder into a part divider (e.g. `Teil 1/` → "Teil 1"), skips Structura's own `backup`/`export`/`notes` folders and Word lock files (`~$…`), and lets you reorder entries with ▲▼ before importing

### Changed

- Export now always produces a real `master.docx`, generated natively (OOXML written directly, no LibreOffice required) — title page, part headings, and chapter headings with page breaks. Previously DOCX was only created when LibreOffice was installed; without it you only got Markdown/HTML. PDF remains optional via LibreOffice and is now converted from the native DOCX

### Fixed

- Export dialog buttons (Exportieren / Abbrechen) were missing — they were placed on a bottom panel whose width wasn't settled when positioned, pushing them off-screen with their right anchor. They are now anchored directly to the dialog's bottom-right
- Import no longer freezes when opened: the recursive scan is bounded (max depth, skips symlinks/junctions and existing Structura projects with a `structura.json`), and the dialog no longer auto-scans the project root folder on open — scanning happens only after you pick a manuscript folder

---

## [0.5.0] — 2026-06-11

### Added

- Open-tasks checklist in the chapter view: add tasks via an input field (Enter or "+"), tick them off with checkboxes. Tasks are stored as Markdown checkboxes (`- [ ]` / `- [x]`) in the chapter notes, so they stay readable and editable without the app and feed the dashboard and review-table counts
- The chapter view now scales with the window: notes, tasks, and preview reflow to the available width and height instead of staying at fixed positions
- Gentle hint line on the dashboard: a single quiet row summarising drafts still remaining, chapters with open tasks, and chapters untouched for 30+ days — informs without nagging (design principle "Mitdenken ohne Dominieren")
- Export is now reachable directly from the project overview ("Export ▼" top-right), not only from the chapter view — opens the same export menu and dialog
- "← Zur Projektliste" link on the project overview closes the current project and returns to the start screen with the recently-opened tiles (saves notes first)
- Header menu (hamburger icon) bundles the rare/global actions — Settings, Erste Schritte (Hilfe), and About — instead of scattering them across a sidebar button and a separate icon. The sidebar "Einstellungen" button is gone; primary workflow actions stay visible

### Changed

- Projects without a cover now show an illustrated "Kein Cover" placeholder (project overview and start view tiles) instead of a plain gray box
- Open-task count moved from the chapter metadata line into the tasks panel heading ("Offene Aufgaben (2 von 5)")

### Fixed

- Button icons, the welcome owl, the About icon, and the cover placeholder were missing when the app was launched from a working directory other than its own folder (e.g. via a shortcut, or from the release zip on another machine) — all asset paths now resolve relative to the executable location instead of the current working directory
- Settings dialog no longer clips the program-status text at the bottom (taller dialog and status label)

---

## [0.4.0] — 2026-06-11

### Added

- Export dialog: choose which chapters to export (checklist, dividers shown as section rows), toggle title page (title, subtitle, author), chapter numbering in headings, and divider headings
- Review export: optionally writes one plain-text file per selected chapter to `export/review/` — ready to paste into Grammarly, LanguageTool, or ChatGPT

### Changed

- Master export uses the rewritten robust DOCX text extraction and the configured chapter number format; exporting with no chapters selected reports an error instead of writing an empty manuscript

---

## [0.3.0] — 2026-06-11

### Added

- Review table ("Review-Ansicht öffnen" on the project overview): all chapters with number, title, status, word count, notes indicator, and open-task count; dividers shown as section rows; double-click or "Zum Kapitel" jumps straight to the chapter
- Markdown preview for chapter notes: a "Vorschau"/"Bearbeiten" toggle next to the notes heading renders headings, lists, checklists, bold/italic/code, and horizontal rules (TurboPower iPro HTML panel, built-in Lazarus package)

### Changed

- DOCX text preview rewritten for robustness: extraction happens in memory (no temp directory), list paragraphs get bullet markers, table cells are tab-separated; if the file is locked by another program the preview retries via a copy and reports the real cause instead of claiming corruption

---

## [0.2.0] — 2026-06-11

### Added

- Author dashboard on the project overview: segmented progress bar colored by chapter status, status legend with counts, open-task count parsed from Markdown checklists (`- [ ]`) in chapter notes, and a suggested next step (problem chapters first, then the least-finished chapter)
- Problem chapters and recently edited chapters listed by name on the dashboard — click to jump straight to the chapter
- Chapter view shows the number of open checklist tasks from its notes
- Keyboard navigation: Alt+Left/Right switches chapters, Alt+O jumps to the next non-final chapter, Alt+P to the next problem chapter (wraps around)
- Configurable chapter number format in settings: 1, 2, or 3 digits (`1_`, `01_`, `001_`) — applies to filenames, sidebar, and chapter heading; changing it asks explicitly before renaming existing files
- Proactive file lock check before renaming chapter files: if a chapter DOCX is open in another program, the rename is refused with a clear message before any file is touched (single rename and bulk renumbering)
- Daily zipped project backup: on first open of a project each day, the entire project (excluding the backup folder) is archived to `backup/daily/YYYY-MM-DD.zip`; backups older than a configurable retention (default 14 days) are deleted automatically
- Colored status dots in the chapter sidebar (gray draft → green final, red problem) — replaces the bracketed status text
- Dividers are now visually distinct in the sidebar; long chapter titles are truncated with an ellipsis
- Welcome illustration (writing owl) on the start view as long as no projects exist yet
- Colored button icons from Streamline Ultimate Color (CC BY 4.0) replace the old two-color BMP glyphs
- About dialog (info icon in the sidebar header): version, MIT license, repository link, and icon attribution

### Changed

- Chapter view header row enlarged; back link more prominent
- Removed unused office diagnostic label from the project overview (leftover from the pre-0.1.0 startup diagnostics)

---

## [0.1.1] — 2026-06-11

### Added

- ROADMAP.md with planned milestones and explicit non-goals
- German README (README.de.md)

### Changed

- README tagline rewritten to focus on the author's actual workflow
- New project dialog redesigned: root folder (Hauptordner) and project subfolder (Unterordner) are now separate fields — the subfolder name is generated automatically from the project title
- Warning shown when creating a project in a folder that already contains a `structura.json`
- After creating a project, the root folder is remembered (not the new project's subfolder)

---

## [0.1.0] — 2026-06-11

First public release.

### Added

- Chapter-based Windows desktop workflow for non-fiction manuscript projects
- Real project folders with `structura.json` metadata — readable without the app
- Chapter and divider management (add, edit, delete, reorder)
- Drag-and-drop chapter reordering in the sidebar
- Per-project and per-chapter Markdown notes stored as `.md` files on disk
- DOCX text preview extraction for chapter files (no Word required for preview)
- Chapter statistics: word count, modification date, file size
- Project overview with cover image, metadata, and aggregate statistics
- Recent projects dashboard on startup — click any cover tile to reopen
- First-run wizard for setting a default project folder on first start
- Import existing project from folder — scans for `.docx` files and creates `structura.json` automatically
- External office application detection for Word, LibreOffice, and TextMaker
- Launch actions for opening chapters in detected external editors
- App settings for project folder defaults and office path overrides
- Configurable clipboard-based workflow buttons for external tools (Grammarly, LanguageTool, ChatGPT)
- Combined manuscript export workflow
- Sample project for contributors and testers

### Fixed

- LFM/PAS mismatch: `OpenMenuClick`, `ReviewMenuClick`, `CopyMenuClick`, `ExportMenuClick` moved to `published` section — resolved "Invalid value for property" startup crash
- `MakeSafeFileNamePart` now replaces German umlauts (ä→ae, ö→oe, ü→ue, ß→ss) in filenames
- Access violation on project card click — deferred `LoadProjectFromFolder` via `Application.QueueAsyncCall` so LCL finishes event dispatch before cards are cleared
- FPC compatibility: replaced `for..in` over inline array literal with explicit `if/else if` chain

### Changed

- License: MPL 2.0 → MIT
