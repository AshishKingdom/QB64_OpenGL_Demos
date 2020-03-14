'###########################
'# StarWars Opening Crawl  #
'# By Ashish               #
'###########################
 
_TITLE "STARSWARS Opening crawl"
 
SCREEN _NEWIMAGE(800, 600, 32)
 
DIM SHARED glAllow, text&, text2&, lines$(26)
DIM SHARED starWars&
'Feel free to modify the value of these lines as your wish. You can also add more lines by increasing the array length then adding values for next
lines$(0) =  "It is a period of civil war"
lines$(1) =  "Rebel spaceships, striking"
lines$(2) =  "from a hidden base, have "
lines$(3) =  "won their first victory"
lines$(4) =  "against the evil Galactic"
lines$(5) =  "Empire."
lines$(6) =  ""
lines$(7) =  ""
lines$(8) =  "During the battle, rebel"
lines$(9) =  "spies managed to steel"
lines$(10) =  "secret plans to the Empire's"
lines$(11) =  "ultimate weapon, the DEATH"
lines$(12) =  "STAR, an armored space station"
lines$(13) =  "with enough to destroy an entire"
lines$(14) =  "planet."
lines$(15) =  ""
lines$(16) =  ""
lines$(17) =  "Pursued by the Empire's sinister"
lines$(18) =  "agents, Princess Leia races"
lines$(19) =  "home abroad her starship,"
lines$(20) =  "custodian of the stolen plans"
lines$(21) =  "that cansave her people and"
lines$(22) =  "restore the freedom to the galaxy"
lines$(23) =  ""
lines$(24) =  ""
lines$(25) =  ""
lines$(26) =  "QB64 Rocks!"
 
'What am I actually doing?
'1. I create an image handle text& as per our array length of lines$ 
'2. I create another copy this image handle in text2&
'3. Then, I print all the text in that image with suitable color in text2& image
'4. After this, I draw the text2& image on text& image and move it from bottom to top.
'5. I use text& as a texture for plane in 3D which is tilted somewhat.
'6. So, as the image move in text&, the plane have corresponding texture in the plane. In fact, if draw anything on text&, it will textured on plane as well. (like bouncing balls, plasma, etc)
text& = _NEWIMAGE(280, (UBOUND(lines$) + 1) * _FONTHEIGHT, 32)
 
text2& = _COPYIMAGE(text&)
starWars& = _NEWIMAGE(65, 17, 32)
 
_DEST starWars&
COLOR _RGB32(255, 255, 255)
_PRINTSTRING (0, 0), "STARWARS"
_DEST 0
 
COLOR _RGB(0, 0, 255)
centerPrint "A long time ago in galaxy far,", _WIDTH, 280
centerPrint "far away...", _WIDTH, 308
_DELAY 2
FOR i = 0 TO 255 STEP 5
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGB32(0, 0, 0, i), BF
    _DISPLAY
    _DELAY 0.01
NEXT
_PUTIMAGE (_WIDTH / 2 - _WIDTH(starWars&) * 3, _HEIGHT / 2 - _HEIGHT(starWars&) * 3)-STEP(_WIDTH(starWars&) * 6, _HEIGHT(starWars&) * 6), starWars&
_DISPLAY
_DELAY 2
FOR i = 0 TO 255 STEP 5
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGB32(0, 0, 0, i), BF
    _DISPLAY
    _DELAY 0.01
NEXT
_DEST text2&
COLOR _RGB(255, 220, 0), _RGB(0, 0, 0)
FOR i = 0 TO UBOUND(lines$)
    IF i = UBOUND(lines$) THEN COLOR _RGB(255, 0, 255)
    centerPrint lines$(i), _WIDTH, y + i * _FONTHEIGHT
NEXT
_DEST 0
 
glAllow = -1
COLOR _RGB(255, 220, 0), _RGBA(0, 0, 0, 0)
y = _HEIGHT(text&) + 10
 
DO
 
    _DEST text&
    _PUTIMAGE (0, y), text2&
    y = y - 1
    _LIMIT 30
LOOP UNTIL y < -_HEIGHT(text2&) - 10
_DEST 0
 
SUB centerPrint (t$, w, y)
    _PRINTSTRING ((w / 2) - (LEN(t$) * _FONTWIDTH) / 2, y), t$
END SUB
 
SUB _GL ()
    STATIC glInit, tex&, texMem AS _MEM ', clock!
    IF NOT glAllow THEN EXIT SUB
    IF glInit = 0 THEN
        glInit = -1
        _glViewport 0, 0, _WIDTH, _HEIGHT
        texMem = _MEMIMAGE(text&) 'creating texture
        _glGenTextures 1, _OFFSET(tex&)
    END IF
        
    IF glInit = -1 THEN clock! = clock! + 0.01
	
    _glEnable _GL_TEXTURE_2D 'enable us to use 2D texture
    _glEnable _GL_DEPTH_TEST 'enable us to go 3D. Enables Z-Buffer
 
 
 
    _glMatrixMode _GL_PROJECTION 'set up perspective
    _glLoadIdentity
    _gluPerspective 60.0, _WIDTH / _HEIGHT, 0.01, 10
 
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
     
	 'pass the image data each time, as the text& is modified everytime
    _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGB16, _WIDTH(texMem.IMAGE), _HEIGHT(texMem.IMAGE), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, texMem.OFFSET
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_LINEAR
 
    'draws the plane with texture
    _glBegin _GL_QUADS
    _glBindTexture _GL_TEXTURE_2D, tex&
    _glTexCoord2f 0, 1: _glVertex3f -0.8, -1, -0.5 'bottom left     #
    _glTexCoord2f 1, 1: _glVertex3f 0.8, -1, -0.5 'bottom right     # Coordinates sign are same as in Cartesian Plane   (3D)
    _glTexCoord2f 1, 0: _glVertex3f 0.8, 3, -7 'upper right       #
    _glTexCoord2f 0, 0: _glVertex3f -0.8, 3, -7 ' upper left      #
    _glEnd
 
 
    _glFlush
END SUB
 
 
