           incdir     "../include/"
           include    "exec/types.i"
           include    "exec/funcdef.i"
           include    "exec/exec_lib.i"
           include    "libraries/dos.i"
           include    "libraries/dos_lib.i"
           include    "myinc.i"
           section    DEMO,CODE

           XDEF       _Tut1Main

maxAttempts EQU 3

_Tut1Main:
           move.l     #doslib,a1                            ;Nome della DOS-Lib
           moveq      #0,d0                                 ;Versione indifferente
           move.l     _SysBase,a6                           ;Base di Exec
           jsr        _LVOOpenLibrary(a6)                   ;Apertura della DOS-Lib
           tst.l      d0                                    ;Errore?
           beq        fini                                  ;Se errore, Fine
           move.l     d0,_DosBase                           ;Annotare il puntatore

* Determinazione dell’Handle di output:
           move.l     _DosBase,a6                           ;Chiamata funzione DOS
           jsr        _LVOOutput(a6)                        ;Prelevamento Handle di Output
           move.l     d0,d4                                 ;e sua annotazione in d4

* ora Output di testo:
           move.l     #1,d7                                 ; d7 = Contatore tentativi
reqLoop:
           lea        msg0,a0
           bsr        print

           lea        msg1,a0
           bsr        print

			;file = Input()
			;D0
           jsr        _LVOInput(a6)                         ; Handle Input
           move.l     d0,d1                                 ; Save Input ptr

		   ;actualLength = Read( file, buffer, length )
		   ;D0		              D1    D2	   D3

           lea.l      buffer,a2                             ; Ptr al buffer
           move.l     a2,d2                                 ; Salvato in d2
           addq       #1,d2                                 ; Salto il byte della lunghezza
           move.l     #79,d3
           jsr        _LVORead(a6)                          ;Funzione "Lettura"

           lea        pwd,a3
           move.b     (a3)+,d4  
checkPwd:
           move.b     (a3)+,d5
           move.b     (a2)+,d6
           cmp.b      d5,d6
           bne.s      pwdKO

           dbra       d0,checkPwd
           bra.s      pwdOK
pwdKO:
           ;addq       #1,d0                                 ; Aggiungo 1 alla lunghezza dell'input
           ;move.b     d0,(a2)                               ; Salvo la nuova lunghezza come primo byte del buffer
           ;move.b     #'!',-1(a2,d0.l)                      ; Aggiunge ! alla fine del buffer
           ;move.b     #10,0(a2,d0.l)                        ; Fine riga

           lea        msg3,a0
           bsr        print

           addq       #1,d7
           cmp.b      maxAttempts,d7
           beq        endGame
           bra        reqLoop

pwdOK:
           lea        msg2,a0                               ; Stampa
           bsr        print
           bra.s      closeAll
endGame:
           lea        msg4,a0                               ; Stampa
           bsr        print

closeAll:
* Al termine chiudere sempre le Lib!
           move.l     _DosBase,a1                           ;Base delle Lib
           move.l     _SysBase,a6                           ;Base di Exec
           jsr        _LVOCloseLibrary(a6)                  ;Funzione "Chiusura"


fini:
                  
           
           rts                                              ;Ritorno al CLI

print:
           clr.l      d3
           move.b     (a0)+,d3                              ; Lunghezza stringa
           move.l     d4,d1                                 ; Handle Output
           move.l     a0,d2                                 ; Ptr alla stringa
           jsr        _LVOWrite(a6)
           rts

doslib:		DOSNAME

msg0       dc.b       12,10,'Tentativo: '
msg1       dc.b       20,10,'Inserire password: '
msg2       dc.b       12,10,'Buongiorno '
msg3       dc.b       27,10,'Password sbagliata ritenta'
msg4       dc.b       11,10,'Fine gioco'

pwd        dc.b       8,'gianluca'

_DosBase:  dc.l       $12345678

buffer     ds.b       80
           end
