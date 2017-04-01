;; Initialize packages
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;; use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

;; Easily list packages in this one central place. You'll be asked automatically whether
;; you'd like to install any packages in this list that aren't currently installed the
;; next time you start Emacs
(setq package-selected-packages
      (quote
       (
	;; Org
	org org-plus-contrib
	
	;;  If using counsel-M-x instead of the default, it's still worth having
	;; smex installed, because counsel will use smex for sorting the candidates
	;; by most recently used.
	smex ivy swiper counsel flx
	
	;; Themes
	borland-blue-theme
	color-theme-sanityinc-tomorrow
	
	projectile
	counsel-projectile
	;;helm ;; For a dashboard
	;;flycheck ;; For Syntax checking
	;;powerline 
	;;solarized-theme ;; This can then be activated with M-x load-theme
	;;markdown-mode 
	;;markdown-mode+ 
	;;darkroom 
	;;ivy 
	;;scroll-restore ;; For allowing scrolling without moving the cursor once it goes off-screen.
	;;org-repo-todo ;; For todo functionality within a repo.
	;;org-journal ;; An org-mode-based journal
	;;undo-tree
	)))

;; Install any missing packages that are listed in the package-selected-packages
;; variable below. (This is a feature introduced in Emacs 25.1).
;; See, e.g., http://stackoverflow.com/a/39891192
(unless package-archive-contents
  (package-refresh-contents))
(package-install-selected-packages)

;; Establish environment
(defvar on-mswindows (string-match "windows" (symbol-name system-type))
  "Am I running under windows?")
(defvar on-osx (string-match "darwin" (symbol-name system-type))
  "Am I running under osx?")
(defvar on-linux (string-match "gnu/linux" (symbol-name system-type))
  "Am I running under linux?")

;; Setup keyboard
(when (and on-osx (window-system))
  (setq mac-command-key-is-meta nil)
  (setq mac-command-modifier 'super)
  (setq mac-option-modifier 'meta)
  (setq mac-right-option-modifier nil))

;; Set nice font
(when on-osx
  (set-face-attribute 'default nil :family "Iosevka")
  (set-face-attribute 'default nil :height 140))

(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 200))
;; (insert "\n(set-default-font \"" (cdr (assoc 'font (frame-parameters))) "\")\n")
;;(set-default-font "-*-Iosevka-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")

;; Turn off annoyances

(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq ring-bell-function 'ignore)

;; Don't display the 'Welcome to GNU Emacs' buffer on startup
(setq inhibit-startup-message t)

;; Simpler dialogues
(when (and on-osx (window-system))
  (defadvice yes-or-no-p (around prevent-dialog activate)
    "Prevent yes-or-no-p from activating a dialog"
    (let ((use-dialog-box nil))
      ad-do-it))
  (defadvice y-or-n-p (around prevent-dialog-yorn activate)
    "Prevent y-or-n-p from activating a dialog"
    (let ((use-dialog-box nil))
      ad-do-it)))

;; Turn on good stuff

;; Auto revert
(global-auto-revert-mode 1)

;; Save place
(save-place-mode 1) 

;; Word wrap at word
(setq-default word-wrap t)

;; Recent files
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; Add folder for extra lisp files not found in packages.
(push "~/.emacs.d/lisp/" load-path)

;; Ange min position för soluppgång och solnedgång etc
(setq calendar-latitude 63.3)
(setq calendar-longitude 14.1)
(setq calendar-location-name "Offne, Sweden")

;; Ladda svenska kalenderdata
(load-file "~/.emacs.d/lisp/sv-kalender.el")

;; Mode for beancounting
(require 'beancount)

;; Org-mode hotkeys
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; Custom Key Bindings (from Bernt)
(global-set-key (kbd "<f12>") 'org-agenda)
;;(global-set-key (kbd "<f5>") 'bh/org-todo)
;;(global-set-key (kbd "<S-f5>") 'bh/widen)
(global-set-key (kbd "<f7>") 'bh/set-truncate-lines)
(global-set-key (kbd "<f8>") 'org-cycle-agenda-files)
(global-set-key (kbd "<f9> <f9>") 'bh/show-org-agenda)
;;(global-set-key (kbd "<f9> b") 'bbdb)
;(global-set-key (kbd "<f9> c") 'calendar)
;(global-set-key (kbd "<f9> f") 'boxquote-insert-file)
;(global-set-key (kbd "<f9> g") 'gnus)
(global-set-key (kbd "<f9> h") 'bh/hide-other)
(global-set-key (kbd "<f9> n") 'bh/toggle-next-task-display)

;(global-set-key (kbd "<f9> I") 'bh/punch-in)
;(global-set-key (kbd "<f9> O") 'bh/punch-out)

(global-set-key (kbd "<f9> o") 'bh/make-org-scratch)

;(global-set-key (kbd "<f9> r") 'boxquote-region)
;(global-set-key (kbd "<f9> s") 'bh/switch-to-scratch)

(global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
(global-set-key (kbd "<f9> T") 'bh/toggle-insert-inactive-timestamp)

;(global-set-key (kbd "<f9> v") 'visible-mode)
;(global-set-key (kbd "<f9> l") 'org-toggle-link-display)
;(global-set-key (kbd "<f9> SPC") 'bh/clock-in-last-task)
;(global-set-key (kbd "C-<f9>") 'previous-buffer)
;(global-set-key (kbd "M-<f9>") 'org-toggle-inline-images)
;(global-set-key (kbd "C-x n r") 'narrow-to-region)
;(global-set-key (kbd "C-<f10>") 'next-buffer)
;(global-set-key (kbd "<f11>") 'org-clock-goto)
;(global-set-key (kbd "C-<f11>") 'org-clock-in)
;(global-set-key (kbd "C-s-<f12>") 'bh/save-then-publish)
;(global-set-key (kbd "C-c c") 'org-capture)

;; (defun bh/hide-other ()
;;   (interactive)
;;   (save-excursion
;;     (org-back-to-heading 'invisible-ok)
;;     (hide-other)
;;     (org-cycle)
;;     (org-cycle)
;;     (org-cycle)))

;; (defun bh/set-truncate-lines ()
;;   "Toggle value of truncate-lines and refresh window display."
;;   (interactive)
;;   (setq truncate-lines (not truncate-lines))
;;   ;; now refresh window display (an idiom from simple.el):
;;   (save-excursion
;;     (set-window-start (selected-window)
;;                       (window-start (selected-window)))))

;; (defun bh/make-org-scratch ()
;;   (interactive)
;;   (find-file "/tmp/publish/scratch.org")
;;   (gnus-make-directory "/tmp/publish"))

;; (defun bh/switch-to-scratch ()
;;   (interactive)
;;   (switch-to-buffer "*scratch*"))

(require 'org-protocol)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "cyan1" :weight bold)
              ("DONE" :foreground "green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "green" :weight bold)
              ("MEETING" :foreground "green" :weight bold)
              ("PHONE" :foreground "green" :weight bold))))

(setq org-use-fast-todo-selection t)

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

;; default notes file
;;(setq org-default-notes-file "~/Org/notes.org")
(setq org-directory "~/Org")
(setq org-default-notes-file "~/Org/refile.org")

;; I use C-c c to start capture mode

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/Org/refile.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("r" "respond" entry (file "~/Org/refile.org")
               "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
              ("n" "note" entry (file "~/Org/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree "~/Org/diary.org")
               "* %?\n%U\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file "~/Org/refile.org")
               "* TODO Review %c\n%U\n" :immediate-finish t)
              ("f" "alfred" entry (file "~/Org/refile.org")
               "* TODO Noted %:description\n%U\n%:initial\n" :immediate-finish t)
              ("m" "Meeting" entry (file "~/Org/refile.org")
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
              ("p" "Phone call" entry (file "~/Org/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
              ("h" "Habit" entry (file "~/Org/refile.org")
               "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))


;; My agenda files
(setq org-agenda-files (list "~/Org/notes.org"
			     "~/Org/todo.org"
			     "~/Org/refile.org"
			     "~/Org/adeprimo.org"
			     "~/Org/from-mobile.org"))

;; smart later
(setq org-catch-invisible-edits 'show-and-error)

;; Log into LOGBOOK
(setq org-log-into-drawer t)
(setq org-log-done t)
(setq org-startup-indented t)

;; org-mobile
(setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")
(setq org-mobile-inbox-for-pull "~/Org/from-mobile.org")


(setq org-hide-emphasis-markers t)

;; Org refile
;; from: https://www.reddit.com/r/emacs/comments/4366f9/how_do_orgrefiletargets_work/
;; Now when I do org-refile, it searches across all headlines in all my agenda files
;; (Up to a depth of 9). The last two variables are useful because I'm using helm.
;; Instead of having to step through the headings Foo, Bar, and Go to the the Store,
;; I just get a giant list of targets in the form Foo/Bar/Go to the Store. Makes it
;; super easy to jump to whatever I'm looking for.
(setq org-refile-targets '((nil :maxlevel . 2)
                           (org-agenda-files :maxlevel . 2)))

;;(setq org-refile-targets (quote (("notes.org" :maxlevel . 2)
;;                                 ("adeprimo.org" :maxlevel . 2)
;;                                 ("todo.org" :maxlevel . 2))))
(setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
(setq org-refile-use-outline-path t)                  ; Show full paths for refiling
    
    
(add-hook 'org-mode-hook 'my/org-mode-hook)

(defun my/org-mode-hook ()                                    ;
  "Stop the org-level headers from increasing in height relative to the other text."
  (dolist
      (face '(org-level-1
              org-level-2
              org-level-3
              org-level-4
              org-level-5
              org-agenda-date-today))
    (set-face-attribute face nil :weight 'normal :height 1.0))
  (auto-fill-mode 1)
  )

;; Cause window titles to display the current buffer's name (rather than just "emacs@computer-name")
(setq-default frame-title-format '("%b"))

(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")

(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
;(global-set-key (kbd "<f1> f") 'counsel-describe-function)
;(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
;(global-set-key (kbd "<f1> l") 'counsel-find-library)
;(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;(global-set-key (kbd "<f2> u") 'counsel-unicode-char)

(global-set-key (kbd "C-c C-r") 'ivy-resume)

; Let ivy use flx for fuzzy-matching
;(require 'flx)
;(setq ivy-re-builders-alist '((t . ivy--regex-fuzzy)))

(projectile-global-mode)
(counsel-projectile-on)

(setq org-feed-alist
      '(

	("Slashdot" 
	 "http://rss.slashdot.org/Slashdot/slashdot"
	 "~/Org/feeds.org" "Slashdot Entries")

	("Pinboard: Egen Hemsida"
	 "http://feeds.pinboard.in/rss/secret:d315662ae2db980c7103/u:mattiasj/t:egenhemsida/"
	 "~/Org/feeds.org" "Pinboard: Egen hemsida")

	("Pinboard: Orgmode"
	 "http://feeds.pinboard.in/rss/secret:d315662ae2db980c7103/u:mattiasj/t:orgmode/"
	 "~/Org/feeds.org" "Pinboard: Orgmode")

	))

;(require 'org-protocol)

;(require 'org-habit) 
;(require 'org-id)

(defun ns-raise-emacs ()
  (ns-do-applescript "tell application \"Emacs\" to activate"))

 (defadvice org-capture-finalize 
  (after delete-capture-frame activate)  
   "Advise capture-finalize to close the frame"  
   (if (equal "capture" (frame-parameter nil 'name))  
       (delete-frame)))  
   
 (defadvice org-capture-destroy 
  (after delete-capture-frame activate)  
   "Advise capture-destroy to close the frame"  
   (if (equal "capture" (frame-parameter nil 'name))  
       (delete-frame)))  
   
 ;; make the frame contain a single window. by default org-capture  
 ;; splits the window.  
 (add-hook 'org-capture-mode-hook  
           'delete-other-windows)  
   
 (defun make-orgcapture-frame ()  
   "Create a new frame and run org-capture."  
   (ns-raise-emacs)
   (make-frame '((name . "capture") 
                 (width . 180) 
                 (height . 40)))  
   (select-frame-by-name "capture") 
   (setq word-wrap 1)
   (setq truncate-lines nil)
   (add-hook 'org-capture-mode-hook  
	     'delete-other-windows) 
   (org-capture)
   (remove-hook 'org-capture-mode-hook  
		'delete-other-windows))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#4d4d4c" "#c82829" "#718c00" "#eab700" "#4271ae" "#8959a8" "#3e999f" "#d6d6d6"))
 '(custom-enabled-themes (quote (sanityinc-tomorrow-eighties)))
 '(custom-safe-themes
   (quote
    ("628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" default)))
 '(fci-rule-color "#d6d6d6")
 '(package-selected-packages
   (quote
    (org org-plus-contrib smex ivy swiper counsel flx borland-blue-theme color-theme-sanityinc-tomorrow projectile counsel-projectile)))
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#c82829")
     (40 . "#f5871f")
     (60 . "#eab700")
     (80 . "#718c00")
     (100 . "#3e999f")
     (120 . "#4271ae")
     (140 . "#8959a8")
     (160 . "#c82829")
     (180 . "#f5871f")
     (200 . "#eab700")
     (220 . "#718c00")
     (240 . "#3e999f")
     (260 . "#4271ae")
     (280 . "#8959a8")
     (300 . "#c82829")
     (320 . "#f5871f")
     (340 . "#eab700")
     (360 . "#718c00"))))
 '(vc-annotate-very-old-color nil))
