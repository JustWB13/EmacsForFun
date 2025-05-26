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
(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;; ===========================
;; 自动补全 company
;; ===========================
(use-package company
  :init (global-company-mode)
  :hook (lsp-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 3
        company-tooltip-align-annotations t
        company-idle-delay 0.5
        company-show-numbers t
        company-selection-wrap-around t
        company-transformers '(company-sort-by-backend-importance
                               company-sort-by-occurrence)))

;; ===========================
;; LSP 支持
;; ===========================
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-auto-guess-root t
        lsp-keep-workspace-alive nil
        lsp-enable-auto-install t))

;; ===========================
;; 快捷提示 which-key
;; ===========================
(use-package which-key
  :config (which-key-mode))

;; ===========================
;; 语法检查 flycheck
;; ===========================
(use-package flycheck
  :init (global-flycheck-mode))

;; ===========================
;; 选项卡 centaur-tabs
;; ===========================
(use-package centaur-tabs
  :demand
  :config (centaur-tabs-mode t))

;; ===========================
;; 项目管理 projectile (已注释)
;; ===========================
;; (use-package projectile
;;   :config (projectile-mode +1))

;; ===========================
;; 文件树 treemacs (已注释)
;; ===========================
;; (use-package treemacs
;;   :defer t
;;   :config
;;   (global-set-key (kbd "C-c r") 'treemacs-remove-project-from-workspace)
;;   (global-set-key (kbd "C-c a") 'treemacs-add-project-to-workspace))
;; (use-package treemacs-projectile
;;   :after (treemacs projectile))
;; (global-set-key (kbd "C-c t") 'treemacs)

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
;; Ivy + Swiper
;; ===========================
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config (ivy-mode 1))
;;

(use-package counsel
  :ensure t
  :after ivy)  ;; C-x b 用于快速切换 buffer
(global-set-key (kbd "C-x b") 'counsel-switch-buffer)

(use-package swiper
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
