NAME  MAIN

 
CGROUP  GROUP   CODE


EXTRN   InitQueues      :NEAR
EXTRN   TxEnQueue       :NEAR
EXTRN   TxDeQueue       :NEAR



CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DATA, SS:STACK



START:  

MAIN:
        MOV     AX, STACK               ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(TopOfStack)

        MOV     AX, DATA                ;initialize the data segment
        MOV     DS, AX

        CALL    InitQueues

Forever:

point1: 

        CMP     AX, 1
        JNE     GetChar
 
PutChar:

        CALL    TxEnQueue
        JMP     Forever

GetChar:

        CALL    TXDeQueue





        JMP     Forever                 ;sit in an infinite loop, nothing to
                                        ;   do in the background routine







        HLT                             ;never executed (hopefully)



CODE ENDS

DATA    SEGMENT PUBLIC  'DATA'




DATA    ENDS




;the stack

STACK           SEGMENT STACK  'STACK'

                DB      80 DUP ('Stack ')       ;240 words

TopOfStack      LABEL   WORD

STACK           ENDS



        END     START
