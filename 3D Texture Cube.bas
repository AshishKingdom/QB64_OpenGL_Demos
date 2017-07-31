'######################
' 3D Wooden Box
' Coded By Ashish Kushwaha
'######################
'twitter - https://twitter.com/KingOfCoders



_TITLE "3D Wooden Box in OpenGL"
DIM SHARED cube(180) AS _FLOAT
DIM SHARED background&, texture&, mouseX, mouseY, walk
walk = -100
DIM SHARED glAllow AS _BYTE

'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE

'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE


REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE

'Define a 3D cube (6 faces, each made by 2 triangle composed of 3 vertices)
f = freefile
open "cube.dat" for input as #f
line input #1, comment$ 'skip comment
line input #1, comment$ 'skip comment
for i = 1 to ubound(cube)
    input #1, cube(i)
next
close #f


SCREEN _NEWIMAGE(600, 600, 32)



background& = _LOADIMAGE("background.jpg")
texture& = _LOADIMAGE("texture.jpg")

_PUTIMAGE , background&
glAllow = -1
DO
    WHILE _MOUSEINPUT: WEND
    mouseX = _MOUSEX
    mouseY = _MOUSEY
	k& = _keyhit
	if k& = asc("w") then walk = walk + 1.5
	if k& = asc("s") then walk = walk - 1.5
	_limit 30
LOOP


SUB _GL STATIC
    IF NOT glAllow THEN EXIT SUB
	
    clock# = clock# + .01
	
	'enable Z-Buffer read/write test
    _glEnable _GL_DEPTH_TEST
    _glDepthMask _GL_TRUE

    _glClearDepth 1.F
	
	'configure the viewport
    _glViewport 0, 0, _WIDTH, _HEIGHT
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
	
	'setup perspective
    ratio## = _WIDTH / _HEIGHT
    _glFrustum -ratio##, ratio##, -1.F, 1.F, 1.F, 500.F

    _glEnable _GL_TEXTURE_2D
    if textureInit = 0 then tex& = GLH_Image_to_Texture(texture&) : textureInit = -1
    GLH_Select_Texture tex&

    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR 'seems these need to be respecified
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR


    _glClear _GL_DEPTH_BUFFER_BIT

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    x = mouseX * 200.F / _WIDTH - 100.F
    y = -mouseY * 200.F / _HEIGHT + 100.F

    _glTranslatef x, y, walk
	
	walk = walk
	

    _glRotatef clock# * 50, 1, 0, 0
    _glRotatef clock# * 30, 0, 1, 0
    _glRotatef clock# * 90, 0, 0, 1

    _glBegin _GL_TRIANGLES
    FOR i = 1 TO 180 STEP 5
        _glTexCoord2f cube(i + 3), cube(i + 4)
        _glVertex3f cube(i), cube(i + 1), cube(i + 2)
    NEXT
    _glEnd

    _glFlush
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

SUB GLH_Select_Texture (texture_handle AS LONG) 'turn an image handle into a texture handle
    IF texture_handle < 1 OR texture_handle > UBOUND(DONT_USE_GLH_HANDLE) THEN ERROR 258: EXIT FUNCTION
    IF DONT_USE_GLH_Handle(texture_handle).in_use = 0 THEN ERROR 258: EXIT FUNCTION
    _glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(texture_handle).handle
END SUB








