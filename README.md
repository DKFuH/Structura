# Structura

Structura is a local Windows desktop application for managing non-fiction book manuscripts as chapter-based projects. It is implemented in Free Pascal / Lazarus and intentionally behaves as a book cockpit rather than a full DOCX editor.

## What Structura is for

- Organize chapter structure and order
- Manage chapter metadata and editing status
- Store chapter notes as Markdown files
- Preview chapter text from DOCX files
- Open chapter files in external editors
- Keep project data in a plain project folder with `structura.json`

## What Structura is not

- It is not a DOCX editor
- It does not replace Word, LibreOffice, or SoftMaker Office
- It does not require LibreOffice to function
- It does not require cloud sync or multi-user collaboration

## Current implementation

The workspace currently contains the following core units:

- `Structura.lpi` – Lazarus project file
- `MainFormUnit.pas` – main UI and workflow logic
- `StructuraTypes.pas` – domain model for project, chapters, dividers, and statuses
- `ProjectStore.pas` – project persistence to `structura.json` and folder structure management
- `DocxPreview.pas` – extracts plain text preview from `.docx` by reading `word/document.xml`
- `ProjectDialogUnit.pas` – project creation/open dialog
- `ElementDialogUnit.pas` – chapter/divider creation/edit dialog
- `OfficeDetection.pas` – detection of available external office targets
- `DocumentWorkflow.pas` – workflow helpers used by the main form

### Project storage model

A Structura project is stored in a folder with:

- `structura.json` – project metadata and ordered item list
- `chapters/` – chapter files, ideally `.docx`
- `notes/` – Markdown notes, including `project.md` and chapter notes like `k20260610212026303.md`
- `backup/` – backup copies created by the app
- `preview/` – preview output and temporary preview artifacts

The project model supports two item types:

- `chapter` – contains a title, DOCX filename, status, and notes file
- `divider` – structural separator without an associated chapter file

### Notes and preview

- Notes are stored as Markdown files, keeping them readable outside Structura
- Project notes are saved to `notes/project.md`
- Chapter notes are saved to `notes/<item-id>.md`
- Preview text is extracted from `.docx` files by unzipping `word/document.xml` and reading paragraph text

## Workspace scan findings

The current workspace contains a sample project in `SampleProject/` with:

- `SampleProject/export/master.md`
- `SampleProject/chapters/Einleitung.txt`
- `SampleProject/notes/project.md`
- `SampleProject/notes/chapter-sample-1.md`

This sample project demonstrates the folder layout and note structure, although the sample chapter file is currently plain text.

## Supported workflow today

- Create or open a project folder
- Display project overview and chapter structure
- Select chapters to view metadata, notes, and preview text
- Save chapter and project notes automatically
- Open chapters in external applications using detected office targets
- Manage chapter file names, backups, and project JSON storage

## Supported statuses

Current chapter status values defined in `StructuraTypes.pas`:

- Rohfassung
- In Bearbeitung
- Grammarly geprüft
- Sprachlich geprüft
- Fachlich geprüft
- Final
- Problem

## Vision and development roadmap

This README is aligned with the stated Arbeitsbeschreibung for the next Structura development stage.

### Core goals

- Keep Structura independent from LibreOffice
- Treat Word, LibreOffice, SoftMaker Office, and the system default editor as optional external tools
- Maintain DOCX chapters as standalone files
- Use Markdown for notes
- Provide a robust local Windows book cockpit

### Priorities for next version

1. Open existing projects, show chapter structure, select chapters, preview text, save notes, and open chapters externally
2. Rename chapters, keep DOCX filenames in sync, move chapters, update numbering, insert dividers, and create backups before unsafe changes
3. Detect available Word/LibreOffice/SoftMaker installations and enable buttons accordingly, plus support the Grammarly workflow
4. Add optional PDF preview/export, export profiles, project statistics, and manuscript compilation later

### Non-goals for this version

- No full DOCX editing engine
- No exact DOCX layout rendering
- No automated Grammarly control
- No cloud sync, no multi-user mode

## Build and run

Open `Structura.lpi` in Lazarus and compile the project.

Required Free Pascal units include:

- `zipper`
- `DOM`
- `XMLRead`
- `fpjson`
- `jsonparser`

## Notes for contributors

- The project data model is intentionally simple and folder-based
- Project persistence is JSON-centric, while notes remain Markdown
- The UI is designed for a resizable Windows layout with sidebar and main panel
- Use `ProjectStore.EnsureProjectFolders` to keep required folders present

## Conclusion

Structura is a lightweight manuscript management tool for Windows authors, built around structured chapter projects and external DOCX editing. The current codebase already implements the key architecture for chapter/divider management, Markdown notes, DOCX preview extraction, and project folder persistence.
