;Morse code transceiver by Joakim L. Christiansen a.k.a JLC
;v1.0 coded in PB v5.20
;Morse code reference:
;http://en.wikipedia.org/wiki/Morse_code
;http://morsecode.scphillips.com/morse2.html

EnableExplicit

Global NewMap morseCode$(), format.WAVEFORMATEX

Procedure setWaveFormat(bitsPerSample=16,samplesPerSec=44100)
  format\wFormatTag = #WAVE_FORMAT_PCM
  format\nChannels = 1 ;mono
  format\wBitsPerSample = bitsPerSample ;8/16
  format\nSamplesPerSec =  samplesPerSec ;8000 Hz, 11025 Hz, 22050 Hz, and 44100 Hz
  format\nBlockAlign = (format\nChannels * format\wBitsPerSample) / 8
  format\nAvgBytesPerSec = format\nSamplesPerSec * format\nBlockAlign
EndProcedure
Procedure addWaveHeader(*address,dataSize,channels,samplesPerSec,blockAlign,bitsPerSample)
  PokeL(*address+ 0, 'FFIR')
  PokeL(*address+ 4, dataSize + 36)
  PokeL(*address+ 8, 'EVAW')
  PokeL(*address+ 12, ' tmf')
  PokeL(*address+ 16, $0010)
  PokeW(*address+ 20, $01)
  PokeW(*address+ 22, channels)
  PokeL(*address+ 24, samplesPerSec)
  PokeL(*address+ 28, samplesPerSec * channels * (bitsPerSample / 8) )
  PokeW(*address+ 32, blockAlign)
  PokeW(*address+ 34, bitsPerSample)
  PokeL(*address+ 36, 'atad')
  PokeL(*address+ 40, dataSize)
EndProcedure
Procedure.l createTone(*address,amplitude,duration,frequency)
  Protected multiplier.f, angle.f, sample, x, size, numSamples
  
  size = Int((format\nSamplesPerSec/1000)*duration) * (format\wBitsPerSample / 8)
  If *address = 0 ;return size needed
    ProcedureReturn size
  EndIf
  numSamples = size / 2
  
  multiplier = (360 / format\nSamplesPerSec)  * frequency
  For x=0 To numSamples-1
    angle + multiplier
    sample = Sin(Radian(angle))*amplitude
    PokeW(*address+(x*2),sample)
  Next
EndProcedure
Procedure catchTone(volume,duration,frequency)
  Protected *memory, id, size
  size = createTone(0,volume,duration,frequency) ;get size
  *memory = AllocateMemory(44+size)
  createTone(*memory+44,volume,duration,frequency)
  addWaveHeader(*memory,size,format\nChannels,format\nSamplesPerSec,format\nBlockAlign,format\wBitsPerSample)
  id = CatchSound(#PB_Any,*memory)
  FreeMemory(*memory)
  ProcedureReturn id
EndProcedure
Procedure initializeMorsecode() ;fills the map
  morseCode$("a") = ".-"
  morseCode$("b") = "-..."
  morseCode$("c") = "-.-."
  morseCode$("d") = "-.."
  morseCode$("e") = "."
  morseCode$("f") = "..-."
  morseCode$("g") = "--."
  morseCode$("h") = "...."
  morseCode$("i") = ".."
  morseCode$("j") = ".---"
  morseCode$("k") = "-.-"
  morseCode$("l") = ".-.."
  morseCode$("m") = "--"
  morseCode$("n") = "-."
  morseCode$("o") = "---"
  morseCode$("p") = ".--."
  morseCode$("q") = "--.-"
  morseCode$("r") = ".-."
  morseCode$("s") = "..."
  morseCode$("t") = "-"
  morseCode$("u") = "..-"
  morseCode$("v") = "...-"
  morseCode$("w") = ".--"
  morseCode$("x") = "-..-"
  morseCode$("y") = "-.--"
  morseCode$("z") = "--.."
  morseCode$("0") = "-----"
  morseCode$("1") = ".----"
  morseCode$("2") = "..---"
  morseCode$("3") = "...--"
  morseCode$("4") = "....-"
  morseCode$("5") = "....."
  morseCode$("6") = "-...."
  morseCode$("7") = "--..."
  morseCode$("8") = "---.."
  morseCode$("9") = "----."
  morseCode$(".") = ".-.-.-"
  morseCode$(",") = "--..--"
  morseCode$("?") = "..--.."
  morseCode$("'") = ".----."
  morseCode$("!") = "-.-.--"
  morseCode$("/") = "-..-."
  morseCode$("(") = "-.--."
  morseCode$(")") = "-.--.-"
  morseCode$("&") = ".-..."
  morseCode$(":") = "---..."
  morseCode$(";") = "-.-.-."
  morseCode$("=") = "-...-"
  morseCode$("+") = ".-.-."
  morseCode$("-") = "-....-"
  morseCode$("_") = "..--.-"
  morseCode$(#DQUOTE$) = ".-..-."
  morseCode$("$") = "...-..-"
  morseCode$("@") = ".--.-."
  ;non English extensions (not complete)
  morseCode$("æ") = ".-.-" ;Ä
  morseCode$("ø") = "---." ;Ö
  morseCode$("å") = ".--.-";Á
EndProcedure
Procedure.s textToMorse(string$)
  Protected i, result$, char$
  For i=1 To Len(string$)
    char$ = LCase(Mid(string$,i,1))
    Select char$
      Case " "
        result$ + "       "
      Default
        If FindMapElement(morseCode$(),char$)
          result$ + morseCode$() + "   "
        Else
          result$ = "This character could not be translated: "+char$: Break
        EndIf
     EndSelect
  Next
  ProcedureReturn result$
EndProcedure
Procedure differenseInPercentage(value,nominalValue)
  ProcedureReturn Abs((value/nominalValue)*100-100)
EndProcedure
Procedure.s decodeSignal(signal,allowedDifferense=60) ;either high or low, it keeps track of time itself
  ;the allowedDifferense variable defines how inaccurate (in percentage) the pulse widths are allowed to be
  ;recommended values are 60-70 but 50-100 could also work
  Static pSignal, pPulseWidth, pulseStart, offStart, shortPulse, longPulse
  Protected ms.q, pulseWidth, offWidth, result$
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;ms = ElapsedMilliseconds() ;not accurate enough for very fast morse code
    QueryPerformanceCounter_(@ms) ;hence this
  CompilerElse ;for Linux or Mac
    ms = ElapsedMilliseconds() ;please replace this with something like "elapsedMicroseconds()"
  CompilerEndIf

  
  If signal = 1
    If pSignal = 0 ;if changed since last call
      pulseStart = ms
      offWidth = ms-offStart
      If shortPulse <> 0 ;must first detect short pulse width
        If differenseInPercentage(offWidth,shortPulse) < allowedDifferense ;if the pulse is within range of a short pulse
          result$ = ""
        ElseIf differenseInPercentage(offWidth,longPulse) < allowedDifferense
          result$ = "   "
        ElseIf differenseInPercentage(offWidth,longPulse) > allowedDifferense
          result$ = "       "
        EndIf
      EndIf
    EndIf
  Else
    If pSignal = 1
      pulseWidth = ms-pulseStart
      offStart = ms
      If pPulseWidth <> 0 ;must first have two pulses to compare
        If differenseInPercentage(pulseWidth,pPulseWidth) > allowedDifferense ;if the pulse width is much different from the last one
          If pulseWidth > pPulseWidth
            shortPulse = pPulseWidth
            longPulse  = pulseWidth
          Else
            shortPulse = pulseWidth
            longPulse  = pPulseWidth
          EndIf
          Debug Str(shortPulse)+" - "+Str(longPulse)
        EndIf
        If differenseInPercentage(pulseWidth,shortPulse) < allowedDifferense ;if the pulse is within range of a short pulse
          result$ = "."
        ElseIf differenseInPercentage(pulseWidth,longPulse) < allowedDifferense
          result$ = "-"
        EndIf
      EndIf
      pPulseWidth = pulseWidth
    EndIf
  EndIf
  pSignal = signal
  ProcedureReturn result$
EndProcedure
Procedure playMorse(morse$,speed)
  Protected i, char$, nextChar$
  Protected snd_short,snd_long;, decoded$
  snd_short = catchTone(20000,speed,700)
  snd_long  = catchTone(20000,speed*3,700)
  For i=1 To Len(morse$)
    char$ = LCase(Mid(morse$,i,1))
    nextChar$ = Mid(morse$,i+1,1)
    Select char$
      Case "."
        ;decoded$ + decodeSignal(1)
        PlaySound(snd_short)
        Delay(speed)
        ;decoded$ + decodeSignal(0)
      Case "-"
        ;decoded$ + decodeSignal(1)
        PlaySound(snd_long)
        Delay(speed*3)
        ;decoded$ + decodeSignal(0)
      Case " "
        Delay(speed)
    EndSelect
    If char$ <> " " And nextChar$ <> " "
      Delay(speed)
    EndIf
  Next
  ;Debug decoded$
EndProcedure
Procedure.s morseToText(morse$)
  Protected result$, i, morseCode$, spaceCount, lastSpacePos
  For i=1 To Len(morse$)
    Select Mid(morse$,i,1)
      Case ".","-"
        spaceCount = 0
      Case " "
        spaceCount + 1
        morseCode$ = Mid(morse$,lastSpacePos+1,i-lastSpacePos-1)
        lastSpacePos = i
        If Len(morseCode$) > 0
          ForEach morseCode$()
            If morseCode$ = morseCode$();CompareMemoryString(@morseCode$,@morseCode$()) = #PB_String_Equal
              result$ + MapKey(morseCode$()): Break
            EndIf
          Next
        EndIf
        If spaceCount > 5
          spaceCount = 0
          result$ + " "
        EndIf
      Default
        result$ = "Error in parsed morse code!": Break
    EndSelect
  Next
  ProcedureReturn result$
EndProcedure
