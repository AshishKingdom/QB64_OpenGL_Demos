'@Author:Petr Preclik
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE
REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE


'Press 'g' for fog, 'a' for blending, 'h' for texture selecting, 'r' for stop rotating, '/' or '.' for Y speed, ',' or 'm' for X speed, 'n' or 'b' for zoom and 'v' for lightning

'UPGRADE: With fog + english comment


DECLARE LIBRARY '                                       GLUT  for mipmaps texturing, now without supported subprogram
    SUB gluBuild2DMipmaps (BYVAL target AS _UNSIGNED LONG, BYVAL internalformat AS LONG, BYVAL width AS LONG, BYVAL height AS LONG, BYVAL format AS _UNSIGNED LONG, BYVAL type AS _UNSIGNED LONG, pixels AS _OFFSET)
END DECLARE

_FULLSCREEN

dim shared path$
path$ = "Resources/Petr's_fog_and_blending/"
DIM SHARED a AS LONG, T1 AS LONG '                       a is for image, T1 for texture


a& = _LOADIMAGE(path$+"container.JPG", 32)
'fog upgrade:                                            i use array style for fog color setting. Arrays are loaded in _GL with _OFFSET
DIM fogColor(3): fogColor(0) = 0.5F: fogColor(1) = 0.5F: fogColor(2) = 0.5F: fogColor(3) = 1.0F



DIM SHARED light, lp, fp, xrot, yrot, xspeed, yspeed, z AS _FLOAT, FirstInit AS _BYTE, li AS _BYTE ' communication between _GL and QB64 sources
DIM SHARED LightAmbient(3) AS _FLOAT '                    three arrays with colors for lightning
DIM SHARED LightDiffuse(3) AS _FLOAT
DIM SHARED LightPosition(3) AS _FLOAT
DIM SHARED textur AS _BYTE, filter, blend, fog 'upgrade


textur = 1
z = -6.0F
xspeed = .5
yspeed = -.8 '                                             start settings
filter = 0
blend = 1
li = 1
fog = 3


DO
    i$ = INKEY$
    SELECT CASE LCASE$(i$) '                               inputs from keyboard. In begin in QB64, in end in C++
        CASE CHR$(27): END
        CASE "v": IF li = 0 THEN li = 1 ELSE li = 0: _DELAY .25
        CASE "b": z = z - .1
        CASE "n": z = z + .1
        CASE "m": xspeed = xspeed + .1
        CASE ",": xspeed = xspeed - 1
        CASE ".": yspeed = yspeed + .1
        CASE "/": yspeed = yspeed - 1
        CASE "r": xspeed = 0: yspeed = 0
        CASE "h": textur = textur + 1: IF textur > 2 THEN textur = 0
        CASE "a": IF blend = 0 THEN blend = 1 ELSE blend = 0: _DELAY .25
        CASE "g": fog = fog + 1: IF fog > 3 THEN fog = 0
    END SELECT
LOOP


SUB _GL ()
IF FirstInit = 0 THEN

    FirstInit = 1
    LightAmbient(0) = 0.5F: LightAmbient(1) = 0.5F: LightAmbient(2) = 0.5F: LightAmbient(3) = 1.0F 'okolni svetlo
    LightDiffuse(0) = 0.0F: LightDiffuse(1) = 0.0F: LightDiffuse(2) = 0.0F: LightDiffuse(3) = 0.0F 'prime svetlo
    LightPosition(0) = 0.0F: LightPosition(1) = 0.0F: LightPosition(2) = 2.0F: LightPosition(3) = 1.0F ' Pozice svetla

    'insert colors to arrays for lightning, only in first loop run


    T1& = GLH_Image_to_Texture(a&) 'create texture from source image and insert this texture as index to array DONT_USE_GLH_NewTexture_handle

END IF
_glViewport 0, 0, _DESKTOPWIDTH, _DESKTOPHEIGHT '                   visible area is fullscreen
_glMatrixMode _GL_PROJECTION '
_glLoadIdentity '
_gluPerspective 45.0F, _DESKTOPWIDTH / _DESKTOPHEIGHT, 0.1F, 100.0F 'set camera, other statement for full 3D is _gluLookAt
_glMatrixMode _GL_MODELVIEW '
_glLoadIdentity '                                                    reset all axis to basic settings (0,0,0 = X, Y, Z in middle)



_glEnable _GL_TEXTURE_2D ' enable texture mapping
_glShadeModel _GL_SMOOTH '
_glClearColor 0.5F, 0.5F, 0.5F, 1.0F ' background color is the same as fog color
_glClearDepth 1.0F '                   depth buffer settings
_glEnable _GL_DEPTH_TEST '             enable depth buffer testing
_glDepthFunc _GL_LEQUAL '              depth buffer testing type
_glHint _GL_PERSPECTIVE_CORRECTION_HINT, _GL_NICEST

SELECT CASE fog '                                               select fog filtering type selected with "g" from keyboard
    CASE 0
    CASE 1
        _glFogi _GL_FOG_MODE, _GL_EXP '             fog mode
        _glFogfv _GL_FOG_COLOR, _OFFSET(fogColor) ' fog color
        _glFogf _GL_FOG_DENSITY, 0.35F '            fog density
    CASE 2
        _glFogi _GL_FOG_MODE, _GL_EXP2 '            fog mode
        _glFogfv _GL_FOG_COLOR, _OFFSET(fogColor) ' fog color
        _glFogf _GL_FOG_DENSITY, 0.35F '            fog density
    CASE 3
        _glFogi _GL_FOG_MODE, _GL_LINEAR '
        _glFogfv _GL_FOG_COLOR, _OFFSET(fogColor) '
        _glFogf _GL_FOG_DENSITY, 0.35F '
END SELECT

IF fog > 0 THEN
    _glHint _GL_FOG_HINT, _GL_DONT_CARE '       fog Quality
    _glFogf _GL_FOG_START, 1.0F '               fog begin in depth - axis z
    _glFogf _GL_FOG_END, 5.0F '                 fog end in depth - axis z
    _glEnable _GL_FOG '                         enable fog
ELSE
    _glDisable _GL_FOG '                        if g = 0 then is none fog, this disable it
END IF

' next source code is the same as in prevoius case

_glLightfv _GL_LIGHT1, _GL_AMBIENT, GLH_RGBA(LightAmbient(0), LightAmbient(1), LightAmbient(2), LightAmbient(3)) 'for light after V press
_glLightfv _GL_LIGHT1, _GL_DIFFUSE, GLH_RGBA(LightDiffuse(0), LightDiffuse(1), LightDiffuse(2), LightDiffuse(3))
_glLightfv _GL_LIGHT1, _GL_POSITION, GLH_RGBA(LightPosition(0), LightPosition(1), LightPosition(2), LightPosition(3))
_glEnable _GL_LIGHT1
IF li = 0 THEN _glEnable _GL_LIGHTING ELSE _glDisable _GL_LIGHTING ' with "v" is enabled or disabled lightning


_glClear _GL_COLOR_BUFFER_BIT
_glClear _GL_DEPTH_BUFFER_BIT 'clear screen ad depth buffer

_glLoadIdentity '              matrix reset


'//////////////////////////////////////////////////////////////////
_glColor4f 1.0F, 1.0F, 1.0F, 0.5F '                                   set full brightness and 50% alpha
_glBlendFunc _GL_SRC_ALPHA, _GL_ONE '                                 Blending =  this two are need for alphablending after pressing "a"
'####################################################################

_glTranslatef 0.0F, 0.0F, z
_glRotatef xrot, 1.0F, 0.0F, 0.0F '                                    quads rotating in axis x  (_glRotatef How much, x, y, z)
_glRotatef yrot, 0.0F, 1.0F, 0.0F '                                    quads rotating in axis y


SELECT CASE textur '                                                   texture filtering select - after "h" is pressed
    CASE 0: GLH_Select_Texture T1&, 0 '
    CASE 1: GLH_Select_Texture T1&, 1
    CASE 2: GLH_Select_Texture T1&, 2
END SELECT

IF blend = 1 THEN '                                                    this create AlphaBlending

    _glEnable _GL_BLEND
    _glDisable _GL_DEPTH_TEST

ELSE

    _glDisable _GL_BLEND
    _glEnable _GL_DEPTH_TEST

END IF

GLH_Select_Texture T1&, textur '                                   the same as _glBindTexture - insert texture from memory to OpenGL image, muss be before _glBegin
_glBegin _GL_QUADS
'    FRONT WALL
_glNormal3f 0.0F, 0.0F, 1.0F '                                     glNormal3f is for lightning. If is bad set, lightning is wrong.
_glTexCoord2f 0.0F, 0.0F: _glVertex3f -1.0F, -1.0F, 1.0F
_glTexCoord2f 1.0F, 0.0F: _glVertex3f 1.0F, -1.0F, 1.0F
_glTexCoord2f 1.0F, 1.0F: _glVertex3f 1.0F, 1.0F, 1.0F
_glTexCoord2f 0.0F, 1.0F: _glVertex3f -1.0F, 1.0F, 1.0F
'   BACK WALL
_glNormal3f 0.0F, 0.0F, -1.0F 'Normála
_glTexCoord2f 1.0F, 0.0F: _glVertex3f -1.0F, -1.0F, -1.0F
_glTexCoord2f 1.0F, 1.0F: _glVertex3f -1.0F, 1.0F, -1.0F
_glTexCoord2f 0.0F, 1.0F: _glVertex3f 1.0F, 1.0F, -1.0F
_glTexCoord2f 0.0F, 0.0F: _glVertex3f 1.0F, -1.0F, -1.0F
'    TOP WALL
_glNormal3f 0.0F, 1.0F, 0.0F
_glTexCoord2f 0.0F, 1.0F: _glVertex3f -1.0F, 1.0F, -1.0F
_glTexCoord2f 0.0F, 0.0F: _glVertex3f -1.0F, 1.0F, 1.0F
_glTexCoord2f 1.0F, 0.0F: _glVertex3f 1.0F, 1.0F, 1.0F
_glTexCoord2f 1.0F, 1.0F: _glVertex3f 1.0F, 1.0F, -1.0F
'    BOTTOM WALL
_glNormal3f 0.0F, -1.0F, 0.0F
_glTexCoord2f 1.0F, 1.0F: _glVertex3f -1.0F, -1.0F, -1.0F
_glTexCoord2f 0.0F, 1.0F: _glVertex3f 1.0F, -1.0F, -1.0F
_glTexCoord2f 0.0F, 0.0F: _glVertex3f 1.0F, -1.0F, 1.0F
_glTexCoord2f 1.0F, 0.0F: _glVertex3f -1.0F, -1.0F, 1.0F
'   RIGHT WALL
_glNormal3f 1.0F, 0.0F, 0.0F
_glTexCoord2f 1.0F, 0.0F: _glVertex3f 1.0F, -1.0F, -1.0F
_glTexCoord2f 1.0F, 1.0F: _glVertex3f 1.0F, 1.0F, -1.0F
_glTexCoord2f 0.0F, 1.0F: _glVertex3f 1.0F, 1.0F, 1.0F
_glTexCoord2f 0.0F, 0.0F: _glVertex3f 1.0F, -1.0F, 1.0F
'   LEFT WALL
_glNormal3f -1.0F, 0.0F, 0.0F
_glTexCoord2f 0.0F, 0.0F: _glVertex3f -1.0F, -1.0F, -1.0F
_glTexCoord2f 1.0F, 0.0F: _glVertex3f -1.0F, -1.0F, 1.0F
_glTexCoord2f 1.0F, 1.0F: _glVertex3f -1.0F, 1.0F, 1.0F
_glTexCoord2f 0.0F, 1.0F: _glVertex3f -1.0F, 1.0F, -1.0F
_glEnd
xrot = xrot + xspeed '                                          for rotation in X axis
yrot = yrot + yspeed '                                          for rotation in Y axis
END SUB

'next comments are WITHOUT GARRANTY, this functions are writed by QB64 GOD Galleon
FUNCTION GLH_Image_to_Texture (image_handle AS LONG) '                                 turn an image handle into a texture handle

IF image_handle >= -1 THEN ERROR 258: EXIT FUNCTION ' don't allow screen pages - if is image handle from _LOADIMAGE invalid, generate error 258 and exit out
DIM m AS _MEM '                                       _MEM type return image data from memory or image offset from memory....
m = _MEMIMAGE(image_handle) '                         insert to M image from memory (_LOADIMAGE) image
DIM h AS LONG '                                                        declare H as long number
h = DONT_USE_GLH_New_Texture_Handle '                                  insert to H INDEX number for array with TEXTURES
GLH_Image_to_Texture = h '                                             for this funkcion set value H
_glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(h).handle '         funkcion OpenGL show, where in memory is TEXTURE
_glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _WIDTH(image_handle), _HEIGHT(image_handle), 0, &H80E1&&, _GL_UNSIGNED_BYTE, m.OFFSET
'_glTexImage2D load this texture to graphic card buffer. Zero is details level (basic setting is 0), image color type, width, height, ?, &H80E1&& is
'alternative for _GL_RGBA, next is data type and area in memory with texture.

_MEMFREE m '                                                          clear memory, delete image M
END FUNCTION '


FUNCTION DONT_USE_GLH_New_Texture_Handle '                          function create texture in memory
handle&& = 0 '                                                      create new variable type _INTEGER64 in memory
_glGenTextures 1, _OFFSET(handle&&) '                               Create one texture to memory to adress hnadle&&  (and copy there image data)
DONT_USE_GLH_New_Texture_Handle = handle&& '                        set for this function value from handle&& from previous line
FOR h = 0 TO UBOUND(DONT_USE_GLH_Handle) '                          copy to array DONT USE GLH HANDLE and write:
    IF DONT_USE_GLH_Handle(h).in_use = 0 THEN '                     if this index number is not used, then
        DONT_USE_GLH_Handle(h).in_use = 1 '                         set in array DONT_USE_GLH_HANDLE with index h this record as used (1)
        DONT_USE_GLH_Handle(h).handle = handle&& '                  copy _INTEGER64 data with image to this array (DONT_USE_GLH_Handle(h)
        DONT_USE_GLH_New_Texture_Handle = h '                       set for this function number h and then exit out. So if in next loop found, that this record is already created, then is not valid first IF and function continue:
        EXIT FUNCTION '                                       (function copy yourself, all old records and after EXIT FUNCTION insert new texture datas)
    END IF
NEXT
REDIM _PRESERVE DONT_USE_GLH_Handle(UBOUND(DONT_USE_GLH_HANDLE) * 2) AS DONT_USE_GLH_Handle_TYPE 'here is in next time, if is texture created in memory and in array. REDIM it to 2* higher size
DONT_USE_GLH_Handle(h).in_use = 1 '                               select new index with new record as used,
DONT_USE_GLH_Handle(h).handle = handle&& '                        copy to new record image datas
DONT_USE_GLH_New_Texture_Handle = h '                             set yourself as valid number with last used record (index number)
END FUNCTION


SUB GLH_Select_Texture (texture_handle AS LONG, filter AS _BYTE) '                                            turn an image handle into a texture handle
'IF texture_handle& < 1 OR texture_handle& > UBOUND(DONT_USE_GLH_HANDLE) THEN ERROR 258: EXIT FUNCTION      ' if selected texture is invalid, or index number is higher as maximal index number in array DONT_USE_GLH_HANDLE, generate error and exit out
IF DONT_USE_GLH_Handle(texture_handle).in_use = 0 THEN ERROR 258: BEEP: EXIT FUNCTION ' if you try used empty record as texture, then exit out

SELECT CASE filter '   this is not original Galleon function, is my own upgrade for texture filtering
    CASE 0 '                                                                     better filtering
        _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_NEAREST
        _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, GL_NEAREST
        _glTexImage2D _GL_TEXTURE_2D, 0, 3, _WIDTH(a&), _HEIGHT(a&), 0, &H80E1&&, GL_UNSIGNED_BYTE, DONT_USE_GLH_Handle(texture_handle).handle
        _glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(h).handle

    CASE 1
        _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR '     basic filtering for old computers
        _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR
        _glTexImage2D _GL_TEXTURE_2D, 0, 3, _WIDTH(a&), _HEIGHT(a&), 0, &H80E1&&, GL_UNSIGNED_BYTE, DONT_USE_GLH_Handle(texture_handle).handle
        _glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(h).handle

    CASE 2 '                                                                      uncompleted - mipmaps filtering (best if be completed)
        gluBuild2DMipmaps _GL_TEXTURE_2D, 1, 16, 16, _GL_RGBA, _GL_UNSIGNED_BYTE, _OFFSET(DONT_USE_GLH_Handle().handle)
END SELECT

END SUB
'used opengl rgba functions
FUNCTION GLH_RGB%& (r AS SINGLE, g AS SINGLE, b AS SINGLE) '                      functions for lightning, coded by Galleon.
DONT_USE_GLH_COL_RGBA(1) = r '                                                    you not need it if use some statements and arrays with using _OFFSET (i show it in next demos)
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