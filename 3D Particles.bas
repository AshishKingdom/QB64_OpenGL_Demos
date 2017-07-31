
_TITLE "3D Particles"
SCREEN _NEWIMAGE(800, 600, 32)

TYPE vector
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
END TYPE

TYPE particle
    pos AS vector
    vel AS vector
    life AS INTEGER
    dead AS INTEGER
END TYPE

DIM SHARED glAllow AS _BYTE

DIM SHARED Particles(10000) AS particle

FOR i = 0 TO UBOUND(particles)
    Particles(i).pos.x = 0
    Particles(i).pos.y = 0
    Particles(i).pos.z = 0
    Particles(i).vel.x = p5random(-.005, .005)
    Particles(i).vel.y = p5random(-.005, .005)
    Particles(i).vel.z = p5random(-.005, .005)
    Particles(i).dead = RND * 200 + 55
NEXT

glAllow = -1

DO
    _LIMIT 60
LOOP UNTIL INKEY$ <> ""



SUB _GL () STATIC

    IF NOT glAllow THEN EXIT SUB

    _glRotatef xangle, 1, 0, 0
    _glRotatef yangle, 0, 1, 0
    _glRotatef zangle, 0, 0, 1

    _glBegin _GL_POINTS

    xangle = xangle + 1
    yangle = yangle + 1
    zangle = zangle + 1

    FOR i = 0 TO mx

        c## = map(Particles(i).life, 0, Particles(i).dead, 1, 0.25)

        _glColor3f c##, c##, c##

        _glVertex3d Particles(i).pos.x, Particles(i).pos.y, Particles(i).pos.z

        Particles(i).pos.x = Particles(i).pos.x + Particles(i).vel.x
        Particles(i).pos.y = Particles(i).pos.y + Particles(i).vel.y
        Particles(i).pos.z = Particles(i).pos.z + Particles(i).vel.z

        Particles(i).life = Particles(i).life + 1

        IF Particles(i).life > Particles(i).dead THEN

            Particles(i).life = 0
            Particles(i).pos.x = 0
            Particles(i).pos.y = 0
            Particles(i).pos.z = 0
            Particles(i).vel.x = p5random(-.005, .005)
            Particles(i).vel.y = p5random(-.005, .005)
            Particles(i).vel.z = p5random(-.005, .005)
            Particles(i).dead = RND * 200 + 55

        END IF

    NEXT

    IF mx < UBOUND(particles) THEN mx = mx + 10

    _glEnd
    _glFlush

END SUB

'these functions are taken from p5js.bas, just modified to work with _FLOAT data types
FUNCTION map## (value##, minRange##, maxRange##, newMinRange##, newMaxRange##)
    map## = ((value## - minRange##) / (maxRange## - minRange##)) * (newMaxRange## - newMinRange##) + newMinRange##
END FUNCTION

FUNCTION p5random## (mn##, mx##)
    IF mn## > mx## THEN
        tmp## = mn##
        mn## = mx##
        mx## = tmp##
    END IF
    p5random## = RND * (mx## - mn##) + mn##
END FUNCTION

