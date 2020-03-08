'3D Sierpinski Triangle or Tetrix
'21 Feb, 2019 Ashish
'The number of pyramid formed are at nth iterations = 4^(n-1). sss
'You must enter number of iterations value between 2-8 or you can enter higher value at your own risk.

_TITLE "3D Sierpinski Triangle"
SCREEN _NEWIMAGE(700, 700, 32)

DECLARE LIBRARY 'camera related subroutine
    SUB gluLookAt (BYVAL eyeX#, BYVAL eyeY#, BYVAL eyeZ#, BYVAL centerX#, BYVAL centerY#, BYVAL centerZ#, BYVAL upX#, BYVAL upY#, BYVAL upZ#)
END DECLARE


TYPE vec3
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE face
    v1 AS vec3
    v2 AS vec3
    v3 AS vec3
    n AS vec3 'normal
END TYPE

TYPE pyramid
    f1 AS face
    f2 AS face
    f3 AS face
    f4 AS face
END TYPE

IF INPUTBOX("Enter the number of iterations", "Recommended range 2-8, or you can go higher at your own risk. ", "4", v$, -1) = 1 THEN
    totalIterations = VAL(v$)
ELSE
    END
END IF

DIM SHARED glAllow AS _BYTE, totalFaces AS LONG, triangles(4 ^ (totalIterations)) AS face
DIM SHARED mouseX, mouseY, modes
generateFractalData totalIterations
modes = 0
glAllow = -1
DO
    k& = _KEYHIT
    IF k& = ASC(" ") THEN modes = modes + 1
    IF modes > 3 THEN modes = 0
    WHILE _MOUSEINPUT: WEND
    mouseX = _MOUSEX: mouseY = _MOUSEY
    _LIMIT 40
LOOP UNTIL k& = 27

SUB _GL
    STATIC glInit, aspect#, t#
    IF NOT glAllow THEN EXIT SUB

    IF NOT glInit THEN
        glInit = -1
        aspect# = _WIDTH / _HEIGHT
        _glViewport 0, 0, _WIDTH, _HEIGHT
    END IF
    _glClearColor 0.4, 0.4, 0.4, 1
    _glClear _GL_DEPTH_BUFFER_BIT OR _GL_COLOR_BUFFER_BIT

    _glEnable _GL_DEPTH_TEST


    IF modes = 0 THEN
        _glEnable _GL_LIGHTING
        _glEnable _GL_LIGHT0
        _glLightfv _GL_LIGHT0, _GL_POSITION, glVec4(0, 0, 25, 0)
        _glLightfv _GL_LIGHT0, _GL_AMBIENT, glVec3(0.4, 0.4, 0.4)
        _glLightfv _GL_LIGHT0, _GL_DIFFUSE, glVec3(1, 1, 1)
        _glLightfv _GL_LIGHT0, _GL_SPECULAR, glVec3(0.6, 0.6, 0.6)
    END IF

    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _gluPerspective 45.0, aspect#, 1, 100

    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity

    gluLookAt 0, 0, 4, 0, 0, 0, 0, 1, 0


    _glPushMatrix

    _glRotatef mouseX * 1.9, 0, 1, 0

    SELECT CASE modes
        CASE 0
            _glMaterialfv _GL_FRONT_AND_BACK, _GL_AMBIENT, glVec3(0.1745, 0.01175, 0.01175)
            _glMaterialfv _GL_FRONT_AND_BACK, _GL_DIFFUSE, glVec3(0.61424, 0.04136, 0.04136)
            _glMaterialfv _GL_FRONT_AND_BACK, _GL_SPECULAR, glVec3(0.727811, 0.626959, 0.626959)
            _glMaterialfv _GL_FRONT_AND_BACK, _GL_SHININESS, glVec3(128 * 0.6, 0, 0)

            _glBegin _GL_TRIANGLES

            FOR i = 0 TO totalFaces - 1

                _glNormal3f triangles(i).n.x, triangles(i).n.y, triangles(i).n.z
                _glVertex3f triangles(i).v1.x, triangles(i).v1.y, triangles(i).v1.z
                _glVertex3f triangles(i).v2.x, triangles(i).v2.y, triangles(i).v2.z
                _glVertex3f triangles(i).v3.x, triangles(i).v3.y, triangles(i).v3.z

            NEXT
            _glEnd
        CASE 1
            _glBegin _GL_TRIANGLES
            FOR i = 0 TO totalFaces - 1
                _glColor3f ABS(triangles(i).n.x), ABS(triangles(i).n.y), ABS(triangles(i).n.z)

                _glVertex3f triangles(i).v1.x, triangles(i).v1.y, triangles(i).v1.z
                _glVertex3f triangles(i).v2.x, triangles(i).v2.y, triangles(i).v2.z
                _glVertex3f triangles(i).v3.x, triangles(i).v3.y, triangles(i).v3.z
            NEXT
            _glEnd
        CASE 2
            _glBegin _GL_LINES
            FOR i = 0 TO totalFaces - 1
                _glVertex3f triangles(i).v1.x, triangles(i).v1.y, triangles(i).v1.z
                _glVertex3f triangles(i).v2.x, triangles(i).v2.y, triangles(i).v2.z

                _glVertex3f triangles(i).v3.x, triangles(i).v3.y, triangles(i).v3.z
                _glVertex3f triangles(i).v2.x, triangles(i).v2.y, triangles(i).v2.z

                _glVertex3f triangles(i).v3.x, triangles(i).v3.y, triangles(i).v3.z
                _glVertex3f triangles(i).v1.x, triangles(i).v1.y, triangles(i).v1.z
            NEXT
            _glEnd
        CASE 3
            _glBegin _GL_LINES
            FOR i = 0 TO totalFaces - 1
                _glColor3f ABS(triangles(i).n.x), ABS(triangles(i).n.y), ABS(triangles(i).n.z)

                _glVertex3f triangles(i).v1.x, triangles(i).v1.y, triangles(i).v1.z
                _glVertex3f triangles(i).v2.x, triangles(i).v2.y, triangles(i).v2.z

                _glVertex3f triangles(i).v3.x, triangles(i).v3.y, triangles(i).v3.z
                _glVertex3f triangles(i).v2.x, triangles(i).v2.y, triangles(i).v2.z

                _glVertex3f triangles(i).v3.x, triangles(i).v3.y, triangles(i).v3.z
                _glVertex3f triangles(i).v1.x, triangles(i).v1.y, triangles(i).v1.z
            NEXT
            _glEnd
    END SELECT
    _glPopMatrix



    _glFlush

END SUB

SUB generateFractalData (num_of_iterations)
    createFaces num_of_iterations, 0, 1, 1 / 3, -1, -1, 1, 1, -1, 1, 0, -1, -1, 1
END SUB

SUB createFaces (i, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, i_c)
    STATIC Fc, normalVec AS vec3
    IF i_c = 1 THEN Fc = 0
    IF i = i_c THEN
        triangles(Fc).v1.x = x1: triangles(Fc).v1.y = y1: triangles(Fc).v1.z = z1
        triangles(Fc).v2.x = x2: triangles(Fc).v2.y = y2: triangles(Fc).v2.z = z2
        triangles(Fc).v3.x = x3: triangles(Fc).v3.y = y3: triangles(Fc).v3.z = z3
        OBJ_CalculateNormal triangles(Fc).v1, triangles(Fc).v2, triangles(Fc).v3, normalVec
        triangles(Fc).n.x = normalVec.x: triangles(Fc).n.y = normalVec.y: triangles(Fc).n.z = normalVec.z
        Fc = Fc + 1
        triangles(Fc).v1.x = x2: triangles(Fc).v1.y = y2: triangles(Fc).v1.z = z2
        triangles(Fc).v2.x = x3: triangles(Fc).v2.y = y3: triangles(Fc).v2.z = z3
        triangles(Fc).v3.x = x4: triangles(Fc).v3.y = y4: triangles(Fc).v3.z = z4
        OBJ_CalculateNormal triangles(Fc).v1, triangles(Fc).v2, triangles(Fc).v3, normalVec
        triangles(Fc).n.x = normalVec.x: triangles(Fc).n.y = normalVec.y: triangles(Fc).n.z = normalVec.z
        Fc = Fc + 1
        triangles(Fc).v1.x = x3: triangles(Fc).v1.y = y3: triangles(Fc).v1.z = z3
        triangles(Fc).v2.x = x4: triangles(Fc).v2.y = y4: triangles(Fc).v2.z = z4
        triangles(Fc).v3.x = x1: triangles(Fc).v3.y = y1: triangles(Fc).v3.z = z1
        OBJ_CalculateNormal triangles(Fc).v1, triangles(Fc).v2, triangles(Fc).v3, normalVec
        triangles(Fc).n.x = normalVec.x: triangles(Fc).n.y = normalVec.y: triangles(Fc).n.z = normalVec.z
        Fc = Fc + 1
        triangles(Fc).v1.x = x4: triangles(Fc).v1.y = y4: triangles(Fc).v1.z = z4
        triangles(Fc).v2.x = x1: triangles(Fc).v2.y = y1: triangles(Fc).v2.z = z1
        triangles(Fc).v3.x = x2: triangles(Fc).v3.y = y2: triangles(Fc).v3.z = z2
        OBJ_CalculateNormal triangles(Fc).v1, triangles(Fc).v2, triangles(Fc).v3, normalVec
        triangles(Fc).n.x = normalVec.x: triangles(Fc).n.y = normalVec.y: triangles(Fc).n.z = normalVec.z
        Fc = Fc + 1
        totalFaces = totalFaces + 4

    ELSE
        'creating 4 pyramid from single pyramid and then dividing them further
        createFaces i, (x4 + x1) / 2, (y4 + y1) / 2, (z4 + z1) / 2, (x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2, (x1 + x3) / 2, (y1 + y3) / 2, (z1 + z3) / 2, x1, y1, z1, i_c + 1
        createFaces i, x4, y4, z4, (x2 + x4) / 2, (y2 + y4) / 2, (z2 + z4) / 2, (x3 + x4) / 2, (y3 + y4) / 2, (z3 + z4) / 2, (x1 + x4) / 2, (y1 + y4) / 2, (z1 + z4) / 2, i_c + 1
        createFaces i, (x2 + x4) / 2, (y2 + y4) / 2, (z2 + z4) / 2, x2, y2, z2, (x2 + x3) / 2, (y2 + y3) / 2, (z2 + z3) / 2, (x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2, i_c + 1
        createFaces i, (x3 + x4) / 2, (y3 + y4) / 2, (z3 + z4) / 2, (x2 + x3) / 2, (y2 + y3) / 2, (z2 + z3) / 2, x3, y3, z3, (x1 + x3) / 2, (y1 + y3) / 2, (z1 + z3) / 2, i_c + 1
    END IF
END SUB

SUB OBJ_CalculateNormal (p1 AS vec3, p2 AS vec3, p3 AS vec3, N AS vec3)
    DIM U AS vec3, V AS vec3

    U.x = p2.x - p1.x
    U.y = p2.y - p1.y
    U.z = p2.z - p1.z

    V.x = p3.x - p1.x
    V.y = p3.y - p1.y
    V.z = p3.z - p1.z

    N.x = (U.y * V.z) - (U.z * V.y)
    N.y = (U.z * V.x) - (U.x * V.z)
    N.z = (U.x * V.y) - (U.y * V.x)
    OBJ_Normalize N
END SUB

SUB OBJ_Normalize (V AS vec3)
    mag! = SQR(V.x * V.x + V.y * V.y + V.z * V.z)
    V.x = V.x / mag!
    V.y = V.y / mag!
    V.z = V.z / mag!
END SUB

FUNCTION glVec4%& (x, y, z, w)
    STATIC internal_vec4(3)
    internal_vec4(0) = x
    internal_vec4(1) = y
    internal_vec4(2) = z
    internal_vec4(3) = w
    glVec4%& = _OFFSET(internal_vec4())
END FUNCTION

FUNCTION glVec3%& (x, y, z)
    STATIC internal_vec3(2)
    internal_vec3(0) = x
    internal_vec3(1) = y
    internal_vec3(2) = z
    glVec3%& = _OFFSET(internal_vec3())
END FUNCTION

'By Fellipe Heitor
FUNCTION INPUTBOX (tTitle$, tMessage$, InitialValue AS STRING, NewValue AS STRING, Selected)
    'INPUTBOX ---------------------------------------------------------------------
    'Show a dialog and allow user input. Returns 1 = OK or 2 = Cancel.            '
    '                                                                             '
    '- tTitle$ is the desired dialog title. If not provided, it'll be "Input"     '
    '                                                                             '
    '- tMessage$ is the prompt that'll be shown to the user. You can show         '
    '   a multiline message by adding line breaks with CHR$(10).                  '
    '                                                                             '
    ' - InitialValue can be passed both as a string literal or as a variable.     '
    '                                                                             '
    '- Actual user input is returned by altering NewValue, so it must be          '
    '   passed as a variable.                                                     '
    '                                                                             '
    '- Selected indicates wheter the initial value will be preselected when the   '
    '   dialog is first shown. -1 preselects the whole text; positive values      '
    '   select only part of the initial value (from the character position passed '
    '   to the end of the initial value).                                         '
    '                                                                             '
    'Intended for use with 32-bit screen modes.                                   '
    '------------------------------------------------------------------------------

    'Variable declaration:
    DIM Message$, Title$, CharW AS INTEGER, MaxLen AS INTEGER
    DIM lineBreak AS INTEGER, totalLines AS INTEGER, prevlinebreak AS INTEGER
    DIM Cursor AS INTEGER, Selection.Start AS INTEGER, InputViewStart AS INTEGER
    DIM FieldArea AS INTEGER, DialogH AS INTEGER, DialogW AS INTEGER
    DIM DialogX AS INTEGER, DialogY AS INTEGER, InputField.X AS INTEGER
    DIM TotalButtons AS INTEGER, B AS INTEGER, ButtonLine$
    DIM cb AS INTEGER, DIALOGRESULT AS INTEGER, i AS INTEGER
    DIM message.X AS INTEGER, SetCursor#, cursorBlink%
    DIM DefaultButton AS INTEGER, k AS LONG
    DIM shiftDown AS _BYTE, ctrlDown AS _BYTE, Clip$
    DIM FindLF%, s1 AS INTEGER, s2 AS INTEGER
    DIM Selection.Value$
    DIM prevCursor AS INTEGER, ss1 AS INTEGER, ss2 AS INTEGER, mb AS _BYTE
    DIM mx AS INTEGER, my AS INTEGER, nmx AS INTEGER, nmy AS INTEGER
    DIM FGColor AS LONG, BGColor AS LONG

    'Data type used for the dialog buttons:
    TYPE BUTTONSTYPE
        ID AS LONG
        CAPTION AS STRING * 120
        X AS INTEGER
        Y AS INTEGER
        W AS INTEGER
    END TYPE

    'Color constants. You can customize colors by changing these:
    CONST TitleBarColor = _RGB32(0, 178, 179)
    CONST DialogBGColor = _RGB32(255, 255, 255)
    CONST TitleBarTextColor = _RGB32(0, 0, 0)
    CONST DialogTextColor = _RGB32(0, 0, 0)
    CONST InputFieldColor = _RGB32(200, 200, 200)
    CONST InputFieldTextColor = _RGB32(0, 0, 0)
    CONST SelectionColor = _RGBA32(127, 127, 127, 100)

    'Initial variable setup:
    Message$ = tMessage$
    Title$ = RTRIM$(LTRIM$(tTitle$))
    IF Title$ = "" THEN Title$ = "Input"
    NewValue = RTRIM$(LTRIM$(InitialValue))
    DefaultButton = 1

    'Save the current drawing page so it can be restored later:
    FGColor = _DEFAULTCOLOR
    BGColor = _BACKGROUNDCOLOR
    PCOPY 0, 1

    'Figure out the print width of a single character (in case user has a custom font applied)
    CharW = _PRINTWIDTH("_")

    'Place a color overlay over the old screen image so the focus is on the dialog:
    LINE (0, 0)-STEP(_WIDTH - 1, _HEIGHT - 1), _RGBA32(170, 170, 170, 170), BF

    'Message breakdown, in case CHR$(10) was used as line break:
    REDIM MessageLines(1) AS STRING
    MaxLen = 1
    DO
        lineBreak = INSTR(lineBreak + 1, Message$, CHR$(10))
        IF lineBreak = 0 AND totalLines = 0 THEN
            totalLines = 1
            MessageLines(1) = Message$
            MaxLen = LEN(Message$)
            EXIT DO
        ELSEIF lineBreak = 0 AND totalLines > 0 THEN
            totalLines = totalLines + 1
            REDIM _PRESERVE MessageLines(1 TO totalLines) AS STRING
            MessageLines(totalLines) = RIGHT$(Message$, LEN(Message$) - prevlinebreak + 1)
            IF LEN(MessageLines(totalLines)) > MaxLen THEN MaxLen = LEN(MessageLines(totalLines))
            EXIT DO
        END IF
        IF totalLines = 0 THEN prevlinebreak = 1
        totalLines = totalLines + 1
        REDIM _PRESERVE MessageLines(1 TO totalLines) AS STRING
        MessageLines(totalLines) = MID$(Message$, prevlinebreak, lineBreak - prevlinebreak)
        IF LEN(MessageLines(totalLines)) > MaxLen THEN MaxLen = LEN(MessageLines(totalLines))
        prevlinebreak = lineBreak + 1
    LOOP

    Cursor = LEN(NewValue)
    Selection.Start = 0
    InputViewStart = 1
    FieldArea = _WIDTH \ CharW - 4
    IF FieldArea > 62 THEN FieldArea = 62
    IF Selected > 0 THEN Selection.Start = Selected: Selected = -1

    'Calculate dialog dimensions and print coordinates:
    DialogH = _FONTHEIGHT * (6 + totalLines) + 10
    DialogW = (CharW * FieldArea) + 10
    IF DialogW < MaxLen * CharW + 10 THEN DialogW = MaxLen * CharW + 10

    DialogX = _WIDTH / 2 - DialogW / 2
    DialogY = _HEIGHT / 2 - DialogH / 2
    InputField.X = (DialogX + (DialogW / 2)) - (((FieldArea * CharW) - 10) / 2) - 4

    'Calculate button's print coordinates:
    TotalButtons = 2
    DIM Buttons(1 TO TotalButtons) AS BUTTONSTYPE
    B = 1
    Buttons(B).ID = 1: Buttons(B).CAPTION = "< OK >": B = B + 1
    Buttons(B).ID = 2: Buttons(B).CAPTION = "< Cancel >": B = B + 1
    ButtonLine$ = " "
    FOR cb = 1 TO TotalButtons
        ButtonLine$ = ButtonLine$ + RTRIM$(LTRIM$(Buttons(cb).CAPTION)) + " "
        Buttons(cb).Y = DialogY + 5 + _FONTHEIGHT * (5 + totalLines)
        Buttons(cb).W = _PRINTWIDTH(RTRIM$(LTRIM$(Buttons(cb).CAPTION)))
    NEXT cb
    Buttons(1).X = _WIDTH / 2 - _PRINTWIDTH(ButtonLine$) / 2
    FOR cb = 2 TO TotalButtons
        Buttons(cb).X = Buttons(1).X + _PRINTWIDTH(SPACE$(INSTR(ButtonLine$, RTRIM$(LTRIM$(Buttons(cb).CAPTION)))))
    NEXT cb

    'Main loop:
    DIALOGRESULT = 0
    _KEYCLEAR
    DO: _LIMIT 500
        'Draw the dialog.
        LINE (DialogX, DialogY)-STEP(DialogW - 1, DialogH - 1), DialogBGColor, BF
        LINE (DialogX, DialogY)-STEP(DialogW - 1, _FONTHEIGHT + 1), TitleBarColor, BF
        COLOR TitleBarTextColor
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(Title$) / 2, DialogY + 1), Title$

        COLOR DialogTextColor, _RGBA32(0, 0, 0, 0)
        FOR i = 1 TO totalLines
            message.X = _WIDTH / 2 - _PRINTWIDTH(MessageLines(i)) / 2
            _PRINTSTRING (message.X, DialogY + 5 + _FONTHEIGHT * (i + 1)), MessageLines(i)
        NEXT i

        'Draw the input field
        LINE (InputField.X - 2, DialogY + 3 + _FONTHEIGHT * (3 + totalLines))-STEP(FieldArea * CharW, _FONTHEIGHT + 4), InputFieldColor, BF
        COLOR InputFieldTextColor
        _PRINTSTRING (InputField.X, DialogY + 5 + _FONTHEIGHT * (3 + totalLines)), MID$(NewValue, InputViewStart, FieldArea)

        'Selection highlight:
        GOSUB SelectionHighlight

        'Cursor blink:
        IF TIMER - SetCursor# > .4 THEN
            SetCursor# = TIMER
            IF cursorBlink% = 1 THEN cursorBlink% = 0 ELSE cursorBlink% = 1
        END IF
        IF cursorBlink% = 1 THEN
            LINE (InputField.X + (Cursor - (InputViewStart - 1)) * CharW, DialogY + 5 + _FONTHEIGHT * (3 + totalLines))-STEP(0, _FONTHEIGHT), _RGB32(0, 0, 0)
        END IF

        'Check if buttons have been clicked or are being hovered:
        GOSUB CheckButtons

        'Draw buttons:
        FOR cb = 1 TO TotalButtons
            _PRINTSTRING (Buttons(cb).X, Buttons(cb).Y), RTRIM$(LTRIM$(Buttons(cb).CAPTION))
            IF cb = DefaultButton THEN
                COLOR _RGB32(255, 255, 0)
                _PRINTSTRING (Buttons(cb).X, Buttons(cb).Y), "<" + SPACE$(LEN(RTRIM$(LTRIM$(Buttons(cb).CAPTION))) - 2) + ">"
                COLOR _RGB32(0, 178, 179)
                _PRINTSTRING (Buttons(cb).X - 1, Buttons(cb).Y - 1), "<" + SPACE$(LEN(RTRIM$(LTRIM$(Buttons(cb).CAPTION))) - 2) + ">"
                COLOR _RGB32(0, 0, 0)
            END IF
        NEXT cb

        _DISPLAY

        'Process input:
        k = _KEYHIT
        IF k = 100303 OR k = 100304 THEN shiftDown = -1
        IF k = -100303 OR k = -100304 THEN shiftDown = 0
        IF k = 100305 OR k = 100306 THEN ctrlDown = -1
        IF k = -100305 OR k = -100306 THEN ctrlDown = 0

        SELECT CASE k
            CASE 13: DIALOGRESULT = 1
            CASE 27: DIALOGRESULT = 2
            CASE 32 TO 126 'Printable ASCII characters
                IF k = ASC("v") OR k = ASC("V") THEN 'Paste from clipboard (Ctrl+V)
                    IF ctrlDown THEN
                        Clip$ = _CLIPBOARD$
                        FindLF% = INSTR(Clip$, CHR$(13))
                        IF FindLF% > 0 THEN Clip$ = LEFT$(Clip$, FindLF% - 1)
                        FindLF% = INSTR(Clip$, CHR$(10))
                        IF FindLF% > 0 THEN Clip$ = LEFT$(Clip$, FindLF% - 1)
                        IF LEN(RTRIM$(LTRIM$(Clip$))) > 0 THEN
                            IF NOT Selected THEN
                                IF Cursor = LEN(NewValue) THEN
                                    NewValue = NewValue + Clip$
                                    Cursor = LEN(NewValue)
                                ELSE
                                    NewValue = LEFT$(NewValue, Cursor) + Clip$ + MID$(NewValue, Cursor + 1)
                                    Cursor = Cursor + LEN(Clip$)
                                END IF
                            ELSE
                                s1 = Selection.Start
                                s2 = Cursor
                                IF s1 > s2 THEN SWAP s1, s2
                                NewValue = LEFT$(NewValue, s1) + Clip$ + MID$(NewValue, s2 + 1)
                                Cursor = s1 + LEN(Clip$)
                                Selected = 0
                            END IF
                        END IF
                        k = 0
                    END IF
                ELSEIF k = ASC("c") OR k = ASC("C") THEN 'Copy selection to clipboard (Ctrl+C)
                    IF ctrlDown THEN
                        _CLIPBOARD$ = Selection.Value$
                        k = 0
                    END IF
                ELSEIF k = ASC("x") OR k = ASC("X") THEN 'Cut selection to clipboard (Ctrl+X)
                    IF ctrlDown THEN
                        _CLIPBOARD$ = Selection.Value$
                        GOSUB DeleteSelection
                        k = 0
                    END IF
                ELSEIF k = ASC("a") OR k = ASC("A") THEN 'Select all text (Ctrl+A)
                    IF ctrlDown THEN
                        Cursor = LEN(NewValue)
                        Selection.Start = 0
                        Selected = -1
                        k = 0
                    END IF
                END IF

                IF k > 0 THEN
                    IF NOT Selected THEN
                        IF Cursor = LEN(NewValue) THEN
                            NewValue = NewValue + CHR$(k)
                            Cursor = Cursor + 1
                        ELSE
                            NewValue = LEFT$(NewValue, Cursor) + CHR$(k) + MID$(NewValue, Cursor + 1)
                            Cursor = Cursor + 1
                        END IF
                        IF Cursor > FieldArea THEN InputViewStart = (Cursor - FieldArea) + 2
                    ELSE
                        s1 = Selection.Start
                        s2 = Cursor
                        IF s1 > s2 THEN SWAP s1, s2
                        NewValue = LEFT$(NewValue, s1) + CHR$(k) + MID$(NewValue, s2 + 1)
                        Selected = 0
                        Cursor = s1 + 1
                    END IF
                END IF
            CASE 8 'Backspace
                IF LEN(NewValue) > 0 THEN
                    IF NOT Selected THEN
                        IF Cursor = LEN(NewValue) THEN
                            NewValue = LEFT$(NewValue, LEN(NewValue) - 1)
                            Cursor = Cursor - 1
                        ELSEIF Cursor > 1 THEN
                            NewValue = LEFT$(NewValue, Cursor - 1) + MID$(NewValue, Cursor + 1)
                            Cursor = Cursor - 1
                        ELSEIF Cursor = 1 THEN
                            NewValue = RIGHT$(NewValue, LEN(NewValue) - 1)
                            Cursor = Cursor - 1
                        END IF
                    ELSE
                        GOSUB DeleteSelection
                    END IF
                END IF
            CASE 21248 'Delete
                IF NOT Selected THEN
                    IF LEN(NewValue) > 0 THEN
                        IF Cursor = 0 THEN
                            NewValue = RIGHT$(NewValue, LEN(NewValue) - 1)
                        ELSEIF Cursor > 0 AND Cursor <= LEN(NewValue) - 1 THEN
                            NewValue = LEFT$(NewValue, Cursor) + MID$(NewValue, Cursor + 2)
                        END IF
                    END IF
                ELSE
                    GOSUB DeleteSelection
                END IF
            CASE 19200 'Left arrow key
                GOSUB CheckSelection
                IF Cursor > 0 THEN Cursor = Cursor - 1
            CASE 19712 'Right arrow key
                GOSUB CheckSelection
                IF Cursor < LEN(NewValue) THEN Cursor = Cursor + 1
            CASE 18176 'Home
                GOSUB CheckSelection
                Cursor = 0
            CASE 20224 'End
                GOSUB CheckSelection
                Cursor = LEN(NewValue)
        END SELECT

        'Cursor adjustments:
        GOSUB CursorAdjustments
    LOOP UNTIL DIALOGRESULT > 0

    _KEYCLEAR
    INPUTBOX = DIALOGRESULT

    'Restore previous display:
    PCOPY 1, 0
    COLOR FGColor, BGColor
    EXIT SUB

    CursorAdjustments:
    IF Cursor > prevCursor THEN
        IF Cursor - InputViewStart + 2 > FieldArea THEN InputViewStart = (Cursor - FieldArea) + 2
    ELSEIF Cursor < prevCursor THEN
        IF Cursor < InputViewStart - 1 THEN InputViewStart = Cursor
    END IF
    prevCursor = Cursor
    IF InputViewStart < 1 THEN InputViewStart = 1
    RETURN

    CheckSelection:
    IF shiftDown = -1 THEN
        IF Selected = 0 THEN
            Selected = -1
            Selection.Start = Cursor
        END IF
    ELSEIF shiftDown = 0 THEN
        Selected = 0
    END IF
    RETURN

    DeleteSelection:
    NewValue = LEFT$(NewValue, s1) + MID$(NewValue, s2 + 1)
    Selected = 0
    Cursor = s1
    RETURN

    SelectionHighlight:
    IF Selected THEN
        s1 = Selection.Start
        s2 = Cursor
        IF s1 > s2 THEN
            SWAP s1, s2
            IF InputViewStart > 1 THEN
                ss1 = s1 - InputViewStart + 1
            ELSE
                ss1 = s1
            END IF
            ss2 = s2 - s1
            IF ss1 + ss2 > FieldArea THEN ss2 = FieldArea - ss1
        ELSE
            ss1 = s1
            ss2 = s2 - s1
            IF ss1 < InputViewStart THEN ss1 = 0: ss2 = s2 - InputViewStart + 1
            IF ss1 > InputViewStart THEN ss1 = ss1 - InputViewStart + 1: ss2 = s2 - s1
        END IF
        Selection.Value$ = MID$(NewValue, s1 + 1, s2 - s1)

        LINE (InputField.X + ss1 * CharW, DialogY + 5 + _FONTHEIGHT * (3 + totalLines))-STEP(ss2 * CharW, _FONTHEIGHT), _RGBA32(255, 255, 255, 150), BF
    END IF
    RETURN

    CheckButtons:
    'Hover highlight:
    WHILE _MOUSEINPUT: WEND
    mb = _MOUSEBUTTON(1): mx = _MOUSEX: my = _MOUSEY
    FOR cb = 1 TO TotalButtons
        IF (mx >= Buttons(cb).X) AND (mx <= Buttons(cb).X + Buttons(cb).W) THEN
            IF (my >= Buttons(cb).Y) AND (my < Buttons(cb).Y + _FONTHEIGHT) THEN
                LINE (Buttons(cb).X, Buttons(cb).Y)-STEP(Buttons(cb).W, _FONTHEIGHT - 1), _RGBA32(230, 230, 230, 235), BF
            END IF
        END IF
    NEXT cb

    IF mb THEN
        IF mx >= InputField.X AND my >= DialogY + 3 + _FONTHEIGHT * (3 + totalLines) AND mx <= InputField.X + (FieldArea * CharW - 10) AND my <= DialogY + 3 + _FONTHEIGHT * (3 + totalLines) + _FONTHEIGHT + 4 THEN
            'Clicking inside the text field positions the cursor
            WHILE _MOUSEBUTTON(1)
                _LIMIT 500
                mb = _MOUSEINPUT
            WEND
            Cursor = ((mx - InputField.X) / CharW) + (InputViewStart - 1)
            IF Cursor > LEN(NewValue) THEN Cursor = LEN(NewValue)
            Selected = 0
            RETURN
        END IF

        FOR cb = 1 TO TotalButtons
            IF (mx >= Buttons(cb).X) AND (mx <= Buttons(cb).X + Buttons(cb).W) THEN
                IF (my >= Buttons(cb).Y) AND (my < Buttons(cb).Y + _FONTHEIGHT) THEN
                    DefaultButton = cb
                    WHILE _MOUSEBUTTON(1): _LIMIT 500: mb = _MOUSEINPUT: WEND
                    mb = 0: nmx = _MOUSEX: nmy = _MOUSEY
                    IF nmx = mx AND nmy = my THEN DIALOGRESULT = cb
                    RETURN
                END IF
            END IF
        NEXT cb
    END IF
    RETURN
END FUNCTION

