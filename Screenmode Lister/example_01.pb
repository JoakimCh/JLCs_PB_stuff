EnableExplicit

IncludeFile "main.pbi"

ExamineDesktops()
Define NewList screenMode.screenMode()
listScreenModes(screenMode(),Str(DesktopDepth(0)),aspectRatio(DesktopWidth(0),DesktopHeight(0)))
ForEach screenMode()
  With screenMode()
  Debug Str(\width)+"x"+Str(\height)+", "+Str(\depth)+"-bit, "+Str(\refreshRate)+"Hz, Ratio:"+\aspectRatio$
  EndWith
Next
; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 2
; EnableXP