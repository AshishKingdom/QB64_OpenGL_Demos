'Open Gl Lines write Petr
_FULLSCREEN
num = 100 'if sets other number, then set _limit on line 62 too.
sel = 0
siz = 2
index = 1
res = 2250
resy = 2000
RANDOMIZE TIMER
DIM SHARED X(num) AS INTEGER
DIM SHARED Y(num) AS INTEGER
DIM SHARED beh(num) AS INTEGER
DIM SHARED behy(num) AS INTEGER
DIM SHARED size(num) AS INTEGER

TYPE OpenColor
    R AS SINGLE
    G AS SINGLE
    B AS SINGLE
    Rm AS SINGLE
    Gm AS SINGLE
    Bm AS SINGLE
    A AS SINGLE
    Am AS SINGLE
END TYPE

DIM SHARED OpenColor(num) AS OpenColor

FOR VP = 1 TO num
    X(VP) = RND * 3500
    Y(VP) = RND * 500
    beh(VP) = 1 'step
    behy(VP) = 1.3 'Y step
    OpenColor(VP).R = (RND * 128) / 256
    OpenColor(VP).G = (RND * 128) / 256
    OpenColor(VP).B = (RND * 128) / 256
    OpenColor(VP).Rm = .001
    OpenColor(VP).Gm = .001
    OpenColor(VP).Bm = .006
    OpenColor(VP).A = (RND * 128) / 256
    OpenColor(VP).Am = 0.1
    size(VP) = 1

NEXT VP
i& = _SCREENIMAGE
SCREEN _NEWIMAGE(_DESKTOPWIDTH, _DESKTOPHEIGHT, 32)
_SETALPHA 125, , i&
LINE (0, 0)-(_WIDTH, _HEIGHT), _RGB32(0, 0, 0), BF
_PUTIMAGE (0, 0), i&, 0
DO
    FOR index = 1 TO num
        _PRINTSTRING (20, 100), TIME$ + " Press ESC to end", (0)
        IF X(index) > res - 1 THEN beh(index) = beh(index) * -1 - (RND / 1.7): size(index) = size(index) + siz: IF siz > 20 THEN siz = siz * -1
        IF X(index) < 2 THEN beh(index) = beh(index) * -1 + (RND / 1.7): size(index) = size(index) + siz: IF siz < 0 THEN siz = siz * -1
        IF Y(index) > resy - 1 THEN behy(index) = behy(index) * -1 - (RND / 1.7): size(index) = size(index) - siz: IF siz > 20 THEN siz = siz * -1
        IF Y(index) < 2 THEN behy(index) = behy(index) * -1 + (RND / 1.7): size(index) = size(index) - siz: IF siz < 0 THEN siz = siz * -1

        IF OpenColor(index).A > 1 OR OpenColor(index).A < 0 THEN OpenColor(index).Am = OpenColor(index).Am * -1: OpenColor(index).A = CINT(OpenColor(index).A) ELSE OpenColor(index).A = OpenColor(index).A + OpenColor(index).Am
        IF OpenColor(index).R > 1 OR OpenColor(index).R < 0 THEN OpenColor(index).Rm = OpenColor(index).Rm * -1: OpenColor(index).R = CINT(OpenColor(index).R) ELSE OpenColor(index).R = OpenColor(index).R + OpenColor(index).Rm
        IF OpenColor(index).G > 1 OR OpenColor(index).G < 0 THEN OpenColor(index).Gm = OpenColor(index).Gm * -1: OpenColor(index).G = CINT(OpenColor(index).G) ELSE OpenColor(index).G = OpenColor(index).G + OpenColor(index).Gm
        IF OpenColor(index).B > 1 OR OpenColor(index).B < 0 THEN OpenColor(index).Bm = OpenColor(index).Bm * -1: OpenColor(index).B = CINT(OpenColor(index).B) ELSE OpenColor(index).B = OpenColor(index).B + OpenColor(index).Bm
        X(index) = X(index) + beh(index)
        Y(index) = Y(index) + behy(index)
        IF beh(index) > 10 THEN beh(index) = 5
        IF behy(index) > 10 THEN behy(index) = 5
        _LIMIT 200000

    NEXT index
    predat = predat + 1: IF predat > num THEN predat = 1

LOOP UNTIL _KEYHIT = 27







SUB _GL
SHARED res, index, setup, num, predat, ogla, resy, sel, dee
IF TIMER > dee THEN dee = TIMER + 10: sel = sel + 1: IF sel > 8 THEN sel = 1

_glClearColor 0.0, 0.0, 0.0, 0.0 '           // nastaveni mazaci barvy na cernou
_glClear GL_color_BUFFER_BIT '               // vymazani bitovych rovin barvoveho
_glMatrixMode _GL_PROJECTION
_glOrtho 0, res, 0, resy, -1, 1 '
REDIM r, g, b, r1, g1, b1 AS SINGLE

_glEnable _GL_LINE_SMOOTH

SELECT CASE sel
    CASE 1
        FOR ogl = 2 TO num
            _glLineWidth size(predat)
            _glBegin _GL_LINES

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glEnable _GL_LINE_SMOOTH
            _glColor4f r!, g!, b, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a1!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f r!, g!, b!, a!
            _glEnd
        NEXT ogl
    CASE 2
        FOR ogl = 3 TO num
            _glLineWidth size(predat)
            _glBegin _GL_TRIANGLES

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glColor4f r!, g!, b!, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a1!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f 1 - r!, 1 - g!, 1 - b!, 1 - a!
            _glVertex2i X(ogl - 2), Y(ogl - 2)
            _glEnd
        NEXT ogl
    CASE 3
        FOR ogl = 1 TO num
            _glLineWidth size(predat)
            _glBegin _GL_POINTS

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glColor4f r!, g!, b!, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a1!
            _glEnd
        NEXT ogl
    CASE 4
        FOR ogl = 4 TO num
            _glLineWidth size(predat)
            _glBegin _GL_QUADS

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glRotatef ogl / 10, 500, 150, 555
            _glColor4f r!, g!, b!, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f 1 - r!, 1 - g!, 1 - b!, a!
            _glVertex2i X(ogl - 2), Y(ogl - 2)
            _glColor4f g! - r!, b! - g!, g! - b!, a!
            _glVertex2i X(ogl - 3), Y(ogl - 3)
            _glColor4f b! - r!, r! - g!, g! - b!, a!
            _glEnd
        NEXT ogl
    CASE 5
        FOR ogl = 4 TO num
            _glLineWidth size(predat)
            _glBegin _GL_TRIANGLE_STRIP

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glColor4f r!, g!, b!, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f 1 - r!, 1 - g!, 1 - b!, a1!
            _glVertex2i X(ogl - 2), Y(ogl - 2)
            _glColor4f g! - r!, b! - g!, g! - b!, a1!
            _glVertex2i X(ogl - 3), Y(ogl - 3)
            _glColor4f b! - r!, r! - g!, g! - b!, a!
            _glEnd
        NEXT ogl
    CASE 6

        FOR ogl = 4 TO num
            _glLineWidth size(predat)
            _glBegin _GL_TRIANGLE_FAN

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glColor3f r!, g!, b!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a1!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f 1 - r!, 1 - g!, 1 - b!, a1!
            _glVertex2i X(ogl - 2), Y(ogl - 2)
            _glColor4f g! - r!, b! - g!, g! - b!, a!
            _glVertex2i X(ogl - 3), Y(ogl - 3)
            _glColor4f b! - r!, r! - g!, g! - b!, a!
            _glEnd
        NEXT ogl
    CASE 7
        FOR ogl = 4 TO num
            _glLineWidth size(predat)
            _glBegin _GL_QUAD_STRIP

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glColor4f r!, g!, b!, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a1!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f 1 - r!, 1 - g!, 1 - b!, a1!
            _glVertex2i X(ogl - 2), Y(ogl - 2)
            _glColor4f g! - r!, b! - g!, g! - b!, a!
            _glVertex2i X(ogl - 3), Y(ogl - 3)
            _glColor4f b! - r!, r! - g!, g! - b!, a!
            _glEnd
        NEXT ogl
    CASE 8
        FOR ogl = 6 TO num
            _glLineWidth size(predat)
            _glBegin _GL_POLYGON

            r! = OpenColor(ogl).R: g! = OpenColor(ogl).G: b! = OpenColor(ogl).B: a! = OpenColor(ogl).A
            r1! = OpenColor(ogl - 1).R: g1! = OpenColor(ogl - 1).G: b1! = OpenColor(ogl - 1).B: a1! = OpenColor(ogl - 1).A
            _glColor4f r!, g!, b!, a!
            _glVertex2i X(ogl), Y(ogl)
            _glColor4f r1!, g1!, b1!, a1!
            _glVertex2i X(ogl - 1), Y(ogl - 1)
            _glColor4f 1 - r!, 1 - g!, 1 - b!, a1!
            _glVertex2i X(ogl - 2), Y(ogl - 2)
            _glColor4f g! - r!, b! - g!, g! - b!, 1 - a!
            _glVertex2i X(ogl - 3), Y(ogl - 3)
            _glColor4f b! - r!, r! - g!, g! - b!, b! - a!
            _glVertex2i X(ogl - 4), Y(ogl - 4)
            _glColor4f r! - b!, 1 - g!, b!, a! - r!
            _glVertex2i X(ogl - 5), Y(ogl - 5)
            _glColor4f r!, r! - g!, g! - b!, a1!


            _glEnd
        NEXT ogl
END SELECT
_glFlush

END SUB

