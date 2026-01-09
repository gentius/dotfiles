;;; discarded.el --- backup of old configs -*- lexical-binding: t; -*-
;;; Commentary:
;; Discarded init.el configurations archived here for reference

;;; Code:
;; from early-init.el
(setq initial-frame-alist
      (let ((loffset (/ (display-pixel-width) 2)))
        `((top . 50) (left . ,loffset) (width . 90) (height . 40))))

(use-package emacs
  :ensure nil
  :bind
  (;; these two worked mostly OK, but they have issues in some modes
   ("C-c C-c" . kill-ring-save)
   ("C-v" . yank))

  :config
  (setopt org-adapt-indentation t
          org-hide-leading-stars t
          org-odd-levels-only t)
  (when (display-graphic-p)
    (define-key key-translation-map (kbd "ESC") (kbd "C-g")) ; ESC ESC ESC issues!
    ))
  

(use-package modus-themes
  :ensure t
  :init
  (setq modus-themes-mode-line '(accented borderless)
        modus-themes-region '(bg-only)
        modus-themes-italic-constructs t
        modus-themes-completions (quote
                                  ((matches . (background extrabold intense))
                                   (selection . (extrabold intense))
                                   (popup . (extrabold intense))))

        modus-themes-common-palette-overrides
        '((bg-mode-line-active bg-sage)
          (fg-mode-line-active fg-main)
          (border-mode-line-active green-cooler))
        ;; Keep only first heading as bold, others regular
        modus-themes-headings
        '((1 . t)
          (t . (regular))))
  (set-face-attribute 'mode-line nil :family "Segoe UI")
  (set-face-attribute 'mode-line-inactive nil :family "Segoe UI"))

(use-package company
  :ensure t
  :hook (prog-mode . company-mode))

;; didn't really use it that often, so not worth it for the conflict with outline-minor-mode-cycle t
(use-package adjust-parens
  :ensure t
  :hook (emacs-lisp-mode clojure-mode))

(use-package hotfuzz
  :ensure t
  :config
  (setq completion-styles '(hotfuzz)))

(use-package bookmark+
  :ensure (bookmark+ :repo "https://github.com/emacsmirror/bookmark-plus.git"))

(use-package consult
  :ensure t
  :config
  (defun rawfile-caddr (args)
    (if (and (cadr args)
             (not (caddr args))
             (not (cadddr args)))
	(append args '('rawfile))
      args))
  (advice-add 'find-file-noselect :filter-args 'rawfile-caddr))

;;; discarded.el ends here
