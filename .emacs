; Gaspard's .emacs config file
;; Melpa, lsp, treemacs, orgmode, format-all, ido, projectile, higlight, dashboard, etc.
;; font :i osevka-nerdfont
;; theme : automata (w/ some customisations)


(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package) (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;
;;         === Emacs package ===
;;

(use-package emacs
  :custom
  ;; Only variables that are intended for customization via M-x customize go here
  (create-lockfile nil)
  (global-auto-revert-non-file-buffers t) ; This is a customization variable, so it fits
  (use-short-answers t) ; This is a customization variable, so it fits

  (tab-always-indent 'complete) ; This is a customization variable, so it fits
  (read-extended-command-predicate #'command-completion-default-include-p) ; This is a customization variable, so it fits

  (enable-recursive-minibuffers t) ; This is a customization variable, so it fits

  :init
  ;; All direct calls to functions (like modes) and `setq` for global variables go here.
  ;; This ensures they are evaluated correctly on startup.

  ;; Emacs Initial Window'size - Using setq here
  (setq initial-frame-alist '((top . 0) (left . 100) (width . 120) (height . 40)))
  (setq default-frame-alist '((top . 0) (left . 100) (width . 120) (height . 40)))

  ;; Clean up interface - These are commands, so they belong in :init or :config
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode 0)
  (column-number-mode 1)
  ;;(show-paren-mode 1) ; Still removed, rely on smartparens

  ;; Global modes and variable settings - Using setq for variables
  (setq display-line-numbers-type 'relative)
  (setq make-backup-files nil)
  (setq inhibit-startup-message t) ; Corrected case

  (global-display-line-numbers-mode 1) ; Command call
  (global-subword-mode 1) ; Command call

  ;; Hooks and other setup
  (global-hl-line-mode 1)
  (global-auto-revert-mode 1)
  (xterm-mouse-mode 1)

  ;; Add prompt indicator to `completing-read-multiple'.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Disable line numbers for some modes
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  shell-mode-hook
                  treemacs-mode-hook
                  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

  (setq split-width-threshold 0)
  (setq split-height-threshold nil)

  :config
  ;; Font setting (a command, so in :config is appropriate)
  (set-frame-font "Iosevka Nerd Font-20")
  )

;; Performance Hacks
;; Emacs is an Elisp interpreter, and when running programs or packages,
;; rit can occasionally experience pauses due to garbage collection.
;; By increasing the garbage collection threshold, we reduce these pauses
;; during heavy operations, leading to smoother performance.
(setq gc-cons-threshold #x40000000)

;; Set the maximum output size for reading process output, allowing for larger data transfers.
(setq read-process-output-max (* 1024 1024 4))


;; Theme
(use-package gruvbox-theme
  :ensure t
  :config
  (load-theme 'gruvbox-dark-hard t))

;; Set background transparency for new frames (Emacs 29+)
 ;;(set-frame-parameter (selected-frame) 'alpha '(<active> . <inactive>))
 ;;(set-frame-parameter (selected-frame) 'alpha <both>)
(set-frame-parameter (selected-frame) 'alpha '(95 . 85))
(add-to-list 'default-frame-alist '(alpha . (95 . 85)))


(use-package nerd-icons
  :ensure t
  :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

;; Expand region hotkey
(use-package expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;;          === Packages ===
;;


(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :config
;; Whether display icons in the mode-line.
;; While using the server mode in GUI, should set the value explicitly.
  (setq doom-modeline-icon t)
  )


;;; ASYNC
;; Emacs look SIGNIFICANTLY less often which is a good thing.
;; asynchronous bytecode compilation and various other actions makes
(use-package async
  :ensure t
  :after dired
  :init
  (dired-async-mode 1))

;;; FLYMAKE
;; Flymake is an on-the-fly syntax checking extension that provides real-time feedback 
;; about errors and warnings in your code as you write. This can greatly enhance your 
;; coding experience by catching issues early. The configuration below activates 
;; Flymake mode in programming buffers.
(use-package flymake
  :ensure nil          ;; This is built-in, no need to fetch it.
  :defer t
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-margin-indicators-string
   '((error "!»" compilation-error) (warning "»" compilation-warning)
	 (note "»" compilation-info))))

(use-package savehist
  :defer 2
  :init
  (savehist-mode t)
  ;; So I can always jump back to wear I left of yesterday
  (add-to-list 'savehist-additional-variables 'global-mark-ring))

(use-package paredit
  :ensure t)

(use-package eterm-256color
  :ensure t
  :hook (term-mode . eterm-256color-mode))

;; Golden-ratio
(use-package golden-ratio
  :ensure t
  :hook (after-init . golden-ratio-mode)
  :custom
  (golden-ratio-exclude-mode '(occur-mode)))

;; Dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  ;; All dashboard-related setq calls moved into :config
  (setq inhibit-startup-screen t) ; Moved into :config of dashboard
  (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
  (setq dashboard-startup-banner 'official)
  (setq dashboard-center-content nil)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-show-shortcuts t)
  (setq dashboard-display-icons-p t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-items '(
	       	(recents   . 5)
                (bookmarks . 5)
                (projects  . 5)
                (registers . 5)))
  (setq dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-newline
                                    dashboard-insert-banner-title
                                    dashboard-insert-newline
                                    dashboard-insert-navigator
                                    dashboard-insert-newline
                                    dashboard-insert-init-info
                                    dashboard-insert-items
                                    dashboard-insert-newline
                                    dashboard-insert-footer)))

;; A file explorer sidebar for Emacs that displays your project's directory structure in a tree-like view, similar to IDEs.
(use-package treemacs
  :ensure t
  :defer t
  :bind
  (("C-c t" . treemacs))
  :config
  (setq treemacs-width 30))

;; Synchronizes Emacs's exec-path (where it looks for executables) and environment variables with your shell's environment.
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; UNDO TREE
;; The `undo-tree' package provides an advanced and visual way to
;; manage undo history. It allows you to navigate and visualize your
;; undo history as a tree structure, making it easier to manage
;; changes in your buffers.
(use-package undo-tree
  :defer t
  :ensure t
  :hook
  (after-init . global-undo-tree-mode)
  :init
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        ;; Increase undo limits to avoid losing history due to Emacs' garbage collection.
        ;; These values can be adjusted based on your needs.
        ;; 10X bump of the undo limits to avoid issues with premature
        ;; Emacs GC which truncates the undo history very aggressively.
        undo-limit 800000                     ;; Limit for undo entries.
        undo-strong-limit 12000000            ;; Strong limit for undo entries.
        undo-outer-limit 120000000)           ;; Outer limit for undo entries.
  :config
  ;; Set the directory where `undo-tree' will save its history files.
  ;; This keeps undo history across sessions, stored in a cache directory.
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/.cache/undo"))))


;; A minimalistic and highly performant completion UI for Emacs's minibuffer, improving how you interact with commands and file selections.
(use-package vertico
  :ensure t
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
   (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
   (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  ;;(marginalia-mode 1)
  :init
  (vertico-mode 1))


;; Enhances completion matching by allowing flexible, order-independent, and space-separated patterns for filtering candidates.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; A package that provides various interactive commands for searching, jumping, and navigating through buffers, files, and other Emacs data.
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)

;; A framework for context-aware actions, letting you perform operations on the "thing at point" (e.g., a file, function, URL) using a consistent interface.
(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Which-key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.5))

;;; Move Text
(use-package move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;; Commenting
(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

;; Fornat-all
(use-package format-all
  :ensure t)


;; A project management tool that helps you navigate, switch between, and perform actions across files within your projects.
(use-package projectile
  :ensure t
  :bind (("C-c p" . projectile-command-map))  ;; Bind the prefix for projectile commands
  :init
  (setq projectile-completion-system 'default) ;; Use default completion (integrates well with Vertico)
  :config
  (projectile-mode +1)
  ;; (setq projectile-project-search-path '("~/projects/")) ;; Set project search path
  (setq projectile-switch-project-action #'projectile-dired))  ;; Default action when switching projects

;; Integrates Projectile's commands with Consult's completion UI, offering a more powerful and interactive way to manage projects.
(use-package consult-projectile
  :after (consult projectile)
  :bind (("C-c p f" . consult-projectile-find-file)  ;; Use consult to find files in projects
         ("C-c p b" . consult-projectile-switch-to-buffer)  ;; Switch buffers within the project
         ("C-c p p" . consult-projectile-switch-project)))  ;; Switch projects using consult

;; Magit for git integration
(use-package magit
  :ensure t
  :defer t)


;; A parsing framework that provides accurate, syntax-aware structural editing and highlighting for various programming languages.
(use-package tree-sitter)
(use-package treesit-auto
  :ensure t
  :after emacs
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))


;;
;;          === Completion ===
;;

;; A lightweight and fast completion-at-point framework for Emacs, providing popup suggestions for code, words, and more.
(use-package corfu
  :ensure t
;; Optional customizations
  :init
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert) ; insert previewed candidate
  (corfu-preselect 'prompt)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-next)
              ([tab]        . corfu-next)
              ("S-TAB"      . corfu-previous)
              ([backtab]    . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET"        . nil))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)) ; Popup completion info

;; A "Completion At Point Extensions" package that unifies and enhances various completion sources within Emacs's completion framework (like Corfu).
(use-package cape
  :ensure t
  :defer 10
  :bind ("C-c f" . cape-file)
  :config
  ;; Make capfs composable
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)

  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; Emacs's official client for the Language Server Protocol (LSP), providing IDE-like features (e.g., completion, diagnostics, go-to-definition) by communicating with external language servers.
(use-package eglot
  :hook
  (sh-mode . eglot-ensure)
  (bash-ts-mode . eglot-ensure)
  (c-mode . eglot-ensure))


;; Use flycheck backends with flymake
(use-package flymake-flycheck
  :ensure t
  :after flymake
  :init
  (setopt flycheck-disabled-checkers '(python-mypy haskell-ghc haskell-hlint))
  :config
  (add-hook 'flymake-mode-hook 'flymake-flycheck-auto))

;; Install smartparens and enable it globally
(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode t)        ;; Enable smartparens globally
  (show-smartparens-global-mode t)  ;; Show matching pairs in all buffers
  (require 'smartparens-config))

;; Enable strict mode for specific languages (optional)
(add-hook 'c-mode-hook #'smartparens-strict-mode)
(add-hook 'c++-mode-hook #'smartparens-strict-mode)
(add-hook 'rust-mode-hook #'smartparens-strict-mode)
(add-hook 'zig-mode-hook #'smartparens-strict-mode)
(add-hook 'js-mode-hook #'smartparens-strict-mode)
(add-hook 'python-mode-hook #'smartparens-strict-mode)

;; Keybindings for navigation
(define-key smartparens-mode-map (kbd "C-M-f") 'sp-forward-sexp)
(define-key smartparens-mode-map (kbd "C-M-b") 'sp-backward-sexp)

;; A templating system that allows you to define and expand code snippets for various programming languages, speeding up common coding tasks.
(use-package yasnippet
  :config
  (yas-global-mode 1))
(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))


;; A major mode in Emacs specifically designed for editing web templates and multi-language files (like HTML with embedded CSS, JavaScript, or server-side code), providing advanced syntax highlighting and indentation.
(use-package web-mode
  :ensure t
  :defer t)
;;; c-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))


(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)

;; A major mode for editing Markdown files, offering specialized features for formatting, previewing, and navigating Markdown documents.
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
  '(custom-safe-themes
   '("0517759e6b71f4ad76d8d38b69c51a5c2f7196675d202e3c2507124980c3c2a3" "51fa6edfd6c8a4defc2681e4c438caf24908854c12ea12a1fbfd4d055a9647a3" "5a0ddbd75929d24f5ef34944d78789c6c3421aa943c15218bac791c199fc897d" "8363207a952efb78e917230f5a4d3326b2916c63237c1f61d7e5fe07def8d378" "6e13ff2c27cf87f095db987bf30beca8697814b90cd837ef4edca18bdd381901" "8526b699f18d2ed8ad2e63dda5dc7dbeaf5ed3d91bb8ec0238f5d4bcc7fd9057" "865f4769f56b8d2b5373ecbd5b82d6d67a6dd1037c1a473351fbf4723032f233" "d4d7039292ed380b0fb8c1535b5bc7cf2f2bf9ff745e33a0e1268a6680ba0d20" "a40703f9d1adb7ee1500d3c33ac4d62144675505ae7fe98b18a5d9ff325ee369" "0f691b0fef27fdeffb52131f21914b6819044659c785109060dbfb72d6b38246" "adb567dc2208b9e95ce3bc1930bf0e84a3eced91e674b4c35777e54650a60763" "eb49a00a049efee497cca4f56c70f807c58ef489cdc4216a034a7587d5ae6893" "c7951fc937039f8f1640fce55d97628d8b2cd124461d6a28dce13fcc29fbed1d" "7fb25688a73234177e66a36b5c8178feed7da7a970d4464f51a0165ffcbf1286" "882d6a5981fd85d9f987d31623e25e69b8d5635a53ab442f1a51e7c252790320" "f5bf1adb45632aad5eb2c627a82ddfe6d034bdd4c1777cf8f1967e3b6b1641ec" "7a778b45d321cf3340b3d762275e2c53be15445d7c753f19a6284c0974e7feeb" "cdfb10a03c37d4e6069d0a088262526d673233247f4042182da95460557410b6" "b81209c6dd9a73ad3f5760afb927210c7757442784e5fe36d0e056df62de5835" "84594f832ca8dadf65b2d155a92feed8545574b4d2843d3d49e7c059a61a418e" "0430ba14a3cc147f924a5e0d24c4fd21b377c6ebe2924855969023430705500c" "9ddf168f587b3e30e8e655f81fb0b8ed30fdb3e16217861e123fc9a62e9830e5" "1576495a064188b7b3017d16763288a6e9583a01f02773144b246ef56e64ec76" "32cffe674ed83acf350fde08b6144388f73a2013f901e340e50fd8fcc7b49cc4" "1ac1cfa4ee281f34f54964d12d59eeeed29c1b09b0d76ecd9cdd6f4edd73b3d7" "387f701b4e03c1628b2f193259f8c5b02c15e04d803e144c154ace1f8384909f" "498ce788d0564d1effb7fbd8d83c7bf636178e4ad63afa7e05d84e68503dda38" "ab3d891637ed949be4c5123d6146443f4855d22d7b57e6da43059515fcf314c8" "154a0469224ee6b1cb91796aec23a0d3ae76b50aced14af0e8352677c7482c0f" "847025d7513316abf78a6a26eb785d7979d0fa891cee2dc76d519220c30d043d" "a9fca58cd23e64cea6d114001003bf147d75fdbc8af98335e822ea705088f965" "cfb9139155392ffe48beba2f76e8b9a93a79729a3cd18feac428746c05f2dbd0" "54c3b844fe0e3076c4a20cde82d9e4890efff9831c7e88cd55f89c2b565cf2e2" "308ead333d5dfc7d64258a9d3d46f9e479e4b62bdf33a8ea8700423842cae32e" "b0fea725c1b6e74d1de532f3905b8ef46071f9e15940732223fc696438fee96f" "6018f08dd19c9fa55c348eb1793deb72624861bc79197f4dcb033243ce13af59" "f146b2935f915fc1f9cee018199fbb93c2887aed85c7051fb8dd57f5a05f123f" "f30abf72b7fdefea767d8035afbb44069e1b44f3aa516a3704395814013b8812" "94256a2952c7a6a77b4f290e6a16d1b2ded393591e7e7fc03edf8cfd34a9b55e" "bc09e03fcca486d34e0b04b7b10ed182058be75668335dae5688e864c89ee8b6" "f8a16292b06df595902fe9ff742af8b160d33106db91f69d4efba46e2f151d48" "b77fb7d89cf58597dcb14782df244553551d1009e885cba6ef487e3866450124" "1004b23037aa368429db2e84746306a9c20a45ba1fd49c8d92daada49515a0f8" "ad10e24741868fcfeedb932b4ce6b493a625df9e71fb23eac1077bd5825efa68" "cfadf4788ea4d5afb3966324037ece71687408ecfefe74ff649aa4f58621c80b" "855b8dee99b96b726a57790eb904544c623cb39caa0846c8afc008d6ee48aec1" "6e2ced785017da31e8da8dbcbb9e69beda4c3b87dd9ad2b1bb5da9f19240ec31" "882001d4237dfe3e84ceeeee697a0da77719c9ab4e85eca7bb43541815d458fc" "c3da4bc9704db159e601c727fe9c33945147749205bb4536ad11fb883faa96f9" "2f1157e7e30f85eb730a2d2c122b66491d48d32f6c92068970824d05b117ecad" "d6426f913bca40360889cba4aa25a6c02b67823a93b51e6db1b6a102b8a631e6" "94ac10e5261b9a32c9f1a7ef88f3fb89bfcbad843436aaaedc97c7975d8e6ab2" "92ef141d05dc078cfaae83a4d87d7d3ddbe7b30591e63ba19a57d1d35f9ab23f" "0deba21a79a993751cf1aa89e4d52feee50142e75f913088b3d8c20d000821e0" "df3d4f912f543ea8455e446f23c5d4d7ce76d01776a0a7239b444d73a2fc5184" "6ed98f47da7556a8ce6280346e5d8e1e25bede71dc5186aa2654b93bec42d2a6" "1cfbec19edafb831c7729be2f6454ec019c21b9a54b39b3bb5ec276a6b21d484" "3f48acc0b6cbedc3126e25eaad128f580d445654eab6602373061cb793ce58c7" "dea106ab256a8017a325f51f01b1131915989fa25db48eb831ffb18dac8ecd39" "308fc0c8cee43c5fccf3efa360c9cdf7d6bbbebc5c2f76850f1b1c8ac8fbaca0" "6ac2faf17d4d37b6f4bc08203b70e82f4b3b5ce76f102fb4802b3f6c74460743" "66678319ba8c4748f95ef7bd4014ad034edbc4fd2c3ca0a52c0bcd1ab8b910f3" "f40842bcefb042419edfee59dbbaedfc8995379864adbafded247185582d9681" "31cd256bcbfca6f2ef12acd3083d5e11c78f3d118f6eb5fa00f0e18a8078fa38" "d3e76a24fbdb051ea1ac68c7e8483c8eaf15f15aa90fe38093924cf01f799bf7" "2902694c7ef5d2a757146f0a7ce67976c8d896ea0a61bd21d3259378add434c4" "47fcd823a849d7e527f582c9e7c6af2aecd5ff12e67a14da5d5fe69853a6f573" "aa02aab622c14c08c6924138fed29225bb2aa57a50b976c6911d90b36c34d89c" "10c5b93ab81da5b92a6a5c3937e638b7a23550c04aa4251d2fec32c1d9475074" "7349fd2dd0671b4dd0fad1ad8d20f032b72b2b0dc34e7566f5e5bea5f045c038" "bf75aa3e5ee805a36b6667b1217b7d7fd8aa95cc38a08a6cf48f13be725ac122" "9777774c632c27aafcd20e969626f87177e3d3ff526badd4bec90b33ed3ab73b" "27dac7a05a4dabd15ee4fec7c881b172cb8464a11afcf3de6ffad3c61f20247a" "879bf3e29b1f88db6eea558a06ebef1ec34e568d89d7eb8f745eeb1a65ab1772" "cdb768021bf99e838364dd5e7fc22d9b6f790124c97be379a5bda4f900e50c26" "2ebd6217d74282fe204f58a64adea7d210c60a5cd11e57f9e435b01e35d2b028" "2e73ff29e0c8cafa854837c04e0de50ccc17ea5e5db0767cd2b5ee7707322b05" "47db66f76b42ba84674ba5c0ff9aaefbaa9425e597538cfa26f0f20b407cea1d" "34b1e5e7008f92d17faa00b36a51b4eeb5fa4e5c8f3c8aa7f6b353754ccd73d6" "800c29594ff735cadd9c93d1d5d25445e8228925c4f1149ee2d48d8b687fa5d7" "aa3fcb18cad987feb30f7c840fdce709c47ad862eec4331d014dd40474fbbe10" "9c204e727c8a05fb0aa9b065f0b15f483fb0a083e2b2f8b8ac5d89bf514def1b" "270cd94be3efd6208fc731862e1b7dbb1ad7fec585773bd7b19f7622cd758463" "71f01d164fbc76d7186e6f93e5820166cbecb5b98b41db6a480a9d202a0b1b6a" "8110bc7cd0a53c87b69e9233ff778c18e51acf04ccfcb0c2fb6f46958d125164" "3c3d4da72f9b26f0125280c3f5868776edbe6f53adcdc2f588e403e5a10da423" "9c564f780c6371b7eaa21c948b66a4f0caa47704dd0493c75465b7968a2e8a11" "427cc3110288c2aa479309dc649bd81a88000ded78aad301cc04a4ede196b824" "0a998d76c2fb27e3528b0d74a84ff80e5c89e1c42ff4e98c5a99b3a9cad0bfd0" "1de73eec00f3487bc463de2ea9147fff57efadb2c293283558f0ed916c10a38b" "3d9512412d5874972f9142a6c230258e33ff1168d1d21aa68d7a568f328a400b" "f700bc979515153bef7a52ca46a62c0aa519950cc06d539df4f3d38828944a2c" "e4dc0e82a5ce83408fd1d22b1483bbec42dd311d4b38cdc34f28ef3db4e873cd" "1d1f4f5b0f792f0bb1b8f944b8ed93b3b20bbebc4ba072c2b7daff82da23ae86" "da19739a11a46ef7c252d9132d0c2c08c269ef2840bb19b136d8d79e370ab1a5" "74797b7cbcc4356101a62037316149faa4935522775adaaa68972f7488361c0d" "33c4f1e69f2f266a0b8e006858039298e6ff00868048cbfb9e20d7e0e4d410c3" "711df73c2d73a038f3e4f9327fa96244f6b081a0ef631fafdc5d3a859d7257b7" "928d362455fcd7f6d333fee8778c672c83b42ac1f3c3cbd98f027097effd6263" "62f788d40caee9e8676257b58e364bbcdedad98f366f97b44e2fb7ab2f4ba652" "f4868f17f7c5f4ec9c9a5d7341856c1307c768e13211e8197d4f4793debe7ffd" "6e14d67edb9336686b4824223320cc7fa5e88fdf15fc030bd6c92ebaca9db963" "46c92c47f7f712908e02d49af76624d7cf828ca9c73131e3824324044e70a0a9" "ecd76ed4cdfc0534b90b663fb18afdd18bd29d7f40761f658d995c9a82f6490b" "58cf241518aa8217fc728302af7d0b59b271eb1a0c1808b6650c0fa8080cfa2b" "c43ad2492e064eb70e0e8cf1d073c9176037e321f0fde51df1d25150dbf51d19" "d1d0bd3d8be9acb87bbdcd1ed3f8d2597403db3f53a9d79560e0213d20b8d780" "91db2df9490180a006964179f3aa4fcbc6bbf63cdcba189b41ea1ff5a606df33" "14e168ce25a773e52e9032640d8cc34293f74fc599230340587fd17c96c2c97a" "a24e023c71f74e8c6a79068947d706f68a566b49a774096671a5cbfe1fb90fc6" "bd17d0f6495c2626c493322ff37c64dc76ddb06c10dbadfead6a4f92775f00f3" "7bf34d114ec815e05a1ecb7f1acfd61ef453bfd27d12cc4c2babfa08ca1314da" "9cda0155ffd0cddac60729f5e821ba7955e1623ec7bcb12ca8e7219c33747e0f" "c8863bf29722cf36c5d293ac723fe9698e16f778326d791516dd717951ea8cd6" "aad354ecde2ba0f811443573c9e6b8a45cd4a1d413cfbe7e3766b7598359a68e" "f756b074a9c12bd01cdc652aae731ec6dc219d1875893e9badbd7a856714d7da" "48c784475c565d241738f10c1ba52284ce2b1588394ef240ada937f132b8b3c9" "17df42390ed61ea41f7e3c30a98bc5ed268e7bfd9d3b781d3f424fd0b80fae0e" "661f3ff21fd9adc9facde2b11cbdeef5f1f2d482e98a456b11922bf55653ceac" "b15bf9cabdd891f0c163d1b914e901d0d9f8f74ad4075b2b8e68a8f35247f82b" "9e1433735d6a571f65319527853bf5eeee20f61749d2b82a8dd88e3f78e6749b" "7b599b6957c7b50bdb7b2595d9bed7ae1926937129201f55e0b3909808ba8afe" "689e6661c79e93fd14d1765850522dbfcb3e49e8f15266516b64cf4f04649a4a" "b54b64550215242ad351a5c7219f1b30d2cec3d1710a2121862ae6d51c7a1c12" "75863c7d5dca60cfb927b5de5c8f39b2a9d7756c5f346990e4423aba33cb3a9d" "a0724a2dbf003213ef1bd93c7df0f07a5368399554078fc85819b2f9f6152101" "4c97de81c29f72109619ee5d755c8a8fd6890903d65124894a0ab412e45de364" "9a06ccf9adfe489bda1ba63c7e622c0f31e2b22f6b4a27118dcd4e8fbad6a282" "8b18b903355488061707df445acc97309acf4977ba40ba58bca110036e235097" "b2a3b2bbe9aea795fd23ecb46ba1fbd28988b7d528b6a1f6e7f8a1122a9025aa" "e57ad9eb8465dcb6b85eeb2f1be11a37aee7b1f24e5f99155b39ff0679e664d5" "5d67552ed2e841039034dc8245ee1746ab4f00614366ca7018386041f9b0a96f" "720e8768e7a9bbda94758aba8ef29314fdc51a3e22ac8146726c752fa0a97221" "1fc299974daa270e19d1b206ec40aab3a0ce35e7c6a7d389b156bcd411e41a3c" "93fbbb7d5c6d185ea0a4ff318208b9c8d9b23ea03041f3d9786a1b03e8fae227" "b58b5aa5664a927866daa481ae5f0795423ed3982ce5f64e56c4106261dbd13e" "5d205766ba4c831730cf88aaba6fa76cd77af631f8572cd85b661766f25fd206" "8970a9dac879f60eee389caed568e9e3430a577604126de1540af5c41f5aaa60" "f7fe70ecf059f036813b327285e615438802980b8a477a3bbe4733aa0176c4fd" "0ac7e8c9336aea2f73b28ecfd1f9fcfc64eeca0585aa071f2f67ff716dcb9c6c" "a50d025e0eb240f59748be7fcd3251a4b0372071546443e57f701f8a8531b764" "e48fc060df74469f0813aaeca2d3556693c26c8a3d7d6d80c9eb7bd43a087d06" "038766672f29210977a0620789252a9a51ad9111fdf6617722aecb611a78275f" "a7d2594e876652f2de36e4ae18b3ffeedf89add6de587283bd6d1a09258fbc65" "12fd37b8dc24e20343b2cf7f94e15f8775a4d1d16db4af7e44f922e6567edae7" "f97a59acd14accb731637967de96b5c88f89ddbc49ba5adb215cbe88f7dd743b" "9f39afd4c4a270b3eddc018b1cd8bec67b738baa864329d65e095f3870024944" "6d7c2881e47ee6ead20f43d6368b2c9b9a1fedbd7c9f0604de15b4c11d5b4841" "b5a7b3e2fd711abcb37bf0f242ed77d7a911abcb2cbaeaed8833d7818f43ce60" "deea4f8ef106dd1d8746a6fdccf42cf504982605bd53024b0f56c4d3e4a108e4" "4bc81db882f65e7fad8fdadb6ce3bbc4447667258174347ab4a0e88768af661b" "b19d77aca9b695b1b6219e949917160cecfa009e9901649c6b98b5d919492fee" "9efdc5016142e274cb29e21c8bd88f7a6e3fd4737eac3274a60593041d7f8419" "e223120256455daba01b6c68510b48fac813acab05c314510e47aea377b23634" "039112154ee5166278a7b65790c665fe17fd21c84356b7ad4b90c29ffe0ad606" "34de8dfc73248c0ede0efc847d88fbbaf9a247dd3109343d9c4b8a093c816410" "eb84dd5afbf9a2f534f79e55508cb3b14bb629f91f5b5a39677bacbf50f90bf6" "3f106811a7502dcca1b7b54686d3fafb2210cb9e27a8b5acbb71b8987a58fe60" "4ca2b8e7ce031be552d1e896f82607af064ac4abe402868dff98759f5970e2b4" "8de91e43d21b9d5cb79a146b267d29d3e377ed73888324912c7f6e514a76e5d7" "e0b2f460b6bee1d7a09b90635b2995e801ff5ac1a7aa66ea9c5674cd0bf1bb7a" "de385583975ed8e83b71b212b3094ee74785834718e2413bc3acff36224fba8d" "cbc8efdcd8e957c9ede1b4a82fed7fa1f3114ff6e7498c16f0cccb9509c1c17c" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
