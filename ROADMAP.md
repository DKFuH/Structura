# Roadmap

Structura follows a slow, deliberate release pace. Each milestone stabilizes before the next one opens.

The guiding idea behind every release: authors need **orientation** (where do I stand?), **relief** (fewer clicks, less friction), and **visible progress** (small wins, not just a word count). Structura makes large book projects manageable by making chapters, status, notes, and progress visible — without taking the files out of the author's hands.

Every feature is measured against three goals — **Orientierung, Entlastung, Fortschritt**. If a feature serves none of them, it does not belong in the main view. See [docs/grundsaetze.md](docs/grundsaetze.md) for the full product and design principles.

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
- editable per-chapter task checklist (Markdown-backed) + responsive chapter view
- gentle dashboard hints (principle 5: "Mitdenken ohne Dominieren") — drafts remaining, chapters with open tasks, chapters untouched for 30+ days

## 0.3.x — Review mode (relief)

A view built for the revision phase, not the drafting phase.

**Done (released as 0.3.0):**
- chapter review table (number | chapter | status | words | notes | open tasks), double-click jumps to the chapter
- Markdown notes preview panel (toggle between edit and rendered view)
- more robust DOCX text preview: in-memory extraction, list bullets, table cells, lock-aware error handling

## 0.4.x — Export

**Done (released as 0.4.0):**
- more stable combined manuscript export (in-memory DOCX extraction)
- export options: title page, chapter numbering, divider headings
- chapter selection for export
- review export for Grammarly/ChatGPT workflows (one text file per chapter)
- structure-aware import: pick a source folder anywhere, recursive subfolder scan, subfolders become part dividers, reorder before importing; creates a new project in the project root and copies the files in (originals untouched)

## 0.7.x — Find & review flow (separate work views)

Not "do more", but: in a real manuscript, find the spot to continue faster. **Hard rule: the sidebar stays a pure table of contents — chapters and parts only. No filters, no search results, no review logic there.** Everything analytical lives in its own modal/dialog.

**Done (released as 0.7.0):**
- global project search as a modal (Ctrl+F): chapter titles, dividers, notes, tasks, extracted DOCX preview text; results list with jump-to-chapter
- review dialog with filters (problem chapters, open tasks, non-final, stale) — filters live only inside that dialog
- backup access from the app menu (open the daily backup folder, show last backup)
- daily backup also refreshed on close/switch
- gentle protection prompts for chapters marked "Final" before rename/delete/move

## 0.7.1 — Stabilization

No new features. A lot was built quickly in 0.6–0.7; harden it before opening the next block.

- test global search with real projects
- verify review filters
- verify backup-on-close
- test final-chapter protection
- re-test export after 0.7 changes
- smooth out small UI glitches

## 0.8.0 — Weiterarbeiten (work flow & motivation)

Not "more technology" — help start and end a work session cleanly. Open the project and immediately know where to continue.

- "Continue last work": on project start, surface the last-edited chapter with a Continue button
- "Heute weiterarbeiten" suggestions on the dashboard (open tasks, problem chapters, stale chapters) — gentle, not nagging
- quiet daily progress (tasks done, chapters opened, export created)
- optional session start/end with a small goal and a short summary
- auto-detected project milestones (all chapters created, first draft complete, 50% reviewed, no open tasks, export created)

Not in 0.8: cloud, AI, installer, template library, Git, own editor, more export logic.

## 1.0.0 — Ready for real book projects

**Done:**
- native, fully Word-compliant DOCX export (real styles, document properties)

**Planned:**
- clean Windows release with SmartScreen-aware packaging (code signing)
- complete user documentation + screenshots
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
