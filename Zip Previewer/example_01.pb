;JLC is back, this time with a ZIP previewer!
;More info here:
;http://www.fileformat.info/format/zip/corion.htm (in middle of the page)

EnableExplicit

Procedure.s sizeString(Bytes.q)
  Protected Result$, KB.f = Bytes / 1024
  
  If KB < 1000
    Result$ = StrF(KB,1)
    If Len(StringField(Result$,1,".")) > 1
      Result$ = StrF(ValF(Result$),0)
    EndIf
    Result$ + "kb"
  ElseIf KB < 1000000
    Result$ = StrF(KB/1000,1)
    If Len(StringField(Result$,1,".")) > 1
      Result$ = StrF(ValF(Result$),0)
    EndIf
    Result$ + "mb"
  Else
    Result$ = StrF(KB/1000000,1)
    If Len(StringField(Result$,1,".")) > 1
      Result$ = StrF(ValF(Result$),0)
    EndIf
    Result$ + "gb"
  EndIf
  
  ProcedureReturn Result$
EndProcedure
Procedure.s memoryToHex(address,length) ;returns a string containing the hex representation of the memory area
  Protected result$, i
  For i=0 To length-1
    result$ + RSet(Hex(PeekB(address+i),#PB_Byte),2,"0")
  Next
  ProcedureReturn result$
EndProcedure 

Define *buffer = AllocateMemory(4)
Define file$, file, pos, i, endFound, cdStart, done, nL, xL, cL, crc32, size, cSize, date, name$, comment$, check

file$ = OpenFileRequester("open zip file","","Zip files|*.zip",0)
If file$
  file = ReadFile(#PB_Any,file$)
  If file
    pos = Lof(file)-4
    While pos > 0 And endFound = #False
      FileSeek(file,pos)
      ReadData(file,*buffer,4)
      If memoryToHex(*buffer,4) = "504B0506"
        endFound = pos
        ;Debug endFound
        FileSeek(file,endFound+16)
        cdStart = ReadLong(file)
        ;Debug cdStart
      EndIf
      pos - 1
    Wend
    pos = cdStart
    FileSeek(file,pos)
    Repeat ;for each element in the central directory structure
      ReadLong(file) ;504B0102 PK..
      ReadQuad(file) ;jump over this shit
      date = ReadLong(file): pos + 4 ;DOS date / time of file
      crc32 = ReadLong(file) ;32-bit CRC of file, I think the bits are reversed?
      cSize = ReadLong(file) ;Compressed size of file
      size  = ReadLong(file) ;Uncompressed size of file
      nL = ReadWord(file)
      xL = ReadWord(file)
      cL = ReadWord(file)
      ReadLong(file): ReadQuad(file)
      FreeMemory(*buffer): *buffer = AllocateMemory(nL)
      ReadData(file,*buffer,nL)
      name$ = PeekS(*buffer,nL)
      Debug name$+" "+sizeString(size)
      If xL
        FreeMemory(*buffer): *buffer = AllocateMemory(xL)
        ReadData(file,*buffer,xL)
      EndIf
      If cL
        FreeMemory(*buffer): *buffer = AllocateMemory(cL)
        ReadData(file,*buffer,cL)
        comment$ = PeekS(*buffer,cL)
      EndIf
      check = ReadLong(file)
      If memoryToHex(@check,4) = "504B0506" ;end reached
        Break
      Else
        FileSeek(file,Loc(file)-4)
      EndIf
    Until done
  Else
    Debug "file not found"
  EndIf
EndIf
; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 95
; Folding = -
; EnableXP