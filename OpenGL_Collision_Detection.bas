'@Author:Ashish Kushwaha
_TITLE "Move cursor on shape(s)."
randomize timer
SCREEN _NEWIMAGE(600, 600, 32)

DECLARE LIBRARY 'external function(s)
    SUB drawCube ALIAS glutSolidCube (BYVAL dsize AS DOUBLE)
	SUB gluPickMatrix (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL delX AS SINGLE, BYVAL delY AS SINGLE, viewport AS LONG)
END DECLARE

type vec3
	x as single
	y as single
	z as single
end type

type cube
	pos as vec3 'position
	col as vec3 'color
	rot as vec3 'rotation
end type

DIM SHARED mouseX, mouseY, gl, collision, obj_type
Dim shared cubes(10) as cube
DIM SHARED selectBuffer(4) AS _UNSIGNED LONG, hits&, viewport&(4)

for i = 0 to ubound(cubes)
	cubes(i).pos.x = p5random(-1 ,1)
	cubes(i).pos.y = p5random(-1, 1)
	cubes(i).pos.z = p5random(-0.8,0)
	cubes(i).col.x = rnd : cubes(i).col.y = rnd : cubes(i).col.z = rnd
	cubes(i).rot.x = p5random(0,360)
	cubes(i).rot.y = p5random(0,360)
	cubes(i).rot.z = p5random(0,360)
next

obj_type = 1
gl = -1
_GLRENDER _BEHIND
DO
    WHILE _MOUSEINPUT: WEND
    mouseX = _MOUSEX: mouseY = _MOUSEY
    IF _KEYHIT = ASC(" ") THEN
        IF obj_type = 1 THEN obj_type = 2 ELSE obj_type = 1
    END IF
    _LIMIT 40
    CLS , 1
    COLOR _RGB(255, 0, 0), 1
    IF hits& >= 1 THEN 
		collision = selectBuffer(3)
		? collision, hits&
	ELSE 
		collision = 0
		erase selectBuffer
	end if
LOOP

SUB _GL ()
	static buffer(4) as _unsigned long, tmp

    IF gl = 0 THEN EXIT SUB


    _glEnable _GL_LIGHTING
    _glEnable _GL_LIGHT0
    _glEnable _GL_DEPTH_TEST
    _glEnable _GL_COLOR_MATERIAL

    _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec4(0.1, 0.1, 0.1, 0)
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec4(0.8, 0.8, 0.8, 0)
    _glLightfv _GL_LIGHT0, _GL_POSITION, glVec4(1, 1, 0, 0)


    _glGetIntegerv _GL_VIEWPORT, _OFFSET(viewport&())

    _glSelectBuffer 4, _OFFSET(buffer())
    dummy = _glRenderMode(_GL_SELECT)
    _glInitNames
    _glPushName 0

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity

	_glPushMatrix

    gluPickMatrix mouseX, _HEIGHT - mouseY, 1,1, viewport&()

	for i = 0 to ubound(cubes)
		_glLoadName (i+1)
		_glPushMatrix
		_glcolor3f cubes(i).col.x,cubes(i).col.y,cubes(i).col.z
		_glrotatef cubes(i).rot.x+tmp,1,0,0
		_glrotatef cubes(i).rot.y+tmp,0,1,0
		_glrotatef cubes(i).rot.z,0,0,1
		_gltranslatef cubes(i).pos.x,cubes(i).pos.y,cubes(i).pos.z
		drawCube 0.22
		_glPopMatrix
	next

	_glPopMatrix

    hits& = _glRenderMode(_GL_RENDER)
	selectBuffer(3) = buffer(3)

    _glMatrixMode _GL_MODELVIEW
	
	for i = 0 to ubound(cubes)
		_glPushMatrix
		if collision = (i+1) then _glColor3f 1,0.5,0 else _glcolor3f cubes(i).col.x,cubes(i).col.y,cubes(i).col.z
		_glrotatef cubes(i).rot.x+tmp,1,0,0
		_glrotatef cubes(i).rot.y+tmp,0,1,0
		_glrotatef cubes(i).rot.z,0,0,1
		_gltranslatef cubes(i).pos.x,cubes(i).pos.y,cubes(i).pos.z
		drawCube 0.22
		_glPopMatrix
	next
	
    _glFlush
    
	tmp=tmp+1
END SUB

FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION

FUNCTION glVec4%& (x, y, z, w)
    STATIC internal_vec4(3)
    internal_vec4(0) = x
    internal_vec4(1) = y
    internal_vec4(2) = z
    internal_vec4(3) = w
    glVec4%& = _OFFSET(internal_vec4())
END FUNCTION

