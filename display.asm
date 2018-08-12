
NAME Display

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   Display                                  ;
;                                Display Routines                            ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the functions for displaying a string, displaying a decimal number
; and displaying a hex number.
;  
;
; Display - Displays a string 
; DisplayNum - Displays a Decimal Number
; DisplayHex - Displays a Hex number 
;
;
;
; Revision History:
;	Chirath Neranjena	FEB 21, 2002	Creation
;
;


CGROUP  GROUP   CODE



$INCLUDE(51MAIN.INC)

EXTRN   Dec2String :NEAR
EXTRN   Hex2String :NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA


; LEDMux
;
; Description:      Multiplexing Function for LED display
;
; Arguments:        DisplayBuffer
; Return Value:     None.
;
; Local Variables:  AX - Segement Pattern
; Shared Variables: DisplayBuffer
; Global Variables: None.
;
; Input:            None.
; Output:           LED Digit at a time
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DX, ES, SI
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB 21, 2002


LEDMux		PROC	NEAR
		PUBLIC	LEDMux


DisplayUpdate:                           ;Update the display

        MOV     AX, SEG DisplayBuffer
        MOV     ES, AX                   ;Get Display Buffer Segment

        MOV     AX, OFFSET DisplayBuffer
        ADD     AX, Digit
        MOV     SI, AX                   ;Get Display Buffer Offset
        
        MOV     DX, LEDDisplay           ;get the display address
        ADD     DX, Digit                ;get offset for current digit
       
        MOV     AL, ES:[SI]              ;get the segment pattern number

        OUT     DX, AL                   ;output segment


NextDigit:                               ;do the next digit
        INC     Digit                    ;update digit number
        CMP     Digit, NO_DIGITS         ;have we done all the digits ?
        JB      SkipDigitAdjust

DigitAdjust:                            ;if so, wrap the digit number back to 0
        MOV     Digit, 0

SkipDigitAdjust:
        ;JMP    EndLEDMux               ;done with LED Muxing


SameDigit:                              ;on the same digit - all done
        ;JMP    EndLEDMux

ENDLEDMux:
	
        RET

LEDMux		ENDP




; Display
;
; Description:      Gets the string given by the ES:SI registers, converts into 
;                   appropriate segment patterns and writes to the display buffer.
;
; Arguments:        ES:SI String
; Return Value:     None.
;
; Local Variables:  None
;                   
; Shared Variables: None.
; Global Variables: None
;                   
;
; Input:            String
; Output:           Segment pattern to the display.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DS, DI, ES, IS
; Stack Depth:      8 words
;
; Author:           Glen George
; Last Modified:    Oct. 29, 1997



Display         PROC NEAR
                PUBLIC Display


InitDisplay:
                                        
        PUSH    AX                      ; Save Registers
        PUSH    BX
        PUSH    CX
        PUSH    DX

        PUSH    ES                      ; Save Segment & Offset Registers
        PUSH    SI
        PUSH    DS
        PUSH    DI

        CALL    ClearDisplay            ; Clear anything already in Display


        MOV     AX, SEG DisplayBuffer         ; Get Display Buffer Segment        
        MOV     DS, AX
        MOV     AX, OFFSET DisplayBuffer      ; Get Display Buffer Offset
        MOV     DI, AX
        MOV     BX, OFFSET(ASCIISegTable)	; Set the Offset of the Segement Table	

StartDisplayingDigits:

        MOV     AL, ES:[SI]             ; Get the Character to Display
        CMP     AL, 0                   ; While (char # Null) 
        JE      EndDisplay              ;   (nothing to more Display)
        ;JNE    ConvertToSegment

ConvertToSegment:

	XLAT	CS:ASCIISegTable	; Convert Character to Segment Pattern

	MOV	DS:[DI], AL		; Save in Display Buffer
	INC	SI			; Go to the Next Character
	INC	DI

	JMP	StartDisplayingDigits	; ENDWHILE

EndDisplay:

	POP	DI			; Restore the registers
	POP	DS
	POP	SI
	POP	ES

	POP	DX			
	POP	CX
	POP	BX
	POP	AX

	RET

Display	ENDP

; DisplayNum
;
; Description:      This function gets a Decimal number given by the Ax register
;                   converts to an ASCII string pattern and calls Display string to
;                   display the number on the LED display.
;
; Arguments:        AX, Decimal Number
; Return Value:     None.
;
; Local Variables: None
;              
; Shared Variables: None.
; Global Variables:
;
; Input:            None.
; Output:           ES:SI String
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB 20, 2002

DisplayNum      PROC NEAR
                PUBLIC DisplayNum

InitDisplayNum:

        PUSH    AX
        PUSH    ES

        CALL    Dec2String

ChangeDecSegments:
        MOV     AX, DS
        MOV     ES, AX

DisplayDecNumber:
        CALL    Display

EndDisplayNum:
        POP     ES
        POP     AX

        RET

DisplayNum      ENDP


; DisplayHex
;
; Description:      This function gets a Hex number given by the Ax register
;                   converts to an ASCII string pattern and calls Display string to
;                   display the number on the LED display.
;
; Arguments:        AX, Hex Number
; Return Value:     None.
;
; Local Variables: None
;              
; Shared Variables: None.
; Global Variables:
;
; Input:            None.
; Output:           ES:SI String
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB 20, 2002

DisplayHex      PROC NEAR
                PUBLIC DisplayHex

InitDisplayHex:

        PUSH    AX
        PUSH    ES

        CALL    Hex2String

ChangeHexSegments:
        MOV     AX, DS
        MOV     ES, AX

DisplayHexNumber:
        CALL    Display

EndDisplayHex:
        POP     ES
        POP     AX

        RET

DisplayHex      ENDP

; ClearDisplay
;
; Description:      Outputs a null string to the displaybuffer to clear the display
;
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables: None
;              
; Shared Variables: None.
; Global Variables:
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      6 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB 20, 2002

ClearDisplay    	PROC    NEAR
                	PUBLIC  ClearDisplay

InitClearDisplay:

        PUSH    AX              ; Save Registers
        PUSH    BX
        PUSH    CX
        PUSH    DX

        PUSH    ES
        PUSH    SI

        MOV     AX, SEG DisplayBuffer ;Get Display Buffer Segment     
        MOV     ES, AX           
        MOV     AX, OFFSET DisplayBuffer  ;Get Display Buffer Offset
        MOV     SI, AX           

        
        MOV     AL, 0           ; Save Null value in AL
        MOV     CX, 1           ; Save Digit Number in CX

        MOV     BX, NO_DIGITS

ClearDigits:

        MOV     ES:[SI], AL      ; Clear Digit
        INC     SI               ; Goto Next Digit
        INC     CX
        CMP     CX, BX           ; Have we done with all Digits?
        JLE     ClearDigits      ; If not Go back to Clearing Digits
        ;JG      EndClearDisplay ; Finished? then end function

EndClearDisplay:

        POP     SI
        POP     ES
        POP     DX              ; Restore the Registers
        POP     CX
        POP     BX
        POP     AX

        RET

ClearDisplay    ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								      ;	
; Segment Table carrying the segement patterns for ASCIII Values      ;
;								      ;	
;								      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ASCIISegTable   LABEL   BYTE
                PUBLIC  ASCIISegTable


;       DB      .gfedcba                ;ASCII character

        DB      00000000B               ;NUL
        DB      00000000B               ;SOH
        DB      00000000B               ;STX
        DB      00000000B               ;ETX
        DB      00000000B               ;EOT
        DB      00000000B               ;ENQ
        DB      00000000B               ;ACK
        DB      00000000B               ;BEL
        DB      00000000B               ;backspace
        DB      00000000B               ;TAB
        DB      00000000B               ;new line
        DB      00000000B               ;vertical tab
        DB      00000000B               ;form feed
        DB      00000000B               ;carriage return
        DB      00000000B               ;SO
        DB      00000000B               ;SI
        DB      00000000B               ;DLE
        DB      00000000B               ;DC1
        DB      00000000B               ;DC2
        DB      00000000B               ;DC3
        DB      00000000B               ;DC4
        DB      00000000B               ;NAK
        DB      00000000B               ;SYN
        DB      00000000B               ;ETB
        DB      00000000B               ;CAN
        DB      00000000B               ;EM
        DB      00000000B               ;SUB
        DB      00000000B               ;escape
        DB      00000000B               ;FS
        DB      00000000B               ;GS
        DB      00000000B               ;AS
        DB      00000000B               ;US

;       DB      .gfedcba                ;ASCII character

        DB      00000000B               ;space
        DB      00000000B               ;!
        DB      00100010B               ;"
        DB      00000000B               ;#
        DB      00000000B               ;$
        DB      00000000B               ;percent symbol
        DB      00000000B               ;&
        DB      00000010B               ;'
        DB      00111001B               ;(
        DB      00001111B               ;)
        DB      00000000B               ;*
        DB      00000000B               ;+
        DB      00000000B               ;,
        DB      01000000B               ;-
        DB      00000000B               ;.
        DB      00000000B               ;/
        DB      00111111B               ;0
        DB      00000110B               ;1
        DB      01011011B               ;2
        DB      01001111B               ;3
        DB      01100110B               ;4
        DB      01101101B               ;5
        DB      01111101B               ;6
        DB      00000111B               ;7
        DB      01111111B               ;8
        DB      01100111B               ;9
        DB      00000000B               ;:
        DB      00000000B               ;;
        DB      00000000B               ;<
        DB      01001000B               ;=
        DB      00000000B               ;>
        DB      00000000B               ;?

;       DB      .gfedcba                ;ASCII character

        DB      01011111B               ;@
        DB      01110111B               ;A
        DB      01111111B               ;B
        DB      00111001B               ;C
        DB      00111111B               ;D
        DB      01111001B               ;E
        DB      01110001B               ;F
        DB      01111101B               ;G
        DB      01110110B               ;H
        DB      00000110B               ;I
        DB      00011110B               ;J
        DB      00000000B               ;K
        DB      00111000B               ;L
        DB      00000000B               ;M
        DB      00000000B               ;N
        DB      00111111B               ;O
        DB      01110011B               ;P
        DB      00000000B               ;Q
        DB      00000000B               ;R
        DB      01101101B               ;S
        DB      00000000B               ;T
        DB      00111110B               ;U
        DB      00000000B               ;V
        DB      00000000B               ;W
        DB      00000000B               ;X
        DB      01100110B               ;Y
        DB      00000000B               ;Z
        DB      00111001B               ;[
        DB      00000000B               ;\
        DB      00001111B               ;]
        DB      00000000B               ;^
        DB      00001000B               ;_

;       DB      .gfedcba                ;ASCII character

        DB      00100000B               ;`
        DB      00000000B               ;a
        DB      01111100B               ;b
        DB      01011000B               ;c
        DB      01011110B               ;d
        DB      00000000B               ;e
        DB      00000000B               ;f
        DB      00000000B               ;g
        DB      01110100B               ;h
        DB      00000100B               ;i
        DB      00000000B               ;j
        DB      00000000B               ;k
        DB      00110000B               ;l
        DB      00000000B               ;m
        DB      01010100B               ;n
        DB      01011100B               ;o
        DB      00000000B               ;p
        DB      00000000B               ;q
        DB      01010000B               ;r
        DB      00000000B               ;s
        DB      01111000B               ;t
        DB      00011100B               ;u
        DB      00000000B               ;v
        DB      00000000B               ;w
        DB      00000000B               ;x
        DB      01101110B               ;y
        DB      00000000B               ;z
        DB      00000000B               ;{
        DB      00000110B               ;|
        DB      00000000B               ;}
        DB      00000001B               ;~
        DB      00000000B               ;rubout

CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


DisplayBuffer   DW      8 DUP(?)
                PUBLIC  DisplayBuffer

Digit           DW      0               ;the current digit number
             

DATA    ENDS


	END
