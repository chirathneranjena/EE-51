
Name Stepper
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Stepper                                    ;
;                              Stepper Routines                              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with stepping the Robocrane motors
;			and turning the crane magnet on/off
;
;
; Input:            None 
; Output:           Stepping data for motors and magnet toggle value
;
; User Interface:   None
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	17 Mar 2002	Creation

CGROUP	GROUP	CODE

$INCLUDE(STEPPER.INC)

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA

; InitParallel
;
; Description:      Initialize the parallel port for motor functions
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: None
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 18 2002

InitParallel    PROC    NEAR
                PUBLIC  InitParallel

        MOV     DX, MotorControl	; write the control word to parallel
        MOV     AX, PortCtrVal		;	control register
        OUT     DX, AX

        RET

InitParallel    ENDP

; StepperEventHandler
;
; Description:      Interrupt Handler for Stepper Functions
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: AngleStatus, TableAnglePtr, AngleStep, VertStatus
;		    TableVertPtr, VertStep, MagnetStatus,MagnetValue
;	            OverrallStatus, CurrentAngle, AngleMotion, VertMotion

; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           Stepper Motor Values
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB. 21 2002

StepperEventHandler	PROC	NEAR
			PUBLIC	StepperEventHandler

        PUSHF           ; Save Registers
	
	PUSH	AX
	PUSH	BX
	PUSH	DX

CheckAngleStatus:

	MOV	BX, StepTableSize	; Keep BX=table size - 1 for future
	SUB	BX, 1			;  comparisons

	CMP	AngleStatus, Pending	; If there is no pending angular movement
	JNE	CheckVertStatus		; then check if there's a pending 
					; vertical movement
	
	CMP	AngleMotion, Reverse	; Check if the angle motion is reverse
	JE	AngleMotionReverse	;    take care of the reverse motion
	
	DEC	TableAnglePtr		; go up one step on the table	
	
	CMP	TableAnglePtr, 0	; if the pointer reaches the top
	JGE	SendAngleDataToPort	;  then pointer is set to the bottom of
	MOV	TableAnglePtr, BX	;  the table
        JMP     SendAngleDataToPort

AngleMotionReverse:
	
	INC	TableAnglePtr		; go down one step on the table

	CMP	TableAnglePtr, BX	; if table pointer is at the bottom
	JLE	SendAngleDataToPort	; then set it back to the top

	MOV	TableAnglePtr, 0


SendAngleDataToPort:

	MOV	BX, OFFSET StepperTable	; Get the next pattern for the 
        MOV     AX, TableAnglePtr       ;       stepper motor from the table 
	XLAT	CS:StepperTable

	MOV	DX, AngleMotor		; Rotate the Stepper Motor
        OUT     DX, AL  

	DEC	AngleStep		; Decrement No of steps to complete step
	CMP	AngleStep, 0 		;  If No of steps more is not Zero
	JNE	CheckVertStatus		;   then Do Vertical Motor movement
	
	MOV	AngleStatus, Free	; No more pending angular movements	

CheckVertStatus:

	CMP	VertStatus, Pending	; If there is no pending vertical movement
        JNE     CheckMagnetStatus       ; then check if there's a pending 
					; vertical movement

	CMP	VertMotion, Reverse	; If vertical motion is in reverse
	JE	VertMotionReverse	; then take care of it	
					
	DEC	TableVertPtr		; go up one step on the table
	
	CMP	TableVertPtr, 0		; if the pointer is at the top
	JGE	SendVertDataToPort	; then set the pointer back to the bottom
	MOV	TableVertPtr, BX
        JMP     SendVertDataToPort

VertMotionReverse:

	INC	TableVertPtr		; go down one step on the table

	CMP	TableVertPtr, BX	; if the pointer has reached the bottom
	JLE	SendVertDataToPort	; of the table then

	MOV	TableVertPtr, 0		; set the pointer back to the top


SendVertDataToPort:

	MOV	BX, OFFSET StepperTable	; Get the next pattern for the 
        MOV     AX, TableVertPtr        ;       stepper motor from the table 
	XLAT	CS:StepperTable

        OR      AX, MagnetValue
	MOV	DX, VertMotor
        OUT     DX, AL

	Dec	VertStep		; Decrement No of steps to complete step
	CMP	VertStep, 0		;  If No of steps more is not Zero
        JNE     CheckMagnetStatus               ;   then Do Magnet On/Off

	MOV	VertStatus, Free	; No more pending Vertical movements

CheckMagnetStatus:

	CMP	MagnetStatus, Pending	; If the magnet need not be turned on or off
	JNE	CheckOverallStatus	;   go to check the overall status
	
	MOV	BX, OFFSET StepperTable	; Get the next pattern for the 
        MOV     AX, TableVertPtr                  ;       stepper motor from the table 
	XLAT	CS:StepperTable

        MOV     DX, MagnetPort          ; get the value fromt the Magnet/Vertical port
        ;IN      AX, DX

        OR      AX, MagnetValue         ; Set the Magnet on or Off
        OUT     DX, AL   

	MOV	MagnetStatus, Free	; No more magnet functions

CheckOverallStatus:

        MOV     AX, AngleStatus
        CMP     AX,Pending              ;If AngleStatus <> Pending Then
	JE	EndStepperHandler	;  IF VertStatus <> Pending Then	
        MOV     AX, VertStatus
        CMP     AX, Pending             ;       IF MagnetStatus <> Pending Then
	JE	EndStepperHandler	;
        MOV     AX, MagnetStatus
        CMP     AX, Pending             ;
	JE	EndStepperHandler

	MOV	OverrallStatus, Free	;		OverrallStatus = Free	

EndStepperHandler:
	
        MOV     DX, INTCtrlrEOI
        MOV     AX, Timer2EOI
        OUT     DX, AL

	POP	DX			; Restore Registers
        POP     BX
	POP	AX
	
        POPF


	IRET				; Done



StepperEventHandler	ENDP

; RotateCrane
;
; Description:      calculates and stores the number of steps for a rotation
;
; Arguments:        Rotate Angle
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: AngleStatus, AngleStep, OverrallStatus, AngleMotion	
; Global Variables: NOne.
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 18 2002


RotateCrane	PROC	NEAR
		PUBLIC	RotateCrane

	PUSH	BX	; Save the registers
	PUSH	DX

LoopWhilePendingA:

	CMP	OverrallStatus, Pending	; Loop Until Crane movement is done
	JE	LoopWhilePendingA

			
CalcAbsAngle:


        MOV     BX, CurrentAngle	 ; Convert Angle to Absolute Angle
        MOV     CurrentAngle, AX	 ;  Save the Current Angle of Crane

        SUB     AX, BX                 
                                        
	CMP	AX, 0			;IF Angle >= 0 then
	JGE	PositiveAngle		; 
	JL	NegativeAngle	

PositiveAngle:

	MOV	AngleMotion, Straight	; remember that the movement is striaght
	JMP	CalcAngleSteps	

NegativeAngle:

	MOV	AngleMotion, Reverse	; remember that the movement is reverse	
	NEG	AX

CalcAngleSteps:

	MOV	BX, 10			; no of steps = (10 * Angle) / 
	MUL	BX			;	(degress per step x 10)
	MOV	BX, DegreesPerStepx10
	MOV	DX, 0
	DIV	BX
	MOV	AngleStep, AX		; save the number of steps
	MOV	AngleStatus, Pending	; setoff flags for initiating rotation
	MOV	OverrallStatus, Pending

	POP	DX
	POP	BX
	
	RET

RotateCrane	ENDP

; LowerCrane
;
; Description:      calculates and stores the number of steps for a Vertical movement
;
; Arguments:        length of motion
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: VertStatus, VertStep, OverrallStatus, VertMotion	
; Global Variables: NOne.
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 18 2002

LowerCrane	PROC	NEAR
		PUBLIC	LowerCrane

	PUSH	BX	;Save registers

LoopWhilePendingV:

	CMP	OverrallStatus, Pending	; Loop Until Crane movement is done
	JE	LoopWhilePendingV

			
	CMP	AX, 0			;IF Vert >= 0 then
	JGE	PositiveVert		; motion is upwards
	JL	NegativeVert		;ELSE	
					; motion is downwards
PositiveVert:

	MOV	VertMotion, Straight	; remember that the movement is straight
	JMP	CalcVertSteps	

NegativeVert:

	MOV	VertMotion, Reverse	; remember that the movement is reverse
	NEG	AX

CalcVertSteps:

	MOV	BX, 10			; no of steps = legth * 10 / inches per step x 10
	MUL	BX
	MOV	BX, InchesPerStepx10
	MOV	DX, 0
	DIV	BX
	MOV	VertStep, AX		; save no steps
	MOV	VertStatus, Pending	; set off flags for crane motion
	MOV	OverrallStatus, Pending

	POP	BX
	
	RET

LowerCrane	ENDP

; EnergizeMagner
;
; Description:      Energize or DeEnergize the crane magnet
;
; Arguments:        Magnet On/Off
; Return Value:     None.
;
; Local Variables:  None
;
; Shared Variables: MagnetStatus, OverrallStatus
; Global Variables: NOne.
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
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 18 2002

EnergizeMagnet	PROC	NEAR
		PUBLIC	EnergizeMagnet

LoopWhilePendingM:

	CMP	OverrallStatus, Pending	; Loop Until Crane movement is done
	JE	LoopWhilePendingM	

	CMP	AX, 0			; if argument = 0 then
	JE	DeEnergize		;   denergize the magnet
	JNE	Energize		; else take care of energizing the magnet

Energize:

	MOV	MagnetValue, MagnetOn	; turn on magnet
	MOV	MagnetStatus, Pending	; set off flags for change
	MOV	OverrallStatus, Pending
	JMP	EndMagnet

DeEnergize:

	MOV	MagnetValue, MagnetOff	; turn off magnet
	MOV	MagnetStatus, Pending	; set off flags for change	
	MOV	OverrallStatus, Pending
	JMP	EndMagnet

EndMagnet:
	
	RET		; done, return	

EnergizeMagnet	ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					;
;    Stepper Motor Step byte Values	;
;					;
;					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StepperTable 	LABEL   BYTE
                PUBLIC  StepperTable


        DB      00001010B
        DB      00001000B            
        DB      00001001B             
        DB      00000001B              
        DB      00000101B             
        DB      00000100B             
        DB      00000110B              
        DB      00000010B               
 

StepTableSize      EQU     8         ;


CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


AngleStatus             DW      0	; holds whether there's a pending angular mortion
TableAnglePtr           DW      4	; holds current position in the table for angles
AngleStep		DW	0	; holds the number of steps remaining	

VertStatus              DW      0	; holds whether there's a pending vertical mortion
TableVertPtr            DW      4	; holds current position in the table for vertical
VertStep                DW      0	; holds the number of steps remaining

MagnetStatus		DW	0	; magnet on or off status
MagnetValue		DW	0	; value written to the port to change magner

OverrallStatus		DW	0	; keeps track if all motion is complete

CurrentAngle		DW	0	; absolute angle for rotaional motion

AngleMotion		DW	0	; holds whether motion is reverse ot not
VertMotion		DW	0	; holds whether motion is reverse ot not
DATA    ENDS


        END
