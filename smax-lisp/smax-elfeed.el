;; * elfeed
(require 'elfeed)
;; Initialize elfeed-org
;; This hooks up elfeed-org to read the configuration when elfeed
;; is started with =M-x elfeed=
;; (elfeed-org)

;; Optionally specify a number of files containing elfeed
;; configuration. If not set then the location below is used.
;; Note: The customize interface is also supported.

(setq elfeed-feeds
      '(
	("http://export.arxiv.org/rss/math.AG" math.AG)
	("http://export.arxiv.org/rss/math.AT" math.AT)
	("http://export.arxiv.org/rss/math.AC" math.AC)
	("http://export.arxiv.org/rss/math.GT" math.GT)
	("http://export.arxiv.org/rss/math.MG" math.MG)
	("http://export.arxiv.org/rss/math.RT" math.RT)
	("http://export.arxiv.org/rss/math.SP" math.SP)
	("https://usamo.wordpress.com/feed/" Personal)
	("https://www.quantamagazine.org/feed/" General)
	("http://rss.sciam.com/sciam/math" General)
	("https://rss.sciencedaily.com/computers_math.xml" General)
	;; ("http://planetpython.org/rss20.xml" python)
	;; ("http://planet.scipy.org/rss20.xml" python)
	("http://planet.emacsen.org/atom.xml" emacs) 
	;; Stackoverflow questions on emacs
	;; ("http://emacs.stackexchange.com/feeds" emacs)
	))

(defface python-elfeed-entry
  '((t :background "Darkseagreen1"))
  "Marks a python Elfeed entry.")

(defface emacs-elfeed-entry
  '((t :background "Lightblue1"))
  "Marks a python Elfeed entry.")

;; (push '(python python-elfeed-entry)
;;       elfeed-search-face-alist)

;; (push '(emacs emacs-elfeed-entry)
;;       elfeed-search-face-alist)


(setq elfeed-search-title-max-width 150)
(setq elfeed-search-trailing-width 30)
;; A snippet for periodic update for feeds (3 mins since Emacs start, then every
;; half hour)
(run-at-time 180 1800 (lambda () (elfeed-update)))

(defun email-elfeed-entry ()
  "Capture the elfeed entry and put it in an email."
  (interactive)
  (let* ((title (elfeed-entry-title elfeed-show-entry))
	 (url (elfeed-entry-link elfeed-show-entry))
	 (content (elfeed-entry-content elfeed-show-entry))
	 (entry-id (elfeed-entry-id elfeed-show-entry))
	 (entry-link (elfeed-entry-link elfeed-show-entry))
	 (entry-id-str (concat (car entry-id)
			       "|"
			       (cdr entry-id)
			       "|"
			       url)))
    (compose-mail)
    (message-goto-subject)
    (insert title)
    (message-goto-body)
    (insert (format "You may find this interesting:
%s\n\n" url))
    (insert (elfeed-deref content))

    (message-goto-body)
    (while (re-search-forward "<br>" nil t)
      (replace-match "\n\n"))

    (message-goto-body)
    (while (re-search-forward "<.*?>" nil t)
      (replace-match ""))

    (message-goto-body)
    (fill-region (point) (point-max))

    (message-goto-to)
    (ivy-contacts nil)))

(defun doi-utils-add-entry-from-elfeed-entry ()
  "Add elfeed entry to bibtex."
  (interactive)
  (require 'org-ref)
  (let* ((title (elfeed-entry-title elfeed-show-entry))
	 (url (elfeed-entry-link elfeed-show-entry))
	 (content (elfeed-deref (elfeed-entry-content elfeed-show-entry)))
	 (entry-id (elfeed-entry-id elfeed-show-entry))
	 (entry-link (elfeed-entry-link elfeed-show-entry))
	 (entry-id-str (concat (car entry-id)
			       "|"
			       (cdr entry-id)
			       "|"
			       url)))
    (if (string-match "DOI: \\(.*\\)$" content)
	(doi-add-bibtex-entry (match-string 1 content)
			      (ido-completing-read
			       "Bibfile: "
			       (append (f-entries "." (lambda (f)
							(and (not (string-match "#" f))
							     (f-ext? f "bib"))))
				       org-ref-default-bibliography)))
      (let ((dois (org-ref-url-scrape-dois url)))
	(cond
	 ;; One doi found. Assume it is what we want.
	 ((= 1 (length dois))
	  (doi-utils-add-bibtex-entry-from-doi
	   (car dois)
	   (ido-completing-read
	    "Bibfile: "
	    (append (f-entries "." (lambda (f)
				     (and (not (string-match "#" f))
					  (f-ext? f "bib"))))
		    org-ref-default-bibliography)))
	  action)
	 ;; Multiple DOIs found
	 ((> (length dois) 1)
	  (helm :sources
		`((name . "Select a DOI")
		  (candidates . ,(let ((dois '()))
				   (with-current-buffer (url-retrieve-synchronously url)
				     (loop for doi-pattern in org-ref-doi-regexps
					   do
					   (goto-char (point-min))
					   (while (re-search-forward doi-pattern nil t)
					     (pushnew
					      ;; Cut off the doi, sometimes
					      ;; false matches are long.
					      (cons (format "%40s | %s"
							    (substring
							     (match-string 1)
							     0 (min
								(length (match-string 1))
								40))
							    doi-pattern)
						    (match-string 1))
					      dois
					      :test #'equal)))
				     (reverse dois))))
		  (action . (lambda (candidates)
			      (let ((bibfile (ido-completing-read
					      "Bibfile: "
					      (append (f-entries "." (lambda (f)
								       (and (not (string-match "#" f))
									    (f-ext? f "bib"))))
						      org-ref-default-bibliography))))
				(loop for doi in (helm-marked-candidates)
				      do
				      (doi-utils-add-bibtex-entry-from-doi
				       doi
				       bibfile)
				      ;; this removes two blank lines before each entry.
				      (bibtex-beginning-of-entry)
				      (delete-char -2)))))))))))))


;; (define-key elfeed-show-mode-map (kbd "e") 'email-elfeed-entry)
;; (define-key elfeed-show-mode-map (kbd "c") (lambda () (interactive) (org-capture nil "e")))
;; (define-key elfeed-show-mode-map (kbd "d") 'doi-utils-add-entry-from-elfeed-entry)

;; ;; help me alternate fingers in marking entries as read
;; (define-key elfeed-search-mode-map (kbd "f") 'elfeed-search-untag-all-unread)
;; (define-key elfeed-search-mode-map (kbd "j") 'elfeed-search-untag-all-unread)
;; (define-key elfeed-search-mode-map (kbd "o") 'elfeed-search-show-entry)

;; * store links to elfeed entries
;; These are copied from org-elfeed
(defun org-elfeed-open (path)
  (cond
   ((string-match "^entry-id:\\(.+\\)" path)
    (let* ((entry-id-str (substring-no-properties (match-string 1 path)))
	   (parts (split-string entry-id-str "|"))
	   (feed-id-str (car parts))
	   (entry-part-str (cadr parts))
	   (entry-id (cons feed-id-str entry-part-str))
	   (entry (elfeed-db-get-entry entry-id)))
      (elfeed-show-entry entry)))
   (t (error "%s %s" "elfeed: Unrecognised link type - " path))))

(defun org-elfeed-store-link ()
  "Store a link to an elfeed entry"
  (interactive)
  (cond
   ((eq major-mode 'elfeed-show-mode)
    (let* ((title (elfeed-entry-title elfeed-show-entry))
	   (url (elfeed-entry-link elfeed-show-entry))
	   (entry-id (elfeed-entry-id elfeed-show-entry))
	   (entry-id-str (concat (car entry-id)
				 "|"
				 (cdr entry-id)
				 "|"
				 url))
	   (org-link (concat "elfeed:entry-id:" entry-id-str)))
      (org-store-link-props
       :description title
       :type "elfeed"
       :link org-link
       :url url
       :entry-id entry-id)
      org-link))
   (t nil)))

(org-link-set-parameters
 "elfeed"
 :follow 'org-elfeed-open
 :store 'org-elfeed-store-link)

(provide 'smax-elfeed)
