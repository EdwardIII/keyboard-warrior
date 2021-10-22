(local repl (require "lib.stdio"))
(fn love.load []
  (repl.start))

(local lume (require "lib.lume"))

; game statuses
:game-over
:in-game

(local state {:game-status :in-game
              :lettersseen 0
              :cursor-pos 1
              :started 0
              :last-wpm 0})

(local letter-width 10)

(fn lookup [letter]
  (match Letter
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
  (lume.count text-coll (fn [letter] (= letter " "))))

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
  (num-words (lume.slice exercise 1 position)))
  
(fn wpm [start text cursor-pos]
  (/ (words-completed text cursor-pos) (minutes (duration start (now)))))

(fn format-wpm [start text cursor-pos]
  (if (> cursor-pos 1)
      (string.format "%s wpm" (wpm start text cursor-pos))
      (string.format "Press key to start")))

(local green [0 1 0 1])
(local blue [0 0 1 1])
(local white [1 1 1 1])

(fn start-measuring-wpm [cursor-pos started]
  "Is it time to start measuring WPM? Returns false if already started."
  (and (> cursor-pos 1) (= started 0)))

(fn reset []
  "Resets all state except last-wpm"
  (set state.lettersseen 0)
  (set state.cursor-pos 1)
  (set state.started 0)
  (set state.game-status :in-game))

(fn love.update []
  (print (fennel.view {:state state :now (now)}))
  (when (start-measuring-wpm state.cursor-pos state.started) (set state.started (love.timer.getTime)))
  (when (= (- state.cursor-pos 1) (length exercise))
    (when (= state.last-wpm 0) (set state.last-wpm (wpm state.started exercise state.cursor-pos)))
    (set state.game-status :game-over)
    (when (pressed? "y")
            (reset))
    (when (pressed? "n") (love.event.quit)))
  
  (when (= state.game-status :in-game)
    (when (pressed? (. exercise state.cursor-pos))
      (set state.cursor-pos (+ state.cursor-pos 1)))))

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
  (set state.lettersseen 0)
  (each [index letter (ipairs exercise)]
    (love.graphics.print [(pick-color state.cursor-pos index) letter] (next-position state.lettersseen letter-width) 10)
    (set state.lettersseen (+ state.lettersseen 1))))

(fn draw-game-over []
  "y/n key presses are listened for in love.update"
  (love.graphics.print (string.format "Your score: %s wpm. Play again? y/n" state.last-wpm)))

(fn love.draw []
  (match state.game-status
    :in-game (draw-prompt state exercise)
    :game-over (draw-game-over)))

; TODO: <ane> you can also add a directory local variable so that whenever you open a
;      .fnl in that game directory it starts with "love ."               [19:28]
;  <ane> and you don't have to customize: <ane> you can do that with M-x add-dir-local-variable <ret> fennel-mode <ret>
;      fennel-program <ret> love . <ret>
