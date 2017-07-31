'##########################
'  OpenGL 3D Shapes
'    By Ashish Kushwaha
'##########################
' :)

_TITLE "OpenGL 3D Shapes"
SCREEN _NEWIMAGE(600, 600, 32)

DECLARE LIBRARY

'Sphere
    SUB glutSolidSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
    SUB glutWireSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)

    'Cube
    SUB glutWireCube (BYVAL dsize AS DOUBLE)
    SUB glutSolidCube (BYVAL dsize AS DOUBLE)

    'Torus
    SUB glutWireTorus (BYVAL dInnerRadius AS DOUBLE, BYVAL dOuterRadius AS DOUBLE, BYVAL nSides AS LONG, BYVAL nRings AS LONG)
    SUB glutSolidTorus (BYVAL dInnerRadius AS DOUBLE, BYVAL dOuterRadius AS DOUBLE, BYVAL nSides AS LONG, BYVAL nRings AS LONG)

    'Cone
    SUB glutWireCone (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
    SUB glutSolidCone (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)

    'Cylinder
    SUB glutWireCylinder (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
    SUB glutSolidCylinder (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)

END DECLARE

'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

DIM SHARED shapeId
DIM SHARED walk 'this will hold value about how close we are to our object
walk = 5
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN
        IF shapeId = 4 THEN shapeId = 0 ELSE shapeId = shapeId + 1
    END IF
    'Hi Sir!
    'try to press 'w' or 's'
    IF k& = ASC("s") THEN walk = walk + .05
    IF k& = ASC("w") THEN walk = walk - .05
    _LIMIT 30
LOOP

SUB _GL STATIC
    _glViewport 0, 0, _WIDTH, _HEIGHT

    'Enable Z-Buffer read/write
    _glEnable _GL_DEPTH_TEST
    
    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, GLH_RGB(.15, .15, .15)
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, GLH_RGB(.8, .8, .8)
    _glLightfv _GL_LIGHT0, _GL_POSITION, GLH_RGBA(COS(clock#), 0, SIN(clock#), 0)
    
    'clears the depth
    _glClearDepth 1.0
    
    'swich Projection matrix mode
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    
    'setting up perpective
    aspect# = _WIDTH / _HEIGHT
    _gluPerspective 40, aspect#, 1, 200
    
    'Now, we'll use ModelView
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
    
    _glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT
    'this clock# variable increases everytime as it is  used for rotation.
    clock# = clock# + .01
    
    'note that  here walk value should be negative.
    'Lesser the walk, object become closes, and vise versa
    _glTranslatef 0, 0, -walk
    
    _glRotatef 30 * clock#, 1, 0, 0
    _glRotatef 60 * clock#, 0, 1, 0
    _glRotatef 90 * clock#, 0, 0, 1

    _glColor3f 1, 1, 1

    SELECT CASE shapeId
        CASE 0
            glutSolidSphere .5, 50, 50
        CASE 1
            glutSolidTorus .2, .5, 50, 50
        CASE 2
            glutSolidCube .5
        CASE 3
            glutSolidCone .4, .5, 30, 30
        CASE 4
            glutSolidCylinder .2, .8, 40, 40
    END SELECT

    _glFlush
END SUB

'used opengl rgba functions
FUNCTION GLH_RGB%& (r AS SINGLE, g AS SINGLE, b AS SINGLE)
    DONT_USE_GLH_COL_RGBA(1) = r
    DONT_USE_GLH_COL_RGBA(2) = g
    DONT_USE_GLH_COL_RGBA(3) = b
    DONT_USE_GLH_COL_RGBA(4) = 1
    GLH_RGB = _OFFSET(DONT_USE_GLH_COL_RGBA())
END FUNCTION

FUNCTION GLH_RGBA%& (r AS SINGLE, g AS SINGLE, b AS SINGLE, a AS SINGLE)
    DONT_USE_GLH_COL_RGBA(1) = r
    DONT_USE_GLH_COL_RGBA(2) = g
    DONT_USE_GLH_COL_RGBA(3) = b
    DONT_USE_GLH_COL_RGBA(4) = a
    GLH_RGBA = _OFFSET(DONT_USE_GLH_COL_RGBA())
END FUNCTION
