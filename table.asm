NAME  PARSETABLES


CGROUP  GROUP   CODE

CODE    SEGMENT PUBLIC 'CODE'


ASCIITable   LABEL   BYTE
             PUBLIC  ASCIITable

        DB      0               ;NUL			0
        DB      0               ;SOH			1
        DB      0               ;STX			2
        DB      0               ;ETX			3
        DB      0               ;EOT			4
        DB      0               ;ENQ			5
        DB      0               ;ACK			6
        DB      0               ;BEL			7
        DB      0               ;backspace		8
        DB      0               ;TAB			9
        DB      0               ;new line		10
        DB      0               ;vertical tab		11
        DB      0               ;form feed		12
        DB      1               ;carriage return	13
        DB      0               ;SO			14
        DB      0               ;SI			15			
        DB      0               ;DLE			16
        DB      0               ;DC1			17
        DB      0               ;DC2			18
        DB      0               ;DC3			19
        DB      0               ;DC4			20
        DB      0               ;NAK			21
        DB      0               ;SYN			22
        DB      0               ;ETB			23
        DB      0               ;CAN			24
        DB      0               ;EM			25
        DB      0               ;SUB			26
        DB      0               ;escape			27
        DB      0               ;FS			28
        DB      0               ;GS			29
        DB      0               ;AS			30
        DB      0               ;US			31

;       DB      .gfedcba                ;ASCII character

        DB      0               ;space			32
        DB      0               ;!			33
        DB      0               ;"			34
        DB      0               ;#			35
        DB      0               ;$			36
        DB      0               ;percent symbol		37	
        DB      0               ;&			38
        DB      0               ;'			39
        DB      0               ;(			40
        DB      0               ;)			41
        DB      0               ;*			42
        DB      2               ;+			43
        DB      0               ;,			44
        DB      3               ;-			45
        DB      0               ;.			46
        DB      0               ;/			47
        DB      4               ;0			48
        DB      5               ;1			49
        DB      6               ;2			50
        DB      7               ;3			51
        DB      8               ;4			52
        DB      9               ;5			53
        DB     10               ;6			54
        DB     11               ;7			55
        DB     12               ;8			56
        DB     13               ;9			57
        DB      0               ;:			58
        DB      0               ;;			59
        DB      0               ;<			60
        DB      0               ;=			61
        DB      0               ;>			62
        DB      0               ;?			63

;       DB      .gfedcba                ;ASCII character

        DB      0               ;@			64
        DB     14               ;A			65
        DB      0               ;B			66
        DB      0               ;C			67
        DB      0               ;D			68
        DB     21               ;E			69
        DB     19               ;F			70
        DB      0               ;G			71
        DB      0               ;H			72
        DB      0               ;I			73
        DB      0               ;J			74
        DB      0               ;K			75
        DB      0               ;L			76
        DB      0               ;M			77
        DB     18               ;N			78
        DB      0               ;O			79
        DB     20               ;P			80
        DB      0               ;Q			81
        DB     15               ;R			82
        DB      0               ;S			83
        DB      0               ;T			84
        DB      0               ;U			85
        DB     17               ;V			86
        DB      0               ;W			87
        DB      0               ;X			88
        DB      0               ;Y			89
        DB     16               ;Z			90
        DB      0               ;[			91
        DB      0               ;\			92
        DB      0               ;]			93
        DB      0               ;^			94
        DB      0              ;_			95
			
;       DB      .gfedcba                ;ASCII character

        DB      0               ;`			96
        DB      0               ;a			97
        DB      0               ;b			98
        DB      0               ;c			99
        DB      0               ;d			100
        DB      0               ;e			101
        DB      0               ;f			102
        DB      0               ;g			103
        DB      0               ;h			104
        DB      0               ;i			105
        DB      0               ;j			106
        DB      0               ;k			107
        DB      0               ;l			108
        DB      0               ;m			109
        DB      0               ;n			110
        DB      0               ;o			111
        DB      0               ;p			112
        DB      0               ;q			113
        DB      0               ;r			114
        DB      0               ;s			115
        DB      0               ;t			116
        DB      0               ;u			117
        DB      0               ;v			118
        DB      0               ;w			119
        DB      0               ;x			120
        DB      0               ;y			121
        DB      0               ;z			122
        DB      0               ;{			123
        DB      0               ;|			124
        DB      0               ;}			125
        DB      0               ;~			126
        DB      0               ;rubout			127



StateTable   LABEL   BYTE
             PUBLIC  StateTable


	DW 	OFFSET ParseError		; path Begin
	DW	OFFSET ParseError	
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET PathInit
	DW	OFFSET ParseError
	
	DW	OFFSET ParseError  		; path just started
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET GetFirstPathNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter			; path started done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET GetPathNum
	DW	OFFSET AAfterPath	
	DW	OFFSET RAfterPath
	DW	OFFSET ZAfterPath
	DW	OFFSET VAfterPath
	DW	OFFSET NAfterPath
	DW	OFFSET FAfterPath
	DW	OFFSET PathDone
	DW	OFFSET PArseError

	DW	OFFSET ParseError		; A started
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA		
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET GetFirstRotNumA
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter			; A Started Done
	DW	OFFSET ParseError		
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum		
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum	
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ZAfterRot
	DW	OFFSET VAfterRot
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError			; R Started
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET GetFirstRotNumR
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter				; R Started Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ZAfterRot
	DW	OFFSET VAfterRot
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError			; Z Started
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ	
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ	
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET GetFirstVertNumZ
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter			; Z Started Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET AAfterVert
	DW	OFFSET RAfterVert
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError		; V Started
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV	
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET GetFirstVertNumV
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter			; V Started Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET AAfterVert
	DW	OFFSET RAfterVert
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError			; A Second
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET GetSecondRotNumA
	DW	OFFSET ParseError	
	DW	OFFSET ParseError	
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter				; A Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum	
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET Enter
	DW	OFFSET Enter
	DW	OFFSET Enter
	DW	OFFSET Enter
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError				; R Second
	DW	OFFSET RotateSignPositive
	DW	OFFSET RotateSignNegative
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET GetSecondRotNumR
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter				; R Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET GetRotNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll		
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError


	DW	OFFSET ParseError				; Z Second
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET GetSecondVertNumZ
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter				; Z Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError

	DW	OFFSET ParseError				; V Second
	DW	OFFSET VertSignPositive
	DW	OFFSET VertSignNegative
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET GetSecondVertNumV
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError

	DW	OFFSET Enter				; V Second Done
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET GetVertNum
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathDone
	DW	OFFSET ParseError
	
	DW	OFFSET ParseError					; Step Start
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET ParseError
	DW	OFFSET AStart	
	DW	OFFSET RStart	
	DW	OFFSET ZStart	
	DW	OFFSET VStart	
	DW	OFFSET NForAll
	DW	OFFSET FForAll
	DW	OFFSET PathInit
	DW	OFFSET Exit


CODE    ENDS



        END


