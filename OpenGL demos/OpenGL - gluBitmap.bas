DO: _LIMIT 25: LOOP
SUB _GL

' GLubyte bitmap[24]={                      //bitmap size 10 x 12 pixels
DIM bitmap(24) AS _UNSIGNED _BYTE
RESTORE value
'--------------------------------- Glubyte QB64 method --------------------------------
FOR LoadArray = 0 TO 23
    READ value$
    hexadecimal$ = "&H" + RIGHT$(value$, 2)
    bitmap(LoadArray) = VAL(hexadecimal$)
NEXT
value:
DATA 0xc0,0x00,0xc0,0x00,0xc0,0x00,0xc0,0x00 '// begin is in left down corner              SEE TO LINE 47 HOW TO WRITE CORRECTLY THIS ARRAY FOR USE WITH _OFFSET!!!! (last parameter for _glBitmap)
DATA 0xc0,0x00,0xff,0x00,0xff,0x00,0xc0,0x00
DATA 0xc0,0x00,0xc0,0x00,0xff,0xc0,0xff,0xc0
'--------------------------------- Glubyte end -----------------------------------------



_glPixelStorei _GL_UNPACK_ALIGNMENT, 1 '      // every pixel sort to bytes
_glClearColor 0.0F, 0.0F, 0.0F, 0.0F '       // background color





_glViewport 0, 0, _DESKTOPWIDTH, _DESKTOPHEIGHT '                    // you see complete window
_glMatrixMode _GL_PROJECTION '               // modification matrix begin
_glLoadIdentity '                          //  clear matrix (create identity)
_glOrtho 0, _DESKTOPWIDTH, 0, _DESKTOPHEIGHT, -1, 1 '


_glClear _GL_COLOR_BUFFER_BIT '              // clear all colors in color buffer

_glBegin _GL_TRIANGLES '                      // draw RGB triangle in background
_glColor3f 1.0F, 0.0F, 0.0F
_glVertex2i 0, 0
_glColor3f 0.0F, 1.0F, 0.0F
_glVertex2i 400, 0
_glColor3f 0.0F, 0.0F, 1.0F
_glVertex2i 200, 300
_glEnd

_glColor3f 1.0F, 1.0F, 1.0F '                // white color for first bitmap
_glRasterPos2i 200, 200 '                    // position for first bitmap
_glBitmap 10, 12, 0.0F, 0.0F, 0.0F, 0.0F, _OFFSET(bitmap()) '// draw bitmap

_glColor3f 0.0F, 0.0F, 0.5F '                // darkblue color for second bitmap
_glRasterPos2i 50, 10 '                      // position for second bitmap
_glBitmap 10, 12, 0.0F, 0.0F, 0.0F, 0.0F, _OFFSET(bitmap()) ' draw second bitmap

_glRasterPos2i 350, 10 '                     // ATTENTION, here is color set after glRasterPos2i(),
_glColor3f 0.5F, 0.0F, 0.0F '                // also color for next bitmap is the same as in previous case
_glBitmap 10, 12, 0.0F, 0.0F, 0.0F, 0.0F, _OFFSET(bitmap()) ' vykresleni bitmapy

_glFlush '                                  // create and draw all to screen

END SUB



