'OpenGL context capture example
'by Ashish Kushwaha

_TITLE "Hit *Space* to capture GL context and 'c' to clear software screen"
SCREEN _NEWIMAGE(600, 600, 32)

DIM SHARED glAllow AS _BYTE
DIM SHARED GL_Color_Buffer~%%(_WIDTH * _HEIGHT * 3)
DIM SHARED keyHit AS LONG

DIM SHARED GL_Context&, buffer_done
buffer_done = 0
'CLS
_GLRENDER _BEHIND
glAllow = -1
DO
    keyHit = _KEYHIT
    IF keyHit = ASC("c") THEN CLS , 1
    IF buffer_done THEN
        _CLEARCOLOR _RGB(0, 0, 0), GL_Context&
        _PUTIMAGE , GL_Context&
        _FREEIMAGE GL_Context&
        buffer_done = 0
    END IF
    _DISPLAY
    _LIMIT 30
LOOP


SUB _GL ()
    STATIC fps AS LONG
    IF NOT glAllow THEN EXIT SUB

    _glDisable _GL_MULTISAMPLE

    _glViewport 0, 0, _WIDTH, _HEIGHT

    _glClearColor 0, 0, 0, 1
    _glClear _GL_COLOR_BUFFER_BIT

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    _glRotatef fps, 0, 0, 1

    _glBegin _GL_TRIANGLES

    _glColor3f 1, 0, 0
    _glVertex2f 0, 1
    _glColor3f 0, 1, 0
    _glVertex2f -1, -1
    _glColor3f 0, 0, 1
    _glVertex2f 1, -1
    _glEnd

    IF keyHit = ASC(" ") AND NOT buffer_done THEN GL_Context& = getOpenGLContextImage: buffer_done = 1

    _glFlush

    fps = fps + 1
END SUB

FUNCTION getOpenGLContextImage& ()
    'storing GL Color Buffer in our  GL_Color_Buffer() array
    _glReadBuffer _GL_BACK
    _glPixelStorei _GL_UNPACK_ALIGNMENT, 1
    _glReadPixels 0, 0, _WIDTH, _HEIGHT, _GL_RGB, _GL_UNSIGNED_BYTE, _OFFSET(GL_Color_Buffer~%%())

    $CHECKING:OFF
    getOpenGLContextImage& = _NEWIMAGE(_WIDTH, _HEIGHT, 32) 'create an image handle
    DIM m AS _MEM
    m = _MEMIMAGE(getOpenGLContextImage&) 'store it in memory
    i& = 0
    FOR y = _HEIGHT(getOpenGLContextImage&) - 1 TO 0 STEP -1
        FOR x = 0 TO _WIDTH(getOpenGLContextImage&) - 1
            index& = 4 * (x + y * _WIDTH(getOpenGLContextImage&))
            _MEMPUT m, m.OFFSET + index&, GL_Color_Buffer~%%(i& + 2) AS _UNSIGNED _BYTE 'blue
            _MEMPUT m, m.OFFSET + index& + 1, GL_Color_Buffer~%%(i& + 1) AS _UNSIGNED _BYTE 'green
            _MEMPUT m, m.OFFSET + index& + 2, GL_Color_Buffer~%%(i&) AS _UNSIGNED _BYTE 'red
            _MEMPUT m, m.OFFSET + index& + 3, 255 AS _UNSIGNED _BYTE 'alpha
            i& = i& + 3
    NEXT x, y
    _MEMFREE m
    $CHECKING:ON
END FUNCTION

