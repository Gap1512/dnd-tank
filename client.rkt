#lang racket
(require 2htdp/universe 2htdp/image "shared.rkt")

;;Client state is one of:
;;-string
;;-integer
(define client-state-0 "none available")

;;WorldState -> Image
;;Renders The Whole Scene
(define (render ws)
  (apply overlay
         (append
          (map (λ (player shoot)
                 (place-image
                  (if (shoot-status shoot)
                      (let ([shoot-frame
                             (if (< 5 (remainder (ws-time ws) 10))
                                  (shoot-aux-frame-1 (skin-aux-shoot-aux (select-skin (player-skin player))))
                                  (shoot-aux-frame-2 (skin-aux-shoot-aux (select-skin (player-skin player)))))])
                        (if (zero? (player-id player))
                            shoot-frame
                            (flip-horizontal shoot-frame)))
                      empty-image)
                  (posn-x (shoot-posn shoot))
                  (posn-y (shoot-posn shoot))
                  (place-image
                   (if (zero? (player-id player))
                       (get-frame player shoot)
                       (flip-horizontal (get-frame player shoot)))
                   (player-pos-x player)
                   (- HEIGHT (/ RESOLUTION 1.5))
                   EMPTY-BACKGROUND)))
               (ws-players ws)
               (ws-shoots ws))
          (list BACKGROUND))))

;;Player Shoot -> Image
(define (get-frame player shoot)
  (if (shoot-status shoot)
      (skin-aux-empty-stancing (select-skin (player-skin player)))
      (skin-aux-stancing       (select-skin (player-skin player)))))

;;Test
#|
> (animate (λ (time) (render
   (ws time (list (player 0 (select-skin 5) time) (player 1 (select-skin 1) (- WIDTH time)))
          (list (shoot 0 (posn 40 40) #t) (shoot 0 (posn 60 40) #t)) #t 0))))

> (render
   (ws 5
       (list
        (player 0 (select-skin 5) 85)
        (player 1 (select-skin 1) 128))
       (list
        (shoot 0 (posn 40 40) #t)
        (shoot 0 (posn 60 40) #f))
       #t
       0))
|#