DmaHigh equ 0c000h
SizeDma equ 2000h	
	
SongAct	 equ 0a000h
AdrMusic equ 08000h

GfxActual equ 08000h
	
	
PortM	 equ 0feh
FuncgM   equ GET_P2
FuncpM   equ PUT_P2	 	

	

		
EXTBIO:	equ 0ffcah
	


PutPageD:			
	ld a,(seg_mc)
	out (PortM),a
	ld  (PageM),a
	ret


			
PutPageP1:		
	ld a,(seg_mp)
	out (PortM),a
	ld  (PageM),a
	ret


PutPageP2:			; Esto es asi para en el futuro meterlo en un megarom
	jr PutPageP1
	ret	
	
PageM:	 db 0		



	
;Nombre: PutPageM
;Objetivo:  Emular paginas de canciones de 8k
;Entrada: a -> Numero de pagina de Datos	
	
		
PutPageM:	
	assert "Pila=%p PutPageM: Cambiando  %d por %d\n",(sp),(PageMnum),a
	ld bc,(PageMnum)	
	cp c
	jp z,PutPageD
	
	
	push	af
	call	resvdp_li
	call	restore_int

	pop	af
	ld	(PageMnum),a
	ld	hl,Songl-12
	ld	b,a
	ld	de,12		
PutPM1	add	hl,de
	djnz	PutPM1

	assert "Pila=%p Cargando la pagina %d Correspondiente al fichero %p\n ",(sp),a,hl
	
	
	call	fileopen	
	ld	de,DmaHigh
	ld	hl,SizeDma	; Esto hay que cambiarlo para ponerlo a un valor mas pequeño
	call    readfile	
	call	closefile

	di
	call	PutPageD
	ld	hl,DmaHigh	
	ld	de,SongAct 
	assert "Pila=%p Copiando de %d:%p a %d:%p\n",(sp),(PageM),hl,3,de
	ld	bc,SizeDma
	ldir
	ei
			
        call	put_vint
	call	setvdp_li
	ret


PageMnum: db 0
		
Songl:	db	0,"XAK     MCM"	
	
	
	
	
							
;NOMBRE: INIT_SYS
;OBJETIVO: Iniciar el sistema para obtener la memoria necesaria y
;	   poder usar directamente los puertos del mapper

INIT_SYS:	
	LD	C,6Fh
	CALL	BDOS
	OR	A
	JR	NZ,SYSDOS1
	LD	A,B
	CP	2	
	JP	Z,SYSDOS2
	JP	NC,SYSDOS2

SYSDOS1: 
	assert "Detectado MSX-DOS 1\n"
	di
	ld a,4
	ld (seg_mc),a
	inc a
	ld (seg_gfx),a 

	ld a,(seg_mc) 
	out (PortM),a
	ld hl,MusicDrv
	ld de,AdrMusic
	ld bc,Fmcdrv-Imcdrv
	ldir
	ld a,1	
	ld (seg_mp),a
	out (PortM),a	
	ei
	ret
	

	
seg_mp:	 db 0,0	
seg_mc:	 db 0,0
seg_gfx: db 0,0	
dosver:	 db 0
	
		
SYSDOS2:
	assert "Detectado MSX-DOS 2\n"	
	ld a,(0fb20h)
	rrca	
	
;;; ld a,EMEM
;;; call nc,panick

	xor a
	ld de,0402h
	call EXTBIO
	
	ld de,ALL_SEG
	ld bc,30h
	ldir
		
	ld a,1
	ld (dosver),a
        xor a
	ld b,a
	call ALL_SEG
	ld (seg_mc),a
	ex af,af'

	
;;; ld a,EMEM
;;; call c,panick
		
	call FuncgM
	ld (seg_mp),a		; reservo una pagina para las canciones
;;; call FuncgM
;;; ld (seg_gfx),a		; y otra para los graficos
	
	ex af,af'
	di
	call FuncpM	
	ld hl,MusicDrv
	ld de,AdrMusic
	ld bc,Fmcdrv-Imcdrv
	ldir
	ld a,(seg_mp)
	call FuncpM		; Ahora parcheamos para poder usar el 
				; mapper directamente
				
PATCH:	LD	HL,0C000h	;Start search adr.
	LD	BC,3FFFh	;$ of bytes to search
B1:	LD	A,3Ah	;1. byte to search for
	CPIR
	JR	NZ,FINI	;No more found
B3:	INC	HL
	LD	A,(HL)
	CP	0F2h	;F2xx adr ?
	JR	NZ,B1	;No then try again
	DEC	HL	;Lo byte check.
	LD	A,(HL)
	CP	0C8h
	JR	C,B1
	CP	0CBh
	JR	NC,B1
FOUND:	DEC	HL
	LD	(HL),0DBh
	INC	HL
	LD	A,(HL)
	SUB	0C7h
	ADD	A,0FCh
	LD	(HL),A
	INC	HL
	LD	(HL),0
	JR	B1
FINI:	EI
	RET


	
ALL_SEG:	jp 0
FRE_SEG:	jp 0
RD_SEG:		jp 0
WR_SEG:		jp 0
CAL_SEG:	jp 0
CALLS:		jp 0
PUT_PH:		jp 0
GET_PH:		jp 0
PUT_P0:		jp 0
GET_P0:		jp 0
PUT_P1:		jp 0
GET_P1:		jp 0
PUT_P2:		jp 0
GET_P2:		jp 0
PUT_P3:		jp 0
GET_P3:		jp 0
		


	
	
	
			
ASK_OUT:	 
	LD	A,7
	CALL	LEE_FILA_KB
	BIT	2,A
	RET	NZ

SALIR:	CALL	FADE_OFF
	CALL	RESVDP_LI
	CALL	RESTORE_INT
	XOR	A
	CALL	INITSCR
	LD	HL,PAL_ODDYSEA
	CALL	PUT_PAL
	LD	A,MC_INICHIPS	
	CALL    MUSICC
	EI
	LD	SP,(STACK_TOP)
	RET





;;; Nombre: PutPageGfx
;;; Objetivo: Emular paginas de 8k
;;; Entrada: Pagina de gfx a colocar

PutPageGfx:		
	assert "Pila=%p PutPageGfx: Cambiando  %d por %d\n",(sp),(PageGfxnum),a
	ld bc,(PageGfxnum)	
	cp c
	jp z,PutPageD
	
	
	push	af
	call	resvdp_li
	call	restore_int

	pop	af
	ld	(PageGfxnum),a
	ld	hl,gfxl-12
	ld	b,a
	ld	de,12		
PutPGfx1	
	add	hl,de
	djnz	PutPGfx1

	assert "Pila=%p Cargando la pagina %d Correspondiente al fichero %p\n ",(sp),a,hl
		
	call	fileopen	
	ld	de,DmaHigh
	ld	hl,SizeDma	; Esto hay que cambiarlo para ponerlo a un valor mas pequeño
	call    readfile	
	call	closefile

	di
	call	PutPageD
	ld	hl,DmaHigh	
	ld	de,GfxActual
	assert "Pila=%p Copiando de %d:%p a %d:%p\n",(sp),(PageM),hl,3,de
	ld	bc,SizeDma
	ldir
	ei
			
        call	put_vint
	call	setvdp_li
	ret


PageGfxnum: db -1
		
gfxl:	db	0,"ABUELA  RAW"
	db	0,"ABUELO  RAW"
	db      0,"CHICO   RAW"
	db	0,"CARAS   RAW"
	db	0,"CIUDAD  RAW"
	db	0,"GALLINA RAW"
	db	0,"GUNKAMI RAW"
	db	0,"JAPO	   RAW"
	db	0,"MARC1   RAW"
	db	0,"MARC2   RAW"
	db	0,"MARC3   RAW"
	db	0,"MUJER   RAW"
	db	0,"OBJ	   RAW"
	db	0,"OPTION  RAW"
	db	0,"PAZOSI  RAW"
	db	0,"ROBERTI RAW"
	db	0,"SQUEL   RAW"
	db	0,"CAMPO   RAW"
	db	0,"GUNKAME RAW"
	db	0,"PAZOSE  RAW"
	db	0,"ROBERTE RAW"
	
+
		


	
;NOMBRE: LPIMAGE
;OBJETIVO: CARGAR DEL DISCO Y PINTAR UNA IMAGEN
;ENTRADA: A -> Numero de imagen
;         IX -> COORDENADA X DE VRAM DONDE SE PINTA
;         IY -> COORDENADA Y DE VRAM DONDE SE PINTA

	
LPIMAGE:
	assert "Cargando imagen\n"
	
		
	PUSH	IX
	PUSH	IY
	LD	DE,BUFFER
	CALL	LOADIM
	
	LD	HL,BUFFER
	POP	IY
	POP	IX
	PUSH	BC
	CALL	WAIT_COM
	POP	BC
	CALL	PAINT
	RET
    





;NOMBRE: LOADSP
;OBJETIVO: CARGAR LOS DATOS DE LOS SPRITES.

LOADSP:	LD	HL,NAMESP
	CALL	FILEOPEN
	LD	HL,STRENL_VEC-CRUZSP1
	LD	DE,CRUZSP1
	CALL	READFILE
	CALL	CLOSEFILE
	RET







;NOMBRE: LOADMAP
;OBJETIVO: CARGAR LOS DATOS DE UN MAPEADO.
;ENTRADA: HL -> PUNTERO AL NOMBRE DEL MAPEADO


LOADMAP:	CALL	FILEOPEN
	LD	HL,STRUCTMAPEADO
	LD	DE,MAPEADO_DAT
	CALL	READFILE
	LD	HL,SIZ_VECENL
	LD	DE,STRENL_VEC
	CALL	READFILE
	CALL	CLOSEFILE
	RET




LOADTIPOS:	LD	HL,NOMTIPOS
	CALL	FILEOPEN
	LD	HL,SIZ_VECTIPOS
	LD	DE,TIPOS_VEC
	CALL	READFILE
	CALL	CLOSEFILE
	RET

LOAD_OBJ	LD	HL,OBJETOS
	LD	IX,0
	LD	IY,PAG_OBJETOS*256+COORDY_OBJ
	CALL	LPIMAGE

	LD	HL,NOM_OBJ
	CALL	FILEOPEN
	LD	HL,SIZ_OBJV
	LD	DE,OBJ_VEC
	CALL	READFILE
	CALL	CLOSEFILE
	RET




;NOMBRE: LOADNIVEL
;OBJETIVO: CARGAR LOS DATOS DE CONFIGURACION DE UN NIVEL ASI COMO
;          LOS PERSONAJES DEL NIVEL ENTERO
;ENTRADA:  HL -> PUNTERO AL NOMBRE DEL NIVEL








	

LOADNIVEL:	
	CALL	FILEOPEN
	LD	HL,STRUCTNIVEL
	LD	DE,NIVELDAT
	CALL	READFILE
	LD	HL,SIZ_PERSOM+SIZ_PERSOC
	LD	DE,BUFFER
	CALL	READFILE
	CALL	CLOSEFILE

	LD	IX,BUFFER
	LD	B,MAXPERSOM-MAXNUMPJS
	LD	DE,STRUCTDEFPER

	LD	HL,STRPER_VECMAP
	LD	(PTR_PERSO),HL
	LD	IY,MAXPERSOM*STRUCTPERSO
	LD	L,11
	LD	C,MAXNUMPJS

LOADNIV1	LD	A,C
	EX	AF,AF'

	LD	A,(IX+STRDEFP_TIPO)
	OR	A
	JR	Z,LOADNIV2

	EXX
	LD	H,A
	LD	C,(IX+STRDEFP_X)
	LD	B,(IX+STRDEFP_X+1)
	LD	E,(IX+STRDEFP_Y)
	LD	D,(IX+STRDEFP_Y+1)
	LD	L,(IX+STRDEFP_DIR)
	EX	AF,AF'
	PUSH	IX
	CALL	INITPERSO
	POP	IX
	EXX

LOADNIV2	ADD	IX,DE
	INC	C
	DJNZ	LOADNIV1

	LD	BC,(PTR_PERSO)
	ADD	IY,BC
	LD	(PTR_PERSO),IY
	LD	IY,MAXPERSOC*STRUCTPERSO
	DEC	L
	JR	NZ,LOADNIV3
	LD	HL,STRPER_VECMAP
	LD	(PTR_PERSO),HL
	RET

LOADNIV3	LD	B,MAXPERSOC-MAXNUMPJS
	LD	C,MAXNUMPJS
	JR	LOADNIV1



;NOMBRE: LOADPAT
;OBJETIVO: CARGAR LOS PATRONES DE UN MAPEADO
;ENTRADA: HL -> PUNTERO A LA PRIMERA ENTRADA DE LA TABLA DE PATRONES



LOADPAT:	LD	(LOADPATT),HL

	LD	C,0
LOADPAT1:	LD	D,0
	PUSH	BC
	LD	E,C
	SLA	E
	LD	HL,(TBLCP_PTR)
	ADD	HL,DE
	LD	E,(HL)
	PUSH	DE
	INC	HL
	LD	E,(HL)
	PUSH	DE

	POP	IX
	POP   DE
	LD	D,PAG_PERSO
	PUSH DE
	POP IY

	LD	DE,(LOADPATT)
	LD	HL,12
	ADD	HL,DE
	EX	DE,HL
	LD	(LOADPATT),DE
	CALL	LPIMAGE

	POP	BC
	INC	C
	DJNZ	LOADPAT1
	RET


LOADPATT:	DW	0





	

;NOMBRE: CAMBIA_INT
;OBJETIVO: COLOCA COMO VECTOR DE INTERRUPCION EL TEMPORIZADOR
;ENTRADA: HL -> PUNTERO AL JUMP CORRESPONDIENTE

PUT_VINT:	LD	HL,MI_VECTOR
CAMBIA_INT:	EXX
	LD	HL,INT
	LD	DE,VECTOR_INT
	LD	BC,5
	LDIR
	EXX
	DI
	LD	HL,MI_VECTOR
	LD	DE,INT
	LD	BC,5
	LDIR
	EI
	RET


;NOMBRE: RESTORE_INT
;OBJETIVO: COLOCA EL VECTOR DE INTERRUPCION ANTERIOR


RESTORE_INT:	DI
	LD	HL,VECTOR_INT
	LD	DE,INT
	LD	BC,5
	LDIR
	EI
	RET


MI_VECTOR:	JP	INTERRUPT
	DB	0,0


VECTOR_INT:	DB	0,0,0,0,0
TIME_:	DB	0



;NOMBRE: LOADIM
;OBJETIVO: ESTA FUNCION LEE UN FICHERO QUE SE LE PASA COMO PARAMETRO
;          Y LO DEPOSITA EN LA POSICION APUNTADA POR HL
;ENTRADA: HL-> NOMBRE DEL FICHERO RAW
;         DE-> BUFFER DESTINO
;SALIDA:  DE->  ALTO
;         BC->  ANCHO (PIXELS)
;         A->  SERA 0 SI NO HA HABIDO NINGUN ERROR Y OTRO VALOR EN CASO
;              CONTRARIO
;MODIFICA: DE,HL,BC,AF


LOADIM:	CALL	FILEOPEN
	LD	HL,4
	LD	DE,BUFFER
	CALL	READFILE
	LD	DE,(BUFFER+2)
	LD	HL,(BUFFER)
	PUSH	HL
	PUSH	DE
	CALL	MULTHLDE
	LD	DE,BUFFER
	CALL	READFILE
	CALL	CLOSEFILE
	POP	BC
	POP	DE
	SLA	E
	RL	D
	RET
	
	
	
		

	


	


				
	
	
			  
	   
	
	
		
	
						