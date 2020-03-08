'Moving into the Matrix Rain
'By Ashish Kushwaha
'23 Jun, 2019
'
'Inspire by B+ Matrix Rain.
_TITLE "Moving into the Matrix Rain"

RANDOMIZE TIMER

SCREEN _NEWIMAGE(800, 600, 32)

TYPE matRain
    x AS SINGLE 'x location
    y AS SINGLE 'y location
    z AS SINGLE 'z location
    ay AS SINGLE 'rain velocity
    strData AS STRING 'string data of each matrix rain
END TYPE

Type location
	x as single
	y as single
	z as single
end type

DIM SHARED charImg(74) AS LONG, matRainWidth, matRainHeight 'ascii char from 48 to 122, i.e, total 75 type of chars
DIM SHARED glAllow AS _BYTE, matrixRain(300) AS matRain, matrixRainTex(74) AS LONG,mov
matRainWidth = _FONTWIDTH * 0.005
matRainHeight = _FONTHEIGHT * 0.005
CLS , _RGB32(255)
tmp& = _NEWIMAGE(_FONTWIDTH - 1, _FONTHEIGHT, 32)
FOR i = 0 TO 74
    charImg(i) = _NEWIMAGE(_FONTWIDTH * 5, _FONTHEIGHT * 5, 32)
    _DEST tmp&
    CLS , _RGBA(0, 0, 0, 0)
    COLOR _RGB32(0, 255, 0), 1
    _PRINTSTRING (0, 0), CHR$(i + 48)
    _DEST charImg(i)
    _PUTIMAGE , tmp&
    _DEST 0
NEXT


glAllow = -1
DO
    FOR i = 0 TO UBOUND(matrixRain)
        matrixRain(i).y = matrixRain(i).y - matrixRain(i).ay
        IF RND > 0.9 THEN
            d$ = ""
            FOR k = 1 TO LEN(matrixRain(i).strData)
                d$ = d$ + CHR$(48 + p5random(0, 74)) 'change the character of rain randomly by a chance of 10%
            NEXT
            matrixRain(i).strData = d$
        END IF
        matrixRain(i).z = matrixRain(i).z + 0.00566 'move into the rain
        IF matrixRain(i).z > 0.1 THEN 'when behind screen
            matrixRain(i).x = p5random(-2, 2)
            matrixRain(i).y = p5random(2, 3.7)
            matrixRain(i).z = map((i / UBOUND(matrixRain)), 0, 1, -8, -0.2)
            matrixRain(i).ay = p5random(0.006, 0.02)
        END IF
    NEXT
    _LIMIT 60
LOOP

SUB _GL ()
    STATIC glInit
    mov = mov + 0.01
    IF NOT glAllow THEN EXIT SUB

    IF glInit = 0 THEN
        glInit = 1

        FOR i = 0 TO UBOUND(matrixRainTex) 'create texture for each ascii character
            _glGenTextures 1, _OFFSET(matrixRainTex(i))

            DIM m AS _MEM
            m = _MEMIMAGE(charImg(i))

            _glBindTexture _GL_TEXTURE_2D, matrixRainTex(i)
            _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _WIDTH(charImg(i)), _HEIGHT(charImg(i)), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET

            _MEMFREE m

            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_NEAREST
            _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
            _FREEIMAGE charImg(i)
        NEXT

        FOR i = 0 TO UBOUND(matrixRain) 'initialization
            n = p5random(1, 15)
            FOR j = 1 TO n
                v$ = CHR$(p5random(48, 122))
                matrixRain(i).strData = matrixRain(i).strData + v$
            NEXT
            matrixRain(i).x = p5random(-2, 2)
            matrixRain(i).y = p5random(2, 3.7)
            matrixRain(i).z = map((i / UBOUND(matrixRain)), 0, 1, -8, -0.2)
            matrixRain(i).ay = p5random(0.006, 0.02)
        NEXT

        _glViewport 0, 0, _WIDTH, _HEIGHT
    END IF

    _glEnable _GL_BLEND 'enabling necessary stuff
    _glEnable _GL_DEPTH_TEST
    _glEnable _GL_TEXTURE_2D


    _glClearColor 0, 0, 0, 1
    _glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT


    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 60, _WIDTH / _HEIGHT, 0.01, 10.0

    _glRotatef SIN(mov) * 20, 1, 0, 0 'rotating x-axis a bit, just to get Depth effect.


    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    'rendering the rain
    FOR i = 0 TO UBOUND(matrixRain)
        n = LEN(matrixRain(i).strData)
        FOR j = 1 TO n
            ca$ = MID$(matrixRain(i).strData, j, 1)
            'selecting texture on the basis of ascii code.
            _glBindTexture _GL_TEXTURE_2D, matrixRainTex(ASC(ca$) - 48)
            _glBegin _GL_QUADS
            _glTexCoord2f 0, 1
            _glVertex3f matrixRain(i).x - matRainWidth, matrixRain(i).y - matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glTexCoord2f 0, 0
            _glVertex3f matrixRain(i).x - matRainWidth, matrixRain(i).y + matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glTexCoord2f 1, 0
            _glVertex3f matrixRain(i).x + matRainWidth, matrixRain(i).y + matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glTexCoord2f 1, 1
            _glVertex3f matrixRain(i).x + matRainWidth, matrixRain(i).y - matRainHeight + 2 * (j - 1) * matRainHeight, matrixRain(i).z
            _glEnd
        NEXT
    NEXT

    _glFlush
END SUB

'taken from p5js.bas
'https://bit.ly/p5jsbas
FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION


FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION



