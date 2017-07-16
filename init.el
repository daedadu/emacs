;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.



(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(material-theme
    elpy
    dired+
    flycheck
    exec-path-from-shell
    epc
    jedi
    auto-complete
    rainbow-delimiters
    org
    helm-projectile
    realgud
    highlight-current-line
    py-yapf
    powerline
    magit
    ;; muss klein geschrieben sein sonst wird es nicht gefunden
    yasnippet
    engine-mode
    ace-window
    auto-highlight-symbol
    json-mode
    json-snatcher
    ))

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)



(global-auto-revert-mode t)



(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(el-get 'sync)


;; Pymacs
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(autoload 'pymacs-autoload "pymacs")

(defun load-ropemacs ()
  "Load pymacs and ropemacs"
  (interactive)
  (require 'pymacs)
  (pymacs-load "ropemacs" "rope-")
  ;; Automatically save project python buffers before refactorings
  (setq ropemacs-confirm-saving 'nil)
)
(global-set-key "\C-xpl" 'load-ropemacs)


;; directories first when sorting in dired
(defun mydired-sort ()
  "Sort dired listings with directories first."
  (save-excursion
    (let (buffer-read-only)
      (forward-line 2) ;; beyond dir. header 
      (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
    (set-buffer-modified-p nil)))

(defadvice dired-readin
  (after dired-after-updating-hook first () activate)
  "Sort dired listings with directories first before adding marks."
  (mydired-sort))

(require 'json-snatcher)
(defun js-mode-bindings ()
	 (when (string-match  "\\.json$" (buffer-name))
        (local-set-key (kbd "C-c C-g") 'jsons-print-path)))
(add-hook 'js-mode-hook 'js-mode-bindings)
(add-hook 'js2-mode-hook 'js-mode-bindings)


(require 'multiple-cursors)
(global-set-key (kbd "C-c m c") 'mc/edit-lines)

(global-set-key (kbd "C-x o") 'ace-window)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))


(require 'auto-highlight-symbol)
(add-hook 'after-init-hook 'global-auto-highlight-symbol-mode)

(require 'engine-mode)
(engine-mode t)

;; engine mode key remapping
(engine/set-keymap-prefix (kbd "C-c s"))
(defengine google
  "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s"
  :keybinding "g")


(require 'ido)
(ido-mode t)
(setq ido-separator "\n")


(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'material t) ;; load material theme
(global-linum-mode t) ;; enable line numbers globally

;; restore old buffers and layout after emacs restart
(desktop-save-mode 1)

(setq diredp-hide-details-initially-flag nil)


(electric-pair-mode 1)

(elpy-enable)
(global-flycheck-mode)
(require 'dired+)
(exec-path-from-shell-initialize)

(require 'helm-projectile)
(projectile-mode)
(helm-projectile-on)
(setq projectile-globally-ignored-directories
      (append '(
        ".git"
        ".svn"
        "out"
        "repl"
        "target"
        "venv"
        )
          projectile-globally-ignored-directories))

(require 'yasnippet)
;;(add-to-list 'yas-snippet-dirs "/Users/angus/yasnippet_git/yasnippet/snippets")
(yas-global-mode t)

(require 'py-yapf)
(add-hook 'python-mode-hook 'py-yapf-enable-on-save)

(setq projectile-globally-ignored-files
      (append '(
        ".DS_Store"
        "*.gz"
        "*.pyc"
        "*.jar"
        "*.tar.gz"
        "*.tgz"
        "*.zip"
        )
          projectile-globally-ignored-files))

(require 'auto-complete)
(ac-config-default)
;(set ac-show-menu-immediately-on-auto-complete t)

(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; brackets fix that curly braces work on os x
(setq mac-option-modifier nil mac-command-modifier 'meta select-enable-clipboard t)

;; org mode
;; The following lines are always needed.  Choose your own keys.
(require 'org)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-log-done t)

(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

   Move point to the first non-whitespace character on this line.
   If point is already there, move to the beginning of the line.
   Effectively toggle between the first non-whitespace character and
   the beginning of the line.
   
   If ARG is not nil or 1, move forward ARG - 1 lines first.  If
   point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)



;; this opens the file with an external app
(defun xah-open-in-external-app ()
  "Open the current file or dired marked files in external app.
The app is chosen from your OS's preference.
URL `http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html'
Version 2016-10-15"
  (interactive)
  (let* (
         (-file-list
          (if (string-equal major-mode "dired-mode")
              (dired-get-marked-files)
            (list (buffer-file-name))))
         (-do-it-p (if (<= (length -file-list) 5)
                       t
                     (y-or-n-p "Open more than 5 files? "))))
    (when -do-it-p
      (cond
       ((string-equal system-type "windows-nt")
        (mapc
         (lambda (-fpath)
           (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" -fpath t t))) -file-list))
       ((string-equal system-type "darwin")
        (mapc
         (lambda (-fpath)
           (shell-command
            (concat "open " (shell-quote-argument -fpath))))  -file-list))
       ((string-equal system-type "gnu/linux")
        (mapc
         (lambda (-fpath) (let ((process-connection-type nil))
                            (start-process "" nil "xdg-open" -fpath))) -file-list))))))

(global-set-key (kbd "M-RET") 'xah-open-in-external-app)

;------------;
;;; Cursor ;;;
;------------;

; highlight the current line
(require 'highlight-current-line)
(global-hl-line-mode t)


; don't blink the cursor
(blink-cursor-mode 0)

; make sure transient mark mode is enabled (it should be by default,
; but just in case)
(transient-mark-mode t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(package-selected-packages
   (quote
    (json-mode multiple-cursors auto-highlight-symbol highlight-symbol ace-window helm-flycheck helm-flymake helm-flyspell powerline highlight-current-line realgud org org-projectile material-theme magit flycheck exec-path-from-shell elpy dired+)))
 '(python-shell-interpreter "python3")
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
