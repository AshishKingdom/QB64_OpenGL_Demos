PRINT "This program converts WAV to WAV another type (all outputs are compatible with WinAmp)"
SLEEP 2
'_SNDRAW need 4096 samples for one beep.




aa = _SNDOPENRAW
bb = _SNDOPENRAW

test = 1 '                                             Here is possible testing program with your WAV file (16 bit, 44 Khz, stereo) without making own sound with _SNDRAW.
IF test = 1 THEN '
    OPEN "11.wav" FOR BINARY AS #4
    DIM left(LOF(4) / 8) AS LONG '                     I tested outputs with WinAmp, because it happened that on another computer without updates windows mediaplayer some types not to play.
    DIM right(LOF(4) / 8) AS LONG
    PRINT "Wait, loading arrays"
    SEEK #4, 45
    FOR nacti = 1 TO UBOUND(left&)
        GET #4, , left&(nacti)
        GET #4, , right&(nacti)
    NEXT nacti
    GOTO s
ELSE

    DIM SHARED a(2 * 110252) AS SINGLE '                All arrays lenght depends on the length of the loops for function _SNDRAW
    DIM SHARED b(2 * 110252) AS SINGLE
    DIM SHARED left(2 * 110252) AS LONG
    DIM SHARED right(2 * 110252) AS LONG

    'code by DartWho - copy from QB64 help

    FREQ = 220 'any frequency desired from 36 to 10,000

    Pi2 = 8 * ATN(1) '2 * pi

    Amplitude = .3 'amplitude of the signal from -1.0 to 1.0

    SampleRate = _SNDRATE 'sets the sample rate

    FRate = FREQ / SampleRate

    PRINT "_SNDRAW:"

    FOR Duration = 0 TO 5 * SampleRate 'play 5 seconds

        _SNDRAW Amplitude * SIN(Pi2 * Duration * FRate), , aa

        '_SNDRAW Amplitude * SGN(SIN(Pi2 * Duration * FRate)), , bb

        a!(Duration) = Amplitude * SIN(Pi2 * Duration * FRate * 2) 'array left spk load        <----- HERE! ITS WRITED * 2

        b!(Duration) = Amplitude * SIN(Pi2 * Duration * FRate * 2) 'array right spk load         IF this is direct saved, are frequencies different!

    NEXT Duration




END IF

'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FOR i = 1 TO UBOUND(a!)
    left&(i) = a!(i) * (2 * _SNDRATE) '                                                             This two blocks resampling all samples for correct frequencies in to WAV file.
NEXT i '                                                                                              See also to different writing array to write wav (a! and b!) versus SNDRAW
index = 0
FOR i = 1 TO UBOUND(b!)
    right&(i) = b!(i) * (2 * _SNDRATE)
    REM PRINT right&(i), b!(i), i
NEXT i
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

s:
SaveSound 9, left&(), right&(), "Alfa.wav" '  Save generated sound to WAV file. Usage: SaveSound [wave type number], left _sndraw numbers array, right _sndraw numbers array, output WAV Filename$
'                                             WAVE types for this sub:         0 = stereo, 16 bit; 1 = mono, both 44 Khz
'                                                                              2 = stereo, 16 bit; 3 = mono, BUT both 22 Khz
'                                                                              4 = stereo, 16 bit; 5 = mono, both 11 Khz
'                                                                              6 = stereo, 16 bit; 7 = mono, both 5.5 Khz
'                                                                              8 = stereo, 16 bit; 9 = mono, both 5 Khz

_SNDRAWDONE
CLOSE #4



'finaly WAVe playing:
SLEEP 5: INPUT "And now press Enter to play recorded WAV", noinput
CLOSE

SLEEP 2
PRINT "And QB64 SNDPLAYFILE:"
h& = _SNDOPEN("alfa.wav", "VOL, SYNC")
_SNDPLAY h&
_SNDCLOSE h&
END







SUB SaveSound (styl AS INTEGER, Fleft() AS LONG, Fright() AS LONG, file AS STRING)

    leftrecords = UBOUND(fleft&) '                                                                                            return value array Fleft& lenght
    size = 44 + leftrecords * 4 - 8
    OPEN file$ FOR OUTPUT AS #1 '                                                                                             If file exists, is owerwrited.
    CLOSE #1
    OPEN file$ FOR BINARY AS #1
    SEEK #1, 45
    DIM a AS LONG, b AS LONG
    DIM a8 AS _UNSIGNED INTEGER, b8 AS _UNSIGNED INTEGER

    SELECT CASE styl

        CASE 0, 1 '                                                                                         16 bit stereo, 44 Khz, 1411 Kb/s, uncompressed, full quality. 0 = stereo, 1 = mono.
            IF styl = 0 THEN bits = 4: sys = 2 ELSE bits = 4: sys = 2 '
            IF styl = 0 THEN ch = 2: rezim = 4 ELSE ch = 1: rezim = 2
            BTCH = 16 'bits
            samplerate2 = (_SNDRATE * bits) / 4
            samplerate = _SNDRATE * bits

            stp = 1

        CASE 2, 3 '                                                                                                         22 Khz / 706 Kb/s, middle quality. 2 = stereo, 3 = mono.
            IF styl = 2 THEN bits = 4: sys = 2 ELSE bits = 4: sys = 4
            IF styl = 2 THEN ch = 2 ELSE ch = 1
            BTCH = 16 'bits

            rezim = (BTCH * ch) / 2
            samplerate2 = (_SNDRATE * bits) / 8
            samplerate = _SNDRATE * bits
            stp = 2

        CASE 4, 5 '                                                                                                         11 Khz / 176 Kb/s, very high sound compression (in wav format)
            IF styl = 4 THEN bits = 4: sys = 2 ELSE bits = 4: sys = 2 '                                                      4 = stereo, 5 = mono.
            IF styl = 4 THEN ch = 2 ELSE ch = 1 '
            BTCH = 16 '

            rezim = (BTCH * ch) / 2
            samplerate2 = (_SNDRATE * bits) / 16
            samplerate = _SNDRATE * bits
            stp = 4

        CASE 6, 7 '                                                                                                         5.5 Khz / 88 Kb/s, extremly high sound compression (in wav format)
            IF styl = 6 THEN bits = 4: sys = 2 ELSE bits = 4: sys = 2 '                                                     6 = stereo - but in this "quality"... 7 = mono.
            IF styl = 6 THEN ch = 2 ELSE ch = 1 '
            BTCH = 16

            rezim = (BTCH * ch) / 2 '
            samplerate2 = (_SNDRATE * bits) / 32
            samplerate = _SNDRATE * bits
            stp = 8

        CASE 8, 9 '*********************************************** 16 bits 5 khz stereo high compressed with INTEGER value ************************

            bits = 4 '                                                                                                       5 Khz, experimental with INTEGER array. 8 for stereo noise :-D and 9 for mono.
            IF styl = 8 THEN ch = 2 ELSE ch = 1
            BTCH = 16 'bits
            rezim = (BTCH * ch) / 2 '
            samplerate2 = (_SNDRATE * bits) / 32
            samplerate = _SNDRATE * bits * 4
            '        s = 1
            stp = 4

    END SELECT

    FOR record8 = 1 TO leftrecords STEP stp '                                                                               Wave "compression". As is here visible, this STEP stp make it. If is selected
        IF styl <= 7 THEN '                                                                                                 then is recorded only each X - sample, but not each sample.
            a& = Fleft&(record8)
            IF styl = 0 OR styl = 2 OR styl = 4 OR styl = 6 OR styl = 8 THEN b& = Fright&(record8) '                        read only if stereo is selected
            PUT #1, , a& '                                                                                                  write always to file
            IF styl = 8 OR styl = 6 OR styl = 4 OR styl = 2 OR styl = 0 THEN PUT #1, , b& '                                 write to file only if stereo is selected
        ELSE
            a8% = Fleft&(record8)
            IF styl MOD 2 = 0 THEN b8% = Fright&(record8)
            PUT #1, , a8%
            IF styl MOD 2 = 0 THEN PUT #1, , b8%


        END IF
    NEXT record8
    DATABLOCK = LOF(1)
    ' WAVE file head. Muss be correctly writed, otherwise is WAVE unreadable.
    head$ = "RIFF" + LTRIM$(MKL$(DATABLOCK - 8)) + LTRIM$("WAVE") + LTRIM$("fmt ") + LTRIM$(MKL$(16)) + LTRIM$(MKI$(1)) + LTRIM$(MKI$(ch)) + LTRIM$(MKL$(samplerate2)) + LTRIM$(MKL$(samplerate)) + LTRIM$(MKI$(rezim)) + LTRIM$(MKI$(BTCH)) + LTRIM$("data") + LTRIM$(MKL$(DATABLOCK - 44))
    'BYTES:  1-4 identificator 5-8 file size           9-12        13-16 chunk    mono/stereo/bits17-20  file type 21-22  channels 23-24      sound rate 25-28                29-32                     33-34               35-36 bits/channel   37-40 "data"  41-44 filesize - fileheadsize
    SEEK #1, 1 '                                                                                     33-34 = (bits per sample  * channels) \ x   who x is 8.1 for 8 bit mono, 2 for 8 bit stereo or 16 bit mono and 4 for 16 bit stereo (in Visual Basic)
    PUT #1, , head$
    CLOSE #1
END SUB












