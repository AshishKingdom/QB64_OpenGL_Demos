'@Author:Ashish Kushwaha
'28 Feb, 2020s
_TITLE "Menger Sponge"
SCREEN _NEWIMAGE(600, 600, 32)

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

DECLARE LIBRARY
    SUB glutSolidCube (BYVAL dsize AS DOUBLE)
END DECLARE

iteration = 3
size = 0.5
n = (20 ^ iteration) - 1

DIM SHARED glAllow, cubeLoc(n) AS vec3, fundamentalCubeSize
fundamentalCubeSize = size / (3 ^ iteration)
initFractal 0, 0, 0, size, iteration

PRINT (n + 1); " Cubes will rendered with total of "; 8 * (n + 1); " vertices"
PRINT "Hit a Key"
SLEEP
glAllow = 1
DO
    WHILE _MOUSEINPUT: WEND
    _LIMIT 40
LOOP

SUB _GL () STATIC
    DIM clr(3)
    IF glAllow = 0 THEN EXIT SUB
    IF glInit = 0 THEN
        _glViewport 0, 0, _WIDTH, _HEIGHT
        aspect# = _WIDTH / _HEIGHT

        glInit = 1
    END IF

    _glEnable _GL_DEPTH_TEST
    _glClear _GL_DEPTH_BUFFER_BIT OR _GL_COLOR_BUFFER_BIT

    'LIGHTS CONFIG
    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    clr(0) = 0.2: clr(1) = 0.2: clr(2) = 0.2: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, _OFFSET(clr())
    clr(0) = 0.8: clr(1) = 0.8: clr(2) = 0.8: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, _OFFSET(clr())
    _glLightfv _GL_LIGHT0, _GL_DIFFUSE, _OFFSET(clr())
    clr(0) = 0: clr(1) = 0: clr(2) = 0: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_POSITION, _OFFSET(clr())

    _glMatrixMode _GL_PROJECTION
    _gluPerspective 60, aspect#, 0.1, 10

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    _glTranslatef 0, 0, -1
    _glRotatef _MOUSEX, 0, 1, 0
    _glRotatef _MOUSEY, 1, 0, 0

    drawFractal
    _glFlush
END SUB

SUB initFractal (x, y, z, s, N) 'x-position, y-position, z-position, size, N-> iteration
    STATIC i
    IF N = 0 THEN
        cubeLoc(i).x = x
        cubeLoc(i).y = y
        cubeLoc(i).z = z
        i = i + 1
        ' ? "Added #",i
        ' sleep
        EXIT SUB
    END IF
    'top section
    'sabse samne wali row, left to right
    initFractal (x - s / 3), (y + s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x), (y + s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z + s / 3), s / 3, N - 1
    'uske peeche wali row, left to right
    initFractal (x - s / 3), (y + s / 3), (z), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z), s / 3, N - 1
    'sabse peeche wali row, left to right
    initFractal (x - s / 3), (y + s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x), (y + s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z - s / 3), s / 3, N - 1
    'middle section
    'sabse samne wali row, left to right
    initFractal (x - s / 3), (y), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y), (z + s / 3), s / 3, N - 1
    'sabse peeche wali row, left to right
    initFractal (x - s / 3), (y), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y), (z - s / 3), s / 3, N - 1
    'bottom section
    'sabse samne wali row, left to right
    initFractal (x - s / 3), (y - s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x), (y - s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z + s / 3), s / 3, N - 1
    'uske peeche wali row, left to right
    initFractal (x - s / 3), (y - s / 3), (z), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z), s / 3, N - 1
    'sabse peeche wali row, left to right
    initFractal (x - s / 3), (y - s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x), (y - s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z - s / 3), s / 3, N - 1

END SUB

SUB drawFractal ()
    FOR i = 0 TO UBOUND(cubeLoc)
        _glPushMatrix
        _glTranslatef cubeLoc(i).x, cubeLoc(i).y, cubeLoc(i).z
        glutSolidCube fundamentalCubeSize
        _glPopMatrix
    NEXT
END SUB


