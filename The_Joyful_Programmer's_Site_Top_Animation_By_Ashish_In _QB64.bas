_TITLE "The Joyful Programmer's Site Top Animation By Ashish In QB64"

SCREEN _NEWIMAGE(800, 400, 32)


DIM SHARED glAllow AS _BYTE
glAllow = -1

DO
    _LIMIT 40
LOOP

SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB

    _glViewport 0, 0, _WIDTH, _HEIGHT

    _glClearColor 0.211, 0.533, 0.854, 1
    _glClear _GL_COLOR_BUFFER_BIT


    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity


    FOR i = clock# TO _PI(2) + clock# STEP .3
        _glColor3f 0.117, 0.482, 0.847
        _glBegin _GL_TRIANGLES
        _glVertex2f 0, -1
        _glVertex2f COS(i) * 3, SIN(i) * 3 - 1
        _glVertex2f COS(i + .15) * 3, SIN(i + .15) * 3 - 1
        _glEnd
    NEXT

    clock# = clock# - .01
END SUB