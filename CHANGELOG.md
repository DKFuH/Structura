# Changelog

All notable changes to Structura are documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/)

---

## [0.1.1] — 2026-06-11

### Added

- ROADMAP.md with planned milestones and explicit non-goals
- German README (README.de.md)
- Configurable chapter number format in settings: 1, 2, or 3 digits (`1_`, `01_`, `001_`) — applies to filenames, sidebar, and chapter heading
- Proactive file lock check before renaming chapter files: if a chapter DOCX is open in another program, the rename is refused with a clear message before any file is touched (single rename and bulk renumbering)
- Daily zipped project backup: on first open of a project each day, the entire project (excluding the backup folder) is archived to `backup/daily/YYYY-MM-DD.zip`; backups older than a configurable retention (default 14 days, settable in settings) are deleted automatically
- Changing the chapter number format asks explicitly whether existing chapter files should be renamed — nothing is renamed silently
- Colored status dots in the chapter sidebar (gray draft → green final, red problem) — replaces the bracketed status text
- Dividers are now visually distinct in the sidebar (bold on gray background instead of `--- title ---`)
- Long chapter titles are truncated with an ellipsis instead of overflowing

### Changed

- README tagline rewritten to focus on the author's actual workflow
- New project dialog redesigned: root folder (Hauptordner) and project subfolder (Unterordner) are now separate fields — the subfolder name is generated automatically from the project title
- Warning shown when creating a project in a folder that already contains a `structura.json`
- After creating a project, the root folder is remembered (not the new project's subfolder)
- Removed unused office diagnostic label from the project overview (leftover from the pre-0.1.0 startup diagnostics)

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
