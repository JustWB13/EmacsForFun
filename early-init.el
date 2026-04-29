;;; early-init.el --- Loaded very early by Emacs 27+  -*- lexical-binding: t; -*-

;; 禁止自动加载 package.el
(setq package-enable-at-startup nil)

;; 默认 frame 参数
(setq default-frame-alist
      '((width . 100) (height . 40)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)))

;; 启动时不让字体/工具栏触发隐式 resize
(setq frame-inhibit-implied-resize t)

;; 关闭欢迎屏幕
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; 提高启动速度：延后 GC（gcmh 启动后会接管）
(setq gc-cons-threshold most-positive-fixnum)

;;; early-init.el ends here
