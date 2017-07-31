'Just another demo for OpenGL
'I've commented this code to explain
'some OpenGL stuffs (Well.. I'm not a good teacher)
'
'and Thanks for seeing this demo.

'_delay 1

RANDOMIZE TIMER

_TITLE "OpenGL Simple Demo"
SCREEN _NEWIMAGE(700, 700, 32)

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE

TYPE vec3
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
END TYPE

TYPE vec2
    x AS _FLOAT
    y AS _FLOAT
END TYPE

TYPE vertex
    v AS vec3
    texCoord AS vec2
END TYPE

TYPE object_positions
    pos AS vec3
    ang AS vec3
END TYPE

DIM SHARED cubeData(36) AS vertex

'I've store the cube data in a file because it would be frustrating
'to store it in code and also wastage of time.
'Data file contain 36 vertices along with their texture coordinates. (6 Faces,
'each face consists of 2 triangles, and each triangle have 3 vertices, and)
'We could have store data in the forms of quads but we are storing it in
'triangles because OpenGL basically works on triangles.
index = 1
t = 0
OPEN "object.vbo" FOR INPUT AS #1
WHILE NOT EOF(1)
    INPUT #1, tmp$
    IF t > 4 THEN t = 0: index = index + 1
    SELECT CASE t
        CASE 0
            cubeData(index).v.x = VAL(tmp$)
            t = t + 1
        CASE 1
            cubeData(index).v.y = VAL(tmp$)
            t = t + 1
        CASE 2
            cubeData(index).v.z = VAL(tmp$)
            t = t + 1
        CASE 3
            cubeData(index).texCoord.x = VAL(tmp$)
            t = t + 1
        CASE 4
            cubeData(index).texCoord.y = VAL(tmp$)
            t = t + 1
    END SELECT
WEND
CLOSE #1

DIM SHARED glAllow AS _BYTE

'Used by GLH RGB/etc helper functions
DIM SHARED DONT_USE_GLH_COL_RGBA(1 TO 4) AS SINGLE

'Used to manage textures
TYPE DONT_USE_GLH_Handle_TYPE
    in_use AS _BYTE
    handle AS LONG
END TYPE

'Used by GLH RGB/etc helper functions
REDIM SHARED DONT_USE_GLH_Handle(1000) AS DONT_USE_GLH_Handle_TYPE

DIM SHARED cubePositions(10) AS object_positions

'We don't have to specify another vertices for the cube to change its position.
'We will use below data to translate into that coordinates and draw our box.

cubePositions(1).pos.x = 0: cubePositions(1).pos.y = 0: cubePositions(1).pos.z = 0
cubePositions(2).pos.x = 2: cubePositions(2).pos.y = 5: cubePositions(2).pos.z = -15
cubePositions(3).pos.x = -1.5: cubePositions(3).pos.y = -2.2: cubePositions(3).pos.z = -2.5
cubePositions(4).pos.x = 3.8: cubePositions(4).pos.y = 2: cubePositions(4).pos.z = 12.3
cubePositions(5).pos.x = 2.4: cubePositions(5).pos.y = -0.4: cubePositions(5).pos.z = -3.5
cubePositions(6).pos.x = -1.7: cubePositions(6).pos.y = 3.0: cubePositions(6).pos.z = -7.5
cubePositions(7).pos.x = 1.3: cubePositions(7).pos.y = -2.0: cubePositions(7).pos.z = -2.5
cubePositions(8).pos.x = 1.5: cubePositions(8).pos.y = 2.0: cubePositions(8).pos.z = -2.5
cubePositions(9).pos.x = 1.5: cubePositions(9).pos.y = 0.2: cubePositions(9).pos.z = -1.5
cubePositions(10).pos.x = -1.3: cubePositions(10).pos.y = 1.0: cubePositions(10).pos.z = -1.5


FOR i = 1 TO UBOUND(cubePositions)
    cubePositions(i).ang.x = RND
    cubePositions(i).ang.y = RND
    cubePositions(i).ang.z = RND
NEXT

Dim shared back&, front&, top&, bottom&, left&, right&

print "Loading Textures..."

back& = _loadimage("skybox/back.jpg")
front& = _loadimage("skybox/front.jpg")
bottom& = _loadimage("skybox/bottom.jpg")
top& = _loadimage("skybox/top.jpg")
left& = _loadimage("skybox/left.jpg")
right& = _loadimage("skybox/right.jpg")

print "Press Any Key To Start Demo."
a$ = input$(1)
cls ,1

Dim shared ZoomValue

_glrender _behind
'I always use this variable for initialization and to
'stop OpenGL to render anything. For this code, OpenGL
'will only render, when glAllow is true.
'Try commenting below line. You will see that OpenGL does not renders anything.
glAllow = -1
ZoomValue = 45.0
fade = 255
DO
    if fade>0 then
	    cls ,1
	    line (0,0)-(_width,_height),_rgba(0,0,0,fade),bf
		fade = fade - 3
		_display
	end if
	if _keydown(asc("w")) then ZoomValue = ZoomValue - .5
	if _keydown(asc("s")) then ZoomValue = ZoomValue + .5
	ZoomValue = constrain(ZoomValue, 1.0, 45.5)
    _LIMIT 30
LOOP 
SYSTEM

SUB _GL () STATIC
    'if you are eager to learn OpenGL then
    'visit https://learnopengl.com/
    '^^^^ This is Cool site based on modern OpenGL. I'm cuurently learning OpenGL from there.
    IF NOT glAllow THEN EXIT SUB 'we are not ready yet.

    'we want to tell OpenGL to enable Z-Buffer for 3D Purpose (disable by default).
    _glEnable _GL_DEPTH_TEST
    'Since we are using texture, we have to enable _GL_TEXTURE_2D (disable by default).
    _glEnable _GL_TEXTURE_2D
	_glDepthMask _GL_TRUE


    'a little trick to execute the code below once

    IF NOT glInit THEN 'should be executed once.
        glInit = -1
        'we'll set the viewport now. By setting the viewport, we tell
        'the OpenGL how to manupulate it's vertex buffer from 3D to 2D
        'on our screen.
        _glViewport 0, 0, _WIDTH, _HEIGHT
        aspect# = _WIDTH / _HEIGHT 'used for perspective.
        'we'll load image data in memory and convert it into texture
        'by GLH_Image_to_Texture() function (Written By Galleon).
        texImage& = _LOADIMAGE("container2.png")
        tex& = GLH_Image_to_Texture(texImage&)
        'we don't need this anymore.
        _FREEIMAGE texImage&
		
		back_tex& = GLH_Image_to_Texture(back&)
		front_tex& = GLH_Image_to_Texture(front&)
		bottom_tex& = GLH_Image_to_Texture(bottom&)
		top_tex& = GLH_Image_to_Texture(top&)
		left_tex& = GLH_Image_to_Texture(left&)
		right_tex& = GLH_Image_to_Texture(right&)
		
		_freeimage back&
		_freeimage front&
		_freeimage bottom&
		_freeimage top&
		_freeimage left&
		_freeimage right&
    END IF
    
    'always remember that we always do rendering stuffs in MODELVIEW &
    'projection stuff in PROJECTION view.
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity 'resets the matrix
    
    'set up are perspective.
    'If you want to know how it works, I suggest you to
    'visit this - https://learnopengl.com/#!Getting-started/Coordinate-Systems
    _gluPerspective ZoomValue, aspect#, 1.0, 100.0
    
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity 'resets the matrix
	

    'Syntax for gluLookAt
    'gluLookAt eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ
    'eyeX, eyeY, eyeZ refers to position of your eye/camera in 3D Space.
    'centerX, centerY, centerZ refers to the point where your camera/eye
    'is looking at in 3D space. Below, we are looking at 0,0,-1.
    'upX, upY, upZ refers to the up point of the world. We usually set it to
    '0,1,0 to define the up point of the world.
    'for more info, visit - https://learnopengl.com/#!Getting-started/Camera
    
	'gluLookAt COS(clock#) * 10, COS(clock#) * 4, SIN(clock#) * 10, 0, 0, -1, 0, 1, 0
	gluLookAt sin(clock#)*10,cos(clock#)*5,cos(clock#)*10, Front.x, Front.y, Front.z, 0,1,0
	
	GLH_Select_Texture back_tex&

    '_glTexParameteri sets the different attribute/properties of our texture.
    'syntax - _glTexParameteri mode, property_name, property_value.
    'https://learnopengl.com/#!Getting-started/Textures
    'It is better explain on the above ^^ link. :)

    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
	
	_glBegin _GL_QUADS
	_glTexCoord2f 0.0, 0.0
	_glVertex3f -10, 10, 10
	_glTexCoord2f 1.0, 0.0
	_glVertex3f 10,10,10
	_glTexCoord2f 1.0, 1.0
	_glVertex3f 10,-10,10
	_glTexCoord2f 0.0, 1.0
	_glVertex3f -10,-10,10
	_glEnd
	
	GLH_Select_Texture right_tex&
    
	_glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
	
	_glBegin _GL_QUADS
	_glTexCoord2f 0.0, 0.0
	_glVertex3f 10, 10, 10
	_glTexCoord2f 1.0, 0.0
	_glVertex3f 10,10,-10
	_glTexCoord2f 1.0, 1.0
	_glVertex3f 10,-10,-10
	_glTexCoord2f 0.0, 1.0
	_glVertex3f 10,-10,10
	_glEnd
	
	GLH_Select_Texture left_tex&
	
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
	
	_glBegin _GL_QUADS
	_glTexCoord2f 1.0, 0.0
	_glVertex3f -10, 10, 10
	_glTexCoord2f 0.0, 0.0
	_glVertex3f -10,10,-10
	_glTexCoord2f 0.0, 1.0
	_glVertex3f -10,-10,-10
	_glTexCoord2f 1.0, 1.0
	_glVertex3f -10,-10,10
	_glEnd
	
	GLH_Select_Texture front_tex&


    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
	
	_glBegin _GL_QUADS
	_glTexCoord2f 1.0, 0.0
	_glVertex3f -10, 10, -10
	_glTexCoord2f 0.0, 0.0
	_glVertex3f 10,10,-10
	_glTexCoord2f 0.0, 1.0
	_glVertex3f 10,-10,-10
	_glTexCoord2f 1.0, 1.0
	_glVertex3f -10,-10,-10
	_glEnd
	
	GLH_Select_Texture top_tex&
	

    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
	
	_glBegin _GL_QUADS
	_glTexCoord2f 0.0, 0.0
	_glVertex3f -10, 10, -10
	_glTexCoord2f 1.0, 0.0
	_glVertex3f 10,10,-10
	_glTexCoord2f 1.0, 1.0
	_glVertex3f 10,10,10
	_glTexCoord2f 0.0, 1.0
	_glVertex3f -10,10,10
	_glEnd
	
	
	GLH_Select_Texture bottom_tex&
	
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
	
	_glBegin _GL_QUADS
	_glTexCoord2f 0.0, 1.0
	_glVertex3f -10, -10, -10
	_glTexCoord2f 1.0, 1.0
	_glVertex3f 10,-10,-10
	_glTexCoord2f 1.0, 0.0
	_glVertex3f 10,-10,10
	_glTexCoord2f 0.0, 0.0
	_glVertex3f -10,-10,10
	_glEnd
	
    'select our texture.
    GLH_Select_Texture tex&
	
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR

	
    FOR j = 1 TO UBOUND(cubePositions)
        'we will save the current matrix.
        _glPushMatrix
        'translate the position to cube location.
        _glTranslatef cubePositions(j).pos.x, cubePositions(j).pos.y, cubePositions(j).pos.z
        'we have already set the angle for each vector.
        _glRotatef 60, cubePositions(j).ang.x, cubePositions(j).ang.y, cubePositions(j).ang.z

        'begin the triangles.
        _glBegin _GL_TRIANGLES
        FOR i = 1 TO 36
            'our texture coordinates. Most of the people don't know
            'how texture coordinates work. But, don't worry, it is
            'explained very nicely here - https://learnopengl.com/#!Getting-started/Textures
            _glTexCoord2f cubeData(i).texCoord.x, cubeData(i).texCoord.y
            'our vertex coordinates
            _glVertex3f cubeData(i).v.x, cubeData(i).v.y, cubeData(i).v.z
        NEXT
        _glEnd
        
        _glPopMatrix 'load the current last matrix
    NEXT
    
    _glFlush 'save the current drawing matrix
    
    'ah... It is just a floating point variable, which increases
    'every time GL is called. Used by Camera ;).
    clock# = clock# + .01
END SUB


'function taken from p5js.bas
FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION

'Calculate minimum value between two values
FUNCTION min! (a!, b!)
    IF a! < b! THEN min! = a! ELSE min! = b!
END FUNCTION

'Calculate maximum value between two values
FUNCTION max! (a!, b!)
    IF a! > b! THEN max! = a! ELSE max! = b!
END FUNCTION

'Constrain a value between a minimum and maximum value.
FUNCTION constrain! (n!, low!, high!)
    constrain! = max(min(n!, high!), low!)
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
