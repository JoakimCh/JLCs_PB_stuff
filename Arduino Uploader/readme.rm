Basically it contains a procedure to load code from a HEX file and a procedure for communicating with Arduino's bootloader to upload the code after it uses the DTR pin to cause a restart of the board. The uploader was made by looking at the source code of the bootloader and implementing the minimum communication needed for a upload.

I have not cleaned it up much though (it should probably have better error checking and whatever), but people are free to change it for their own needs! It is mostly shared as an example.

For now I made it as a console application where you use it like this:
uploader.exe COMtoUse "filePath"
For example: uploader.exe COM7 "F:\yourHexFile.hex"

There has sometimes been a problem causing the restart but for me it mostly works, but maybe it can be improved.
If you try it please share your experience!