;-------------------------------------------------
;Countdown / Zaehlt auf Null
;in Minuten und Sekunden
;
; mit 4x7-segment anzeige
;
; P2.0 =  1er Sekunden => P3=R2
; P2.1 = 10er Sekunden => P3=R3
; P2.2 =  1er Minuten  => P3=R4
; P2.3 = 10er Minuten  => P3=R5
;
; Hauptprogrammschleife
;
; Start = P1.0
; Stop  = P1.1
; Reset = P1.2
; -------------------------------------------------
cseg at 0h
ajmp init
cseg at 100h

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
init:
mov IE, #10010010b
mov tmod, #00000010b
mov R7, #00h
mov R5, #00h
mov tl0, #0c0h  ; Timer-Initionalsierung 
mov th0, #0c0h
mov P2,#10000111b
setb P0.0 ; Merker für RESET

mov 18h, #11111110b
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

mov P3, #00b
;-----------------------------------------------------------------------
; die Voreingestellten Minuten und Sekunden erscheinen auf dem Display
;-----------------------------------------------------------------------
call zeigen
;---------------------------
anfang:
jnb p2.0, starttimer
jnb p2.1, stoptimer
nurRT:
jnb p2.2, RT
jnb tr0, da
ajmp anfang
da:
call display
jnb P2.3, nurRT
ajmp anfang
;------------------------------
; Hauptprogrammschleife
;
; Start = P1.0
; Stop  = P1.1
; Reset = P1.2
;------------------------------
starttimer:
setb tr0; start timer0
mov P3, #01b
setb P2.0
ajmp anfang
; stop Timer
stoptimer:
clr tr0; stop timer
setb P2.1
ajmp init
; reset Timer
RT:
clr tr0; stop timer
setb P2.2
ljmp init
;---------------------------------------------
; timer
; Zählt 1 Sekunde: 25 mal 40 Millisekunden
; 24mal wird nur die Anzeige "refresht"
; beim 25mal wird die Zeit runter gezählt
;(hier: nur 2mal und nur wenige my Sekunden)
;---------------------------------------------
timer:
cjne R5, #04h, nichtFertig
clr tr0
clr P2.7
ret

nichtFertig:
inc r1
cjne r1, #01h, nuranzeige
mov r1, #00h
call countdown
ret

nuranzeige:
call display
ret

countdown:
call display

mov A, P3
add A, A
cjne A, #10000b, schreibezurück
mov P3, #01b
inc R7

cjne R7, #01h, weiter01
mov R7, #00h
inc R5

weiter01:

call display
ret

schreibezurück:
mov P3, A
call display
ret

;mov P3, #0b
;mov A, 1Ch
;subb A, #00101000b
;orl A, #0b
;call checkP3_0
;
;
;mov A, 1Dh
;subb A, #01000100b
;orl A, #0b
;call checkP3_1
;
;
;mov A, 1Eh
;subb A, #10000010b
;orl A, #0b
;call checkP3_2
;
;mov A, 1Fh
;subb A, #10000010b
;orl A, #0b
;call checkP3_3
;
;
;mov A, P3
;call bewegeKorn
;
;call zurückschreibenP3_0
;call zurückschreibenP3_1
;call zurückschreibenP3_2
;call zurückschreibenP3_3
;
;cjne R7, #02h, displayAndRet
;mov R7, #0h
;cjne R5, #00h, reihe3_2_1
;;alles leer
;inc R5
;mov 2Fh, #11111110b
;jmp displayAndRet

reihe3_2_1:
cjne R5, #01h, reihe2_1
;4. zeile schon voll
inc R5
mov 2Eh, #11111110b
jmp displayAndRet

reihe2_1:
cjne R5, #02h, reihe1
;3. zeile schon voll
inc R5
mov 2Dh, #01111100b
jmp displayAndRet

reihe1:
; 2. zeile schon voll
inc R5
mov 2Ch, #00111000b
jmp displayAndRet


displayAndRet:
call display
ret

zurückschreibenP3_0:
jnb P3.0, set1C
mov 1Ch, #00111000b
ret
set1C:
mov 1Ch, #00101000b
ret

zurückschreibenP3_1:
jnb P3.1, set1D
mov 1Dh, #01010100b
ret
set1D:
mov 1Dh, #01000100b
ret

zurückschreibenP3_2:
jnb P3.2, set1E
mov 1Eh, #10010010b
ret
set1E:
mov 1Eh, #10000010b
ret

zurückschreibenP3_3:
jnb P3.3, set1F
mov 1Fh, #10010010b
ret
set1F:
mov 1Fh, #10000010b
ret



bewegeKorn:
cjne A, #00000000b, bewegeKornNachVorn
setb P3.0
ret


bewegeKornNachVorn:
mov R6, P3
cjne R6, #01000b, macheWeiter
inc R7
mov P3, #00000001b
ret

macheWeiter:
add A, A
mov P3, A
ret


checkP3_0:
cjne A, #0b, setzeP3_0
ret
setzeP3_0:
setb P3.0
ret

checkP3_1:
cjne A, #0b, setzeP3_1
ret
setzeP3_1:
setb P3.1
ret

checkP3_2:
cjne A, #0b, setzeP3_2
ret
setzeP3_2:
setb P3.2
ret

checkP3_3:
cjne A, #0b, setzeP3_3
ret
setzeP3_3:
setb P3.3
ret




countdownAlt:
cjne r6, #0h, sekunden
cjne r7, #0h, minuten
hupe:
clr tr0; stop timer
clr P2.3
ret

minuten:
mov r6, #3bh
dec r7
call zeigen
ret
sekunden:
dec r6
call zeigen
ret
;-------------------------------------------------------
; Anzeigewerte: holt die Anzeigewerte aus der Datenbank
; - erst wird aus dem Hex_Wert ein Dezimalwert : BCD-Umrechnung
; dann wird der Wert mit @A+DPTR aus der Datenbank 
; in die Register geschrieben
; 1er Sekunden => P3=R2
; 10er Sekunden => P3=R3
; 1er Minuten  => P3=R4
; 10er Minuten  => P3=R5
;-------------------------------------------------------
zeigen:


;mov DPTR, #table
;mov a, R6
;mov b, #0ah
;div ab
;mov R0, a
;movc a,@a+dptr
;mov r3, a
;mov a, r0
;xch a,b
;movc a, @a+dptr
;mov r2, a
;;----------------
;mov a, R7
;mov b, #0ah
;div ab
;mov R0, a
;movc a,@a+dptr
;mov r5, a
;mov a, r0
;xch a,b
;movc a, @a+dptr
;mov r4, a
;call display
ret
;-----------------------------------------------
;   DISPLAY: steuert die 4x7 Segmentanzeige
;-----------------------------------------------
display:


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
mov p0, #00h


mov A, 1Ch

cjne R5, #04h, weiter001
mov 2Ch, #00010000b

weiter001:

orl A, 2Ch

jnb P3.0, weiter1
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

jnb P3.1, weiter2
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

jnb P3.2, weiter3
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

jnb P3.3, weiter4
orl A, #00010000b
weiter4:

mov p1, A
mov p0, #00000001b
mov p0, #00h
ret

;-------------------------------------------------
; TABLE: Datenbank der 7-Segment-Darstellung
;-------------------------------------------------
org 300h
table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b

end