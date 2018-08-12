
NAME SDL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                            Serial Download                                 ;
;                            Serial Routines                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Contains Functions For
;			1. Downloading Paths over the serial channel
;			2. Execute a Step from a path
;			3. Reset the Path i.e go to the 1st step
;			4. Display the next step
;			5. Clear Path (remove all steps from path)
;			6. Run Path run the path
;
;
; Input:            Key Presses from Key Pad, Serial Path data
; Output:           Motor Control Data	
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

$INCLUDE(SDL.INC)
$INCLUDE(SETTINGS.INC)

EXTRN	Display	:NEAR
EXTRN	ClearDisplay	:NEAR
EXTRN	RotateCrane	:NEAR
EXTRN	LowerCrane	:NEAR
EXTRN	EnergizeMagnet	:NEAR
EXTRN	displayNum	:NEAR
EXTRN	GetKey		:NEAR
EXTRN	IsaKey		:NEAR
EXTRN	SerialGetChar	:NEAR
EXTRN	ParseSerialChar	:NEAR


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA

; SerialDownLoad
;
; Description:      This Function Parses characters received from the serial channel.
;			The function ends if there's an error or end of path is 
;			indicated.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX, ES, SI
; Stack Depth:      3 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

SerialMenu	PROC	NEAR
		PUBLIC	SerialMenu


	PUSH	AX	; Save Registers
	PUSH	ES
	PUSH	SI

	MOV	AX, SEG StringBuffer	; Display message to acknowledge menu entry
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 83
	MOV	ES:[SI], AL		; 83 - S
	INC	SI
	MOV	AL, 79
	MOV	ES:[SI], AL		; 116 - D
	INC	SI			
	MOV	AL, 76
	MOV	ES:[SI], AL		; 76 - L
	INC	SI
	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI

	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message


SDLLoop:

	
	CALL	GetKey		; Get Key from Key pad	

	CMP	AL, Key22	; If Key = DownLoad Then
	JE	DownLoadPath	; 	download the path

	CMP	AL, Key23	; If Key = execute Then
	JE	ExecuteStep		; 	execute the next step

	CMP	AL, Key33	; If Key = reset Then
	JE	ResetPath	; 	reset the current path

	CMP	AL, Key24	; If Key = clear Then
	JE	ClearPath	; 	clear the current path
	
	CMP	AL, Key34	; If Key = Run Then
	JE	RunPath		; 	Run the current Path

	CMP	AL, Key14	; If Key = Display Angle Then
	JE	DisplayAngle	; 	display the angle of next step

	CMP	AL, Key13	; If Key = Display Vert Then
	JE	DisplayVert	; 	display the vert of next step

	CMP	AL, Key12	; If Key =  Return Then
	JE	SDLReturn	; 	download the path

DownLoadPath:

	CALL	SerialDownload	;Down load a path
	JMP	EndSDL

ExecuteStep:

	CALL	ExecStep	; execute next step in path
	JMP	EndSDL

ResetPath:

	CALL	Reset		; reset the path i.e go to the first step
	JMP	EndSDL

ClearPath:

	Call	Clear		; clear all steps in path
	JMP	EndSDL

RunPath:

	Call	Run	; Run the entire path
	JMP	EndSDL

DisplayAngle:

	CALL	DisplayAgl	; display the angle of next path step
	JMP	EndSDL

DisplayVert:

	CALL	DisplayVrt	; display the vert of next path step
	JMP	EndSDL

EndSDL:

	JMP	SDLLoop		; Loop back to the top

SDLReturn:
	
	POP	SI
	POP	ES	
	POP	AX		; restore registers

	RET		; done - go back to previous menu

SerialMenu	ENDP

; SerialDownLoad
;
; Description:      Downloads a path from the serial channel and stores it in an array
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX, ES, SI
; Stack Depth:      3 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002


SerialDownLoad	PROC	NEAR
		

	PUSH	AX	; Save Registers
	PUSH	ES
	PUSH	SI
	
	CALL	ClearDisplay
	
	MOV	AX, SEG StringBuffer	; Display message to acknowledge menu entry
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 100
	MOV	ES:[SI], AL		; 100 - d
	INC	SI
	MOV	AL, 108
	MOV	ES:[SI], AL		; 108 - l
	INC	SI			
	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI

	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message


	MOV	PathStepPtr, 0		; Initialize the path pointer
	MOV	PathStepSize, 0		; Initialize the path size

DownLoadLoop:

	CALL 	IsaKey		; Check if there is a key
	JZ	NoStop		; If no key then there is no stop
	JNZ	CheckWhatKey	; If there's a key check what it is

CheckWhatKey:

	CALL	GetKey		; get the key pressed
	CMP	AL, Key32	; If Halt Key the STOP !
	JE	EndDownLoadPath	;
	JNE	NoStop		; Otherwise keep doing download

NoStop:

	CALL	SerialGetChar	; Get a character from the serial channel
	
	CALL	ParseSerialChar	; Parse the character

	CMP	AL, 0		; If path error, or path end
	JNE	EndDownLoadPath	; we have finished downloading

	JMP	DownLoadLoop	; Otherwise Get another character and parse

EndDownLoadPath:

	POP	SI
	POP	ES	
	POP	AX	; restore registers

	RET		; done

SerialDownLoad	ENDP

; BeginPath
;
; Description:      Initializes a path by resetting all pointers in the pathh arrays
;
; Arguments:        Path Number
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX,
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

BeginPath	PROC	NEAR
		PUBLIC	BeginPath

	MOV	PathNumber, AX		; set path number
	MOV	PathStepSize, 0		; initialize pointers
	MOV	PathStepPtr, 0


	RET

BeginPath	ENDP

; StorePathStep
;
; Description:      Stores a step parsed by the serial channel in a series of arrays
;		    for future path movements
;
; Arguments:        (DX) Angle - Angle of Rotation
;		    (CH) ArFlag- Way of Rotation
;		    (BX) Vert - Length of vertical movement
;		    (CL) VrFlag - Way of Vertical movement
;		    (AL) Magnet - status of the magnet On or Off
;
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  Arrays
;
; Registers Used:   AX, ES, SI
; Stack Depth:      3 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

StorePathStep	PROC	NEAR
		PUBLIC	StorePathStep

	PUSH	ES		
	PUSH	SI
	PUSH	AX
	
	MOV	AX, SEG VertArray
	MOV	ES, AX			; get memory location of vert array
	MOV	AX, OFFSET VertArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; store the vertical motion of step
	MOV	ES:[SI], BX

	MOV	AX, SEG VrflagArray
	MOV	ES, AX			; get memory location of VrFlag array
	MOV	AX, OFFSET VrFlagArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; store vertical orientation for step
	MOV	ES:[SI], cL

	MOV	AX, SEG AngleArray
	MOV	ES, AX			; get memory location of Angle array
	MOV	AX, OFFSET AngleArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; add new step to the end of the array
	MOV	ES:[SI], DX

	MOV	AX, SEG ArFlagArray
	MOV	ES, AX			; get memory location of ArFlag array
	MOV	AX, OFFSET ArFlagArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; store vertical orientation for step
	MOV	ES:[SI], CH

	MOV	AX, SEG MagnetArray
	MOV	ES, AX			; get memory location of Magnet array
	MOV	AX, OFFSET MagnetArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; store vertical magnet status for step
	
	POP	AX		; retore the value of AX
	MOV	ES:[SI], AL

	ADD	PathStepSize, 2		; increment the size of the buffer, (2 word)

	RET

StorePathStep	ENDP

; ExecPath
;
; Description:      Executes a step in the path staore from serial download
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  Arrays
;
; Registers Used:   AX, BX, ES, SI
; Stack Depth:      4 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

ExecStep	PROC	NEAR


	PUSH	AX
	PUSH	BX
	PUSH	ES		; Save registers
	PUSH	SI

	MOV	AX, PathStepPtr
	CMP	PathstepSize, AX 	; If path is empty
	JE	EndExecjmp			;  then nothing to execute

	MOV	AX, SEG MagnetArray
	MOV	ES, AX			; get memory location of Magnet array
	MOV	AX, OFFSET MagnetArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	
	MOV	AX, ES:[SI]	; get the magnet status for the path

	CMP	AX, Magnet_Neutral	; Check if magnet if to switch on or off
	JG	EnergizeMag		;  if switch on then energize magnet
	JL	DeEnergizeMag		;  else de energize magnet
	JMP	MoveAngle		; If no change the continue

EnergizeMag:

	MOV	AX, MagnetOn		; set magnet on
	CALL	EnergizeMagnet
	MOV	CraneMagnet, MagnetOn
	JMP	MoveAngle		; now take care of rotation

DeEnergizeMag:

	MOV	AX, MagnetOff		; set magnet off
	CALL 	EnergizeMagnet
	MOV	CraneMagnet, MagnetOff
	JMP	MoveAngle		; now take care of rotation

MoveAngle:

	MOV	AX, SEG ArFlagArray
	MOV	ES, AX			; get memory location of  Ararray
	MOV	AX, OFFSET ArFlagArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]		; get value for angular orientation
	
	CMP	AX, Absolute		; Check if Angle is Absolute or Relative
	JE	AbsoluteAngle		;  appropriately jump to the next code
	JNE	RelativeAngle

EndExecjmp:

	JMP	EndExec			; End Exec Jump Booster
	
AbsoluteAngle:

	MOV	AX, SEG AngleArray
	MOV	ES, AX			; get memory location of  Angle Arrat
	MOV	AX, OFFSET AngleArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]	; Get the angle

	MOV	CraneAngle, AX	; Undate Absolute angle

	CALL	RotateCrane	; Rotate the crane
	JMP	MoveVert

RelativeAngle:

	MOV	AX, SEG AngleArray
	MOV	ES, AX			; get memory location of  Angle Array
	MOV	AX, OFFSET AngleArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]	; Get the angle

	ADD	AX, CraneAngle	; Calculate new absolute position
	MOV	CraneAngle, AX	; Undate Absolute angle

	CALL	RotateCrane	; Rotate the crane
	JMP	MoveVert

MoveVert:

	MOV	AX, SEG VrFlagArray
	MOV	ES, AX			; get memory location of  Vrarray
	MOV	AX, OFFSET VrFlagArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]		; get value for angular orientation
	
	CMP	AX, Absolute		; Check if Vert is Absolute or Relative
	JE	AbsoluteVert		;  appropriately jump to the next code
	JNE	RelativeVert

AbsoluteVert:

	MOV	AX, SEG VertArray
	MOV	ES, AX			; get memory location of  Vert Array
	MOV	AX, OFFSET VertArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]	; Get the length

	MOV	BX, AX		; Calculate relative position
	SUB	AX, CraneVert
	MOV	CraneVert, BX

	CALL	LowerCrane	; Rotate the crane
	JMP	EndExec	; goto end

RelativeVert:

	MOV	AX, SEG VertArray
	MOV	ES, AX			; get memory location of Vert Array
	MOV	AX, OFFSET AngleArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]	; Get the length

	MOV	BX, AX		; Calculate relative position
	ADD	AX, CraneVert
	MOV	CraneVert, BX

	CALL	LowerCrane	; Rotate the crane
	JMP	EndExec

EndExec:

	ADD	PathStepPtr, 2 ; increment the pointer by two (cos word)

	POP	SI	
	POP	ES
	POP	BX
	POP	AX

	RET

ExecStep	ENDP

; Reset
;
; Description:      Set the Path step pointer = 0 (i.e go to the first step)
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002


Reset	PROC	NEAR

	MOV	PathStepPtr, 0	; restart at the top of array
	RET

Reset	ENDP

; Run
;
; Description:      Runs the path that is stores in the arrays that was downloaded
;			from the serial channel
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

Run		PROC	NEAR

	PUSH	AX	; save AX

	CALL	ResetPath	; go to the begining of the path

LoopWhileRunPath:
	
	MOV	AX, PathStepSize	
	CMP	PathStepPtr, AX		; if path is empty then nothing
					;   to run
	JE	EndRunPath		;  then we are done

	CALL	ExecStep		; execute next step
	JMP	LoopWhileRunPath
	

EndRunPath:

	POP	AX	; restore AX

	RET

Run	ENDP

; Clear
;
; Description:      Erase all path data in the path arrays
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

Clear	PROC	NEAR

	MOV	PathStepPtr, 0		; reset the pointers !
	MOV	PathStepSize, 0		;  it's all that is required

	RET

Clear	ENDP

; DisplayAgl
;
; Description:      Display the angle of the next step
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  Arrays
;
; Registers Used:   AX, ES, SI
; Stack Depth:      3 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

DisplayAgl	PROC	NEAR

	PUSH	AX
	PUSH	ES
	PUSH	SI

	MOV	AX, SEG AngleArray
	MOV	ES, AX			; get memory location of  Angle Array
	MOV	AX, OFFSET AngleArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]	; Get the Angle

	CALL	DisplayNum	; Display the Angle

	RET

DisplayAgl	ENDP

; DisplayVrt
;
; Description:      Display the vertical distance of the next step
;
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  Arrays
;
; Registers Used:   AX, ES, SI
; Stack Depth:      3 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 16 2002

DisplayVrt	PROC	NEAR

	PUSH	AX
	PUSH	ES
	PUSH	SI

	MOV	AX, SEG VertArray
	MOV	ES, AX			; get memory location of  Vert Array
	MOV	AX, OFFSET VertArray
	MOV	SI, AX

	ADD	SI, PathStepSize	; Add the current loaction of the step being
					; executed
	MOV	AX, ES:[SI]	; Get the length

	CALL	DisplayNum	; Display the vertical length

	RET

DisplayVrt	ENDP

	
CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'




EXTRN	StringBuffer	:BYTE	; ; Buffer for storing display messages
EXTRN   CraneAngle	:WORD   ; Holds the Absolute Angle       
EXTRN   CraneVert	:WORD   ; Holds the Absolute Vertical position	       
EXTRN   CraneMagnet	:WORD  	; Holds the status of the magnet        

PathNumber	DW	?
PathStepSize	DW	?
PathStepPtr	DW	?

VertArray          DW      Path_Size DUP(?)	; Vertical motion array
VrFlagArray        DW      Path_Size DUP(?)	; vertical motion orientation array
AngleArray         DW      Path_Size DUP(?)	; Angular motion array
ArFlagArray        DW      Path_Size DUP(?)	; Angular motion orientation array
MagnetArray        DW      Path_Size DUP(?)	; Magnet status array



DATA    ENDS


        END