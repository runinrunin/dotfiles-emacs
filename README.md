# dotfiles-emacs
my current emacs configuration in one file 

# Emacs Configuration

Personal Emacs configuration focused on programming, project navigation, and a modern completion UI.

## Features

- `use-package`-based package management
- Modern minibuffer completion with:
  - `vertico`
  - `orderless`
  - `marginalia`
  - `consult`
  - `embark`
- In-buffer completion with:
  - `corfu`
  - `cape`
- LSP support with `eglot`
- Syntax checking with `flymake`
- Project management with `projectile`
- File tree sidebar with `treemacs`
- Git integration with `magit`
- Snippets with `yasnippet`
- Structural editing with `smartparens`
- Formatting support with `format-all`
- Startup dashboard with `dashboard`
- Modeline with `doom-modeline`
- Tree-sitter integration via `treesit-auto`

## UI

- Theme: `gruvbox-dark-hard`
- Font: `Iosevka Nerd Font`
- Relative line numbers
- Transparent frame
- Minimal interface:
  - no toolbar
  - no menubar
  - no scrollbar

## Extra Packages

This config also includes useful quality-of-life packages such as:

- `which-key`
- `expand-region`
- `move-text`
- `undo-tree`
- `nerd-icons`
- `nerd-icons-dired`
- `golden-ratio`
- `dashboard`
- `async`

## Notes

- Designed for a personal workflow, mainly development-oriented.
- Some features assume external tools are installed (language servers, formatters, Nerd Fonts, etc.).
- Best used with a recent Emacs version, especially for built-in tree-sitter support.

## Requirements

- Emacs 29+ recommended
- Internet access on first launch to install packages
- `Iosevka Nerd Font` installed for the intended appearance

## Installation

Clone or copy this file as your `~/.emacs` then start Emacs.

