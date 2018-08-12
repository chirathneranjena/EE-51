NAME H2S

PROGRAM SEGMENT PUBLIC 'CODE'

  ASSUME CS:PROGRAM, DS:DATA, ES:DATA, SS:STACK


Dec2StringStart:

        MOV     AX, STACK                       ;Initialize Stack
        MOV     SS, AX
        MOV     SP, OFFSET(TopOfStack)

        MOV     AX, DATA
        MOV     DS, AX

        CLD

InputLoop:

        MOV     DI, OFFSET String
        MOV     AX, SEG String
        MOV     ES, AX                          ; Initialize Var String

        MOV     BX, 0                           ; Error = False
        MOV     CX, 1000H                       ; Pwr16 = 1000H

        CMP     I, 7777                         ; If I = 7777 Stop Program
        JE      EndInputLoop                    ; Otherwise Store String
        ;JNE    StartTrace                      ; in memory

StartTrace:

        CMP     BX, 0                           ; WHILE (Error = False)
        JNE     StopTrace                       ;  AND
        CMP     CX, 0                           ;    (Pwr16 > 0)
        JLE     StopTrace
        ;JG     CheckDigit

CheckDigit:

        MOV     AX, I                           ;   digit = I / pwr16
        MOV     DX, 0
        DIV     CX
        CMP     AX, 10H                         ;   IF (digit >= 10H) THEN
        JGE     DigitError                      ;       
        JL      CheckHexNumber

DigitError:

        MOV     BX, 1                           ;     Error = True
        JMP     TraceNext                       ;
                                                ;   ELSE
CheckHexNumber:

        CMP     AX, 10                          ; IF (digit > 10) THEN
        JGE     StoreHexNumber                  ;   
        JL      StoreDecNumber                  ;

StoreHexNumber:
                                                ;   Covert Digit to ASCII
        SUB     AX, 10                          ;   Store Hex Number ASCII Code
        ADD     AX, 41H
        STOSW
        JMP CorrectIandPwr16                    ; ELSE


StoreDecNumber:

        ADD     AX, 30H                         ;     Convert digit to ASCII
        STOSW                                   ;     Store ASCII Code
        ;JMP    CorrectIandPwr16

CorrectIandPwr16:

        MOV     AX, I                           ;     I = I MOD pwr16
        MOV     DX, 0
        DIV     CX
        MOV     I, DX

        MOV     AX, CX                          ;     Pwr16 = Pwr16/16
        MOV     DX, 0
        MOV     BX, 10H
        DIV     BX
        MOV     CX, AX
        MOV     BX, 0                           ;     Error = False
        JMP     TraceNext                            

TraceNext:

        JMP     StartTrace                      ;   ENDIF
                                                ; END WHILE

StopTrace:

        MOV     AX, 0H                          ; Store Null at the end of
        STOSW                                   ; string
        ;JMP EndInputLoop

EndInputLoop:

        CMP     I, 7777                         ; I (I # 7777) Then go back
        JNE     InputLoop                       ; to the start of the program
        ;JE     EndDec2String

EndDec2String:

        NOP
        NOP
        NOP

PROGRAM ENDS
        

;the data segment

DATA    SEGMENT  WORD  PUBLIC  'DATA'


I               DW      ?               ;number to Convert

String          DW      15 DUP(?)       ;prime factors (at most log2 I)


DATA    ENDS




;the stack

STACK           SEGMENT  WORD  STACK  'STACK'


                DB      80 DUP ('Stack   ')             ;320 words

TopOfStack      LABEL   WORD


STACK           ENDS



END    Dec2StringStart
