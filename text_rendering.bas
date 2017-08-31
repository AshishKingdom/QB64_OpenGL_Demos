'@Author: Petr Preclik
_TITLE "Glut Text Rendering"
$RESIZE:ON
'void glutStrokeCharacter(void *font, int character);

DECLARE LIBRARY
'    SUB glutStrokeCharacter (BYVAL font AS _UNSIGNED LONG, BYVAL character AS _UNSIGNED _BYTE)
    SUB glutSolidIcosahedron ()
    SUB gluOrtho2D (BYVAL left AS DOUBLE, BYVAL right AS DOUBLE, BYVAL bottom AS DOUBLE, BYVAL top AS DOUBLE)
    SUB gluLookAt (BYVAL eyeX AS DOUBLE, BYVAL eyeY AS DOUBLE, BYVAL eyeZ AS DOUBLE, BYVAL centerX AS DOUBLE, BYVAL centerY AS DOUBLE, BYVAL centerZ AS DOUBLE, BYVAL upX AS DOUBLE, BYVAL upY AS DOUBLE, BYVAL upZ AS DOUBLE)
END DECLARE

DECLARE LIBRARY "./text_rendering_helper"
    SUB GLoutput (BYVAL x AS DOUBLE, BYVAL y AS DOUBLE, text AS STRING)
END DECLARE

'CONST GLUT_STROKE_ROMAN = &H2F

'/* Copyright (c) Mark J. Kilgard, 1994. */

'/* This program is freely distributable without licensing fees
'   and is provided without guarantee or warrantee expressed or
'   implied. This program is -not- in the public domain. */

'/* blender renders two spinning icosahedrons (red and green).
'   The blending factors for the two icosahedrons vary sinusoidally
'   and slightly out of phase.  blender also renders two lines of
'   text in a stroke font: one line antialiased, the other not.  */

'#include <GL/glut.h>
'#include <stdio.h>
'#include <math.h>

DIM SHARED light0_ambient(3) AS SINGLE
light0_ambient(0) = 0.2: light0_ambient(1) = 0.2: light0_ambient(2) = 0.2: light0_ambient(3) = 1.0
DIM SHARED light0_diffuse(3) AS SINGLE
light0_diffuse(0) = 0.0: light0_diffuse(1) = 0.0: light0_diffuse(2) = 0.0: light0_diffuse(3) = 1.0
DIM SHARED light1_diffuse(3) AS SINGLE
light1_diffuse(0) = 1.0: light1_diffuse(1) = 0.0: light1_diffuse(2) = 0.0: light1_diffuse(3) = 1.0
DIM SHARED light1_position(3)
light1_position(0) = 1.0: light1_position(1) = 1.0: light1_position(2) = 1.0: light1_position(3) = 0.0
DIM SHARED light2_diffuse(3) AS SINGLE
light2_diffuse(0) = 0.0: light2_diffuse(1) = 1.0: light2_diffuse(2) = 0.0: light2_diffuse(3) = 1.0
DIM SHARED light2_position(3) AS SINGLE
light2_position(0) = -1.0: light2_position(1) = -1.0: light2_position(2) = 1.0: light2_position(3) = 0.0
DIM SHARED s, angle1, angle2, first
s = 0.0: angle1 = 0.0: angle2 = 0.0

'void
'output(GLfloat x, GLfloat y, char *text)
'{

DO WHILE _KEYHIT <> 27
LOOP


SUB _GL
IF first = 0 THEN
    main
    first = 1
END IF
main
idle
display




END SUB


'SUB GLoutput (x AS SINGLE, y AS SINGLE, text AS STRING)
'  char *p;
'
'_glPushMatrix
'_glTranslatef x, y, 0

'REDIM p(LEN(text$)) AS STRING
'FOR pc = 1 TO LEN(text$)
'    p(pc) = LEFT$(MID$(text$, pc), 1)
'    glutStrokeCharacter 1, 2 ' ASC(p(pc))
'NEXT pc




'_glPopMatrix

'END SUB





'void
'display(void)
SUB display

REDIM amb(3) AS SINGLE
amb(0) = 0.4: amb(1) = 0.4: amb(2) = 0.4: amb(3) = 0.0
REDIM dif(3)
dif(0) = 1.0: dif(1) = 1.0: dif(2) = 1.0: dif(3) = 0.0

_glClear _GL_COLOR_BUFFER_BIT: _glClear _GL_DEPTH_BUFFER_BIT
_glEnable _GL_LIGHT1
_glDisable _GL_LIGHT2
amb(3) = COS(s) / 2.0 + 0.5
dif(3) = COS(s) / 2.0 + 0.5


_glMaterialfv _GL_FRONT, _GL_AMBIENT, _OFFSET(amb())
_glMaterialfv _GL_FRONT, _GL_DIFFUSE, _OFFSET(dif())

_glPushMatrix
_glTranslatef -0.3, -0.3, 0.0
_glRotatef angle1, 1.0, 5.0, 0.0
_glCallList (1) '        /* render ico display list */
_glPopMatrix

_glClear _GL_DEPTH_BUFFER_BIT
_glEnable _GL_LIGHT2
_glDisable _GL_LIGHT1
amb(3) = dif(3)
amb(3) = 0.5 - COS(s * .95) / 2.0
dif(3) = 0.5 - COS(s * .95) / 2.0





_glMaterialfv _GL_FRONT, _GL_AMBIENT, _OFFSET(amb())
_glMaterialfv _GL_FRONT, _GL_DIFFUSE, _OFFSET(dif())

_glPushMatrix
_glTranslatef 0.3, 0.3, 0.0
_glRotatef angle2, 1.0, 0.0, 5.0
_glCallList (1) '        /* render ico display list */
_glPopMatrix

_glPushAttrib _GL_ENABLE_BIT
_glDisable _GL_DEPTH_TEST
_glDisable _GL_LIGHTING
_glMatrixMode _GL_PROJECTION
_glPushMatrix
_glLoadIdentity
gluOrtho2D 0, 1500, 0, 1500

_glMatrixMode _GL_MODELVIEW
_glPushMatrix
_glLoadIdentity
'  /* Rotate text slightly to help show jaggies. */
_glRotatef 14, 0.0, 0.0, 1.0

GLoutput 200, 225, "This is antialiased! :)." + CHR$(0) 'sub in this program
_glDisable _GL_LINE_SMOOTH
_glDisable _GL_BLEND
GLoutput 160, 100, "This text is not." + CHR$(0)
_glPopMatrix
_glMatrixMode _GL_PROJECTION
_glPopMatrix
_glPopAttrib
_glMatrixMode _GL_MODELVIEW

'  glutSwapBuffers();
END SUB

'void
'idle(void)
SUB idle

angle1 = angle1 + 0.8 MOD 360.0
angle2 = angle2 + 1.1 MOD 360.0
s = s + 0.05
'  glutPostRedisplay(); QB use own
END SUB

'void
'visible(int vis)
'{
'  if (vis == GLUT_VISIBLE)
'    glutIdleFunc(idle);
'  else
'    glutIdleFunc(NULL);
'}

'int
'main(int argc, char **argv)
SUB main

'  glutInit(&argc, argv);
'  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
'  glutCreateWindow("blender");
'  glutDisplayFunc(display);
' glutVisibilityFunc(visible);

_glNewList 1, _GL_COMPILE '  /* create ico display list */
glutSolidIcosahedron
_glEndList

_glEnable _GL_LIGHTING
_glEnable _GL_LIGHT0
_glLightfv _GL_LIGHT0, _GL_AMBIENT, _OFFSET(light0_ambient())
_glLightfv _GL_LIGHT0, _GL_DIFFUSE, _OFFSET(light0_diffuse())
_glLightfv _GL_LIGHT1, _GL_DIFFUSE, _OFFSET(light1_diffuse())
_glLightfv _GL_LIGHT1, _GL_POSITION, _OFFSET(light1_position())
_glLightfv _GL_LIGHT2, _GL_DIFFUSE, _OFFSET(light2_diffuse())
_glLightfv _GL_LIGHT2, _GL_POSITION, _OFFSET(light2_position())
_glEnable _GL_DEPTH_TEST
_glEnable _GL_CULL_FACE
_glEnable _GL_BLEND
_glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
_glEnable _GL_LINE_SMOOTH
_glLineWidth 2.0

_glMatrixMode _GL_PROJECTION
_gluPerspective 40.0, 1.0, 1.0, 10.0
_glMatrixMode _GL_MODELVIEW
gluLookAt 0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 '      /* up is in positive Y direction */
_glTranslatef 0.0, 0.6, -1.0
END SUB
