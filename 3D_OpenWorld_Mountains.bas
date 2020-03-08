'3D OpenWorld Terrain Demo
'Using Perlin Noise
'By Ashish Kushwaha

RANDOMIZE TIMER

'$CONSOLE

_TITLE "3D OpenWorld Terrain"
SCREEN _NEWIMAGE(800, 600, 32)



CONST sqrt2 = 2 ^ 0.5
CONST mountHeightMax = 4

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE vec2
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE tree
    h AS SINGLE
    pos AS vec3
    mpos AS vec2
END TYPE

TYPE camera
    pos AS vec3
    mpos AS vec3
    target AS vec3
END TYPE

TYPE blowMIND
    pos AS vec3
    set AS _BYTE
END TYPE

DECLARE LIBRARY 'camera control function
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE


'noise function related variables
DIM SHARED perlin_octaves AS SINGLE, perlin_amp_falloff AS SINGLE

DIM SHARED mapW, mapH
mapW = 800: mapH = 800 'control the size of the map or world

'Terrain Map related variables
'terrainData(mapW,mapH) contain elevation data and moistureMap(mapW,mapH) contain moisture data
DIM SHARED terrainMap(mapW, mapH), moistureMap(mapW, mapH), terrainData(mapW, mapH) AS vec3
'these stored the 3 Dimensional coordinates of the objects. Used as a array buffer with glDrawArrays(). glDrawArrays() is faster than normal glBegin() ... glEnd() for rendering
DIM SHARED mountVert(mapW * mapH * 6) AS SINGLE, mountColor(mapW * mapH * 6), mountNormal(mapW * mapH * 6)

'MODs
DIM SHARED worldMOD

'map
DIM SHARED worldMap&, myLocation& 'stored the 2D Map
worldMap& = _NEWIMAGE(mapW + 300, mapH + 300, 32)
myLocation& = _NEWIMAGE(10, 10, 32)

'surprise
DIM SHARED Surprise AS blowMIND, snowMount

'sky
DIM SHARED worldTextures&(3), worldTextureHandle&(2)

tmp& = _LOADIMAGE(WriteqbiconData$("qb.png"))
KILL "qb.png"
worldTextures&(1) = _NEWIMAGE(32, 32, 32) '3 32's
_PUTIMAGE (0, 32)-(32, 0), tmp&, worldTextures&(1)

_DEST worldMap&
CLS , _RGB(0, 0, 255)

'day sky containing some clouds
worldTextures&(2) = _NEWIMAGE(400, 400, 32)

_DEST worldTextures&(2)
CLS , _RGB(109, 164, 255)
FOR y = 0 TO _HEIGHT - 1
    FOR x = 0 TO _WIDTH - 1
        j1# = map(ABS((_WIDTH / 2) - x), _WIDTH / 2, 70, 0, 1)
        j2# = map(ABS((_HEIGHT / 2) - y), _HEIGHT / 2, 70, 0, 1)
        noiseDetail 5, 0.46789
        k! = (ABS(noise(x * 0.04, y * 0.04, x / y * 0.01)) * 1.3) ^ 3 * j1# * j2#
        PSET (x, y), _RGBA(255, 255, 255, k! * 255)
NEXT x, y
'starry night sky texture
worldTextures&(3) = _NEWIMAGE(_WIDTH * 3, _HEIGHT * 3, 32)
_DEST worldTextures&(3)
CLS , _RGB(7, 0, 102)
FOR i = 0 TO 300
    cx = p5random(10, _WIDTH - 10): cy = p5random(10, _HEIGHT - 10)
    CircleFill cx, cy, p5random(0, 2), _RGBA(255, 255, 255, p5random(0, 255))
NEXT
_DEST 0
DIM SHARED Cam AS camera, theta, phi


DIM SHARED glAllow AS _BYTE
RESTORE blipicon
_DEST myLocation& 'Generating the blip icon
FOR i = 0 TO 10
    FOR j = 0 TO 10
        READ cx
        IF cx = 1 THEN PSET (j, i), _RGB(255, 0, 200)
NEXT j, i
_DEST 0
'image data of blip icon
blipicon:
DATA 0,0,0,0,0,1,0,0,0,0,0
DATA 0,0,0,0,0,1,0,0,0,0,0
DATA 0,0,0,0,1,1,1,0,0,0,0
DATA 0,0,0,1,1,1,1,1,0,0,0
DATA 0,0,0,1,1,1,1,1,0,0,0
DATA 0,0,1,1,1,1,1,1,1,0,0
DATA 0,1,1,1,1,1,1,1,1,1,0
DATA 0,1,1,1,1,1,1,1,1,1,0
DATA 1,1,1,1,0,0,0,1,1,1,1
DATA 1,1,0,0,0,0,0,0,0,1,1
DATA 1,0,0,0,0,0,0,0,0,0,1
DATA 0,0,0,0,0,0,0,0,0,0,0


'Map elevations and mositure calculation done here with the help of perlin noise
freq = 1
FOR y = 0 TO mapH
    FOR x = 0 TO mapW
        nx = x * 0.01
        ny = y * 0.01
        noiseDetail 2, 0.4
        v! = ABS(noise(nx * freq, ny * freq, 0)) * 1.5 + ABS(noise(nx * freq * 4, ny * freq * 4, 0)) * .25
        v! = v! ^ (3.9)
        elev = v! * 255
        noiseDetail 2, 0.4
        m! = ABS(noise(nx * 2, ny * 2, 0))
        m! = m! ^ 1.4

        ' PSET (x + mapW, y), _RGB(0, 0, m! * 255)
        moistureMap(x, y) = m!

        ' PSET (x, y), _RGB(elev, elev, elev)
        terrainMap(x, y) = (elev / 255) * mountHeightMax
        terrainData(x, y).x = map(x, 0, mapW, -mapW * 0.04, mapW * 0.04)
        terrainData(x, y).y = terrainMap(x, y)
        terrainData(x, y).z = map(y, 0, mapH, -mapH * 0.04, mapH * 0.04)

        setMountColor x, y, 0, (elev / 255) * mountHeightMax, mountHeightMax
        clr~& = _RGB(mountColor(0) * 255, mountColor(1) * 255, mountColor(2) * 255)
        PSET (x, y), clr~&
        _DEST worldMap&
        PSET (x + 150, y + 150), clr~&
        _DEST 0

        IF terrainMap(x, y) <= 0.3 * mountHeightMax AND RND > 0.99993 AND Surprise.set = 0 THEN
            Surprise.pos = terrainData(x, y)
            ' line(x-2,y-2)-step(4,4),_rgb(255,0,0),bf
            Surprise.set = 1
            sx = x: sy = y
        END IF

    NEXT x

    'CLS
    'PRINT "Generating World..."
    'need to show a catchy progress bar
    FOR j = 0 TO map(y, 0, mapH - 1, 0, _WIDTH - 1): LINE (j, _HEIGHT - 6)-(j, _HEIGHT - 1), hsb~&(map(j, 0, _WIDTH - 1, 0, 255), 255, 128, 255): NEXT j
    _DISPLAY
NEXT y
' _TITLE "3D OpenWorld Mountails [Hit SPACE to switch between MODs]"
_DEST worldMap&
LINE (sx - 3 + 150, sy - 3 + 150)-STEP(6, 6), _RGB(255, 0, 0), BF
_DEST 0
generateTerrainData
PRINT "Hit Enter To Step In The World."
PRINT "Map size : "; (mapH * mapW * 24) / 1024; " kB"
_DISPLAY
SLEEP
_MOUSEHIDE
CLS
_GLRENDER _BEHIND

glAllow = -1
DO
    WHILE _MOUSEINPUT: WEND
    theta = (_MOUSEX / _WIDTH) * _PI(2.5) 'controls x-axis rotation
    phi = map(_MOUSEY, 0, _HEIGHT, -_PI(0), _PI(0.5)) 'controls y-axis rotation

    IF Cam.mpos.z > mapH - 2 THEN Cam.mpos.z = mapH - 2 'prevent reaching out of the world map
    IF Cam.mpos.x > mapW - 2 THEN Cam.mpos.x = mapW - 2 '
    IF Cam.mpos.z < 2 THEN Cam.mpos.z = 2 '
    IF Cam.mpos.x < 2 THEN Cam.mpos.x = 2 '

    IF _KEYDOWN(ASC("w")) OR _KEYDOWN(ASC("W")) THEN 'forward movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z + SIN(theta) * 0.45: Cam.mpos.x = Cam.mpos.x + COS(theta) * 0.45
    END IF
    IF _KEYDOWN(ASC("s")) OR _KEYDOWN(ASC("S")) THEN ' backward movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z - SIN(theta) * 0.45: Cam.mpos.x = Cam.mpos.x - COS(theta) * 0.45
    END IF
    IF _KEYDOWN(ASC("a")) OR _KEYDOWN(ASC("A")) THEN 'left movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z + SIN(theta - _PI(0.5)) * 0.45: Cam.mpos.x = Cam.mpos.x + COS(theta - _PI(0.5)) * 0.45
    END IF
    IF _KEYDOWN(ASC("d")) OR _KEYDOWN(ASC("D")) THEN 'right movement based on y-axis rotation
        Cam.mpos.z = Cam.mpos.z + SIN(theta + _PI(0.5)) * 0.45: Cam.mpos.x = Cam.mpos.x + COS(theta + _PI(0.5)) * 0.45
    END IF

    IF _KEYHIT = ASC(" ") THEN 'switching between MODs
        IF worldMOD = 2 OR worldMOD = 3 THEN worldMOD = 0 ELSE worldMOD = worldMOD + 1
    END IF

    CLS , 1 'clear the screen and make it transparent so that GL context not get hidden.
    _LIMIT 60

    'rotation of world causes rotation of map too. calculation of the source points of map is done below
    sx1 = COS(_PI(.75) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy1 = SIN(_PI(.75) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    sx2 = COS(_PI(1.25) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy2 = SIN(_PI(1.25) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    sx3 = COS(_PI(1.75) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy3 = SIN(_PI(1.75) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    sx4 = COS(_PI(2.25) + theta) * 150 * sqrt2 + Cam.mpos.x + 150: sy4 = SIN(_PI(2.25) + theta) * 150 * sqrt2 + Cam.mpos.z + 150
    'displaying the minimap
    _MAPTRIANGLE (sx3, sy3)-(sx4, sy4)-(sx2, sy2), worldMap& TO(0, _HEIGHT - 150 * sqrt2)-(150 * sqrt2, _HEIGHT - 150 * sqrt2)-(0, _HEIGHT - 1)
    _MAPTRIANGLE (sx2, sy2)-(sx4, sy4)-(sx1, sy1), worldMap& TO(0, _HEIGHT - 1)-(150 * sqrt2, _HEIGHT - 150 * sqrt2)-(150 * sqrt2, _HEIGHT - 1)
    'showing your location
    _PUTIMAGE (75 * sqrt2, _HEIGHT - 75 * sqrt2)-STEP(10, 10), myLocation&
    'drawing red border along the map make it attractive
    LINE (1, _HEIGHT - 150 * sqrt2)-STEP(150 * sqrt2, 150 * sqrt2), _RGB(255, 0, 0), B
    _DISPLAY
    
    IF snowMount = 1 THEN
        FOR i = 1 TO UBOUND(mountVert) STEP 3
            setMountColor 0, 0, i - 1, mountVert(i), mountHeightMax
        NEXT
        snowMount = 2
    END IF

LOOP

SUB _GL () STATIC

    IF glAllow = 0 THEN EXIT SUB 'we are not ready yet

    IF NOT glSetup THEN
        glSetup = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT 'define our rendering area

        aspect# = _WIDTH / _HEIGHT 'used to create perspective view

        rad = 1 'distance of camera from origin (0,0,0)
        farPoint = 1.0 'far point of camera target

        'initialize camera
        Cam.mpos.x = mapW / 2
        Cam.mpos.z = mapH / 2
        Cam.mpos.y = 8
        'initialize textures for sky
        FOR i = 1 TO UBOUND(worldTextures&)
            _glGenTextures 1, _OFFSET(worldTextureHandle&(i - 1))

            DIM m AS _MEM
            m = _MEMIMAGE(worldTextures&(i))

            _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(i - 1)
            _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGB, _WIDTH(worldTextures&(i)), _HEIGHT(worldTextures&(i)), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET

            _MEMFREE m

            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
            _FREEIMAGE worldTextures&(i)
        NEXT
    END IF

    IF worldMOD = 0 THEN _glClearColor 0.7, 0.8, 1.0, 1.0 'this makes the background look sky blue.
    IF worldMOD = 1 THEN _glClearColor 0.031, 0.0, 0.307, 1.0 'night sky
    IF worldMOD = 2 THEN _glClearColor 0.0, 0.0, 0.0, 1.0
    IF worldMOD = 3 THEN
        v~& = hsb~&(clock# MOD 255, 255, 128, 255)
        kR = _RED(v~&) / 255: kG = _GREEN(v~&) / 255: kB = _BLUE(v~&) / 255
        _glClearColor kR, kG, kB, 1
    END IF
    '_glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT

    _glEnable _GL_DEPTH_TEST 'Of course, we are going to do 3D
    _glDepthMask _GL_TRUE


    _glEnable _GL_TEXTURE_2D 'so that we can use texture for our sky. :)

    IF worldMOD <> 2 THEN
        _glEnable _GL_LIGHTING 'Without light, everything dull.
        _glEnable _GL_LIGHT0
    END IF

    IF worldMOD = 1 THEN
        'night MOD
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(0.05, 0.05, 0.33, 0)
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec4(0.55, 0.55, 0.78, 0)
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(0.75, 0.75, 0.98, 0)
    ELSEIF worldMOD = 0 THEN
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(0.35, 0.35, 0.33, 0) 'gives a bit yellowing color to the light
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec4(0.75, 0.75, 0.60, 0) 'so it will feel like sun is in the sky
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(0.95, 0.95, 0.80, 0)
    ELSEIF worldMOD = 3 THEN 'disco light
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(kR / 2, kG / 2, kB / 2, 0)
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec4(kR * 0.9, kG * 0.9, kB * 0.9, 0)
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(kR, kG, kB, 0)
    END IF
    _glShadeModel _GL_SMOOTH 'to make the rendering smooth

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 70, aspect#, 0.01, 15.0 'set up out perpective

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    ' IF Cam.mpos.y > (terrainMap(Cam.mpos.x, Cam.mpos.z)) THEN Cam.mpos.y = Cam.mpos.y - 0.03 ELSE
    Cam.mpos.y = meanAreaHeight(1, Cam.mpos.x, Cam.mpos.z) 'if you are in air then you must fall.

    'calculation of camera eye, its target, etc...
    Cam.pos.x = map(Cam.mpos.x, 0, mapW, -mapW * 0.04, mapW * 0.04)
    Cam.pos.z = map(Cam.mpos.z, 0, mapH, -mapH * 0.04, mapH * 0.04)
    Cam.pos.y = Cam.mpos.y + 0.3

    Cam.target.y = Cam.pos.y * COS(phi)
    Cam.target.x = Cam.pos.x + COS(theta) * farPoint
    Cam.target.z = Cam.pos.z + SIN(theta) * farPoint

    gluLookAt Cam.pos.x, Cam.pos.y, Cam.pos.z, Cam.target.x, Cam.target.y, Cam.target.z, 0, 1, 0



    ' draw the world
    _glEnable _GL_COLOR_MATERIAL
    _glColorMaterial _GL_FRONT, _GL_AMBIENT_AND_DIFFUSE

    _glEnableClientState _GL_VERTEX_ARRAY
    _glVertexPointer 3, _GL_FLOAT, 0, _OFFSET(mountVert())
    _glEnableClientState _GL_COLOR_ARRAY
    _glColorPointer 3, _GL_FLOAT, 0, _OFFSET(mountColor())
    _glEnableClientState _GL_NORMAL_ARRAY
    _glNormalPointer _GL_FLOAT, 0, _OFFSET(mountNormal())

    IF worldMOD = 2 THEN _glDrawArrays _GL_LINE_STRIP, 1, (UBOUND(mountvert) / 3) - 1 ELSE _glDrawArrays _GL_TRIANGLE_STRIP, 1, (UBOUND(mountVert) / 3) - 1
    _glDisableClientState _GL_VERTEX_ARRAY
    _glDisableClientState _GL_COLOR_ARRAY
    _glDisableClientState _GL_NORMAL_ARRAY
    _glDisable _GL_COLOR_MATERIAL


    _glDisable _GL_LIGHTING
    IF worldMOD <> 3 AND snowMount <> 2 THEN showSurprise 0.4, Cam.pos

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 70, aspect#, 0.01, 100

    _glMatrixMode _GL_MODELVIEW

    skybox 32.0 'sky

    _glFlush

    clock# = clock# + .5
END SUB

FUNCTION meanAreaHeight# (n%, x%, y%)
    $CHECKING:OFF
    FOR i = y% - n% TO y% + n%
        FOR j = x% - n% TO x% + n%
            h# = h# + terrainMap(j, i)
            g% = g% + 1
    NEXT j, i
    meanAreaHeight# = (h# / g%)
    $CHECKING:ON
END FUNCTION

SUB showSurprise (s, a AS vec3)
    IF a.x > Surprise.pos.x - s AND a.x < Surprise.pos.x + s AND a.z > Surprise.pos.z - s AND a.z < Surprise.pos.z + s THEN
        IF RND > 0.5 THEN
            worldMOD = 3
            _TITLE "You finally came to know that its QB64 Island!!"
        ELSE
            snowMount = 1
            _TITLE "Welcome to this new world..."
            Cam.mpos.y = 6
        END IF
    END IF

    _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(0)

    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y + 2 * s, Surprise.pos.z - s 'front
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y, Surprise.pos.z - s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y, Surprise.pos.z - s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y + 2 * s, Surprise.pos.z - s
    _glEnd

    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y + 2 * s, Surprise.pos.z + s 'rear
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y, Surprise.pos.z + s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y, Surprise.pos.z + s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y + 2 * s, Surprise.pos.z + s
    _glEnd

    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y + 2 * s, Surprise.pos.z + s 'left
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y, Surprise.pos.z + s
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y, Surprise.pos.z - s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y + 2 * s, Surprise.pos.z - s
    _glEnd

    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y + 2 * s, Surprise.pos.z + s 'right
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y, Surprise.pos.z + s
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y, Surprise.pos.z - s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y + 2 * s, Surprise.pos.z - s
    _glEnd

    _glBegin _GL_QUADS 'up
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y + 2 * s, Surprise.pos.z - s 'up
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y + 2 * s, Surprise.pos.z + s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y + 2 * s, Surprise.pos.z + s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y + 2 * s, Surprise.pos.z - s
    _glEnd

    _glBegin _GL_QUADS 'down
    _glTexCoord2f 0, 1
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y, Surprise.pos.z - s 'up
    _glTexCoord2f 0, 0
    _glVertex3f Surprise.pos.x - s, Surprise.pos.y, Surprise.pos.z + s
    _glTexCoord2f 1, 0
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y, Surprise.pos.z + s
    _glTexCoord2f 1, 1
    _glVertex3f Surprise.pos.x + s, Surprise.pos.y, Surprise.pos.z - s
    _glEnd

END SUB

'draws a beautiful sky
SUB skybox (s)
    IF worldMOD > 1 THEN EXIT SUB

    _glDepthMask _GL_FALSE

    IF worldMOD = 0 THEN _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(1) ELSE _glBindTexture _GL_TEXTURE_2D, worldTextureHandle&(2)

    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f -s, s, -s 'front
    _glTexCoord2f 0, 0
    _glVertex3f -s, -s, -s
    _glTexCoord2f 1, 0
    _glVertex3f s, -s, -s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, -s
    _glEnd

    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(0)
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f -s, s, s 'rear
    _glTexCoord2f 0, 0
    _glVertex3f -s, -s, s
    _glTexCoord2f 1, 0
    _glVertex3f s, -s, s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, s
    _glEnd

    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(1)
    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f -s, s, s 'left
    _glTexCoord2f 0, 0
    _glVertex3f -s, -s, s
    _glTexCoord2f 0, 1
    _glVertex3f -s, -s, -s
    _glTexCoord2f 1, 1
    _glVertex3f -s, s, -s
    _glEnd

    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(3)
    _glBegin _GL_QUADS
    _glTexCoord2f 1, 0
    _glVertex3f s, s, s 'right
    _glTexCoord2f 0, 0
    _glVertex3f s, -s, s
    _glTexCoord2f 0, 1
    _glVertex3f s, -s, -s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, -s
    _glEnd

    '_glBindTexture _GL_TEXTURE_2D, skyTextureHandle&(2)
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex3f -s, s, -s 'up
    _glTexCoord2f 0, 0
    _glVertex3f -s, s, s
    _glTexCoord2f 1, 0
    _glVertex3f s, s, s
    _glTexCoord2f 1, 1
    _glVertex3f s, s, -s
    _glEnd

    _glDepthMask _GL_TRUE
END SUB

SUB setMountColor (xi, yi, i, h, h_max) 'assign color on the basis of height map and moisture map.
    IF snowMount = 1 THEN
        IF h > 0.8 * h_max THEN mountColor(i) = 0.439: mountColor(i + 1) = 0.988: mountColor(i + 2) = 0.988: EXIT SUB
        mountColor(i) = 1: mountColor(i + 1) = 1: mountColor(i + 2) = 1
        EXIT SUB
    END IF
    IF h > 0.8 * h_max THEN
        IF moistureMap(xi, yi) < 0.1 THEN mountColor(i) = 0.333: mountColor(i + 1) = 0.333: mountColor(i + 2) = 0.333: EXIT SUB 'scorched
        IF moistureMap(xi, yi) < 0.2 THEN mountColor(i) = 0.533: mountColor(i + 1) = 0.533: mountColor(i + 2) = 0.533: EXIT SUB 'bare
        IF moistureMap(xi, yi) < 0.5 THEN mountColor(i) = 0.737: mountColor(i + 1) = 0.737: mountColor(i + 2) = 0.6705: EXIT SUB 'tundra
        mountColor(i) = 0.8705: mountColor(i + 1) = 0.8705: mountColor(i + 2) = 0.898: EXIT SUB 'snow
    END IF
    IF h > 0.6 * h_max THEN
        IF moistureMap(xi, yi) < 0.33 THEN mountColor(i) = 0.788: mountColor(i + 1) = 0.823: mountColor(i + 2) = 0.607: EXIT SUB 'temperate desert
        IF moistureMap(xi, yi) < 0.66 THEN mountColor(i) = 0.533: mountColor(i + 1) = 0.600: mountColor(i + 2) = 0.466: EXIT SUB 'shrubland
        mountColor(i) = 0.6: mountColor(i + 1) = 0.6705: mountColor(i + 2) = 0.466: EXIT SUB 'taiga
    END IF
    IF h > 0.3 * h_max THEN
        IF moistureMap(xi, yi) < 0.16 THEN mountColor(i) = 0.788: mountColor(i + 1) = 0.823: mountColor(i + 2) = 0.607: EXIT SUB 'temperate desert
        IF moistureMap(xi, yi) < 0.50 THEN mountColor(i) = 0.533: mountColor(i + 1) = 0.6705: mountColor(i + 2) = 0.333: EXIT SUB 'grassland
        IF moistureMap(xi, yi) < 0.83 THEN mountColor(i) = 0.403: mountColor(i + 1) = 0.576: mountColor(i + 2) = 0.349: EXIT SUB 'temperate deciduous forest
        mountColor(i) = 0.262: mountColor(i + 1) = 0.533: mountColor(i + 2) = 0.233: EXIT SUB 'temperate rain forest
    END IF
    IF h < 0.01 * h_max THEN mountColor(i) = 0.262: mountColor(i + 1) = 0.262: mountColor(i + 2) = 0.478: EXIT SUB 'ocean
    IF h < 0.07 * h_max THEN mountColor(i) = 0.627: mountColor(i + 1) = 0.568: mountColor(i + 2) = 0.466: EXIT SUB 'beach
    IF h <= 0.3 * h_max THEN
        IF moistureMap(xi, yi) < 0.16 THEN mountColor(i) = 0.823: mountColor(i + 1) = 0.725: mountColor(i + 2) = 0.545: EXIT SUB 'subtropical desert
        IF moistureMap(xi, yi) < 0.33 THEN mountColor(i) = 0.533: mountColor(i + 1) = 0.6705: mountColor(i + 2) = 0.333: EXIT SUB 'grassland
        IF moistureMap(xi, yi) < 0.66 THEN mountColor(i) = 0.337: mountColor(i + 1) = 0.600: mountColor(i + 2) = 0.266: EXIT SUB 'tropical seasonal forest
        mountColor(i) = 0.2: mountColor(i + 1) = 0.466: mountColor(i + 2) = 0.333: EXIT SUB 'tropical rain forest
    END IF
END SUB

SUB generateTerrainData ()
    DIM A AS vec3, B AS vec3, C AS vec3, R AS vec3
    index = 0

    '##################################################################################################
    '# Note : The below method consumes more memory. It uses 3x more vertex array than the next one.  #
    '# So, use of this method was avoided by me.                                                      #
    '##################################################################################################

    ' _dest _console
    ' FOR z = 0 TO mapH - 1
    ' FOR x = 0 TO mapW - 1
    ' A = terrainData(x, z)
    ' B = terrainData(x, z + 1)
    ' C = terrainData(x + 1, z)
    ' D = terrainData(x+1,z+1)

    ' ' ?index
    ' ' OBJ_CalculateNormal A, B, C, R

    ' ' mountNormal(index) = R.x : mountNormal(index+1) = R.y : mountNormal(index+2) = R.z
    ' ' mountNormal(index+3) = R.x : mountNormal(index+4) = R.y : mountNormal(index+5) = R.z
    ' ' mountNormal(index+6) = R.x : mountNormal(index+7) = R.y : mountNormal(index+8) = R.z

    ' mountVert(index) = A.x : mountVert(index+1) = A.y : mountVert(index+2) = A.z : setMountColor x,z,index, A.y, mountHeightMax
    ' mountVert(index+3) = B.x : mountVert(index+4) = B.y : mountVert(index+5) = B.z :  setMountColor x,z+1,index+3, B.y, mountHeightMax
    ' mountVert(index+6) = C.x : mountVert(index+7) = C.y : mountVert(index+8) = C.z: setMountColor x+1,z,index+6, C.y, mountHeightMax

    ' ' OBJ_CalculateNormal C,B,D, R

    ' ' mountNormal(index+9) = R.x : mountNormal(index+10) = R.y : mountNormal(index+11) = R.z
    ' ' mountNormal(index+12) = R.x : mountNormal(index+13) = R.y : mountNormal(index+14) = R.z
    ' ' mountNormal(index+15) = R.x : mountNormal(index+16) = R.y : mountNormal(index+17) = R.z

    ' mountVert(index+9) = C.x : mountVert(index+10) = C.y : mountVert(index+11) = C.z: setMountColor x+1,z, index+9, C.y, mountHeightMax
    ' mountVert(index+12) = B.x : mountVert(index+13) = B.y : mountVert(index+14) = B.z: setMountColor x,z+1,index+12, B.y, mountHeightMax
    ' mountVert(index+15) = D.x : mountVert(index+16) = D.y : mountVert(index+17) = D.z: setMountColor x+1,z+1,index+15, D.y, mountHeightMax
    ' index = index+18
    ' NEXT x,z

    'this method is efficient than the above one.
    DO
        IF z MOD 2 = 0 THEN x = x + 1 ELSE x = x - 1

        A = terrainData(x, z) 'get out coordinates from our stored data
        B = terrainData(x, z + 1)
        C = terrainData(x + 1, z)

        OBJ_CalculateNormal A, B, C, R 'calculates the normal of a triangle

        'store color, coordinate & normal data in an array
        mountNormal(index) = R.x: mountNormal(index + 1) = R.y: mountNormal(index + 2) = R.z
        mountVert(index) = A.x: mountVert(index + 1) = A.y: mountVert(index + 2) = A.z: setMountColor x, z, index, A.y, mountHeightMax

        mountNormal(index + 3) = R.x: mountNormal(index + 4) = R.y: mountNormal(index + 5) = R.z
        mountVert(index + 3) = B.x: mountVert(index + 4) = B.y: mountVert(index + 5) = B.z: setMountColor x, z + 1, index + 3, B.y, mountHeightMax

        index = index + 6

        IF x = mapW - 1 THEN
            IF z MOD 2 = 0 THEN x = x + 1: z = z + 1
        END IF
        IF x = 1 THEN
            IF z MOD 2 = 1 THEN x = x - 1: z = z + 1
        END IF
        IF z = mapH - 1 THEN EXIT DO
    LOOP
    _DEST 0
END SUB

FUNCTION trimDecimal# (num, n%)
    d$ = RTRIM$(STR$(num))
    dd$ = d$
    FOR i = 1 TO LEN(d$)
        cA$ = MID$(d$, i, 1)
        IF foundpoint = 1 THEN k = k + 1
        IF cA$ = "." THEN foundpoint = 1
        IF k = n% THEN dd$ = LEFT$(dd$, i)
    NEXT i
    trimDecimal# = VAL(dd$)
END FUNCTION


FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION


FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

SUB CircleFill (CX AS LONG, CY AS LONG, R AS LONG, C AS _UNSIGNED LONG)
    'This sub from here: http://www.qb64.net/forum/index.php?topic=1848.msg17254#msg17254
    DIM Radius AS LONG
    DIM RadiusError AS LONG
    DIM X AS LONG
    DIM Y AS LONG

    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0

    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), C, BF

    WHILE X > Y

        RadiusError = RadiusError + Y * 2 + 1

        IF RadiusError >= 0 THEN

            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF

            X = X - 1
            RadiusError = RadiusError - X * 2

        END IF

        Y = Y + 1

        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF

    WEND

END SUB


'coded in QB64 by Fellipe Heitor
'Can be found in p5js.bas library
'http://bit.ly/p5jsbas
FUNCTION noise! (x AS SINGLE, y AS SINGLE, z AS SINGLE)
    STATIC p5NoiseSetup AS _BYTE
    STATIC perlin() AS SINGLE
    STATIC PERLIN_YWRAPB AS SINGLE, PERLIN_YWRAP AS SINGLE
    STATIC PERLIN_ZWRAPB AS SINGLE, PERLIN_ZWRAP AS SINGLE
    STATIC PERLIN_SIZE AS SINGLE

    IF p5NoiseSetup = 0 THEN
        p5NoiseSetup = 1

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

SUB noiseDetail (lod!, falloff!)
    IF lod! > 0 THEN perlin_octaves = lod!
    IF falloff! > 0 THEN perlin_amp_falloff = falloff!
END SUB

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


SUB OBJ_CalculateNormal (p1 AS vec3, p2 AS vec3, p3 AS vec3, N AS vec3)
    DIM U AS vec3, V AS vec3

    U.x = p2.x - p1.x
    U.y = p2.y - p1.y
    U.z = p2.z - p1.z

    V.x = p3.x - p1.x
    V.y = p3.y - p1.y
    V.z = p3.z - p1.z

    N.x = (U.y * V.z) - (U.z * V.y)
    N.y = (U.z * V.x) - (U.x * V.z)
    N.z = (U.x * V.y) - (U.y * V.x)
    OBJ_Normalize N
END SUB

SUB OBJ_Normalize (V AS vec3)
    mag! = SQR(V.x * V.x + V.y * V.y + V.z * V.z)
    V.x = V.x / mag!
    V.y = V.y / mag!
    V.z = V.z / mag!
END SUB

FUNCTION glVec4%& (x, y, z, w)
    STATIC internal_vec4(3)
    internal_vec4(0) = x
    internal_vec4(1) = y
    internal_vec4(2) = z
    internal_vec4(3) = w
    glVec4%& = _OFFSET(internal_vec4())
END FUNCTION

'============================================================
'=== This file was created with MakeDATA.bas by RhoSigma, ===
'=== you must $INCLUDE this at the end of your program.   ===
'============================================================

'=====================================================================
'Function to write the embedded DATAs back to disk. Call this FUNCTION
'once, before you will access the represented file for the first time.
'After the call always use the returned realFile$ ONLY to access the
'written file, as the filename was maybe altered in order to avoid the
'overwriting of an existing file of the same name in the given location.
'---------------------------------------------------------------------
'SYNTAX: realFile$ = WriteqbiconData$ (wantFile$)
'
'INPUTS: wantFile$ --> The filename you would like to write the DATAs
'                      to, can contain a full or relative path.
'
'RESULT: realFile$ --> On success the path and filename finally used
'                      after applied checks, use ONLY this returned
'                      name to access the file.
'                   -> On failure this FUNCTION will panic with the
'                      appropriate ERROR code, you may handle this as
'                      needed with your own ON ERROR GOTO... handler.
'=====================================================================
FUNCTION WriteqbiconData$ (file$)
    '--- separate filename body & extension ---
    FOR po% = LEN(file$) TO 1 STEP -1
        IF MID$(file$, po%, 1) = "." THEN
            body$ = LEFT$(file$, po% - 1)
            ext$ = MID$(file$, po%)
            EXIT FOR
        ELSEIF MID$(file$, po%, 1) = "\" OR MID$(file$, po%, 1) = "/" OR po% = 1 THEN
            body$ = file$
            ext$ = ""
            EXIT FOR
        END IF
    NEXT po%
    '--- avoid overwriting of existing files ---
    num% = 1
    WHILE _FILEEXISTS(file$)
        file$ = body$ + "(" + LTRIM$(STR$(num%)) + ")" + ext$
        num% = num% + 1
    WEND
    '--- write DATAs ---
    ff% = FREEFILE
    OPEN file$ FOR OUTPUT AS ff%
    RESTORE qbicon
    READ numL&, numB&
    FOR i& = 1 TO numL&
        READ dat&
        PRINT #ff%, MKL$(dat&);
    NEXT i&
    IF numB& > 0 THEN
        FOR i& = 1 TO numB&
            READ dat&
            PRINT #ff%, CHR$(dat&);
        NEXT i&
    END IF
    CLOSE ff%
    '--- set result ---
    WriteqbiconData$ = file$
    EXIT FUNCTION

    '--- DATAs representing the contents of file qbicon32.png
    '---------------------------------------------------------------------
    qbicon:
    DATA 144,4
    DATA &H474E5089,&H0A1A0A0D,&H0D000000,&H52444849,&H20000000,&H20000000,&H00000608,&H7A7A7300
    DATA &H000000F4,&H4D416704,&HB1000041,&H61FC0B8F,&H00000005,&H59487009,&H0E000073,&H0E0000C1
    DATA &H91B801C1,&H0000ED6B,&H45741A00,&H6F537458,&H61777466,&H50006572,&H746E6961,&H54454E2E
    DATA &H2E337620,&H30312E35,&HA172F430,&HC0010000,&H54414449,&H97C54758,&H20C371E1,&HA519850C
    DATA &H064430A3,&HDB3124E8,&H823B3FB4,&H5D14C887,&H04A84D21,&H8C096308,&H87F6E2E0,&HD67E02F2
    DATA &HBE7C5F13,&H6EE6318B,&H32F9F98D,&H4A6A13E6,&H66A141DF,&H060DE3F4,&H283CCDC8,&HA0AEB0D4
    DATA &H869AC350,&HE1E5F0A0,&H42FAF78D,&H35621C7F,&HE71AB1F6,&H3CFE85F5,&H0F502444,&HA81115E9
    DATA &H922AF485,&HE6F00828,&H8C2746EE,&H0F4B7EBA,&HEDCDE011,&H15184E93,&H25D3DCD7,&H0A938650
    DATA &H1940834F,&H3D3C2A4E,&H551C3C02,&H6CBEC278,&H8E04EFFE,&H24E64F6A,&H92554702,&HBD808D39
    DATA &HCD712195,&H2812A73D,&HA78549C3,&HF73DC047,&H9EE6B8E1,&H7F365D78,&HB54D0109,&H104A6808
    DATA &H27157A98,&H62AF5302,&HDDC4A04E,&H11F35222,&H082D39E6,&HC89CE6F0,&HBCAE6276,&H020688E9
    DATA &HB732A1F0,&H569436B4,&H8301F0E1,&HBCA6AC3A,&H00E288E9,&H5CB2C091,&H2EAD0057,&HD87DE3F4
    DATA &HEF57B16C,&H5050FC1D,&H2616BDF8,&H237F613D,&HAA390B50,&H40244038,&H3878A98D,&H0230F4AA
    DATA &H0BB9C03C,&HADA7B09D,&H9E953BE6,&H2FD8010E,&HD5B48E43,&H73D2A77C,&HFDB70122,&HCD7141C6
    DATA &H39FAE93D,&HD2A680CF,&H9A026D70,&H24F0FBC2,&H2DAE13E5,&H6FEE0FBC,&H9F2E7013,&HB9AE2830
    DATA &H66A75D27,&H52F6754D,&H0043A019,&HA93873F6,&HA90244F4,&H01CAA1D9,&H10DFFEC2,&H84039540
    DATA &H033CD7FD,&H72A6AC3C,&H11BFB080,&HEB157B98,&HD75E3409,&H02184099,&H688E9A94,&H0854190E
    DATA &H2FF0040F,&H46621E72,&H1B3509A1,&H05FDBBD5,&HF13FDC1C,&H6A6E33B4,&H00000000,&H444E4549
    DATA &HAE,&H42,&H60,&H82
END FUNCTION


