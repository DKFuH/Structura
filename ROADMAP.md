# Roadmap

Structura follows a slow, deliberate release pace. Each milestone stabilizes before the next one opens.

The guiding idea behind every release: authors need **orientation** (where do I stand?), **relief** (fewer clicks, less friction), and **visible progress** (small wins, not just a word count). Structura makes large book projects manageable by making chapters, status, notes, and progress visible — without taking the files out of the author's hands.

## 0.1.x — Stabilization

The goal of the 0.1.x series is a reliable, calm desktop workflow for authors who already work with DOCX files.

**Done in 0.1.0 / 0.1.1:**
- project dialog with root folder + subfolder separation
- auto-detection of Word, LibreOffice, TextMaker — detected paths pre-filled in settings
- workflow buttons grouped into dropdowns (Open, Review, Copy, Export)
- clean startup view without diagnostic output
- configurable workflow buttons for external review tools
- configurable chapter number format (1–3 digits)
- file lock check before renaming — projects never end up half-renamed
- daily zipped project backups with configurable retention

- colored status dots in the sidebar, dividers visually distinct, long titles truncated cleanly

**Planned for 0.1.x:**
- improved SampleProject layout
- screenshots in documentation

## 0.2.x — Author dashboard (orientation & progress)

When a project is open, the overview should answer at a glance: what is done, what is open, what is the next sensible step?

**Done:**
- project dashboard: chapter counts by status, segmented progress bar
- suggested next step ("review chapter 07") — problem chapters first
- open-task count from Markdown checklists (`- [ ]`) in chapter notes
- problem chapters listed by name, clickable
- recently edited chapters, clickable
- per-chapter open-task count in the chapter view
- fast keyboard navigation: Alt+←/→ chapters, Alt+O next open, Alt+P next problem

## 0.3.x — Review mode (relief)

A view built for the revision phase, not the drafting phase.

- chapter review table: chapter | status | words | notes | open tasks
- better notes view, Markdown notes with preview panel
- more robust DOCX text preview

## 0.4.x — Export

- more stable combined manuscript export
- export profiles (title page, chapter numbering options)
- chapter selection for export
- review export for Grammarly/ChatGPT workflows
- better import from existing DOCX folder structures

## 1.0.0 — Ready for real book projects

- clean Windows release with SmartScreen-aware packaging
- complete user documentation
- stable end-to-end workflow from draft to export
- tested against real manuscript sizes

---

## What is not planned

Structura will not become any of these things:

- a DOCX editor or word processor
- a cloud sync or collaboration platform
- a PDF renderer
- an installer-based application
- a Scrivener replacement

The goal is to stay small, fast, local, and focused on the workflow that connects external editors to a structured manuscript folder.
