;;; init.el --- Main configuration  -*- lexical-binding: t; -*-

;; PERFORMANCE
(setq read-process-output-max (* 1024 1024))

;; DISPLAY
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(global-hl-line-mode 1)
(show-paren-mode t)
(electric-pair-mode 1)

;; STYLE
(setq make-backup-files nil)
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq c-basic-offset 4)
(c-add-style "microsoft"
             '("stroustrup"
               (c-offsets-alist
                (innamespace . -)
                (inline-open . 0)
                (inher-cont . c-lineup-multi-inher)
                (template-args-cont . +))))
(setq c-default-style '((c-mode . "microsoft")
                        (c++-mode . "microsoft")
                        (java-mode . "java")
                        (awk-mode . "awk")
                        (other . "gnu")))

;; PACKAGE MANAGEMENT
(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")
                         ;; official
                         ("gnu-official"    . "https://elpa.gnu.org/packages/")
                         ("nongnu-official" . "https://elpa.nongnu.org/packages/")
                         ("melpa-official"  . "https://melpa.org/packages/")
                         ))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)

;; GCMH
(use-package gcmh
  :ensure t
  :config
  (gcmh-mode 1))

;; HUGE FILE
(use-package so-long
  :ensure t
  :config (global-so-long-mode 1))

;; THEME
(use-package ample-theme
  :ensure t
  :config
  (load-theme 'ample t t)
  (load-theme 'ample-flat t t)
  (load-theme 'ample-light t t)
  (enable-theme 'ample-flat))

;; CODE COMPLETE
(use-package eglot
  :ensure nil
  :hook (prog-mode . eglot-ensure)
  :config
  (setq eglot-events-buffer-size 0)
  (fset 'jsonrpc--log-event #'ignore)
  (add-to-list 'eglot-ignored-server-capabilities
               :documentOnTypeFormattingProvider))

(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-backends '((company-capf company-dabbrev-code)
                      company-dabbrev
                      company-files))
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1))

(use-package yasnippet
  :ensure t
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

;; RUST
(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")

;; SLY
(use-package sly
  :ensure t
  :commands (sly sly-connect)
  :init
  (setq inferior-lisp-program "sbcl")
  (setq sly-contribs '(sly-fancy sly-quicklisp sly-asdf)))

;; WHICH-KEY
(use-package which-key
  :ensure t
  :defer 1
  :config (which-key-mode))

;; COUNSEL + IVY + SWIPER
(use-package ivy
  :init
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-re-builders-alist '((swiper . ivy--regex-plus)
                                (t      . ivy--regex-fuzzy)))
  :config
  (ivy-mode 1)
  (let ((map ivy-minibuffer-map))
    (define-key map (kbd "TAB") #'ivy-alt-done)
    (define-key map (kbd "C-j") #'ivy-next-line)
    (define-key map (kbd "C-k") #'ivy-previous-line)))

(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(use-package counsel
  :after ivy
  :init (counsel-mode 1)
  :bind (("C-x C-f" . counsel-find-file)
         ("C-x b"   . counsel-switch-buffer)
         ("M-x"     . counsel-M-x)
         ("C-c f"   . counsel-git)
         ("C-c j"   . counsel-imenu)))

;; ESHELL + SHACKLE
(defvar my/eshell-pane-window nil
  "专用的底部 side window，用于承载 eshell。")
(defvar my/eshell-pane-height 0.3
  "底部窗格高度占比。")

(defun my//ensure-eshell-buffer (index)
  "返回第 INDEX 个 Eshell buffer，不存在则创建。"
  (require 'eshell)
  (let* ((name (format "*eshell-%d*" index))
         (buf  (get-buffer name)))
    (if (and buf (buffer-live-p buf)
             (with-current-buffer buf (derived-mode-p 'eshell-mode)))
        buf
      (save-window-excursion
        (let ((eshell-buffer-name name))
          (eshell))                       ; 真正启动 eshell-mode
        (get-buffer name)))))

(defun my//show-in-bottom-pane (buf &optional select)
  "把 BUF 显示到专用底部 side window 中；若不存在则创建。"
  (if (and (window-live-p my/eshell-pane-window)
           (window-parameter my/eshell-pane-window 'my-eshell-pane))
      (progn
        (set-window-buffer my/eshell-pane-window buf)
        (when select (select-window my/eshell-pane-window))
        my/eshell-pane-window)
    ;; 创建或复用 slot=0 的底部 side window
    (let* ((win (display-buffer
                 buf
                 '((display-buffer-in-side-window)
                   (side . bottom)
                   (slot . 0)
                   (window-height . my/eshell-pane-height)
                   (window-parameters . ((no-other-window . t)
                                         (no-delete-other-windows . t)
                                         (my-eshell-pane . t)))))))
      (setq my/eshell-pane-window win)
      (when select (select-window win))
      win)))

(defun my/toggle-eshell-n (index)
  "Toggle 第 INDEX 个 Eshell：同 buffer 再按一次则隐藏；否则在同一底部窗格切换。"
  (interactive "p")
  (let* ((buf (my//ensure-eshell-buffer index))
         (win (and (window-live-p my/eshell-pane-window)
                   my/eshell-pane-window)))
    (if (and win (eq (window-buffer win) buf))
        (progn
          (delete-window win)              ; 隐藏
          (setq my/eshell-pane-window nil))
      (my//show-in-bottom-pane buf t))))   ; 切换/显示

;; 绑定 M-1 ... M-9
(dotimes (i 9)
  (let ((n (1+ i)))
    (global-unset-key (kbd (format "M-%d" n)))
    (global-set-key (kbd (format "M-%d" n))
                    (lambda () (interactive) (my/toggle-eshell-n n)))))

;; TAB-LINE SETTING
(defun my/tab-line-tabs-only-files ()
  "Return all file-visiting buffers, ordered by recency."
  (seq-filter (lambda (b) (buffer-local-value 'buffer-file-name b))
              (buffer-list)))

(use-package tab-line
  :ensure nil
  :hook (prog-mode . tab-line-mode)
  :config
  (setq tab-line-tabs-function #'my/tab-line-tabs-only-files)
  (setq tab-line-tab-name-function
        (lambda (buffer &optional _buffers)
          (format " %s " (buffer-name buffer))))
  (setq tab-line-close-button-show nil))

;; 在文件 buffer 间循环（不依赖 tab-line）
(defun my/next-file-buffer ()
  "Cycle to next file-visiting buffer only."
  (interactive)
  (let ((start (current-buffer)))
    (next-buffer)
    (while (and (not (eq (current-buffer) start))
                (not buffer-file-name))
      (next-buffer))
    (when (eq (current-buffer) start)
      (message "No other file buffers."))))

(defun my/prev-file-buffer ()
  "Cycle to previous file-visiting buffer only."
  (interactive)
  (let ((start (current-buffer)))
    (previous-buffer)
    (while (and (not (eq (current-buffer) start))
                (not buffer-file-name))
      (previous-buffer))
    (when (eq (current-buffer) start)
      (message "No other file buffers."))))

(global-set-key (kbd "M-0") 'other-window)
(global-set-key (kbd "M--") #'my/next-file-buffer)
(global-set-key (kbd "M-=") #'my/prev-file-buffer)

;;; init.el ends here
