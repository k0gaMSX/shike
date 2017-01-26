
	

MusicC:
	assert "Pila= %p Comando de musica %d\n",(sp),a
	di
	push af		
	call PutPageD
	ld a,(PagMusAct)
	call PutPageM
	pop af	
	call mcdrvC
	call PutPageP1
	call PutPageP2
	ei
	assert "Fin de comando de musica\n"
	ret

	
	
;Nombre: PUTSNG
;Objetivo: Cargar y poner como cancion activa (no necesariamente hace 
;	   que se toque (depende del estado del fade).
;Entrada: A -> Numero de cancion a tocar (de 1 en adelante)
;Modifica: Todos los registros.
					

			
PutSng:	

	ld hl,MusicTbl-3
	ld b,a
	ld de,3
-	add hl,de
	djnz -
	
	assert "Cancion %d -> Pagina  %d\n",a,(hl)
	push hl
	ld a,(hl)
	ld (PagMusAct),a
	call PutPageM
	pop hl 
	inc hl
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
								
	ld a,MC_MUSICON
	ld hl,SongAct
	call MusicC

	ret


MusicTbl:	db 1
		dw SongAct		
PagMusAct:	db 0		; Este valor coincide con el del emulador para que en las primeras
				; Llamadas no se intente cargar nada				

	
	
	
Play:	
	di	
	ld hl,PlayOnD		; Semaforo de acceso a la musica
	xor a
	or (hl)
	ret nz
	
	inc a
	ld (hl),a
	ei
	
	call PutPageD
	ld a,(PagMusAct)
        call PutPageM	
	call mcdrv
	call PutPageP1
	call PutPageP2

	di
	ld hl,playOnD
	xor a
	ld (hl),a
	ei
	ret

PlayOnD:	 db 0		; Esto habria que inicializarlo en init_game



