#lang racket
(require 2htdp/universe 2htdp/image)

#|
Client Functions: on-mouse, to-draw, on-key

Client Messages: type(string) id(string(iworld-name)), pos-x-player(integer), mouse-click(posn)
                 or
                 type(string) id(string(iworld-name)), pos-x-player(integer), pressed-key(string)

Server Bundle: time(integer),
               pos-x-player-1(integer), skin-player-1(integer),
	       pos-x-player-2(integer), skin-player-2(integer),
	       shoot-status-player-1(boolean), shoot-pos-player-1(integer), 
               shoot-status-player-2(boolean), shoot-pos-player-2(integer), 
	       game-running(boolean), winner-id(integer)

Local Processing: render
Server Processing: hit-player, game-over, player-move, render-all, time-progression, bullet-calculation

A Client->Server Package will be sent when:
I : A mouse event occur
II: A key is pressed
A Server->Client Bundle will be sent when:
I : Processing Ends

Shared Attributes: Sprites/Skins, Background, Properties (Gravity, Width, Height, Sprites Properties, Proportion)
|#

;Attributes
(define GRAVITY 370)
(define PROPORTION 1)
(define BASE-RESOLUTION 64)
(define RESOLUTION (* BASE-RESOLUTION PROPORTION))
(define WIDTH (* 6 BASE-RESOLUTION))
(define HEIGHT (* 3 BASE-RESOLUTION))
(define PLAYER-HEIGHT 1.75)
(define SHOOT-HEIGHT (- RESOLUTION 15))
(provide GRAVITY PROPORTION BASE-RESOLUTION RESOLUTION WIDTH HEIGHT SHOOT-HEIGHT)

;Auxiliar functions to convert between pixels and meters
(define (pixels->meters pixels)
  (/ (* PLAYER-HEIGHT pixels) BASE-RESOLUTION))
(define (meters->pixels meters)
  (/ (* BASE-RESOLUTION meters) PLAYER-HEIGHT))
(provide pixels->meters meters->pixels)

;Sprites
(define BACKGROUND       (scale PROPORTION (bitmap "graphics/Background/Background.png")))
(define EMPTY-BACKGROUND (scale PROPORTION (bitmap "graphics/Background/Empty_Background.png")))
(define LOADING-SCREEN   (scale PROPORTION (bitmap "graphics/Background/Loading_Screen.png")))
(provide BACKGROUND EMPTY-BACKGROUND LOADING-SCREEN)

;Skin, Shoot, Player and Posn structures
(struct skin-aux  [stancing walking empty-stancing empty-walking shoot-aux] #:transparent)
(struct shoot-aux [frame-1 frame-2]                                         #:transparent)
(struct posn      [x y]                                                     #:prefab)
(struct player    [id skin pos-x]                                           #:prefab)
(struct shoot     [id posn status]                                          #:prefab)
(struct ws        [time players shoots game-running winner-id]              #:prefab)
(provide (struct-out player) (struct-out ws) (struct-out shoot) (struct-out skin-aux) (struct-out shoot-aux) (struct-out posn))

;Skins definitions
(define ARROW    (shoot-aux
                       (scale PROPORTION (bitmap "graphics/Shoots/Arrow_01.png"))
                       (scale PROPORTION (bitmap "graphics/Shoots/Arrow_02.png"))))
(define FIREBALL (shoot-aux
                       (scale PROPORTION (bitmap "graphics/Shoots/Fire_01.png"))
                       (scale PROPORTION (bitmap "graphics/Shoots/Fire_02.png"))))
(define RANGER-1 (skin-aux
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Walking_1.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Empty_Arrow_Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Empty_Arrow_Walking_1.png"))
                       ARROW))
(define RANGER-2 (skin-aux
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Walking_2.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Empty_Arrow_Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Empty_Arrow_Walking_2.png"))
                       ARROW))
(define RANGER-3 (skin-aux
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Stancing_3.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Walking_3.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Empty_Arrow_Stancing_3.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Empty_Arrow_Walking_3.png"))
                       ARROW))
(define WIZARD-1 (skin-aux
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Walking_1.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Empty_Fireball_Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Empty_Fireball_Walking_1.png"))
                       FIREBALL))
(define WIZARD-2 (skin-aux
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Walking_2.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Empty_Fireball_Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Empty_Fireball_Walking_2.png"))
                       FIREBALL))
(define WIZARD-3 (skin-aux
                       (scale PROPORTION (bitmap "graphics/Wizard/3/Stancing_3.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/3/Walking_3.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/3/Empty_Fireball_Stancing_3.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/3/Empty_Fireball_Walking_3.png"))
                       FIREBALL))
(define SKIN-LIST (list RANGER-1 RANGER-2 RANGER-3 WIZARD-1 WIZARD-2 WIZARD-3))

;Id -> Skin
;Return the correspond shoot for given id
(define (select-skin id)
  (list-ref SKIN-LIST id))
(provide select-skin)