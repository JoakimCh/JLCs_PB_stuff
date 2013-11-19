;Some commands to make working with hex easier
;Made by Joakim L. Christiansen a.k.a JLC
;Feel free to use! :)

EnableExplicit

Enumeration ;endians
  ;http://en.wikipedia.org/wiki/Endianness
  ;http://forums.purebasic.com/english/viewtopic.php?p=294231
  #littleEndian ;right to left
  #bigEndian ;left to right
EndEnumeration

Procedure.l getHexSize(hex$) ;no point to use if you got a brain
  hex$ = RemoveString(hex$," ")
  ProcedureReturn Len(hex$)/2
EndProcedure
Procedure.s memoryToHex(address,length,byteorder=#bigEndian) ;returns a string containing the hex representation of the memory area
  Protected result$, i
  If byteorder = #bigEndian
    For i=0 To length-1
      result$ + RSet(Hex(PeekB(address+i),#PB_Byte),2,"0")+" "
    Next
  ElseIf byteorder = #littleEndian
    For i=length-1 To 0 Step -1
      result$ + RSet(Hex(PeekB(Address+i),#PB_Byte),2,"0")+" "
    Next
  EndIf
  ProcedureReturn RTrim(result$)
EndProcedure
Procedure hexToMemory(address,hex$,byteorder=#bigEndian) ;converts hex into data
  Protected i, pos, len
  hex$ = RemoveString(hex$," ")
  len = Len(hex$)
  If byteorder = #bigEndian
    For i=1 To len Step 2
      PokeB(address+pos,Val("$"+Mid(hex$,i,2)))
      pos+1
    Next
  ElseIf byteorder = #littleEndian
    For i=len - 1 To 0 Step -2
      PokeB(Address+pos,Val("$"+Mid(hex$,i,2)))
      pos+1
    Next
  EndIf
EndProcedure

Procedure.s hexToText(hex$) ;tries to show hex as text
  Protected i, pos, len, result$, val
  hex$ = RemoveString(hex$," ")
  len = Len(hex$)
  result$ = Space(len/2)
  For i=1 To len Step 2
    val = Val("$"+Mid(hex$,i,2))
    If val <> #Null ;replace null char with space
      PokeB(@result$+pos,val)
    Else
      PokeB(@result$+pos,' ')
    EndIf
    pos+1
  Next
  ProcedureReturn result$
EndProcedure
Procedure.s hexToTextSanitized(hex$) ;emulates hex editors, called "sanitized" since it removes tabs and linefeeds
  Protected i, pos, len, result$, val
  hex$ = RemoveString(hex$," ")
  len = Len(hex$)
  result$ = Space(len/2)
  For i=1 To len Step 2
    val = Val("$"+Mid(hex$,i,2))
    Select val
      Case #Null,#TAB,#CR,#LF: PokeB(@result$+pos,'.')
      Default: PokeB(@result$+pos,val)
    EndSelect
    pos+1
  Next
  ProcedureReturn result$
EndProcedure
Procedure.s memoryToTextSanitized(address,length) ;emulates hex editors, called "sanitized" since it removes tabs and linefeeds
  Protected result$, i, byte.b
  For i=0 To length
    byte = PeekB(address+i)
    Select byte
      Case #Null,#TAB,#CR,#LF: result$ + "."
      Default: result$ + Chr(byte)
    EndSelect
  Next
  ProcedureReturn result$
EndProcedure
Procedure.l SendNetworkHex(connection,hex$) ;stuff should often be big-endian over network btw
  Protected result, *buffer = AllocateMemory(getHexSize(hex$))
  hexToMemory(*buffer,hex$)
  result = SendNetworkData(connection,*buffer,MemorySize(*buffer))
  FreeMemory(*buffer)
  ProcedureReturn result
EndProcedure

Procedure.s strToHex(string$)
  ProcedureReturn memoryToHex(@string$,Len(string$))
EndProcedure
Procedure.s longToHex(long,byteorder=#littleEndian)
  ProcedureReturn memoryToHex(@long,4,byteorder)
EndProcedure
Procedure.s wordToHex(word.w,byteorder=#littleEndian)
  ProcedureReturn memoryToHex(@word,2,byteorder)
EndProcedure
Procedure.s byteToHex(byte.b)
  ProcedureReturn memoryToHex(@byte,1)
EndProcedure
Procedure hexToLong(*long,hex$,byteorder=#littleEndian)
  hex$ = RemoveString(hex$," ")
  If Len(hex$) = 8 ;limits stupidity
    hexToMemory(*long,hex$,byteorder)
  EndIf
EndProcedure
Procedure hexToWord(*word,hex$,byteorder=#littleEndian)
  hex$ = RemoveString(hex$," ")
  If Len(hex$) = 4 ;limits stupidity
    hexToMemory(*word,hex$,byteorder)
  EndIf
EndProcedure
Procedure hexToByte(*byte,hex$)
  If Len(hex$) = 2 ;limits stupidity
    hexToMemory(*byte,hex$)
  EndIf
EndProcedure

;Extra
Procedure.l reverseLong(long)
  Protected result.l, i
  For i=0 To 3
    PokeB(@result+i,PeekB(@long+3-i))
  Next
  ProcedureReturn result
EndProcedure
Procedure.q uLongToQuad(ulong.l)
  ProcedureReturn ulong & $FFFFFFFF
EndProcedure
Procedure.s uToHex(u.u,byteorder=#littleEndian)
  ProcedureReturn memoryToHex(@u,2,byteorder)
EndProcedure

; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 141
; FirstLine = 104
; Folding = ----
; EnableXP