;Argument equates (include the return address (1 word) and BP (1 word)).
arg	EQU	WORD PTR [BP + 4]
pwr10	EQU	WORD PTR [BP - 2]
result	EQU	WORD PTR [BP - 4]

;local variables - 2 words
LocalVarSize	EQU	4


Dec2String	PROC	NEAR
		PUBLIC	Dec2String
		
		
Dec2StringInit:			;initialization	
	PUSH BP			;save BP
	MOV BP, SP		;and get BP pointing at the stack
	SUB SP, LocalVarSize	;save space on stack for local variables
	PUSH CX			;save registers
	PUSH DX		
	
	MOV arg, AX		;arg equals the number to be converted
	MOV result, 0		;result = 0
	MOV pwr10, 10000	;pwr10 = 10000
	CLC			;error = FALSE
	;JMP Dec2StringLoop	;now start looping to get digits
	
Dec2StringLoop:			;loop getting the digits on arg
	JC EndDec2StringLoop	;WHILE ((error = FALSE) AND
	CMP pwr10, 0		;	(pwr10 > 0)
	JLE EndDec2StringLoop	;if have end conditions - end loop
	JMP Dec2StringLoopBody	;else execute the loop body
	
NegateNumber:
	NEG arg			;make the negative number positive
	MOV result, 45		;store a negative sign (45 is the value in ASCII FOR "-")
	;JMP Dec2StringLoopBody	;then continue in conversion

Dec2StringLoopBody:
	CMP arg, 0		;IF (arg < 0) THEN
	JL NegateNumber		;make number positive and store minus sign
	MOV DX, 0		;setup for arg/pwr10
	MOV AX, arg		
	DIV pwr10		;digit (AX) = arg/pwr10
	CMP AX, 10		;check IF (digit < 10) THEN
	JAE SizeError		;if not it's an error
	;JB Convert		;otherwise process the digit
	
Convert:			;IF (digit < 10) THEN
	ADD AX, 48		;converts digit to ASCII value
	SHL result, 4		;result = result shifted left 4
	OR result, AX		;	OR digit
	MOV arg, DX		;arg = arg MODULO pwr10
	MOV AX, pwr10		;setup to update pwr10
	MOV CL, 10
	DIV CL			;calculate pwr10 = pwr10/10
	MOV AH, 0		;clear out remainder (not 0 if AX was 1)
	MOV pwr10, AX		;update pwr10
	CLC			;error = FALSE
	JMP EndLoopBody		;end of loop body
	
SizeError:			;ELSE
	STC			;	error = TRUE
	;JMP EndLoopBody	
	
EndLoopBody:			;ENDIF
	JMP Dec2StringLoop	;ENDWHILE (keep looping)
	
EndDec2StringLoop:		;ENDWHILE (out of loop)	
	MOV [DS:SI], result		;move result into return value
	
	POP DX			;restore registers
	POP CX
	ADD SP, LocalVarSize	;remove local variables from stack
	POP BP			;restore BP
	RET 2			;and return (releasing stack space)
	
	
Dec2String	ENDP