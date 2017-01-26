	
;NOMBRE:   FILEOPEN
;OBJETIVO: ABRIR UN FICHERO
;ENTRADA: HL -> PUNTERO AL NOMBRE DEL FICHERO.


FILEOPEN:	
	ld	de,FCBLOAD
	ld	BC,12
	LDIR

	LD	C,FOPEN
	LD	DE,FCBLOAD
	CALL	BDOS

	LD	HL,1
	LD	(FCBLOAD+14),HL
	LD	HL,0
	LD	(FCBLOAD+33),HL
	LD	(FCBLOAD+35),HL
	RET


;NOMBRE: READFILE
;OBJETIVO: LEER PARTE DE UN FICHERO
;ENTRADA: HL -> NUMERO DE BYTES
;         DE -> DESTINO

READFILE:	PUSH	HL
	LD	C,SETDMA
	CALL	BDOS
	POP	HL
	LD	C,RDBLK
	LD	DE,FCBLOAD
	CALL	BDOS
	RET

;NOMBRE: CLOSEFILE
;OBJETIVO: CERRAR EL FICHERO


CLOSEFILE:	LD	DE,FCBLOAD
	LD	C,FCLOSE
	CALL	BDOS
	RET