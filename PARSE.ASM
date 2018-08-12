NAME Parsing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                Parsing                                     ;
;                   Serial Processing Routines                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:Function involved with handling downloaded commands to the RoboCrane(TM)
; 		Over the serial channel
;		ParseSerialChar - The function processors the passed character
;                                 to a given criteria and returns the status of the 
;                                 parsing operation in AX
;
; Input: Input Character
;		P - path start command
;		E - doenload exit command
;		A - Absolute Rotation	
;		R - Relative Rotation
;		Z - Absolute Vertical movement
;		V - Relative vertical movement
;		N - Turn on magnet
;		F - Turn Off Magnet
;	
; Output: Error Status	
;			Zero(0) - No Error
;			High bit set - Error
;			One(1) - End of the path
;
; User Interface:   None
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	08 Mar 2002	Creation

CGROUP  GROUP   CODE


$INCLUDE(PARSE.INC)

EXTRN	BeginPath	:NEAR
EXTRN	StorePathStep	:NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DATA



; SerialParseChar
;
; Description:      Serial Processing
;
; Arguments:        Input Character
; Return Value:     Error Status
;
; Local Variables:  
;	NewChar - Stores the current Character being processed
;	State   - Holds the current State in Processing
;		PathBegin	- 0 
;		PathJustStarted	- 1 
;		PathStartedDone	- 2 
;		AStarted	- 3 
;		AStartedDone	- 4  
;		RStarted	- 5 
;		RStartedDone	- 6 
;		ZStarted	- 7 
;		ZStartedDone	- 8 
;		VStarted	- 9 
;		VStartedDone	- 10 
;		ASecond		- 11
;		ASecondDone	- 12
;		RSecond		- 13
;		RSecondDone	- 14
;		ZSecond		- 15
;		ZSecondDone	- 16
;		VSecond		- 17
;		VSecondDone	- 18
;		StepStart	- 19
;
;	PathNum - Path number in processing
;	Angle   - Angle of Rotation
;	Vert    - magnitude of vertical movement	
;	ArFlag	- interpretation of Angle / Abs or Rel
;	VrFlag	- interpretation of Vertical movement / Abs or Rel
;	RotSign	- holds whether angle is positive or negative 
;	VertSign- holds whether vert is positive ot negative
;
;	Magnet  - magnet on / off
;
; Shared Variables: None.
; Global Variables: None
;		    
;		    
;
; Input:            Input Character
; Output:           Error Status
;
; Error Handling:   Ignores invalid characters and returns error
;
; Algorithms:       None.
;                   
;                   
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX, DX, ES, SI
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    Mar 16 2002


ParseSerialChar		PROC	NEAR
			PUBLIC	ParseSerialChar

	PUSH	BX			; Save Registers
	PUSH	CX
	PUSH	DX
        PUSH    ES
        PUSH    SI

ParseStart:

        MOV     AH, 0        		; Store Character in Variable
        MOV     NewChar, AL

        CMP     AL, 20H			; If Character is 'space' the nothing to process
        JE      NoErrorOne		; exit with no error return

        MOV	BX, OFFSET ASCIITable	; get the column number of the state table
	XLAT	CS:ASCIITable

	CMP	AL, 0			; if column number = 0 then invalid character
	JE	ParseErrorOne		; exit with error

       

        MOV     CX, 0			; save value of AL
	MOV	CL, AL

	MOV	AL, State		; Calculate the Offset of the state table
        MOV     BX, NoStateChar         ;  Offset = Current State * No of States + Column number
        IMUL    BX			;
        ADD     AX, CX			;
        MOV     BX, 2			;
        MUL     BX			;
        MOV     BX, AX			;
        

        MOV     AX, SEG StateTable	; Get Segment value of the state table
        MOV     ES, AX

        MOV     AX, OFFSET StateTable	; get the offset of state table
        ADD     AX, BX			; add the new offset
        MOV     SI, AX

        DEC     SI
        MOV     BH, ES:[SI]		; Get the offset of the needed command
        DEC     SI			;  given in the state table
        MOV     BL, ES:[SI]

        JMP     BX			; jump to that command

ParseErrorOne:

	MOV	AX, -1			; exit parsing with error
        MOV     State, StepStart
        MOV     MagnetDone, False
	JMP	ParseEnd

NoErrorOne:

	MOV	AX, 0			; exit parsing with no error
	JMP	ParseEnd

PathInit:

	MOV	State, PathJustStarted	; change state to handle new path
	MOV	PathNum, 0
	JMP	NoError

GetFirstPathNum:
	
	MOV	AX, 0
	MOV	AL, NewChar		; calculate the real numerical value
	SUB	AX, ZeroASCII		;  from ascii number
	MOV	PathNum, AL		;  path number = ascii value - ascii value for zero
	MOV	NUMCntr, 0

	MOV	State, PathStartedDone	; path completed, ready for new commands
	JMP	NoError			

GetPathNum:
	

	MOV	AL, PathNum		; calculate the real numerical value
	MOV	DX, 10			;  for path number
	MUL	DX			;  new path value = 10 * old path value
	MOV	BL, AL			;			+
	MOV	AL, NewChar		;		    New value - Zero ascii value 
	SUB	AL, ZeroASCII
	ADD	AL, BL

	MOV	PathNum, AL
	JMP	NoError

AAfterPath:
	
        MOV     AL, PathNum		
	CALL	BeginPath

	MOV	State, AStarted		; Change State to receive angle
	MOV	Angle, 0		; Initialize angle = 0
	MOV	ArFlag, Absolute	; Initialize interpretation = absolute	
	JMP	NoError

RAfterPath:

	Mov	AL, PathNum
	CALL	BeginPath

	MOV	State, RStarted		; Change State to receive angle
	MOV	Angle, 0		; Initialize angle = 0
	MOV	ArFlag, Relative	; Initialize interpretation = absolute
	JMP	NoError

ZAfterPath:

        MOV     AL, PathNum
	CALL	BeginPath

	MOV	State, ZStarted		; Change State to receive vert
	MOV	Vert, 0			; Initialize vert = 0
	MOV	VrFlag, Absolute	; Initialize interpretation = absolute
	JMP	NoError


VAfterPath:

        MOV     AL, PathNum
	CALL	BeginPath

	MOV	State, VStarted		; Change State to receive vert
	MOV	Vert, 0			; Initialize vert = 0
	MOV	VrFlag, Relative	; Initialize interpretation = vert
	JMP	NoError

NAfterPath:

        MOV     AL, PathNum
	CALL	BeginPath
	MOV	Magnet, True		; set magnet = on
	MOV	MagnetDone, true	; done with magnet handling for step
        JMP     NoError

FAfterPath:

        MOV     AL, PathNum
	CALL	BeginPath
	MOV	Magnet, False		; set magnet = false
	MOV	MagnetDone, true	; done with magnet handling for step
	JMP	NoError

CarrageReturnAfterPath:

        MOV     AL, PathNum		; Begin path
	CALL	BeginPath


	MOV	Vert, 0			; Reset All values
	MOV	Angle, 0

        MOV     ArFlag, True
        MOV     VrFlag, True

	MOV	Magnet, Unchange
	MOV	MagnetDone, False

	MOV	RotSign, Positive
	MOV	VertSign, Positive

	MOV	RotSignDone, False
	MOV	VertSignDone, False

	MOV	State, StepStart	;change state for a new step

	JMP	NoError


CarrageReturn:

	CMP	RotSign, Negative	; if angle is negative
	JNE	NegVertCheck		;  calculate the negative value
	MOV	AX, Angle
	NEG	AX
	MOV	Angle, AX

NegVertCheck:
	
	CMP	VertSign, Negative	; if vert is negative 
	JNE	StorePathNow		;   calculate the negative value
	MOV	AX, Vert
	NEG	AX
	MOV	Vert, AX

StorePathNow:

	MOV	BX, Vert		; setup the registers
	MOV	CL, VrFlag
	MOV	DX, Angle
	MOV	CH, ArFlag
	MOV	AL, Magnet
	
	CALL	StorePathStep		; store path


	MOV	Vert, 0			; reset all values
	MOV	Angle, 0

        MOV     ArFlag, True
        MOV     VrFlag, True

	MOV	Magnet, Unchange
	MOV	MagnetDone, False

	MOV	RotSign, Positive
	MOV	VertSign, Positive

	MOV	RotSignDone, False
	MOV	VertSignDone, False

	MOV	State, StepStart	; change state for a new step	

	JMP	NoError

PathDone:
        CMP     MagnetDone, True
        JNE     PathDoneNewPath

	CMP	RotSign, Negative	; if angle is negative
	JNE	PathNegVertCheck	;  calculate the negative value
	MOV	AX, Angle
	NEG	AX
	MOV	Angle, AX

PathNegVertCheck:
	
	CMP	VertSign, Negative	; if vert is negative 
	JNE	PathStorePathNow	;   calculate the negative value
	MOV	AX, Vert
	NEG	AX
	MOV	Vert, AX

PathStorePathNow:

	MOV	BX, Vert
	MOV	CL, VrFlag
	MOV	DX, Angle
	MOV	CH, ArFlag
	MOV	AL, Magnet
	
	CALL	StorePathStep		; store path
	
	MOV	Vert, 0			; Reset All values
	MOV	Angle, 0

        MOV     ArFlag, True
        MOV     VrFlag, True

	MOV	Magnet, Unchange
	MOV	MagnetDone, False

	MOV	RotSign, Positive
	MOV	VertSign, Positive

	MOV	RotSignDone, False
	MOV	VertSignDone, False

PathDoneNewPath:

	MOV	PathNum, 0
	MOV	State, PathJustStarted	; Change state for a new path

        JMP     NoError

RotateSignPositive:

	CMP	RotSignDone, True
	JE	ParseErrorTwo		; remember that angle is negative
	MOV	RotSign, Positive
	MOV	RotSignDone, True
	JMP	NoError

RotateSignNegative:

	CMP	RotSignDone, True
	JE	ParseErrorTwo		; remember that vert is negative
	MOV	RotSign, Negative
	MOV	RotSignDone, True
	JMP	NoError

ParseErrorTwo:

	MOV	AX, -1			; exit with error
        MOV     MagnetDone, False
        MOV     State, StepStart
	JMP	ParseEnd

GetFirstRotNumA:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get the first rotation digit
	MOV	Angle, AX
	MOV	State, AStartedDone
	MOV	NumCntr, 0
	JMP	NoError

GetRotNum:

	
	MOV	BX, 0
	MOV	BL, NewChar
	SUB	BL, ZeroASCII		; get the rest of the rotation digits
	MOV	AX, Angle
        MOV     CX, 10
        MOV     DX, 0
        MUL     CX
        CMP     DX, 0			;  if angle > 65536 then
        JNE     ParseErrorTwo		;    error
        ADD	AX, BX
	MOV	Angle, AX

        CMP     RotSign, Negative	; if rot sign is not negative 
        JE      RotNumNegCheck		;   check for overflow of the
        AND     AX, 08000H		;    positive number
        CMP     AX, 08000H
        JE      ParseErrorTwo
        JMP     NoError

RotNumNegCheck:
        CMP     AX, 08000H		;   check for overflow of the negative number	
        JE      NoErrorTwo
        AND     AX, 08000H
        CMP     AX, 08000H
        JE      ParseErrorTwo
        JMP     NoError

NoErrorTwo:

	MOV	AX, 0			; no error
	JMP	ParseEnd		; exit


ZAfterRot:
	
	MOV	Vert, 0
	MOV	VrFlag, Absolute	; change state to accept  
	MOV	State, ZSecond		;  an absolute vertical movement
	JMP	NoError

VAfterRot:
	
	MOV	Vert, 0
	MOV	VrFlag, Relative	; change state to accept  
	MOV	State, ZSecond		;  an relative vertical movement
	JMP	NoError

NForAll:

	CMP	MagnetDone, True	; if magnet not already doen for the step	
        JE      ParseErrorThree           ; turn on magnet
	MOV	Magnet, True		; remember we are done with magnet for the step
	MOV	MagnetDone, True
	JMP	NoError

FForAll:

	CMP	MagnetDone, True	; if magnet not already doen for the step
	JE	ParseErrorThree		; turn off magnet
	MOV	Magnet, False		; remember we are done with magnet for the step
	MOV	MagnetDone, True
	JMP	NoError

GetFirstRotNumR:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get the first digit of rotation 
	MOV	Angle, AX		;  for relative rotation	
	MOV	State, RStartedDone
	MOV	NumCntr, 0
	JMP	NoError

VertSignPositive:

	CMP	VertSignDone, True
	JE	ParseErrorThree		; remember vert sign is positive
	MOV	VertSign, Positive
	MOV	VertSignDone, True
	JMP	NoError

VertSignNegative:

	CMP	VertSignDone, True
	JE	ParseErrorThree		; remember vert sign is negative
	MOV	VertSign, Negative	
	MOV	VertSignDone, True
	JMP	NoError

ParseErrorThree:

	MOV	AX, -1			; error
        MOV     MagnetDone, False
        MOV     State, StepStart
	JMP	ParseEnd		; exit

GetFirstVertNumZ:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get first digit for absolute vert
	MOV	Vert, AX
	MOV	State, ZStartedDone
	MOV	NumCntr, 0
	JMP	NoError

GetFirstVertNumV:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get first digit for relative vert
	MOV	Vert, AX
	MOV	State, VStartedDone
	MOV	NumCntr, 0
	JMP	NoError

GetVertNum:

 	MOV	BX, 0
	MOV	BL, NewChar
	SUB	BL, ZeroASCII		; get the rest of vert digits
	MOV	AX, Vert
        MOV     DX, 0
        MOV     CX, 10
        MUL     CX			; if vert > 65536 then
        CMP     DX, 0			;   error
        JNE     ParseErrorThree
        ADD     AX, BX
	MOV	Vert, AX

        CMP     VertSign, Negative
        JE      VertNumNegCheck		; if vert is not negative
        AND     AX, 08000H
        CMP     AX, 08000H		; do positive vert overflow check
        JE      ParseErrorThree
        JMP     NoError

VertNumNegCheck:
        CMP     AX, 08000H
        JE      NoErrorThree		;  else do negative overflow check
        AND     AX, 08000H
        CMP     AX, 08000H
        JE      ParseErrorFour
        JMP     NoError

NoErrorThree:

	MOV	AX, 0			; no error
	JMP	ParseEnd		; exit

ParseErrorFour:

	MOV	AX, -1			; error
        MOV     MagnetDone, False
        MOV     State, StepStart
	JMP	ParseEnd		; exit

AAfterVert:
	
	MOV	Angle, 0
	MOV	ArFlag, Absolute	; get ready for rotation (abs) after 
	MOV	State, ASecond		;  a vertical movement
	JMP	NoError

RAfterVert:
	
	MOV	Angle, 0		
	MOV	ArFlag, Relative	; get ready for rotation (rel) after
	MOV	State, RSecond		;   a vertical movement
	JMP	NoError

GetSecondRotNumA:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get the angle for a second call to A
	MOV	Angle, AX
	MOV	State, ASecondDone
	MOV	NumCntr, 0
	JMP	NoError	

GetSecondRotNumR:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get the angle for a second call to R
	MOV	Angle, AX
	MOV	State, RSecondDone
	MOV	NumCntr, 0
	JMP	NoError		

GetSecondVertNumZ:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get the angle for a second call to Z
	MOV	Vert, AX
	MOV	State, ZSecondDone
	MOV	NumCntr, 0
	JMP	NoError

GetSecondVertNumV:

	MOV	AX, 0
	MOV	AL, NewChar
	SUB	AL, ZeroASCII		; get the angle for a second call to V
	MOV	Vert, AX
	MOV	State, VSecondDone
	MOV	NumCntr, 0
	JMP	NoError

AStart:

	MOV	State, AStarted
	MOV	Angle, 0		; change state to accept rotation (abs)
	MOV	ArFlag, Absolute	;  at the start of step	
	JMP	NoError

RStart:

	MOV	State, RStarted
	MOV	Angle, 0		; change state to accept rotation (rel)
	MOV	ArFlag, Relative	;  at the start of step	
	JMP	NoError

ZStart:

	MOV	State, ZStarted
	MOV	Vert, 0			; change state to accept vertical mov (abs)
	MOV	VrFlag, Absolute	;  at the start of step	
	JMP	NoError


VStart:

	MOV	State, VStarted
	MOV	Vert, 0			; change state to accept vert move (rel)
	MOV	VrFlag, Relative	;  at the start of step			
	JMP	NoError	

Exit:
	MOV	Vert, 0			; reset all values
	MOV	Angle, 0

	MOV	Magnet, Unchange
	MOV	MagnetDone, False

	MOV	RotSign, Positive
	MOV	VertSign, Positive

	MOV	RotSignDone, False
	MOV	VertSignDone, False

	MOV	PathNum, 0

	MOV	State, PathBegin	; change state to accpet new path

	JMP	PathEnd

ParseError:

	MOV	AX, -1			; error
        MOV     MagnetDone, False
        MOV     State, StepStart
	JMP	ParseEnd		; exit

NoError:

	MOV	AX, 0			; no error
	JMP	ParseEnd		; exit

PathEnd:

	MOV	AX, 1			; path end
        MOV     State, PathBegin
	JMP	ParseEnd		; exit

ParseEnd:

        POP     SI			; restore registers
        POP     ES
        POP	DX
	POP	CX
	POP	BX

	RET

ParseSerialChar		ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								      ;	
; ASCII Table carrying the state table column values for ASCIII Values;
;								      ;	
;								      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ASCIITable   LABEL   BYTE
             PUBLIC  ASCIITable

        DB      0               ;NUL			0
        DB      0               ;SOH			1
        DB      0               ;STX			2
        DB      0               ;ETX			3
        DB      0               ;EOT			4
        DB      0               ;ENQ			5
        DB      0               ;ACK			6
        DB      0               ;BEL			7
        DB      0               ;backspace		8
        DB      0               ;TAB			9
        DB      0               ;new line		10
        DB      0               ;vertical tab		11
        DB      0               ;form feed		12
        DB      1               ;carriage return	13
        DB      0               ;SO			14
        DB      0               ;SI			15			
        DB      0               ;DLE			16
        DB      0               ;DC1			17
        DB      0               ;DC2			18
        DB      0               ;DC3			19
        DB      0               ;DC4			20
        DB      0               ;NAK			21
        DB      0               ;SYN			22
        DB      0               ;ETB			23
        DB      0               ;CAN			24
        DB      0               ;EM			25
        DB      0               ;SUB			26
        DB      0               ;escape			27
        DB      0               ;FS			28
        DB      0               ;GS			29
        DB      0               ;AS			30
        DB      0               ;US			31

;       DB      .gfedcba                ;ASCII character

        DB      0               ;space                  32
        DB      0               ;!			33
        DB      0               ;"			34
        DB      0               ;#			35
        DB      0               ;$			36
        DB      0               ;percent symbol		37	
        DB      0               ;&			38
        DB      0               ;'			39
        DB      0               ;(			40
        DB      0               ;)			41
        DB      0               ;*			42
        DB      2               ;+			43
        DB      0               ;,			44
        DB      3               ;-			45
        DB      0               ;.			46
        DB      0               ;/			47
        DB      4               ;0			48
        DB      5               ;1			49
        DB      6               ;2			50
        DB      7               ;3			51
        DB      8               ;4			52
        DB      9               ;5			53
        DB     10               ;6			54
        DB     11               ;7			55
        DB     12               ;8			56
        DB     13               ;9			57
        DB      0               ;:			58
        DB      0               ;;			59
        DB      0               ;<			60
        DB      0               ;=			61
        DB      0               ;>			62
        DB      0               ;?			63

;       DB      .gfedcba                ;ASCII character

        DB      0               ;@			64
        DB     14               ;A			65
        DB      0               ;B			66
        DB      0               ;C			67
        DB      0               ;D			68
        DB     21               ;E			69
        DB     19               ;F			70
        DB      0               ;G			71
        DB      0               ;H			72
        DB      0               ;I			73
        DB      0               ;J			74
        DB      0               ;K			75
        DB      0               ;L			76
        DB      0               ;M			77
        DB     18               ;N			78
        DB      0               ;O			79
        DB     20               ;P			80
        DB      0               ;Q			81
        DB     15               ;R			82
        DB      0               ;S			83
        DB      0               ;T			84
        DB      0               ;U			85
        DB     17               ;V			86
        DB      0               ;W			87
        DB      0               ;X			88
        DB      0               ;Y			89
        DB     16               ;Z			90
        DB      0               ;[			91
        DB      0               ;\			92
        DB      0               ;]			93
        DB      0               ;^			94
        DB      0              ;_			95
			
;       DB      .gfedcba                ;ASCII character

        DB      0               ;`			96
        DB     14               ;a                      97
        DB      0               ;b			98
        DB      0               ;c			99
        DB      0               ;d			100
        DB     21               ;e                      101
        DB     19               ;f                      102
        DB      0               ;g			103
        DB      0               ;h			104
        DB      0               ;i			105
        DB      0               ;j			106
        DB      0               ;k			107
        DB      0               ;l			108
        DB      0               ;m			109
        DB     18               ;n                      110
        DB      0               ;o			111
        DB     20               ;p                      112
        DB      0               ;q			113
        DB     15               ;r                      114
        DB      0               ;s			115
        DB      0               ;t			116
        DB      0               ;u			117
        DB     17               ;v                      118
        DB      0               ;w			119
        DB      0               ;x			120
        DB      0               ;y			121
        DB     16               ;z                      122
        DB      0               ;{			123
        DB      0               ;|			124
        DB      0               ;}			125
        DB      0               ;~			126
        DB      0               ;rubout			127

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								      ;	
; State Table                                                         ;
;								      ;	
;								      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StateTable   LABEL   BYTE
             PUBLIC  StateTable


	DW 	OFFSET ParseError		; path Begin
	DW	OFFSET ParseError	
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET PathInit
	DW	OFFSET ParseError
	
	DW	OFFSET ParseError  		; path just started
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

        DW      OFFSET CarrageReturnAfterPath           ; path started done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET AAfterPath	
	DW	OFFSET RAfterPath
	DW	OFFSET ZAfterPath
	DW	OFFSET VAfterPath
	DW	OFFSET NAfterPath
	DW	OFFSET FAfterPath
	DW	OFFSET PathDone
	DW	OFFSET PArseError

	DW	OFFSET ParseError		; A started
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA		
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn			; A Started Done
	DW	OFFSET ParseError		
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum		
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ZAfterRot
	DW	OFFSET VAfterRot
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError			; R Started
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn				; R Started Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ZAfterRot
	DW	OFFSET VAfterRot
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError			; Z Started
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ	
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ	
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn			; Z Started Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET AAfterVert
	DW	OFFSET RAfterVert
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError		; V Started
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV	
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn			; V Started Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET AAfterVert
	DW	OFFSET RAfterVert
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError			; A Second
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET ParseError	
	DW	OFFSET ParseError	
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn				; A Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError				; R Second
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn				; R Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll		
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError


	DW	OFFSET ParseError				; Z Second
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn				; Z Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError				; V Second
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET CarrageReturn				; V Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError
	
        DW      OFFSET CarrageReturn                             ; Step Start
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET AStart	
	DW	OFFSET RStart	
	DW	OFFSET ZStart	
	DW	OFFSET VStart	
	DW	OFFSET NForAll
	DW	OFFSET FForAll
        DW      OFFSET PathDone
	DW	OFFSET Exit

CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'

NewChar             	DB      ?
State			DB	0
PathNum			DB	?
NumCntr			DW	0
Angle			DW	0
Vert			DW	0
ArFlag			DB	0
VrFlag			DB	0

RotSign			DW	?
VertSign		DW	?

RotSignDone		DW	?
VertSignDone		DW	?

Magnet                  DB      0
MagnetDone		DW	?




DATA    ENDS


        END
