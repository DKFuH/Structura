# Structura

Structura is a local Windows desktop application for organizing non-fiction book projects as chapter-based folders on disk. It is built with Free Pascal and Lazarus and intentionally focuses on project structure, notes, preview, and export workflows instead of becoming a DOCX editor.

## Release status

Structura is being prepared for its first open-source release, `0.1.0`.

The current scope is intentionally small and practical:

- create and open real project folders
- manage chapters and divider sections
- reorder chapters with drag and drop
- store project notes and chapter notes as Markdown files
- preview extracted text from `.docx` chapter files
- open chapters in external editors
- detect optional office targets such as Word, LibreOffice, and TextMaker
- export a combined master document

The repository is usable and buildable, but `0.1.0` should still be treated as an early release focused on local desktop workflows rather than a polished end-user product.

## What Structura is

- a local-first manuscript cockpit for chapter-based book projects
- a file-based organizer that keeps project data readable outside the app
- a companion to Word, LibreOffice, TextMaker, or other external editors

## What Structura is not

- not a DOCX editor
- not a cloud sync service
- not a collaborative multi-user writing platform
- not a pixel-perfect DOCX or PDF renderer

## Core concepts

Each Structura project is a normal folder on disk. A typical project contains:

- `structura.json` for metadata and structure
- `chapters/` for chapter files, usually `.docx`
- `notes/` for project and chapter notes in Markdown
- `backup/` for safety copies before risky file operations
- `preview/` for generated preview output
- `export/` for generated master exports

Structura supports two structural item types:

- `chapter` for editable manuscript sections with file, status, and notes
- `divider` for parts or separators without a chapter document

## Platform and requirements

- Windows desktop environment
- Lazarus / Free Pascal toolchain for local builds
- Lazarus package dependency: `LCL`
- optional external office tools for editing or PDF workflows:
  - Microsoft Word
  - LibreOffice
  - SoftMaker TextMaker

Text preview is intended to work without these external office applications. PDF-related workflows are optional and currently depend on external tooling where available.

## Build from source

1. Install Lazarus with a matching Free Pascal toolchain on Windows.
2. Open `Structura.lpi` in Lazarus.
3. Build the project from the IDE.
4. If Lazarus reports stale artifacts, clean local build outputs and rebuild.

The repository currently expects standard Lazarus project ingredients only:

- `Structura.lpi`
- `Structura.lpr`
- `*.pas`
- `*.lfm`
- the standard `LCL` package

Units in active use include:

- `MainFormUnit.pas`
- `ProjectDialogUnit.pas`
- `ElementDialogUnit.pas`
- `StructuraTypes.pas`
- `ProjectStore.pas`
- `DocxPreview.pas`
- `DocumentWorkflow.pas`
- `OfficeDetection.pas`
- `AppSettings.pas`
- `SettingsStore.pas`
- `SettingsDialogUnit.pas`
- `WorkflowButtonDialogUnit.pas`

## Repository layout

- `assets/` application assets such as icons and button graphics
- `docs/WORKLIST.md` working roadmap and release checklist
- `SampleProject/` example project structure for contributors and testers

## Preview, export, and external tools

Structura treats text preview as a core feature and PDF as optional:

- text preview should remain available without LibreOffice
- PDF generation currently relies on external office tooling when available
- chapter editing happens in external applications, not inside Structura
- office target paths can be overridden in the app settings
- clipboard-based workflow buttons can open websites or tools such as Grammarly, LanguageTool, or ChatGPT
- manual PDF creation outside the app remains a supported fallback

This keeps the app usable on machines that do not have a full office suite installed.

## Sample project

`SampleProject/` is included as a reference layout for contributors and testers. It demonstrates expected folders and files such as `structura.json`, `chapters/`, `notes/`, and generated export output. It is a working example, not a polished showcase manuscript.

## Release notes and planning

- roadmap and open release tasks: `docs/WORKLIST.md`
- release summary for `0.1.0`: `docs/release-notes.md`
- version history: `CHANGELOG.md`

## Contributing expectations

This repository is still settling into its first public release shape. Contributions should keep documentation and behavior aligned:

- do not present planned features as finished
- keep README and changelog statements consistent with the repository contents
- do not commit Lazarus build artifacts such as `*.ppu`, `*.o`, `*.obj`, `*.compiled`, or built executables

See `.gitignore` for the expected ignore rules.

## License

Structura is licensed under the Mozilla Public License 2.0 (`MPL-2.0`).

See [LICENSE](LICENSE) for the full license text.
