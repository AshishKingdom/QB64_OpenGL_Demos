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

    'Tetrahedron
    SUB glutWireTetrahedron ()
    SUB glutSolidTetrahedron ()

    'Docecanhedron
    SUB glutWireDodecahedron ()
    SUB glutSolidDeodecahedron ()

    'Octahedron
    SUB glutWireOctahedron ()
    SUB glutSolidOctahedron ()

    'Cone
    SUB glutWireCone (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
    SUB glutSolidCone (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)

    'Cylinder
    SUB glutWireCylinder (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
    SUB glutSolidCylinder (BYVAL base AS DOUBLE, BYVAL height AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)

END DECLARE

DIM SHARED shapeId
DIM SHARED walk 'this will hold value about how close we are to our object
walk = 5
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN
        IF shapeId = 7 THEN shapeId = 0 ELSE shapeId = shapeId + 1
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
    _glDepthMask _GL_TRUE
    
    'clears the depth
    _glClearDepth 1.0
    
    'swich Projection matrix mode
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    
    'setting up perpective
    aspect# = _WIDTH / _HEIGHT
    _glFrustum -aspect#, aspect#, 1.0, -1.0, 1, 20
    
    _glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT
    'Now, we'll use ModelView
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
    
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
            glutWireSphere .5, 30, 30
        CASE 1
            glutWireTorus .2, .5, 30, 30
        CASE 2
            glutWireCube .5
        CASE 3
            glutWireCone .4, .5, 25, 25
        CASE 4
            glutWireCylinder .2, .8, 30, 30
        CASE 5
            glutWireTetrahedron
        CASE 6
            glutWireOctahedron
        CASE 7
            glutWireDodecahedron
    END SELECT

    _glFlush
END SUB

