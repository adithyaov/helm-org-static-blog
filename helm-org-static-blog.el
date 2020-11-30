;;; helm-org-static-blog.el --- Manage files related to org-static-blog via helm

;; Copyright 2020 Adithya Obilisetty
;;
;; Author: Adithya Obilisetty <adi.obilisetty@gmail.com>
;; Maintainer: Adithya Obilisetty <adi.obilisetty@gmail.com>
;; Keywords: helm blog org
;; URL: https://github.com/adithyaov/helm-org-static-blog
;; Created: 30th November 2020
;; Version: 0.1.0
;; Package-Requires: ((helm "0.0.0") (org-static-blog "1.4.0"))

;;; Commentary:

;; A simple (primitive) package to manage the posts and drafts defined by
;; variables in org-static-blog configuration.

;; No additional configuration is needed. This package will work properly if
;; org-static-blog is configured properly.

;;; Code:

(require 'helm)
(require 'org-static-blog)

(defun hosb-find-post (post-name)
  (find-file (concat-to-dir org-static-blog-posts-directory post-name)))

(defun hosb-find-draft (draft-name)
  (find-file (concat-to-dir org-static-blog-drafts-directory draft-name)))

(defun hosb-unpublish (draft-name)
  (let ((from (concat-to-dir org-static-blog-drafts-directory draft-name))
	(to (concat-to-dir org-static-blog-posts-directory draft-name)))
    (when (file-exists-p from)
      (rename-file from to)
      (org-static-blog-publish))))

(defun hosb-publish (post-name)
  (let ((from (concat-to-dir org-static-blog-posts-directory post-name))
	(to (concat-to-dir org-static-blog-drafts-directory post-name)))
    (when (file-exists-p from)
      (rename-file from to)
      (org-static-blog-publish))))

(setq hosb-posts-source
      (helm-build-sync-source "Posts"
	:candidates #'org-static-blog-get-post-filenames
	:candidate-transformer (lambda (ls) (mapcar #'file-name-nondirectory ls))
	:action '(("Open this file" . hosb-find-post)
		  ("Unpublish" . hosb-publish))
	:persistent-action 'hosb-find-post))

(setq hosb-drafts-source
      (helm-build-sync-source "Drafts"
	:candidates #'org-static-blog-get-draft-filenames
	:candidate-transformer (lambda (ls) (mapcar #'file-name-nondirectory ls))
	:action '(("Open this file" . hosb-find-draft)
		  ("Publish" . hosb-unpublish))
	:persistent-action 'hosb-find-draft))

(setq hosb-commands-source
      (helm-build-sync-source "Commands"
	:candidates '(org-static-blog-publish org-static-blog-clean)
	:persistent-action (lambda (c) (funcall (intern-soft c)))))

;;;###autoload
(defun helm-org-static-blog ()
  (interactive)
  (helm :sources '(hosb-posts-source
		   hosb-drafts-source
		   hosb-commands-source)
	:buffer "*helm-org-static-blog*"))

(provide 'helm-org-static-blog)
