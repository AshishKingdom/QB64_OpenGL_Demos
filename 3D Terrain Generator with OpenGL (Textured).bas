'Coded by Ashish

_TITLE "3D Terrain Generator with OpenGL"
SCREEN _NEWIMAGE(_desktopwidth, _desktopheight, 32)

DIM SHARED glAllow AS _BYTE
DIM SHARED cols, rows, scl
DIM SHARED width, height, startOff, tex&

'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE

'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE

tex& = _loadimage("mountain.jpg")


width = _width
height = _height
scl = 75
cols = width / scl
rows = height / scl
DIM SHARED terrain(cols, rows * 2) AS SINGLE
FOR y = 0 TO rows * 2
    xoff = 0
    FOR x = 0 TO cols
        terrain(x, y) = map(noise(xoff, yoff, 0), 0, 1, -.3,.3)
        xoff = xoff + .2
    NEXT
    yoff = yoff + .2
NEXT
DIM SHARED c
glAllow = -1
DO
    'startOff = startOff + 1
    'IF startOff > rows - 1 THEN startOff = 1
    '_LIMIT 25
    _DISPLAY
LOOP

SUB _GL STATIC
    IF NOT glAllow THEN EXIT SUB
    
	_glClearColor 0, 0, 0, 1
    _glViewPort 0,0,_width,_height
	_glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT
	
	_glEnable _GL_TEXTURE_2D
	_glEnable _GL_DEPTH_TEST
	
	_glMatrixMode _GL_MODELVIEW
	_glLoadIdentity
	
	_gluPerspective 20,_width/_height,0,.6
    
	_glRotatef 40, 1, 0, 0
    _glRotatef rotateZ, 0, 0, 1
	
	rotateX = rotateX + .1
	rotateZ = rotateZ + .25
	texture& = GLH_Image_to_Texture(tex&)
	GLH_Select_Texture texture&
	_glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR 'seems these need to be respecified
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR
    
	FOR y = 0 TO rows - 1
        _glBegin _GL_TRIANGLE_STRIP
        FOR x = 0 TO cols - 1
            k## = map(terrain(x, y + startOff), -.2, .2, 0, 1)

			_glTexCoord2f k##, k##-1
            _glVertex3f toGlX(x * scl), toGlY(y * scl), terrain(x, y + startOff)
			
			_glTexCoord2f k##-1,k##
            _glVertex3f toGlX(x * scl), toGlY((y + 1) * scl), terrain(x, y + 1 + startOff)
        NEXT
        _glEnd
    NEXT
    _glFlush
END SUB

FUNCTION toGlX## (x#)
    x# = (_WIDTH / 2) - x#
    toGlX## = map(x#, -(_WIDTH / 2), _WIDTH / 2, 1, -1)
END FUNCTION

FUNCTION toGlY## (y#)
    y# = (_HEIGHT / 2) - y#
    toGlY## = map(y#, -(_HEIGHT / 2), _HEIGHT / 2, -1, 1)
END FUNCTION

FUNCTION map## (value##, minRange##, maxRange##, newMinRange##, newMaxRange##)
    map## = ((value## - minRange##) / (maxRange## - minRange##)) * (newMaxRange## - newMinRange##) + newMinRange##
END FUNCTION

FUNCTION noise! (x AS SINGLE, y AS SINGLE, z AS SINGLE)
    STATIC p5NoiseSetup AS _BYTE
    STATIC perlin() AS SINGLE
    STATIC PERLIN_YWRAPB AS SINGLE, PERLIN_YWRAP AS SINGLE
    STATIC PERLIN_ZWRAPB AS SINGLE, PERLIN_ZWRAP AS SINGLE
    STATIC PERLIN_SIZE AS SINGLE, perlin_octaves AS SINGLE
    STATIC perlin_amp_falloff AS SINGLE

    IF NOT p5NoiseSetup THEN
        p5NoiseSetup = true

        PERLIN_YWRAPB = 4
        PERLIN_YWRAP = INT(1 * (2 ^ PERLIN_YWRAPB))
        PERLIN_ZWRAPB = 8
        PERLIN_ZWRAP = INT(1 * (2 ^ PERLIN_ZWRAPB))
        PERLIN_SIZE = 4095

        perlin_octaves = 4
        perlin_amp_falloff = 0.5

        REDIM perlin(PERLIN_SIZE + 1) AS SINGLE
        DIM i AS SINGLE
        FOR i = 0 TO PERLIN_SIZE + 1
            perlin(i) = RND
        NEXT
    END IF

    x = ABS(x)
    y = ABS(y)
    z = ABS(z)

    DIM xi AS SINGLE, yi AS SINGLE, zi AS SINGLE
    xi = INT(x)
    yi = INT(y)
    zi = INT(z)

    DIM xf AS SINGLE, yf AS SINGLE, zf AS SINGLE
    xf = x - xi
    yf = y - yi
    zf = z - zi

    DIM r AS SINGLE, ampl AS SINGLE, o AS SINGLE
    r = 0
    ampl = .5

    FOR o = 1 TO perlin_octaves
        DIM of AS SINGLE, rxf AS SINGLE
        DIM ryf AS SINGLE, n1 AS SINGLE, n2 AS SINGLE, n3 AS SINGLE
        of = xi + INT(yi * (2 ^ PERLIN_YWRAPB)) + INT(zi * (2 ^ PERLIN_ZWRAPB))

        rxf = 0.5 * (1.0 - COS(xf * _PI))
        ryf = 0.5 * (1.0 - COS(yf * _PI))

        n1 = perlin(of AND PERLIN_SIZE)
        n1 = n1 + rxf * (perlin((of + 1) AND PERLIN_SIZE) - n1)
        n2 = perlin((of + PERLIN_YWRAP) AND PERLIN_SIZE)
        n2 = n2 + rxf * (perlin((of + PERLIN_YWRAP + 1) AND PERLIN_SIZE) - n2)
        n1 = n1 + ryf * (n2 - n1)

        of = of + PERLIN_ZWRAP
        n2 = perlin(of AND PERLIN_SIZE)
        n2 = n2 + rxf * (perlin((of + 1) AND PERLIN_SIZE) - n2)
        n3 = perlin((of + PERLIN_YWRAP) AND PERLIN_SIZE)
        n3 = n3 + rxf * (perlin((of + PERLIN_YWRAP + 1) AND PERLIN_SIZE) - n3)
        n2 = n2 + ryf * (n3 - n2)

        n1 = n1 + (0.5 * (1.0 - COS(zf * _PI))) * (n2 - n1)

        r = r + n1 * ampl
        ampl = ampl * perlin_amp_falloff
        xi = INT(xi * (2 ^ 1))
        xf = xf * 2
        yi = INT(yi * (2 ^ 1))
        yf = yf * 2
        zi = INT(zi * (2 ^ 1))
        zf = zf * 2

        IF xf >= 1.0 THEN xi = xi + 1: xf = xf - 1
        IF yf >= 1.0 THEN yi = yi + 1: yf = yf - 1
        IF zf >= 1.0 THEN zi = zi + 1: zf = zf - 1
    NEXT
    noise! = r
END FUNCTION

SUB GLH_Select_Texture (texture_handle AS LONG) 'turn an image handle into a texture handle
IF texture_handle < 1 OR texture_handle > UBOUND(DONT_USE_GLH_HANDLE) THEN ERROR 258: EXIT FUNCTION
IF DONT_USE_GLH_Handle(texture_handle).in_use = 0 THEN ERROR 258: EXIT FUNCTION
_glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(texture_handle).handle
END SUB

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
