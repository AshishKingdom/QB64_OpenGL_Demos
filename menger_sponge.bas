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
    SUB glutSolidCube (BYVAL dsize AS DOUBLE) 'use to draw a solid cube by taking the side length as its arguement
END DECLARE

'Algorithm
'1. We take a cube.
'2. We divide it into 27 equal cubical parts.
'3. Out of this 27 cubes, 7 cubes are removed.
'4. In the remaining 20 cubes, Step-1 is repeated for each cube.
iteration = 3 'no. of iteration. At each iteration, 7 cubes are removed from parent cube.
size = 0.5 'the size of our first cube
n = (20 ^ iteration) - 1

DIM SHARED glAllow, cubeLoc(n) AS vec3, fundamentalCubeSize 'cubeLoc array store the location of cubes to be rendered. They are the smallest cube which are formed in the last iteration
fundamentalCubeSize = size / (3 ^ iteration) 'the size the smallest cube which is formed in the last iteration
initFractal 0, 0, 0, size, iteration 'this sub done all calculation for cube location & other stuff.

PRINT (n + 1); " Cubes will rendered with total of "; 8 * (n + 1); " vertices"
PRINT "Hit a Key"
SLEEP
glAllow = 1 'to start rendering in the SUB _GL
DO
    WHILE _MOUSEINPUT: WEND
    _LIMIT 40
LOOP

SUB _GL () STATIC
    DIM clr(3)
    IF glAllow = 0 THEN EXIT SUB 'So that rendering will start as soon as initialization is done.
    IF glInit = 0 THEN
        _glViewport 0, 0, _WIDTH, _HEIGHT 'this defines the area in the screen where GL rendering will occur
        aspect# = _WIDTH / _HEIGHT

        glInit = 1
    END IF

    _glEnable _GL_DEPTH_TEST 'this enable Z-buffer. So that we can do 3D things.
    _glClear _GL_DEPTH_BUFFER_BIT OR _GL_COLOR_BUFFER_BIT 'Not required unless we do softwre rendering as well.

    'LIGHTS CONFIG
    _glEnable _GL_LIGHTING 'this enable us to use light. There are max of 8 lights in GL
    _glEnable _GL_LIGHT0
    clr(0) = 0.2: clr(1) = 0.2: clr(2) = 0.2: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, _OFFSET(clr()) 'this define the color of the material where light can hardly reach.
    clr(0) = 0.8: clr(1) = 0.8: clr(2) = 0.8: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, _OFFSET(clr()) 'this define the color of the material where light is directly reflected & reach your eye.
    _glLightfv _GL_LIGHT0, _GL_DIFFUSE, _OFFSET(clr()) 'this define the default/usual color of the light on the material.
    clr(0) = 0: clr(1) = 0: clr(2) = 0: clr(3) = 1
    _glLightfv _GL_LIGHT0, _GL_POSITION, _OFFSET(clr()) 'use to define the direction of light when 4th component is 0. When 4th component is 1, it defines the position of light. In this case, the light looses its intensity as distance increases.

    _glMatrixMode _GL_PROJECTION 'usually used for setting up perspective etc.
    _gluPerspective 60, aspect#, 0.1, 10 'first arguement tell angle for FOV (Field of View, for human it is round 70degree for one eye.LOL) next one aspect ratio, next 2 are near & far distance. Objects which are not between these distance are clipped. (or are not rendered.)

    _glMatrixMode _GL_MODELVIEW 'rendering takes place here
    _glLoadIdentity

    _glTranslatef 0, 0, -1 'move the origin forward by 1 unit
    _glRotatef _MOUSEX, 0, 1, 0 'these are for rotation by the movement of mouse.
    _glRotatef _MOUSEY, 1, 0, 0

    drawFractal 'draws the fractal
    _glFlush 'force all the GL command to complete in finite amount of time
END SUB

SUB initFractal (x, y, z, s, N) 'x-position, y-position, z-position, size, N-> iteration
    STATIC i
	'As we divide the cube, value of N decreases.
    IF N = 0 THEN 'when the division is done N times (no. of iteration)
        cubeLoc(i).x = x 'store the coordinates of cube
        cubeLoc(i).y = y
        cubeLoc(i).z = z
        i = i + 1
        ' ? "Added #",i
        ' sleep
        EXIT SUB
    END IF
    'top section
    'front row, left to right
    initFractal (x - s / 3), (y + s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x), (y + s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z + s / 3), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y + s / 3), (z), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y + s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x), (y + s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y + s / 3), (z - s / 3), s / 3, N - 1
    'middle section
    'front row, left to right
    initFractal (x - s / 3), (y), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y), (z + s / 3), s / 3, N - 1
    'behind the previous row (last one as middle one contain no cube ;) ), left to right
    initFractal (x - s / 3), (y), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y), (z - s / 3), s / 3, N - 1
    'bottom section
    'front row, left to right
    initFractal (x - s / 3), (y - s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x), (y - s / 3), (z + s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z + s / 3), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y - s / 3), (z), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z), s / 3, N - 1
    'behind the previous row, left to right
    initFractal (x - s / 3), (y - s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x), (y - s / 3), (z - s / 3), s / 3, N - 1
    initFractal (x + s / 3), (y - s / 3), (z - s / 3), s / 3, N - 1 '20

END SUB

SUB drawFractal ()
    FOR i = 0 TO UBOUND(cubeLoc)
        _glPushMatrix 'save the previous transformation configuration
        _glTranslatef cubeLoc(i).x, cubeLoc(i).y, cubeLoc(i).z 'move at given location
        glutSolidCube fundamentalCubeSize 'draws the solid cube of smallest size which is formed in the last iteration
        _glPopMatrix 'restore the original transformation configuration
    NEXT
END SUB


