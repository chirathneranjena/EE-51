

Pending		EQU	1
Free		EQU	0

VertMotor	EQU	00181H
MagnetPort	EQU	00181H
AngleMotor	EQU	00182H
MotorControl    EQU     00183H

PortCtrVal      EQU     00080H


MagnetOn        EQU     0000000010000000b
MagnetOff       EQU     0000000000000000b

Straight	EQU	1
Reverse		EQU	-1

DegreesPerStepx10	EQU	9
InchesPerStepx10	EQU	5	

INTCtrlrEOI     EQU     0FF22H
Timer2EOI       EQU     00008H
