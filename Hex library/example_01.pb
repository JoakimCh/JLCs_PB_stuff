EnableExplicit

IncludeFile "hexLibrary.pbi"

;little-endian example (uncomment to test)
;Define long.l
;hexToLong(@long,"00 00 00 04") ;at default saves in little-endian order, same as long=$00000004
;Debug long
;Debug longToHex(long) ;at default reads as little-endian
;Debug longToHex(long,#bigEndian) ;shown as physically stored (left to right)
;End

;Just me playing around with it...
Define hex$ = "F7"+strToHex("Hello")+"F7"
Define size = getHexSize(hex$)
Define *buffer = AllocateMemory(size)
hexToMemory(*buffer,hex$)
Debug PeekS(*buffer,size)
Debug memoryToHex(*buffer,size)
Debug ""
Debug hexToText("48656C6C6F20776F726C64210041206E756C6C20776F6E742073746F70206D65203A29")
Debug hexToTextSanitized("48656C6C6F20776F726C64210D0A416E64206E6F7720636F6D657320612074616209636F6F6C2072696768743F0D0A0D0A0D0A0D0A0D0A0D0A0D0A")
Debug ""
Define string$ = "Hex rules!"
Debug memoryToHex(@string$,Len(string$))

; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 2
; EnableXP