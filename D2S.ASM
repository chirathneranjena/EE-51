NAME D2S

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
        MOV     CX, 10000                       ; Pwr10 = 10000

        CMP     I, 7777                         ; If I = 7777 Stop Program
        JE      EndInputLoop                    ; Otherwise Store String
        ;JNE    MakeString                      ; in memory

MakeString:

        MOV     AX, I                           ; IF (I<0) THEN
        CMP     AX, 0                           ;   Start String with '-' Sign
        JL      PutNegativeSign                 ; ELSE
        JGE     StartTrace                      ;   Start String Normally
                                                ; ENDIF

PutNegativeSign:

        MOV     AX, 2DH                         ; Store '-' in string
        STOSW
        MOV     AX, I                           ; I=absolute(I)
        NEG     AX
        MOV     I, AX
        JMP     StartTrace                      ; Start Tracing Digits

StartTrace:

        CMP     BX, 0                           ; WHILE (Error = False)
        JNE     StopTrace                       ;  AND
        CMP     CX, 0                           ;    (Pwr10 > 0)
        JLE     StopTrace
        ;JG     CheckDigit

CheckDigit:

        MOV     AX, I                           ;   digit = I / pwr10
        MOV     DX, 0
        DIV     CX
        CMP     AX, 10                          ;   IF (digit >= 10) THEN
        JGE     DigitError                      ;       
        JL      StoreNumber

DigitError:

        MOV     BX, 1                           ;     Error = True
        JMP     TraceNext                       ;
                                                ;   ELSE

StoreNumber:

        ADD     AX, 30H                         ;     Convert digit to ASCII
        STOSW                                   ;     Store ASCII Code
        ;JMP    CorrectIandPwr10

CorrectIandPwr10:

        MOV     AX, I                           ;     I = I MOD pwr10
        MOV     DX, 0
        DIV     CX
        MOV     I, DX

        MOV     AX, CX                          ;     Pwr10 = Pwr10/10
        MOV     DX, 0
        MOV     BX, 10
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
