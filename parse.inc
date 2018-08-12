;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  Parse.INC                                 ;
;                                    PARSE                                   ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the State table for serial parsing
; Program, (PARSE.ASM)
;
; Revision History:
;    03/16/2002  Chirath Neranjena      initial revision


; States
PathBegin		EQU	0
PathJustStarted		EQU	1
PathStartedDone		EQU	2
AStarted		EQU	3
AStartedDone		EQU	4
RStarted		EQU	5
RStartedDone		EQU	6
ZStarted		EQU	7
ZStartedDone		EQU	8
VStarted		EQU	9
VStartedDone		EQU	10
ASecond			EQU	11
ASecondDone		EQU	12
RSecond			EQU	13
RSecondDone		EQU	14
ZSecond			EQU	15
ZSecondDone		EQU	16
VSecond			EQU	17
VSecondDone		EQU	18
StepStart		EQU	19


; Number of States
NoStateChar		EQU	21

; ASCII value of zero
ZeroASCII		EQU	48

;Misc
Absolute		EQU	0
Relative		EQU	1

True			EQU	1
UnChange		EQU	0
False			EQU	-1

Negative		EQU	-1
Positive		EQU	1
