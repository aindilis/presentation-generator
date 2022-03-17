(figure out how to play a video over zoom - test ahead of time)
(also, just play over the speakers if I cannot get the video's
 audio to work during the screenshare)

(include something at the beginning of the talk apologizing for
 the use of TTS, and also asking them to type any questions into
 the chat which I could then answer)

(2022-03-15 17:13:12 <sarnold> aindilis: hhmm, I wonder if a tool like selenium
      might do the trick? I think it's *way* heavier than xdotool or figuring
      out how to set configs at launch, if that's possible -- but it's pretty
      popular for web automation tasks)


(https://videoblerg.wordpress.com/2017/11/10/ffmpeg-and-how-to-use-it-wrong/)

(it's hard to sync them by running ffmpeg simultaneously, so I
 should record the video with
 /var/lib/myfrdcsa/codebases/minor/presentation-generator/scripts/run.sh,
 and then then open OBS, set up to record from the Sound Out, and
 then run run-audio.sh to replay the presentaiton.  Then import
 both files, and manually sync them.  It's somewhat tedious to do
 that.  So I can generate most of the presentation first.  Also,
 need to restablish the usual Festival TTS in order to tweak the
 presentation without wasting GCloud API hits, causing undue expenses)

(will need to troubleshoot to get rid of TTS "noise", like http :
 / / frdcsa . org / etc)


(BUGS:
 (fix the timeline having to have empty space manually removed)
 (fix the parameter of number of slides in the last script)
 (fix the PDDL problem goals, remove all but the last three, i.e.:
  (:goal
   (and
    (played ac45)
    (played ic45)
    (played vc45)
    ))
  )
 )



(https://github.com/hakimel/reveal.js/wiki/Plugins,-Tools-and-Hardware)

(use archive.org for public domain or cc-by-sa music)

(deleted
 (https://www.mltframework.org/))
(deleted
 (https://www.mltframework.org/changes/todo/))
(https://opentimelineio.readthedocs.io/en/latest/)
(https://arrayfire.com/)

(emacs-lisp -n :async :results verbatim raw (list2str (pen-long-complete (pf-asktutor "vscode" "packages" "What are some useful packages?" :no-select-result t))))

;; (docker run --rm -v "$(shell pwd):/$(shell pwd | scripts/slugify)" -ti --entrypoint= semiosis/pen.el:latest ./run.sh)
(docker run --rm -v "$(pwd):/$(pwd | scripts/slugify)" -ti --entrypoint= semiosis/pen.el:latest ./run.sh)

(2021-07-27 20:45:18 <IrcsomeBot_> <frdbr> @aindilis checkout freemusicarchive,
      youtube music, sound cloud
2021-07-27 20:45:24 <IrcsomeBot_> <frdbr> they all have cc music
2021-07-27 20:45:31 <IrcsomeBot_> <frdbr> even bandcamp
2021-07-27 20:46:05 <IrcsomeBot_> <frdbr> if you search, you'll find young padawan)

(https://wave.video/blog/how-we-render-animated-content-from-html5-canvas/)

(https://computingforgeeks.com/how-to-install-nodejs-on-ubuntu-debian-linux-mint/)

(source text -> Text::Fracture -> Lingua::EN::Sentence
 get_sentences -> GPT-3 -> Bullet Points -> [INSERT HIGHLIGHTER]
 -> Reveal.js -> Xvfb / ffmpeg -> mp4s, .pngs, and .wavs -> PDDL
 2.2 -> otio.xml -> .kdenlive -> final.mp4)

(to autoscroll a webpage page, for recording screencaps:
 ;; <script type="text/javascript">
 ;;    function pageScroll() {
 ;; 	window.scrollBy(0,10);
 ;; 	scrolldelay = setTimeout(pageScroll,10); 
 ;;    }
 ;;    window.onload = function () {
 ;; 	pageScroll();
 ;;    }
 ;;  </script>
 )

(https://wellsaidlabs.com/)

(festival data-git/config/fest.conf --server)
