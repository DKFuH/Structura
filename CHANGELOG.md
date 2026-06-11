# Changelog

All notable changes to Structura will be documented in this file.

The format is based on Keep a Changelog, and this project uses semantic versioning for release intent.

## [0.1.0] - 2026-06-11

Initial open-source release.

### Added

- chapter-based Windows desktop workflow for non-fiction manuscript projects
- real project folders with `structura.json` metadata storage
- chapter and divider management
- drag-and-drop chapter reordering in the sidebar
- per-project and per-chapter Markdown notes
- DOCX text preview extraction for chapter files
- chapter statistics such as word counts and modification dates
- project overview with cover, metadata, and aggregate statistics
- external office application detection for Word, LibreOffice, and TextMaker
- launch actions for external chapter editing
- app settings for project defaults and office path overrides
- configurable clipboard-based workflow buttons for external review tools
- combined manuscript export workflow
- sample project structure for contributors and testers

### Fixed

- LFM/PAS mismatch: `OpenMenuClick`, `ReviewMenuClick`, `CopyMenuClick`, `ExportMenuClick` moved to `published` section — resolves "Invalid value for property" startup crash
- `MakeSafeFileNamePart` now replaces German umlauts (ä→ae, ö→oe, ü→ue, Ä→Ae, Ö→Oe, Ü→Ue, ß→ss) before sanitizing file name characters
- `DeleteItemClick` now creates a backup copy of the chapter DOCX before removing the entry from the project
- added `OpenProjectFolderClick` and "Projektordner öffnen" entry in the export popup menu

### Notes

- Structura is intentionally not a DOCX editor
- text preview is not a full layout renderer
- PDF workflows are optional and may depend on external office software
- release packaging and screenshots are still being refined after `0.1.0`
