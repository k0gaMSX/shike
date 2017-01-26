
	
	
;;;Nombre: prt_d
;;;Objetivo: mostrar una cadena de depuracion (valida para openMSX)
;;;Entrada: hl -> cadena de control (terminada en 0) //Control string
;;;Modifica: hl,af,bc				     //Modidy register

	ifdef   DEBUG
	ifdef	OPENMSX

prt_di:	   db  0	
	
		
prt_d:     
	   ld a,(hl)
	   or a
	   ret z
	
	   pop bc
	   ld (r_sp),bc
	   

	   ld a,23h
	   ld b,a
	   ld c,02eh
	
	   ld a,b
	   out (c),a
prt_dl	   ld a,(hl)
	   inc hl
	   or a	   
	   jr nz,+
	     ld a,b		; Fin de cadena //end of control string
	     out (c),a
	     ld hl,(r_sp)
	     jp (hl)
	
		
+	   cp '%'		; especificador de formato //format type
	   jr nz,+
	   jr prt_par	   
			   	
		
+	   cp '\\'		; Constante de tipo caracter //character constant
	   jr nz,+
	     ld a,(hl)
	     inc hl
	     call prt_ccar
	     or a
             jr z,prt_dl
			
+	   out (02fh),a		; otro caracter de la cadena de control //character of control string
	   jr prt_dl
	   												
r_sp:	dw 0
		   	   		
		
prt_ccar: ld a,(hl)
	  inc hl 
	  cp 'n'
	  jr nz,+
	    ld a,'*'
	    out (02fh),a
	    ld a,0ch	    	    
	    ret
+	  cp 'a'
	  jr nz,+
	    ld a,7
	    ret
	

+	xor a	
	ret			; añadir mas constantes ... 




prt_par:     		
	     ld a,(hl)
	     inc hl
	     cp 'd'
	     jr nz,+

	       ld a,b		; numero decimal
	       out (c),a
	       ld a,22h
	       out (c),a
	       pop de
	       ld a,e
	       out (02fh),a
	       ld a,22h
	       out (c),a
	       ld a,b
	       out (c),a
	       jr prt_dl

+	    cp 'x'
	    jr nz,+		;Comprobar  caso de la cadena y caracter

	       ld a,b		; numero hexadecimal
	       out (c),a
	       ld a,20h
	       out (c),a
	       pop af
	       out (02fh),a
	       ld a,20h
	       out (c),a
	       ld a,b
	       jr prt_dl
+	   cp 's'	   
	   jr nz,+
 	       pop de
	       call prt_cad
 	       jr prt_dl
+ 	   cp 'p'
	   jr nz,+
	       pop de
	       call prt_ptr
	       jp prt_dl
		
+	   jp prt_dl		; I must add %c,%p format


prt_ptr:	 
	ld a,b		; Imprimir direccion
	out (c),a
	ld a,20h
	out (c),a
	ld a,d
	out (02fh),a
	ld a,e
	out (02fh),a
	ld a,20h
	out (c),a
	ld a,b
	out (c),a
	ret

	
prt_cad:
	ld a,(de)
	inc de
	or a
	ret z
	out (02fh),a
	jr prt_cad
	
	endif
prt_b:	ret	
	endif
	