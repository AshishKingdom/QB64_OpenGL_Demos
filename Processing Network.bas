'@Author:Ashish Kushwaha
TYPE vector
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
END TYPE

TYPE particle
    pos AS vector
    rr AS _FLOAT
    i AS INTEGER
    j AS INTEGER
    r AS INTEGER
    g AS INTEGER
    b AS INTEGER
END TYPE
RANDOMIZE TIMER
_TITLE "Processing Network"
SCREEN _NEWIMAGE(800, 500, 32)

CONST speed = .05
DIM SHARED Particles(100) AS particle
DIM SHARED glAllow AS _BYTE
FOR i = 0 TO UBOUND(Particles)
    Particles(i).pos.x = RND * _WIDTH
    Particles(i).pos.y = RND * _HEIGHT
    Particles(i).pos.z = RND * 100
    Particles(i).j = RND * 7
    Particles(i).i = 5
    IF RND * 2 > 1 THEN Particles(i).i = -Particles(i).i
    Particles(i).rr = RND * 3
    SELECT CASE Particles(i).j
        CASE 0: Particles(i).r = 5: Particles(i).g = 205: Particles(i).b = 229
        CASE 1: Particles(i).r = 255: Particles(i).g = 184: Particles(i).b = 3
        CASE 2: Particles(i).r = 91: Particles(i).g = 3: Particles(i).b = 255
        CASE 3: Particles(i).r = 61: Particles(i).g = 62: Particles(i).b = 62
        CASE 4: Particles(i).r = 255: Particles(i).g = 0: Particles(i).b = 255
        CASE 5: Particles(i).r = 255: Particles(i).g = 0: Particles(i).b = 0
        CASE 6: Particles(i).r = 0: Particles(i).g = 255: Particles(i).b = 0
        CASE 7: Particles(i).r = 0: Particles(i).g = 0: Particles(i).b = 255
    END SELECT
    IF RND * 2 > 1 THEN Particles(i).j = -Particles(i).j
NEXT

glAllow = -1
DO
    CLS , _RGB(255, 255, 255)
    FOR i = 0 TO UBOUND(particles)
        CIRCLE (Particles(i).pos.x, Particles(i).pos.y), Particles(i).rr, _RGB(Particles(i).r, Particles(i).g, Particles(i).b)
        PAINT (Particles(i).pos.x, Particles(i).pos.y), _RGB(Particles(i).r, Particles(i).g, Particles(i).b), _RGB(Particles(i).r, Particles(i).g, Particles(i).b)
        Particles(i).pos.x = Particles(i).pos.x + Particles(i).j * speed
        Particles(i).pos.y = Particles(i).pos.y + Particles(i).i * speed
        IF Particles(i).pos.y > _HEIGHT - Particles(i).rr THEN Particles(i).i = -Particles(i).i
        IF Particles(i).pos.y < 0 + Particles(i).rr THEN Particles(i).i = -Particles(i).i
        IF Particles(i).pos.x > _WIDTH - Particles(i).rr THEN Particles(i).j = -Particles(i).j
        IF Particles(i).pos.x < 0 + Particles(i).rr THEN Particles(i).j = -Particles(i).j
    NEXT
    '   _LIMIT 60
    _DISPLAY
LOOP


SUB _GL STATIC
    IF NOT glAllow THEN EXIT SUB
    '  _glClearColor 1, 1, 1, 1
    ' _glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT

    _glEnable _GL_BLEND
    '   _glColor4f 1, 1, 1, .05
    FOR i = 0 TO UBOUND(particles)
        FOR j = i + 1 TO UBOUND(particles)
            IF distance(Particles(i).pos.x, Particles(i).pos.y, Particles(j).pos.x, Particles(j).pos.y) < 80 THEN
                FOR n = j + 1 TO UBOUND(particles)
                    IF distance(Particles(j).pos.x, Particles(j).pos.y, Particles(n).pos.x, Particles(n).pos.y) < 80 THEN
                        _glColor4f Particles(i).r / 255, Particles(i).g / 255, Particles(i).b / 255, .1
                        _glBegin _GL_TRIANGLES
                        _glVertex3f toGlX(Particles(i).pos.x), toGlY(Particles(i).pos.y), 0
                        _glVertex3f toGlX(Particles(j).pos.x), toGlY(Particles(j).pos.y), 0
                        _glVertex3f toGlX(Particles(n).pos.x), toGlY(Particles(n).pos.y), 0
                        _glEnd
                    END IF
                NEXT
            END IF
        NEXT
    NEXT
    _glFlush
END SUB

FUNCTION toGlX## (x#)
    x# = (_WIDTH / 2) - x#
    toGlX## = map(x#, -(_WIDTH / 2), _WIDTH / 2, 1, -1)
END FUNCTION

FUNCTION toGlY## (y#)
    y# = (_HEIGHT / 2) - y#
    toGlY## = map(y#, -(_HEIGHT / 2), _HEIGHT / 2, -1, 1)
END FUNCTION
FUNCTION toGlZ## (z#)
    toGlZ## = map(z#, 0, 100, 0, 1)
END FUNCTION

FUNCTION map## (value##, minRange##, maxRange##, newMinRange##, newMaxRange##)
    map## = ((value## - minRange##) / (maxRange## - minRange##)) * (newMaxRange## - newMinRange##) + newMinRange##
END FUNCTION

FUNCTION distance## (x1##, y1##, x2##, y2##)
    IF x1## > x2## THEN dx## = x1## - x2## ELSE dx## = x2## - x1##
    IF y1## > y2## THEN dy## = y1## - y2## ELSE dy## = y2## - y1##
    distance## = SQR(dx## * dx## + dy## * dy##)
END FUNCTION

