Ever wanted to send network data just by typing the hex for example? (nice to have when trying to implement certain protocols)
I made some functions to make my own life easier, maybe it can help you too? :D Feel free to add more stuff or optimize.

Could easily make some kind of hex editor with this.

Currently I have added:
memoryToHex.s(address,length,byteorder=#bigEndian)
hexToMemory(address,hex$,byteorder=#bigEndian)
hexToText.s(hex$)
hexToTextSanitized.s(hex$)
SendNetworkHex.l(connection,hex$)
getHexSize.l(hex$)

strToHex.s(string$)
longToHex.s(long,byteorder=#littleEndian)
wordToHex.s(word.w,byteorder=#littleEndian)
byteToHex.s(byte.b)

hexToLong(*long,hex$,byteorder=#littleEndian)
hexToWord(*word,hex$,byteorder=#littleEndian)
hexToByte(*byte,hex$)

EDIT: Now with byte order support (little and big endian).
