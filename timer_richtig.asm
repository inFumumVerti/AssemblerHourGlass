;-------------------------------------------------
; Sanduhr
; 1 Minute und 5 Sekunden
;
;
; P0 = Y-Achse
; P1 = X-Achse
;
;
; Start = P1.0
; Stop/Reset  = P1.2#
; -------------------------------------------------
cseg at 0h
call start
cseg at 100h

; ------------------------------------------------
; Interrupt für P3.2 = EX0
;-------------------------------------------------
ORG 03h
call stoptimer
reti

; ------------------------------------------------
; Interrupt für TIMER0: Einsprung bei 0Bh
;-------------------------------------------------
ORG 0Bh
call timer
reti
;-------------------------------------------------------
;init: TIMER wird initialisiert
; für 40 ms benötigt man einen 16 bit Timer
; das dauert zu lange in der Simulation! 
; Daher hier eine kurze Variante!
; Es wird nur von C0h auf FFh hochgezählt und 
; dann der Timer wird auf C0h gesetzt
; (für Hardware müsste das ersetzt werden!)
;-------------------------------------------------------
ORG 20h
start:
call init
jmp anfang

init:
mov IE, #10000011b ; Interrupt-Initialisierung
mov tmod, #00000010b ; Timer-Initionalsierung 
mov tcon, #0b
clr t0
clr t1
mov tl0, #0b
mov th0, #0b
mov tl1, #0b
mov th1, #0b

mov tl0, #0c0h
mov th0, #0c0h

mov R7, #00h
mov R5, #00h
mov P3, #10000101b ; Initialisierung Keypad

mov 18h, #11111110b ; Initialisierung Gundlayout
mov 19h, #01111100b
mov 1Ah, #00111000b
mov 1Bh, #00010000b
mov 1Ch, #00101000b
mov 1Dh, #01000100b
mov 1Eh, #10000010b
mov 1Fh, #10000010b

mov 2Ch, #0h
mov 2Dh, #0h
mov 2Eh, #0h
mov 2Fh, #0h

mov R7, #0h
mov R5, #0h

mov P2, #00b
;-----------------------------------------------------------------------
; die Voreingestellten Minuten und Sekunden erscheinen auf dem Display
;-----------------------------------------------------------------------
call display
ret
;---------------------------
anfang:
jnb tr0, frageObStart
call display
jmp anfang

frageObStart:
jnb p3.0, starttimer
call display
jmp anfang


starttimer:
setb tr0; start timer0
mov P2, #01b
setb P3.0
ajmp anfang


stoptimer:
clr tr0; stop timer
setb P3.2
call init


;---------------------------------------------
; timer
; Zählt 1 Sekunde: 25 mal 40 Millisekunden
; 24mal wird nur die Anzeige "refresht"
; beim 25mal wird die Zeit runter gezählt
;(hier: nur 2 mal und nur wenige Sekunden)
;---------------------------------------------
timer:
cjne R5, #04h, nichtFertig
clr tr0
clr P3.7
ret

;---------------------------------------------
; timer
; Beim 3. Durchlauf fällt das Sandkorn ein Pixel nach unten.
;---------------------------------------------
nichtFertig:
inc r1
cjne r1, #02h, nuranzeige
mov r1, #00h
call countdown
ret

nuranzeige:
call display
ret



;--------------------------------
; Bewege das Sandkorn, Bit in P2 wird immer eine Position nach vorn gesetzt.
;--------------------------------
countdown:
call display

mov A, P2
add A, A
cjne A, #10000b, schreibezurück
mov P2, #01b
inc R7

cjne R7, #01h, weiter01
mov R7, #00h
inc R5

weiter01:

call display
ret

schreibezurück:
mov P2, A
call display
ret


;-----------------------------------------------
;   DISPLAY: steuert die LED Matrix
;-----------------------------------------------
display:
mov p0, #0b
mov p1, 18h
mov p0, #10000000b
mov p0, #00h
mov p1, 19h
mov p0, #01000000b
mov p0, #00h
mov p1, 1Ah
mov p0, #00100000b
mov p0, #00h
mov p1, 1Bh
mov p0, #00010000b
mov p0, #0b


mov A, 1Ch

cjne R5, #04h, weiter001
mov 2Ch, #00010000b

weiter001:

orl A, 2Ch

jnb P2.0, weiter1
orl A, #00010000b
weiter1:

mov p1, A
mov p0, #00001000b
mov p0, #00h







mov A, 1Dh

cjne R5, #03h, weiter002
mov 2Dh, #00111000b

weiter002:

orl A, 2Dh

jnb P2.1, weiter2
orl A, #00010000b
weiter2:

mov p1, A
mov p0, #00000100b
mov p0, #00h






mov A, 1Eh

cjne R5, #02h, weiter003
mov 2Eh, #01111100b

weiter003:

orl A, 2Eh

jnb P2.2, weiter3
orl A, #00010000b
weiter3:

mov p1, A
mov p0, #00000010b
mov p0, #00h





mov A, 1Fh

cjne R5, #01h, weiter004
mov 2Fh, #01111100b

weiter004:

orl A, 2Fh

jnb P2.3, weiter4
orl A, #00010000b
weiter4:

mov p1, A
mov p0, #00000001b
mov p0, #00h
ret

end