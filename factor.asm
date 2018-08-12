        NAME    FACTOR3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   FACTOR3                                  ;
;                         Demo Program for Homework #3                       ;
;                                  EE/CS  51                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program finds the prime factorization of a 16-bit
;                   number stored at location I.  The program is terminated
;                   by this number being non-positive.
;
; Input:            Integer to factor (at location I).
; Output:           The prime factorization of the input number.  The prime
;                   factors are output to memory starting at location Factors.
;
; User Interface:   The user must store the number to be factored at location
;                   I and the prime factors can be read from location Factors.
; Error Handling:   None.
;
; Local Variables:  CX               - possible factor.
;                   ES:DI            - pointer to list of prime factors.
;                   I (memory)       - value to factor.
;                   Factors (memory) - factors of I.
; Shared Variables: None.
; Global Variables: None.
;
; Algorithms:       Check for divisibility by 2 and odd numbers starting with
;                   3.  (This is somewhat inefficient, but it works.)
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      The number to factor must fit in 16-bits, including the
;                   sign bit.
;
; Revision History:
;    10/20/93  Glen George              Initial revision.
;    10/24/94  Glen George              Updated comments.
;    10/25/95  Glen George              Added CLD instruction to make sure
;                                          strings are auto-incrementing.
;                                       No longer write 1 as a factor.
;                                       Updated comments.
;    10/20/98  Glen George              Updated comments.
;    12/26/99  Glen George              Fixed minor bug in FactorLoop end
;                                          condition test.
;     1/14/00  Glen George              Changed name of stack segment from
;                                          TheStack to STACK.
;    12/25/00  Glen George              Changed name of program to FACTOR4.
;                                       Updated comments.
;    11/19/01  Glen George              Changed name of program to FACTOR3.
;     1/30/02  Glen George              Added proper assume for ES.



PROGRAM SEGMENT PUBLIC 'CODE'

        ASSUME  CS:PROGRAM, DS:DATA, ES:DATA, SS:STACK



FactorStart:                            ;start factorization program
        MOV     AX, STACK               ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(TopOfStack)

        MOV     AX, DATA                ;initialize the data segment
        MOV     DS, AX

        CLD                             ;setup auto-increment


InputLoop:                              ;REPEAT
        MOV     DI, OFFSET Factors      ;    get pointer to location to store
        MOV     AX, SEG Factors         ;       factorization in ES:DI
        MOV     ES, AX
        CMP     I, 0                    ;    check IF (i > 0)
        JLE     EndInputLoop            ;    if not - get out of here
        ;JG     FactorIt                ;    otherwise factor the number

FactorIt:                               ;    IF (i > 0) THEN
        MOV     CX, 2                   ;        factor = 2


FactorLoop:                             ;        WHILE  (factor*factor <= i)
        MOV     AX, CX
        MUL     CX                      ;            compute factor * factor
        CMP     AX, I                   ;            check factor * factor <= i
        JA      EndFactorLoop           ;            if not - get out of loop
        ;JBE    FactorLoopBody          ;            else - execute loop body

FactorLoopBody:                         ;            body of factorization loop
        MOV     AX, I                   ;            setup for divide by factor
        MOV     DX, 0
        DIV     CX                      ;            compute i/factor
        CMP     DX, 0                   ;            check for remainder
        JNE     NotAFactor              ;            remainder != 0 => no factor
        ;JE     IsAFactor               ;            remainder = 0 => factor

IsAFactor:                              ;            IF (i divisible by factor)  THEN
        MOV     I, AX                   ;                i = i/factor
        MOV     AX, CX
        STOSW                           ;                store the factor
        JMP     EndFactorChk            ;                done dealing with factor

NotAFactor:                             ;            ELSE
        CMP     CX, 2                   ;                check IF (factor = 2)
        JNE     OddFactor               ;                if not - do odd factors
        ;JE     FirstFactor             ;                else - it's the first one
FirstFactor:                            ;                IF (factor = 2)  THEN
        MOV     CX, 3                   ;                    factor = 3
        JMP     EndFactorUpdate         ;                    done setting factor
OddFactor:                              ;                ELSE
        ADD     CX, 2                   ;                    factor = factor + 2
        ;JMP    EndFactorUpdate         ;                    done setting factor
EndFactorUpdate:                        ;                ENDIF
        ;JMP    EndFactorChk            ;                done checking factors

EndFactorChk:                           ;            ENDIF
        JMP     FactorLoop              ;        ENDWHILE (keep looping)


EndFactorLoop:                          ;        ENDWHILE (done with loop)
        MOV     AX, I                   ;        store the final factor
        STOSW
        ;JMP    EndInputLoop            ;        done processing this input


EndInputLoop:                           ;    ENDIF

        CMP     I, 0                    ;    check for (i <= 0)
        JG      InputLoop               ;    UNTIL (i <= 0)
        ;JLE    EndFactor


EndFactor:                              ;    end program
        NOP
        NOP
        NOP



PROGRAM ENDS




;the data segment

DATA    SEGMENT  WORD  PUBLIC  'DATA'


I               DW      ?               ;number to factor

Factors         DW      15 DUP(?)       ;prime factors (at most log2 I)


DATA    ENDS




;the stack

STACK           SEGMENT  WORD  STACK  'STACK'


                DB      80 DUP ('Stack   ')             ;320 words

TopOfStack      LABEL   WORD


STACK           ENDS



        END     FactorStart
