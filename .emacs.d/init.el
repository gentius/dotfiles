;;; init.el --- Custom init file -*- lexical-binding: t; -*-

;;; Commentary:
;; Built bit-by-bit, parts of it after trying out things
;; like technomancy better defaults.

;;; Code:
;; Doom Emacs inspired startup-time improvement (reverted at the end)
(progn (defvar last-file-name-handler-alist file-name-handler-alist)
       (setq gc-cons-threshold 402653184
             gc-cons-percentage 0.6
             file-name-handler-alist nil))

;; Setup
(add-to-list 'load-path (expand-file-name "settings" user-emacs-directory))

;; Load the Elpaca installer, and install use-package support
(progn (require 'elpaca-installer)
       (elpaca-no-symlink-mode)
       (elpaca elpaca-use-package
         (elpaca-use-package-mode)))

;; Loads everything when running as daemon
(setopt use-package-always-demand (daemonp))

;; TIP: uncomment and use (use-package-report) after startup
(setopt use-package-compute-statistics t)

(use-package emacs
  :ensure nil
  :init
  (defun gk-kill-buffer (arg)
    (interactive "P")
    (if arg
        (call-interactively 'kill-buffer)
      (kill-buffer)))
  
  (defun gk-other-window ()
    (interactive)
    (if (one-window-p)
        (progn (split-window-right) (other-window 1))
      (other-window 1)))

  (defun gk-slurp-sexp ()
    "If the point is after a closing paren, slurp the next sexp into the former."
    (interactive)
    (when (member (preceding-char) '(?\) ?\} ?\]))
      (save-excursion
        (delete-horizontal-space)
        (kill-sexp)
        (if (string-match-p "[[:graph:]]+" (current-kill 0))
            (progn
              (backward-char)
              (unless (member (preceding-char) '(?\( ?\{ ?\[))
                (insert " "))
              (yank))
          (yank)))))

  (defun gk-delete-indentation-forward () (interactive) (delete-indentation t))

  :hook
  ((prog-mode . electric-pair-mode)
   (prog-mode . display-line-numbers-mode)
   (text-mode . visual-line-mode))

  :bind
  ( :map global-map
    ("C-x C-b" . ibuffer)
    ("C-x k" . gk-kill-buffer)
    ("M-o" . gk-other-window)
    ("M-/" . hippie-expand)
    ;; these two worked mostly OK, but they have issues in some modes
    ;; ("C-c C-c" . kill-ring-save)
    ;; ("C-v" . yank)
    ("M-n" . scroll-up-command)
    ("M-p" . scroll-down-command)
    ("C-c r" . raise-sexp)
    ("C-c s" . gk-slurp-sexp)
    ("C-; C-p" . delete-indentation)
    ("C-; C-n" . gk-delete-indentation-forward))

  :config

  ;; (global-visual-wrap-prefix-mode 1)
  
  (when (display-graphic-p)
    (keymap-global-set "C-z" 'undo)
    ;; (define-key key-translation-map (kbd "ESC") (kbd "C-g")) ; ESC ESC ESC issues!
    )

  (when (eq system-type 'windows-nt)
    (setq grep-command "rg -nS --no-heading "
          grep-use-null-device nil))

  (setq-default truncate-lines t) ; By default, don't wrap lines.

  ;; [tool/menu/scroll]-bar-mode configured in early-init.el
  (setq visible-bell t)
  (setq column-number-mode t)
  (setq inhibit-splash-screen t)
  (setq use-dialog-box nil) ; Don't pop up UI dialogs when prompting

  (recentf-mode 1)
  (save-place-mode 1)

  (winner-mode 1)
  
  (setq history-length 25)

  ;; vertico recommended
  (setq context-menu-mode t
        enable-recursive-minibuffers t
        read-extended-command-predicate #'command-completion-default-include-p
        minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))

  (global-auto-revert-mode 1) ; Watch/refresh buffer if file is changed elsewhere
  (setq global-auto-revert-non-file-buffers t) ; same for Dired and other buffers

  (setq ispell-program-name "aspell")
  
  (setq backup-directory-alist ; anti-littering
        `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage) ; unclutter init.el
  
  ;; Selectively taken from technomancy better-defaults.el
  (setq-default indent-tabs-mode nil)
  (setq save-interprogram-paste-before-kill t
        apropos-do-all t
        mouse-yank-at-point t
        require-final-newline t
        load-prefer-newer t
        backup-by-copying t
        frame-inhibit-implied-resize t
        read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t
        ediff-window-setup-function 'ediff-setup-windows-plain)

  (progn (set-language-environment "UTF-8")
         (setq default-input-method nil)) ; see doom emacs
  
  (add-to-list 'default-frame-alist
               '(font . "Fira Code Retina 10"))
  ) ; end `use-package emacs` ;;;;;;;;;;;;;;;;;;;;

(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-operandi-tinted t)
  (defun gk-toggle-theme ()
    (interactive)
    (load-theme
     (if (equal (car custom-enabled-themes) 'modus-operandi-tinted)
         'modus-vivendi-tinted
       'modus-operandi-tinted))))

(use-package org
  :ensure nil
  :custom (org-ellipsis " ↘"))

(use-package transient
  :ensure t)

(use-package magit
  ;; :after (transient)
  :ensure t
  :init
  (defun gk-compare-cl-json ()
    "Compares the CL json configuration file at point for meaningful
differences considering the provided primary keys. (discarding
auto-updating fields)"
    (interactive)
    (async-shell-command
     (concat "compare-cl-json "
             (magit-current-file) " "
	     (magit-current-file) " "
	     (read-string "Primary keys: " "ModelId Trigger")))))

(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode)
  :bind ( :map hs-minor-mode-map
          ("C-; C-f" . hs-toggle-hiding)))

(use-package outline
  :ensure nil
  :hook (prog-mode . outline-minor-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer) ; orig. switch-to-buffer
         )
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  (tab-always-indent 'complete))

(use-package paren-face
  :ensure t
  :config
  (global-paren-face-mode 1))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package sql-duckdb
  :ensure nil
  :after (sql)
  :load-path "local-packages/sql-duckdb")

(use-package flycheck
  :ensure t
  :hook ((after-init . global-flycheck-mode)
         (prog-mode . flycheck-mode)))

(use-package clojure-mode
  :ensure t
  :custom
  (clojure-toplevel-inside-comment-form t)
  (clojure-align-forms-automatically t))

(use-package flycheck-clj-kondo
  :ensure (:host github :repo "borkdude/flycheck-clj-kondo")
  :after clojure-mode)

(use-package cider
  :ensure t
  :config
  (define-key cider-mode-map (kbd "C-c C-c") nil) ; so it remains 'copy'
  (setq cider-use-tooltips nil
        cider-download-java-sources t
        cider-enable-nrepl-jvmti-agent t))

(use-package clj-deps-new
  :ensure t)

(use-package adjust-parens
  :ensure t
  :hook (emacs-lisp-mode clojure-mode))

(use-package aggressive-indent
  :ensure t
  :hook (emacs-lisp-mode clojure-mode))

(use-package ess
  :ensure t
  :hook (ess-r-mode . outline-minor-mode))

;; Revert of Doom emacs inspired start-up time improvement:
;; after startup, it is important you reset this to some reasonable default
;; A large gc-cons-threshold will cause freezing and stuttering during
;; long-term interactive use. I find these are nice defaults:
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 16777216
                  gc-cons-percentage 0.1
                  file-name-handler-alist last-file-name-handler-alist)))
(put 'dired-find-alternate-file 'disabled nil)

;; (provide 'init)
;;; init.el ends here
