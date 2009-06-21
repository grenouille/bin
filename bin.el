;;; bin.el --- dto's catch-all organizational system

;; Copyright (C) 2007  David O'Toole

;; Author: David O'Toole(require 'org) <dto@gnu.org>
;; Keywords: tools

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary: 

;; The bin system organizes your life around "pages". Each page is an
;; org-file about a particular topic, project, or person. All the
;; pages go in your "bin folder" (by default, ~/org) and when queried
;; for information on a topic "foo", the system looks for
;; "~/org/foo.org". (You can specify that a topic's page is stored
;; elswehere by customizing `org-other-pages'.) See also `bin-folder'.

;; A default page called "the bin" is for incoming items that have not
;; been archived or refiled to another page. If you are away from the
;; computer where you run org-mode, you can use a sheet of paper and
;; enter the items later. See `bin-file'.

;; Some top-level headings in pages are handled specially, for example
;; "* Appointments" and "* Tasks".

;; Hotkeys and auto-completion speed up access to the bin and its
;; pages, including a search tool.

;; foo

;;; Code:

(require 'org)
(require 'remember)

;; Org-mouse adds various clickable menus to org-mode constructs.

(require 'org-mouse)

;; I want files with the extension ".org" to open in org-mode.

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.org_archive$" . org-mode))

(defvar bin-folder (file-name-as-directory "~/org")
  "The disk directory where bin pages go by default.
See also `bin-other-pages'.")

(defvar bin-file "~/org/bin.org" 
  "Filename of the bin file, a central location for incoming unfiled items.
If you are away from the computer, you can use a piece of paper
for this, and enter the items into org-mode later.")

(defun bin-page-filename (name &optional archive-p)
  "Return the filename of the page named NAME.
A page is an org file covering one topic."
  (let ((extension (if archive-p ".org_archive" ".org")))
    (expand-file-name (concat name extension) bin-folder)))

(defvar bin-pages '() "The list of current page names.")

(defvar bin-other-pages '() "Association list of pages stored outside the bin folder.
Each entry is of the form: 

  (PAGENAME . FILENAME)

where both PAGENAME and FILENAME are strings. Example: 

  (setf bin-other-pages
        '((\"finance\" . \"~/finance/todo.org\")
          (\"myproject\" . \"~/myproject/myproject.org\")))")

(defun bin-read-pages ()
  (setf bin-pages 
	(

(defun bin-complete-page-name ()
  (completing-read bin-pages

(defun bin-find-page (page &optional archive-p)
  (find-file (bin-page-filename page)))
  
  

;; I open my bin file when I hit C-c g

(defun bin ()
  "Open the BIN file and move to the top of the buffer."
  (interactive)
  (find-file bin-file)
  (goto-char (point-min)))

;; Some basic keybindings.

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cr" 'org-remember)
(global-set-key "\C-cb" 'bin)

;; This seems like a good basic set of keywords to start out with:

(setq org-todo-keywords '((type "TODO" "NEXT" "WAITING" "DONE")))

;; Some projects need their own org files, but I still want them to
;; show up in my agenda.

(defvar bin-other-files)

(setf bin-other-files (list "~/eon/eon.org"))

(setf org-agenda-files (cons bin-file bin-other-files))

;; When I'm using org to track issues in a project, I use these
;; keywords on a file-local basis: 

;; #+SEQ_TODO: TODO | DONE
;; #+SEQ_TODO: REPORT BUG KNOWNCAUSE | FIXED 
;; #+SEQ_TODO: | CANCELLED

;; The lisp version is:

;; (setq org-todo-keywords '((sequence "TODO" | "DONE")
;;   			  (sequence "REPORT" "BUG" "KNOWNCAUSE" | "FIXED")
;; 			  (sequence | "CANCELLED")))

;; Easy basic searches. Get a quick view of nextactions, etc

(setq org-agenda-custom-commands
      '(("w" todo "WAITING" nil)
	("n" todo "NEXT" nil)
	("d" "Agenda + Next Actions" ((agenda) (todo "NEXT")))))

;; I use org's tag feature to implement contexts.

(setq org-tag-alist '(("STUDIO" . ?s)
		      ("COMPUTER" . ?c)
		      ("MAIL" . ?m)
		      ("HOME" . ?h)
		      ("FIELD" . ?f) 
		      ("READING" . ?r)
		      ("DVD" . ?d)))

;; I like to color-code task types.

(setf org-todo-keyword-faces 
      '(("TODO" . (:foreground "yellow" :background "forestgreen" :bold t :weight bold))
	("FEATURE" . (:foreground "dodgerblue" :background "navyblue" :bold t :weight bold))
	("WAITING" . (:foreground "cyan" :background "purple" :bold t :weight bold))
	("TUNE" . (:foreground "black" :background "darkgoldenrod" :bold t :weight bold))
	("DOC" . (:foreground "yellow" :background "brown" :bold t :weight bold))
	("BUG" . (:foreground "cyan" :background "red" :bold t :weight bold))
	("NEXT" . (:foreground "yellow" :background "red" :bold t :weight bold))
	("DONE" . (:foreground "goldenrod" :background "gray10" :bold t :weight bold))))

;; I put the archive in a separate file, because the bin file will
;; probably already get pretty big just with current tasks.

(setq org-archive-location "%s_archive::")

;; Remember support. This creates several files:
;;
;;   ~/todo.org      Where remembered TODO's are stored.
;;   ~/journal.org   Timestamped journal entries.
;;   ~/remember.org  All other notes

;; and a keybinding of "C-c r" for making quick notes from any buffer.

;; These bits of Remembered information must eventually be reviewed
;; and filed somewhere (perhaps in bin.org, or in a project-specific
;; org file.) The out-of-sight, out-of-mind rule applies here---if I
;; don't review these auxiliary org-files, I'll probably forget what's
;; in them.

(require 'remember)
(setq org-reverse-note-order t)  ;; note at beginning of file by default.
(setq org-default-notes-file "~/remember.org")
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))
(add-hook 'remember-mode-hook 'org-remember-apply-template)

(setq org-remember-templates
      '((?t "* TODO %?\n  %i\n  %a" "~/todo.org")
        (?j "* %U %?\n\n  %i\n  %a" "~/journal.org")
        (?i "* %^{Title}\n  %i\n  %a" "~/remember.org" "New Ideas")))

(global-set-key "\C-cr" 'org-remember)
(global-set-key [(f12)] 'org-remember)

;; My preferences. These are less related to BIN, and more to my
;; particular setup. They are included here for completeness, and so
;; that new org users can see a complete example bin
;; configuration.

(setq org-return-follows-link t)
(setq org-hide-leading-stars t) 
(setf org-tags-column -65)
(setf org-special-ctrl-a/e t)

(setq org-log-done t)
(setq org-deadline-warning-days 14)
(setq org-fontify-emphasized-text t)
(setq org-fontify-done-headline t)
(setq org-agenda-include-all-todo nil)
(setq org-directory "~/")
(setq org-export-html-style "<link rel=stylesheet href=\"../e/freeshell2.css\" type=\"text/css\">")
(setq org-export-with-section-numbers nil)
(setq org-export-with-toc nil)
(setq org-adapt-indentation nil)

;; widen category field a little
(setq org-agenda-prefix-format "  %-17:c%?-12t% s") 

;; fix new keybinding that clobbers mine
(add-hook 'org-mode-hook (lambda ()
			   (local-set-key [(control tab)] 'other-window)))

(provide 'bin)
;;; bin.el ends here

