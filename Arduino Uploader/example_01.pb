EnableExplicit

IncludeFile "arduinoUploader.pbi"

Define file$, dataBufferSize=1000000, *dataBuffer = AllocateMemory(dataBufferSize), dataLength
Define file, COM$

OpenConsole()
PrintN("JLC's Arduino Hex Uploader v1.00 Beta 1")

; file$ = "project.hex": COM$ = "COM7"
; Debug loadHexFile(file$,*dataBuffer,dataBufferSize)
; Input()
; End

COM$  = ProgramParameter(0)
file$ = ProgramParameter(1)
PrintN("Uploading: "+file$)

If FileSize(file$) > 0
  dataLength = loadHexFile(file$,*dataBuffer,dataBufferSize)
  If dataLength
    PrintN("Bytes to upload: "+Str(dataLength))
    uploadData(COM$,*dataBuffer,dataLength)
  Else
    PrintN("Error parsing hex file...")
  EndIf
Else
  PrintN("Error, file not found!")
EndIf
; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 2
; EnableXP