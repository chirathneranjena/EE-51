
NAME Settings

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Settings                                   ;
;                             RoboCrane Settings                             ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with the setup of miscellanious
;			Robocrane Settings
;			User Changable Settings include
;				- Setting the Baud Rate of the serial channel
;				- Setting the Parity
;				- Changing the Origin of absolute movements of 
;				  Robocrane
;
;
; Input:            KeyPad
; Output:           None	
;
; User Interface:   KeyPad, Display
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	18 Mar 2002	Creation

CGROUP  GROUP   CODE


$INCLUDE(SETTINGS.INC)


EXTRN	Display	:NEAR
EXTRN	GetKey	:NEAR
EXTRN	ClearDisplay	:NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA

; SettingsMenu
;
; Description:      Function handles the certain settings of the Robocrane system
;			
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: CraneAngle, CraneVert
;		    
;		    
;
; Input:            KeyPad Input
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
; Last Modified:    Mar 18 2002

SettingsMenu	PROC	NEAR
		PUBLIC	SettingsMenu

	PUSH	AX


SettingLoop:

	MOV	AX, SEG StringBuffer	; Display message to acknowledge menu entry
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 83
	MOV	ES:[SI], AL		; 83 - S
	INC	SI
	MOV	AL, 69
	MOV	ES:[SI], AL		; 116 - E
	INC	SI			
	MOV	AL, 115
	MOV	ES:[SI], AL		; 65 - t
	INC	SI
	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI

	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message



	CALL	GetKey		;Get key from Keypad

	CMP	AL, Key32	; If Key = Baud
	JE	Baud		;   Initiate Change Baud

	CMP	AL, Key33	; If key = parity
	JE	Parity		;   Initiate Change Parity

	CMP	AL, Key34	; If Key = Origin
	JE	SetOrigin	;   Change Origin	

	CMP	AL, Key12	; If Key = Return	
	JE	SettingsReturn	;   Go back to main menu

	JMP	EndSettings

Baud:

	CALL	SetBaud		; need to change baud rate
	JMP	EndSettings

Parity:

	CALL 	SetupParity	; need to change parity
	JMP	EndSettings

SetOrigin:

	MOV	CraneVert, 0	; set current location of crane
	MOV	CraneAngle, 0	;   as origin

	CALL	ClearDisplay	; indicate the change has been made
	JMP	EndSettings

EndSettings:

	JMP	SettingLoop	; Go back to the top

SettingsReturn:

	POP	AX		; restore registers

	RET			; done

SettingsMenu	ENDP

; SetBaud
;
; Description:      Function sets the Baud rate of the serial channel
;			
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None.
;		    
;		    
;
; Input:            KeyPad Input
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
; Last Modified:    Mar 18 2002


SetBaud		PROC	NEAR

	
	PUSH	AX	; Save register

	MOV	AX, SEG StringBuffer	; Display message to acknowledge menu entry
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 56
	MOV	ES:[SI], AL		; 83 - B
	INC	SI
	MOV	AL, 65
	MOV	ES:[SI], AL		; 116 - A
	INC	SI			
	MOV	AL, 85
	MOV	ES:[SI], AL		; 65 - U
	INC	SI
	MOV	AL, 68
	MOV	ES:[SI], AL		; 68 - D
	INC	SI
	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI

	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message

SetBaudLoop:

	CALL	GetKey		; Get Key From Key pad

	CMP	AL, Key12	; Baud rate 300
	JE	B300	

	CMP	AL, Key13	; Baud rate 1200
	JE	B1200	

	CMP	AL, Key14	; Baud rate 4800
	JE	B4800	
	
	CMP	AL, Key22	; Baud rate 9600
	JE	B9600	

	CMP	AL, Key23	; Baud rate 19200
	JE	B19200	

	CMP	AL, Key24	; Baud rate 57600
	JE	B57600	

	JMP	SetBaudLoop

B300:
	MOV	AX, Baud_300	; get baud rate divsor for 300
	JMP	SetBaudEnd

B1200:
	MOV	AX, Baud_1200	; get baud rate divsor for 1200
	JMP	SetBaudEnd

B4800:
	MOV	AX, Baud_4800	; get baud rate divsor for 4800
	JMP	SetBaudEnd

B9600:
	MOV	AX, Baud_9600	; get baud rate divsor for 9600
	JMP	SetBaudEnd

B19200:
	MOV	AX, Baud_19200	; get baud rate divsor for 19200
	JMP	SetBaudEnd

B57600:
	MOV	AX, Baud_57600	; get baud rate divsor for 57600
	JMP	SetBaudEnd

SetBaudEnd:


	MOV	DX, Serial_LCR		; Enable Access to Divisor Latch Access Bit
	MOV	AX, Enable_DL_Acc
	OUT	DX, AL

	MOV	DX, Serial_DL		; Set Baud Rate
	OUT	DX, AL
	INC	DX
	MOV	AL, AH
	OUT	DX, AL

	POP	AX

	RET

SetBaud	ENDP


; SetParity
;
; Description:      Function sets the Parity of the serial channel
;			
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None.
;		    
;		    
;
; Input:            KeyPad Input
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
; Last Modified:    Mar 18 2002


SetupParity	PROC	NEAR

			
	PUSH	AX	; Save register

	MOV	AX, SEG StringBuffer	; Display message to acknowledge menu entry
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 80
	MOV	ES:[SI], AL		; 83 - P
	INC	SI
	MOV	AL, 65
	MOV	ES:[SI], AL		; 116 - A
	INC	SI			
 	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI
	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message

SetParityLoop:

	CALL	GetKey		; Get Key From Key pad

	CMP	AL, Key13	; Set Odd Parity
	JE	SetOddParity	

	CMP	AL, Key23	; Set Even Parity
	JE	SetEvenParity	

	CMP	AL, Key33	; Set Mark Parity
	JE	SetMarkParity	
	
	CMP	AL, Key24	; Set 'Set' Parity
	JE	SetSetParity	

	CMP	AL, Key34	; set No Parity
	JE	SetNoParity


	JMP	SetParityLoop


SetOddParity:

	MOV	AL, OddParity	; get odd parity LCR value
	JMP	SetParityEND

SetEvenParity:

	MOV	AL, EvenParity	; get Even parity LCR value
	JMP	SetParityEND

SetMarkParity:

	MOV	AL, MarkParity	; get Mark parity LCR value
	JMP	SetParityEND

SetSetParity:

	MOV	AL, SetParity	; get Set parity LCR value
	JMP	SetParityEND

SetNoParity:

	MOV	AL, NoParity	; get No parity LCR value
	JMP	SetParityEND


SetParityEnd:


	MOV	DX, Serial_LCR		; Set Parity
	OUT	DX, AL


	POP	AX

	RET

SetupParity	ENDP

CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'

EXTRN	StringBuffer	:BYTE	; ; Buffer for storing display messages

EXTRN   CraneAngle	:WORD   ; Holds the Absolute Angle       
EXTRN   CraneVert	:WORD   ; Holds the Absolute Vertical position	       
       



DATA    ENDS


        END
