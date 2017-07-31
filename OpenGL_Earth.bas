'##########################
' 3D Earth in OpenGL
' Coded By Ashish Kushwaha
'#########################


_TITLE "3D Earth in OpenGL"
SCREEN _NEWIMAGE(600, 600, 32)

DO: LOOP UNTIL _SCREENEXISTS

'c code
DECLARE LIBRARY "QB64_OpenGL_Demos/earth_helper"
    SUB initEarth ()
    SUB drawEarth ()
END DECLARE


'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE


'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE

DIM SHARED glAllow AS _BYTE, walk

dim shared path$
path$ = "Resources/OpenGL 3D Earth/"

'defining textures
DIM SHARED earth_texture&

walk = 19

'textures are from http://planetpixelemporium.com/planets.html
earth_texture& = _LOADIMAGE(path$+"earthmap1k.jpg")

glAllow = -1


DO
    k& = _KEYHIT
    IF k& > 0 THEN
        IF k& = ASC("s") THEN walk = walk + .5
        IF k& = ASC("w") THEN walk = walk - .5
    END IF

    _LIMIT 35
LOOP

SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB

    _glViewport 0, 0, _WIDTH, _HEIGHT

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity

    _glEnable _GL_DEPTH_TEST
	'if you really want to know how OpenGL lights work then
	'go to here - https://learnopengl.com/#!Lighting/Basic-Lighting
    'Enable lighting
    'try to comment these 6 lines below me to see differece
    'without lights
    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
	_glLightfv _GL_LIGHT0, _GL_SPECULAR, GLH_RGB(1, 1, 0)
	_glLightfv _GL_LIGHT0, _GL_AMBIENT, GLH_RGB(.3,.3,.3)
	_glLightfv _GL_LIGHT0, _GL_POSITION, GLH_RGBA(cos(clock#),0,sin(clock#),0)
	_glShadeModel _GL_SMOOTH 'how to shade model with light

    _gluPerspective 45, _WIDTH / _HEIGHT, 1.0, 200.0

    IF NOT earthHasCreated THEN
        earthHasCreated = -1
        initEarth
    END IF

    _glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    _glTranslatef 0.0, 1.0, -walk
    _glEnable _GL_TEXTURE_2D

    IF NOT textureInit THEN
        textureInit = -1
        'should be executed once to prevent memory errors
        'also we don't want to load it again & again
        earth& = GLH_Image_to_Texture(earth_texture&)
		
		_freeimage earth_texture&
    END IF

    GLH_Select_Texture earth&

    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_NEAREST

    _glRotatef 100, 1, 0, 0
    _glRotatef clock# * 60, 0, 0, 1
    zr = zr + .5

    drawEarth
    _glFlush

    clock# = clock# + .01
END SUB





'used for texture
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