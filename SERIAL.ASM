
NAME Serial

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Serial                                     ;
;                              Serial Routines                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with handling Serial Chip
;			SetSerial - Initialized Serial Chip
;		        SerialInterrupt Handler - Interrupt Handler for Serial Interrupt 				
;			SerialInReady - Checks if ready to receive
;			SerialGetChar - Gets a character from serial channel	
;			SerialOutRdy  - Checks if ready to transmit		
;			SerialPutChar - Transmit next char over the serial channel
;
;
; Input:            Zero Flag, Input Characters
; Output:           Zero Flag, Output Characters	
;
; User Interface:   None
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	08 Mar 2002	Creation


CGROUP  GROUP   CODE


$INCLUDE(SERIAL.INC)

EXTRN	RxFull		:NEAR
EXTRN   RxEmpty         :NEAR
EXTRN	RxEnQueue	:NEAR
EXTRN	RxDeQueue	:NEAR

EXTRN	TxFull		:NEAR
EXTRN   TxEmpty         :NEAR
EXTRN	TxEnQueue	:NEAR
EXTRN	TxDeQueue	:NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA

; SetSerial
;
; Description:      Function sets up the Serial Chip for program use
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
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB. 21 2002

SetSerial	PROC	NEAR
		PUBLIC	SetSerial

	MOV	DX, Serial_LCR		; Enable Access to Divisor Latch Access Bit
	MOV	AX, Enable_DL_Acc
	OUT	DX, AL

	MOV	DX, Serial_DL		; Set Baud Rate
        MOV     AX, Baud_19200
	OUT	DX, AL
	INC	DX
	MOV	AL, AH
	OUT	DX, AL

	MOV	DX, Serial_LCR		; Setup other Serial chip options
	MOV	AX, Serial_Setup
	OUT	DX, AL

	MOV	DX, Serial_IER		; Enable Serial chip Interrupts
	MOV	AX, Serial_IRQ
	OUT	DX, AL

        MOV     DX, SERIAL_MCR                  ;set the modem control lines
        MOV     AL, SERIAL_RTS + SERIAL_DTR     ;RTS and DTR both on
        OUT     DX, AL


	MOV	DX, Int2CtrlReg		; Setup Interrupt 2
	MOV	AX, Int2CtrlVal
	OUT	DX, AX

	MOV	DX, IntCtrlEOI		; send a non-specific EOI (to clear out controller)
	MOV	AX, NonSpecEOI		
	OUT	DX, AX

	MOV	ErrorBits, 0		; set Errorbits = nothing
	
        RET

SetSerial	ENDP


; SerialInterruptHandler
;
; Description:      This procedure is the event handler for the Serial
;                   interrupt.  
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  None
; Shared Variables: None.
; Global Variables: None
; Input:            Input Character, Error Values
; Output:           Output Character	
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      5 words
;
; Author       :    Chirath Neranjena  Feb. 14 2002    
;	
;


SerialInterruptHandler	PROC	NEAR
			PUBLIC	SerialInterruptHandler


        PUSHF

	PUSH	AX			; Save registers
	PUSH	DX

InterruptCheck:

	MOV	DX, Serial_IIR		; Get IIR register value to check type of interrupt
	IN	AL, DX

	CMP	AL, Serial_Error	; If error Handle error
	JE	HandleSerialError

	CMP	AL, Serial_Rx_Rdy	; If there is a received character then
	JE	SerialReceive		;   Acknowledge the received charcter

	CMP	AL, Serial_Tx_Rdy	; If Transmission is possible then
	JE	SerialTransmit		;   Trasmit the next character

HandleSerialError:

	MOV	DX, Serial_LSR		; Dump Error value in Status register	
	IN	AL, DX			;  onto ErrorBits Variable
	OR	ErrorBits, AL
	JMP	EndSerialInterrupt	; done	

SerialReceive:
	

	MOV	DX, Serial_Rx		; Get the received character
	IN	AL, DX

	CALL	RxFull			; If the receive queue is not full then
	JZ	EndSerialInterrupt	;   store the value in the queue	

	CALL	RxEnQueue		
	JMP	EndSerialInterrupt	; done

SerialTransmit:

	CALL	TxEmpty			; if Transmit Queue is Full then
	JZ	EndSerialInterrupt	;	nothing to do

	CALL	TxDeQueue		; Else get the next character from queue
	MOV	DX, Serial_Tx		;    and transmit
	OUT	DX, AL

	JMP	EndSerialInterrupt	; done

EndSerialInterrupt:

	MOV	DX, IntCtrlEOI		; Send EOI to clear interrupt on controller
	MOV	AX, Int2EOI
	OUT	DX, AX

	POP	DX			; restore registers
	POP	AX

        POPF

        IRET

SerialInterruptHandler	ENDP

; SerialInRdy
;
; Description - Checks if ready to receive
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

SerialInRdy	PROC	NEAR
		PUBLIC	SerialInRdy

	CALL	RxEmpty		; If Receive queue is empty then no character available
	RET			; 

SerialInRdy	ENDP


; SerialGetChar
;
; Description - Gets Character from the serial channel
;
; Arguments:        None.
; Return Value:     Character from serial channel, Error flag
;
; Local Variables:  None
;
; Shared Variables: ErrorBits
; Global Variables: None.
;
; Input:            None.
; Output:           AX
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

SerialGetChar	PROC	NEAR
		PUBLIC	SerialGetChar

SerialGetCharStart:

	CALL	SerialInRdy		; Loop while there is a character in Receive queue
	JZ	SerialGetCharStart

	CALL	RxDeQueue		; Get Character received from serial channel

	CMP	ErrorBits, NO_ERROR		; Check for errors
	JE	EndSerialGetChar	; If there is an error

	STC				;   set carry flag

EndSerialGetChar:			; End If

	RET				; done

SerialGetChar	ENDP

; SerialOutRdy
;
; Description - Checks if ready to Transmit
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

SerialOutRdy	PROC	NEAR
		PUBLIC	SerialOutRdy

	CALL	TxFull			; If Transmit queue is full, the transmission
					;   of character is not possible
	RET

SerialOutRdy	ENDP
		

; SerialOutChar
;
; Description - Transmits a Character to the serial channel
;
; Arguments:        Character to Transmit
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: None
; Global Variables: None.
;
; Input:            AX
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

SerialPutChar	PROC	NEAR
		PUBLIC	SerialPutChar

SerialPutCharStart:

	CALL 	SerialOutRdy		; lOOP while character can be transmitted
	JZ	SerialPutCharStart

	CALL	TxEnQueue		; move charcter to transmit queue

        PUSH    AX
        PUSH    DX

        MOV     DX, Serial_IER          ; Disable ETBE chip Interrupt
        MOV     AX, Tickle_IRQ          
	OUT	DX, AL

	MOV	DX, Serial_IER		; Enable Serial chip Interrupts
	MOV	AX, Serial_IRQ
	OUT	DX, AL

        POP     DX
        POP     AX

        RET

SerialPutChar	ENDP


; SerialStatus
;
; Description - Returns the Error Value of the serial channel
;
; Arguments:        None.
; Return Value:     Error Value
;
; Local Variables:  None
;
; Shared Variables: ErrorBits
; Global Variables: None.
;
; Input:            None.
; Output:           Error Value
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

SerialStatus	PROC	NEAR
	
	MOV	AL, ErrorBits
	MOV	Errorbits, NO_ERROR

	RET

SerialStatus	ENDP


CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


ErrorBits             DB      ?			; Error Bits Variable	


DATA    ENDS


        END
