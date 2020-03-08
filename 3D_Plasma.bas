'3D plasma, coded by Ashish  14 June, 2018
'Twitter : @KingOfCoders
'http://lodev.org/cgtutor/plasma.html

_TITLE "3D Plasma"
SCREEN _NEWIMAGE(600, 600, 32)


DECLARE LIBRARY
    'for camera
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE

DIM SHARED mapSize
mapSize = 200
DIM SHARED glAllow AS _BYTE, textureImage&(258), tmp_buffer_image&
DIM SHARED tmp_height_map&, height_map_buffer AS _MEM 'New height maps

tmp_buffer_image& = _NEWIMAGE(mapSize, mapSize, 32)
tmp_height_map& = _NEWIMAGE(mapSize, mapSize, 32) 'this image will be treated as height map
height_map_buffer = _MEMIMAGE(tmp_height_map&) 'the data in above image will access by this _MEM buffer


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
    f = f + 1
    FOR y = 0 TO _HEIGHT(tmp_buffer_image&) - 1
        FOR x = 0 TO _WIDTH(tmp_buffer_image&) - 1
            col = sin1(x, y) * 64 + sin2(x, y) * 64 + sin3(x, y) * 64 + 255 + f
            col2 = col MOD 255
            _DEST tmp_buffer_image&
            PSET (x, y), hsb(col2, 255, 128, 255)
    NEXT x, y
    textureImage&(f) = _COPYIMAGE(tmp_buffer_image&)
LOOP UNTIL f > UBOUND(textureImage&) - 1
_DEST 0
_FREEIMAGE tmp_buffer_image&


_GLRENDER _ONTOP

_DEST tmp_height_map&
glAllow = -1
DO
    f = f + 1
    FOR y = 0 TO _HEIGHT - 1
        FOR x = 0 TO _WIDTH - 1
            col = sin1(x, y) * 64 + sin2(x, y) * 64 + sin3(x, y) * 64 + 255 + f
            col = SIN(col * .01) * 64 + 128
            PSET (x, y), _RGB(col, col, col)
    NEXT x, y
LOOP

SUB _GL ()
$checking:off
    STATIC cubeTexture&(257), glSetup
    STATIC aspect#, frame


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

    _glClearColor 0, 0, 0, 1
    _glClear _GL_DEPTH_BUFFER_BIT OR _GL_COLOR_BUFFER_BIT

    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_DEPTH_TEST

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1, 100

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    _glShadeModel _GL_SMOOTH

    gluLookAt 0, 0, 4, 0, 0, 0, 0, 1, 0

    i = (frame MOD (UBOUND(textureImage&) - 1)) + 1

    'select our texture
    _glBindTexture _GL_TEXTURE_2D, cubeTexture&(i)

    'rotation
    _glRotatef -45, 1, 0, 0

    drawPlane 2, 2, .05, height_map_buffer

    frame = frame + 1
$checking:on
END SUB

SUB drawPlane (w, h, detail, height_map AS _MEM)

    'texture coordinates
    tx1 = 0: ty1 = 0
    tx2 = 0: ty2 = 0

    depth1 = 0 'used for depth effect by using height maps
    depth2 = 0

    hx1% = 0: hy1% = 0
    hx2% = 0: hy2% = 0
    _glBegin _GL_TRIANGLE_STRIP
    FOR y = -h / 2 TO h / 2 - detail STEP detail
        FOR x = -w / 2 TO w / 2 - detail STEP detail
            tx1 = map(x, -w / 2, w / 2, 0, 1)
            ty1 = map(y, -h / 2, h / 2, 1, 0)
            ty2 = map(y + detail, -h / 2, h / 2, 1, 0)

            hx1% = map(tx1, 0, 1, 1, mapSize - 1)
            hy1% = map(ty1, 0, 1, mapSize - 1, 1)
            hy2% = map(ty2, 0, 1, mapSize - 1, 1)

            depth1 = _MEMGET(height_map, height_map.OFFSET + memImageIndex(hx1%, hy1%, mapSize), _UNSIGNED _BYTE) / 400
            depth2 = _MEMGET(height_map, height_map.OFFSET + memImageIndex(hx1%, hy2%, mapSize), _UNSIGNED _BYTE) / 400

            _glTexCoord2f tx1, ty1
            _glVertex3f x, y, depth1
            _glTexCoord2f tx1, ty2
            _glVertex3f x, y + detail, depth2
        NEXT x
    NEXT y

    _glEnd

END SUB

FUNCTION memImageIndex& (x, y, w)
    memImageIndex& = (x + y * w) * 4
END FUNCTION


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


