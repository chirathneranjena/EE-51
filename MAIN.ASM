; Requirement fot EE/CS 51
; Chirath Thouppuarachchi				Feb 10, 2002
; TA: VIJI Balaraman


NAME MAIN

CGROUP  GROUP   CODE

;$INCLUDE(convert.INC)

EXTRN   ConvertTest :NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DATA, SS:STACK





START:  

MAIN:
        MOV     AX, STACK               ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(TopOfStack)

        MOV     AX, DATA                ;initialize the data segment
        MOV     DS, AX

 

Forever:

        CALL ConvertTest

	JMP    Forever                 ;sit in an infinite loop, nothing to
                                        ;   do in the background routine
        HLT                             ;never executed (hopefully)

	RET

CODE ENDS


;the data segment

DATA    SEGMENT PUBLIC  'DATA'

;String          DW      15 DUP(?)       ;prime factors (at most log2 I)

DATA    ENDS




;the stack

STACK           SEGMENT STACK  'STACK'

                DB      80 DUP ('Stack ')       ;240 words

TopOfStack      LABEL   WORD

STACK           ENDS



        END     START
