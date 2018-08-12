



%*DEFINE(CLR(reg)) (

	MOV	%reg, 0
)

%*DEFINE(SETBIT(reg, bit)) (

	PUSH	AX
	PUSH	DS

	MOV	AX, 1b
	SAL	AX, %bit
	MOV	DS, AX
	
	POP	AX
	OR	%reg, DS

	POP	DS
)


%*DEFINE(CLEARBIT(reg, bit)) (

	PUSH	AX
	PUSH	DS

	MOV	AX, 1b
	SAL	AX, %bit
	MOV	DS, AX
	
	POP	AX
	NOT	DS
	AND	%reg, DS

	POP	DS
)

%*DEFINE(TESTBIT(reg, bit)) (

	PUSH	AX
	PUSH	DS
	PUSH	ES

	MOV	AX, 1b
	SAL	AX, %bit
	MOV	DS, AX
	
	POP	AX
	MOV	ES, %reg
	AND	ES, DS

	POP	ES
	POP	DS
)

%*DEFINE(COMBIT(reg, bit)) (

	PUSH	AX
	PUSH	DS
	PUSH	ES

	MOV	AX, 1b
	SAL	AX, %bit
	MOV	DS, AX
	
	POP	AX
	MOV	ES, %reg
	AND	ES, DS

	%IF (ES EQ 0)  THEN  (
        	%SETBIT(reg, bit)
	)  ELSE  (
	        %CLRBIT(reg, bit)
        )  FI


	POP	ES
	POP	DS
)



