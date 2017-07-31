'#########################
'     Music Maker
'  Coded By Ashish Kushwaha
'#########################
'Inspired from http://g.co/doodle/nxznt7
'All the rendering is done via OpenGL, leaving mini-map.
_TITLE "Oskar Fischinger's Doodle"

SCREEN _NEWIMAGE(600, 600, 32)
DO: LOOP UNTIL _SCREENEXISTS

TYPE vector
    x AS DOUBLE
    y AS DOUBLE
    z AS DOUBLE
END TYPE

TYPE ripple
    pos AS vector
    size AS SINGLE
    speed AS SINGLE
    limit AS SINGLE
END TYPE

TYPE diamonds
    pos AS vector
    active AS _BYTE
    powered AS _BYTE
    frequency AS INTEGER
END TYPE

TYPE bubbles
    pos AS vector
    size AS SINGLE
    r AS SINGLE
    b AS SINGLE
    g AS SINGLE
    limit AS SINGLE
    vel AS vector
    active AS _BYTE
END TYPE

DIM SHARED glAllow AS _BYTE
DIM SHARED rippleWave(51) AS ripple, rippleWaveLocations(5) AS vector
DIM SHARED diamond(170) AS diamonds, bubble(30) AS bubbles
DIM SHARED dataMap&

dataMap& = _NEWIMAGE(80, 80, 32)
_DEST dataMap&
CLS
_DEST 0

RANDOMIZE TIMER
v = 1
rippleWaveLocations(1).x = 50
rippleWaveLocations(1).y = 50

rippleWaveLocations(2).x = _WIDTH - 50
rippleWaveLocations(2).y = 50

rippleWaveLocations(3).x = _WIDTH - 50
rippleWaveLocations(3).y = _HEIGHT - 50

rippleWaveLocations(4).x = 0
rippleWaveLocations(4).y = _HEIGHT - 50

rippleWaveLocations(5).x = _WIDTH / 2
rippleWaveLocations(5).y = _HEIGHT / 2

FOR i = 1 TO UBOUND(rippleWaveLocations)
    rippleWaveLocations(i).z = p5random(150, 240) 'used as radius for ripple
    FOR j = v TO v + 10
        rippleWave(j).pos.x = rippleWaveLocations(i).x
        rippleWave(j).pos.y = rippleWaveLocations(i).y
        rippleWave(j).limit = rippleWaveLocations(i).z
        rippleWave(j).size = map(j, v, v + 10, 0, rippleWave(j).limit)
        rippleWave(j).speed = .5
    NEXT
    v = v + 10
NEXT
v = 1
FOR x = 120 TO _WIDTH - 120 STEP 30
    FOR y = 120 TO _HEIGHT - 120 STEP 30
        diamond(v).pos.x = x
        diamond(v).pos.y = y
        diamond(v).active = 0 'false
        diamond(v).frequency = map(y, 120, _HEIGHT - 120, 300, 800)
        v = v + 1
    NEXT
NEXT

COLOR _RGB(255, 255, 255)
totalColumns = 13
column = 1
activateColumn column

_GLRENDER _BEHIND


mapHasUpdated = -1
_SETALPHA 150, , dataMap&
glAllow = -1

tt## = TIMER

DO
    WHILE _MOUSEINPUT: WEND
    mouseX = _MOUSEX
    mouseY = _MOUSEY
    IF _MOUSEBUTTON(1) THEN
        WHILE _MOUSEBUTTON(1)
            WHILE _MOUSEINPUT: WEND
        WEND
        mouseClick = -1
    ELSE
        mouseClick = 0
    END IF
   
    FOR i = 1 TO UBOUND(diamond)
        IF mouseX > diamond(i).pos.x - 10 AND mouseY > diamond(i).pos.y - 10 AND mouseX < diamond(i).pos.x + 10 AND mouseY < diamond(i).pos.y + 10 AND mouseClick THEN
            IF diamond(i).active THEN
                diamond(i).active = 0
                ' dx = map(diamond(i).pos.x, 120, _width-120,4,76)
                ' dy = map(diamond(i).pos.y, 120, _height-120,4,76)
                _DEST dataMap&
                CLS , 1
                LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, 150), BF
                FOR j = 1 TO UBOUND(diamond)
                    IF diamond(j).active THEN
                        dx = map(diamond(j).pos.x, 120, _WIDTH(0) - 120, 4, 76)
                        dy = map(diamond(j).pos.y, 120, _HEIGHT(0) - 120, 4, 76)
                        LINE (dx - 2, dy - 2)-STEP(4, 4), _RGB(200, 255, 255), BF
                    END IF
                NEXT
                _DEST 0
                '_setalpha 150,,dataMap&
                mapHasUpdated = -1
            ELSE
                dx = map(diamond(i).pos.x, 120, _WIDTH - 120, 4, 76)
                dy = map(diamond(i).pos.y, 120, _HEIGHT - 120, 4, 76)
                _DEST dataMap&
                LINE (dx - 2, dy - 2)-STEP(4, 4), _RGB(200, 255, 255), BF
                _DEST 0
                diamond(i).active = -1
                mapHasUpdated = -1
            END IF
        END IF
    NEXT
   
    IF TIMER - tt## > .4 THEN
        column = column + 1
        IF column > 13 THEN column = 1
        activateColumn column
        tt## = TIMER
        mapHasUpdated = -1
    END IF
   
    IF mapHasUpdated THEN
        mapHasUpdated = 0
        CLS , 1
        x = map((column - 1) * 30 + 120, 120, _WIDTH - 120, 4, 76)
        LINE (_WIDTH / 2 - 20 + x - 2, 0)-STEP(4, 79), _RGB(200, 200, 200), BF
        _PUTIMAGE (_WIDTH / 2 - 20, 0), dataMap&
        IF specialEffectDone THEN _DISPLAY
    END IF
   
    IF NOT specialEffectDone THEN
        IF ringSize > 400 THEN specialEffectDone = -1
        CLS , 1
        CIRCLE (300, 300), ringSize, _RGB(0, 0, 0)
        PAINT (0, 599), _RGB(0, 0, 0), _RGB(0, 0, 0)
        PAINT (0, 0), _RGB(0, 0, 0), _RGB(0, 0, 0)
        PAINT (599, 599), _RGB(0, 0, 0), _RGB(0, 0, 0)
        PAINT (599, 0), _RGB(0, 0, 0), _RGB(0, 0, 0)
        _DISPLAY
        ringSize = ringSize + 1.5
    END IF
    IF specialEffectDone THEN _LIMIT 30
LOOP UNTIL _MOUSEBUTTON(2)
CLS
PRINT "Thanks for using me! :)"

SUB activateColumn (which%)
    last% = which% - 1
    IF last% = 0 THEN last% = 13
    FOR i = 1 TO UBOUND(diamond)
        IF diamond(i).pos.x = (which% - 1) * 30 + 120 THEN
            diamond(i).powered = -1
            IF diamond(i).active THEN addBubble diamond(i).pos: SOUND diamond(i).frequency, 2
        END IF
        IF diamond(i).pos.x = (last% - 1) * 30 + 120 THEN
            diamond(i).powered = 0
        END IF
    NEXT
END SUB

SUB addBubble (position AS vector)
    FOR i = 0 TO UBOUND(bubble)
        IF NOT bubble(i).active THEN
            bubble(i).pos.x = position.x
            bubble(i).pos.y = position.y
            bubble(i).size = 0
            bubble(i).active = -1 'true
            bubble(i).r = p5random(80, 200)
            bubble(i).g = p5random(80, 200)
            bubble(i).b = p5random(80, 200)
            bubble(i).limit = p5random(60, 100)
            bubble(i).vel.x = p5random(-3, 3)
            bubble(i).vel.y = p5random(-3, 3)
            EXIT SUB
        END IF
    NEXT
END SUB

SUB _GL () STATIC
    IF NOT glAllow THEN EXIT SUB
   
    IF NOT glInit THEN
        glInit = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT
        clock_step# = .005
        clock# = .1
    END IF
    _glEnable _GL_BLEND
   
    _glClearColor 0, clock# * 0.75, clock# * .55, 1
    _glClear _GL_COLOR_BUFFER_BIT
    FOR i = 1 TO UBOUND(rippleWave)
        _glColor4f 1, 1, 1, map(rippleWave(i).size, 0, rippleWave(i).limit, 1, 0)
        _glBegin _GL_LINE_LOOP
        FOR n = 0 TO _PI(2) STEP .01
            _glVertex2f normalizeX(rippleWave(i).pos.x + rippleWave(i).size * COS(n)), normalizeY(rippleWave(i).pos.y + rippleWave(i).size * SIN(n))
        NEXT
        _glEnd
        rippleWave(i).size = rippleWave(i).size + rippleWave(i).speed
        IF rippleWave(i).size > rippleWave(i).limit + 20 THEN rippleWave(i).size = 0
    NEXT
   
    FOR i = 1 TO UBOUND(diamond) - 1
        _glColor3f .7, .9, 1.0
        IF diamond(i).active THEN
            _glBegin _GL_TRIANGLE_FAN
            _glVertex2f normalizeX(diamond(i).pos.x), normalizeY(diamond(i).pos.y - 10)
            _glVertex2f normalizeX(diamond(i).pos.x + 10), normalizeY(diamond(i).pos.y)
            _glVertex2f normalizeX(diamond(i).pos.x), normalizeY(diamond(i).pos.y + 10)
            _glVertex2f normalizeX(diamond(i).pos.x - 10), normalizeY(diamond(i).pos.y)
            _glEnd
        ELSE
            _glBegin _GL_LINE_LOOP
            _glVertex2f normalizeX(diamond(i).pos.x), normalizeY(diamond(i).pos.y - 10)
            _glVertex2f normalizeX(diamond(i).pos.x + 10), normalizeY(diamond(i).pos.y)
            _glVertex2f normalizeX(diamond(i).pos.x), normalizeY(diamond(i).pos.y + 10)
            _glVertex2f normalizeX(diamond(i).pos.x - 10), normalizeY(diamond(i).pos.y)
            _glEnd
        END IF
    NEXT
   
    FOR i = 1 TO UBOUND(diamond) - 2
        IF diamond(i).powered THEN
            FOR n = 1 TO 6
                _glColor4f .7, .9, 1.0, map(n, 1, 6, 1, 0)
                _glBegin _GL_LINES
                _glVertex2f normalizeX(diamond(i).pos.x + n), normalizeY(diamond(i).pos.y - 10 - n)
                _glVertex2f normalizeX(diamond(i).pos.x + 10 + n), normalizeY(diamond(i).pos.y - n)
                _glEnd
               
                _glBegin _GL_LINES
                _glVertex2f normalizeX(diamond(i).pos.x + 10 + n), normalizeY(diamond(i).pos.y + n)
                _glVertex2f normalizeX(diamond(i).pos.x + n), normalizeY(diamond(i).pos.y + 10 + n)
                _glEnd
               
                _glBegin _GL_LINES
                _glVertex2f normalizeX(diamond(i).pos.x - n), normalizeY(diamond(i).pos.y + 10 + n)
                _glVertex2f normalizeX(diamond(i).pos.x - n - 10), normalizeY(diamond(i).pos.y + n)
                _glEnd
               
                _glBegin _GL_LINES
                _glVertex2f normalizeX(diamond(i).pos.x - n - 10), normalizeY(diamond(i).pos.y - n)
                _glVertex2f normalizeX(diamond(i).pos.x - n), normalizeY(diamond(i).pos.y - 10 - n)
                _glEnd
            NEXT
        END IF
    NEXT
   
    FOR i = 0 TO UBOUND(bubble)
        IF bubble(i).active THEN
            _glColor4f normalizeC(bubble(i).r), normalizeC(bubble(i).g), normalizeC(bubble(i).b), map(bubble(i).size, 0, bubble(i).limit, 1, 0)
           
            _glBegin _GL_TRIANGLE_FAN
            FOR n = 0 TO _PI(2) STEP .01
                _glVertex2f normalizeX(bubble(i).pos.x + bubble(i).size * COS(n)), normalizeY(bubble(i).pos.y + bubble(i).size * SIN(n))
            NEXT
            _glEnd
           
            bubble(i).size = bubble(i).size + 1
            bubble(i).pos.x = bubble(i).pos.x + bubble(i).vel.x
            bubble(i).pos.y = bubble(i).pos.y + bubble(i).vel.y
            IF bubble(i).size > bubble(i).limit + 20 THEN bubble(i).active = 0
        END IF
    NEXT
   
    _glFlush
   
    clock# = clock# + clock_step#
    IF clock# < .1 OR clock# > 1 THEN clock_step# = clock_step# * -1
    fpsRate = fpsRate + 1
END SUB













FUNCTION normalizeX# (x#)
    normalizeX# = map(x#, 0, _WIDTH, -1, 1)
END FUNCTION

FUNCTION normalizeY# (y#)
    normalizeY# = map(y#, 0, _WIDTH, 1, -1)
END FUNCTION

FUNCTION normalizeC# (c!)
    normalizeC# = map(c!, 0, 255, 0, 1)
END FUNCTION

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

FUNCTION p5random! (mn!, mx!)
    IF mn! > mx! THEN
        SWAP mn!, mx!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION