DIM SHARED seznam2(1000) AS STRING * 255 '                 maximum files in directory limited to 1000
DIM SHARED VFiles(1000) AS STRING * 255 '                  Dim for memory array contains VISIBLE file names (vith national characters others as US, displayed with _MAPUNICODE, BUT UNUSABLE TO OPERATION WITH FILES!
DIM SHARED UFiles(1000) AS STRING * 255 '                  Dim for memory array contains UNVISIBLE, old filenames type 8.3. This is ussable to operation with files, but is not standardly displayed. One record lenght = 13.
DIM SHARED MaskUFiles(1000) AS STRING * 255 '              Dim for array contains empty blocks + blocks with record accetable filemask - U = usable for file access
DIM SHARED MaskVFiles(1000) AS STRING * 255 '              the same, but V = Visible - here are strings that can be correctly converted to screen with _MAPUNICODE, but are unussable to file access
' -------------------------------------------------        this all dims are erased if sub end. Final outputs are:
DIM SHARED FinalVFiles(1000) AS STRING * 255 '             Contains all QB64 usable soundformat files from directory - names unusable for access
DIM SHARED FinalUFiles(1000) AS STRING * 12 '               8 + "." + 3 the same as previous case, but usable for file access
DIM SHARED sekunda(10) AS INTEGER, minuta(360) AS INTEGER 'Array contains seconds and minute for song time
DIM SHARED text(27) AS STRING * 200 '                       27 linies, contains 200 characters (max)
DIM SHARED RndFinalVFiles(1000) AS STRING * 255 '           its still copy FinalVFiles - if random play is off, its random array generated in VFiles copyed back from this still copy
DIM SHARED RndFinalUFiles(1000) AS STRING * 255
DIM SHARED copyU(1000) AS STRING * 200 ' bylo nastaveno max misto 1000 kdyby rndplay neslo...
DIM SHARED copyV(1000) AS STRING * 200
DIM SHARED Track(1000) AS INTEGER '                         contains track list in play order (every track listed by nacti.b has own rerord number)
DIM SHARED status AS STRING

path$ = ENVIRON$("SYSTEMROOT")
path$ = path$ + "\fonts\cour.ttf"
f& = _LOADFONT(path$, 32, "monospace, bold") '              Load font. Font is used for correct display song name
Vol = 1
polar = 10


_TITLE "QB64 Music Player.      By Petr"
i& = _NEWIMAGE(1024, 300, 32) '                              My screen window
new& = _LOADIMAGE("skinDb.png", 32) '                        My all in one graphic file
j& = _NEWIMAGE(1024, 300, 32)
d& = _NEWIMAGE(491, 74, 32)
GreenButtonPlay& = _NEWIMAGE(100, 100, 32)
GreenButtonStop& = _NEWIMAGE(100, 100, 32)
GreenButtonPower& = _NEWIMAGE(100, 100, 32)
GreenButtonBack& = _NEWIMAGE(100, 100, 32)
GreenButtonPause& = _NEWIMAGE(100, 100, 32)
GreenButtonNext& = _NEWIMAGE(100, 100, 32)
VolumePlus& = _NEWIMAGE(50, 50, 32)
VolumeMinus& = _NEWIMAGE(50, 50, 32)
ImageOpenFiles& = _NEWIMAGE(50, 50, 32)
resicon& = _NEWIMAGE(114, 30, 32)
infoicon& = _NEWIMAGE(50, 50, 32)
LoopOneU& = _NEWIMAGE(50, 50, 32) ' U as unpressed or NOT pressed
LoopAllU& = _NEWIMAGE(50, 50, 32)
LoopOneP& = _NEWIMAGE(50, 50, 32) ' P as Pressed
LoopAllP& = _NEWIMAGE(50, 50, 32)
RandPlayOff& = _NEWIMAGE(27, 12, 32)
RandPlayOn& = _NEWIMAGE(27, 12, 32)
afterinfo& = _NEWIMAGE(1024, 300, 32)
_PUTIMAGE (0, 0)-(26, 11), new&, RandPlayOff&, (560, 60)-(586, 71)
_PUTIMAGE (0, 0)-(26, 11), new&, RandPlayOn&, (560, 74)-(586, 85)
_PUTIMAGE (0, 0)-(49, 49), new&, LoopAllP&, (894, 592)-(960, 656)
_PUTIMAGE (0, 0)-(49, 49), new&, LoopOneP&, (960, 590)-(1023, 650)
_PUTIMAGE (0, 0)-(49, 49), new&, LoopAllU&, (896, 530)-(956, 590)
_PUTIMAGE (0, 0)-(49, 49), new&, LoopOneU&, (950, 470)-(1010, 530)
_PUTIMAGE (0, 0)-(49, 49), new&, infoicon&, (964, 538)-(1014, 588)
_PUTIMAGE (0, 0)-(113, 29), new&, resicon&, (571, 8)-(684, 37)
_PUTIMAGE (0, 0)-(49, 49), new&, ImageOpenFiles&, (899, 474)-(948, 523)
_PUTIMAGE (0, 0)-(49, 49), new&, VolumeMinus&, (895, 412)-(945, 462)
_PUTIMAGE (0, 0)-(49, 49), new&, VolumePlus&, (958, 412)-(1008, 462)
_PUTIMAGE (0, 0), new&, GreenButtonNext&, (760, 540)-(860, 640)
_PUTIMAGE (0, 0), new&, GreenButtonPause&, (650, 540)-(750, 640)
_PUTIMAGE (0, 0), new&, GreenButtonBack&, (540, 540)-(640, 640)
_PUTIMAGE (0, 0), new&, GreenButtonPower&, (770, 430)-(870, 530)
_PUTIMAGE (0, 0), new&, GreenButtonStop&, (650, 430)-(750, 530)
_PUTIMAGE (0, 0), new&, GreenButtonPlay&, (532, 431)-(632, 531)
_PUTIMAGE (0, 0), new&, j&, (1, 100)-(1025, 401)
_PUTIMAGE (0, 0), new&, d&, (0, 0)-(490, 73)
'j& = _LOADIMAGE("skin.png", 32) 'tohle
'd& = _LOADIMAGE("digits.png", 32) 'tohle
_PUTIMAGE , j&, i&: m& = _NEWIMAGE(400, 100, 32): t& = _NEWIMAGE(5000, 120, 32) ' t& = song title - for long names


titlemusic$ = "Stoped" '                                                          basic status
InsertX = -200 '                                                                  its X axis for song name moving on screen
'mrizka 170, 10
'path$ = ENVIRON$("SYSTEMROOT")
'path$ = path$ + "\fonts\cour.ttf"

SCREEN i&
'screen i&
white& = _RGB32(255, 255, 255)
whitetwo& = _RGB32(150, 150, 150)
_SETALPHA 0, white& TO whitetwo&, VolumePlus&
_SETALPHA 0, white& TO whitetwo&, VolumeMinus&
_SETALPHA 0, white& TO whitetwo&, ImageOpenFiles&
_SETALPHA 0, white& TO whitetwo&, infoicon&
_SETALPHA 0, white& TO _RGB32(65, 65, 65), LoopOneU&
_SETALPHA 0, white& TO _RGB32(65, 65, 65), LoopAllU&
'_SETALPHA 0, white& TO _RGB32(65, 65, 65), LoopOneP&
'_SETALPHA 0, white& TO _RGB32(65, 65, 65), LoopAllP&
_PUTIMAGE (918, 170), LoopOneU&
_PUTIMAGE (918, 115), LoopAllU&

_PUTIMAGE (739, 223), infoicon&
_PUTIMAGE (799, 223), ImageOpenFiles&, i&
_PUTIMAGE (859, 222), VolumePlus&, i&
_PUTIMAGE (919, 222), VolumeMinus&, i&
_PUTIMAGE (0, 0), i&, afterinfo&
_SETALPHA 0, white& TO _RGB32(65, 65, 65), RandPlayOff&
_PUTIMAGE (930, 91), RandPlayOff&, i&
_SETALPHA 0, white& TO _RGB32(65, 65, 65), RandPlayOn&


PCOPY _DISPLAY, 1
LoopOne = 0 '                                               basic status for neverending playing one track
LoopAll = 0 '                                               basic status for neverending playing all tracks from selected directory
WindowsFileOpenSystem
IF PlEr = 1 THEN PlEr = 0: BEEP: WindowsFileOpenSystem '    PlEr = Play Error. 0 = no error, 1 = is error. WindowsFileOpenSystem is function for opening folders from windows.
nacti.b '                                                   create list all playble files in selected folder to swap file, load it to memory, then delete swap file. Create unsorted list!

'RndPlay 1 OK!!!!

reload = 1 '                                                'Reload = 1 started WindowsFileOpenSystem, Reload = 0 close it.
RAP "StartDemo" '                                            Start basic mode
' WindowsFileOpenSystem ' if skiped this, its start automaticaly plays files in the same directory who is

dalsi:
IF _SNDPLAYING(zvuk&) = 0 THEN minuta = 0: sekunda = 0: oldsec = sec 'dodana podminka    Reset song time if song playing is on the end
IF posuv = 1 THEN posuv = 0: GOTO posunuto '                                             POSUV = song moving. 1 = is pressed next or back button
IF LoopOne = 1 THEN GOTO posunuto '                                                      LoopOne = is pressed neverending playing for one song, also akt muss be the same.
akt = akt + 1 '                                                                          akt = actual play track number. Here this say go playing next song in list.

posunuto:
IF LoopAll = 1 AND akt > max THEN akt = 1 '                                              This reset playing to begin, if is selected neverending playing for all songs in directory.
IF LoopAll = 0 AND akt > max THEN akt = 0: BEEP: stopp = 1: status$ = "Playlist end!" '  If all songs id directory are played to end and neverending playing for all not selected, beep and now new with status. Stopp = 1 = draw stop button to pressed.




'IF akt > max THEN akt = 1 'return plays to begin
file$ = FinalUFiles$(akt)
IF _SNDPLAYING(zvuk&) = 0 AND _SNDPAUSED(zvuk&) <> -1 AND stopp = 0 THEN hraj file$ 'tento krok zpusobuje chybu funkce STOP
IF inf = 0 THEN _TITLE "QB64 Music Player.      By Petr"
DO WHILE _SNDPLAYING(zvuk&) = -1 OR _SNDPAUSED(zvuk&) = -1 OR stopp = 1 '                  Play sound if STOP is not pressed, playing is not in the end or PAUSE is not pressed
    IF _FULLSCREEN > 0 THEN _FULLSCREEN _OFF '                                             if user press Alt + enter, do screen size back!
    Rodent '                                                                               call mouse interaction sub
    IF reload = 1 THEN reload = 0: akt = 0: GOTO dalsi '                                   this line is for RELOAD if you open next folder
    RAP FinalVFiles$(akt) '                                                                draw visible song name to screen
    '    COLOR _RGB(255, 255, 255): PRINT FinalVFiles$(akt): SLEEP
    IF inf = 0 THEN _DISPLAY '                                                             inf is for info if icon INFO on screen is pressed or not. If is, then my screen is in the background
    '_LIMIT 25
    cj '                                                                                   cj - sub named as Cesky Jazyk - english - Czech language. It make Czech characters correctly readable an othe screen.
    '--------------------------------------------------------- KEYBOARD INPUTS ---------------------------------------------- Keyboard inputs -------------
    IF inf = 1 THEN info '                                                                  return to sub INFO. INFO is waiting for pressing Esc key to end him or up/dn to read text.
    IF inf = 1 THEN GOTO rtr '                                                              if INFO icon is pressed, is keyboard input for my program off, but not for INFO window.
    i$ = INKEY$
    SELECT CASE i$
        CASE CHR$(27)
            RAP "shutdown.internal.cmd" '                                                  this shutdown this program, before is called other sub for ersing all images from memory.
        CASE CHR$(13)
            IF vs = 1 THEN vs = 0 ELSE vs = 1 '                                             switch song time    backward / normal
        CASE "P", "p"
            'previous
            RAP "getback.internal.cmd" '                                                    say - play previous song
            akt = akt - 1: posuv = 1
            i$ = ""
            IF akt < 1 THEN pl = max '                                                      if is played first song in list, then skip and play last from list
            _SNDSTOP (zvuk&) '                                                              but first stop playing current song.
            EXIT DO
        CASE "N", "n"
            'next
            RAP "getnext.internal.cmd" '                                                    say - play next song
            akt = akt + 1: posuv = 1
            i$ = ""
            IF akt > linka THEN pl = 1 'found and repaired ERROR                            if is played last song from list, then skip and play first from list
            _SNDSTOP (zvuk&) '                                                              but first stop current song.
            EXIT DO
        CASE CHR$(32)
            IF _SNDPAUSED(zvuk&) = -1 THEN _SNDPLAY (zvuk&) ELSE _SNDPAUSE zvuk& '          if is pressed spacebar, use _SNDPAUSE
        CASE "<", ","
            ch# = ch# - .01: IF ch# < -1 THEN ch# = -1
            _SNDBAL zvuk&, ch# '                                                            if is pressed < or , or . or > then reselect balance settings. Using double values.
        CASE ">", "."
            ch# = ch# + .01: IF ch# > 1 THEN ch# = 1
            _SNDBAL zvuk&, ch#
        CASE "+"
            Vol = Vol + .01: IF Vol > 1 THEN Vol = 1 '                                      if is pressed + or - then reselect volume level
            _SNDVOL zvuk&, Vol
        CASE "-"
            Vol = Vol - .01: IF Vol < 0 THEN Vol = 0
            _SNDVOL zvuk&, Vol
    END SELECT
    rtr:
LOOP

IF reload = 1 THEN GOTO dalsi 'here is curent problem?

GOTO dalsi '                                                                                   go back to DALSI, its begin this my loop and wait until song is played to end or keys are pressed.
'konec:
'_SNDSTOP (zvuk&)
'IF LoopAll = 1 THEN GOTO dalsi 'make neverending loop, plays all files from begin
END

SUB RndPlay (status AS INTEGER) 'sub is tested                                                   Create random order for playlist, status: 0 = not use random order, 1 = use random order
    SHARED max, usingRND, gen, tracknumber, stav '                                                max = maximal songs number in list, usingRND - info if song list is original or randomized
    IF RTRIM$(LTRIM$(FinalUFiles(1))) = "" OR RTRIM$(LTRIM$(FinalVFiles(1))) = "" THEN EXIT SUB
    IF usingRND = 0 THEN
        FOR StillCopy = 1 TO max
            copyU(StillCopy) = FinalUFiles(StillCopy)
            copyV(StillCopy) = FinalVFiles(StillCopy)
        NEXT
    END IF
    gen = 0
    SELECT CASE status
        CASE 0 'Random music play is OFF
            IF usingRND = 0 THEN EXIT SUB
            FOR rewrite = 1 TO max '                                                             here copying old playlist to this arrays, randomlist is ready in finalufiles and finalvfiles. Its ready for rndmusic off.
                FinalUFiles(rewrite) = copyU(rewrite)
                FinalVFiles(rewrite) = copyV(rewrite)

            NEXT
            usingRND = 0 '                                                                      select RndPlay as unused for next use

        CASE 1 'Random music play is ON
            FOR generate = 1 TO max
                gene:
                RANDOMIZE generate
                tracknumber = INT(RND * (max * 2))
                IF tracknumber > max OR tracknumber <= 0 THEN GOTO gene
                FOR ctrl = 1 TO generate
                    IF tracknumber = Track(ctrl) THEN GOTO gene
                NEXT ctrl
                gen = gen + 1
                Track(gen) = tracknumber
            NEXT
            '            PRINT "Generovana cisla stop priradim pisnickam:"

            FOR cisla = 1 TO max
                FinalVFiles(cisla) = copyV(Track(cisla))
                FinalUFiles(cisla) = copyU(Track(cisla))
            NEXT
            '            vypis
            usingRND = 1 '                                                                        Rndmusic is used and is possible rewriting arrays back if is going off.
    END SELECT
END SUB



SUB Rodent
    SHARED MouseX, MouseY, Lb, zvuk&, akt, posuv, Vol, ch#, vs, stopp, inf, LoopAll, LoopOne, LoopAllU&, LoopAllP&, LoopOneU&, LoopOneP&, i&, rndpl '  mouse interface
    IF inf = 1 THEN EXIT SUB '                                                                                                                         if INFO icon is pressed, is mouse to program window off
    DO WHILE _MOUSEINPUT
        MouseX = _MOUSEX
        MouseY = _MOUSEY
        Lb = _MOUSEBUTTON(1)
    LOOP
    White& = _RGB32(255, 255, 255)
    'mouse interaction
    IF MouseX > 27 AND MouseX < 86 AND MouseY > 40 AND MouseY < 105 AND Lb = -1 THEN GOSUB PlayPressed
    IF MouseX > 145 AND MouseX < 190 AND MouseY > 40 AND MouseY < 105 AND Lb = -1 THEN GOSUB StopPressed
    IF MouseX > 252 AND MouseX < 305 AND MouseY > 40 AND MouseY < 105 AND Lb = -1 THEN GOSUB PowerPressed
    IF MouseX > 27 AND MouseX < 86 AND MouseY > 151 AND MouseY < 209 AND Lb = -1 THEN GOSUB BackPressed
    IF MouseX > 145 AND MouseX < 190 AND MouseY > 151 AND MouseY < 209 AND Lb = -1 THEN GOSUB PausePressed
    IF MouseX > 252 AND MouseX < 305 AND MouseY > 151 AND MouseY < 209 AND Lb = -1 THEN GOSUB NextPressed
    IF MouseX > 861 AND MouseX < 900 AND MouseY > 230 AND MouseY < 265 AND Lb = -1 THEN GOSUB VolPlus
    IF MouseX > 798 AND MouseX < 835 AND MouseY > 230 AND MouseY < 265 AND Lb = -1 THEN GOSUB FilesSelect: EXIT SUB
    IF MouseX > 925 AND MouseX < 961 AND MouseY > 225 AND MouseY < 265 AND Lb = -1 THEN GOSUB VolMinus
    IF MouseX > 410 AND MouseX < 460 AND MouseY > 160 AND MouseY < 205 AND Lb = -1 THEN GOSUB BalanceLeft
    IF MouseX > 600 AND MouseX < 650 AND MouseY > 160 AND MouseY < 205 AND Lb = -1 THEN GOSUB BalanceRight
    IF MouseX > 730 AND MouseX < 923 AND MouseX > 60 AND MouseY < 93 AND Lb = -1 THEN GOSUB ViewTime
    IF MouseX > 745 AND MouseX < 785 AND MouseY > 230 AND MouseY < 265 AND Lb = -1 THEN GOSUB info
    IF MouseX > 930 AND MouseX < 960 AND MouseY > 120 AND MouseY < 155 AND Lb = -1 THEN GOSUB PressedLoopAll
    IF MouseX > 930 AND MouseX < 960 AND MouseY > 176 AND MouseY < 210 AND Lb = -1 THEN GOSUB PressedLoopOne
    IF MouseX > 933 AND MouseX < 955 AND MouseY > 94 AND MouseY < 100 AND Lb = -1 THEN GOSUB RandomPlay
    EXIT SUB
    PlayPressed:
    '_SNDPLAY (zvuk&)
    IF stopp = 1 THEN stopp = 0 '                                                             if is stop button draw as pressed, then draw it as unpressed (stop button cooperation)
    RETURN
    StopPressed:
    IF _SNDPLAYING(zvuk&) = -1 THEN _SNDSTOP (zvuk&)
    IF stopp = 1 THEN stopp = 0 ELSE stopp = 1: _DELAY 0.5 '                                  Stop button cooperation
    RETURN
    PowerPressed: RAP "shutdown.internal.cmd" '                                               Power button cooperation
    BackPressed: RAP "getback.internal.cmd": akt = akt - 1: posuv = 1: _SNDSTOP zvuk& '       Back button cooperation
    IF akt < 1 THEN pl = max
    RETURN
    PausePressed: '                                                                           Pause button cooperation
    IF _SNDPAUSED(zvuk&) = -1 THEN _SNDPLAY (zvuk&) ELSE _SNDPAUSE zvuk&
    _DELAY 0.2
    RETURN
    NextPressed: '                                                                            Next button cooperation
    RAP "getnext.internal.cmd"
    akt = akt + 1: posuv = 1
    IF pl > linka THEN pl = 1
    _SNDSTOP (zvuk&)
    RETURN
    VolPlus: Vol = Vol + .01: IF Vol > 1 THEN Vol = 1 '                                       Volume plus button cooperation
    _SNDVOL zvuk&, Vol: RETURN
    VolMinus: Vol = Vol - .01: IF Vol < 0 THEN Vol = 0 '                                      Volume minus button cooperation
    _SNDVOL zvuk&, Vol: RETURN
    FilesSelect:
    _SNDSTOP (zvuk&)
    ' IF RTRIM$(LTRIM$(FinalUFiles(1))) = "" THEN
    RndPlay 0
    rndpl = 0
    akt = 0
    WindowsFileOpenSystem '                                                                   start first folder select window in program begin
    RETURN
    BalanceLeft:
    ch# = ch# - .01: IF ch# < -1 THEN ch# = -1 '                                              balance (speakers) icon cooperation
    _SNDBAL zvuk&, ch#
    RETURN
    BalanceRight:
    ch# = ch# + .01: IF ch# > 1 THEN ch# = 1
    _SNDBAL zvuk&, ch#
    RETURN
    ViewTime: IF vs = 1 THEN vs = 0: _DELAY .1 ELSE IF vs = 0 AND ab = 0 THEN vs = 1: _DELAY .1 ' If is enter pressed, so vs = 0 = show song time from begin, vs = 1 = show song time from end
    ViewSongTime vs '                                                                           call sub for time view
    RETURN
    info:
    info '                                                                                      call sub info, this view information in data block sub info
    RETURN
    PressedLoopAll:
    IF LoopAll = 0 THEN LoopAll = 1 ELSE LoopAll = 0
    PressLoop 1 '                                                                               set loop after loop for all songs icon click
    _DELAY 0.2
    RETURN
    PressedLoopOne:
    IF LoopOne = 0 THEN LoopOne = 1 ELSE LoopOne = 0 '                                          set loop after click to icon for one song loop
    PressLoop 2
    _DELAY 0.2
    RETURN
    RandomPlay: '                                                                               cooperation with RND icon (random order music play)
    IF _SNDPLAYING(zvuk&) <> -1 THEN RETURN
    IF rndpl = 0 THEN _DELAY .01: rndpl = 1 ELSE rndpl = 0
    RETURN

END SUB


SUB PressLoop (ico AS INTEGER)
    SHARED LoopAll, LoopOne, LoopAllU&, LoopAllP&, LoopOneU&, LoopOneP&
    SELECT CASE ico
        CASE 1
            SELECT CASE LoopAll
                CASE 0
                    _PUTIMAGE (918, 115), LoopAllU&
                CASE 1
                    _CLEARCOLOR _RGB32(255, 255, 255), LoopAllP&
                    _SETALPHA 0, _RGB32(254, 255, 255) TO _RGB32(200, 200, 200), LoopAllP& '    draw loop icons on screen for both case
                    _PUTIMAGE (920, 115), LoopAllP&
            END SELECT
        CASE 2
            SELECT CASE LoopOne
                CASE 0
                    _PUTIMAGE (918, 170), LoopOneU&
                CASE 1
                    _CLEARCOLOR _RGB32(255, 255, 255), LoopOneP&
                    _PUTIMAGE (918, 170), LoopOneP&
            END SELECT
    END SELECT
END SUB


SUB info 'hodnota inf se priradi pri prvnim spusteni subu info a smaze po jeho opusteni (nastavi se na nulu)
    SHARED i&, inf, afterinfo&, sdeleni&, mov, mox, f&
    IF inf = 1 THEN GOTO block ELSE inf = 1 '                                                    info subprogram started after info icon click
    'text& = _NEWIMAGE(1024, 300, 32)
    RESTORE txt
    sdeleni& = _NEWIMAGE(1024, 300, 32)
    _DEST sdeleni&
    RESTORE txt
    FOR viewtext = 0 TO 27 '28 data linies
        READ r$
        text$(viewtext) = r$
    NEXT

    mov = 0
    block:
    _TITLE "QB64 Petr's Player - INFO window"
    LOCATE 1, 1
    SCREEN i&
    ij$ = INKEY$
    DO UNTIL ij$ = CHR$(27)
        SELECT CASE ij$
            CASE CHR$(0) + CHR$(72) 'up
                mov = mov - 1
                IF mov < 0 THEN mov = 0


            CASE CHR$(0) + CHR$(80) 'down
                mov = mov + 1
                IF mov > 11 THEN mov = 11 '                                                        11 steps because one screen use 16 linies, data block is long 28 linies, 28 - 16 = 12 - 1 = 11


        END SELECT
        _DEST sdeleni&
        mox = mov + 16 '                16 rows to one page
        IF mox > 28 THEN mox = 28 '     total linies
        FOR PAGE = mov TO mox
            PRINT RTRIM$(text$(PAGE))
        NEXT


        _CLEARCOLOR _RGB32(0, 0, 0), sdeleni&
        _SETALPHA 190, , sdeleni&


        _DEST 0
        '_PUTIMAGE (0, 0), i&, text& 'dokud nestisknes klavesu, tak se vraci rizeni pro i& mimo subu pro klavesnici a mys
        _PUTIMAGE (0, 0), sdeleni&, i&
        _DISPLAY
        ' _DELAY 0.5
        '  _DEST 0
        EXIT SUB
    LOOP

    inf = 0 'po stisku klavesy v okne info se vrati rizeni i pro klvesnici a mys a ukonci se sub info
    SCREEN i&
    _PUTIMAGE (0, 0), afterinfo&, i&
    PCOPY _DISPLAY, 1
    '_FREEIMAGE text& '
    _FREEIMAGE sdeleni&
    _TITLE "QB64 Music Player.      By Petr "


    txt:
    DATA "                                                                                                                               "
    DATA "                                                                                                                               "
    DATA "About QB Player:                                                                                    USE KEY UP / KEY DOWN / ESC"
    DATA "This open source player writed Petr. Its use QB64 commands, its based on the _SNDPLAY statement. This is my first ver- "
    DATA "sion in graphic mode. To program:"
    DATA "Is possible program using with mouse or keyboard. Use < or , and > or. for balance, + and - for volume and spacebar for pause"
    DATA "Esc to quit program, enter for song time selecting. N, n for next song in selected directory, P, p for previous song."
    DATA "With mouse is possible using LOOP one or LOOP all songs, play, stop, pause, next, previous, to time select click to song time"
    DATA "display. Two icons are for LOOP / LOOP all (songs in selected dir). "
    DATA "Files for this program: QBPlay.EXE, SKINDb.PNG, Demo.MP3. All used pictures are in the one PNG file, all pictures used in this"
    DATA "PNG file from www.eu.fotolia.com. Program read none ID3, is without equalizer and without vizualization. Is possible, next ver-"
    DATA "sion this already to have. For ID3TAG - See to http://www.qb64.net/forum/index.php?topic=14111.msg122204#msg122204,i wrote it"
    DATA "but in this version is unimplemented. In the end this program is comming monkey."
    DATA "QB64 users info:"
    DATA "SUB Rodent / mouse coordination with program. Is off if this info is view,"
    DATA "SUB WindowsFileOpenSystem / two QB64 WIKI sources in one SUB, returning path to directory in 8.3 format,"
    DATA "SUB The End - monkeys and memory cleaning sub if program get out,"
    DATA "SUB timing - yes. It calculate time. If is runned as timing TIMER, calculate current time from TIMER,"
    DATA "SUBS ViewVolume, ViewFrequency, ViewVolumeLevel... the same _PUTIMAGE subs. Many coordinates...."
    DATA "SUB rest - reset sound playng if error is comming, because _SNDPLAY generate none errors, is possible if uncompatible file is "
    DATA " loaded,"
    DATA "SUB hraj - its heart. This sub plays music."
    DATA "SUB nacti.b - this sub is my FIRST, this load files with mask filtering to memory (old version was not here used named nacti.A"
    DATA "reads it direct from harddrive), this sub is writed 14 days before i have found windows library file system..."
    DATA "SUB cj - for Czech text correct readable by SUB znak and the to correct displayed"
    DATA "SUB RAP - call other SUBS, because this sub is as graphic central, it displayed song name in the program"
    DATA "SUB znak - First write to unvisible screen song name. Then with POINT is this scaning and every point is with LINE drawing to"
    DATA "other unvisible screen. View this is then used as song name in program.                                    Happy coding! Petr"
    DATA " And now.... i need 2D game in the Commander Keen style to write..."
END SUB



SUB WindowsFileOpenSystem
    SHARED reload, zvuk&, Lb, akt, stopp, rndpl

    wfos:
    DECLARE CUSTOMTYPE LIBRARY
        FUNCTION FindWindow& (BYVAL ClassName AS _OFFSET, WindowName$)
    END DECLARE

    '_TITLE "Super Window"
    hwnd& = FindWindow(0, "QB64 Music Player.      By Petr " + CHR$(0))

    TYPE BROWSEINFO 'typedef struct _browseinfo 'Microsoft MSDN http://msdn.microsoft.com/en-us/library/bb773205%28v=vs.85%29.aspx
        hwndOwner AS LONG '              '  HWND
        pidlRoot AS _OFFSET '            '  PCIDLIST_ABSOLUTE
        pszDisplayName AS _OFFSET '      '  LPTSTR
        lpszTitle AS _OFFSET '           '  LPCTSTR
        ulFlags AS _UNSIGNED LONG '  UINT
        lpfn AS _OFFSET '                '  BFFCALLBACK
        lParam AS _OFFSET '              '  LPARAM
        iImage AS LONG '                 '  int
    END TYPE 'BROWSEINFO, *PBROWSEINFO, *LPBROWSEINFO;

    DECLARE DYNAMIC LIBRARY "shell32"
        FUNCTION SHBrowseForFolder%& (x AS BROWSEINFO) 'Microsoft MSDN http://msdn.microsoft.com/en-us/library/bb762115%28v=vs.85%29.aspx
        SUB SHGetPathFromIDList (BYVAL lpItem AS _OFFSET, BYVAL szDir AS _OFFSET) 'Microsoft MSDN http://msdn.microsoft.com/en-us/library/bb762194%28VS.85%29.aspx
    END DECLARE

    DIM b AS BROWSEINFO
    b.hwndOwner = hwnd
    DIM s AS STRING * 1024
    b.pszDisplayName = _OFFSET(s$)
    a$ = "" + CHR$(0)
    b.lpszTitle = _OFFSET(a$)
    DIM o AS _OFFSET
    o = SHBrowseForFolder(b)
    IF o THEN
        ' PRINT LEFT$(s$, INSTR(s$, CHR$(0)) - 1)
        DIM s2 AS STRING * 1024
        SHGetPathFromIDList o, _OFFSET(s2$)
        FolderLong$ = LEFT$(s2$, INSTR(s2$, CHR$(0)) - 1)

        'this function make 8.3 worlwide full compatible format to correct acces to folder with no - english chars!:
        DECLARE LIBRARY 'Directory Information using KERNEL32
            FUNCTION GetShortPathNameA (lpLongPath AS STRING, lpShortPath AS STRING, BYVAL cBufferLen AS LONG)
        END DECLARE

        '=== SHOW SHORT PATH NAME
        FileOrPath$ = FolderLong$ '<< change to a relevant path or file name on computer
        ShortPathName$ = SPACE$(260)
        Result = GetShortPathNameA(FileOrPath$ + CHR$(0), ShortPathName$, LEN(ShortPathName$))
        Folder$ = ShortPathName$

        'end of 8.3 function

    ELSE
        EXIT SUB
    END IF

    '    IF Folder$ = "" THEN EXIT SUB
    _SNDSTOP (zvuk&)
    _DELAY 0.5
    IF Folder$ = "" THEN GOTO wfos
    IF _DIREXISTS(Folder$) = 0 THEN GOTO wfos
    CHDIR Folder$
    mousex = 0: mousey = 0: Lb = 0
    '    IF stopp = 1 THEN stopp = 0
END SUB





SUB TheEnd
    SHARED zvuk&, i&, new&, obraz&, f&, GreenButtonPlay&, GreenButtonStop&, j&, d&, GreenButtonPower&, GreenButtonBack&, GreenButtonPause&, GreenButtonNext&, VolumePlus&, VolumeMinus&, ImageOpenFiles&, resicon&, infoicon&, LoopOne&, loopall&, afterinfo&
    _SNDSTOP (zvuk&)
    IF VAL(LEFT$(TIME$, 3)) > 12 THEN GOSUB opic1 ELSE GOSUB opic2
    b& = _RGB32(255, 255, 255)
    _DEST i&
    CLS
    PCOPY 1, _DISPLAY
    FOR krok = 1024 TO -1024 STEP -1
        hovno = hovno + .2: IF hovno >= 255 THEN hovno = 255
        visible = 255 - hovno
        _SETALPHA visible, b&, obraz&
        _PUTIMAGE (krok, 15), obraz&, i&
        _DISPLAY
        PCOPY 1, _DISPLAY
    NEXT
    'blok _FREE
    SCREEN 0
    _DEST 0
    _FREEFONT f&
    _FREEIMAGE GreenButtonPlay&
    _FREEIMAGE GreenButtonStop&
    _FREEIMAGE new&
    _FREEIMAGE j&
    _FREEIMAGE d&
    _FREEIMAGE GreenButtonPower&
    _FREEIMAGE GreenButtonBack&
    _FREEIMAGE GreenButtonPause&
    _FREEIMAGE GreenButtonNext&
    _FREEIMAGE VolumePlus&
    _FREEIMAGE VolumeMinus&
    _FREEIMAGE ImageOpenFiles&
    _FREEIMAGE resicon&
    _FREEIMAGE obraz&
    _FREEIMAGE i&
    _FREEIMAGE infoicon&
    '    _FREEIMAGE LoopOneU&
    '   _FREEIMAGE LoopAllU&
    '  _FREEIMAGE LoopOneP&
    ' _FREEIMAGE LoopAllP&
    _FREEIMAGE afterinfo&
    _SNDCLOSE zvuk&
    SYSTEM
    opic1:
    obraz& = _NEWIMAGE(252, 241, 32)
    _PUTIMAGE (0, 0), new&, obraz&, (6, 410)-(260, 650)
    RETURN
    opic2:
    obraz& = _NEWIMAGE(228, 246, 32)
    _PUTIMAGE (0, 0), new&, obraz&, (273, 405)-(500, 650)
    RETURN
END SUB

SUB timing (hodnota AS DOUBLE) '                calculate time. Writed for Timer, _SndLen. Input format as TIMER or _SNDLEN WITH "."
    SHARED hodin, minut, sekund, sets
    IF hodnota < 60 THEN hodin = 0: minut = 0: sekund = hodnota: GOTO a1
    IF hodnota > 60 AND hodnota < 3600 THEN hodin = 0: minut = hodnota / 60: GOTO a2
    hodin = hodnota / 3600
    hodin$ = STR$(hodin)
    tecka = INSTR(0, hodin$, ".")
    minut = (VAL("0." + RIGHT$(hodin$, LEN(hodin$) - tecka)) * 0.6) * 100
    a2:
    minut$ = STR$(minut)
    tecka = INSTR(0, STR$(minut), ".")
    sekund = (VAL("0." + RIGHT$(minut$, LEN(minut$) - tecka)) * 0.6) * 100
    a1:
    sekund$ = STR$(sekund)
    tecka = INSTR(0, sekund$, ".")
    sets = (VAL("0." + RIGHT$(sekund$, LEN(sekund$) - tecka)) * 1) * 100
END SUB


SUB ViewSongTime (Viewtype AS INTEGER)
    SHARED zvuk&, oldsec!, d&, i&, MouseX, MouseY, Lb, sec, sekunda, minuta, mi, se, se2, hodin, minut, sekund, sets

    IF Viewtype = 1 THEN timing (_SNDLEN(zvuk&) - _SNDGETPOS(zvuk&)) ELSE timing _SNDGETPOS(zvuk&)
    minuta = INT(minut)
    sekunda = INT(sekund)
    IF sekunda = 60 THEN sekunda = 0
    set = INT(sets)

    IF set < 10 THEN set0 = 0 ELSE set0 = VAL(LEFT$(MID$(STR$(set), 2), 1))
    IF set < 10 THEN set1 = VAL(RIGHT$(STR$(set), 1))
    IF set > 10 THEN set1 = VAL(RIGHT$(STR$(set), 1))

    stp = 470: sty = -175

    SELECT CASE set1

        CASE 0
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (432 + stp, 230 + sty), d&, i&, (260, 0)-(286, 47)

    END SELECT

    stp = 440: sty = -175

    SELECT CASE set0

        CASE 0
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (432 + stp, 230 + sty), d&, i&, (260, 0)-(286, 47)

    END SELECT


    IF sekunda < 10 THEN sekunda0 = 0 ELSE sekunda0 = VAL(LEFT$(MID$(STR$(sekunda), 2), 1))
    IF sekunda < 10 THEN sekunda1 = VAL(RIGHT$(STR$(sekunda), 1))
    IF sekunda > 10 THEN sekunda1 = VAL(RIGHT$(STR$(sekunda), 1))

    stp = 370: sty = -175

    SELECT CASE sekunda0

        CASE 0
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (432 + stp, 230 + sty), d&, i&, (260, 0)-(286, 47)

    END SELECT

    stp = 400: sty = -175

    SELECT CASE sekunda1

        CASE 0
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (432 + stp, 230 + sty), d&, i&, (260, 0)-(286, 47)

    END SELECT

    '    minuta = 20

    IF minuta < 10 THEN minuta0 = 0 ELSE minuta0 = VAL(LEFT$(MID$(STR$(minuta), 2), 1))
    IF minuta < 10 THEN minuta1 = minuta 'VAL(RIGHT$(STR$(minuta), 1))
    IF minuta >= 10 THEN minuta1 = VAL(RIGHT$(STR$(minuta), 1))
    '    IF sec < 60 AND minuta < 1 THEN minuta = 0

    stp = 300: sty = -175

    SELECT CASE minuta0

        CASE 0 TO 0.99
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (285, 0)-(320, 47)

        CASE 1 TO 1.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (1, 0)-(33, 47)

        CASE 2 TO 2.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (30, 0)-(57, 47)

        CASE 3 TO 3.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (64, 0)-(95, 47)

        CASE 4 TO 4.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (95, 0)-(120, 47)

        CASE 5 TO 5.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (130, 0)-(154, 47)

        CASE 6 TO 6.99
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (156, 0)-(185, 47)

        CASE 7 TO 7.99
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (190, 0)-(217, 47)

        CASE 8 TO 8.99
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (225, 0)-(250, 47)

        CASE 9 TO 9.99
            _PUTIMAGE (432 + stp, 230 + sty), d&, i&, (260, 0)-(286, 47)

    END SELECT

    stp = 330: sty = -175

    SELECT CASE minuta1

        CASE 0 TO 0.99
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (285, 0)-(320, 47)

        CASE 1 TO 1.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (1, 0)-(33, 47)

        CASE 2 TO 2.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (30, 0)-(57, 47)

        CASE 3 TO 3.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (64, 0)-(95, 47)

        CASE 4 TO 4.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (95, 0)-(120, 47)

        CASE 5 TO 5.99
            _PUTIMAGE (430 + stp, 230 + sty), d&, i&, (130, 0)-(154, 47)

        CASE 6 TO 6.99
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (156, 0)-(185, 47)

        CASE 7 TO 7.99
            _PUTIMAGE (424 + stp, 230 + sty), d&, i&, (190, 0)-(217, 47)

        CASE 8 TO 8.99
            _PUTIMAGE (426 + stp, 230 + sty), d&, i&, (225, 0)-(250, 47)

        CASE 9 TO 9.99
            _PUTIMAGE (432 + stp, 230 + sty), d&, i&, (260, 0)-(286, 47)

    END SELECT






END SUB















SUB ViewFrequency
    SHARED d&, i&
    s = _SNDRATE
    '    s = 25864
    'use 5 chracters to view frequency
    Ach = VAL(LEFT$(STR$(s), 2))
    Bch = VAL(LEFT$(MID$(STR$(s), 3), 1))
    Cch = VAL(LEFT$(MID$(STR$(s), 4), 1))
    Dch = VAL(LEFT$(MID$(STR$(s), 5), 1))
    Ech = VAL(LEFT$(MID$(STR$(s), 6), 1))

    '    COLOR _RGB32(255, 255, 255): PRINT Ach, Bch, Cch, Dch, Ech   'ALL pass
    stp = 165

    SELECT CASE Ach


        CASE 0
            _PUTIMAGE (426 + stp, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (427 + stp, 230), d&, i&, (260, 0)-(286, 47)

    END SELECT

    stp = 190

    SELECT CASE Bch

        CASE 0
            _PUTIMAGE (426 + stp, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (427 + stp, 230), d&, i&, (260, 0)-(286, 47)



    END SELECT

    stp = 215

    SELECT CASE Cch

        CASE 0
            _PUTIMAGE (426 + stp, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (427 + stp, 230), d&, i&, (260, 0)-(286, 47)

    END SELECT

    stp = 240

    SELECT CASE Dch

        CASE 0
            _PUTIMAGE (426 + stp, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (427 + stp, 230), d&, i&, (260, 0)-(286, 47)

    END SELECT

    stp = 265

    SELECT CASE Ech

        CASE 0
            _PUTIMAGE (426 + stp, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (427 + stp, 230), d&, i&, (260, 0)-(286, 47)

    END SELECT

END SUB








SUB ViewBalanceLevel (channel AS DOUBLE)
    SHARED d&, i&, ch#
    '                                    Left Speaker --------#--------  Right Speaker       - usable with mouse to left or right speaker or keyboard "<" and  ","  or ">" and "." Full funcionality only
    '                                                -100 to  0  to 100                        with WAV files.
    REM    lvl& = _NEWIMAGE(150, 150, 32)
    _PUTIMAGE (400, 150), d&, i&, (321, 0)-(392, 65)
    _PUTIMAGE (590, 150), d&, i&, (321, 0)-(392, 65)

    LINE (480, 185)-(580, 185), _RGB32(0, 0, 0)
    LINE (525 - (channel# * 50), 175)-(535 - (channel# * 50), 195), _RGB32(20, 40, 20), BF
    '    COLOR _RGB32(255, 255, 255): PRINT  'ok, funguje s double
    REM  _FREEIMAGE lvl&




END SUB






SUB ViewVolumeLevel
    SHARED Vol, d&, i&
    bila& = _RGB32(255, 255, 255)
    bila2& = _RGB32(215, 215, 215)
    _SETALPHA 0, bila& TO bila2&, d&

    Volume = CINT(Vol * 100)
    '    Volume = 256
    IF LEN(STR$(Volume)) = 4 THEN fv = 1 ELSE fv = 0
    IF LEN(Volume) >= 2 THEN sv = VAL(LEFT$(RIGHT$(STR$(Volume), LEN(Volume) - 2), LEN(Volume) - 3)) ELSE sv = 0 'stale druha pozice i pri vol = 56
    Tv = VAL(RIGHT$(STR$(Volume), 1))
    '   firstV$ = "1"
    '  _DEST i&
    ' COLOR bila&
    '    CLS
    '   PRINT sv, 'STR$(Volume)
    '    SLEEP
    'fv = 0

    SELECT CASE fv 'first character Volume. Its 0 or 1 --------------------------  vloz to do noveho pole& a tam trochu zpruhledni ty bily segmenty a teprve pak to vloz do i&

        CASE 0
            'load null to view
            _PUTIMAGE (392, 230), d&, i&, (285, 0)-(320, 45)

        CASE 1
            'load one to view
            _PUTIMAGE (400, 230), d&, i&, (1, 0)-(23, 47)


    END SELECT
    'COLOR _RGB32(255, 255, 255): PRINT Tv ', LEN(STR$(Volume)) ' overeno, ze sv ukazuje spravne cislo, overeno a spraveno FV!, overena spravna hodnota Tv  - here i tested it
    'multipl = (23 * sv) + 10
    SELECT CASE sv 'second volume character. 0 - 9
        CASE 0
            _PUTIMAGE (426, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (422, 230), d&, i&, (252, 0)-(286, 47)

    END SELECT

    stp = 30

    SELECT CASE Tv 'third volume character. 0 - 9

        CASE 0
            _PUTIMAGE (426 + stp, 230), d&, i&, (285, 0)-(320, 47)

        CASE 1
            _PUTIMAGE (430 + stp, 230), d&, i&, (1, 0)-(33, 47)

        CASE 2
            _PUTIMAGE (430 + stp, 230), d&, i&, (30, 0)-(57, 47)

        CASE 3
            _PUTIMAGE (430 + stp, 230), d&, i&, (64, 0)-(95, 47)

        CASE 4
            _PUTIMAGE (430 + stp, 230), d&, i&, (95, 0)-(120, 47)

        CASE 5
            _PUTIMAGE (430 + stp, 230), d&, i&, (130, 0)-(154, 47)

        CASE 6
            _PUTIMAGE (424 + stp, 230), d&, i&, (156, 0)-(185, 47)

        CASE 7
            _PUTIMAGE (424 + stp, 230), d&, i&, (190, 0)-(217, 47)

        CASE 8
            _PUTIMAGE (426 + stp, 230), d&, i&, (225, 0)-(250, 47)

        CASE 9
            _PUTIMAGE (427 + stp, 230), d&, i&, (260, 0)-(286, 47)

    END SELECT
END SUB

SUB rest
    SHARED akt, pokus
    ' BEEP
    '  WindowsFileOpenSystem
    IF PlEr = 1 THEN PlEr = 0: BEEP: WindowsFileOpenSystem
    pokus = pokus + 1
    akt = 0 + pokus - 1
    nacti.b
    reload = 1
    RAP "StartDemo"
END SUB






SUB hraj (plaj AS STRING)
    IF plaj$ = "" THEN EXIT SUB
    IF PlEr = 1 THEN EXIT SUB
    SHARED zvuk&, hraju, ch#, Vol, reload, PlEr
    IF _SNDPLAYING(zvuk&) = -1 THEN PRINT "Sorry, now playing": EXIT SUB ELSE _SNDCLOSE (zvuk&) '    This is music program hearth.
    zvuk& = _SNDOPEN(plaj$, "VOL, PAUSE, SETPOS, SYNC, LEN"): ' oldzvuk& = _SNDCOPY(zvuk&)
    IF zvuk& > 0 THEN PRINT "" ELSE PRINT "File not ready - "; file$; "or uncompatible!": rest
    hraju = 1
    _SNDBAL zvuk&, ch# * 1000 'i have here not enought place for 5.1 / 7.1 speakers. :-D
    _SNDVOL zvuk&, Vol '  _SNDBAL funcionality is correct only with garanteed file types.
    _SNDPLAY zvuk&
    IF _SNDPLAYING(zvuk&) = 0 THEN _SNDPLAY (zvuk&)
END SUB

SUB nacti.b
    SHARED seznam2$, NewRecNr, linka, max, reload: RESTORE FileMask
    seznam2$ = "": NewRecNr = 0: linka = 0: max = 0: reload = 0
    'nacte a vyfiltruje soubory do poli Rfiles a Vfiles (Read and open files a Viewed as files)

    comm$ = "dir *.* /x > filelist.qb64" '                                            vylistuje vsechny soubory ve slozce  8.3 a LONG / DIR make file filelist.qb64 with old type and new type file names
    SHELL _HIDE comm$
    IF _FILEEXISTS("filelist.qb64") = 0 THEN _DEST 0: PRINT "Error on line 1264: File list not created!": EXIT SUB 'chybu odchyti funkce plaj vypisem varovani
    OPEN "filelist.qb64" FOR INPUT AS #1
    zacatek:
    IF EOF(1) THEN GOTO konec
    LINE INPUT #1, nothing$ '                                                        This read rows from DIR outputfile and load its to memory. Its better for harddrive, for SSD extra!
    linies = linies + 1
    'PRINT linies
    seznam2$(linies) = nothing$
    GOTO zacatek
    konec:
    CLOSE #1
    KILL "filelist.qb64"
    'PRINT "Transformuji Seznam na pole U a V (usable a visible)"
    '    IF linies = 0 THEN _DEST 0: PRINT "No files for play.(line 1276)": BEEP: EXIT SUB
    FOR test = 0 TO linies '                                                       This For...Next read array seznam and make two new arrays: Vfiles and Ufiles. Ussable for us is record from row 7 to row
        '    PRINT seznam$(test); " = record nr. "; test '                              linies - 3
        text = text + 1
        ' IF text > 6 AND text < linies - 3 THEN             vyrazeno verzi 0.21C - necetl vsechny mozne soubory.

        VFiles$(test) = RIGHT$(seznam2$(test), LEN(seznam2$(test)) - 49)
        UFiles$(test) = RIGHT$(LEFT$(seznam2$(test), 49), 13)
        IF VFiles$(test) <> "" AND LTRIM$(UFiles$(test)) = "" THEN UFiles$(test) = VFiles$(test) 'LTRIM$ remove spaces. This IF muss to be used, because if filename is <8 characters or is used compatible
        '  COLOR , 2: PRINT "UFILE RECORD"; UFiles$(test) 'VTK OK!                                   filename with American ASCII, then filename is writed only as Vfile (visible and unvisible name is the same)
        '  COLOR , 6: PRINT "VFILE RECORD"; VFiles$(test) ' VTK OK!
        'END IF
    NEXT


    FOR mask = 1 TO 11 '                                                                     Have 11 filetypes in DATA - am end this sub
        READ FileMask$ '                                                                     in arrays we have all files in the directory. I need only types in DATA command. This filemask is filter.
        FOR FileFilter = 0 TO linies
            a$ = RIGHT$(LTRIM$(UCASE$(LEFT$(UFiles$(FileFilter), (INSTR(0, UFiles$(FileFilter), ".") + 3)))), 3)
            IF a$ = FileMask$ THEN MaskUFiles$(FileFilter) = RTRIM$(UFiles$(FileFilter)): MaskVFiles$(FileFilter) = RTRIM$(VFiles$(FileFilter))
            ' PRINT FileMask$, RIGHT$(LTRIM$(UCASE$(LEFT$(UFiles$(FileFilter), (INSTR(0, UFiles$(FileFilter), ".") + 3)))), 3), mask, FileFilter,
            ' PRINT a$, FileMask$: SLEEP
            'sleep
        NEXT FileFilter
    NEXT mask

    COLOR 7, 0
    'REDIM MaskUFiles
    'REDIM MaskVFiles
    IF linies = 0 THEN reload = 0: EXIT SUB

    FOR vypis = 0 TO linies 'here is already created filelist using filemask in DATA. But in array are empty records, this muss be removed.

        IF MaskUFiles$(vypis) = STRING$(255, "") THEN GOTO nowrite ELSE NewRecNr = NewRecNr + 1: FinalUFiles$(NewRecNr) = LTRIM$(MaskUFiles$(vypis))
        IF MaskVFiles$(vypis) = STRING$(255, "") THEN GOTO nowrite ELSE NewRecNr2 = NewRecNr2 + 1: FinalVFiles$(NewRecNr2) = LTRIM$(MaskVFiles$(vypis))

        nowrite:
    NEXT vypis
    IF NewRecNr <= 0 THEN reload = 0: EXIT SUB
    'IF RTRIM$(FinalUFiles$(1)) = "" THEN reload = 0: BEEP: EXIT SUB
    '   PRINT NewRecNr: SLEEP               chyba.
    'BEEP
    'COLOR _RGB32(255, 255, 255)
    'FOR ControlLoop = 0 TO NewRecNr

    'PRINT FinalUFiles$(ControlLoop); ControlLoop; NewRecNr
    'PRINT FinalVFiles$(ControlLoop); ControlLoop; NewRecNr2
    'PRINT "MaskUFiles record NR:"; vypis; MaskUFiles$(vypis); "LEN:"; LEN(MaskUFiles$(vypis))
    'PRINT "MaskVFiles record NR:"; vypis; MaskVfiles$(vypis); "LEN:"; LEN(MaskVfiles$(vypis))
    'SLEEP
    'NEXT ControlLoop

    'here are sub outputs:
    'NewRecNr - number new records - files accepts filemask
    'FinalUFiles$(record_number) - list files accepts filemasks, usable to file access
    'FinalVFiles$(record_number) - list files accepts filemasks, unusable to file acces if filename contains non US characters, but usable to correct view filenames with non US characters with _MAPUNICODE
    'If filename contains US compatible characters, are both records the same.

    'ERASE seznam2$, UFiles$, VFiles$, MaskUFiles$, MaskVFiles$
    'RESTORE FileMask



    FileMask:
    DATA WAV,OGG,AIFF,RIFF,VOC,MP3,MIDI,MOD,AIF,RIF,MID
    linka = NewRecNr: max = NewRecNr

END SUB


SUB cj '                                                                                      Sub make Czech characters readable correctly on the screen. If you needed use this
    '                                                                                         for other language, is possible, you needed others DATA block. Data blocks are
    RESTORE Microsoft_pc_cpMIK '                                                              for more languages in QB64 help (Shift + F1 / Alphabetical index / _MAPUNICODE statement /
    '                                                                                         Code Pages)
    FOR ASCIIcode = 128 TO 255 '                                                              But if your problem is in acces to files with no english names, see to sub nacti.b used in
        '                                                                                     this program. This is first, based on DIR /X, uses 8.3 filenames, is full compatible for ALL
        READ unicode '                                                                        languages. It have 2 outputs. One as long filenames uses national characters, two in 8.3 to
        '                                                                                     file access. 8.3 is full compatible with all languages.
        _MAPUNICODE unicode TO ASCIIcode '                                                    And i. I need adress in memory to read sound wave. For drawing sound waves to screen :-D

    NEXT



    EXIT SUB


    Microsoft_pc_cpMIK:

    DATA 199,252,233,226,228,367,263,231,322,235,336,337,238,377,196,262
    DATA 201,313,314,244,246,317,318,346,347,214,220,356,357,321,215,269
    DATA 225,237,243,250,260,261,381,382,280,281,172,378,268,351,171,187
    DATA 9617,9618,9619,9474,9508,193,194,282,350,9571,9553,9559,9565,379,380,9488
    DATA 9492,9524,9516,9500,9472,9532,258,259,9562,9556,9577,9574,9568,9552,9580,164
    DATA 273,272,270,203,271,327,205,206,283,9496,9484,9608,9604,354,366,9600
    DATA 211,223,212,323,324,328,352,353,340,218,341,368,253,221,355,180
    DATA 173,733,731,711,728,167,247,184,176,168,729,369,344,345,9632,160

END SUB




SUB RAP (text AS STRING)
    IF text$ = "shutdown.internal.cmd" THEN GOTO sht
    SHARED t&, i&, InsertX, ch#, f&, zvuk&, GreenButtonPlay&, GreenButtonStop&, GreenButtonPower&, viewto, GreenButtonBack&, viewto2, GreenButtonNext&, GreenButtonPause&, MouseX, MouseY, vs
    SHARED resicon&, res, i&, polar, bmx, stopp, LoopAll, RandPlayOn&, RandPlayOff&, rndpl
    IF text$ = "StartDemo" THEN text$ = "Waiting": GOTO startdemo
    IF LEN(text$) > 75 THEN text$ = LEFT$(text$, 75)
    IF _SNDPLAYING(zvuk&) = 0 AND _SNDPAUSED(zvuk&) = 0 THEN znak "...STOP...": GOTO sk
    IF _SNDPAUSED(zvuk&) = -1 THEN znak RTRIM$("+   -Paused-    +"): GOTO sk

    startdemo:
    znak text$
    sk:
    _DEST i&
    black& = _RGB32(0, 0, 0)

    _SETALPHA 0, black&, t&
    IF InsertX > 7 * (LEN(RTRIM$(text$)) * _FONTWIDTH(f&)) THEN InsertX = -920 'display have 7 characters
    sht:
    IF text$ <> "StartDemo" THEN PCOPY 1, _DISPLAY
    ViewVolumeLevel
    ViewBalanceLevel ch#
    ViewFrequency
    PressLoop 1: PressLoop 2
    IF vs = 0 THEN ViewSongTime 0 ELSE ViewSongTime 1: GOSUB viewicon
    IF rndpl = 0 THEN _PUTIMAGE (930, 91), RandPlayOff&, i&: RndPlay 0 ELSE _PUTIMAGE (930, 91), RandPlayOn&, i&: RndPlay 1


    REM LOCATE 16, 1: COLOR _RGB(255, 255, 255): PRINT MouseX, MouseY, LoopAll
    LINE (435, 33)-(710, 128), _RGB32(0, 0, 0), B 'cernej obdelnik kolem TITLE

    IF text$ = "shutdown.internal.cmd" THEN _SNDSTOP (zvuk&): _PUTIMAGE (237, 41), GreenButtonPower&, i&: _DISPLAY: SLEEP 1: TheEnd
    IF _SNDPLAYING(zvuk&) = -1 THEN _PUTIMAGE (-1, 42), GreenButtonPlay&, i&
    IF _SNDPLAYING(zvuk&) = 0 AND _SNDPAUSED(zvuk&) = 0 AND text$ <> "shutdown.internal.cmd" THEN _PUTIMAGE (117, 41), GreenButtonStop&, i&
    IF text$ = "getback.internal.cmd" THEN viewto = TIMER + 4: text$ = "" ' this make green visible to 4 sec
    IF viewto > TIMER THEN _PUTIMAGE (7, 151), GreenButtonBack&, i&
    IF text$ = "getnext.internal.cmd" THEN viewto2 = TIMER + 4: text$ = ""
    IF viewto2 > TIMER THEN _PUTIMAGE (227, 151), GreenButtonNext&, i&
    IF _SNDPAUSED(zvuk&) = -1 THEN _PUTIMAGE (117, 151), GreenButtonPause&, i&

    _PUTIMAGE (450, 30)-(700, 144), t&, i&, (InsertX, -8)-(InsertX + 500, 150)
    InsertX = InsertX + 10
    'COLOR _RGB32(255, 255, 255): LOCATE 1, 1: PRINT _SNDLEN(zvuk&)
    'doresit posuv pouze pres usek textu, ne pres cely t& - JES bracho, mas to hotovy.
    EXIT SUB

    viewicon:
    res = res + polar / 2
    IF res >= 250 OR res <= 0 THEN polar = -polar
    IF res < 0 THEN res = 0: polar = -polar
    IF res > 255 THEN res = 255: polar = -polar

    _SETALPHA res, , resicon&
    _PUTIMAGE (865, 27), resicon&, i&
    'COLOR _RGB(255, 255, 255): PRINT res

    RETURN
END SUB


SUB znak (txt AS STRING)
    'udela kompletni obraz do t&, txt$ prichazi spravne
    SHARED t&, f&, linka, akt, printed$
    text& = _NEWIMAGE(1980, 100, 32)
    _DEST t&: CLS
    _DEST text&
    cj
    _FONT f&

    printed$ = "(" + LTRIM$(STR$(akt)) + "/" + LTRIM$(STR$(linka)) + ")"
    '    IF linka > akt THEN linka = 1
    toend = 140 - LEN(printed$)
    PRINT printed$; txt$ ' + STRING$(toend, CHR$(32))
    '    SCREEN text&: SLEEP
    black& = _RGB32(0, 0, 0)
    cil = LEN(txt$) * 29
    _SOURCE text&
    FOR rozlozX = 0 TO cil
        FOR rozlozY = 1 TO 29
            scan& = POINT(rozlozX, rozlozY)
            IF scan& <> black& THEN _DEST t&: LINE ((tx + (rozlozX * 4)) - 2, (ty + (rozlozY * 4)) - 2)-((tx + (rozlozX * 4)) + 2, (ty + (rozlozY * 4)) + 2), _RGB32(33, 33, 38), B
            _DEST text&
        NEXT
    NEXT
    '    SCREEN t&: SLEEP
    'cast co vklada text na "displej" je v RAP
    _DEST i& 'pocat
    _FREEIMAGE text&
END SUB










