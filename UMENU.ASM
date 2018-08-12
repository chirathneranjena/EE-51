
NAME UserMenu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 UserMenu                                   ;
;                           Manual Control Routines                          ;
;                                of RoboCrane                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      The function containing the Manual Control Routines of
;			RoboCrane.
;
; Input:            KeyPad Key Inputs
; Output:           RoboCrane Stepper Motor Control Values	
;
; User Interface:   KeyPad and LED Display
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	18 Mar 2002	Creation


CGROUP  GROUP   CODE


$INCLUDE(51MAIN.INC)

EXTRN	Display	:NEAR
EXTRN	GetKey	:NEAR

EXTRN	LowerCrane	:NEAR
EXTRN	RotateCrane	:NEAR
EXTRN	EnergizeMagnet	:NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA

; UserMenu
;
; Description:      Function gets the key presses from the key pad and
;		    appropriately sends motor control values to the
;		    RoboCrane.
;		    -   see attached keypad layout for functions assigned
;			to each key
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: StringBuffer, CraneVert, CraneAngle, CraneMagnet
;		    
;		    
;
; Input:            Key Pad Input
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX
; Stack Depth:      1 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 18 2002




UserMenu	PROC	NEAR
		PUBLIC	UserMenu

	PUSH	AX	; Save Registers

	MOV	AX, SEG StringBuffer	; Display message to acknowledge menu entry
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 85
	MOV	ES:[SI], AL		; 83 - U
	INC	SI
	MOV	AL, 83
	MOV	ES:[SI], AL		; 116 - S
	INC	SI			
	MOV	AL, 69
	MOV	ES:[SI], AL		; 65 - E
	INC	SI
	MOV	AL, 114
	MOV	ES:[SI], AL		; 114 - r
	INC	SI
	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI

	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message


UserLoop:

	
	CALL	GetKey		; Get Key from Key pad	

	CMP	AL, Key13	; If key = Up
	JE	CraneRaise	;     Lower Crane
	CMP	AL, Key33	; If Key =  Down
	JE	CraneLower	;     Raise Crane	

	CMP	AL, Key22	; If key = Left
	JE	CraneRotLeft	;     rotate anti clock wise
	CMP	AL, Key24	; If Key =  Right
	JE	CraneRotRight	;     rotate clock wise	

	CMP	AL, Key23	; If key = Middle
	JE	MagnetChange	;     Change Magnet Status

	CMP	AL, Key12	; If key = Return
        JE      UserReturn    ;     go back to main menu

	JMP	EndUser

CraneRaise:

	MOV	AX, 5
	ADD	CraneVert, AX	; remember the new position of the crane
	CALL	LowerCrane	; raise the crane (5)
	JMP	EndUser

CraneLower:

	MOV	AX, -5
	ADD	CraneVert, AX	; remember the new position of the crane
	CALL	LowerCrane	; Lower the crane (5)
	JMP	EndUser

CraneRotLeft:

	SUB	CraneAngle, 5
	MOV	AX, CraneAngle		; remember the new position of the crane
	CALL	RotateCrane		; Rotate the crane (-5)
	JMP	EndUser

CraneRotRight:

	ADD	CraneAngle, 5
	MOV	AX, CraneAngle		; remember the new position of the crane
	CALL	RotateCrane		; Rotate the Crane (5)
	JMP	EndUser

MagnetChange:

	CMP	CraneMagnet, MagnetOn	; Check the Current ctatus of the magnet
	JE	TurnMagnetOff		;  If magnet is On then
	JNE	TurnMagnetOn

TurnMagnetOff:

	MOV	AX, 0
	CALL	EnergizeMagnet		;      	Turn off the magnet
	MOV	CraneMagnet, MagnetOff	;	remember magnet is now off
	JMP	EndUser

TurnMagnetOn:				; Else

	MOV	AX, 10
	CALL	EnergizeMagnet		;	Turn On the magnet
	MOV	CraneMagnet, MagnetOn	;	remember now the magnet is on
	JMP	EndUser			; ENDIF

EndUser:

	JMP	UserLoop		; Go back and start again

UserReturn:

	POP	AX			; restore registers
		
	RET				; return to the main menu

UserMenu	ENDP

CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'

EXTRN	StringBuffer	:BYTE	; ; Buffer for storing display messages

EXTRN   CraneAngle	:WORD   ; Holds the Absolute Angle       
EXTRN   CraneVert	:WORD   ; Holds the Absolute Vertical position	       
EXTRN   CraneMagnet	:WORD  	; Holds the status of the magnet        



DATA    ENDS


        END
