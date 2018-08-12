;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  SERIAL.INC                                ;
;                                                                            ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Serial Channel Functions
; program (SERIAL.ASM).
;
; Revision History:
;    08/03/2002    Chirath Neranjena  initial revision 



; Register Selects

Serial_Rx	EQU	100H	; Reciever Buffer Register
Serial_Tx	EQU	100H	; Trasmitter Holding Register

Serial_DL	EQU	100H	; Serial MSB and LSB Data Latch Registers

Serial_IER	EQU	101H	; Interrupt Enable Register in Serial Chip
Serial_IIR	EQU	102H	; Interrupt Identification Register
Serial_LCR	EQU	103H	; Lactch Control Register
Serial_MCR	EQU	104H	; Modem Control Register
Serial_LSR	EQU	105H	; Line Status Register

; DLAB Access value

Enable_DL_Acc	EQU	10000000B	; Enable Access to MSB and LSB by setting DLAB

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



; Serial LCR Register setup value
Serial_Setup	EQU	00000011B	; Word length -8 bits
					; stop bits - 1

; Serial IER Register setup values
Serial_IRQ	EQU	00000111B	; enable ERBF, ETBE, ELSI

Tickle_IRQ      EQU     00000101B       ; enable ERBF, ELSI and not ETBE


; Interrupt2 configuration, Register Selects
SerialVec	EQU	14		; Interrupt Vector for Interrupt 2
Int2CtrlReg	EQU	0FF3CH		; Interrupt2 controller register address
IntCtrlEOI	EQU	0FF22H		; EOI register address

; Interrupt2 Setup Values	
Int2CtrlVal	EQU	00011H		; Unmask Int2, prority 1
Int2EOI		EQU	0000EH		; Interrupt 2 EOI
NonSpecEOI	EQU	08000H		; Non specific EOI

; IIR Values
Serial_Error	EQU	00000110B	; IER - Serial Error
Serial_Rx_Rdy	EQU	00000100B	; IER - Receiver Data Ready
Serial_Tx_Rdy	EQU	00000010B	; IER - Transmitter holding register

; MCR REgister Setup values
SERIAL_RTS      EQU     00000010B       ;RTS output bit
SERIAL_DTR      EQU     00000001B       ;DTR output bit


ERROR_BIT_MASK  EQU     00011110B       ;error bits

No_ERROR	EQU	0

