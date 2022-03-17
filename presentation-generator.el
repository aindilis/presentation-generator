(global-set-key "\C-cpgr" 'presgen-run-generate-presentation)

(global-set-key "\C-cpgop" 'presgen-open-current-project-presentation-file)
(global-set-key "\C-cpgot" 'presgen-open-templates-directory)
(global-set-key "\C-cpgom" 'presgen-open-modules-directory)

(global-set-key "\C-cpgod" 'presgen-open-outputted-presentation-dir)
(global-set-key "\C-cpgoh" 'presgen-open-outputted-presentation-html-file)
(global-set-key "\C-cpgov" 'presgen-open-video-directory)

(add-to-list 'auto-mode-alist '("\\.kdenlive\\'" . nxml-mode))

(defun presgen-run-generate-pddl ()
 ""
 (interactive)
 (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/presentation-generator/scripts && ./generate-pddl-problem-from.pl"))

(defvar presgen-current-project-class "flp-videos")

(defun presgen-set-current-project-class ()
 ""
 (interactive))

(defvar presgen-current-project "flp-video-3")

(defun presgen-set-current-project ()
 ""
 (interactive))

(defun presgen-run-generate-presentation ()
 ""
 (interactive)
 (run-in-shell
  (concat
   "cd /var/lib/myfrdcsa/codebases/minor/presentation-generator && ./presgen "
   ;; "--video "
   "--tts "
   "--no "
   "-c "
   (shell-quote-argument presgen-current-project-class)
   " -p "
   (shell-quote-argument presgen-current-project))
  "*Presentation-Generator*"))

(defun presgen-open-current-project-presentation-file ()
 ""
 (interactive)
 (ffap
  (frdcsa-el-concat-dir
   (list
    "/var/lib/myfrdcsa/codebases/minor/flp-videos/data-git"
    presgen-current-project-class
    presgen-current-project
    "presentation.txt"))))

(defun presgen-open-templates-directory ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/presentation-generator/data-git/templates"))

(defun presgen-open-modules-directory ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/presentation-generator/PresGen/Mod"))

(defun presgen-open-outputted-presentation-dir ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/flp-videos/data-git/flp-videos/flp-video-3/slides/dummy"))

(defun presgen-open-outputted-presentation-html-file ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/flp-videos/data-git/flp-videos/flp-video-3/slides/dummy/s.html"))

(defun presgen-open-video-directory ()
 ""
 (interactive)
 (ffap "/media/andrewdo/SSD2/PresGen/projects/flp-videos/flp-video-3/videos"))
