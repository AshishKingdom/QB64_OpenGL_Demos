'Cube plasma, coded by Ashish  6/12/2018
'Twitter : @KingOfCoders
'http://lodev.org/cgtutor/plasma.html

_TITLE "Cube Plasma"
SCREEN _NEWIMAGE(600, 600, 32)

DECLARE LIBRARY
    'for camera
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE

DIM SHARED glAllow AS _BYTE, textureImage&(258), tmp_buffer_image&
tmp_buffer_image& = _NEWIMAGE(200, 200, 32)

_DEST tmp_buffer_image&
'storing calculation in memory for faster rendering
DIM sin1(_WIDTH - 1, _HEIGHT - 1), sin2(_WIDTH - 1, _HEIGHT - 1), sin3(_WIDTH - 1, _HEIGHT - 1)
FOR y = 0 TO _HEIGHT - 1
    FOR x = 0 TO _WIDTH - 1
        sin1(x, y) = SIN(SQR(x ^ 2 + y ^ 2) * .09)
        sin2(x, y) = SIN(y * .03)
        sin3(x, y) = COS(((_WIDTH / 2 - x) ^ 2 + (_HEIGHT / 2 - y) ^ 2) ^ .5 * .07)
NEXT x, y

DO
    _DEST 0
    CLS
    PRINT "Generating Textures "; f; "/"; UBOUND(textureImage&) - 1
    _DEST tmp_buffer_image&
    f = f + 1
    FOR y = 0 TO _HEIGHT - 1
        FOR x = 0 TO _WIDTH - 1
            col = sin1(x, y) * 64 + 64 + sin2(x, y) * 64 + 64 + sin3(x, y) * 64 + 64 + f
            col = col MOD 256
            PSET (x, y), hsb(col, 255, 128, 255)
    NEXT x, y
    textureImage&(f) = _COPYIMAGE(tmp_buffer_image&)
LOOP UNTIL f > UBOUND(textureImage&) - 1
_DEST 0
_FREEIMAGE tmp_buffer_image&

glAllow = -1
DO
    _LIMIT 30
LOOP

SUB _GL ()
    STATIC cubeTexture&(601), glSetup, aspect#, frame

    IF NOT glAllow THEN EXIT SUB

    IF NOT glSetup THEN
        glSetup = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT
        'Convert all images to GL textures
        FOR i = 1 TO UBOUND(textureImage&) - 1
            _glGenTextures 1, _OFFSET(cubeTexture&(i))
            DIM m AS _MEM
            m = _MEMIMAGE(textureImage&(i))

            _glBindTexture _GL_TEXTURE_2D, cubeTexture&(i)
            _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGB, _WIDTH(textureImage&(i)), _HEIGHT(textureImage&(i)), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET

            _MEMFREE m

            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
            _FREEIMAGE textureImage&(i)
        NEXT
        aspect# = _WIDTH / _HEIGHT
    END IF

    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_DEPTH_TEST

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1, 100

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    gluLookAt 0, 0, 5, 0, 0, 0, 0, 1, 0

    i = (frame MOD (UBOUND(textureImage&) - 1)) + 1
    'select our texture
    _glBindTexture _GL_TEXTURE_2D, cubeTexture&(i)

    'rotation
    _glRotatef frame * .01 * 120, 1, .5, .3

    _glBegin _GL_QUADS
    'front face
    _glTexCoord2f 0, 1
    _glVertex3f -1, 1, 1
    _glTexCoord2f 1, 1
    _glVertex3f 1, 1, 1
    _glTexCoord2f 1, 0
    _glVertex3f 1, -1, 1
    _glTexCoord2f 0, 0
    _glVertex3f -1, -1, 1
    'rear face
    _glTexCoord2f 0, 1
    _glVertex3f -1, 1, -1
    _glTexCoord2f 1, 1
    _glVertex3f 1, 1, -1
    _glTexCoord2f 1, 0
    _glVertex3f 1, -1, -1
    _glTexCoord2f 0, 0
    _glVertex3f -1, -1, -1
    'upward face
    _glTexCoord2f 0, 1
    _glVertex3f -1, 1, -1
    _glTexCoord2f 1, 1
    _glVertex3f 1, 1, -1
    _glTexCoord2f 1, 0
    _glVertex3f 1, 1, 1
    _glTexCoord2f 0, 0
    _glVertex3f -1, 1, 1
    'downward face
    _glTexCoord2f 0, 1
    _glVertex3f -1, -1, -1
    _glTexCoord2f 1, 1
    _glVertex3f 1, -1, -1
    _glTexCoord2f 1, 0
    _glVertex3f 1, -1, 1
    _glTexCoord2f 0, 0
    _glVertex3f -1, -1, 1
    'left face
    _glTexCoord2f 0, 1
    _glVertex3f -1, 1, -1
    _glTexCoord2f 1, 1
    _glVertex3f -1, 1, 1
    _glTexCoord2f 1, 0
    _glVertex3f -1, -1, 1
    _glTexCoord2f 0, 0
    _glVertex3f -1, -1, -1
    'right face
    _glTexCoord2f 0, 1
    _glVertex3f 1, 1, -1
    _glTexCoord2f 1, 1
    _glVertex3f 1, 1, 1
    _glTexCoord2f 1, 0
    _glVertex3f 1, -1, 1
    _glTexCoord2f 0, 0
    _glVertex3f 1, -1, -1

    _glEnd

    frame = frame + 1
END SUB



FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

'method adapted form http://stackoverflow.com/questions/4106363/converting-rgb-to-hsb-colors
FUNCTION hsb~& (__H AS _FLOAT, __S AS _FLOAT, __B AS _FLOAT, A AS _FLOAT)
    DIM H AS _FLOAT, S AS _FLOAT, B AS _FLOAT

    H = map(__H, 0, 255, 0, 360)
    S = map(__S, 0, 255, 0, 1)
    B = map(__B, 0, 255, 0, 1)

    IF S = 0 THEN
        hsb~& = _RGBA32(B * 255, B * 255, B * 255, A)
        EXIT FUNCTION
    END IF

    DIM fmx AS _FLOAT, fmn AS _FLOAT
    DIM fmd AS _FLOAT, iSextant AS INTEGER
    DIM imx AS INTEGER, imd AS INTEGER, imn AS INTEGER

    IF B > .5 THEN
        fmx = B - (B * S) + S
        fmn = B + (B * S) - S
    ELSE
        fmx = B + (B * S)
        fmn = B - (B * S)
    END IF

    iSextant = INT(H / 60)

    IF H >= 300 THEN
        H = H - 360
    END IF

    H = H / 60
    H = H - (2 * INT(((iSextant + 1) MOD 6) / 2))

    IF iSextant MOD 2 = 0 THEN
        fmd = (H * (fmx - fmn)) + fmn
    ELSE
        fmd = fmn - (H * (fmx - fmn))
    END IF

    imx = _ROUND(fmx * 255)
    imd = _ROUND(fmd * 255)
    imn = _ROUND(fmn * 255)

    SELECT CASE INT(iSextant)
        CASE 1
            hsb~& = _RGBA32(imd, imx, imn, A)
        CASE 2
            hsb~& = _RGBA32(imn, imx, imd, A)
        CASE 3
            hsb~& = _RGBA32(imn, imd, imx, A)
        CASE 4
            hsb~& = _RGBA32(imd, imn, imx, A)
        CASE 5
            hsb~& = _RGBA32(imx, imn, imd, A)
        CASE ELSE
            hsb~& = _RGBA32(imx, imd, imn, A)
    END SELECT

END FUNCTION

