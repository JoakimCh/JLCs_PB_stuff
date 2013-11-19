EnableExplicit

IncludeFile "bruteforceEngine.pbi"

;To automatically try all combinations in lengths from 1 to 4 code like this can be used:
Define charset$, charCount, length, combination.q, maxCombinations.q
charset$ = "abc"
charCount = Len(charset$)
length = 1 ;start length
Repeat
  combination = 0
  maxCombinations = Pow(charCount,length)
  ;Debug "": Debug maxCombinations
  Repeat
    Debug getCharComb(charset$,combination,length)
    combination + 1
  Until combination = maxCombinations ;since it starts at 0
  length + 1
Until length = 5 ;end length

;If you're curious about the time a bruteforce would use to test all combinations then I've made some code for that too:
Debug bruteForceTimeCalc(36,4,50)

; IDE Options = PureBasic 5.20 LTS (Windows - x86)
; CursorPosition = 21
; EnableXP