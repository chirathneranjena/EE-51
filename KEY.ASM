
NAME Key

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    Key                                     ;
;                              Keypad Routines                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with the keypad. Includes
;			IsAKey - Sets the zero flags appropriately if a key is pressed
;		        GetKey - Returns a key that has been pressed 				
;
; Input:            None.
; Output:           Zero Flag, KeyValue (AL)
;
; User Interface:   requires the user to press keys in keypad
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	21, Feb 2002	Creation



CGROUP  GROUP   CODE


$INCLUDE(51MAIN.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA


; Scan
;
; Description:      Keypad Scaning routines
;
; Arguments:        None.
; Return Value:     NewKey, NewKeyRow
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: KeyStatus - 0 - No key, 1 - Key pressed, 2 - Key Debpunced
;		    KeyRow    - row in keypad pressed
;		    Key	      - Key in keypad row being pressed		
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       Scan row in Key pad.
;                   If a key is pressed then debounce it
;                   Else go back to no key status    
; Data Structures:  None.
;
; Registers Used:   AX, BX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB. 21 2002

SCAN		PROC	NEAR
		PUBLIC	SCAN

CheckKeyStatus:
	
        MOV     AL, KeyStatus
        CMP     AL, KeyPressedState     ; Check Key Status
	JL	NoKey			;   IF There is no Key Check for a Keypress
	JE	KeyPressed		;   IF there is a keypress debounce it	
	JG	KeyDebounced		;   IF the key has been debounced then hold.	

NoKey:

	CALL	ScanRow			;   Scan row on keypad
        CMP     AL, NoKeyValue          ;   IF There is a Key THEN
	JNE	NewKeyPress		;     do stuff for new keypress
        MOV     AX, KeyRow
        ADD     AX, 1
        MOV     KeyRow, AX              ;   IF NOT go to the next row
        CMP     AX, KeyDebouncedState   ;     See if row exceeds row on kepad
        JG      ResetKeyRow             ;       then adjust
        JLE     EndScan                 ;    Otherwise we are done

ResetKeyRow:

        MOV     KeyRow, 0               ; Reset the Row being scanned
	JMP	EndScan			; Finish, go to the end

NewKeyPress:

	MOV	KeyStatus, KeyPressedState ; Set Key Status = Key Pressed
	MOV	Key, AL			; Store pressed key
	MOV	KeyDebounceTime, 0	; Reset KeyDebounceTime
	JMP	EndScan			; All done

KeyPressed:

	CALL	ScanRow			;  Scan row on keypad
        CMP     AL, NoKeyValue          ;  Check if the Key is still being pressed
	JE	KeyReleased		;      If not then reset
	CMP	AL, Key			;  Check if the same key
	JNE	KeyReleased		;	If not then reset
					;  Otherwise
        MOV     AX, KeyDebounceTime         ;    Increment debounce time
        ADD     AX, 1
        MOV     KeyDebounceTime, AX

        MOV     AX, DebounceTime
        MOV     BX, KeyDebounceTime
        CMP     AX, BX                          ; If Debounce complete
	JGE	KeyJustDebounced		;   Set variables
	JMP	EndScan				; Otherwise Finish

KeyJustDebounced:

	MOV	KeyStatus, KeyDebouncedState		; Key has debounced
	MOV	KeyAvailable, 1		; Set KeyAvailable = true
        MOV     BL, Key
        MOV     NewKey, BL              ; Store the Key pressed
        MOV     BX, KeyRow
        MOV     NewKeyRow, BX           ; Also store the row number of the Key
	JMP	EndScan			; Alright done

KeyDebounced:

	CALL	ScanRow			; Scan row in Keypad
        CMP     AL, NoKeyValue          ; Check if the key is still been pressed
	JE	KeyReleased		;   If not then reset
	CMP	AL, Key			; Check if same Key
	JNE	KeyReleased		;   If not then reset
	JMP	EndScan			;  Otherwise go to finish

KeyReleased:
	
	MOV	KeyStatus, NoKeyState		; No more key press
        MOV     KeyAvailable, NoKeyState        ; KeyAvailable = false
	JMP	EndScan			; Done

EndScan:

	RET

Scan		ENDP


; ScanRow
;
; Description - Scans the keypad for a keypress
;
; Arguments:        None.
; Return Value:     Pressed Key value
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: KeyRow		
;
; Input:            None.
; Output:           AL
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   DX, AL
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB. 21 2002

ScanRow		PROC	NEAR
                PUBLIC  ScanRow

	MOV	DX, KeyPadPort
        ADD     DX, KeyRow                  ;   Go to the required row in Keypad

	IN	AL, DX			; Get the key

	RET				; get back

ScanRow		ENDP
	

; IsAKey
;
; Description:      Sets the zeroflag if no key is available
;			Resets the zeroflag if key is available
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  AX
;                  
; Shared Variables: None.
; Global Variables: KeyAvailable  - indicates whether a key is available
;                  
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB 20, 2002





IsAKey		PROC	NEAR
		PUBLIC	IsAKey


	PUSH	AX			; Save registers

        MOV     AL, KeyAvailable
        CMP     AL, False               ; Check KeyAvailable and set the flag

EndIsAKey:                              

	POP	AX			; Restore registers
        RET

IsAKey	ENDP



; GetKey
;
; Description:      Sits in a loop until a key has been pressed and then returns the Key pressed in AL
;

; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  BX, DX 
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           AL Key Code
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    21 FEB 2002

GetKey		PROC	NEAR
		PUBLIC	GetKey

	PUSH	BX
	PUSH	CX


LoopWhileNoKey:

        CALL    IsAKey                  ; While Zero flag = 0 
        JZ      LoopWhileNoKey          ;   Check for Key using IsAkey
                                        ; ENDWHILE

        MOV     AL, NewKey              ; Get whichkey was pressed
        SUB     AL, 00C0H               ; convert it to a number
	MOV	BL, AL

	MOV	AX, NewKeyRow		; get row of the pressed key
	MOV	CX, 00010H
	MUL	CX
	MOV	CX, AX			; convert it to the code

	MOV	AL, BL
	ADD	AL, CL			; Store in AL
        MOV     Keyavailable, NoKeyState         ; Done with key, now no key
point:        
	POP	CX
	POP	BX			; Restore the registers

	RET

GetKey	ENDP

CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


Key             DB      ?
KeyStatus	DB	0
KeyRow          DW      0
KeyDebounceTime DW      ?


NewKey          DB      ?		; Holds the value of a new key being pressed
		PUBLIC	NewKey

NewKeyRow       DW      ?		; row of the key just pressed
		PUBLIC	NewKeyRow

KeyAvailable    DB      0		; holds whether a key has been pressed or not
		PUBLIC	KeyAvailable


DATA    ENDS


        END
