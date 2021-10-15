(require "love.event")
(local {: view} (require :lib.fennel))

;; This module exists in order to expose stdio over a channel so that it
;; can be used in a non-blocking way from another thread.

(local (event channel) ...)

(fn prompt [next-line?]
  (io.write (if next-line? ".." ">> ")) (io.flush) (.. (io.read) "\n"))

(when channel
  ((fn looper []
     (match (channel:demand)
         [:out vals] (do (io.write (table.concat vals "\t"))
                         (io.write "\n"))
         [:read stack-size] (love.event.push event (prompt (< 0 stack-size))))
     (looper))))

{:start (fn start-repl []
          (let [code (love.filesystem.read "lib/stdio.fnl")
                luac (if code
                         (love.filesystem.newFileData
                          (fennel.compileString code) "io")
                         (love.filesystem.read "lib/stdio.lua"))
                thread (love.thread.newThread luac)
                io-channel (love.thread.newChannel)
                coro (coroutine.create fennel.repl)
                out (fn [...]
                      (io-channel:push [:out ...]))
                options {:readChunk (fn [{: stack-size}]
                                      (io-channel:push [:read stack-size])
                                      (coroutine.yield))
                         :onValues out
                         :onError (fn [errtype err]
                                    (io-channel:push [:out [err]]))
                         :moduleName "lib.fennel"}]
            ;; this thread will send "eval" events for us to consume:
            (coroutine.resume coro options)
            (: thread :start "eval" io-channel)
            (set love.handlers.eval
                 (fn [input]
                   (coroutine.resume coro  input)))))}
