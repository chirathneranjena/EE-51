
;;;					Chirath Neranjena Thouppuarachchi
;;;					EE / CS 51

NAME  MAIN
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    MAIN	                             ;
;                         EE/CS 51 Robocrane Main Function                   ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program is the main function of the Robocrane.
;		    It include the Initialization of the chip select,
;			sets the interrupt vector table, and installs the
;			timer event handler
;		    WARNING!: The program is an infinite Loop	                    		 
;
; Input:            Keys from the Keypad
; Output:           String on the LED Display.
;
; User Interface:   Keypad.
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;
;     2/21/02  Chirath Neranjena  Converted to the Main function of Robocrane		



CGROUP  GROUP   CODE

; local include files

$INCLUDE(51MAIN.INC)


EXTRN	SCAN		:NEAR
EXTRN	LEDMux		:NEAR
EXTRN	SetSerial	:NEAR
EXTRN	ClearDisplay	:NEAR
EXTRN   InitParallel    :NEAR

EXTRN	SerialInterruptHandler	:NEAR
EXTRN	StepperEventHandler	:NEAR

EXTRN	Display			:NEAR
EXTRN	GetKey			:NEAR

EXTRN	UserMenu	:NEAR
EXTRN	SettingsMenu	:NEAR
EXTRN	SerialMenu	:NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DATA, SS:STACK



START:  

MAIN:
        MOV     AX, STACK               ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(TopOfStack)

        MOV     AX, DATA                ;initialize the data segment
        MOV     DS, AX


        CALL    InitCS                  ;initialize the 80188 chip selects
                                        ;   assumes LCS and UCS already setup

        CALL    ClrIRQVectors           ;clear (initialize) interrupt vector table

                                        ;initialize the variables for the timer event handler


        CALL    InstallHandler          ;install the event handler
                                        ;   ALWAYS install handlers before
                                        ;   allowing the hardware to interrupt.

        CALL    InitTimer               ;initialize the internal timer

        CALL    SetSerial		; initialize the serial port

        CALL    InitParallel		; initialize the parallel port

        CALL    ClearDisplay            ;Clear the Display

        STI                             ;and finally allow interrupts.

Forever:

	MOV	AX, SEG StringBuffer	; Display Welcome message
	MOV	ES, AX
	MOV	AX, OFFSET  StringBuffer
	MOV	SI, AX
	
	MOV	AL, 83
	MOV	ES:[SI], AL		; 83 - S
	INC	SI
	MOV	AL, 116
	MOV	ES:[SI], AL		; 116 - t
	INC	SI			
	MOV	AL, 65
	MOV	ES:[SI], AL		; 65 - A
	INC	SI
	MOV	AL, 114
	MOV	ES:[SI], AL		; 114 - r
	INC	SI
	MOV	AL, 116
	MOV	ES:[SI], AL		; 116 - t
	INC	SI
	MOV	AL, 0
	MOV	ES:[SI], AL		; null char for termination
	INC	SI

	MOV	AX, OFFSET  StringBuffer ; return to the top of message	
	MOV	SI, AX

	CALL	Display			; now call display to display message


	


	Call GetKey		; Get key from key pad

	CMP	AL, Key11	; If key = user mode
	JE	User		;     go into user mode
	CMP	AL, Key21	; If Key = serial download mode
	JE	SerialDownLoad	;     go into serial down load mode	
	CMP	AL, Key31	; If Key = Settings Menu Mode	
	JE	Settings	;     go into settings menu	


	JMP	EndMainLoop	; If any other key jump to the end of the function

User:

	CALL	UserMenu	; Calls the Crane Manual Control Mode
	JMP	EndMainLoop

Settings:

	CALL	SettingsMenu	; Calls the Menu to set robocrane transmission
	JMP	EndMainLoop	;   settings

SerialDownLoad:

	CALL	SerialMenu	; go to serial down load mode
	JMP	EndMainLoop

EndMainLoop:

	JMP     Forever                 ;sit in an infinite loop, nothing to
                                        ;   do in the background routine

        HLT                             ;never executed (hopefully)


; TimerEventHandler
;
; Description:      This procedure is the event handler for the timer 0
;                   interrupt.  It generated interrupts for display and 
;		    keypad functions
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
; Shared Variables: None.
; Global Variables: None
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      5 words
;
; Revision     :    Chirath Neranjena  Feb. 14 2002    
;		    Chirath Neranjena  Feb. 21 2002	
;

TimerEventHandler       PROC    NEAR

        PUSHF

        PUSH    AX                      ;save the registers
        PUSH    BX                      ;Event Handlers should NEVER change
        PUSH    DX                      ;   any register values

        PUSH    ES
        PUSH    SI



	CALL	LEDMux			;do the Displaying on the LEDs

        CALL    Scan

EndTimerEventHandler:                   ;done taking care of the timer

        MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Timer0EOI
        OUT     DX, AL


        POP     SI
        POP     ES

        POP     DX                      ;restore the registers
        POP     BX
        POP     AX

        POPF

        IRET                            ;and return (Event Handlers end with IRET not RET)


TimerEventHandler       ENDP




; InitCS
;
; Description:      Initialize the Peripheral Chip Selects on the 80188.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Glen George
; Last Modified:    Oct. 29, 1997

; Reviced for use in RoboCrane
;  02/21/02 	Chirath Thouppuarachchi

InitCS  PROC    NEAR


        MOV     DX, PACSreg     ;setup to write to PACS register
        MOV     AX, PACSval
        OUT     DX, AL          ;write PACSval to PACS (base at 0, 3 wait states)

        MOV     DX, MPCSreg     ;setup to write to MPCS register
        MOV     AX, MPCSval
        OUT     DX, AL          ;write MPCSval to MPCS (I/O space, 3 wait states)


        RET                     ;done so return


InitCS   ENDP




; InitTimer
;
; Description:      Initialize the 80188 Timers.
;    		    Timer 0 is set to generate interrupts at a frequancy 1000Hz
;			User bt Display and Keypad Functions
;		    Timer 1 is set to generate interrupts by counting Timer 2
;			Frequancy 10 Hz - Used to control stepper motor stepping
;		    Timer 2 is set to count every milli second
;			Used to prescale timer 1 to count every 100 ms
;                   
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Glen George
; Last Modified:    Oct. 29, 1997

; Revised for Use in RoboCrane
;	02/21/02	Chirath Neranjena - removed timer 2
;	22/03/02	Chirath Neranjena - set up timer 1 and 2

InitTimer       PROC    NEAR


        MOV     DX, Tmr2Count   ;initialize the count register to 0
        XOR     AX, AX
        OUT     DX, AL

        MOV     DX, Tmr2MaxCnt  ;setup max count for 1ms counts
        MOV     AX, COUNTS_PER_MS_2
        OUT     DX, AL

        MOV     DX, Tmr2Ctrl    ;setup the control register, 
        MOV     AX, Tmr2CtrlVal
        OUT     DX, AL
                        


        MOV     DX, Tmr1Count   ;initialize the count register to 0
        XOR     AX, AX
        OUT     DX, AL

        MOV     DX, Tmr1MaxCntA ;set up the max count of the timer
        MOV     AX, MS_PER_STEP  ;   
        OUT     DX, AL

        MOV     DX, Tmr1Ctrl    ;setup the control register, interrupts on
        MOV     AX, Tmr1CtrlVal
        OUT     DX, AL


                                ;initialize Timer #0 for 1 ms interrupts

        MOV     DX, Tmr0Count   ;initialize the count register to 0
        XOR     AX, AX
        OUT     DX, AL

        MOV     DX, Tmr0MaxCntA ;
        MOV     AX, COUNTS_PER_MS_0  ;   
        OUT     DX, AL

        MOV     DX, Tmr0Ctrl    ;setup the control register, interrupts on
        MOV     AX, Tmr0CtrlVal
        OUT     DX, AL

                                ;initialize interrupt controller for timers
        MOV     DX, INTCtrlrCtrl;setup the interrupt control register
        MOV     AX, INTCtrlrCVal
        OUT     DX, AL

        MOV     DX, INTCtrlrEOI ;send a non-specific EOI (to clear out controller)
        MOV     AX, NonSpecEOI
        OUT     DX, AL


        RET                     ;done so return


InitTimer       ENDP




; InstallHandler
;
; Description:      Install the event handler for the timer interrupts,
;		    and Serial channel Interrupt and 
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   flags, AX, ES
; Stack Depth:      1 word
;
; Author:           Glen George
; Last Modified:    Jan. 28, 2002

; Reviced to work with RoboCrane
; 02/22/02	Chirath Neranjena	- set up timer 0 interrupt
; 7/03/02	Chirath Neranjena	- set interrupt 2
; 18/03/02	Chirath Neranjena	- set timer 1 interrupt

InstallHandler  PROC    NEAR


        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
                                ;store the vector
        MOV     ES: WORD PTR (4 * Tmr0Vec), OFFSET(TimerEventHandler)
        MOV     ES: WORD PTR (4 * Tmr0Vec + 2), SEG(TimerEventHandler)

        MOV     ES: WORD PTR (4 * Tmr1Vec), OFFSET(StepperEventHandler)
        MOV     ES: WORD PTR (4 * Tmr1Vec + 2), SEG(StepperEventHandler)

	MOV	ES: WORD PTR (4 * SerialVec), OFFSET(SerialInterruptHandler)
	MOV	ES: WORD PTR (4 * SerialVec + 2), SEG(SerialInterruptHandler)
	

        RET			;all done, return


InstallHandler  ENDP




; ClrIRQVectors
;
; Description:      This functions installs the IllegalEventHandler for all
;                   interrupt vectors in the interrupt vector table.  Note
;                   that all 256 vectors are initialized so the code must be
;                   located above 400H.  The initialization skips the first
;                   RESERVED_VECS vectors.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  CX    - vector counter.
;                   ES:SI - pointer to vector table.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   flags, AX, CX, SI, ES
; Stack Depth:      1 word
;
; Author:           Glen George
; Last Modified:    Jan. 28, 2002

; Revived for Use with RoboCrane
; 22/02/02	 - Chirath Neranjena

ClrIRQVectors   PROC    NEAR


InitClrVectorLoop:              ;setup to store the same handler 256 times

        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
        MOV     SI, 4 * RESERVED_VECS   ;initialize SI to skip RESERVED_VECS (4 bytes each)

        MOV     CX, 256 - RESERVED_VECS ;up to 256 vectors to initialize


ClrVectorLoop:                  ;loop clearing each vector
                                ;store the vector
        MOV     ES: WORD PTR [SI], OFFSET(IllegalEventHandler)
        MOV     ES: WORD PTR [SI + 2], SEG(IllegalEventHandler)

        ADD     SI, 4           ;update pointer to next vector

        LOOP    ClrVectorLoop   ;loop until have cleared all vectors
        ;JMP    EndClrIRQVectors;and all done


EndClrIRQVectors:               ;all done, return
        RET


ClrIRQVectors   ENDP




; IllegalEventHandler
;
; Description:      This procedure is the event handler for illegal
;                   (uninitialized) interrupts.  It does nothing - it just
;                   returns after sending a non-specific EOI.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Glen George
; Last Modified:    Dec. 25, 2000
; Reviced to Work With RoboCrane

IllegalEventHandler     PROC    NEAR

        NOP                             ;do nothing (can set breakpoint here)

        PUSH    AX                      ;save the registers
        PUSH    DX

        MOV     DX, INTCtrlrEOI         ;send a non-sepecific EOI to the
        MOV     AX, NonSpecEOI          ;   interrupt controller to clear out
        OUT     DX, AL                  ;   the interrupt that got us here

        POP     DX                      ;restore the registers
        POP     AX

        IRET                            ;and return


IllegalEventHandler     ENDP



CODE ENDS

;the data segment

DATA    SEGMENT PUBLIC  'DATA'


StringBuffer   	DB      8 DUP(?)	; Buffer for storing display messages
		PUBLIC	StringBuffer

CraneVert	DW	0		; Holds the Absolute Vertical position	
		PUBLIC	CraneVert
CraneAngle	DW	0		; Holds the Absolute Angle
		PUBLIC	CraneAngle
CraneMagnet	DW	0		; Holds the status of the magnet
		PUBLIC	CraneMagnet

DATA    ENDS




;the stack

STACK           SEGMENT STACK  'STACK'

                DB      80 DUP ('Stack ')       ;240 words

TopOfStack      LABEL   WORD

STACK           ENDS



        END     START
