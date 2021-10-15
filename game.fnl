(local repl (require "lib.stdio"))
(local lume (require "lib.lume"))

(fn love.load []
  (repl.start))

; game statuses
:game-over
:in-game

(local state {:game-status :in-game
              :lettersseen 0
              :cursorpos 1
              :started 0})

(local letter-width 10)

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
  
(fn wpm [start text letters-seen]
  (/ (words-completed text letters-seen) (minutes (duration start (now)))))

(fn format-wpm [start text letters-seen]
  (string.format "%s wpm" (wpm start text letters-seen)))


(local green [0 1 0 1])
(local blue [0 0 1 1])
(local white [1 1 1 1])

(fn love.update []
  (when (= state.started 0) (set state.started (love.timer.getTime)))
  (when (= (- state.cursorpos 1) (length exercise))
    (set state.game-status :game-over))
  (when (= state.game-status :in-game)
    (when (pressed? (. exercise state.cursorpos))
      (set state.cursorpos (+ state.cursorpos 1)))))

(fn pick-color [cursor-pos index]
  (if (> index cursor-pos)
    green
    white))
  
(fn next-position [seen width-px]
  "Gives you the position of the next letter based on how many have been seen so far.

  Note: use font:getWidth letter to calculate the width of a letter
  (local font (love.graphics.getFont))
  (print (font:getWidth \"w\"))"

  (* seen width-px))

(fn draw-prompt [state exercise]
  ; TODO: Only start on first keypress

  ;(love.graphics.print (format-wpm state.started exercise) 10 500)
  (love.graphics.print (format-wpm state.started exercise state.lettersseen) 10 500)
  (set state.lettersseen 0)
  (each [index letter (ipairs exercise)]
    (love.graphics.print [(pick-color state.cursorpos index) letter] (next-position state.lettersseen letter-width) 10)
    (set state.lettersseen (+ state.lettersseen 1))))

(fn draw-game-over []
  (love.graphics.print "Good game, play again? y/n"))


(fn love.draw []
  (match state.game-status
    :in-game (draw-prompt state exercise)
    :game-over (draw-game-over)))
