(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq visual-bell nil)
(xterm-mouse-mode)

;; https://github.com/daviwil/emacs-from-scratch/blob/master/Emacs.org
;; https://realpython.com/emacs-the-best-python-editor/

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil)

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)


;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt --pylab")

(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs helm-lsp
					   projectile hydra flycheck company avy which-key helm-xref dap-mode))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(require 'python)

;;(menu-bar-mode nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(conda toml-mode rustic yaml-mode jupyter org-bullets org-tempo ivy elixr elixer magit counsel-projectile company-box lsp-ivy lsp-ui dap-mode dap-cpptools rust-mode cask realgud-lldb lsp-python-ms lsp-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . (lambda nil
		      (setq lsp-headerline-breadcrumb-segments
			    '(path-up-to-project file symbols))
		      (lsp-headerline-breadcrumb-mode)))

  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t)
  :custom
  (lsp-idle-delay 0.1)  ;; clangd is fast
  )
(use-package ivy)
(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-delay 0.2)  )
		       

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))


(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))




;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
;(helm-mode)
;(require 'helm-xref)
;(define-key global-map [remap find-file] #'helm-find-files)
;(define-key global-map [remap execute-extended-command] #'helm-M-x)
;(define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)
;(add-hook 'python-mode-hook 'lsp)

;(with-eval-after-load 'lsp-mode
;  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
;  (require 'dap-cpptools)
					;  (yas-global-mode))
;(use-package zmq)
(use-package jupyter)

(defun mmh/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . mmh/org-mode-setup)
  :custom
  (org-ellipsis " ▾")
  (org-confirm-babel-evaluate nil))
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))
(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
	(python . t)
	(shell . t)
	(makefile . t)
	(C . t)
	(jupyter . t)
	)))


(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)
  
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("mk" . "src makefile"))
  (add-to-list 'org-structure-template-alist '("cc" . "src C++"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("jpy" . "src jupyter-python :async yes :session py"))
  (add-to-list 'org-structure-template-alist '("cpp" . "src jupyter-C++17 :async yes :session c++17"))
  (add-to-list 'org-structure-template-alist '("C" . "src jupyter-C++17 :async yes :session c++17"))
  )

(use-package jupyter)

(use-package yaml)
(put 'narrow-to-region 'disabled nil)
;;;
;;;                                              _   
;;;                               _ __ _   _ ___| |_ 
;;;                              | '__| | | / __| __|
;;;                              | |  | |_| \__ \ |_ 
;;;                              |_|   \__,_|___/\__|
;;;                                                  
;;;
;;;
;;;
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status)
              ("C-c C-c e" . lsp-rust-analyzer-expand-macro)
              ("C-c C-c d" . dap-hydra)
              ("C-c C-c h" . lsp-ui-doc-glance))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t))
  (add-hook 'before-save-hook 'lsp-format-buffer nil t))

(use-package toml-mode :ensure)

(use-package conda
  :custom
  (conda-anaconda-home "/opt/anaconda3/")
  :config
  (conda-env-activate "py")
  (conda-env-initialize-interactive-shells)
  (conda-env-initialize-eshell)
  (conda-env-autoactivate-mode t)  )
