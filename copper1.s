  incdir       "../include/"
  include      "exec/types.i"
  include      "exec/funcdef.i"
  include      "exec/exec_lib.i"
  include      "libraries/dos.i"
  include      "libraries/dos_lib.i"
  INCLUDE      "hw.i"
  include      "myinc.i"
           
  section      DEMO,CODE
  XDEF         Copper1
           
Copper1:
  lea          OldCop(PC),a4                                 ; salviamo l'indirizzo della copperlist vecchia
  jsr          SaveCopper
    
  move         CUSTOM+INTENAR,OldIntenar                     ; salvo l'attuale stato di INTENAR ($01C)
  move         #$7FFF,CUSTOM+INTENA                          ; Disabilita i bit in INTENA ($09A)

;	 PUNTIAMO IL NOSTRO BITPLANE

  move.l       #PIC,d0                                       ; in d0 mettiamo l'indirizzo della PIC,
  lea          BPLPOINTERS,A1                                ; puntatori nella COPPERLIST
  moveq        #2,D1                                         ; numero di bitplanes -1 (qua sono 3)
bitplaneLoop:
  move.w       d0,6(a1)                                      ; copia la word BASSA dell'indirizzo del plane
  swap         d0                                            ; scambia le 2 word di d0 (es: 1234 > 3412)
  move.w       d0,2(a1)                                      ; copia la word ALTA dell'indirizzo del plane
  swap         d0
  add.l        #40*256,d0
  addq         #8,a1
  dbra         d1,bitplaneLoop
 
  MOVE.L       #BITPLANE,d0                                  ; in d0 mettiamo l'indirizzo della PIC,
  LEA          BPLPOINTERS2,A1                               ; puntatori nella COPPERLIST
  move.w       d0,6(a1)                                      ; copia la word BASSA dell'indirizzo del plane
  swap         d0                                            ; scambia le 2 word di d0 (es: 1234 > 3412)
  move.w       d0,2(a1)                                      ; copia la word ALTA dell'indirizzo del plane

  move.l       #COPPERLIST,CUSTOM+COP1LC                     ; Puntiamo la nostra COP
  move.w       d0,CUSTOM+COPJMP1                             ; Facciamo partire la COP
  move.w       #0,$dff1fc                                    ; Disattiva l'AGA
  move.w       #$c00,CUSTOM+$106                             ; Disattiva l'AGA

  bsr.w        PRINTLN                                       ; Stampa le linee di testo sullo schermo

mouse:
  btst         #6,$bfe001                                    ; tasto sinistro del mouse premuto?
  bne.s        mouse                                         ; se no, torna a mouse:

  move.l       OldCop(PC),CUSTOM+COP1LC                      ; Puntiamo la cop di sistema
  move.w       d0,CUSTOM+COPJMP1                             ; facciamo partire la vecchia cop

  or           #$C000,OldIntenar
  move         OldIntenar,CUSTOM+INTENA
  
  move.l       #0,d0
  rts                                                        ; Fine dei giochi

;	Dati
OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
  dc.l         $12345678

OldIntenar:     ; Stato di INTENAR
  dc.l         0

;	Routine che stampa caratteri larghi 8x8 pixel

PRINTLN:
  LEA          TESTO(PC),A0                                  ; Indirizzo del testo da stampare in a0
  LEA          BITPLANE,A3                                   ; Indirizzo del bitplane destinazione in a3
  MOVEQ        #23-1,D3                                      ; NUMERO RIGHE DA STAMPARE: 23
PRINTRIGA:
  MOVEQ        #40-1,D0                                      ; NUMERO COLONNE PER RIGA: 40
PRINTCHAR2:
  MOVEQ        #0,D2                                         ; Pulisci d2
  MOVE.B       (A0)+,D2                                      ; Prossimo carattere in d2
  SUB.B        #$20,D2                                       ; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
  beq.b        nextchar
  MULU.W       #8,D2                                         ; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
  MOVE.L       D2,A2
  ADD.L        #FONT,A2                                      ; TROVA IL CARATTERE DESIDERATO NEL FONT...

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
  MOVE.B       (A2)+,(A3)                                    ; stampa LA LINEA 1 del carattere
  MOVE.B       (A2)+,40(A3)                                  ; stampa LA LINEA 2  " "
  MOVE.B       (A2)+,40*2(A3)                                ; stampa LA LINEA 3  " "
  MOVE.B       (A2)+,40*3(A3)                                ; stampa LA LINEA 4  " "
  MOVE.B       (A2)+,40*4(A3)                                ; stampa LA LINEA 5  " "
  MOVE.B       (A2)+,40*5(A3)                                ; stampa LA LINEA 6  " "
  MOVE.B       (A2)+,40*6(A3)                                ; stampa LA LINEA 7  " "
  MOVE.B       (A2)+,40*7(A3)                                ; stampa LA LINEA 8  " "
nextchar:
  ADDQ.w       #1,A3                                         ; A1+1, avanziamo di 8 bit (PROSSIMO CARATTERE)

  DBRA         D0,PRINTCHAR2                                 ; STAMPIAMO D0 (40) CARATTERI PER RIGA

  ADD.W        #40*7,A3                                      ; ANDIAMO A CAPO

  DBRA         D3,PRINTRIGA                                  ; FACCIAMO D3 RIGHE

  RTS


		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
	     ;	 1234567890123456789012345678901234567890
  dc.b         '   PRIMA RIGA                           '    ; 1
  dc.b         '                SECONDA RIGA            '    ; 2
  dc.b         '     /\  /                              '    ; 3
  dc.b         '    /  \/                               '    ; 4
  dc.b         '                                        '    ; 5
  dc.b         '        SESTA RIGA                      '    ; 6
  dc.b         '                                        '    ; 7
  dc.b         '                                        '    ; 8
  dc.b         'GIANLUCA BELARDELLI           AMIGA DEMO'    ; 9
  dc.b         '                                        '    ; 10
  dc.b         '   1234567890 !@#$%^&*()_+|\=-[]{}      '    ; 11
  dc.b         '                                        '    ; 12
  dc.b         '     ..............................     '    ; 15
  dc.b         '                                        '    ; 25
  dc.b         '                                        '    ; 16
  dc.b         '  Nel mezzo del cammin di nostra vita   '    ; 17
  dc.b         '                                        '    ; 18
  dc.b         '    Mi RitRoVaI pEr UnA sELva oScuRa    '    ; 19
  dc.b         '                                        '    ; 20
  dc.b         '    CHE LA DIRITTA VIA ERA SMARRITA     '    ; 21
  dc.b         '                                        '    ; 22
  dc.b         '  AHI Quanto a DIR QUAL ERA...          '    ; 23
  dc.b         '                                        '    ; 24
  dc.b         '                                        '    ; 25
  dc.b         '                                        '    ; 26
  dc.b         '                                        '    ; 27

  EVEN

  SECTION      GRAPHIC,DATA_C
  incdir       "."

COPPERLIST:
  include      "copper_reset.i"

		    ; 5432109876543210
  dc.w         BPLCON0,%0100001000000000                     ; 4 bitplanes LOWRES 320x256

BPLPOINTERS:
  dc.w         BPL0PTH,$0000,BPL0PTL,$0000                   ;primo	 bitplane della figura
  dc.w         BPL1PTH,$0000,BPL1PTL,$0000                   ;secondo	 bitplane della figura
  dc.w         BPL2PTH,$0000,BPL2PTL,$0000                   ;terzo	 bitplane della figura
BPLPOINTERS2:
  dc.w         BPL3PTH,$0000,BPL3PTL,$0000                   ;quarto	 bitplane per le scritte

  COP_COL00    $000                                          ; color0 - SFONDO
  COP_COL01    $354                                          ; color1 - SCRITTE
  COP_COL02    $678
  COP_COL03    $567
	
  COP_COL04    $455                                          ; color4
  COP_COL05    $121                                          ; color5
  COP_COL06    $455                                          ; color6
  COP_COL07    $233                                          ; color7

  COP_COL08    $d6e                                          ; color8	; I colori della scritta:
  COP_COL09    $d6e                                          ; color9	; infatti tutte le varie
  COP_COL10    $d6e                                          ; color10	; sovrapposizioni formerebbero
  COP_COL11    $d6e                                          ; color11	; altri 8 colori, che noi
  COP_COL12    $d6e                                          ; color12	; definiamo tutti uguali
  COP_COL13    $d6e                                          ; color13
  COP_COL14    $d6e                                          ; color14
  COP_COL15    $d6e                                          ; color15

  COPWAIT_Y    $6b                                           ; Sfumatura alla linea di testo 9
  COP_COL00    $451                                          ; linea1 del carattere
  COP_COL08    $333                                          ; color8	; I colori della scritta:
  COP_COL09    $333                                          ; color9	; infatti tutte le varie
  COP_COL10    $333                                          ; color10	; sovrapposizioni formerebbero
  COP_COL11    $333                                          ; color11	; altri 8 colori, che noi
  COP_COL12    $333                                          ; color12	; definiamo tutti uguali
  COP_COL13    $333                                          ; color13
  COP_COL14    $333                                          ; color14
  COP_COL15    $333                                          ; color15

  COPWAIT_Y    $6d
  COP_COL00    $671                                          ; linea 2
  COPWAIT_Y    $6e
  COP_COL00    $891                                          ; linea 3
  COPWAIT_Y    $6f
  COP_COL00    $ab1                                          ; linea 4
  COPWAIT_Y    $70
  COP_COL00    $781                                          ; linea 5
  COPWAIT_Y    $71
  COP_COL00    $561                                          ; linea 6
  COPWAIT_Y    $72
  COP_COL00    $451                                          ; linea 7  l'ultima perche' la 8 e' azzerata
	; 			                                             ; per fare spaziatura tra le linee
  COPWAIT_Y    $75
  COP_COL00    $000                                          ; colore normale
  COP_COL08    $d6e                                          ; color8	; I colori della scritta:
  COP_COL09    $d6e                                          ; color9	; infatti tutte le varie
  COP_COL10    $d6e                                          ; color10	; sovrapposizioni formerebbero
  COP_COL11    $d6e                                          ; color11	; altri 8 colori, che noi
  COP_COL12    $d6e                                          ; color12	; definiamo tutti uguali
  COP_COL13    $d6e                                          ; color13
  COP_COL14    $d6e                                          ; color14
  COP_COL15    $d6e                                          ; color15
  ; COPWAIT_Y    $8c                                           ; Sfumatura alla linea di testo 11
  ; COP_COL01    $516                                          ; linea1 del carattere
  ; COPWAIT_Y    $8d
  ; COP_COL01    $739                                          ; linea 2
  ; COPWAIT_Y    $8e
  ; COP_COL01    $95b                                          ; linea 3
  ; COPWAIT_Y    $8f
  ; COP_COL01    $c6f                                          ; linea 4
  ; COPWAIT_Y    $90
  ; COP_COL01    $84a                                          ; linea 5
  ; COPWAIT_Y    $91
  ; COP_COL01    $739                                          ; linea 6
  ; COPWAIT_Y    $92
  ; COP_COL01    $517                                          ; linea 7  l'ultima perche' la 8 e' azzerata
  ; COPWAIT_Y    $93
  ; COP_COL01    $19a                                          ; colore normale

  dc.l         COPPER_HALT                                   ; Fine della copperlist

;	Il FONT caratteri 8x8
 
FONT:
  incbin       "metal.fnt"                                   ; Carattere largo
;	incbin	"normal.fnt"	; Simile ai caratteri kickstart 1.3
;	incbin	"nice.fnt"	; Carattere stretto

PIC:
  incbin       "amiga.raw"
  
  SECTION      MIOPLANE,BSS_C                                ; Le SECTION BSS devono essere fatte di
				; soli ZERI!!! si usa il DS.b per definire
				; quanti zeri contenga la section.

BITPLANE:
  ds.b         40*256                                        ; un bitplane lowres 320x256

  end
