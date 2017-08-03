_TITLE "Plovouci foto / Petr.Pr@Email.cz"
j& = _LOADIMAGE("d.jpg", 32) 'HERE INSERT YOU PICTURE
i& = _NEWIMAGE(1024, 768, 32)
W& = _WIDTH(j&)
H& = _HEIGHT(j&)
IF H& > W& THEN SWAP H&, W&
_PUTIMAGE , j&, i&, (0, 0)-(W&, H&) 'original picture resized to 1024 x 768 for higher power
_FREEIMAGE j&
SCREEN i&
_FULLSCREEN
_DISPLAY


'SLEEP 5
DO WHILE INKEY$ = ""
    regenre:
    X = X + 35: IF X > _WIDTH(i&) THEN X = 0: y = y + 35 '     x source
    IF y > _HEIGHT(i&) THEN X = 0: y = 0 '                     y source
    X2 = 150 'CINT(RND * _WIDTH(i&)) 'cil x              (dest x)
    Y2 = 150 'CINT(RND * _HEIGHT(i&)) 'cil y             (dest y)
    prumer = 70 'CINT(RND * 80) '                        output size

    LineVideo 300, 220, 600, 500 'linevideo sirka, vyska, x, y                               LineVideo Width, Height, x ,y (x and y is position this window)
    razitko X, y, X2, Y2, prumer 'its first SUB, then X,Y not write to sub as SHARED
    _DISPLAY
LOOP

'----------------------------------------------------------------------------------------


SUB razitko (x AS INTEGER, y AS INTEGER, x2 AS INTEGER, y2 AS INTEGER, polomer AS INTEGER)
    FOR obvod = 0 TO polomer
        FOR a = 0 TO 2 * 3.1415927! * (2 * polomer) 'obvod kruhu se pocita 2 * PI * r, tady je nutno dat 2 r
            scan& = POINT(obvod * SIN(a) + x, obvod * COS(a) + y)
            PSET (obvod * SIN(a) + x2, obvod * COS(a) + y2), scan&
        NEXT a

    NEXT obvod

    _LIMIT 20
END SUB

SUB LineVideo (sirka AS INTEGER, vyska AS INTEGER, ix AS INTEGER, iy AS INTEGER)
    SHARED X, y
    FOR tahy = 0 TO vyska
        FOR tahx = 0 TO sirka
            tah& = POINT(tahx + (1024 - X), tahy + (768 - y))
            PSET (tahx + ix, tahy + iy), tah&
        NEXT tahx
    NEXT tahy
END SUB









