


NAME Convert
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    Convert	                             ;
;                         Robocrane Numeric Conversion Routines              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program contains numeric convertion functions
;		     for Robocrane system. converts decimal and haxadecimal
;			 numbers into ascii coded characters.
;
; Input:            None
; Output:           None
;
; User Interface:   None.
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;
;     2/21/02  Chirath Neranjena  Converted to the Main function of Robocrane		




CGROUP  GROUP  CODE


CODE SEGMENT PUBLIC 'CODE'

     ASSUME  CS:CGROUP


; Dec2String
;
; Description:      Function converts a decimal number or a hex number passed 
;			to it through the AX register and returns the ASCII 
;			string form of the number. The string is stored at the
;			memory location given by the address in the DS:SI register.	
; 
; 
;
; Arguments:        AX         - Number to be converted to String
; Return Values:    DS:SI      - Starting Address of the memory location 
;				containing the ASCII string
;                   
;
; Local Variables: arg (BX)    - copy of passed binary value to convert.
;                 digit (AX)  - computed string character.
;                 pwr10 (CX)  - current power of 10 being computed.
;                 StartAddress (DS) – Address where the string begin
;		  Offset (SI) – Address where each character is stored.
; 			
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None
;
; Registers Used:   AX, BX, CX, SI, DS
; Stack Depth:      0 words
;
; Algorithms:       Repeatedly divide by powers of 10 and get the remainders. 
;		These remainder are added to ASCII # and stored as a byte in memory.
;
; Data Structures:  None.
;
;Known Bugs:       None.
;Limitations:      None.

;Pseudo Code
;
;   pwr10 = 1000
;   error = FALSE
;   Offset = 0
;   IF arg < 0 then
;     write to (startaddress + offset) value 2DH ; ASCII Code for ‘-‘
;     Offset = Offset + 1				
;     arg = magnitude (arg)
;   ENDIF
;    
;   WHILE ((error = FALSE) AND (pwr10 > 0))
;       digit = arg/pwr10
;       IF (digit < 10) THEN
;        Write to (startaddress + offset) value (digit + 30H)
;					;ASCII Code for 0 + digit;
;	Offset = offset + 1
;        arg = arg MODULO pwr10
;        pwr10 = pwr10/10
;        error = FALSE
;       ELSE
;        error = TRUE
;       ENDIF
;   ENDWHILE
;   Write to (startaddress + offset), 0H  
;		;ASCII Code for Null char, end string
;   RETURN  


; Revision History: 02/10/2002   Chirath Neranjena	Creation
;


Dec2String      PROC    NEAR
                PUBLIC  Dec2String

        PUSH    AX				; Store the registers to start the funcion
        PUSH    BX
        PUSH    CX
        PUSH    DX


DecInit:


        MOV     BX, 0                           ; Error = False
        MOV     CX, 10000                       ; Pwr10 = 10000
        PUSH    SI				; Store the SI register to get the starting address later

MakeDecString:

                                                ; IF (I<0) THEN
        CMP     AX, 0                           ;   Start String with '-' Sign
        JL      PutNegativeSign                 ; ELSE
        JGE     StartDecTrace                   ;   Start String Normally
                                                ; ENDIF

PutNegativeSign:

        PUSH    AX				; Relieve AX for calculations
        MOV     AX, 0002DH			; Move the ASCII value for '-' in AX
        MOV     DS:[SI], AX                     ; Store '-' in string
        INC     SI                              ; Go to the next byte in memmory
        POP     AX				; Get back the number to AX

                                                
        NEG     AX				; I=absolute(I)
        ;JMP    StartTrace                      ; Start Tracing Digits

StartDecTrace:

        CMP     BX, 0                           
        JNE     StpDecTrace                     
        CMP     CX, 0                           
        JLE     StpDecTrace                     
        ;JG     CheckDecDigit                   
                                                
CheckDecDigit:                                  
                                                
        PUSH    AX				;   (relieve AX for calculations)
                                                
        MOV     DX, 0				;   (prepair for division)
        DIV     CX				;   digit = I / pwr10
        CMP     AX, 10                          ;   IF (digit >= 10) THEN
        JGE     DecDigitError                   ;       
        JL      StoreDecNumber

DecDigitError:

        MOV     BX, 1
        POP     AX                              ;     Error = True
        JMP     StartDecTrace                   ;
                                                ;   ELSE

StoreDecNumber:

        ADD     AX, 00030H                      ;     Convert digit to ASCII
        MOV     DS:[SI], AX                     ;     Store ASCII Code
        INC     SI                              ;     Go to the next byte in memory	
        ;JMP    CorrectIandPwr10

CorrectIandPwr10:

        POP     AX                              ;     (Get back I)
        MOV     DX, 0				;     Prepair for division	
        DIV     CX				;     I = I MOD pwr10
        MOV     AX, DX				
        PUSH    AX				;     (push back I to relieve AX for calculations

        MOV     AX, CX                         
        MOV     DX, 0
        MOV     BX, 10				;     Prepair for Division
        DIV     BX
        MOV     CX, AX				;     Pwr10 = Pwr10/10
        MOV     BX, 0				;     Error = False
        POP     AX                              ;     (restore I in AX)
        JMP     TraceNextDec                            

TraceNextDec:

        JMP     StartDecTrace                   ;   ENDIF
                                                ; END WHILE

StpDecTrace:
        MOV     AX, 00000H                      ; Store Null at the end of
        MOV     DS:[SI], AX                     ; string
        POP     SI				; Get back the starting address of the string
        ;JMP EndDec2String


EndDec2String:

        POP     DX				; Restore the registers
        POP     CX
        POP     DX
        POP     AX

        RET

Dec2String      ENDP

;Hex2String
;
; Description: The function converts the 16-bit signed value passed to it, 
;              into a string using the ASCII values for each numeric character.
;		 If the digit is greater than 10 then it puts the appropriate
;		 alpha character to the hex string. 
;              The number is assumed to be unsigned.
;
; Arguments:   	AX Binary value to convert to a Hex string
;      	        SI Address in memory where the string is stored.
;	     
;	   
; Return Values: DS:SI String value of the binary number passed in AX
;                   
; Local Variables: arg (BX)    - copy of passed binary value to convert.
;                 digit (AX)  - computed string character.
;                 pwr10 (CX)  - current power of 10H being computed.
;                 StartAddress (DS) – Address where the string begin
;		  Offset (SI) – Address where each character is stored.
; 			
;Shared Variables: None.
;Global Variables: None.
;
;Input:            None.
;Output:           None.
;
;Error Handling:   None
;
;Registers Used:   AX, BX, CX, SI, DS
;Stack Depth:      0 words
;
;Algorithms:       Repeatedly divide by powers of 10 and get the remainders. 
;                  These remainder are added to ASCII # and stored as a byte in memory.
;
;Data Structures:  None.
;
;Known Bugs:       None.
;Limitations:      None.
;
;
;
;Pseudo Code
;
;   pwr10 = 1000H
;   error = FALSE
;   Offset = 0
;   
;   WHILE ((error = FALSE) AND (pwr10 > 0))
;       digit = arg/pwr10
;       IF (digit < 10H) THEN
;         IF (digit =< 9H) THEN
;           Write to (startaddress +offset) value (digit + 30H);
;	  ELSE
;           Write to (startaddress + Offset) value (digit + 41H)
;			;ASCII Code for ‘A’ + digit
; 	  ENDIF     
;        Offset = offset + 1
;        arg = arg MODULO pwr10
;        pwr10 = pwr10/10
;        error = FALSE
;       ELSE
;        error = TRUE
;      ENDIF
;  ENDWHILE
;   Write to (startaddress + offset), 0H  ;end string
;   RETURN  




Hex2String      PROC    NEAR
                PUBLIC  Hex2String


        PUSH    AX				; Store the registers to start the function
        PUSH    BX
        PUSH    CX
        PUSH    DX

HexInit:


        MOV     BX, 0                           ; Error = False
        MOV     CX, 1000H                       ; Pwr16 = 1000H
        PUSH    SI				; Store the SI register to get the starting address later

StartHexTrace:

        CMP     BX, 0                           ; WHILE (Error = False)
        JNE     StopHexTrace                    ;  AND
        CMP     CX, 0                           ;    (Pwr10 > 0)
        JLE     StopHexTrace
        ;JG     CheckHexDigit

CheckHexDigit:

        PUSH    AX				;   (relieve AX for calculations)
                                                ;   digit = I / pwr10
        MOV     DX, 0				;   Prepair for division
        DIV     CX
        CMP     AX, 00010H                      ;   IF (digit >= 10H) THEN
        JGE     HexDigitError                   ;       
        JL      CheckHexNumber			

HexDigitError:

        MOV     BX, 00001                       ;     ERROR ERROR ERROR !
        POP     AX                              ;     Error = True
        JMP     TraceNextHex                    ;
                                                ;   ELSE

CheckHexNumber:

        CMP     AX, 10                          ; IF (digit > 10) THEN
        JGE     StoreHexNumber                  ;
        JL      StoreHexDecNumber               ;


StoreHexNumber:

       ADD      AX, 00041H			;   Convert digit to ASCII Code
       SUB      AX, 10				;    more converting to ASCII code
       MOV      DS:[SI], AX                     ;   Store ASCII Code 
       INC      SI				;   Go to next byte in memory
       JMP      CorrectIandPwr16



StoreHexDecNumber:

        ADD     AX, 00030H                      ;     Convert digit to ASCII
        MOV     DS:[SI], AX                     ;     Store ASCII Code
        INC     SI   				;     Go to next byte in memory                           
        ;JMP    CorrectIandPwr16

CorrectIandPwr16:

        POP     AX    				;     (get back I)
        MOV     DX, 0				;     Prepiar for division	
        DIV     CX				;     I = I MOD pwr10
        MOV     AX, DX
        PUSH    AX				;     (relieve AX for calculations)

        MOV     AX, CX                          ;     
        MOV     DX, 0				;     prepair for division
        MOV     BX, 00010H			;     Pwr10 = Pwr10/10
        DIV     BX
        MOV     CX, AX		
        MOV     BX, 0				 ;     Error = False
        POP     AX   				 ;     (get back I)                          
        JMP     TraceNextHex                            

TraceNextHex:

        JMP     StartHexTrace                   ;   ENDIF
                                                ; END WHILE

StopHexTrace:

        MOV     AX, 00000H                      ; Store Null at the end of
        MOV     DS:[SI], AX                     ; string
        POP     SI
        ;JMP EndHex2String


EndHex2String:

        POP     DX				; Restore the registers 
        POP     CX
        POP     BX
        POP     AX
        RET


Hex2String      ENDP

CODE ENDS
        END					; WE ARE DONE !
