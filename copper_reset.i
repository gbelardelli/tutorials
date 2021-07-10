    ; Facciamo puntare gli sprite a ZERO, per eliminarli, o ce li troviamo
    ; in giro impazziti a disturbare!!!
    dc.w    SPR0PTH,$0000,SPR0PTL,$0000,SPR1PTH,$0000,SPR1PTL,$0000
    dc.w    SPR2PTH,$0000,SPR2PTL,$0000,SPR3PTH,$0000,SPR3PTL,$0000
    dc.w    SPR4PTH,$0000,SPR4PTL,$0000,SPR5PTH,$0000,SPR5PTL,$0000
    dc.w    SPR6PTH,$0000,SPR6PTL,$0000,SPR7PTH,$0000,SPR7PTL,$0000

    dc.w    DIWSTRT,$2c81  ; Display window start 
                           ; (upper left vertical-horizontal position)
                           ; 44,129
    dc.w    DIWSTOP,$2cc1  ; Display window stop 
                           ; (lower right vertical-horizontal position)
                           ; 44,193
    dc.w    DDFSTRT,$0038  ; DdfStart
    dc.w    DDFSTOP,$00d0  ; DdfStop
    dc.w    BPLCON1,0      ; BplCon1
    dc.w    BPLCON2,0      ; BplCon2
    dc.w    BPL1MOD,0      ; Bpl1Mod
    dc.w    BPL2MOD,0      ; Bpl2Mod
