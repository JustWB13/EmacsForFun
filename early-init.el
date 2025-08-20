;;; early-init.el --- Loaded very early by Emacs 27+

;; 禁止自动加载 package.el
(setq package-enable-at-startup nil)

;; 默认 frame 参数
(setq default-frame-alist
      '((width . 100) (height . 40)
        (menu-bar-lines . 0) (tool-bar-lines . 0)))

;; 提高启动速度：延后 GC
(setq gc-cons-threshold most-positive-fixnum)

(provide 'early-init)
;;; early-init.el ends here
