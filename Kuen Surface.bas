'@Author:Ashish Kushwaha
_TITLE "Kuen Surface"
'http://paulbourke.net/geometry/kuen/
SCREEN _NEWIMAGE(700, 700, 32)

DECLARE LIBRARY
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE


TYPE vec3
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
END TYPE

TYPE vec4
    x AS _FLOAT
    y AS _FLOAT
    z AS _FLOAT
    w AS _FLOAT
END TYPE


DO
    _LIMIT 40
LOOP

SUB _GL ()
    STATIC glInit, aspect#, v1 AS vec3, v2 AS vec3, v3 AS vec3, n AS vec3, v4 AS vec3
    STATIC clock#, kuen, kuenGenerated
    k = .024
    p = .05
    IF NOT glInit THEN
        glInit = -1
        aspect# = _WIDTH / _HEIGHT
        _glViewport 0, 0, _WIDTH, _HEIGHT
        kuen = _glGenLists(1)
    END IF

    _glEnable _GL_DEPTH_TEST

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 50.0, aspect#, 1.0, 100.0

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
    gluLookAt 0, 0, 5, 0, 0, 0, 0, 1, 0


    _glTranslatef 0, 0, 0
    _glRotatef clock# * 90, 1.5, 1, .5
    IF NOT kuenGenerated THEN
        _glNewList kuen, _GL_COMPILE
        _glBegin _GL_TRIANGLES
        FOR s = -4.5 + p TO 4.5 - p STEP p
            FOR t = k TO _PI - k STEP k
                v1.x = (2 * (COS(s) + SIN(s)) * SIN(t)) / (1 + s * s * SIN(t) * SIN(t))
                v1.y = (2 * (SIN(s) - s * COS(s)) * SIN(t)) / (1 + s * s * SIN(t) * SIN(t))
                v1.z = LOG(TAN(t / 2)) + (2 * COS(t)) / (1 + s * s * SIN(t) * SIN(t))

                v2.x = (2 * (COS(s + p) + SIN(s + p)) * SIN(t)) / (1 + (s + p) * (s + p) * SIN(t) * SIN(t))
                v2.y = (2 * (SIN(s + p) - (s + p) * COS(s + p)) * SIN(t)) / (1 + (s + p) * (s + p) * SIN(t) * SIN(t))
                v2.z = LOG(TAN(t / 2)) + (2 * COS(t)) / (1 + (s + p) * (s + p) * SIN(t) * SIN(t))

                v3.x = (2 * (COS(s) + SIN(s)) * SIN(t + k)) / (1 + s * s * SIN(t + k) * SIN(t + k))
                v3.y = (2 * (SIN(s) - s * COS(s)) * SIN(t + k)) / (1 + s * s * SIN(t + k) * SIN(t + k))
                v3.z = LOG(TAN((t + k) / 2)) + (2 * COS(t + k)) / (1 + s * s * SIN(t + k) * SIN(t + k))

                v4.x = (2 * (COS(s + p) + SIN(s + p)) * SIN(t + k)) / (1 + (s + p) * (s + p) * SIN(t + k) * SIN(t + k))
                v4.y = (2 * (SIN(s + p) - (s + p) * COS(s + p)) * SIN(t + k)) / (1 + (s + p) * (s + p) * SIN(t + k) * SIN(t + k))
                v4.z = LOG(TAN((t + k) / 2)) + (2 * COS(t + k)) / (1 + (s + p) * (s + p) * SIN(t + k) * SIN(t + k))

                calcNormal v1, v2, v3, n

                _glNormal3f n.x, n.y, n.z
                _glColor3f ABS(n.x), ABS(n.y), ABS(n.z)

                _glVertex3f v1.x, v1.y, v1.z
                _glVertex3f v2.x, v2.y, v2.z
                _glVertex3f v3.x, v3.y, v3.z

                calcNormal v2, v3, v4, n

                _glNormal3f n.x, n.y, n.z
                _glColor3f ABS(n.x), ABS(n.y), ABS(n.z)

                _glVertex3f v2.x, v2.y, v2.z
                _glVertex3f v3.x, v3.y, v3.z
                _glVertex3f v4.x, v4.y, v4.z



            NEXT
        NEXT
        _glEnd
        _glEndList
        kuenGenerated = -1
    ELSE
        _glCallList kuen
    END IF
    _glFlush

    clock# = clock# + .01
END SUB

'calculates the normal for the surface to interact with lights
SUB calcNormal (p1 AS vec3, p2 AS vec3, p3 AS vec3, n AS vec3)
    DIM u AS vec3, v AS vec3

    u.x = p2.x - p1.x
    u.y = p2.y - p1.y
    u.z = p2.z - p1.z

    v.x = p3.x - p1.x
    v.y = p3.y - p1.y
    v.z = p3.z - p1.z

    n.x = (u.y * v.z) - (u.z * v.y)
    n.y = (u.z * v.x) - (u.x * v.z)
    n.z = (u.x * v.y) - (u.y * v.x)
    normalizeVec3 n

END SUB

SUB normalizeVec3 (v AS vec3)
    mag## = SQR(v.x * v.x + v.y * v.y + v.z * v.z)
    v.x = v.x / mag##
    v.y = v.y / mag##
    v.z = v.z / mag##
END SUB
