'Coded By Ashish on 7 March, 2018

_TITLE "3D Spirograph"

SCREEN _NEWIMAGE(800, 600, 32)

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE sphere
    pos AS vec3
    r AS SINGLE
	theta as double
	phi as double
    angStp AS DOUBLE
END TYPE

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
    SUB glutWireSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
END DECLARE

DIM SHARED __sphere(6) AS sphere, glAllow AS _BYTE
DIM SHARED tracer(12000) AS vec3, f

init:
ERASE tracer
v = 0
f = 0
__sphere(0).pos.x = 0
__sphere(0).pos.y = 0
__sphere(0).pos.z = 0
__sphere(0).r = 1
__sphere(0).angStp = p5random(.001, .1)
__sphere(0).phi = p5random(0,_pi(2))
__sphere(0).theta = p5random(0,_pi)
FOR i = 1 TO UBOUND(__sphere)

    __sphere(i).r = __sphere(i - 1).r / 2
    __sphere(i).angStp = p5random(-.1, .1)
	__sphere(i).theta = p5random(0,_pi)
	__sphere(i).phi = p5random(0,_pi(2))
NEXT

_GLRENDER _BEHIND
glAllow = -1
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN GOTO init
    FOR i = 0 TO UBOUND(__sphere)
        __sphere(i).theta = __sphere(i).theta + __sphere(i).angStp/2
		__sphere(i).phi = __sphere(i).phi + __sphere(i).angStp
    NEXT
    f = f + 1
    IF f > 4 THEN
        v = v + 1
        tracer(v) = __sphere(UBOUND(__sphere)).pos
    END IF
    _LIMIT 60
    _DISPLAY
LOOP

SUB _GL ()
    STATIC clock!, glInit AS _BYTE, aspect#

    IF NOT glAllow THEN EXIT SUB
    IF NOT glInit THEN
        glInit = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT
        aspect# = _WIDTH / _HEIGHT
    END IF

    _glEnable _GL_DEPTH_TEST
    '_glEnable _GL_BLEND

    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0

    _glShadeModel _GL_SMOOTH

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1.0, 100.0

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    gluLookAt 0, 0, -8, 0, 0, 0, 0, -1, 0

    _glTranslatef 0, 0, 0
   _glRotatef clock! * 90, 0, 1, 0
    _glColor4f 1, 1, 1, .3
    _glLineWidth 1.0
    glutWireSphere __sphere(0).r, UBOUND(__sphere) * 20, UBOUND(__sphere) * 20

    FOR i = 1 TO UBOUND(__sphere)
        __sphere(i).pos.x = SIN(__sphere(i - 1).theta) * cos(__sphere(i - 1).phi)*(__sphere(i - 1).r + __sphere(i).r) + (__sphere(i - 1).pos.x)
        __sphere(i).pos.y = COS(__sphere(i - 1).theta) * sin(__sphere(i-1).phi)*(__sphere(i - 1).r + __sphere(i).r) + (__sphere(i - 1).pos.y)
        __sphere(i).pos.z = cos(__sphere(i - 1).theta) * (__sphere(i - 1).r + __sphere(i).r) + (__sphere(i - 1).pos.z)
        _glPushMatrix
        _glTranslatef __sphere(i).pos.x, __sphere(i).pos.y, __sphere(i).pos.z
        glutWireSphere __sphere(i).r, (UBOUND(__sphere) + 1 - i) * 20, (UBOUND(__sphere) + 1 - i) * 20
        _glPopMatrix
    NEXT
    IF f > 6 THEN
        _glDisable _GL_LIGHTING
        _glDisable _GL_LIGHT0
        _glTranslatef 0, 0, 0
        _glLineWidth 2.0
        _glPushMatrix
        _glColor3f 1, 0, 0
        FOR i = 1 TO f - 2
            _glBegin _GL_LINES
            _glColor3f map(tracer(i).x * tracer(i).y, -9, 9, .4, .1), map(tracer(i).x, -3, 3, .2, 1), map(tracer(i).y, -3, 3, 1, .2)
            _glVertex3f tracer(i).x, tracer(i).y, tracer(i).z
            _glVertex3f tracer(i + 1).x, tracer(i + 1).y, tracer(i + 1).z
            _glEnd
        NEXT
        _glPopMatrix
    END IF

    clock! = clock! + .01

    _glFlush
END SUB


'taken from p5js.bas
'https://bit.ly/p5jsbas
FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

=======
'Coded By Ashish on 7 March, 2018

_TITLE "3D Spirograph"

SCREEN _NEWIMAGE(800, 600, 32)

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE sphere
    pos AS vec3
    r AS SINGLE
	theta as double
	phi as double
    angStp AS DOUBLE
END TYPE

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
    SUB glutWireSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
END DECLARE

DIM SHARED __sphere(6) AS sphere, glAllow AS _BYTE
DIM SHARED tracer(12000) AS vec3, f

init:
ERASE tracer
v = 0
f = 0
__sphere(0).pos.x = 0
__sphere(0).pos.y = 0
__sphere(0).pos.z = 0
__sphere(0).r = 1
__sphere(0).angStp = p5random(.001, .1)
__sphere(0).phi = p5random(0,_pi(2))
__sphere(0).theta = p5random(0,_pi)
FOR i = 1 TO UBOUND(__sphere)

    __sphere(i).r = __sphere(i - 1).r / 2
    __sphere(i).angStp = p5random(-.1, .1)
	__sphere(i).theta = p5random(0,_pi)
	__sphere(i).phi = p5random(0,_pi(2))
NEXT

_GLRENDER _BEHIND
glAllow = -1
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN GOTO init
    FOR i = 0 TO UBOUND(__sphere)
        __sphere(i).theta = __sphere(i).theta + __sphere(i).angStp/2
		__sphere(i).phi = __sphere(i).phi + __sphere(i).angStp
    NEXT
    f = f + 1
    IF f > 4 THEN
        v = v + 1
        tracer(v) = __sphere(UBOUND(__sphere)).pos
    END IF
    _LIMIT 60
    _DISPLAY
LOOP

SUB _GL ()
    STATIC clock!, glInit AS _BYTE, aspect#

    IF NOT glAllow THEN EXIT SUB
    IF NOT glInit THEN
        glInit = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT
        aspect# = _WIDTH / _HEIGHT
    END IF

    _glEnable _GL_DEPTH_TEST
    '_glEnable _GL_BLEND

    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0

    _glShadeModel _GL_SMOOTH

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1.0, 100.0

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    gluLookAt 0, 0, -8, 0, 0, 0, 0, -1, 0

    _glTranslatef 0, 0, 0
   _glRotatef clock! * 90, 0, 1, 0
    _glColor4f 1, 1, 1, .3
    _glLineWidth 1.0
    glutWireSphere __sphere(0).r, UBOUND(__sphere) * 20, UBOUND(__sphere) * 20

    FOR i = 1 TO UBOUND(__sphere)
        __sphere(i).pos.x = SIN(__sphere(i - 1).theta) * cos(__sphere(i - 1).phi)*(__sphere(i - 1).r + __sphere(i).r) + (__sphere(i - 1).pos.x)
        __sphere(i).pos.y = COS(__sphere(i - 1).theta) * sin(__sphere(i-1).phi)*(__sphere(i - 1).r + __sphere(i).r) + (__sphere(i - 1).pos.y)
        __sphere(i).pos.z = cos(__sphere(i - 1).theta) * (__sphere(i - 1).r + __sphere(i).r) + (__sphere(i - 1).pos.z)
        _glPushMatrix
        _glTranslatef __sphere(i).pos.x, __sphere(i).pos.y, __sphere(i).pos.z
        glutWireSphere __sphere(i).r, (UBOUND(__sphere) + 1 - i) * 20, (UBOUND(__sphere) + 1 - i) * 20
        _glPopMatrix
    NEXT
    IF f > 6 THEN
        _glDisable _GL_LIGHTING
        _glDisable _GL_LIGHT0
        _glTranslatef 0, 0, 0
        _glLineWidth 2.0
        _glPushMatrix
        _glColor3f 1, 0, 0
        FOR i = 1 TO f - 2
            _glBegin _GL_LINES
            _glColor3f map(tracer(i).x * tracer(i).y, -9, 9, .4, .1), map(tracer(i).x, -3, 3, .2, 1), map(tracer(i).y, -3, 3, 1, .2)
            _glVertex3f tracer(i).x, tracer(i).y, tracer(i).z
            _glVertex3f tracer(i + 1).x, tracer(i + 1).y, tracer(i + 1).z
            _glEnd
        NEXT
        _glPopMatrix
    END IF

    clock! = clock! + .01

    _glFlush
END SUB


'taken from p5js.bas
'https://bit.ly/p5jsbas
FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

>>>>>>> db1670cd8b28c1e4d58790c7f4d29c0d649f9e56
