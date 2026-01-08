;; -*- lexical-binding: t; -*-
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1) ; "M-`" still useable to explore new modes' menu

;; because I'm using a different package manager
(setq package-enable-at-startup nil)

;; presumably effective on Windows especially
(setq load-path-filter-function #'load-path-filter-cache-directory-files)
