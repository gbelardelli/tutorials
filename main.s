  section    DEMO,CODE
  
  XREF       Copper1
  XREF       _Tut1Main

Main:
  movem.l    d0/a0,-(sp)    ; Save cmdline

  jsr        Copper1
  jsr        _Tut1Main

  movem.l    (sp)+,a0/d0
  move.l     #0,d0

  rts