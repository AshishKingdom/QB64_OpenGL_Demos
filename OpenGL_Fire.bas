'@Author : Petr Preclik
'castice - L19
' comment "-//-" = the same as previous comment
_TITLE "OpenGL Fire Demo!!"
SCREEN _NEWIMAGE(800, 600, 32)

dim shared path$
path$ = "Resources/Petr's_Fire_Demo/"
DIM SHARED MAX_PARTICLES
MAX_PARTICLES = 10000

'################### GLHB.bi #################
'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE
'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE


REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE
'###################################################

DIM SHARED first, xspeed, yspeed, zoom, slowdown, drawloop, angle
DIM SHARED texture AS LONG
slowdown = 2.0F
zoom = -40.0F

TYPE struct
    active AS _BYTE '   is this partice active?
    life AS SINGLE '  particle life
    fade AS SINGLE '  speed for particles age  starnuti

    r AS SINGLE '  colors: red
    g AS SINGLE '          green
    b AS SINGLE '          blue

    x AS SINGLE ' position on X
    y AS SINGLE ' position on Y
    z AS SINGLE ' position on Z

    xi AS SINGLE ' direction and speed in X
    yi AS SINGLE ' direction and speed in Y
    zi AS SINGLE ' direction and speed in Z

    xg AS SINGLE 'gravity in X axis
    yg AS SINGLE 'gravity in Y axis
    zg AS SINGLE 'gravity in Z axis
END TYPE
DIM SHARED Particle(MAX_PARTICLES) AS struct

TYPE Colors
    r AS SINGLE
    g AS SINGLE
    b AS SINGLE
END TYPE
DIM SHARED Colors(12) AS Colors

FOR LoadColors = 1 TO 12
    READ Colors(LoadColors).r, Colors(LoadColors).g, Colors(LoadColors).b
NEXT LoadColors

DATA 1.0,0.5,0.5,1.0,0.75,0.5,1.0,1.0,0.5,0.75,1.0,0.5
DATA 0.5,1.0,0.5,0.5,1.0,0.75,0.5,1.0,1.0,0.5,0.75,1.0
DATA 0.5,0.5,1.0,0.75,0.5,1.0,1.0,0.5,1.0,1.0,0.5,0.75


DO WHILE _KEYHIT <> 27
    i$ = INKEY$


    SELECT CASE (UCASE$(i$))

        CASE CHR$(32), "5"
            FOR Drawloop2 = 1 TO MAX_PARTICLES
                pp = RND * 5
                IF pp > 5 THEN P = 1 ELSE P = -1

                Particle(Drawloop2).x = 0.0F ' center to screen
                Particle(Drawloop2).y = 0.0F ' center to screen
                Particle(Drawloop2).z = 0.0F ' center to screen
                Particle(Drawloop2).xi = P * RND - 26.0F * 10.0F ' x axis random speed
                Particle(Drawloop2).yi = P * RND - 25.0F * 10.0F ' y axis random speed
                Particle(Drawloop2).zi = P * RND - 25.0F * 10.0F ' z axis random speed
            NEXT
        CASE "+"
            IF slowdown > 1.0F THEN slowdown = slowdown - 0.1 ' particles speed up
        CASE "-"
            IF slowdown < 4.0F THEN slowdown = slowdown + 0.1F ' particles speed down
        CASE "*"
            zoom = zoom + 0.8F 'zoom +
        CASE "/"
            zoom = zoom - 0.8F 'zoom -
        CASE CHR$(13)
            IF sp = 0 THEN col = col + 1: IF col > 12 THEN col = 1

        CASE CHR$(0) + "H"
            IF yspeed < 200 THEN yspeed = yspeed + 1.0F ' arrow up

        CASE CHR$(0) + "P"
            IF yspeed > -200 THEN yspeed = yspeed - 1.0F ' arrow down
        CASE CHR$(0) + "M"
            IF xspeed < 200 THEN xspeed = xspeed + 1.0F ' arrow right
        CASE CHR$(0) + "K"
            IF xspeed > -200 THEN xspeed = xspeed - 1.0F ' arrow left

    END SELECT
LOOP

SUB _GL
IF first = 0 THEN
    image& = _LOADIMAGE(path$+"fire_particle.png", 32)
    IF image& = -1 THEN BEEP: PRINT "Image format wrong": END
    texture& = GLH_Image_to_Texture(image&)
    _FREEIMAGE image&
    first = 1
    FOR partloop = 1 TO MAX_PARTICLES 'inicializing all particles
        Particle(partloop).active = 1
        Particle(partloop).life = 1.0F
        Particle(partloop).fade = RND / 1000.0F + 0.003F ' live speed

        Particle(partloop).r = Colors(INT(partloop * (12 / MAX_PARTICLES))).r ' red
        Particle(partloop).g = Colors(INT(partloop * (12 / MAX_PARTICLES))).g ' gren
        Particle(partloop).b = Colors(INT(partloop * (12 / MAX_PARTICLES))).b ' blue

        polarity = RND * 10: IF polarity <= 5 THEN P = -1 ELSE P = 1 'aternative for C++ rand()%50

        Particle(partloop).xi = P * RND - 26.0F * 10.0F ' speed and direction move on axis x
        Particle(partloop).yi = P * RND - 25.0F * 10.0F '     -//-                         y
        Particle(partloop).zi = P * RND - 25.0F * 10.0F '     -//-                         z

        Particle(partloop).xg = 0.0F ' Gravity on axis x
        Particle(partloop).yg = -0.8F ' Gravity on axis y
        Particle(partloop).zg = 0.0F ' Gravity on axis z
    NEXT partloop
END IF

'DrawGLScene

GLH_Select_Texture texture&


_glMatrixMode _GL_PROJECTION '//                                         Set projection matrix
_gluPerspective 45.0F, _WIDTH / _HEIGHT, 0.1F, 100.0F '                  This is GLUT statement, this is directly supported by QB64. Set up perspective projection matrix.  First is angle for perspective, then is aspct, next is Z Near and Z Far
_glMatrixMode _GL_MODELVIEW '                                            Set Modelview matrix

'---
_glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR '     Filtering at shrinking
_glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR '     Filtering when zooming

_glShadeModel _GL_SMOOTH
_glClearColor 0.0F, 0.0F, 0.0F, 0.0F ' black background
_glClearDepth 1.0F ' depth buffer setting
_glDisable _GL_DEPTH_TEST ' disable depth testing
_glEnable _GL_BLEND ' enable blending
_glBlendFunc _GL_SRC_ALPHA, _GL_ONE ' blendig type set
_glHint _GL_PERSPECTIVE_CORRECTION_HINT, _GL_NICEST ' Perspective
_glHint _GL_POINT_SMOOTH_HINT, _GL_NICEST ' point softness
_glEnable _GL_TEXTURE_2D ' enable texture mapping

_glClear _GL_COLOR_BUFFER_BIT
_glClear _GL_DEPTH_BUFFER_BIT ' clear screen and depth buffer (this and previous line)
'GLH_Select_Texture texture&



'_glLoadIdentity ' Reset matice

FOR drawloop = 0 TO MAX_PARTICLES


    IF Particle(drawloop).active = 1 THEN ' if is particle active

        angle = angle + .01: IF angle > 72 THEN angle = 0
        Particle(drawloop).yg = (SIN(angle) * 10)
        Particle(drawloop).xg = (COS(angle) * 10)


        i$ = INKEY$


        SELECT CASE (UCASE$(i$))

            CASE "W", "8" '8
                IF Particle(drawloop).yg < 1.5F THEN Particle(drawloop).yg = Particle(drawloop).yg + 0.01F
            CASE "S", "2" '2
                IF Particle(drawloop).yg > -1.5F THEN Particle(drawloop).yg = Particle(drawloop).yg - 0.01F
            CASE "A", "4" '4
                IF Particle(drawloop).xg < 1.5F THEN Particle(drawloop).xg = Particle(drawloop).xg + 0.01F
            CASE "D", "6"
                IF Particle(drawloop).xg > -1.5F THEN Particle(drawloop).xg = Particle(drawloop).xg - 0.01F
        END SELECT

        x = Particle(drawloop).x ' x position
        y = Particle(drawloop).y ' y position
        z = Particle(drawloop).z + zoom ' z position + zoom
        _glColor4f Particle(drawloop).r, Particle(drawloop).g, Particle(drawloop).b, Particle(drawloop).life 'coloring

        _glBegin _GL_TRIANGLE_STRIP
        _glTexCoord2d 1, 1: _glVertex3f x + 0.5F, y + 0.5F, z ' top right
        _glTexCoord2d 0, 1: _glVertex3f x - 0.5F, y + 0.5F, z ' top left
        _glTexCoord2d 1, 0: _glVertex3f x + 0.5F, y - 0.5F, z ' bottom right
        _glTexCoord2d 0, 0: _glVertex3f x - 0.5F, y - 0.5F, z ' bottom left
        _glEnd 'Ukoncí triangle strip

        Particle(drawloop).x = Particle(drawloop).x + Particle(drawloop).xi / (slowdown * 1000) ' move on axis X
        Particle(drawloop).y = Particle(drawloop).y + Particle(drawloop).yi / (slowdown * 1000) '  - // -      y
        Particle(drawloop).z = Particle(drawloop).z + Particle(drawloop).zi / (slowdown * 1000) ' - // -       z

        Particle(drawloop).xi = Particle(drawloop).xi + Particle(drawloop).xg ' Gravity on axis               x
        Particle(drawloop).yi = Particle(drawloop).yi + Particle(drawloop).yg '      - // -                   y
        Particle(drawloop).zi = Particle(drawloop).zi + Particle(drawloop).zg '      -//-                     z

        Particle(drawloop).life = Particle(drawloop).life - Particle(drawloop).fade 'speed for particle live

        IF Particle(drawloop).life < 0.0F THEN 'if particle is dead (alpha is full, particle is unseen)
            Particle(drawloop).life = 1.0F 'New life
            Particle(drawloop).fade = RND / 1000.0F + 0.003F

            Particle(drawloop).x = 0.0F ' X screen center
            Particle(drawloop).y = 0.0F ' Y -//-
            Particle(drawloop).z = 0.0F ' Z -//-

            pp = RND * 10: IF pp <= 4 THEN P2 = 1 ELSE P2 = -1

            Particle(drawloop).xi = xspeed + (P2 * RND) - 32.0F ' New speed and direction
            Particle(drawloop).yi = yspeed + (-P2 * RND) - 30.0F ' -//-
            Particle(drawloop).zi = (P2 * RND) - 30.0F ' -//-

            co: col = INT(RND * 6): IF col > 12 OR col < 1 THEN GOTO co

            Particle(drawloop).r = Colors(col).r ' color select from palette
            Particle(drawloop).g = Colors(col).g ' -//-
            Particle(drawloop).b = Colors(col).b ' -//-

        END IF


    END IF
NEXT
end sub



'############### GLH.BI ########################

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
'###############################################