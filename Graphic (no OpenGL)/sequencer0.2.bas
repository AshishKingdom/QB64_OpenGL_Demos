'Friends! I looked on Google Play, where there are plenty of applications that can photo sequence. And that is my source. My cellphone.
'That source, I took a photo sequence, it was about 55 MB JPG files. Through this program, I knocked it in BMP and then to a JPG. The program works exactly
'as I wrote yesterday to the forum. Look into the source photos where you can see individual images. But without Galleon SUB would not work. Galleon thank you!

'SEQUENCER  - program make BMP file, that contains pictures from your sources pictures. This BMP is then used as source file
'to video.
'Tested only in directory with source JPEGs. This JPG are from mobile phone, there is application Camera, that can making photosequencion.
'I see to GooglePlay, there is too much aplications for photo sequence. Then can everybody video in QB64 making.



_TITLE "Petr's Sequencer. Make you own QB64 Video!"
CLS
INPUT "Please input path + filemask for create bitmap or only filemask if files are in current directory."; bitmap$
com$ = "DIR " + bitmap$ + " /B /O >filelist.txt"
SHELL com$
IF _FILEEXISTS("filelist.txt") THEN cti "filelist.txt", 0 ELSE PRINT "Filelist not found": SYSTEM
vytvor lin, text$
KILL "filelist.txt"



INPUT "Convert completed. View output? (Y/N)"; outp$
IF LCASE$(outp$) = "y" THEN PRINT "Press any key after output is viewed to continue": SLEEP 2: SCREEN new&: SLEEP: SCREEN old&
INPUT "If you want save this output, insert name or press enter to quit without save:"; outp2$
IF outp2$ = "" THEN GOTO ending ELSE PRINT "Saving as "; outp2$; ".BMP, please wait."
SaveImage new&, outp2$
IF _FILEEXISTS("BMPTOJPG.EXE") THEN INPUT "Convert this BMP to JPG? (maximum JPG quality is set)"; jpgansw$
IF LCASE$(jpgansw$) = "y" THEN com2$ = "BMPTOJPG.EXE " + outp2$ + ".BMP": SHELL com2$ 'BMPTOJPG.EXE - program in QB64/programs/samples/n54/big/JPEGmake.bas i modified a little
'                                                                                      to convert anything what can _loadimage to JPG. But is modified to other program, i muss
'                                                                                      it rewriting, while output FULL HD is not enough for this program if you more frames have.


ending:
PRINT "Sequencer. V. 0.2 Alfa": _SOURCE 0: _FREEIMAGE new&: SYSTEM






END

SUB cti (file AS STRING, position AS INTEGER)
    SHARED lin, text$, lini

    DIM text$(10000)
    OPEN file$ FOR INPUT AS #1
    home: 'my lovely label name :D
    IF EOF(1) THEN GOTO fileend
    IF lin = position AND position <> 0 THEN EXIT SUB
    PRINT lin, position
    INPUT #1, tex$
    text$ = text$ + CHR$(13) + tex$
    lin = lin + 1
    lini = lin
    GOTO home
    fileend:
    CLOSE #1
END SUB



SUB vytvor (pocet AS INTEGER, file AS STRING)
    SHARED text$, lini, new&
    CLS
    PRINT text$
    INPUT "This files are be used to crate bitmap.  Is this ok? (Y/N)"; sure$
    IF UCASE$(sure$) = "Y" THEN GOTO inpt ELSE PRINT "Bitmap will not created": SYSTEM
    inpt:
    INPUT "Insert X, Y resolution for video source pictures, these will used to create every one frame"; xr, yr
    IF xr < 2 OR yr < 2 OR xr > 800 OR yr > 800 THEN PRINT "Invalid resolution": GOTO inpt 'when you use more than 800 x 800 / 1 frame and have long sequention, then its ended with error
    inpt2: '                                                                                "Not enough memory". Yeah, 32GB is not too. :-D
    ' INPUT "Input number of frames for one line:"; lines 'old usage (not good)
    lines = CINT(SQR(lini)) 'its best for good function.
    IF lines < 1 THEN PRINT "Ivnalid number. Minimum is 1": GOTO inpt2
    '-----------------------------------------------------------------------------------------

    PRINT "INFO: New bitmap use "; pocet; "pictures as frames. In one line is used "; lines; " frames."
    PRINT "Resolution every frame is"; xr; ","; yr; ". In Bitmap is"; pocet / lines; "columns."

    f$ = "filelist.txt"
    OPEN f$ FOR INPUT AS #1
    new& = _NEWIMAGE(xr * CINT(lines) + 1, yr * CINT(pocet / lines) + 1, 32)

    FOR make = 1 TO lini


        IF EOF(1) THEN GOTO fileend
        INPUT #1, tex$
        old& = _LOADIMAGE(tex$, 32)
        PRINT "Converting Frame "; make; "/"; lini; "("; tex$; ")"
        _SOURCE old&
        _PUTIMAGE (ssx, ssy)-(ssx + xr, ssy + yr), old&, new&
        ssx = ssx + xr
        IF ssx >= xr * lines THEN ssx = 0: ssy = ssy + yr
        _SOURCE 0
        _SOURCE new&
        _FREEIMAGE old&
    NEXT make

    fileend:
    CLOSE #1

END SUB


SUB SaveImage (image AS LONG, filename AS STRING)
    bytesperpixel& = _PIXELSIZE(image&)
    IF bytesperpixel& = 0 THEN PRINT "Text modes unsupported!": END
    IF bytesperpixel& = 1 THEN bpp& = 8 ELSE bpp& = 24
    x& = _WIDTH(image&)
    y& = _HEIGHT(image&)
    b$ = "BM????QB64????" + MKL$(40) + MKL$(x&) + MKL$(y&) + MKI$(1) + MKI$(bpp&) + MKL$(0) + "????" + STRING$(16, 0) 'partial BMP header info(???? to be filled later)
    IF bytesperpixel& = 1 THEN
        FOR c& = 0 TO 255 ' read BGR color settings from JPG image + 1 byte spacer(CHR$(0))
            cv& = _PALETTECOLOR(c&, image&) ' color attribute to read.
            b$ = b$ + CHR$(_BLUE32(cv&)) + CHR$(_GREEN32(cv&)) + CHR$(_RED32(cv&)) + CHR$(0) 'spacer byte
        NEXT
    END IF
    MID$(b$, 11, 4) = MKL$(LEN(b$)) ' image pixel data offset(BMP header)
    lastsource& = _SOURCE
    _SOURCE image&
    IF ((x& * 3) MOD 4) THEN padder$ = STRING$(4 - ((x& * 3) MOD 4), 0)
    FOR py& = y& - 1 TO 0 STEP -1 ' read JPG image pixel color data
        r$ = ""
        FOR px& = 0 TO x& - 1
            c& = POINT(px&, py&) 'POINT 32 bit values are large LONG values
            IF bytesperpixel& = 1 THEN r$ = r$ + CHR$(c&) ELSE r$ = r$ + LEFT$(MKL$(c&), 3)
        NEXT px&
        d$ = d$ + r$ + padder$
    NEXT py&
    _SOURCE lastsource&
    MID$(b$, 35, 4) = MKL$(LEN(d$)) ' image size(BMP header)
    b$ = b$ + d$ ' total file data bytes to create file
    MID$(b$, 3, 4) = MKL$(LEN(b$)) ' size of data file(BMP header)
    IF LCASE$(RIGHT$(filename$, 4)) <> ".bmp" THEN ext$ = ".bmp"
    f& = FREEFILE
    OPEN filename$ + ext$ FOR OUTPUT AS #f&: CLOSE #f& ' erases an existing file
    OPEN filename$ + ext$ FOR BINARY AS #f&
    PUT #f&, , b$
    CLOSE #f&
END SUB

REM Code by Galleon
REM This SUB program can also be Included with any program!
REM Very thank you, Galleon! Petr.







