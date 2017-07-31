'Simple Textured Flag By Ashish
'
'

SCREEN _NEWIMAGE(800, 600, 32)

DIM SHARED glAllow AS _BYTE, wired
wired = 1

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE

'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE

'Used by GLH RGB/etc helper functions
REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE


glAllow = -1
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN wired = wired * -1
    _LIMIT 40
LOOP UNTIL k& = ASC(CHR$(27))


SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB

    _glEnable _GL_DEPTH_TEST

    _glEnable _GL_TEXTURE_2D
   
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
   
    IF NOT glSetup THEN
        aspect# = _WIDTH / _HEIGHT
        glSetup = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT
        ang = 0
        v& = _LOADIMAGE("indian-flag.png")
        flag_texture = GLH_Image_to_Texture(v&)
        _FREEIMAGE v&
    END IF
   
    _gluPerspective 45.0, aspect#, 1.0, 100.0
   
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
   
    gluLookAt 0, 0, 4, 0, 0, -1, 0, 1, 0
   
   
    GLH_Select_Texture flag_texture
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
   
   
    IF wired = 1 THEN
        _glBegin _GL_TRIANGLES
   
        FOR x = -1 TO 1 STEP .02
            z = SIN(clock# + k) * .4
            FOR y = .8 TO -.78 STEP -.02
                tx = map(x, -1, 1, 1, 0)
                ty = map(y, .8, -.8, 0, 1)
                tx2 = map(x + .02, -1, 1, 1, 0)
                ty2 = map(y - .02, -.8, .8, 1, 0)
           
                _glTexCoord2f tx, ty
                _glVertex3f x, y, z
                _glTexCoord2f tx, ty2
                _glVertex3f x, y - .02, z
                _glTexCoord2f tx2, ty
                _glVertex3f x + .02, y, SIN(clock# + k + .1) * .4
           
                _glTexCoord2f tx2, ty
                _glVertex3f x + .02, y, SIN(clock# + k + .1) * .4
                _glTexCoord2f tx2, ty2
                _glVertex3f x + .02, y - .02, SIN(clock# + k + .1) * .4
                _glTexCoord2f tx, ty2
                _glVertex3f x, y - .02, z
            NEXT
            k = k + .1
        NEXT
        k = 0
        _glEnd
    ELSE
        _glBegin _GL_LINE_STRIP
   
        FOR x = -1 TO 1 STEP .03
            z = SIN(clock# + k) * .4
            FOR y = .8 TO -.78 STEP -.03
                _glVertex3f x, y, z
                _glVertex3f x, y - .02, z
                _glVertex3f x + .02, y, SIN(clock# + k + .1) * .4

            NEXT
            k = k + .1
        NEXT
        k = 0
        _glEnd
    END IF
    _glFlush
   
    clock# = clock# + .05
    clock2# = clock2# + .01
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