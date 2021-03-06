;;; packages.el --- Install and configure smax packages
;;; Commentary:
;;
;; This is a starter kit for smax. This package provides a
;; customized setup for emacs that we use daily for scientific
;; programming and publication.
;;
;; see https://github.com/jwiegley/use-package for details on use-package


;;; Code:

(setq use-package-always-ensure t)

;; * org-mode
;; load this first before anything else to avoid mixed installations
(use-package org-plus-contrib
  :mode ("\\.org\\'" . org-mode)
  :diminish outline-minor-mode
  :init
  ;; Use the current window for C-c ' source editing
  (setq org-src-window-setup 'current-window
        org-support-shift-select t)

  ;; I like to press enter to follow a link. mouse clicks also work.
  (setq org-return-follows-link t)
  :bind
  (("C-c l" . org-store-link)
   ("C-c L" . org-insert-link-global)
   ("C-c o" . org-open-at-point-global)
   ("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("s-y" . org-mark-ring-goto)
   ("H-." . org-time-stamp-inactive)))


;; * Other packages

(use-package tex
  :ensure auctex)


;; Make cursor more visible when you move a long distance
;; (use-package beacon
;;   :diminish beacon-mode
;;   :config
;;   (beacon-mode 1))

(use-package bookmark
  :init
  (setq bookmark-default-file (expand-file-name "user/bookmarks" smax-dir)
    bookmark-save-flag 1))


(use-package bookmark+
  :init
  :config
  (progn (setq bookmark-version-control t)))


;; Potential for commandline scripts using emacs
(use-package commander
  :disabled t)


(use-package swiper
  :bind
  ("C-s" . counsel-grep-or-swiper)
  :diminish ivy-mode
  :config
  (ivy-mode))

(use-package counsel
  :init
  (require 'ivy)
  (setq projectile-completion-system 'ivy)
  (setq ivy-use-virtual-buffers t)
  ;; default pattern ignores order.
  (setf (cdr (assoc t ivy-re-builders-alist))
        'ivy--regex-ignore-order)
  :bind
  (("M-x" . counsel-M-x)
   ("C-x b" . ivy-switch-buffer)
   ("C-x C-f" . counsel-find-file)
   ("C-h f" . counsel-describe-function)
   ("C-h v" . counsel-describe-variable)
   ("C-h i" . counsel-info-lookup-symbol)
   ("<f8> r" . ivy-resume)
   ("<f8> l" . counsel-load-library)
   ("<f8> g" . counsel-git-grep)
   ("<f8> a" . counsel-ag)
   ("<f8> p" . counsel-pt)
   )

  :diminish ""
  :config
  (progn
    (counsel-mode)

    (define-key ivy-minibuffer-map (kbd "M-<SPC>") 'ivy-dispatching-done)

    ;; C-RET call and go to next
    (define-key ivy-minibuffer-map (kbd "C-<return>")
      (lambda ()
        "Apply action and move to next/previous candidate."
        (interactive)
        (ivy-call)
        (ivy-next-line)))

    ;; M-RET calls action on all candidates to end.
    (define-key ivy-minibuffer-map (kbd "M-<return>")
      (lambda ()
        "Apply default action to all candidates."
        (interactive)
        (ivy-beginning-of-buffer)
        (loop for i from 0 to (- ivy--length 1)
              do
              (ivy-call)
              (ivy-next-line)
              (ivy--exhibit))
        (exit-minibuffer)))

    ;; s-RET to quit
    (define-key ivy-minibuffer-map (kbd "s-<return>")
      (lambda ()
        "Exit with no action."
        (interactive)
        (ivy-exit-with-action
         (lambda (x) nil))))

    (define-key ivy-minibuffer-map (kbd "?")
      (lambda ()
        (interactive)
        (describe-keymap ivy-minibuffer-map)))

    (define-key ivy-minibuffer-map (kbd "<left>") 'ivy-backward-delete-char)
    (define-key ivy-minibuffer-map (kbd "C-d") 'ivy-backward-delete-char)))

;; Provides functions for working on lists
(use-package dash)
(use-package dash-functional)

(use-package elfeed)



;; Provides functions for working with files
(use-package f)

(use-package flx)

(use-package helm
  :init (setq helm-command-prefix-key "C-c h")
  :bind
  ("<f7>" . helm-recentf)
  ;; ("M-x" . helm-M-x)
  ;; ("M-y" . helm-show-kill-ring)
  ;; ("C-x b" . helm-mini)
  ;; ("C-x C-f" . helm-find-files)
  ;; ("C-h C-f" . helm-apropos)
  :config
  (add-hook 'helm-find-files-before-init-hook
        (lambda ()
          (helm-add-action-to-source
           "Insert path"
           (lambda (target)
         (insert (file-relative-name target)))
           helm-source-find-files)

          (helm-add-action-to-source
           "Insert absolute path"
           (lambda (target)
         (insert (expand-file-name target)))
           helm-source-find-files)

          (helm-add-action-to-source
           "Attach file to email"
           (lambda (candidate)
         (mml-attach-file candidate))
           helm-source-find-files)

          (helm-add-action-to-source
           "Make directory"
           (lambda (target)
         (make-directory target))
           helm-source-find-files))))


(use-package helm-bibtex)

(use-package helm-projectile
  :init
  :config
  (require 'helm-projectile)
  (helm-projectile-on))

(use-package help-fns+)

;; Functions for working with hash tables
(use-package ht)

(use-package htmlize)

(use-package hy-mode)

(use-package hydra
  :init
  (setq hydra-is-helpful t)

  :config
  (require 'hydra-ox))

(use-package ivy-hydra)

(use-package jedi)

(use-package jedi-direx)

;; Superior lisp editing
(use-package lispy
  :diminish lispy-mode
  :config
  (dolist (hook '(emacs-lisp-mode-hook
                  hy-mode-hook))
    (add-hook hook
              (lambda ()
                (lispy-mode)
                (eldoc-mode)))))



;; Templating system
;; https://github.com/Wilfred/mustache.el
(use-package mustache)

;; this is a git submodule
(use-package ob-ipython
  :ensure t
  :init)

(use-package ov)

;; this is a git submodule
(use-package org-ref
  :ensure t
  :init

  (setq bibtex-autokey-year-length 4
        bibtex-autokey-name-year-separator "-"
        bibtex-autokey-year-title-separator "-"
        bibtex-autokey-titleword-separator "-"
        bibtex-autokey-titlewords 2
        bibtex-autokey-titlewords-stretch 1
        bibtex-autokey-titleword-length 5)
  (define-key global-map (kbd "s-/") 'org-ref-bibtex-hydra/body)
  )


;; https://github.com/bbatsov/projectile
(use-package projectile
  :init (setq projectile-cache-file
              (expand-file-name "user/projectile.cache" conf-dir)
              projectile-known-projects-file
              (expand-file-name "user/projectile-bookmarks.eld" conf-dir))
  :bind
  ("<f5>" . projectile-compile-project)
  ("<f6>" . next-error)
  ("C-c pp" . projectile-switch-project)
  ("C-c pb" . projectile-switch-to-buffer)
  ("C-c pf" . projectile-find-file)
  ("C-c pg" . projectile-grep)
  ("C-c pk" . projectile-kill-buffers)
  ;; nothing good in the modeline to keep.
  :diminish ""
  :config
  (define-key projectile-mode-map (kbd "<f2> p") 'projectile-command-map)
  (projectile-global-mode)
  (defun malb/projectile-ignore-projects (project-root)
    (progn
      (or (file-remote-p project-root)
          (and  (string-match (rx-to-string `(: bos "/tmp/" ) t)
                              project-root) t))))


  (setq projectile-make-test-cmd "make check"
        projectile-ignored-project-function #'malb/projectile-ignore-projects
        projectile-switch-project-action 'helm-projectile
        projectile-mode-line  '(:eval (format "\xf07c[%s]" (projectile-project-name))))
  )

(use-package pydoc)

(use-package rainbow-mode)

(use-package recentf
  :init
  :diminish recentf-mode
  :config
  (require 'cl)

  (defvar my-recentf-list-prev nil)

  (defadvice recentf-save-list
      (around no-message activate)
    "If `recentf-list' and previous recentf-list are equal,
do nothing. And suppress the output from `message' and
`write-file' to minibuffer."
    (unless (equal recentf-list my-recentf-list-prev)
      (flet ((message (format-string &rest args)
                      (eval `(format ,format-string ,@args)))
             (write-file (file &optional confirm)
                         (let ((str (buffer-string)))
                           (with-temp-file file
                             (insert str)))))
        ad-do-it
        (setq my-recentf-list-prev recentf-list))))

  (defadvice recentf-cleanup
      (around no-message activate)
    "suppress the output from `message' to minibuffer"
    (flet ((message (format-string &rest args)
                    (eval `(format ,format-string ,@args))))
      ad-do-it))
  (setq recentf-auto-cleanup 10)
  (run-with-idle-timer 30 t 'recentf-save-list)
  (recentf-mode 1)
  (setq recentf-exclude
        '("COMMIT_MSG" "COMMIT_EDITMSG" "github.*txt$"
          ".*png$" "\\*message\\*" "auto-save-list\\*"))
  (setq recentf-max-saved-items 7000)
  )


;; Functions for working with strings
(use-package s)

(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t)
  (setq sml/theme 'light)
  (sml/setup))


;; keep recent commands available in M-x
(use-package smex)

(use-package undo-tree
  :diminish undo-tree-mode
  :config (global-undo-tree-mode))


;; * Smax packages

;; ** General
(use-package smax
  :ensure nil
  :load-path conf-dir
  :init (require 'smax))

(use-package key-chord
  :ensure t
  :config (progn
            (setq key-chord-one-key-delay 0.2
                  key-chord-two-keys-delay 0.1)
            (key-chord-mode 1)))

;; ** Appearance
(use-package mk-highlight-line
  :ensure nil
  :load-path conf-dir
  :init
  :config
  (require 'mk-highlight-line)
  (mk-highlight-line-mode           1) ; highlight lines in list-like buffers
  )

(defvar malb/popup-windows '("\\`\\*helm flycheck\\*\\'"
                             "\\`\\*Flycheck errors\\*\\'"
                             "\\`\\*helm projectile\\*\\'"
                             "\\`\\*Helm all the things\\*\\'"
                             "\\`\\*Helm Find Files\\*\\'"
                             "\\`\\*Help\\*\\'"
                             "\\`\\*ielm\\*\\'"
                             "\\`\\*Synonyms List\\*\\'"
                             "\\`\\*anaconda-doc\\*\\'"
                             "\\`\\*Google Translate\\*\\'"
                             "\\` \\*LanguageTool Errors\\* \\'"
                             "\\`\\*Edit footnote .*\\*\\'"
                             "\\`\\*TeX errors*\\*\\'"
                             "\\`\\*mu4e-update*\\*\\'"
                             "\\`\\*prodigy-.*\\*\\'"
                             "\\`\\*Org Export Dispatcher\\*\\'"
                             "\\`\\*Helm Swoop\\*\\'"
                             "\\`\\*Backtrace\\*\\'"))

(dolist (name malb/popup-windows)
  (add-to-list 'display-buffer-alist
               `(,name
                 (display-buffer-reuse-window
                  display-buffer-in-side-window)
                 (reusable-frames . visible)
                 (side            . bottom)
                 ;; height only applies when golden-ratio-mode is off
                 (window-height   . 0.3))))
(defun malb/quit-bottom-side-windows ()
  "Quit side windows of the current frame."
  (interactive)
  (dolist (window (window-at-side-list))
    (delete-window window)))

(key-chord-define-global "qq" #'malb/quit-bottom-side-windows)

(use-package golden-ratio
  :ensure t
  :diminish golden-ratio-mode
  :config (progn

            (require 'ispell)
            (setq golden-ratio-adjust-factor 1.0
                  golden-ratio-exclude-modes '(imenu-list-major-mode
                                               eshell-mode
                                               pdf-view-mode
                                               mu4e-view-mode
                                               mu4e-main-mode
                                               mu4e-headers-mode
                                               calendar-mode
                                               compilation-mode))

            (defun malb/golden-ratio-inhibit-functions ()
              (cond
               ;; which function is exempt
               ((bound-and-true-p which-key--current-page-n))
               ;; helm is exempt
               ((bound-and-true-p helm-alive-p))
               ;; embrace is exempt
               ((eq this-command 'embrace-commander))
               ;; if ispell is running let's not golden ratio
               ((get-buffer ispell-choices-buffer))
               ;; any olivetti mode buffer disables gr
               ;; we also block if any buffer has inhibit major-mode not only target
               (t (catch 'inhibit
                    (dolist (window (window-list))
                      (with-current-buffer (window-buffer window)
                        (if (or (memq major-mode golden-ratio-exclude-modes)
                                (bound-and-true-p olivetti-mode))
                            (throw 'inhibit t))))
                    (throw 'inhibit nil)))))

            (setq golden-ratio-exclude-buffer-regexp malb/popup-windows)

            (setq golden-ratio-inhibit-functions '(malb/golden-ratio-inhibit-functions))))
;; ** Version Control
(use-package smax-vc
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-vc))
;; ** Editing
(use-package smax-editing
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-editing))
;; ** Programming

(use-package smax-lisp
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-lisp))

(use-package smax-python
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-python))

(use-package smax-r
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-r))

(use-package smax-haskell
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-haskell))

(use-package smax-c
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-c))

;; ** Budgeting
(use-package smax-hledger
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-hledger))
;; ** Navigation
(use-package smax-navy
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-navy))

;; ** LaTeX
(use-package smax-latex
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-latex))
;; ** Etc
(use-package smax-mode
  :ensure nil
  :load-path conf-dir
  :init (require 'smax-mode)
  :config (smax-mode))

(use-package smax-org
  :ensure nil
  :load-path conf-dir
  :bind
  ("s--" . org-subscript-region-or-point)
  ("s-=" . org-superscript-region-or-point)
  ("s-i" . org-italics-region-or-point)
  ("s-b" . org-bold-region-or-point)
  ("s-v" . org-verbatim-region-or-point)
  ("s-c" . org-code-region-or-point)
  ("s-u" . org-underline-region-or-point)
  ("s-+" . org-strikethrough-region-or-point)
  ("s-4" . org-latex-math-region-or-point)
  ("s-e" . ivy-insert-org-entity)
  :init
  (require 'smax-org))

(use-package smax-email
  :ensure nil
  :load-path conf-dir)

(use-package smax-notebook
  :ensure nil
  :load-path conf-dir)

(use-package smax-elfeed
  :ensure nil
  :load-path conf-dir)

(use-package smax-dired
  :ensure nil
  :load-path conf-dir)

(use-package smax-utils
  :ensure nil
  :load-path conf-dir
  :bind ( "<f9>" . hotspots))

(use-package smax-ivy
  :ensure nil
  :load-path conf-dir)


;; * User packages

;; We load one file: user.el

(when (and
       smax-load-user-dir
       (file-exists-p (expand-file-name "user.el" user-dir)))
  (load (expand-file-name "user.el" user-dir)))

;; * The end
(provide 'smax-packages)

;;; packages.el ends here
