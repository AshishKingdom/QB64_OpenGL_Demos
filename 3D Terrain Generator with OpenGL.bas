'Coded by Ashish

_TITLE "3D Terrain Generator with OpenGL"
SCREEN _NEWIMAGE(800, 700, 32)

DIM SHARED glAllow AS _BYTE
DIM SHARED cols, rows, scl
DIM SHARED width, height, startOffzz

width = 800
height = 700
scl = 20
cols = width / scl
rows = height / scl
DIM SHARED terrain(cols, rows * 2) AS SINGLE
FOR y = 0 TO rows * 2
    xoff = 0
    FOR x = 0 TO cols
        terrain(x, y) = map(noise(xoff, yoff, 0), 0, 1, -.2, .2)
        xoff = xoff + .2
    NEXT
    yoff = yoff + .2
NEXT
DIM SHARED c
glAllow = -1
DO
    'startOff = startOff + 1
    'IF startOff > rows - 1 THEN startOff = 1
    '_LIMIT 25
    _DISPLAY
LOOP

SUB _GL STATIC
    IF NOT glAllow THEN EXIT SUB
    _glClearColor 0, 0, 0, 1
    _glClear _GL_COLOR_BUFFER_BIT OR _GL_DEPTH_BUFFER_BIT


    _glRotatef 50, 1, 0, 0
    _glRotatef rotateZ, 0, 0, 1
    rotateZ = rotateZ + .25

    FOR y = 0 TO rows - 1
        _glBegin _GL_TRIANGLE_STRIP
        FOR x = 0 TO cols - 1
            k## = map(terrain(x, y + startOff), -.2, .2, 1, .3)
            _glColor3f k##, k##, k##
            _glVertex3f toGlX(x * scl), toGlY(y * scl), terrain(x, y + startOff)
            k## = map(terrain(x, y + startOff + 1), -.2, .2, 1, .3)
            _glColor3f k##, k##, k##
            _glVertex3f toGlX(x * scl), toGlY((y + 1) * scl), terrain(x, y + 1 + startOff)
            '_glVertex3f toGlX((x + 1) * scl), toGlY((y + 1) * scl), terrain(x + 1, y + 1)
            '_glVertex3f toGlX(x * scl), toGlY((y + 1) * scl), terrain(x, y + 1)
        NEXT
        _glEnd
    NEXT
    _glFlush
END SUB

FUNCTION toGlX## (x#)
    x# = (_WIDTH / 2) - x#
    toGlX## = map(x#, -(_WIDTH / 2), _WIDTH / 2, 1, -1)
END FUNCTION

FUNCTION toGlY## (y#)
    y# = (_HEIGHT / 2) - y#
    toGlY## = map(y#, -(_HEIGHT / 2), _HEIGHT / 2, -1, 1)
END FUNCTION

FUNCTION map## (value##, minRange##, maxRange##, newMinRange##, newMaxRange##)
    map## = ((value## - minRange##) / (maxRange## - minRange##)) * (newMaxRange## - newMinRange##) + newMinRange##
END FUNCTION

FUNCTION noise! (x AS SINGLE, y AS SINGLE, z AS SINGLE)
    STATIC p5NoiseSetup AS _BYTE
    STATIC perlin() AS SINGLE
    STATIC PERLIN_YWRAPB AS SINGLE, PERLIN_YWRAP AS SINGLE
    STATIC PERLIN_ZWRAPB AS SINGLE, PERLIN_ZWRAP AS SINGLE
    STATIC PERLIN_SIZE AS SINGLE, perlin_octaves AS SINGLE
    STATIC perlin_amp_falloff AS SINGLE

    IF NOT p5NoiseSetup THEN
        p5NoiseSetup = true

        PERLIN_YWRAPB = 4
        PERLIN_YWRAP = INT(1 * (2 ^ PERLIN_YWRAPB))
        PERLIN_ZWRAPB = 8
        PERLIN_ZWRAP = INT(1 * (2 ^ PERLIN_ZWRAPB))
        PERLIN_SIZE = 4095

        perlin_octaves = 4
        perlin_amp_falloff = 0.5

        REDIM perlin(PERLIN_SIZE + 1) AS SINGLE
        DIM i AS SINGLE
        FOR i = 0 TO PERLIN_SIZE + 1
            perlin(i) = RND
        NEXT
    END IF

    x = ABS(x)
    y = ABS(y)
    z = ABS(z)

    DIM xi AS SINGLE, yi AS SINGLE, zi AS SINGLE
    xi = INT(x)
    yi = INT(y)
    zi = INT(z)

    DIM xf AS SINGLE, yf AS SINGLE, zf AS SINGLE
    xf = x - xi
    yf = y - yi
    zf = z - zi

    DIM r AS SINGLE, ampl AS SINGLE, o AS SINGLE
    r = 0
    ampl = .5

    FOR o = 1 TO perlin_octaves
        DIM of AS SINGLE, rxf AS SINGLE
        DIM ryf AS SINGLE, n1 AS SINGLE, n2 AS SINGLE, n3 AS SINGLE
        of = xi + INT(yi * (2 ^ PERLIN_YWRAPB)) + INT(zi * (2 ^ PERLIN_ZWRAPB))

        rxf = 0.5 * (1.0 - COS(xf * _PI))
        ryf = 0.5 * (1.0 - COS(yf * _PI))

        n1 = perlin(of AND PERLIN_SIZE)
        n1 = n1 + rxf * (perlin((of + 1) AND PERLIN_SIZE) - n1)
        n2 = perlin((of + PERLIN_YWRAP) AND PERLIN_SIZE)
        n2 = n2 + rxf * (perlin((of + PERLIN_YWRAP + 1) AND PERLIN_SIZE) - n2)
        n1 = n1 + ryf * (n2 - n1)

        of = of + PERLIN_ZWRAP
        n2 = perlin(of AND PERLIN_SIZE)
        n2 = n2 + rxf * (perlin((of + 1) AND PERLIN_SIZE) - n2)
        n3 = perlin((of + PERLIN_YWRAP) AND PERLIN_SIZE)
        n3 = n3 + rxf * (perlin((of + PERLIN_YWRAP + 1) AND PERLIN_SIZE) - n3)
        n2 = n2 + ryf * (n3 - n2)

        n1 = n1 + (0.5 * (1.0 - COS(zf * _PI))) * (n2 - n1)

        r = r + n1 * ampl
        ampl = ampl * perlin_amp_falloff
        xi = INT(xi * (2 ^ 1))
        xf = xf * 2
        yi = INT(yi * (2 ^ 1))
        yf = yf * 2
        zi = INT(zi * (2 ^ 1))
        zf = zf * 2

        IF xf >= 1.0 THEN xi = xi + 1: xf = xf - 1
        IF yf >= 1.0 THEN yi = yi + 1: yf = yf - 1
        IF zf >= 1.0 THEN zi = zi + 1: zf = zf - 1
    NEXT
    noise! = r
END FUNCTION

