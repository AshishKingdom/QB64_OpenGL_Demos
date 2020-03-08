'Coded by Ashish on 12 March, 2018
'Originally By @BeesandBombs
'https://youtu.be/H81Tdrmz2LA

_TITLE "Cube Wave"

SCREEN _NEWIMAGE(800, 600, 32)

TYPE vec4
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
    w AS SINGLE
END TYPE

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

DECLARE LIBRARY
    'for camera
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE

DIM SHARED glAllow AS _BYTE
DIM SHARED cubeSize
cubeSize = .2

_GLRENDER _BEHIND
glAllow = -1
DO
    _DISPLAY
    _LIMIT 40
LOOP



SUB _GL ()
    STATIC glInit, aspect#, clock#, angOff#

    DIM lightAmb AS vec3, lightDiff AS vec3, lightSpec AS vec3, lightPos AS vec4
    DIM matAmb AS vec3, matDiff AS vec3, matSpec AS vec3, matShin AS SINGLE

    'light color settings
    lightAmb.x = .2: lightDiff.x = .79: lightSpec.x = .99
    lightAmb.y = .2: lightDiff.y = .79: lightSpec.x = .99
    lightAmb.z = .2: lightDiff.z = .79: lightSpec.x = .99
    'light direction settings ,when w=0 it is directional light, when w =1, it is a point light
    lightPos.x = 0
    lightPos.y = 0
    lightPos.z = 1
    lightPos.w = 0
    'material settings
    'try to play with it! but the value of any of these must be between 0 and 1.
    matAmb.x = .4: matDiff.x = .7: matSpec.x = .999
    matAmb.y = .7: matDiff.y = 1: matSpec.y = .999
    matAmb.z = .7: matDiff.z = 1: matSpec.z = .999
    matShin = .6
    '

    IF NOT glAllow THEN EXIT SUB

    _glEnable _GL_DEPTH_TEST

    IF NOT glInit THEN
        glInit = -1
        aspect# = _WIDTH / _HEIGHT
        _glViewport 0, 0, _WIDTH, _HEIGHT
    END IF

    'setuping light
    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    addLight _GL_LIGHT0, lightAmb, lightSpec, lightDiff, lightPos

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    'we will be using orthographic projection
    _glOrtho -5, 5, -5, 5, -5, 5

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    _glTranslatef 0, 0, 0
    _glRotatef 45, 0, 1, 0
    _glRotatef 23, 0, 0, 1

    'give our materials.
    setMaterial matAmb, matSpec, matDiff, matShin

    'draw our cubes
    FOR z = -3 TO 3 STEP cubeSize + cubeSize / 1.5
        FOR x = -3 TO 3 STEP cubeSize + cubeSize / 1.5
            d = dist(0, 0, x, z) 'angle will be shifted according to the distance from the center, i.e., (0,0,0)
            offset = map(d, 0, SQR(18), _PI, -_PI)

            s# = map(SIN(offset + angOff#), -1, 1, 1, 4)

            _glPushMatrix

            _glTranslatef x, 0, z
            drawBox cubeSize, s#, cubeSize

            _glPopMatrix
        NEXT x
    NEXT z

    _glFlush
    angOff# = angOff# + .07
    clock# = clock# + .01
END SUB


SUB addLight (light, ambient AS vec3, specular AS vec3, diffuse AS vec3, __pos AS vec4)
    _glLightfv light, _GL_AMBIENT, glVec3(ambient.x, ambient.y, ambient.z)
    _glLightfv light, _GL_SPECULAR, glVec3(specular.x, specular.y, specular.z)
    _glLightfv light, _GL_DIFFUSE, glVec3(diffuse.x, diffuse.y, diffuse.z)
    _glLightfv light, _GL_POSITION, glVec4(__pos.x, __pos.y, __pos.z, __pos.w)
END SUB

SUB setMaterial (ambient AS vec3, specular AS vec3, diffuse AS vec3, shineness AS SINGLE)
    _glMaterialfv _GL_FRONT, _GL_AMBIENT, glVec3(ambient.x, ambient.y, ambient.z)
    _glMaterialfv _GL_FRONT, _GL_DIFFUSE, glVec3(diffuse.x, diffuse.y, diffuse.z)
    _glMaterialfv _GL_FRONT, _GL_SPECULAR, glVec3(specular.x, specular.y, specular.z)
    _glMaterialfv _GL_FRONT, _GL_SHININESS, glVec3(128 * shineness, 0, 0)
END SUB

'sub to draw a custom box with given width, height and depth.
SUB drawBox (w, h, d)
    _glPushMatrix
    _glBegin _GL_QUADS
    'front
    _glNormal3f 0, 0, 1
    _glVertex3f -w / 2, h / 2, d / 2
    _glVertex3f w / 2, h / 2, d / 2
    _glVertex3f w / 2, -h / 2, d / 2
    _glVertex3f -w / 2, -h / 2, d / 2
    'back
    _glNormal3f 0, 0, -1
    _glVertex3f -w / 2, h / 2, -d / 2
    _glVertex3f w / 2, h / 2, -d / 2
    _glVertex3f w / 2, -h / 2, -d / 2
    _glVertex3f -w / 2, -h / 2, -d / 2
    'right
    _glNormal3f 1, 0, 0
    _glVertex3f w / 2, h / 2, d / 2
    _glVertex3f w / 2, h / 2, -d / 2
    _glVertex3f w / 2, -h / 2, -d / 2
    _glVertex3f w / 2, -h / 2, d / 2
    'left
    _glNormal3f -1, 0, 0
    _glVertex3f -w / 2, h / 2, d / 2
    _glVertex3f -w / 2, h / 2, -d / 2
    _glVertex3f -w / 2, -h / 2, -d / 2
    _glVertex3f -w / 2, -h / 2, d / 2
    'top
    _glNormal3f 0, 1, 0
    _glVertex3f -w / 2, h / 2, d / 2
    _glVertex3f -w / 2, h / 2, -d / 2
    _glVertex3f w / 2, h / 2, -d / 2
    _glVertex3f w / 2, h / 2, d / 2
    'bottom
    _glNormal3f 0, -1, 0
    _glVertex3f -w / 2, -h / 2, d / 2
    _glVertex3f -w / 2, -h / 2, -d / 2
    _glVertex3f w / 2, -h / 2, -d / 2
    _glVertex3f w / 2, -h / 2, d / 2

    _glEnd
    _glPopMatrix
END SUB

'used for passing pointers to the OpenGL.
FUNCTION glVec3%& (x, y, z)
    STATIC internal_vec3(2)
    internal_vec3(0) = x
    internal_vec3(1) = y
    internal_vec3(2) = z
    glVec3%& = _OFFSET(internal_vec3())
END FUNCTION

FUNCTION glVec4%& (x, y, z, w)
    STATIC internal_vec4(3)
    internal_vec4(0) = x
    internal_vec4(1) = y
    internal_vec4(2) = z
    internal_vec4(3) = w
    glVec4%& = _OFFSET(internal_vec4())
END FUNCTION

'taken from p5js.bas
FUNCTION dist! (x1!, y1!, x2!, y2!)
    dist! = SQR((x2! - x1!) ^ 2 + (y2! - y1!) ^ 2)
END FUNCTION


FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

