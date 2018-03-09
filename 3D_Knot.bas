'Coded in QB64 by Ashish on 9 March, 2018
'http://paulbourke.net/geometry/knots/
_TITLE "3D Knot [Press space for next knot]"

SCREEN _NEWIMAGE(700, 700, 32)

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE
DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE

DIM SHARED glAllow AS _BYTE, knot_type, ma
knot_type = 1
glAllow = -1

DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN
        knot_type = knot_type + 1
        ma = 0
        IF knot_type > 7 THEN knot_type = 1
    END IF
    _LIMIT 60
LOOP

SUB _GL ()
    STATIC glInit, clock
    ' static r, pos, theta, phi, beta

    IF NOT glAllow THEN EXIT SUB

    IF NOT glInit THEN
        glInit = -1
        aspect# = _WIDTH / _HEIGHT
        _glViewport 0, 0, _WIDTH, _HEIGHT
    END IF
    
    _glEnable _GL_DEPTH_TEST
    _glDepthMask _GL_TRUE
    
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1.0, 100.0
    
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
    ' gluLookAt 0,0,-1,0,0,0,0,1,0
    
    _glColor3f 1, 1, 1
    _glTranslatef 0, 0, 0
    _glRotatef clock * 90, 0, 1, 0
    _glLineWidth 3.0
    
    SELECT CASE knot_type
        CASE 7
            _glBegin _GL_LINE_STRIP
            FOR beta = 0 TO ma STEP .005
                r = .3 + .6 * SIN(6 * beta)
                theta = 2 * beta
                phi = _PI(.6) * SIN(12 * beta)
                x = r * COS(phi) * COS(theta)
                y = r * COS(phi) * SIN(theta)
                z = r * SIN(phi)
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma <= _PI THEN ma = ma + .005
        CASE 6
            _glBegin _GL_LINE_STRIP
            FOR beta = 0 TO ma STEP .005
                r = 1.2 * 0.6 * SIN(_PI(.5) * 6 * beta)
                theta = 4 * beta
                phi = _PI(.2) * SIN(6 * beta)
                x = r * COS(phi) * COS(theta)
                y = r * COS(phi) * SIN(theta)
                z = r * SIN(phi)
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma <= _PI(2) THEN ma = ma + .005
        CASE 5
            k = 1
            _glBegin _GL_LINE_STRIP
            FOR u = 0 TO ma STEP .005
                x = COS(u) * (2 - COS(2 * u / (2 * k + 1))) / 5
                y = SIN(u) * (2 - COS(2 * u / (2 * k + 1))) / 5
                z = -SIN(2 * u / (2 * k + 1)) / 5
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma < _PI(4 * k + 2) THEN ma = ma + .045
        CASE 4
            k = 2
            _glBegin _GL_LINE_STRIP
            FOR u = 0 TO ma STEP .005
                x = COS(u) * (2 - COS(2 * u / (2 * k + 1))) / 5
                y = SIN(u) * (2 - COS(2 * u / (2 * k + 1))) / 5
                z = -SIN(2 * u / (2 * k + 1)) / 5
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma < _PI(4 * k + 2) THEN ma = ma + .045
        CASE 3
            k = 3
            _glBegin _GL_LINE_STRIP
            FOR u = 0 TO ma STEP .005
                x = COS(u) * (2 - COS(2 * u / (2 * k + 1))) / 5
                y = SIN(u) * (2 - COS(2 * u / (2 * k + 1))) / 5
                z = -SIN(2 * u / (2 * k + 1)) / 5
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma < _PI(4 * k + 2) THEN ma = ma + .045
        CASE 2
            _glBegin _GL_LINE_STRIP
            FOR u = 0 TO ma STEP .005
                x = (41 * COS(u) - 18 * SIN(u) - 83 * COS(2 * u) - 83 * SIN(2 * u) - 11 * COS(3 * u) + 27 * SIN(3 * u)) / 200
                y = (36 * COS(u) + 27 * SIN(u) - 113 * COS(2 * u) + 30 * SIN(2 * u) + 11 * COS(3 * u) - 27 * SIN(3 * u)) / 200
                z = (45 * SIN(u) - 30 * COS(2 * u) + 113 * SIN(2 * u) - 11 * COS(3 * u) + 27 * SIN(3 * u)) / 200
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma < _PI(2) THEN ma = ma + .005
        CASE 1
            _glBegin _GL_LINE_STRIP
            FOR u = 0 TO ma STEP .005
                x = (-22 * COS(u) - 128 * SIN(u) - 44 * COS(3 * u) - 78 * SIN(3 * u)) / 200
                y = (-10 * COS(2 * u) - 27 * SIN(2 * u) + 38 * COS(4 * u) + 46 * SIN(4 * u)) / 200
                z = (70 * COS(3 * u) - 40 * SIN(3 * u)) / 200
                _glColor3f map(x, -1, 1, 0, 1), map(y, -1, 1, 0, 1), map(z, -1, 1, 0, 1)
                _glVertex3f x, y, z
            NEXT
            _glEnd
            IF ma < _PI(2) THEN ma = ma + .005
    END SELECT
    _glFlush
    
    clock = clock + .01
END SUB

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION
