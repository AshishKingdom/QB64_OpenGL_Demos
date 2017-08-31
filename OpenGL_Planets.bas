'##########################
' 3D Planets in OpenGL
' Coded By Ashish Kushwaha
'#########################
'Controls -
' "w" - move ahead
' "s" - move back
' "a" - move left
' "d" - move right
' "z" - move up
' "x" - move down
' "r" - toggle on/off world rotation
' "e" - toggle on/off OpenGL lights
_TITLE "OpenGL 3D Planets"

SCREEN _NEWIMAGE(700, 700, 32)

DO: LOOP UNTIL _SCREENEXISTS

'c code
DECLARE LIBRARY "./planets_helper"
    SUB initPlanet ()
    SUB drawPlanet ()
END DECLARE


'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE


REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE

dim shared path$
path$ = "Resources/OpenGL 3D Planets/"

DIM SHARED glAllow AS _BYTE, walkZ, walkX, walkY
DIM SHARED rotX, rotY, rotZ
'defining textures
DIM SHARED mercury_texture&, venus_texture&
DIM SHARED earth_texture&, mars_texture&, jupiter_texture&
DIM SHARED saturn_texture&, neptune_texture&, pluto_texture&, uranus_texture&, stars&

walkZ = 30

'textures are from http://planetpixelemporium.com/planets.html

mercury_texture& = _LOADIMAGE(path$+"mercurymap.jpg")
venus_texture& = _LOADIMAGE(path$+"venusmap.jpg")
earth_texture& = _LOADIMAGE(path$+"earthmap1k.jpg")
mars_texture& = _LOADIMAGE(path$+"mars_1k_color.jpg")
jupiter_texture& = _LOADIMAGE(path$+"jupitermap.jpg")
saturn_texture& = _LOADIMAGE(path$+"saturnmap.jpg")
uranus_texture& = _LOADIMAGE(path$+"uranusmap.jpg")
neptune_texture& = _LOADIMAGE(path$+"neptunemap.jpg")
pluto_texture& = _LOADIMAGE(path$+"plutomap1k.jpg")

DIM SHARED allowLight AS _BYTE
allowLight = -1

PRINT "Controls - "
PRINT "Press 'a' to move left"
PRINT "Press 'd' to move right"
PRINT "Press 'z' to move up"
PRINT "Press 'x' to move down"
PRINT "Press 'w' to move ahead"
PRINT "Press 's' to move back"
PRINT "Press 'e' to toggle on/off lights"
PRINT "Press 'r' to rotate X-Axis anti-clockwise"
PRINT "Press 't' to rotate Y-Axis anti-clockwise"
PRINT "Press 'y' to rotate Z-Axis anti-clockwise"
PRINT "Press 'i' to rotate X-Axis clockwise"
PRINT "Press 'o' to rotate Y-Axis clockwise"
PRINT "Press 'p' to rotate Z-Axis clockwise"
PRINT "*********** Hit A Key ***************"
SLEEP
glAllow = -1
stars& = _LOADIMAGE(path$+"outer-space-texture.jpg")
printRenderingStatus


DO
    if _keyhit>0 then
        IF _keydown(asc("s")) THEN walkZ = walkZ + .5
        IF _keydown(ASC("w")) THEN walkZ = walkZ - .5
        IF _keydown(ASC("a")) THEN walkX = walkX + .5
        IF _keydown(ASC("d")) THEN walkX = walkX - .5
        IF _keydown(ASC("z")) THEN walkY = walkY - .5
        IF _keydown(ASC("x")) THEN walkY = walkY + .5
        IF _keydown(ASC("r")) THEN rotX = rotX + .5
        IF _keydown(ASC("t")) THEN rotY = rotY + .5
        IF _keydown(ASC("y")) THEN rotZ = rotZ + .5
        IF _keydown(ASC("u")) THEN rotX = rotX - .5
        IF _keydown(ASC("i")) THEN rotY = rotY - .5
        IF _keydown(ASC("o")) THEN rotZ = rotZ - .5
        IF _keydown(ASC("e")) THEN
            IF allowLight THEN allowLight = 0 ELSE allowLight = -1
        END IF
		printRenderingStatus
    END IF
    _LIMIT 35
LOOP

SUB printRenderingStatus ()
	_putimage , stars&
    COLOR _RGB(255, 255, 255)
	Locate 1,1
    IF allowLight THEN PRINT "Lights are on" ELSE PRINT "Lights are off"
    PRINT "Current X Position : "; walkX
    PRINT "Current Y Position : "; walkY
    PRINT "Current Z Position : "; walkZ
    PRINT "Current X Rotation : "; rotX
    PRINT "Current Y Rotation : "; rotY
    PRINT "Current Z Rotation : "; rotZ
END SUB

SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB

    _glViewport 0, 0, _WIDTH, _HEIGHT

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity

    _glEnable _GL_DEPTH_TEST

    IF allowLight THEN
        'Enable lighting
        _glEnable _GL_LIGHTING
        _glEnable _GL_LIGHT0
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, GLH_RGB(.2, .2, .2)
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, GLH_RGB(1, 1, 1)
		'It doesn't want to move light. Sun is fixed. :p
        '_glLightfv _GL_LIGHT0, _GL_POSITION, GLH_RGBA(COS(clock#), 0, SIN(clock#), 0)
        _glShadeModel _GL_SMOOTH 'how to shade model with light
    END IF

    _gluPerspective 50, _WIDTH / _HEIGHT, 1.0, 500.0

    IF NOT planetHasCreated THEN
        planetHasCreated = -1
        initPlanet
    END IF

    _glClearDepth 1.F

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    _glTranslatef walkX, walkY, -walkZ
    _glEnable _GL_TEXTURE_2D

    IF NOT textureInit THEN
        textureInit = -1
        'should be executed once to prevent memory errors
        'also we don't want to load it again & again
        DIM planets(8) AS LONG
        planets(0) = GLH_Image_to_Texture(mercury_texture&)
        planets(1) = GLH_Image_to_Texture(venus_texture&)
        planets(2) = GLH_Image_to_Texture(earth_texture&)
        planets(3) = GLH_Image_to_Texture(mars_texture&)
        planets(4) = GLH_Image_to_Texture(jupiter_texture&)
        planets(5) = GLH_Image_to_Texture(saturn_texture&)
        planets(6) = GLH_Image_to_Texture(uranus_texture&)
        planets(7) = GLH_Image_to_Texture(neptune_texture&)
        planets(8) = GLH_Image_to_Texture(pluto_texture&)
    END IF
    _glRotatef rotX, 1, 0, 0
    _glRotatef rotY, 0, 1, 0
    _glRotatef rotZ, 0, 0, 1
    FOR i = 0 TO 8
        'Save the current rendering state
        _glPushMatrix
        _glTranslatef map(i, 0, 8, -.4, i * 8), 0, -(map(i, 0, 8, 0, walkZ * 8))
        _glRotatef 90, 1, 0, 0
        _glRotatef clock# * 60, 0, 0, 1
        GLH_Select_Texture planets(i)
        
        _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR
        _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
        drawPlanet
        'load the last saved rendering state
        _glPopMatrix
    NEXT

    'drawPlanet
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

'taken from p5js.bas
FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION
