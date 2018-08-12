
NAME	Queue
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Queue                                      ;
;                              Queue  Routines                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with handling queues for serial communication
;			InitQueues - Setup head and tails pointers of the Tx and Rx Queues
;			RxEmpty - Checks if the Receive Queue is Empty
;		       	TxEmpty - Checks if the Transmit Queue is Empty
;			RxFull  - Checks if the Receieve Queue is Full
;			TxFull	- Checks if the Transmit Queue is Full
;			RxDeQueue - Pops a value from the receive queue
;			TxDeQueue - pops a value from the transmit queue
;			RxEnQueue - pushes a value into the receieve queue
;			TxEnQueue - pushes a value into the transmit queue
;
;
;
; Input:            AX ( PUSH Values)
; Output:           Zero Flag, AX ( POP Values)
;
; User Interface:   None
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	08, Mar 2002	Creation



CGROUP	GROUP	CODE

$INCLUDE(QUEUE.INC)

CODE SEGMENT PUBLIC 'CODE'

	ASSUME	CS: CGROUP, DS: DATA

; InitQueues
;
; Description:      Queue Initializing Routines
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: TxHead, TxTail, RxHead, RxTail
; Global Variables: None
;		    		
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       Set Queue Head pointers
;                   Set Queue Tail pointers
;                       
; Data Structures:  TxQueue, RxQueue
;
; Registers Used:   AX
; Stack Depth:      1 word
;
; Author:           Chirath Neranjena
; Last Modified:    Mar 08 2002

InitQueues	PROC	NEAR
		PUBLIC	InitQueues

	PUSH	AX			; Save registers
	
	MOV	AX, OFFSET TxQueue	; Get start of the queue
	MOV	TxHead, AX		; initialize queue head
	MOV	TxTail, AX		; initialize queue tail
	
	MOV	AX, OFFSET RxQueue	; do the same for the receive queue	
	MOV	RxHead, AX
	MOV	RxTail, AX

	POP	AX

	RET				; return

InitQueues 	ENDP

; RxEmpty
;
; Description:      Checks if the Receive Queue is Empty
;
; Arguments:        None
; Return Value:     Zero Flag set or reset
;
; Local Variables:  None
;
; Shared Variables: RxTail, RxHead
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           Zero Flag
;
; Error Handling:   None.
;
; Algorithms:       Check if Receive Queue is Empty and set the zero flag, else
;                   reset the flag
;                       
; Data Structures:  RxQueue
;
; Registers Used:   AX
; Stack Depth:      1 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002


RxEmpty		PROC	NEAR
		PUBLIC	RxEmpty

	PUSH	AX			; store registers

	MOV	AX, RxHead		; if head = tails then queue is empty (set flag)
	CMP	AX, RxTail		; else queue is not empty (reset flag)

	POP	AX			; restore registers

	RET

RxEmpty		ENDP


; TxEmpty
;
; Description:      Checks if the Transmit Queue is Empty
;
; Arguments:        None
; Return Value:     Zero Flag set or reset
;
; Local Variables:  None
;
; Shared Variables: TxTail, TxHead
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           Zero Flag
;
; Error Handling:   None.
;
; Algorithms:       Check if Receive Queue is Empty and set the zero flag, else
;                   reset the flag
;                       
; Data Structures:  TxQueue
;
; Registers Used:   AX
; Stack Depth:      1 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002


TxEmpty		PROC	NEAR
		PUBLIC	TxEmpty

	PUSH	AX			; store registers

	MOV	AX, TxHead		; if head = tails then queue is empty (set flag)
	CMP	AX, TxTail		; else queue is not empty (reset flag)

	POP	AX			; restore registers

	RET

TxEmpty		ENDP


; RxFull
;
; Description:      Checks if the Receive Queue is Full
;
; Arguments:        None
; Return Value:     Zero Flag set or reset
;
; Local Variables:  None
;
; Shared Variables: RxTail, RxHead
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           Zero Flag
;
; Error Handling:   None.
;
; Algorithms:       Check if Receive Queue is Full and set the zero flag, else
;                   reset the flag
;                       
; Data Structures:  RxQueue
;
; Registers Used:   AX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002


RxFull		PROC	NEAR
		PUBLIC	RxFull

	PUSH	AX			; save registers
        PUSH    BX

	MOV	AX, RxTail		; get the tail of the queue
  	INC	AX			; twice increment ( for word)
	INC	AX              
        MOV     BX, OFFSET RxQueue        
        ADD     BX, Queue_Size
        CMP     AX, BX                  ; if tail+1 > queue size the then
	JLE	RxFullCheck		;    do a wrap around
	MOV	AX, OFFSET RxQueue	; 	    
	
RxFullCheck:
	CMP	AX, RxHead		; if the tail is one behind head
					; 	the queue is full (set flag)
        POP     BX
	POP	AX			; else  the queue is not full (reset flag)
	RET

RxFull	ENDP

; TxFull
;
; Description:      Checks if the Transmit Queue is Full
;
; Arguments:        None
; Return Value:     Zero Flag set or reset
;
; Local Variables:  None
;
; Shared Variables: TxTail, TxHead
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           Zero Flag
;
; Error Handling:   None.
;
; Algorithms:       Check if Transmit Queue is Full and set the zero flag, else
;                   reset the flag
;                       
; Data Structures:  TxQueue
;
; Registers Used:   AX
; Stack Depth:      1 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

TxFull		PROC	NEAR
		PUBLIC	TxFull

	PUSH	AX			; save registers
        PUSH    BX

	MOV	AX, TxTail		; get the tail of the queue
   	INC	AX			; twice increment it for word
	INC	AX           
        MOV     BX, OFFSET TxQueue
        ADD     BX, Queue_Size        
        CMP     AX, BX                  ; if tail+1 > queue size the then
	JLE	TxFullCheck		;    do a wrap around
        MOV     AX, OFFSET TxQueue      ;           
	
TxFullCheck:
	CMP	AX, TxHead		; if the tail is one behind head
					; 	the queue is full (set flag)
        POP     BX
        POP	AX			; else  the queue is not full (reset flag)
	RET

TxFull	ENDP

; RxDeQueue
;
; Description:      POPS a value from the Receive queue
;
; Arguments:        None
; Return Value:     POPPED value from queue in AX
;
; Local Variables:  None
;
; Shared Variables: RxHead, Rx Queue
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           AX, BX, DX, ES, SI
;
; Error Handling:   None.
;
; Algorithms:       if queue if empty then loop while key available
;			then get the value and adjust the queue head
;                       
; Data Structures:  RxQueue
;
; Registers Used:   AX, BX, ES, SI, DX
; Stack Depth:      4 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

RxDeQueue	PROC 	NEAR
		PUBLIC	RxDeQueue


	PUSH	ES			; save the registers
	PUSH	SI
        PUSH    BX
	PUSH	DX

        CALL    RxEmpty                 ; If queue is empty then
	JZ	EndRxDeQueue		;   nothing to return 

 	MOV	AX, RxHead		; get value of queue head
      	INC	AX
	INC	AX                      ; increment AX twice ( for word )
        MOV     BX, OFFSET RxQueue
        ADD     BX, Queue_Size
        CMP     AX, BX                  ; if the value exceeds the queue size then
        JLE     RxGetchar               ;   wrap around to the start of the queue
        MOV     AX, OFFSET RxQueue      ;
	
RxGetChar:

        MOV	DX, AX			; save the value of the offset
	MOV	AX, SEG RxQueue		; get the segement of the queue
	MOV	ES, AX			; put that to ES
	MOV	SI, DX			; put the offset into SI	
				
        MOV     AX, ES:[SI]             ; get the character in the queue
	MOV	RxHead, DX		; change queue head
        

EndRxDeQueue:
	
	POP	DX			; restore the registers
        POP     BX
	POP	SI
	POP	ES

        RET

RxDeQueue	ENDP


; TxDeQueue
;
; Description:      POPS a value from the Transmit queue
;
; Arguments:        None
; Return Value:     POPPED value from queue
;
; Local Variables:  None
;
; Shared Variables: TxHead, TxQueue
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       if queue if empty then loop while key available
;			then get the value and adjust the queue head
;                       
; Data Structures:  TxQueue
;
; Registers Used:   AX, BX, DX, ES, SI
; Stack Depth:      4 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

TxDeQueue	PROC 	NEAR
		PUBLIC	TxDeQueue

        PUSH    ES                      ; save the registers
	PUSH	SI
        PUSH    BX
	PUSH	DX

        CALL    TxEmpty                 ; If queue is empty then
	JZ	EndTxDeQueue		;   nothing to return 


	MOV	AX, TxHead		; get value of queue head
        INC	AX
	INC	AX                      ; add one to the value 
        MOV     BX, OFFSET TxQueue
        ADD     BX, Queue_Size        
        CMP     AX, BX                  ; if the value exceeds the queue size then
        JLE     TxGetchar               ;   wrap around to the start of the queue
	MOV	AX, OFFSET TxQueue	;
	
TxGetChar:
       

        MOV	DX, AX			; save the value of the offset    
	MOV	AX, SEG TxQueue		; get the segement of the queue
	MOV	ES, AX			;   and put this value in ES
	MOV	SI, DX			; get the offset of the character in queue	

        
        MOV     AX, ES:[SI]             ; get the character in the queue
	MOV	TxHead, DX		; change queue head


EndTxDeQueue:
	
	POP	DX			; restore the registers
        POP     BX
	POP	SI
	POP	ES



	RET

TxDeQueue       ENDP

; RxEeQueue
;
; Description:      PUSHES a value to the Receive queue
;
; Arguments:        AX - Value
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: RxTail, Rx Queue
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       if queue if Full then loop while space available
;			then put the value and adjust the queue tail
;                       
; Data Structures:  RxQueue
;
; Registers Used:   AX, BX, CX, DX, ES, SI
; Stack Depth:      5 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

RxEnQueue	PROC	NEAR
		PUBLIC	RxEnQueue

       	PUSH	ES
	PUSH	SI			; save registers
        PUSH    BX
	PUSH	CX
	PUSH	DX

        MOV     DX, AX                  ; save the input character
	CALL	RxFull			; check if the queue if full
	JZ	EndRxEnQueue		; if queue is full the exit


        MOV	AX, RxTail		; get the queue tail
        INC	AX
	INC	AX                      ; increment this value
        MOV     BX, OFFSET RxQueue
        ADD     BX, Queue_Size
        CMP     AX, BX                  ; if this vaalue passes the size of the queue
        JLE     RxPutChar               ; then wrap around to the start of the queue
	MOV	AX, OFFSET RxQueue

RxPutChar:
	MOV	CX, AX			; save offset
	MOV	AX, SEG RxQueue		; get the segment of the queue
	MOV	ES, AX			;    put this value in ES
	MOV	SI, CX			; put the offset in SI
	MOV	ES:[SI], DX		; store the value in queue  	
        MOV     RxTail, CX              ; update the queue tail


EndRxEnQueue:

	POP	DX
	POP	CX
        POP     BX
	POP	SI			; restore registers
	POP	ES


	RET

RxEnQueue	ENDP			; done


; TxEeQueue
;
; Description:      PUSHES a value to the Transmit queue
;
; Arguments:        AX - Value
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: TxTail, Rx Queue
; Global Variables: None
;		    
;		    
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       if queue if Full then loop while space available
;			then put the value and adjust the queue tail
;                       
; Data Structures:  TxQueue
;
; Registers Used:   AX, BX, CX, DX, ES, SI
; Stack Depth:      5 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAR 08 2002

TxEnQueue	PROC	NEAR
		PUBLIC	TxEnQueue


	PUSH	ES
	PUSH	SI			; save registers
        PUSH    BX
	PUSH	CX
	PUSH	DX

	MOV	DX, AX			; save the input character
	CALL	TxFull			; check if the queue if full
	JZ	EndTxEnQueue		; if queue is full the exit


	MOV	AX, TxTail		; get the queue tail
        INC	AX
	INC	AX	                ; increment this value twice
        MOV     BX, OFFSET TxQueue
        ADD     BX, Queue_Size
        CMP     AX, BX                  ; if this vaalue passes the size of the queue
        JLE     TxPutChar               ; then wrap around to the start of the queue
	MOV	AX, OFFSET TxQueue

TxPutChar:

	MOV	CX, AX			; save offset
	MOV	AX, SEG TxQueue		; get the segment of the queue
	MOV	ES, AX			;  put thi value in ES
	MOV	SI, CX			; put offset in SI
	MOV	ES:[SI], DX		; store the value in queue  
        MOV     TxTail, CX              ; update the queue tail


EndTxEnQueue:

	POP	DX
        POP     CX
        POP     BX        
	POP	SI			; restore registers
	POP	ES


        RET

TxEnQueue	ENDP			; done


CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


TxHead          DW      ?		; Transmit Queue Head Pointer
TxTail   	DW	?		; Transmit Queue Tail Pointer
RxHead          DW      ?               ; Receive Queue Head Pointer
RxTail          DW      ?               ; Receive Queue Tail Pointer


TxQueue         DW      Q_Elem DUP(?)	; TRANSMIT QUEUE
RxQueue         DW      Q_Elem DUP(?)	; RECEIVE QUEUE	

DATA    ENDS


        END
