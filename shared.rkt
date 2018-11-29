#lang racket
(require 2htdp/universe 2htdp/image)

#|
Client Package: id-player(integer), pos-x-player(integer), shoot-status(boolean), shoot-pos(posn)

Server Bundle: pos-x-player-1(integer), skin-player-1(integer),
	       pos-x-player-2(integer), skin-player-2(integer),
	       shoot-status-player-1(boolean), shoot-pos-player-1(integer), 
               shoot-status-player-2(boolean), shoot-pos-player-2(integer), 
	       game-running(boolean), winner-id(integer)

Local Processing: player-move, render-all, time-progression, bullet-calculation
Server Processing: hit-player, game-over

A Client->Server Package will be sent when:
I : A movement processing occur
II: A bullet calculation occur
A Server->Client Bundle will be sent when:
I : On Tick

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
(provide GRAVITY PROPORTION BASE-RESOLUTION RESOLUTION WIDTH HEIGHT)

;Auxiliar functions to convert between pixels and meters
(define (pixels->meters pixels)
  (/ (* PLAYER-HEIGHT pixels) BASE-RESOLUTION))
(define (meters->pixels meters)
  (/ (* BASE-RESOLUTION meters) PLAYER-HEIGHT))
(provide pixels->meters meters->pixels)

;Sprites
(define BACKGROUND     (scale PROPORTION (bitmap "graphics/Background/Background.png")))
(define LOADING-SCREEN (scale PROPORTION (bitmap "graphics/Background/Loading_Screen.png")))
(provide BACKGROUND LOADING-SCREEN)

;Skin and Shoot structures
(struct skin [stancing walking empty-stancing empty-walking shoot] #:transparent)
(struct shoot [frame-1 frame-2] #:transparent)
(provide (struct-out skin) (struct-out shoot))

;Skins definitions
(define ARROW    (shoot
                       (scale PROPORTION (bitmap "graphics/Shoots/Arrow_01.png"))
                       (scale PROPORTION (bitmap "graphics/Shoots/Arrow_02.png"))))
(define FIREBALL (shoot
                       (scale PROPORTION (bitmap "graphics/Shoots/Fire_01.png"))
                       (scale PROPORTION (bitmap "graphics/Shoots/Fire_02.png"))))
(define RANGER-1 (skin
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Walking_1.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Empty_Arrow_Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/1/Empty_Arrow_Walking_1.png"))
                       ARROW))
(define RANGER-2 (skin
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Walking_2.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Empty_Arrow_Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/2/Empty_Arrow_Walking_2.png"))
                       ARROW))
(define RANGER-3 (skin
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Stancing_3.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Walking_3.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Empty_Arrow_Stancing_3.png"))
                       (scale PROPORTION (bitmap "graphics/Ranger/3/Empty_Arrow_Walking_3.png"))
                       ARROW))
(define WIZARD-1 (skin
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Walking_1.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Empty_Fireball_Stancing_1.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/1/Empty_Fireball_Walking_1.png"))
                       FIREBALL))
(define WIZARD-2 (skin
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Walking_2.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Empty_Fireball_Stancing_2.png"))
                       (scale PROPORTION (bitmap "graphics/Wizard/2/Empty_Fireball_Walking_2.png"))
                       FIREBALL))
(define WIZARD-3 (skin
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