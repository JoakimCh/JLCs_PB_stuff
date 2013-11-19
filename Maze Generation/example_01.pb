;Maze example by Joakim L. Christiansen
;Feel free to use and abuse!
;
;Extra credits to:
;http://weblog.jamisbuck.org/2011/2/7/maze-generation-algorithm-recap

EnableExplicit

#main=0
#main_image=0

Global wantedWidth=800, wantedHeight=600, blockSize=8
Global drawDelay = 1, showDelay = 2000
Global mazeWidth  = Round(wantedWidth/blockSize,#PB_Round_Up)
Global mazeHeight = Round(wantedHeight/blockSize,#PB_Round_Up)
Global image, Dim maze(mazeWidth,mazeHeight)

Procedure.l passageAllowed(fromX,fromY,toX,toY)
  Protected i,u,result
  If toX>0 And toX<mazeWidth And toY>0 And toY<mazeHeight
    result=#True
    If maze(toX,toY)=0
      result = #False
    EndIf
    If maze(toX,toY-1)=0 And toY-1<>fromY
      result = #False
    EndIf
    If maze(toX,toY+1)=0 And toY+1<>fromY
      result = #False
    EndIf
    If maze(toX-1,toY)=0 And toX-1<>fromX
      result = #False
    EndIf
    If maze(toX+1,toY)=0 And toX+1<>fromX
      result = #False
    EndIf
  EndIf
  ProcedureReturn result
EndProcedure
Procedure.l moveRandomDirection(*x.long,*y.long,checkOnly=#False)
  Protected result, NewList possibleDirection()
  ClearList(possibleDirection())
  If passageAllowed(*x\l,*y\l, *x\l,*y\l-1) ;up
    AddElement(possibleDirection()): possibleDirection() = 0
  EndIf
  If passageAllowed(*x\l,*y\l, *x\l,*y\l+1) ;down
    AddElement(possibleDirection()): possibleDirection() = 1
  EndIf
  If passageAllowed(*x\l,*y\l, *x\l-1,*y\l) ;left
    AddElement(possibleDirection()): possibleDirection() = 2
  EndIf
  If passageAllowed(*x\l,*y\l, *x\l+1,*y\l) ;right
    AddElement(possibleDirection()): possibleDirection() = 3
  EndIf
  If ListSize(possibleDirection()) > 0
    If checkOnly=#False
      SelectElement(possibleDirection(),Random(ListSize(possibleDirection())-1))
      Select possibleDirection()
        Case 0: *y\l-1
        Case 1: *y\l+1
        Case 2: *x\l-1
        Case 3: *x\l+1
      EndSelect
      maze(*x\l,*y\l) = 0
    EndIf
    result = #True
  Else
    result = #False
  EndIf
  ProcedureReturn result
EndProcedure
Procedure drawPassage(x,y)
  Protected round1,round2,round3,round4
  If maze(x,y-1)=1
    If maze(x+1,y)=1  ;top right
      round1=#True
    EndIf
    If maze(x-1,y)=1 ;top left
      round2=#True
    EndIf
  EndIf
  If maze(x,y+1)=1
    If maze(x+1,y)=1 ;bottom right
      round3=#True
    EndIf
    If maze(x-1,y)=1 ;bottom left
      round4=#True
    EndIf
  EndIf
  RoundBox(x*blockSize,y*blockSize,blockSize,blockSize,7,7,RGB(180,180,180))
  If Not round1
    Box(x*blockSize+blockSize/2,y*blockSize,blockSize/2,blockSize/2,RGB(180,180,180))
  EndIf
  If Not round2
    Box(x*blockSize,y*blockSize,blockSize/2,blockSize/2,RGB(180,180,180))
  EndIf
  If Not round3
    Box(x*blockSize+blockSize/2,y*blockSize+blockSize/2,blockSize/2,blockSize/2,RGB(180,180,180))
  EndIf
  If Not round4
    Box(x*blockSize,y*blockSize+blockSize/2,blockSize/2,blockSize/2,RGB(180,180,180))
  EndIf
EndProcedure
Procedure drawMaze()
  Protected x,y
  If StartDrawing(ImageOutput(image))
    Box(0,0,mazeWidth*blockSize,mazeHeight*blockSize,#Black)
    For y=0 To mazeHeight
      For x=0 To mazeWidth
        If maze(x,y) = 1
          Box(x*blockSize,y*blockSize,blockSize,blockSize,RGB(0,0,0))
        Else
          drawPassage(x,y)
        EndIf
      Next
    Next
    StopDrawing()
    SetGadgetState(#main_image,ImageID(image))
  EndIf
EndProcedure
Procedure createMaze(d)
  Protected x,y, scanY, scanX, mazeComplete, didNotMove, noMoreMoves
  Protected xScanDirection, yScanDirection

  For x=0 To mazeWidth ;fill with walls
    For y=0 To mazeHeight
      maze(x,y) = 1
    Next
  Next

  x = Random(mazeWidth-2)+1
  y = Random(mazeHeight-2)+1
  maze(x,y) = 0 ;place first brick

  Repeat
    If moveRandomDirection(@x,@y) = #False
      didNotMove = #True
      yScanDirection = Random(1)
      scanY = 1+Random(mazeHeight-2)
      Repeat
        xScanDirection = Random(1)
        scanX = 1+Random(mazeWidth-2)
        If xScanDirection=0: scanX=1: Else: scanX = mazeWidth-1: EndIf
        Repeat
          If maze(scanX,scanY) = 0
            If moveRandomDirection(@scanX,@scanY)
              x = scanX: y = scanY
              didNotMove = #False
              Break 2
            EndIf
          EndIf
          If xScanDirection = 0
            scanX + 1: If scanX > mazeWidth-1: Break: EndIf
          Else
            scanX - 1: If scanX < 1: Break: EndIf
          EndIf
        ForEver
        If yScanDirection = 0
          scanY + 1: If scanY > mazeHeight-1: Break: EndIf
        Else
          scanY - 1: If scanY < 1: Break: EndIf
        EndIf
      ForEver
      If didNotMove
        noMoreMoves = #True
        For scanY=1 To mazeHeight-1
          For scanX=1 To mazeWidth-1
            If maze(scanX,scanY) = 0
              If moveRandomDirection(@scanX,@scanY,#True)
                noMoreMoves = #False
                Break 2
              EndIf
            EndIf
          Next
        Next
        If noMoreMoves
          mazeComplete = #True
        EndIf
      EndIf
    EndIf
    If drawDelay
      drawMaze()
      Delay(drawDelay)
    EndIf
  Until mazeComplete
  Debug "Maze building completed!"
  drawMaze()
  Delay(showDelay)
  CreateThread(@createMaze(),0)
EndProcedure

image = CreateImage(#PB_Any,(mazeWidth+1)*blockSize,(mazeHeight+1)*blockSize,24)

OpenWindow(#main,0,0,(mazeWidth+1)*blockSize,(mazeHeight+1)*blockSize,"JLC's Maze Example v1.2",#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
ImageGadget(#main_image,0,0,(mazeWidth+1)*blockSize,(mazeHeight+1)*blockSize,ImageID(image))

CreateThread(@createMaze(),0)

Repeat
Until WaitWindowEvent()=#PB_Event_CloseWindow
; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 199
; FirstLine = 162
; Folding = -
; EnableXP