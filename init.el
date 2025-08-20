;; BEGIN

;; PERFORMANCE
(setq gc-cons-threshold (* 128 1024 1024))
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
(setq c-default-style "microsoft")

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
  :init (progn (load-theme 'ample t t)
               (load-theme 'ample-flat t t)
               (load-theme 'ample-light t t)
               (enable-theme 'ample-flat))
  :defer t
  :ensure t)

;; RUST
(use-package rust-mode
  :hook (rust-mode . (lambda () (setq indent-tabs-mode nil)))
  :config
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode)))

;; SLIME
(use-package slime
  :ensure t
  :commands (sly sly-connect)
  :init
  ;; 设置你要用的 Common Lisp 实现，这里默认用 sbcl
  ;; 如果 sbcl 不在 PATH，请写绝对路径
  (setq inferior-lisp-program "sbcl")
  :config
  ;; 推荐加载 sly-quicklisp、sly-asdf 等扩展
  (setq sly-contribs '(sly-fancy
                       sly-quicklisp
                       sly-asdf))

  ;; 文件关联
  (add-to-list 'auto-mode-alist '("\\.lisp\\'" . lisp-mode))
  (add-to-list 'auto-mode-alist '("\\.asd\\'" . lisp-mode)))

;; WHICH-KEY
(use-package which-key
  :ensure t
  :defer 1
  :config (which-key-mode))

;; COUNSEL + IVY + SWIPER
(use-package counsel
  :ensure t
  :after ivy
  :config (counsel-mode 1))

(use-package ivy
  :ensure t
  :diminish (ivy-mode . "")
  :init
  (ivy-mode 1)
  :bind (;; 绑定 counsel 提供的命令，覆盖原生命令
         ("C-x C-f" . counsel-find-file)
         ("C-x b"   . counsel-switch-buffer)
         ;; 其他有用的 counsel 命令，您可以按需添加
         ("M-x"     . counsel-M-x)
         ("C-c f"   . counsel-git)
         ("C-c j"   . counsel-imenu)

         ;; Swiper 绑定
         ("C-s" . swiper)
         ("C-r" . swiper)

         ;; Ivy 内部快捷键
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  ;; 一些推荐的 Ivy 配置
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-re-builders-alist '((swiper . ivy--regex-plus)
                               (t      . ivy--regex-fuzzy))))

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
  (let* ((n (1+ i))
         (fname (intern (format "my/toggle-eshell-%d" n))))
    ;; 生成 9 个可交互命令，避免闭包键位捕获问题
    (fset fname `(lambda () (interactive) (my/toggle-eshell-n ,n)))
    ;; 覆盖默认 digit-argument
    (global-unset-key (kbd (format "M-%d" n)))
    (global-set-key (kbd (format "M-%d" n)) fname)))

;; TAB-LINE SETTING
(global-tab-line-mode 1)

;; 只保留“有文件名”的 buffer（排除 *Messages* / *Help* 等）
(defun my/tab-line-tabs-only-files ()
  "Return only file-visiting buffers for tab-line."
  (seq-filter
   (lambda (b)
     (buffer-local-value 'buffer-file-name b))
   (tab-line-tabs-window-buffers)))

(setq tab-line-tabs-function #'my/tab-line-tabs-only-files)

;; 可选：标签名使用简短文件名（不带路径），更紧凑
(setq tab-line-tab-name-function
      (lambda (buffer &optional _buffers)
        (format " %s " (buffer-name buffer))))

;; 可选：不显示关闭按钮，保持干净
(setq tab-line-close-button-show nil)

;; 保险起见：提供“只在文件 buffer 间循环”的 next/prev（不依赖 tab-line）
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
(global-set-key (kbd "M-=")  #'my/prev-file-buffer)
;; END

