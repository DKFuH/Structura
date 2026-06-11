# Changelog

All notable changes to Structura are documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning](https://semver.org/)

---

## [Unreleased] — 0.1.1

### Changed

- README tagline updated to reflect the actual user promise
- ROADMAP.md added for public visibility of direction
- German README (README.de.md) added

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
