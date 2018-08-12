PROGRAM SEGMENT PUBLIC 'CODE'

        ASSUME  CS:PROGRAM, DS:DATA, ES:DATA, SS:STACK

CheckF:
        CMP  F,0                ; IF ( F >= 0) THEN
	JL   FgreatthanZero	;   
	;JGE FlessthanZero

FlessthanZero:
        MOV  BX, 0              ; B=0
        JMP LoopCondition       ; ELSE

FgreatthanZero:
        MOV  AX, CX             ; B = 22 * C/F
        IDIV F
        IMUL AX, 22
	MOV BX, AX
	;JMP LoopCondition	; END IF	

LoopCondition:                  ; WHILE (E > 5)
       CMP  E,5        ;   AND (B > 7)
       JLE Final       ; If the conditions are met      
       CMP  BX, 7      ; then execute the body of the
       JLE Final       ; loop
       ;JMP LoopBody   ; else exit the loop

LoopBody:
       MOV  AX, E       ; E = E -1
       SUB  AX, 1
       MOV  E, AX
       SUB  BX, DX      ; B = E -D
       JMP LoopCondition

Final:
       MOV  AX, E        ; D = E - B
       SUB  AX, BX
       MOV  DX, AX

PROGRAM ENDS

;the data segment

DATA    SEGMENT  WORD  PUBLIC  'DATA'


E               DW      ?             

F               DW      ?

DATA    ENDS



STACK           SEGMENT  WORD  STACK  'STACK'


                DB      80 DUP ('Stack   ')             ;320 words

TopOfStack      LABEL   WORD


STACK           ENDS



        END     CheckF
