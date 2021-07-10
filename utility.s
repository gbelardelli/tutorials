
  incdir     "../include/"
  include    "exec/types.i"
  include    "exec/funcdef.i"
  include    "exec/exec_lib.i"
  include    "graphics/gfxbase.i"
  include    "graphics/graphics_lib.i"
  include    "myinc.i"

  XDEF       SaveCopper

SaveCopper:
; a4 = OldCopper Address
  move.l     _SysBase.w,a6                ; Execbase in a6
  lea        GfxName(PC),a1               ; Indirizzo del nome della lib da aprire in a1
  jsr        _LVOOpenLibrary(a6)          ; OpenLibrary
  move.l     d0,a6
  move.l     $26(a6),(a4)                 ; salviamo l'indirizzo della copperlist vecchia
  jsr        _LVOCloseLibrary(a6)
  rts
    
GfxName:    GRAPHICSNAME
  EVEN

