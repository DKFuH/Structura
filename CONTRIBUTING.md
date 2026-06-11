# Contributing to Structura

Thank you for your interest in contributing.

## Before you start

- Check open issues to avoid duplicate work.
- For larger changes, open an issue first to discuss the approach.

## Development setup

1. Install [Lazarus](https://www.lazarus-ide.org/) with a matching Free Pascal toolchain on Windows.
2. Clone the repository.
3. Open `structura.lpi` in the Lazarus IDE.
4. Build and run from the IDE.

## Coding conventions

- Free Pascal / Lazarus LCL — follow existing unit and naming conventions.
- Forms that can be built programmatically (no designer required) are preferred for new dialogs.
- No build artefacts in commits — `*.ppu`, `*.o`, `*.exe` are gitignored.

## Submitting changes

1. Fork the repository and create a feature branch.
2. Keep commits focused — one logical change per commit.
3. Describe *what* and *why* in commit messages, not just *what*.
4. Open a pull request against `main`.

## Reporting bugs

Open a GitHub issue and include:

- Structura version (from the release tag)
- Windows version
- Steps to reproduce
- Expected vs. actual behaviour
- Screenshot or error message if applicable

## Feature requests

Open a GitHub issue with the label `enhancement` and describe the use case.
