;; -*- lexical-binding: t; -*-

;; because I'm using a different package manager
(setq package-enable-at-startup nil)

;; presumably effective on Windows especially
(setq load-path-filter-function #'load-path-filter-cache-directory-files)
