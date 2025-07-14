;; ===========================
;; 性能优化
;; ===========================
(setq gc-cons-threshold (* 128 1024 1024))
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; ===========================
;; 全局按键 & 取消默认
;; ===========================
(global-unset-key (kbd "C-x b"))
(global-set-key (kbd "M-0") 'other-window)
(global-set-key (kbd "M--") 'previous-buffer)
(global-set-key (kbd "M-=") 'next-buffer)

;; ===========================
;; 显示样式
;; ===========================
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(global-hl-line-mode 1)     ;; 高亮当前行
(show-paren-mode t)         ;; 高亮括号
(global-font-lock-mode t)   ;; 语法高亮
(electric-pair-mode 1)      ;; 自动补对
(setq electric-pair-pairs
      '((?\" . ?\")
        (?\{ . ?\})
        (?\' . ?\')
        (?\< . ?\>)))

;; ===========================
;; 编码风格
;; ===========================
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

;; ===========================
;; 包管理 & 基础配置
;; ===========================
(require 'package)
(setq package-archives '(
                         ("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
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

;; gc optimize
(use-package gcmh
  :ensure t
  :config
  (gcmh-mode 1))

;; big file
(use-package so-long
  :ensure t
  :config (global-so-long-mode 1))

;; ===========================
;; LSP, Company, Flycheck (已修正和优化)
;; ===========================
;;(use-package lsp-mode
;;  :ensure t
;;  :commands (lsp lsp-deferred)
;;  :hook (prog-mode . lsp-deferred) ;; 关键：异步启动
;;  :config
;;  (setq lsp-auto-guess-root t
;;        lsp-keep-workspace-alive nil
;;        lsp-enable-auto-install nil ;; 建议：手动安装 lsp server
;;        lsp-log-io nil))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  ;; 避免在 lisp-mode 中自动启用 lsp
  (defun my/lsp-conditional-activate ()
    (unless (derived-mode-p 'lisp-mode)
      (lsp-deferred)))
  :hook
  (prog-mode . my/lsp-conditional-activate)
  :config
  (setq lsp-auto-guess-root t
        lsp-keep-workspace-alive nil
        lsp-enable-auto-install nil
        lsp-log-io nil))


(use-package company
  :ensure t
  :hook (lsp-mode . company-mode) ;; 在 lsp 准备好后启动
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  :config
  (setq company-minimum-prefix-length 2
        company-idle-delay 0.2
        company-backends '((company-capf company-dabbrev-code company-keywords))))

(use-package flycheck
  :ensure t
  :defer t ;; 明确延迟
  :hook (prog-mode . flycheck-mode)
  :config
  (setq flycheck-idle-change-delay 0.8)
  (setq flycheck-check-syntax-automatically '(mode-enabled save)))

;; ===========================
;; SLY for Common Lisp
;; ===========================
(use-package sly
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

;; ===========================
;; 快捷提示 which-key
;; ===========================
(use-package which-key
  :ensure t
  :defer 1
  :config (which-key-mode))

;; ===========================
;; 选项卡 centaur-tabs
;; ===========================
(use-package centaur-tabs
  ;;:demand
  :ensure t
  :config (centaur-tabs-mode t)
  :hook (emacs-startup . centaur-tabs-mode))

;; ===========================
;; Ibuffer-sidebar
;; ===========================

(setq ibuffer-saved-filter-groups
      '(("default"  ;; 组名
         ;; Org 文件
         ("Org"     (mode . org-mode))
         ;; Dired buffer
         ("Dired"   (mode . dired-mode))
         ;; Emacs 自带 buffer
         ("Emacs"   (or
                     (name . "^\\*scratch\\*$")
                     (name . "^\\*Messages\\*$")))
         ;; 代码类 buffer（所有 prog-mode 的子模式）
         ("Code"    (derived-mode . prog-mode))
         ;; Git 相关 buffer
         ("Magit"   (name . "^\\*magit"))
         ;; 其他……
         )))

;; 安装 ibuffer-sidebar
(use-package ibuffer-sidebar
  :ensure t
  :bind (("C-x C-b" . ibuffer-sidebar-toggle-sidebar))  ;; C-x C-b 切换侧边栏
  :config
  ;; 侧边栏宽度
  (setq ibuffer-sidebar-width 30)
  ;; 自动刷新侧边栏（秒）
  (setq ibuffer-sidebar-refresh-timer 2)
  ;; 开启自动刷新命令钩子
  (setq ibuffer-sidebar-refresh-on-special-commands t))
(add-hook 'ibuffer-mode-hook
          (lambda ()
            ;; 切换到名为 "default" 的过滤组
            (ibuffer-switch-to-saved-filter-groups "default")))
(add-hook 'emacs-startup-hook #'ibuffer-sidebar-show-sidebar)

;; ===========================
;; Ivy
;; ===========================
(use-package ivy
  :ensure t
  :diminish (ivy-mode . "")
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-re-builders-alist '((swiper . ivy--regex-plus)
                                (t . ivy--regex-fuzzy))))

;; ===========================
;; Counsel
;; ===========================
(use-package counsel
  :ensure t
  :after ivy
  :config
  (counsel-mode 1)
  :bind (("M-x"     . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b"   . counsel-switch-buffer)
         ("C-c f"   . counsel-git)
         ("C-c j"   . counsel-imenu)))

;; ===========================
;; Swiper
;; ===========================
(use-package swiper
  :ensure t
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

;; ===========================
;; Rust 支持
;; ===========================
(use-package rust-mode
  :hook (rust-mode . (lambda () (setq indent-tabs-mode nil)))
  :config
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode)))

;; ===========================
;; 字体与主题
;; ===========================
(set-face-attribute 'default nil :height 160)
(use-package modus-themes
  :init (load-theme 'modus-vivendi t))

;; ===========================
;; Custom-set 由 Emacs 自动管理
;; ===========================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
