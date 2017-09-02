_TITLE "Spot Lights"
SCREEN _NEWIMAGE(800, 600, 32)
DO: LOOP UNTIL _SCREENEXISTS

DIM SHARED glAllow

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
    SUB glutSolidSphere (BYVAL radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stack AS LONG)
END DECLARE

TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

DIM SHARED redLight AS vec3, greenLight AS vec3, blueLight AS vec3

glAllow = -1


DO
    _LIMIT 40
LOOP UNTIL INKEY$ = CHR$(27)


SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB 'we are not ready yet
    'setup
    IF NOT glSetup THEN
        _glViewport 0, 0, _WIDTH, _HEIGHT
        aspect# = _WIDTH / _HEIGHT
        glSetup = -1
		spot_cutoff = 60
    END IF

    _glEnable _GL_DEPTH_TEST

    'enable lights
    _glEnable _GL_LIGHTING
    'red light
    _glEnable _GL_LIGHT0
    _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec3(.2, 0, 0)
    _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec3(.8, 0, 0)
    _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec3(.4, 0, 0)
    _glLightfv _GL_LIGHT0, _GL_SPOT_CUTOFF, glVec1(30)
    _glLightfv _GL_LIGHT0, _GL_SPOT_EXPONENT, glVec1(120)
    _glLightfv _GL_LIGHT0, _GL_SPOT_DIRECTION, glVec3(0, 0, -1)
    _glLightfv _GL_LIGHT0, _GL_POSITION, glVec4(redLight.x, redLight.y, redLight.z, 1.0)

    'green light
    _glEnable _GL_LIGHT1
    _glLightfv _GL_LIGHT1, _GL_AMBIENT, glVec3(0, .2, 0)
    _glLightfv _GL_LIGHT1, _GL_DIFFUSE, glVec3(0, .8, 0)
    _glLightfv _GL_LIGHT1, _GL_SPECULAR, glVec3(0, .4, 0)
    _glLightfv _GL_LIGHT1, _GL_SPOT_CUTOFF, glVec1(30)
    _glLightfv _GL_LIGHT1, _GL_SPOT_EXPONENT, glVec1(120)
    _glLightfv _GL_LIGHT1, _GL_SPOT_DIRECTION, glVec3(0, 0, -1)
	_glLightfv _GL_LIGHT1, _GL_POSITION, glVec4(greenLight.x, greenLight.y, greenLight.z, 1.0)

    'blue light
    _glEnable _GL_LIGHT2
    _glLightfv _GL_LIGHT2, _GL_AMBIENT, glVec3(0, 0, .2)
    _glLightfv _GL_LIGHT2, _GL_DIFFUSE, glVec3(0, 0, .8)
    _glLightfv _GL_LIGHT2, _GL_SPECULAR, glVec3(0, 0, .4)
    _glLightfv _GL_LIGHT2, _GL_SPOT_CUTOFF, glVec1(30)
    _glLightfv _GL_LIGHT2, _GL_SPOT_EXPONENT, glVec1(120)
    _glLightfv _GL_LIGHT2, _GL_SPOT_DIRECTION, glVec3(0, 0, -1)
	_glLightfv _GL_LIGHT2, _GL_POSITION, glVec4(blueLight.x, blueLight.y, blueLight.z, 1.0)
	
	_glShadeModel _GL_SMOOTH


    _glClear _GL_COLOR_BUFFER_BIT

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity

    _gluPerspective 45.0, aspect#, 1.0, 1000.0

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity


    gluLookAt 0, -1, 2.5, 0, 0, 0, 0, 1, 0

    _glColor3f 1, 1, 1
	'Let's define the material to use.
	_glMaterialfv _GL_FRONT_AND_BACK, _GL_AMBIENT, glVec3(.2,.2,.2)
	_glMaterialfv _GL_FRONT_AND_BACK, _GL_DIFFUSE, glVec3(.8,.8,.8)
	_glMaterialfv _GL_FRONT_AND_BACK, _GL_SPECULAR, glVec3(.4,.4,.4)
	_glMaterialfv _GL_FRONT_AND_BACK, _GL_SPECULAR, glVec3(.4,.4,.4)
	
    drawPlane 2,2
    drawLights redLight, 1,0,0
	drawLights greenLight, 0,1,0
	drawLights blueLight, 0,0,1
	

    _glFlush
	
	'updating the position of light in circular/eclipse motion.
    redLight.x = COS(clock#) * .5
    redLight.y = SIN(clock#) * .5
    redLight.z = 1
	greenLight.x = COS(clock#)*1.2
	greenLight.y = sin(clock#)*.5
	greenLight.z = 1
	blueLight.x = cos(clock#)*.5
	blueLight.y = sin(clock#)*1.2
	blueLight.z = 1
    clock# = clock# + .01
END SUB

FUNCTION glVec1%& (x)
    STATIC internal_vec1
    internal_vec1 = x
    glVec1%& = _OFFSET(internal_vec1)
END FUNCTION

FUNCTION glVec2%& (x, y)
    STATIC internal_vec2(2)
    internal_vec2(0) = x
    internal_vec2(1) = y
    glVec2%& = _OFFSET(internal_vec2())
END FUNCTION

FUNCTION glVec3%& (x, y, z)
    STATIC internal_vec3(2)
    internal_vec3(0) = x
    internal_vec3(1) = y
    internal_vec3(2) = z
    glVec3%& = _OFFSET(internal_vec3())
END FUNCTION

FUNCTION glVec4%& (x, y, z, w)
    STATIC internal_vec4(3)
    internal_vec4(0) = x
    internal_vec4(1) = y
    internal_vec4(2) = z
    internal_vec4(3) = w
    glVec4%& = _OFFSET(internal_vec4())
END FUNCTION

SUB drawPlane (w, h)
    _glNormal3f 0,0,1
	for y = -h/2 to h/2 step .1
	    _glBegin _GL_TRIANGLE_STRIP
	    for x  = -w/2 to w/2 step .1
		    _glVertex2f x,y
			_glVertex2f x,y+.1
		next
		_glEnd
	next
END SUB

SUB drawLights (w AS vec3, r!, g!, b!)
    _glDisable _GL_LIGHTING
    _glPushMatrix
	_glColor3f r!, g!, b!
    _glTranslatef w.x, w.y, w.z
    glutSolidSphere .02, 10, 10
    _glPopMatrix
    _glEnable _GL_LIGHTING
END SUB
