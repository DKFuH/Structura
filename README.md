# Structura

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/DKFuH/Structura)](https://github.com/DKFuH/Structura/releases/latest)

Structura is a local Windows desktop application for organizing non-fiction book projects as chapter-based folders on disk. It is built with Free Pascal and Lazarus and intentionally focuses on project structure, notes, preview, and export workflows instead of becoming a DOCX editor.

## Download

Pre-built Windows binaries are available on the [Releases page](https://github.com/DKFuH/Structura/releases).

Download the latest `Structura-vX.X.X-windows-x64.zip`, extract it anywhere, and run `Structura.exe`. No installer required.

## Getting started

On first launch, a three-step setup wizard guides you through the initial configuration:

1. **Root folder** — choose a folder that will contain your book project subfolders, for example `C:\Books`. Structura scans this folder for existing projects on startup.
2. **Office tools** — Word, LibreOffice, and SoftMaker TextMaker are detected automatically. Paths can be changed in Settings at any time.
3. **Done** — the wizard shows what was found and you can start immediately.

To create your first project, click **Neues Projekt**, enter a title, and Structura creates a named subfolder with the full project structure.

For a step-by-step walkthrough see [`docs/first-steps.md`](docs/first-steps.md).

## What Structura does

- create and open book project folders
- manage chapters and divider sections
- reorder chapters with drag and drop
- store project notes and chapter notes as Markdown files
- preview extracted text from `.docx` chapter files
- open chapters in external editors
- detect optional office tools (Word, LibreOffice, TextMaker)
- export a combined master document

`0.1.0` is an early release focused on local desktop workflows.

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

Structura is licensed under the MIT License.

See [LICENSE](LICENSE) for the full license text.
