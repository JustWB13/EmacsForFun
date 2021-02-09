;;import package
(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)
;;开始界面
(setq initial-buffer-choice "~/start.org")
;;一键编译
(defun compile-file ()(interactive)(compile (format "g++ -o %s %s -g -std=c++11 -lm -Wall" (file-name-sans-extension (buffer-name))(buffer-name))))
(global-set-key [f9] 'compile-file)
;;括号补全
(electric-pair-mode 1)
(setq electric-pair-pairs
      '(
		(?\" . ?\")  ;; 添加双引号补齐
		(?\{ . ?\})  ;; 添加大括号补齐
		(?\' . ?\'))) ;; 添加单引号补齐
;;fundamental settings
(setq-default indent-tabs-mode nil)
(setq c-basic-offset 4)
(setq c-default-style "linux")
(setq default-tab-width 4)
(setq make-backup-files nil)
(global-linum-mode t)
(setq-default frame-title-format "")
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(global-hl-line-mode 1);;高亮当前行
(show-paren-mode t);;高亮匹配括号
(global-font-lock-mode t);;语法高亮
;;auto-complete setup
(add-to-list 'load-path "~/.emacs.d/elpa/auto-complete-20201213.1255")
(require 'auto-complete)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/elpa/auto-complete-20201213.1255/dict")
(require 'auto-complete-config)
(add-to-list 'load-path "~/.emacs.d/elpa/auto-complete-clang-20140409.752/")
(require 'auto-complete-clang)  
;; 设置不自动启动
(setq ac-auto-start nil)  
;; 设置响应时间 0.5
(setq ac-quick-help-delay 0.5)  
;;(ac-set-trigger-key "TAB")  
;;(define-key ac-mode-map  [(control tab)] 'auto-complete)  
;; 提示快捷键为 M-/
(define-key ac-mode-map  (kbd "<f1>") 'auto-complete) 
(defun my-ac-config ()  
  (setq ac-clang-flags  
        (mapcar(lambda (item)(concat "-I" item))  
               (split-string  
                "
/usr/local/include
 /Library/Developer/CommandLineTools/usr/bin/../include/c++/v1
 /Library/Developer/CommandLineTools/usr/lib/clang/12.0.0/include
 /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include
 /Library/Developer/CommandLineTools/usr/include
 /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks (framework directory)
"
)))  
(setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))  
(add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)  
(add-hook 'c-mode-common-hook 'ac-cc-mode-setup)  
(add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)  
(add-hook 'css-mode-hook 'ac-css-mode-setup)  
(add-hook 'auto-complete-mode-hook 'ac-common-setup)  
(global-auto-complete-mode t))  
(defun my-ac-cc-mode-setup ()  
  (setq ac-sources (append '(ac-source-clang ac-source-yasnippet) ac-sources)))  
(add-hook 'c-mode-common-hook 'my-ac-cc-mode-setup)  
;; ac-source-gtags  
(my-ac-config)  
(ac-config-default)
;;auto-complete setup end
