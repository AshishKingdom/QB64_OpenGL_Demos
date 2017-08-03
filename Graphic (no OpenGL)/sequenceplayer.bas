_TITLE "Sequence reader + viewer! /Petr/"
ms& = _NEWIMAGE(1024, 768, 32)

SCREEN ms&
DO WHILE INKEY$ = ""
    ReadFrame 320, 320, sourc&, 40, 160, 140, myscr& ' Frames in source&(c.bmp) are on X 320 and on Y 200 pixel
LOOP


END



SUB ReadFrame (X AS INTEGER, Y AS INTEGER, framesource AS LONG, frames AS INTEGER, viewX AS INTEGER, viewY AS INTEGER, place AS LONG) 'ReadFrame X, Y (X = frame width (width of every one frame in source!), y = frame height), framesource (source& BMP or JPG file),
    SHARED ms&

    '                                                                               frames - total number frames in source file, viewX and ViewY - coordinates to display video, plase& - array who is video insert.
    test = CINT(SQR(frames))
    L& = _LOADIMAGE("h.jpg", 32)
    _FULLSCREEN
    FOR RF = 1 TO frames
        LOCATE 1, 1: PRINT "Now playing frame nr."; RF
        IF sx >= test * X THEN sx = 0: sy = sy + Y
        _DEST ms&
        _PUTIMAGE (viewX, viewY), L&, ms&, (sx, sy)-(sx + X, sy + Y)

        _DISPLAY
        sx = sx + X
        _LIMIT 3
    NEXT RF

END SUB

'     And now if you'll excuse me. I'm going to drunk.
