;; ** variables

(defvar temp-notes-dir)
(setq temp-notes-dir "~/TMP/NOTES/")

(defvar subjects)
(setq subjects '(("analysis"	. "MAT157")
		 ("algebra"	. "MAT247")
		 ("logic"	. "CSC240")
		 ("biology"	. "BIO130")
		 ("other"	. "")
		 ))

;; ** org
(setq org-directory "~/ORG/")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map (kbd "<f2> c") 'org-capture)

;; ** Functions
(defun add-note (name)
  "Add a new note to temp-notes-dir."
  (interactive
   (list (read-string "Enter the title of the note:")))

  ;; store the name of a note
  (kill-new name)
  (defvar topic-key)
  (setq topic-key name)

  ;; store the subject key
  (defvar subject-key)

  (find-file  (concat
	       (file-name-as-directory temp-notes-dir)
	       (format-time-string "%Y%m%d" (current-time))
	       (let ((key (ivy-completing-read "Subject:" (mapcar 'car subjects))))
		 (message "%S" key)
		 (setq subject-key (cdr (assoc  key subjects)))
		 (cdr (assoc  key subjects))
		 ) 
	       (replace-regexp-in-string " " "+" name)
	       ".tex")
	      )
  (yas-expand-snippet (yas-lookup-snippet "note_automatic" 'latex-mode))
  )

(defun add-pset (name)
  "Add a new pset solutions to temp-notes-dir."
  (interactive
   (list (read-string "Enter the title of the pset:")))

  ;; store the name of a note
  (kill-new name)
  (defvar topic-key)
  (setq topic-key name)

  ;; store the subject key
  (defvar subject-key)

  (find-file  (concat
	       (file-name-as-directory temp-notes-dir)
	       "ARBEIT"
	       (format-time-string "%Y%m%d" (current-time))
	       (let ((key (ivy-completing-read "Subject:" (mapcar 'car subjects))))
		 (message "%S" key)
		 (setq subject-key (cdr (assoc  key subjects)))
		 (cdr (assoc  key subjects))
		 ) 
	       (replace-regexp-in-string " " "+" name)
	       ".tex")
	      )
  (yas-expand-snippet (yas-lookup-snippet "note_automatic" 'latex-mode))
  )


(defun add-mikveh (name)
  "Add a new lecture note to temp-notes-dir."
  (interactive
   (list (read-string "Enter the title of the pset:")))

  ;; store the name of a note
  (kill-new name)
  (defvar topic-key)
  (setq topic-key name)

  ;; store the subject key
  (defvar subject-key)

  (find-file  (concat
	       (file-name-as-directory temp-notes-dir)
	       "MIKVEH"
	       (format-time-string "%Y%m%d" (current-time))
	       (let ((key (ivy-completing-read "Subject:" (mapcar 'car subjects))))
		 (message "%S" key)
		 (setq subject-key (cdr (assoc  key subjects)))
		 (cdr (assoc  key subjects))
		 ) 
	       (replace-regexp-in-string " " "+" name)
	       ".tex")
	      )
  (yas-expand-snippet (yas-lookup-snippet "note_automatic" 'latex-mode))
  )


(provide 'init-notes)

