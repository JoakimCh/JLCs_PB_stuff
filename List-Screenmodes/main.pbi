EnableExplicit

Structure screenMode
  width.l
  height.l
  depth.l
  refreshRate.l
  aspectRatio$
EndStructure
Procedure gcd(a,b) ;finds the greatest common divisor
  If b=0
    ProcedureReturn a
  Else
    ProcedureReturn gcd(b,a%b)
  EndIf
EndProcedure
Procedure.s aspectRatio(width,height)
  Protected gcd, aspectRatio$
  gcd          = gcd(width,height)
  aspectRatio$ = Str(width/gcd)+":"+Str(height/gcd)
  Select aspectRatio$ ;change into more common values
    Case "8:5"    : aspectRatio$ = "16:10"
    Case "25:16"  : aspectRatio$ = "14:9"
    Case "85:48"  : aspectRatio$ = "16:9"
    Case "683:384": aspectRatio$ = "16:9"
  EndSelect
  ProcedureReturn aspectRatio$
EndProcedure
Procedure listScreenModes(List screenMode.screenMode(),depthFilter$,aspectFilter$)
  Protected aspectRatio$
  InitSprite()
  If ExamineScreenModes()
    While NextScreenMode()
      aspectRatio$ = aspectRatio(ScreenModeWidth(),ScreenModeHeight())
      If (depthFilter$="" Or Str(ScreenModeDepth())=depthFilter$) And (aspectFilter$="" Or aspectRatio$=aspectFilter$)
        AddElement(screenMode())
        With screenMode()
        \width       = ScreenModeWidth()
        \height      = ScreenModeHeight()
        \depth       = ScreenModeDepth()
        \refreshRate = ScreenModeRefreshRate()
        \aspectRatio$ = aspectRatio$
        EndWith
      EndIf
    Wend
  EndIf
EndProcedure

; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 47
; FirstLine = 9
; Folding = -
; EnableXP