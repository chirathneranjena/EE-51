;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                SETTINGS.INC                                ;
;                                                                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for certain settings of Robocrane
;
; Revision History:
;    18/03/2002    Chirath Neranjena  initial revision 



;Serial Port Registers
Serial_LCR	EQU	103H		; Lactch Control Register
Enable_DL_Acc	EQU	10000000B	; Enable Access to MSB and LSB by setting DLAB

Serial_DL	EQU	100H		; Serial MSB and LSB Data Latch Registers

; Baud Rate Divisors
Baud_300        EQU     960              ; Baud rate divisor for 300 Baud rate
Baud_1200       EQU     240              ; Baud rate divisor for 1200 Baud rate
Baud_2400       EQU     120              ; Baud rate divisor for 2400 Baud rate
Baud_4800       EQU      60              ; Baud rate divisor for 4800 Baud rate
Baud_9600       EQU      30              ; Baud rate divisor for 9600 Baud rate
Baud_19200      EQU      15              ; Baud rate divisor for 19200 Baud rate
Baud_57600	EQU	  5		 ; Baud rate divisor for 57600 Baud rate

;Parity Settings
EvenParity	EQU	00011011B	; LCR Even Parity Value
OddParity	EQU	00001011B	; LCR Odd Parity Value
MarkParity	EQU	00101011B	; LCR Mark Parity Value
SetParity	EQU	00111011B	; LCR Set Parity Value
NoParity	EQU	00000011B	; LCR No Parity Value

;KepPad Key Values
; Each key is named after its row and column numbers

Key11		EQU	0002EH
Key12		EQU	0002DH
Key13		EQU	0002BH
Key14		EQU	00027H
Key21		EQU	0001EH
Key22		EQU	0001DH
Key23		EQU	0001BH
Key24		EQU	00017H
Key31		EQU	0000EH
Key32		EQU	0000DH
Key33		EQU	0000BH
Key34		EQU	00007H




