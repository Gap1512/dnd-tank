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
(struct play [players shoots] #:mutable)

;Initial State
(define s0 (play RESOLUTION 0
                  (- WIDTH RESOLUTION) 0
                  #f (posn RESOLUTION (- HEIGHT SHOOT-HEIGHT))
                  #f (posn (- WIDTH RESOLUTION) (- HEIGHT SHOOT-HEIGHT))
                  #t 0))

;Launch
(define (launch-dnd-tank-server)
  (universe #f
            (on-new connect)
            (on-msg handle-msg)))

;Connection
(define (connect u client)
  (if (false? u)
      (make-bundle s0)
      (make-bundle u empty (list client))))