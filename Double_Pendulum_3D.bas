'Coded By Ashish on 4 March, 2018

_TITLE "3D Double Pendulum [Press Space for new settings]"
SCREEN _NEWIMAGE(800, 600, 32)

TYPE vec3
    x AS DOUBLE
    y AS DOUBLE
    z AS DOUBLE
END TYPE

TYPE pendlm
    pos AS vec3
    r AS DOUBLE
    ang AS DOUBLE
    angInc AS DOUBLE
    angSize AS DOUBLE
END TYPE

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
    SUB glutSolidSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
END DECLARE

DIM SHARED glAllow AS _BYTE
DIM SHARED pendulum(1) AS pendlm, t1 AS vec3, t2 AS vec3
DIM SHARED tracer(3000) AS vec3, tracerSize AS _UNSIGNED LONG
RANDOMIZE TIMER

settings:
tracerSize = 0
g = 0

pendulum(0).pos.x = 0
pendulum(0).pos.y = 0
pendulum(0).pos.z = 0
pendulum(0).r = p5random(.7, 1.1)
pendulum(0).angInc = p5random(0, _PI(2))
pendulum(0).angSize = p5random(_PI(.3), _PI(.6))

pendulum(1).r = p5random(.25, .5)
pendulum(1).angInc = p5random(0, _PI(2))
pendulum(1).angSize = p5random(_PI(.3), _PI(1.1))

glAllow = -1
_GLRENDER _BEHIND
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN GOTO settings
    pendulum(0).ang = SIN(pendulum(0).angInc) * pendulum(0).angSize + _PI(.5)

    t1.x = COS(pendulum(0).ang) * pendulum(0).r + pendulum(0).pos.x
    t1.y = SIN(pendulum(0).ang) * pendulum(0).r + pendulum(0).pos.y
    t1.z = COS(pendulum(0).ang) * pendulum(0).r + pendulum(0).pos.z

    pendulum(1).pos = t1

    pendulum(1).ang = SIN(pendulum(1).angInc) * pendulum(1).angSize + pendulum(0).ang

    t2.x = COS(pendulum(1).ang) * pendulum(1).r + pendulum(1).pos.x
    t2.y = SIN(pendulum(1).ang) * pendulum(1).r + pendulum(1).pos.y
    t2.z = SIN(pendulum(1).ang) * pendulum(1).r + pendulum(1).pos.z

    pendulum(0).angInc = pendulum(0).angInc + .02
    pendulum(1).angInc = pendulum(1).angInc + .043

    IF tracerSize < UBOUND(tracer) - 1 AND g > 40 THEN tracer(tracerSize) = t2
    IF g > 40 AND tracerSize < UBOUND(tracer) - 1 THEN tracerSize = tracerSize + 1

    g = g + 1
    _LIMIT 60
LOOP

SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB

    IF NOT glInit THEN
        glInit = -1
        aspect# = _WIDTH / _HEIGHT
        _glViewport 0, 0, _WIDTH, _HEIGHT
    END IF

    _glEnable _GL_BLEND
    _glEnable _GL_DEPTH_TEST


    _glShadeModel _GL_SMOOTH

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1.0, 1000.0

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    gluLookAt 0, 0, -4, 0, 1, 0, 0, -1, 0

    _glRotatef clock# * 90, 0, 1, 0
    _glLineWidth 3.0

    _glPushMatrix

    _glColor4f 1, 1, 1, .7

    _glBegin _GL_LINES
    _glVertex3f pendulum(0).pos.x, pendulum(0).pos.y, pendulum(0).pos.z
    _glVertex3f t1.x, t1.y, t1.z
    _glEnd
    _glPopMatrix

    _glPushMatrix

    _glBegin _GL_LINES
    _glVertex3f t1.x, t1.y, t1.z
    _glVertex3f t2.x, t2.y, t2.z
    _glEnd

    IF tracerSize > 3 THEN
        _glBegin _GL_LINES
        FOR i = 0 TO tracerSize - 2
            _glColor3f 0, map(tracer(i).x, -1, 1, .5, 1), map(tracer(i).y, -1, 1, .5, 1)
            _glVertex3f tracer(i).x, tracer(i).y, tracer(i).z
            _glColor3f 0, map(tracer(i + 1).x, -1, 1, .5, 1), map(tracer(i + 1).y, -1, 1, .5, 1)
            _glVertex3f tracer(i + 1).x, tracer(i + 1).y, tracer(i + 1).z
        NEXT
        _glEnd
    END IF
    _glPopMatrix

    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    _glPushMatrix
    _glTranslatef t1.x, t1.y, t1.z

    _glColor3f .8, .8, .8
    glutSolidSphere .1, 15, 15
    _glPopMatrix

    _glPushMatrix
    _glTranslatef t2.x, t2.y, t2.z

    _glColor3f .8, .8, .8
    glutSolidSphere .1, 15, 15
    _glPopMatrix

    clock# = clock# + .01

    _glFlush
END SUB



'taken from p5js.bas
'https://bit.y/p5jsbas
FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION
