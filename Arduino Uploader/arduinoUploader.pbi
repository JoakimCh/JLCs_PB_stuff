EnableExplicit

Macro ub: a: EndMacro: Macro uw: u: EndMacro ;unsigned byte and word

Procedure WriteSerialPortDataDebug(COM,*buffer,length)
  Protected i, hex$
  For i=0 To length-1
    hex$ + RSet(Hex(PeekB(*buffer+i),#PB_Byte),2,"0")+" "
  Next
  Debug hex$
  ProcedureReturn WriteSerialPortData(COM,*buffer,length)
EndProcedure
Procedure SerialFlushIncoming(COM,bytes)
  Protected byte.b, *buffer
  *buffer = AllocateMemory(bytes)
  While AvailableSerialPortInput(COM) < bytes: Delay(5): Wend
  ReadSerialPortData(COM,*buffer,bytes)
  FreeMemory(*buffer)
EndProcedure
Procedure.l waitSerial(COM,bytesToWaitFor,timeout=1000)
  Protected time, timedOut
  time = ElapsedMilliseconds()
  While AvailableSerialPortInput(COM) < bytesToWaitFor
    If ElapsedMilliseconds()-time >= timeout
      timedOut = #True
      Break
    EndIf
  Wend
  ProcedureReturn timedOut ! 1
EndProcedure

Procedure loadHexFile(file$,*dataBuffer,maxLength)
  ;http://en.wikipedia.org/wiki/Intel_HEX
  ;http://www.scienceprog.com/shelling-the-intel-8-bit-hex-file-format/
  ;Alt.version: http://www.purebasic.fr/english/viewtopic.php?f=12&t=43157
  Protected file, line$, stringPos, i, dataByte.ub, extOffset, mPos
  Protected dataLength.ub, address.uw, recordType.ub, checksum.b, calculatedChecksum.b
  
  file = ReadFile(#PB_Any,file$)
  If file
    While Not Eof(file)
      line$ = ReadString(file,#PB_Ascii)
      stringPos = 1
      If Mid(line$,stringPos,1) = ":": stringPos+1
        dataLength = Val("$"+Mid(line$,stringPos,2)): stringPos+2
        address = Val("$"+Mid(line$,stringPos,4)): stringPos+4
        recordType = Val("$"+Mid(line$,stringPos,2)): stringPos+2
        checksum = Val("$"+Right(line$,2))
        calculatedChecksum = dataLength+PeekA(@address+1)+PeekA(@address)+recordType
        Select recordType
          Case $00;: Debug "data record"
            mPos = address + extOffset
            If mPos+dataLength <= maxLength
              For i=0 To dataLength-1
                dataByte = Val("$"+Mid(line$,stringPos,2)): stringPos+2
                PokeB(*dataBuffer+mPos,dataByte)
                calculatedChecksum + dataByte
                mPos+1
              Next
              If checksum <> ~calculatedChecksum+1
                PrintN("Hex parser: Warning! Checksum error...")
              EndIf
            Else
              PrintN("Hex parser: Buffer is full!")
            EndIf
          Case $01;: Debug "end of file record"
          Case $02: extOffset = Val("$"+Mid(line$,10,4)) << 4
          Case $03: extOffset = Val("$"+Mid(line$,10,4)) << 16
          Default: PrintN("Hex parser: Record not implemented: "+Hex(recordType,#PB_Byte))
        EndSelect
      Else
        PrintN("Hex parser: Invalid line: "+line$)
      EndIf
    Wend
  Else
    PrintN("Hex parser: Error reading file!")
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn mPos ;is now the size
EndProcedure


Procedure uploadData(COM$,*address,dataLength,baud=57600)
  Define COM, byte.ub, memPos.uw, bytesToWrite.uw, chipMemPos.uw
  Dim bytes.ub(32)
  ;Dim bytesIn.ub(32)
  COM = OpenSerialPort(#PB_Any,COM$,baud,#PB_SerialPort_NoParity,8,1,#PB_SerialPort_NoHandshake,0,0)
  If COM
    SetSerialPortStatus(COM,#PB_SerialPort_DTR,#True) ;cause restart
    Delay(100)
    SetSerialPortStatus(COM,#PB_SerialPort_DTR,#False)
    Delay(100)
    WriteSerialPortString(COM,"0 ")
    If waitSerial(COM,2)
      SerialFlushIncoming(COM,2)
      PrintN("Flashing...")
      While memPos < dataLength-1
        bytes(0) = 'U' ;set address command
        chipMemPos = memPos/2 ;?!?!
        bytes(1) = PeekB(@chipMemPos)
        bytes(2) = PeekB(@chipMemPos+1)
        bytes(3) = ' ' ;end of command char
        If WriteSerialPortDataDebug(COM,@bytes(),4) <> 4: Debug "error1": End: EndIf
        SerialFlushIncoming(COM,2)
        If memPos+128 <= dataLength-1
          bytesToWrite = 128 ;the bootloader has a buffer of 256 bytes :)
        Else
          bytesToWrite = dataLength-memPos
        EndIf
        bytes(0) = 'd' ;write memory command
        bytes(1) = $00 ;since we will not write more than 256 bytes
        bytes(2) = PeekB(@bytesToWrite)
        bytes(3) = 'F' ;F for flash, E for epprom
        If WriteSerialPortDataDebug(COM,@bytes(),4) <> 4: Debug "error2": End: EndIf
        If WriteSerialPortDataDebug(COM,*address+memPos,bytesToWrite) <> bytesToWrite: Debug "error3": End: EndIf
        memPos + bytesToWrite
        bytes(0) = ' ' ;end of command char
        If WriteSerialPortDataDebug(COM,@bytes(),1) <> 1: Debug "error4": End: EndIf
        SerialFlushIncoming(COM,2)
      Wend
      WriteSerialPortString(COM,"Q ") ;restart command
      CloseSerialPort(COM)
      PrintN("Done! "+Str(dataLength)+" bytes written!")
    Else
      PrintN("Contact with bootloader failed!")
    EndIf
  Else
    PrintN("Error connecting to "+COM$+"!")
  EndIf
EndProcedure

; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 131
; FirstLine = 93
; Folding = --
; EnableXP