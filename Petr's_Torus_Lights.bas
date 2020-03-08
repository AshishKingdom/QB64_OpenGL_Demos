'MODifined @Author:Petr Preclik
'OpenGL Lights & Material By Ashish

_TITLE "OpenGL Lights & Material"
sele = 1
SCREEN _NEWIMAGE(800, 600, 32)

DIM SHARED glAllow AS _BYTE
DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
    SUB glutSolidSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)

    SUB glutSolidTorus (BYVAL INradius AS LONG, BYVAL OUTradius AS LONG, BYVAL nsides AS LONG, BYVAL rings AS LONG)
    SUB glutWireTorus (BYVAL INradius AS LONG, BYVAL OUTradius AS LONG, BYVAL nsides AS LONG, BYVAL rings AS LONG)
END DECLARE

'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE


'Used by GLH RGB/etc helper functions
REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE

DIM SHARED redLight AS vec3
DIM SHARED greenLight AS vec3
DIM SHARED blueLight AS vec3



glAllow = -1
DO
    _LIMIT 40
	k& = _KEYHIT
IF k& = asc(" ") THEN sele = sele * -1
LOOP UNTIL k& = ASC(CHR$(27))

SUB _GL () STATIC
SHARED sele
IF NOT glAllow THEN EXIT SUB

_glEnable _GL_DEPTH_TEST
_glEnable _GL_LIGHTING

_glEnable _GL_LIGHT0 'we need three lights, each for red, green & blue.
_glEnable _GL_LIGHT1
_glEnable _GL_LIGHT2

_glLightfv _GL_LIGHT0, _GL_AMBIENT, GLH_RGB(0, 0, 0)
_glLightfv _GL_LIGHT0, _GL_DIFFUSE, GLH_RGB(.5, 0, 0)
_glLightfv _GL_LIGHT0, _GL_SPECULAR, GLH_RGB(1, 0, 0)
_glLightfv _GL_LIGHT0, _GL_POSITION, GLH_RGBA(redLight.x, redLight.y, redLight.z, 0)

_glLightfv _GL_LIGHT1, _GL_AMBIENT, GLH_RGB(0, 0, 0)
_glLightfv _GL_LIGHT1, _GL_DIFFUSE, GLH_RGB(0, .5, 0)
_glLightfv _GL_LIGHT1, _GL_SPECULAR, GLH_RGB(0, 1, 0)
_glLightfv _GL_LIGHT1, _GL_POSITION, GLH_RGBA(greenLight.x, greenLight.y, greenLight.z, 0)

_glLightfv _GL_LIGHT2, _GL_AMBIENT, GLH_RGB(0, 0, 0)
_glLightfv _GL_LIGHT2, _GL_DIFFUSE, GLH_RGB(0, 0, .5)
_glLightfv _GL_LIGHT2, _GL_SPECULAR, GLH_RGB(0, 0, 1)
_glLightfv _GL_LIGHT2, _GL_POSITION, GLH_RGBA(blueLight.x, blueLight.y, blueLight.z, 0)

_glMatrixMode _GL_PROJECTION
_glLoadIdentity

IF NOT glSetup THEN
    aspect# = _WIDTH / _HEIGHT
    glSetup = -1
    _glViewport 0, 0, _WIDTH, _HEIGHT
END IF

_gluPerspective 45.0, aspect#, 1.0, 100.0

_glMatrixMode _GL_MODELVIEW
_glLoadIdentity

gluLookAt 0, 0, 20, 0, 0, 0, 0, 1, 0

_glColor3f 0, 0, 0

_glMaterialfv _GL_FRONT_AND_BACK, _GL_AMBIENT, GLH_RGB(0, 0, 0)
_glMaterialfv _GL_FRONT_AND_BACK, _GL_DIFFUSE, GLH_RGB(0.8, 0.8, 0.8)
_glMaterialfv _GL_FRONT_AND_BACK, _GL_SPECULAR, GLH_RGB(.86, .86, .86)
_glMaterialfv _GL_FRONT_AND_BACK, _GL_SHININESS, GLH_RGB(128 * .566, 0, 0)

'glutSolidSphere 1, 100, 100 'prumer, pocet vrcholu v ose X, pocet vrcholu v ose Y
IF sele = 1 THEN
    glutWireTorus 2, 4, 100, 100
ELSE
    glutSolidTorus 2, 4, 100, 100
END IF


_glDisable _GL_LIGHTING

_glPushMatrix
_glTranslatef redLight.x, redLight.y, redLight.z
_glColor3f 1, 0, 0

glutSolidSphere .15, 20, 20

_glPopMatrix

_glPushMatrix
_glTranslatef greenLight.x, greenLight.y, greenLight.z
_glColor3f 0, 1, 0
glutSolidSphere .15, 20, 20
_glPopMatrix

_glPushMatrix
_glTranslatef blueLight.x, blueLight.y, .1
_glColor3f 0, 0, 1
glutSolidSphere .15, 20, 20
_glPopMatrix

_glFlush

clock# = clock# + .01

redLight.x = SIN(clock# * 1.5) * 1.5
redLight.z = COS(clock# * 1.5) * 1.5

greenLight.y = COS(clock# * .8) * 1.5
greenLight.z = SIN(clock# * .8) * 1.5

blueLight.x = SIN(clock#) * 1.5
blueLight.y = COS(clock#) * 1.5
END SUB


FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION


'below, all functions are coded by Galleon
FUNCTION GLH_Image_to_Texture (image_handle AS LONG) 'turn an image handle into a texture handle
IF image_handle >= 0 THEN ERROR 258: EXIT FUNCTION 'don't allow screen pages
DIM m AS _MEM
m = _MEMIMAGE(image_handle)
DIM h AS LONG
h = DONT_USE_GLH_New_Texture_Handle
GLH_Image_to_Texture = h
_glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(h).handle
_glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _WIDTH(image_handle), _HEIGHT(image_handle), 0, &H80E1&&, _GL_UNSIGNED_BYTE, m.OFFSET
_MEMFREE m
END FUNCTION

FUNCTION DONT_USE_GLH_New_Texture_Handle
handle&& = 0
_glGenTextures 1, _OFFSET(handle&&)
DONT_USE_GLH_New_Texture_Handle = handle&&
FOR h = 1 TO UBOUND(DONT_USE_GLH_Handle)
    IF DONT_USE_GLH_Handle(h).in_use = 0 THEN
        DONT_USE_GLH_Handle(h).in_use = 1
        DONT_USE_GLH_Handle(h).handle = handle&&
        DONT_USE_GLH_New_Texture_Handle = h
        EXIT FUNCTION
    END IF
NEXT
REDIM _PRESERVE DONT_USE_GLH_Handle(UBOUND(DONT_USE_GLH_HANDLE) * 2) AS DONT_USE_GLH_Handle_TYPE
DONT_USE_GLH_Handle(h).in_use = 1
DONT_USE_GLH_Handle(h).handle = handle&&
DONT_USE_GLH_New_Texture_Handle = h
END FUNCTION

SUB GLH_Select_Texture (texture_handle AS LONG) 'turn an image handle into a texture handle
IF texture_handle < 1 OR texture_handle > UBOUND(DONT_USE_GLH_HANDLE) THEN ERROR 258: EXIT FUNCTION
IF DONT_USE_GLH_Handle(texture_handle).in_use = 0 THEN ERROR 258: EXIT FUNCTION
_glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(texture_handle).handle
END SUB


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