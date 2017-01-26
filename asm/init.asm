;NOMBRE:  INIT_GAME
;OBJETIVO: SE ENCARGA DE INICIALIZAR EL MODO GRAFICOS ASI COMO LAS ESTRUCTURAS
;          DE DATOS GENERICAS, ADEMAS DE CARGAR LO FICHEROS QUE SE VAN A USAR
;          A LO LARGO DEL JUEGO.


INIT_GAME:
	CALL	INIT_SYS
	LD	A,5
	CALL	INITSCR
	LD	A,MC_INICHIPS
	CALL	MUSICC
	LD	A,MC_MUSICOFF
	CALL	MUSICC

	CALL	PUT_VINT
	CALL	RESTORE_INT
	CALL	COLOR0_OFF
	CALL	VIS_OFF
	LD	HL,PAL_NEGRO
	CALL	PUT_PAL
	LD	A,0Dh
	CALL	SET_CFONDO
	CALL	SET_SPD16
	CALL	SPD_OFF
	CALL	WAIT_COM

	LD	A,COLOR_NEGRO
	CALL	LIMPIA_VRAM
	CALL	INIT_SPTBL

	CALL	LOADSP
	CALL	INIT_CRUZ
	CALL	HIDE_CRUZ
	CALL	INIT_CUAD
	CALL	HIDE_CUAD
	CALL	VIS_ON
	CALL	LOADTIPOS
	CALL	MAKEMARK
	CALL	LOAD_OBJ

	LD	HL,OPTIONS
	LD	IX,0
	LD	IY,(PAG_OPTIONS*256)+COORDY_OPT
	CALL	LPIMAGE

	LD	HL,CARAS
	LD	IX,0
	LD	IY,PAG_OBJETOS*256+128
	CALL	LPIMAGE

	CALL	INIT_PERV
	LD	HL,STRPER_VECMAP
	LD	(PTR_PERSO),HL
	CALL	INITPJS
	RET







;NOMBRE: GO_CIUDAD
;OBJETIVO: CARGA LOS DATOS DE UNA CIUDAD E INICIALIZA TODOS LOS DATOS
;          NECESARIOS.
;ENTRADA: L -> NUMERO DE CIUDAD (NUMERADOS DE 1 A 10). SI SE INTRODUCE
;              0 LA FUNCION PUEDE FALLAR

GO_CIUDAD:
	PUSH	HL
	PUSH	HL
	PUSH	HL

	CALL	RESTORE_INT
	CALL	VIS_OFF

	LD	A,GET_DIR_KEY
	LD	(MODO_GET_DIR),A

	LD	A,16
	LD	(ANCHOPIXPER),A
	LD	A,28
	LD	(ALTOPIXPER),A
	LD	A,PERIODOS
	LD	(PERIODO),A
	LD	HL,TABLA_PATC
	LD	(TBLCP_PTR),HL
	LD	HL,TABLA_ANIMC
	LD	(TBLAN_PTR),HL
	LD	HL,FT_AUTOC
	LD	(AUTO_PTR),HL
	LD	HL,PROPIEDAD_VEC
	LD	(PROP_PTR),HL
	LD	HL,MAXVALXRC
	LD	(MAXVALXR),HL
	LD	HL,MAXVALYRC
	LD	(MAXVALYR),HL

	LD	HL,PROF_PERSOC
	LD	(PROF_PERSO),HL
	LD	HL,PROF_PERSOARC
	LD	(PROF_PERSOAR),HL


	POP	HL
	LD	DE,12
	LD	H,0
	CALL	MULTHLDE
	LD	DE,NIVELDAT+STRNIV_CIUD1
	ADD	HL,DE
	CALL	LOADMAP

	LD	B,12
	LD	HL,MAPEADO_DAT+STRMAP_PAT0
	CALL	LOADPAT

	LD	IX,0
	LD	IY,PAG_PATRONES*256+COORDY_PAT
	LD	HL,MAPEADO_DAT+STRMAP_PATMAP
	CALL	LPIMAGE

	LD	HL,MAPEADO_DAT+STRMAP_MAPA
	CALL	LOADPANT


	LD	A,2
	LD	(MAPEACONT),A
	XOR	A
	LD	(NUMPAT2PLN),A
	LD	(PAG_ACT),A
	LD	(SCROLLST),A
	LD	(SCROLLSOL),A
	LD	(MOVPJSPTR),A
	LD	(MAPRUT_OFF),A
	LD	(SINCRO),A
	LD	(SOL_CHGP),A
	LD	(BUFFER_FUNC),A
	LD	(KEY_SPST),A
	LD	(KEY_F1ST),A


	LD	A,080h
	LD	B,TAM_FIFO
	LD	HL,MOVPJSWAY
GO_CIUDAD1	LD	(HL),A
	INC	HL
	DJNZ	GO_CIUDAD1
	LD	(BUFFER_INT),A

	LD	HL,1
	LD	(DESP_PANTX),HL
	LD	HL,1
	LD	(DESP_PANTY),HL

	LD	HL,INC_MOVS
	LD	(INC_MOV),HL
	LD	A,ANIMACIONIC
	LD	(ANIMACIONI),A
	LD	A,INTERIOR
	LD	(MODO_GAME),A
	LD	A,4
	LD	(ALTOPATPER),A
	LD	A,2
	LD	(ANCHOPATPER),A
	LD	A,1
	LD	(PAG_NACT),A
	INC	A
	LD	(SWAP_CONT),A


	LD	IX,(PTR_PERSO)
	LD	HL,(MAPEADO_DAT+STRMAP_XDEF)
	LD	DE,(MAPEADO_DAT+STRMAP_YDEF)
	LD	B,0
	LD	C,CEN_TOTAL
	LD	A,B
	CALL	SET_XY


	POP	HL	;AHORA PASAMOS A COPIAR LOS
	LD	H,0	;PJS A ESTE MAPA
	DEC	L
	LD	DE,STRUCTPERSO*MAXPERSOC
	CALL	MULTHLDE
	LD	DE,STRPER_VECCIT
	ADD	HL,DE
	LD	DE,(PTR_PERSO)
	EX	DE,HL
	LD	BC,STRUCTPERSO*MAXNUMPJS
	LDIR

	LD	HL,HANDLE_DEF
	LD	(HANDLE_EKB),HL

	POP	HL
	CALL	INIT_INDEXPER
	CALL	INIT_FIGURASV
	CALL	INIT_BUFPAG
	LD	HL,MAPEADO_DAT+STRMAP_PROP
	CALL	LOADPROP
	CALL	GET_DIR
	LD	A,(PAG_ACT)
	CALL	VER_PAGE

	LD	A,TIMEFADE
	LD	(FADE_V),A
	CALL	VIS_ON
	CALL	PUT_VINT
	CALL	SETVDP_LI
	RET


;NOMBRE: GO_EXTERIOR
;OBJETIVO: CARGA LOS DATOS DE LOS EXTERIORES E INICIALIZA TODOS LOS DATOS
;          NECESARIOS.


GO_EXTERIOR:	CALL	RESTORE_INT
	CALL	VIS_OFF

	LD	A,GET_DIR_KEY
	LD	(MODO_GET_DIR),A

	LD	A,32
	LD	(ANCHOPIXPER),A
	LD	(ALTOPIXPER),A
	LD	A,PERIODOS
	LD	(PERIODO),A
	LD	HL,TABLA_PATE
	LD	(TBLCP_PTR),HL
	LD	HL,TABLA_ANIMAE
	LD	(TBLAN_PTR),HL
	LD	HL,FT_AUTOE
	LD	(AUTO_PTR),HL
	LD	HL,PROPIEDAD_VEC
	LD	(PROP_PTR),HL
	LD	HL,MAXVALXRE
	LD	(MAXVALXR),HL
	LD	HL,MAXVALYRE
	LD	(MAXVALYR),HL

	LD	HL,PROF_PERSOM
	LD	(PROF_PERSO),HL
	LD	(PROF_PERSOAR),HL

	LD	HL,NIVELDAT+STRNIV_MAPEX
	CALL	LOADMAP

	LD	B,8
	LD	HL,MAPEADO_DAT+STRMAP_PAT0
	CALL	LOADPAT

	LD	IX,0
	LD	IY,PAG_PATRONES*256+COORDY_PAT
	LD	HL,MAPEADO_DAT+STRMAP_PATMAP
	CALL	LPIMAGE

	LD	HL,MAPEADO_DAT+STRMAP_MAPA
	CALL	LOADPANT

	CALL	LOADSP

	LD	A,2
	LD	(MAPEACONT),A
	XOR	A
	LD	(NUMPAT2PLN),A
	LD	(PAG_ACT),A
	LD	(SCROLLST),A
	LD	(SCROLLSOL),A
	LD	(MOVPJSPTR),A
	LD	(MAPRUT_OFF),A
	LD	(SINCRO),A
	LD	(SOL_CHGP),A
	LD	(BUFFER_FUNC),A
	LD	(KEY_SPST),A
	LD	(KEY_F1ST),A


	LD	A,80h
	LD	B,TAM_FIFO
	LD	HL,MOVPJSWAY
GO_EXTERIOR1	LD	(HL),A
	INC	HL
	DJNZ	GO_EXTERIOR1
	LD	(BUFFER_INT),A

	LD	HL,15
	LD	(DESP_PANTX),HL
	LD	HL,20
	LD	(DESP_PANTY),HL

	LD	HL,INC_MOVS
	LD	(INC_MOV),HL
	LD	A,ANIMACIONIM
	LD	(ANIMACIONI),A
	LD	A,EXTERIOR
	LD	(MODO_GAME),A
	LD	A,4
	LD	(ALTOPATPER),A
	LD	A,4
	LD	(ANCHOPATPER),A
	LD	A,1
	LD	(PAG_NACT),A
	INC	A
	LD	(SWAP_CONT),A

	LD	HL,HANDLE_DEF
	LD	(HANDLE_EKB),HL


	LD	L,0
	CALL	INIT_INDEXPER
	CALL	INIT_FIGURASV
	CALL	INITPJS
	CALL	INIT_BUFPAG
	LD	HL,MAPEADO_DAT+STRMAP_PROP
	CALL	LOADPROP
	CALL	GET_DIR
	LD	A,(PAG_ACT)
	CALL	VER_PAGE

	LD	A,TIMEFADE
	LD	(FADE_V),A
	CALL	VIS_ON
	CALL	PUT_VINT
	CALL	SETVDP_LI


	LD	IX,(PTR_PERSO)
	LD	HL,(MAPEADO_DAT+STRMAP_XDEF)
	LD	DE,(MAPEADO_DAT+STRMAP_YDEF)
	LD	B,0
	LD	C,CEN_TOTAL
	LD	A,5
	CALL	SET_XY


	LD	A,3
	LD	(WRITE_CONT),A
	LD	B,3
GO_CIUDAD3	PUSH	BC
	CALL	DO_VISUAL
	POP	BC
	DJNZ	GO_CIUDAD3
	RET




;NOMBRE: LOADPROP
;OBJETIVO: CARGAR LAS PROPIEDADES DE UNAS TEXTURAS.
;ENTRADA: HL -> NOMBRE DEL FICHERO



LOADPROP:	CALL	FILEOPEN
	LD	HL,SIZ_PROPVEC
	LD	DE,PROPIEDAD_VEC
	CALL	READFILE
	CALL	CLOSEFILE
	RET





;NOMBRE: LOADPANT
;OBJETIVO: CARGAR UNA PANTALLA CONTENIDA EN UN ARCHIVO
;ENTRADA:     HL: PUNTERO AL NOMBRE DEL FICHERO DE  LA PANTALLA
;SALIDA: A: SERA 0 SI NO SE HA PRODUCIDO NINGUN ERROR Y OTRO VALOR EN CASO
;           CONTRARIO
;MODIFICA: DE,HL,BC,AF


LOADPANT:	CALL	FILEOPEN
	LD	HL,4
	LD	DE,BUFFER
	CALL	READFILE
	LD	HL,(BUFFER+2)
	LD	(TAM_FILA_MTEX),HL
	LD	DE,(BUFFER)
	PUSH	DE
	CALL	MULTHLDE
	LD	DE,BUFFER
	CALL	READFILE
	CALL	CLOSEFILE

	XOR	A
	POP	BC
	LD	DE,BUFFER
	LD	HL,INDEXMAPA
LOADPANT2	XOR	A
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	PUSH	HL
	LD	HL,(TAM_FILA_MTEX)
	ADD	HL,DE
	LD	D,H
	LD	E,L
	POP	HL
	DEC	BC
	OR	C
	JR	NZ,LOADPANT2
	OR	B
	JR	NZ,LOADPANT2
	RET

