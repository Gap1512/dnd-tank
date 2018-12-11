#lang racket
(require "shared.rkt" 2htdp/universe 2htdp/image)

;;Server state is one of:
;;-(state
;;  pos-x-player-1(integer), skin-player-1(integer),
;;  pos-x-player-2(integer), skin-player-2(integer),
;;  shoot-status-player-1(boolean), shoot-pos-player-1(integer), 
;;  shoot-status-player-2(boolean), shoot-pos-player-2(integer), 
;;  game-running(boolean), winner-id(integer))
;;-#f

;Initial State
(define ws0 (ws 0
                (list
                 (player 0 0 64)
                 (player 1 3 320))
                (list
                 (shoot 0 (posn 0 0) #f)
                 (shoot 0 (posn 0 0) #f))
                #f
                -1))

;Launch
(define (launch-dnd-tank-server)
  (universe ws0
            (on-new connect)
            (on-msg handle-msg)))

;Connection
(define (connect ws client)
  (if (false? u)
      (make-bundle s0)
      (make-bundle u empty (list client))))

;