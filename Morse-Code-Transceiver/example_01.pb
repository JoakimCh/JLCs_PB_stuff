EnableExplicit

IncludeFile "main.pbi"

InitSound()
setWaveFormat(16,44100)
initializeMorsecode()
Define text$, morse$
text$ = "hello morse code world"
morse$ = textToMorse(text$)
Debug morse$
Debug morseToText(morse$)
playMorse(morse$,100)
