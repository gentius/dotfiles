;;; Doom emacs inspired startup-time improvement (reverted at the end)
(defvar last-file-name-handler-alist file-name-handler-alist)
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      file-name-handler-alist nil)

(add-to-list 'load-path (expand-file-name "settings" user-emacs-directory))

;;; Load the Elpaca installer, and install use-package support
(require 'elpaca-installer)
(elpaca-no-symlink-mode)
(elpaca elpaca-use-package
  (elpaca-use-package-mode))


(use-package emacs
  :ensure nil
  :init
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
    ("C-c C-c" . kill-ring-save)
    ("C-v" . yank)
    ("M-n" . scroll-up-command)
    ("M-p" . scroll-down-command)
    ("C-c r" . raise-sexp)
    ("C-c ." . gk-slurp-sexp)
    ("C-; C-p" . delete-indentation)
    ("C-; C-n" . gk-delete-indentation-forward)) 

  :config
  
  (when (display-graphic-p)
    (define-key key-translation-map (kbd "ESC") (kbd "C-g")))

  (setq visible-bell t)
  (setq column-number-mode t)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (setq use-dialog-box nil) ; Don't pop up UI dialogs when prompting

  (recentf-mode 1)
  (save-place-mode 1)
  
  (icomplete-vertical-mode 1)
  
  (setq history-length 25)
  (savehist-mode 1)
  
  (global-auto-revert-mode 1) ; Watch/refresh buffer if file is changed elsewhere
  (setq global-auto-revert-non-file-buffers t) ; same for Dired and other buffers

  (setq ispell-program-name "aspell")
  
  (setq backup-directory-alist ; anti-littering
	`(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage) ; unclutter init.el
  
  ;; Selectively taken from technomancy better-defaults.el
  (setq save-interprogram-paste-before-kill t
	apropos-do-all t
	mouse-yank-at-point t
	require-final-newline t
	load-prefer-newer t
	backup-by-copying t
	read-file-name-completion-ignore-case t
	read-buffer-completion-ignore-case t
	completion-ignore-case t
	ediff-window-setup-function 'ediff-setup-windows-plain)

  (setq org-adapt-indentation t
	org-hide-leading-stars t
	org-odd-levels-only t)
  
  (progn (set-language-environment "UTF-8")
	 (setq default-input-method nil)) ; see doom emacs
  
  (add-to-list 'default-frame-alist
	       '(font . "Fira Code Retina 10"))
  ) ; end `use-package emacs` ;;;;;;;;;;;;;;;;;;;;


(use-package transient
  :ensure t)


(use-package magit
  :after (transient) 
  :ensure t
  :init
  (defun gk-cl-json-git-diff ()
    "Compares the CL json configuration file at point and if there are
meaningful differences, opens a csv file with only the objects with such differences.

Placeholder implementation. Use shell-command eventually."
    (interactive)
    (eshell-command
     (concat "echo "
	     (magit-current-file)))))


(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode)
  :bind ( :map hs-minor-mode-map 
	  ("C-; C-f" . hs-toggle-hiding)))


(use-package modus-themes
  :ensure t
  :init
  (setq modus-themes-mode-line '(accented borderless)
	modus-themes-region '(bg-only)
	modus-themes-italic-constructs t
	modus-themes-completions (quote
				  ((matches . (background extrabold intense))
				   (selection . (extrabold intense))
				   (popup . (extrabold intense)))))
  (set-face-attribute 'mode-line nil :family "Segoe UI")
  (set-face-attribute 'mode-line-inactive nil :family "Segoe UI")
  (setq modus-themes-common-palette-overrides
	'((bg-mode-line-active bg-sage)
	  (fg-mode-line-active fg-main)
	  (border-mode-line-active green-cooler)))
  :config
  (load-theme 'modus-operandi t))


(use-package company
  :ensure t
  :hook (prog-mode . company-mode))


(use-package hotfuzz
  :ensure t
  :config
  (setq completion-styles '(hotfuzz)))


(use-package paren-face
  :ensure t
  :config
  (global-paren-face-mode 1))


(use-package sql-duckdb
  :ensure nil
  :after (sql) 
  :load-path "local-packages/sql-duckdb")


(use-package flycheck-clj-kondo
  :ensure (:host github :repo "borkdude/flycheck-clj-kondo")
  :config
  (setq flycheck-check-syntax-automatically '(mode-enabled save)))


(use-package clojure-mode
  :ensure t
  :config
  (setq clojure-toplevel-inside-comment-form t
	clojure-align-forms-automatically t))


(use-package cider
  :ensure t
  :after (clojure-mode)
  :config
  (setq cider-use-tooltips nil
        cider-download-java-sources t
        cider-enable-nrepl-jvmti-agent t)
  (define-key cider-mode-map (kbd "C-c C-c") nil) ; so it remains 'copy'
  (require 'flycheck-clj-kondo))


(use-package adjust-parens
  ;; :disabled
  :ensure t
  :hook (emacs-lisp-mode clojure-mode))


(use-package aggressive-indent
  :ensure t
  :hook (emacs-lisp-mode clojure-mode))


;;; Revert of Doom emacs inspired start-up time improvement
;; after startup, it is important you reset this to some reasonable default
;; A large gc-cons-threshold will cause freezing and stuttering during
;; long-term interactive use. I find these are nice defaults:
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold 16777216
		  gc-cons-percentage 0.1
		  file-name-handler-alist last-file-name-handler-alist)))
(put 'dired-find-alternate-file 'disabled nil)

