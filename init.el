(setq gc-cons-threshold 32000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;;key binding
(global-set-key (kbd "<f9>") 'other-window)
(global-set-key (kbd "<f11>") 'previous-buffer)
(global-set-key (kbd "<f12>") 'next-buffer)
(global-unset-key (kbd "C-x b"))

;;display style
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(global-hl-line-mode 1);;highlight current line
(show-paren-mode t);;highlight brackets
(global-font-lock-mode t);;highlight grammer
(electric-pair-mode 1);;key pair auto fill
(setq electric-pair-pairs
      '(
		(?\" . ?\")  
		(?\{ . ?\})  
		(?\' . ?\')
        (?\< . ?\>)))

;;coding style
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
                ;; (arglist-cont-nonempty . +)
                (template-args-cont . +))))
(setq c-default-style "microsoft")

;;basic package configuration
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

(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 3) 
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay 0.0)
  (setq company-show-numbers t) 
  (setq company-selection-wrap-around t)
  (setq company-transformers '(company-sort-by-occurrence))) 

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
  :config
  (ivy-mode 1))
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)

(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(set-face-attribute 'default nil :height 160)
(use-package modus-themes
  :ensure t
  :init
  (load-theme 'modus-vivendi t))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(modus-vivendi-theme cmake-mode use-package swiper company)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
