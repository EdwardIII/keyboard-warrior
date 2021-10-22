{:draw (fn draw [context]
         (love.graphics.print (string.format "Your score: %s wpm. Play again? y/n" context.last-wpm)))

 :update (fn update [dt set-mode]
           )

 :keypressed (fn keypressed [key set-mode]
               (when (= key "y") (set-mode :mode-intro))
               (when (= key "n") (love.event.quit)))}

