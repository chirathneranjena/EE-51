;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  QUEUE.INC                                 ;
;                                     QUEUE                                  ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Queue used in Serial Communication
; Program, (SERIAL.ASM) and (QUEUE.ASM)
;
; Revision History:
;    03/08/2002  Chirath Neranjena      initial revision

; Define the number of element in queue and byte size of queue

Q_Elem          EQU     100	; no of elements in queue
Queue_Size      EQU     200     ; Queue Size in bytes, 1 elem = 1 word = 2 bytes (2*Q_Elem)
