(local lum (require "lib.lume"))

(local default-state {:num-letters-printed 0
                      :cursor-pos 1
                      :started 0
                      })

;; State for the current game mode
(var state (or _G.state default-state))
(set _G.state state)

(local letter-width 10)

(local green [0 1 0 1]) ; yet to type this letter
(local blue [0 0 1 1]) ; nothing yet
(local white [1 1 1 1]) ; typed this letter correctly

(fn reset! [context]
  "Resets the state for this mode and also the context"
  (print "resetting...")
  (set state default-state)
  (set _G.state default-state)
  (set context.last-wpm 0))

(fn lookup [letter]
  (match letter
    " " "space"
    _ letter))

(fn pressed? [key]
  "Convert real text into something that can be checked by love2d"
  (let [cleaned-letter (-> key
        string.lower
        lookup)]
    ; TODO: love.keypressed( key, unicode )
    (love.keyboard.isDown cleaned-letter)))

; TODO: Figure out how to specifically test upper/lowercase
(local exercise 
  ["T" "h" "e" " " "a" "d" "v" "e" "n" "t" "u" "r" "e" "s" " " "o" "f" " " "b" "e" "a" "v" "i" "s" " " "b" "u" "t" "t" "h" "e" "a" "d" " " "a" "n" "d" " " "c" "o" "r" "n" "h" "o" "l" "i" "o"])

(fn num-spaces [text-coll]
  (lum.count text-coll (fn [letter] (= letter " "))))

(fn num-words [text-coll]
  "Given the number of spaces, calculate the number of words"
  (+ (num-spaces text-coll) 1))

(fn minutes [seconds]
  (/ seconds 60))

(fn duration [start end]
  (- end start))

(fn now []
  "Get current time, in seconds (includes decimals)"
  (love.timer.getTime))

(fn words-completed [exercise position]
  "Number of words completed if you got to this position"
  (num-words (lum.slice exercise 1 position)))
  
(fn wpm [start text cursor-pos]
  (/ (words-completed text cursor-pos) (minutes (duration start (now)))))

(fn format-wpm [start text cursor-pos]
  (if (> cursor-pos 1)
      (string.format "%s wpm" (wpm start text cursor-pos))
      (string.format "Press key to start")))


(fn start-measuring-wpm [cursor-pos started]
  "Is it time to start measuring WPM? Returns false if already started."
  (and (> cursor-pos 1) (= started 0)))

;;; drawining stuff

(fn pick-color [cursor-pos index]
  (if (> index cursor-pos)
      green
      white))

(fn next-position [seen width-px]
  "Gives you the position of the next letter based on how many have been seen so far.

  Note: If hard coding is no good, use font:getWidth letter
  to calculate the width of a letter:
    (local font (love.graphics.getFont))
    (print (font:getWidth \"w\"))"
  (* seen width-px))

(fn draw-prompt [state exercise]
  (love.graphics.print (format-wpm state.started exercise state.cursor-pos) 10 500)
  (set state.num-letters-printed 0)
  (each [index letter (ipairs exercise)]
    (love.graphics.print [(pick-color state.cursor-pos index) letter] (next-position state.num-letters-printed letter-width) 10)
    (set state.num-letters-printed (+ state.num-letters-printed 1))))

(fn start-new-game? [last-wpm cursor-pos]
  (and (> last-wpm 0) (> cursor-pos 1)))

{:draw (fn draw [message]
         (draw-prompt state exercise))
 :update (fn update [dt set-mode context]
           (print (fennel.view {:state state :context context}))
           ;; Player has come back from game-over screen, reset everything
           (when (start-new-game? context.last-wpm state.cursor-pos) (reset! context))
           (pp state.cursor-pos)
           (pp (length exercise))
           (pp "------")
           (when (start-measuring-wpm state.cursor-pos state.started) (set state.started (love.timer.getTime)))
           (when (= (- state.cursor-pos 1) (length exercise))
             (set context.last-wpm (wpm state.started exercise state.cursor-pos))
             (set-mode :mode-over)))

 :keypressed (fn keypressed [key set-mode]
               (when (pressed? (. exercise state.cursor-pos))
                 (set state.cursor-pos (+ state.cursor-pos 1))))}

