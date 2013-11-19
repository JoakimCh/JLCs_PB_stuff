EnableExplicit

Procedure.s getCharComb(characters$,combination.q,length)
  Protected charCount = Len(characters$)
  Protected result$, maxCombinations.q, val.q,res.q,rem,base=charCount
  maxCombinations = Pow(charCount,length)
  If combination < maxCombinations
    val = combination
    Repeat
      res = val / base
      rem = val % base
      val = res
      result$ = Mid(characters$,rem+1,1) + result$ 
    Until val <= 0
    result$ = RSet(result$,length,Mid(characters$,1,1)) 
  Else
    ;Debug "maximum amount of combinations reached"
  EndIf
  ProcedureReturn result$
EndProcedure

Procedure.s secondsToTime(seconds.q)
  Protected rem, years.q, days, hours, minutes
  years = seconds / 31536000
  rem = seconds %  31536000
  days = rem / 86400
  rem = rem % 86400
  hours = rem / 3600
  rem = rem % 3600
  minutes = rem / 60
  rem = rem % 60
  seconds = rem
  ProcedureReturn Str(years)+" years, "+Str(days)+" days, "+Str(hours)+" hours and "+Str(minutes)+" minutes"
EndProcedure

Procedure.s bruteForceTimeCalc(charCount,numOfChars,perSecond,delayMS.d=0)
  Protected combinations.q, secondsUsed.q
  If perSecond > 0 ;else delayMS should be set
    delayMS = 1000 / perSecond
  EndIf
  combinations = Pow(charCount,numOfChars)
  secondsUsed = IntQ((combinations * delayMS) / 1000)
  ProcedureReturn secondsToTime(secondsUsed)
EndProcedure

; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 44
; FirstLine = 6
; Folding = -
; EnableXP