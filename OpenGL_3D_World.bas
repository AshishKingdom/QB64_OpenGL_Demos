'@Author : Petr Preclik
_TITLE "3D World!"

dim shared path$
path$ = "Resources/3D World/"

' ############# GLHB.BI ########################
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE
REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE
' ##############################################
SCREEN _NEWIMAGE(640, 480, 32) '                                    set the same resolution for OpenGL window
DIM SHARED i '                                                      index
TYPE filread '                                                      i write 5 variables to one array. X, Y, Z for triangle, U, V for texture.
    x AS SINGLE '                                                   Three lines are three X, three Y and three Z. So this three lines create ONE triangle
    y AS SINGLE '                                                   and three lines contains three U and V  for texture coordinate
    z AS SINGLE
    u AS SINGLE
    v AS SINGLE
END TYPE
CONST piover180 = 0.0174532925F '                                   if you go, this is constant for simulation steps

file$ = path$+"world.txt" '                                               source file contains vertexes for triangles and for textures in this order:
IF _FILEEXISTS(file$) = -1 THEN 'file exists                        X, Y, Z, U, V  three lines create one triangle. Try modify it, if you add next lines,
    '                                                               muss be rewrited then number after word "NUMMPOLIES". The number is calculated as
    DIM num AS STRING '                                             (total file lines - 1) / 3 First three lines are first triangle in the floor, next three
    OPEN file$ FOR INPUT AS #10 '                                   lines for second trinagle in the floor, so is created quad for floor. If you look to
    LINE INPUT #10, num$ '                                          lines 7,8,9 and 1,2,3 as you see, here are the same coordinates, only Y is not 0 as in
    'PRINT num$: SLEEP '                                            previous case, but is 1. It so, because this coordinates are for roof.
    triangles = VAL(RIGHT$(num$, 2)) 'ok, return 36               ' TRIANGLES = record in file - number of triangles
    REDIM SHARED fileread(triangles * 3) AS filread '
    DO WHILE NOT EOF(10) '                                          read the file to end, but program need correct number in TRIANGLES for correct array dimension / yes i can create this automatic.....
        INPUT #10, x, y, z, u, v '                                  on line contains 5 records. I read all in one time (faster with GET, but then in file can not be commas...
        i = i + 1 '                                                 i is index. Start here as 1
        fileread(i).x = x
        fileread(i).y = y
        fileread(i).z = z
        fileread(i).u = u
        fileread(i).v = v

    LOOP
    CLOSE #10
ELSE
    BEEP: PRINT "File not exists": END
END IF

DIM SHARED first, xtrans, ytrans, ztrans, xpos, ypos, zpos, walkbias, sceneroty, yrot, lookupdown, T1 AS LONG, T2 AS LONG, T3 AS LONG, t4 AS LONG, t5 AS LONG, blend, walkbiasangle
blend = -1 '                                                        control blending. Press B in the program and look
'                                                                   T1& - T5& for textures, walkbias is for steps simulation, other for screen move


DO WHILE _KEYHIT <> 27
    k$ = INKEY$
    SELECT CASE LCASE$(k$)
        CASE "b": blend = blend * -1: _DELAY .15
        CASE CHR$(0) + "h": '                                               arrow up
            xpos = xpos - SIN(heading * piover180) * 0.05F '                move on x axis
            zpos = zpos - COS(heading * piover180) * 0.05F '                move on z axis
            IF walkbiasangle >= 359.0F THEN walkbiasangle = 0.0F ELSE walkbiasangle = walkbiasangle + 10 'steps simulation (this and next line)
            walkbias = SIN(walkbiasangle * piover180) / 20.0F



        CASE CHR$(0) + "p": '                                              arrow down

            xpos = xpos + SIN(heading * piover180) * 0.05F '               move on x axis
            zpos = zpos + COS(heading * piover180) * 0.05F '               move on z axis
            IF walkbiasangle <= 1.0F THEN walkbiasangle = 359.0F ELSE walkbiasangle = walkbiasangle - 10 'steps simulation
            walkbias = SIN(walkbiasangle * piover180) / 20.0F


        CASE CHR$(0) + "m": '                                               arrow right
            heading = heading - 1.0F '                                      rotate screen. All screen moves are in diferent direction
            yrot = heading

        CASE CHR$(0) + "k": '                                               arrow left

            heading = heading + 1.0F '                                      rotate screen
            yrot = heading

        CASE CHR$(0) + "i": '                                               page UP for look UP
            lookupdown = lookupdown - 1.0F

        CASE CHR$(0) + "u": '                                               page DOWN for look DOWN
            lookupdown = lookupdown + 1.0F

    END SELECT



    '  PRINT LBOUND(readfile), UBOUND(readfile)               Ubound in newerest IDE  Return 10. I dont know why. So i use index I for array size (in GL).
LOOP


SUB _GL
IF first = 0 THEN

    texture& = _LOADIMAGE(path$+"floor.png", 32)
    T1& = GLH_Image_to_Texture(texture&)
    _FREEIMAGE texture&
    texture& = _LOADIMAGE(path$+"wall.jpg", 32)
    T2& = GLH_Image_to_Texture(texture&)
    _FREEIMAGE texture& 
    ' texture& = _LOADIMAGE(path$+"wall.jpg", 32) '              load 4 textures, as 5th texture i use empty memory place/invalid name, that create white walls.
    T3& = T2&
    ' _FREEIMAGE texture&
    texture& = _LOADIMAGE(path$+"wall_art.jpg", 32)
    t4& = GLH_Image_to_Texture(texture&)
    _FREEIMAGE texture&
    first = 1
    EXIT SUB
END IF

_glMatrixMode _GL_PROJECTION '                              Select The Projection Matrix
_glLoadIdentity '                                           Reset The Projection Matrix

_gluPerspective 45.0F, _WIDTH / _HEIGHT, 0.1F, 100.0F

_glMatrixMode _GL_MODELVIEW '                               Select The Modelview Matrix

_glLoadIdentity '                                           Reset The Modelview Matrix










IF blend = 1 THEN _glEnable _GL_BLEND: _glEnable _GL_DEPTH_TEST ELSE _glDisable _GL_BLEND: _glDisable _GL_DEPTH_TEST 'is b pressed?

_glEnable _GL_TEXTURE_2D '                                      enable texture mapping
_glBlendFunc _GL_SRC_ALPHA, _GL_ONE '                           set blending (alpha) as transparent
_glClearColor 0.0F, 0.0F, 0.0F, 0.0F '                          black background
_glClearDepth 1.0 '                                             set depth buffer
_glDepthFunc _GL_LESS '                                         set depth type testing
_glEnable _GL_DEPTH_TEST '                                      enable depth testing
_glShadeModel _GL_SMOOTH '                                      enable smooth
_glHint _GL_PERSPECTIVE_CORRECTION_HINT, _GL_NICEST '           best perspective projection
xtrans = -xpos '                                                for move in  x axis
ztrans = -zpos '                                                for moving in axis z
ytrans = -walkbias - 0.25F '                                    steps simulation
sceneroty = 360.0F - yrot '                                     view angle
_glRotatef lookupdown, 1.0F, 0.0F, 0.0F '                       Rotation on axis x - look up or down
_glRotatef sceneroty, 0.0F, 1.0F, 0.0F '                        Rotation on axis Y - rotation left/right
_glTranslatef xtrans, ytrans, ztrans '                          shift to position in the scene



FOR load = 1 TO i STEP 3 '                                      load every 3th record from array named fileread. We need 3 * X....
    SELECT CASE load '                                          this select first texture for first triangle  (if this is not here, then is not first triangle in the floor)
        CASE 1 '                                                case 1 is for first three lines from file world.txt this lines are for first triangle in the floor
            GLH_Select_Texture T1&
    END SELECT

    _glBegin _GL_TRIANGLES '                                    start tringle drawing
    _glNormal3f 0.0F, 0.0F, 1.0F '                              Normal here is for lighting, is not used now
    x_m = fileread(load).x: '                                   first vertex X
    y_m = fileread(load).y
    z_m = fileread(load).z
    u_m = fileread(load).u
    v_m = fileread(load).v
    _glTexCoord2f u_m, v_m: _glVertex3f x_m, y_m, z_m '         set coordinates for texture

    _glNormal3f 0.0F, 0.0F, 1.0F '                               This block is the same as previous, BUT LOOK AT INDEX, i read here LINE index + 1 from file
    x_m = fileread(load + 1).x '                                 first vertex X2
    y_m = fileread(load + 1).y
    z_m = fileread(load + 1).z
    u_m = fileread(load + 1).u
    v_m = fileread(load + 1).v
    _glTexCoord2f u_m, v_m: _glVertex3f x_m, y_m, z_m

    _glNormal3f 0.0F, 0.0F, 1.0F
    x_m = fileread(load + 2).x '                                The same block BUT index + 2, vertex X3
    y_m = fileread(load + 2).y
    z_m = fileread(load + 2).z
    u_m = fileread(load + 2).u
    v_m = fileread(load + 2).v
    _glTexCoord2f u_m, v_m: _glVertex3f x_m, y_m, z_m
    _glEnd


    SELECT CASE load '                                         in first time i thing, that i write to file world.txt 6th number for every trinagle with
        CASE 1 TO 2 '                                          texture number, but then i use this way. Two triangles create one Quad, but not in all cases.
            GLH_Select_Texture T1& '                           texture for floor

        CASE 3 TO 4
            GLH_Select_Texture T2& '                           texture for roof (roof number is to 8)

        CASE 8 TO 20, 34
            GLH_Select_Texture T3& '                           texture for wall - rock

        CASE 21, 22
            GLH_Select_Texture t4& '                           graphite texture


        CASE 26 TO 32
            GLH_Select_Texture t4& '                           graphite texture

        CASE 33, 35

            GLH_Select_Texture t0& '                           none texture, draw white walls

    END SELECT

NEXT
end sub

'next is included Galleon's function for creating textures (upgraded version with LINEAR filtering (shrinking and zooming))
' ################ GLHu0.BI ######################

FUNCTION GLH_Image_to_Texture (image_handle AS LONG) 'turn an image handle into a texture handle  prevede obrazek na texturu
IF image_handle >= 0 THEN ERROR 258: EXIT FUNCTION 'don't allow screen pages                      pokud parametr imageHandle >=0 ukonci a error 258
DIM m AS _MEM '                                                                                   typ _mem vraci hodnotu o obrazku:
m = _MEMIMAGE(image_handle) '                                          vraci hodnotu (jako loadimage) o platnosti obrazu obrazku v pameti, je to asi bez hlavy
DIM h AS LONG '                                                        deklaruje promennou H
h = DONT_USE_GLH_New_Texture_Handle '                                  priradi H hodnotu prazdneho mista v pameti
GLH_Image_to_Texture = h '                                             priradi teto funkci hodnotu volneho mista v pameti H
_glBindTexture _GL_TEXTURE_2D, DONT_USE_GLH_Handle(h).handle        '  funkce ukaze OpenGL misto v pameti, kde je ulozena textura
_glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _WIDTH(image_handle), _HEIGHT(image_handle), 0, &H80E1&&, _GL_UNSIGNED_BYTE, m.OFFSET
'cislo nula je hladina podrobnosti obrazku, nasleduje pocet barev, sirka, vyska,             _GL_RGB
'dalsi nula je ramecek / obvykle nulovy, dalsi urcuje typ pole = jakeho typu jsou barvy a na konci pole dat pro obrazek
_MEMFREE m '                                                          _glTexImage2D: vytvori texturu
END FUNCTION '                                                        _MEMFREE delete this image from memory. But if you need it in memory, use _MEMCOPY

FUNCTION DONT_USE_GLH_New_Texture_Handle '                          funkce pro H
handle&& = 0 '                                                      vytvori novou promennou typu INTEGER64
_glGenTextures 1, _OFFSET(handle&&) '                               rekne OpenGL, ze chceme sestavit texturu v poctu 1 kus v pameti na adrese zacatku pole hnadle&&
DONT_USE_GLH_New_Texture_Handle = handle&&                         'teto funkci priradi hodnotu z predchoziho radku, tedy obraz pameti handle&&
FOR h = 1 TO UBOUND(DONT_USE_GLH_Handle)                           'zahaji plneni pole DONT USE GLH HANDLE
    IF DONT_USE_GLH_Handle(h).in_use = 0 THEN                      'pokud se nepouziva pole DONT USE GLH HANDLE s indexem H, potom
        DONT_USE_GLH_Handle(h).in_use = 1                          'oznaci pole DONT USE GLH HANDLE jako pouzivane
        DONT_USE_GLH_Handle(h).handle = handle&&                   'priradi poli DONT USE GLH HANDLE hodnotu prazdneho mista v pameti
        DONT_USE_GLH_New_Texture_Handle = h                        'priradi poli DONT USE GLH New Texture Handle hodnotu H (hodnotu velikosti pole)
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
'upgrade
_glTexParameteri _GL_TEXTURE_2D,_GL_TEXTURE_MAG_FILTER,_GL_LINEAR
_glTexParameteri _GL_TEXTURE_2D,_GL_TEXTURE_MIN_FILTER,_GL_LINEAR
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

' ################################################










