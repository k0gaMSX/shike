assert macro cadctr,pars
	ifdef DEBUG
	
	  if cadctr <> ""
	    jp next	     
cad:	    db cadctr,0
r_sp:	    dw 0		
old_sp:	    dw 0
pushls:	    dw 0

			
next:	    	    
            push hl    
	    ld hl,-6
	    add hl,sp
	    ld (r_sp),hl
	    ld hl,2
	    add hl,sp
	    ld (old_sp),hl

            push af
            ld a,r		; Salvar el estado de las interrupciones
	    push af
	    pop hl
	    ld a,l
	    ld (prt_di),a	    
            pop af
	    pop hl
            di
		 
	    push hl
	    push de
	    push bc
	    push af
      	    ld (pushls),hl
	    shift
	    pushlist ALLARGS
	    ld hl,cad
	    call prt_d

	    ld hl,(r_sp)
	    ld sp,hl	

            ld a,(prt_di) 
	    bit 2,a
	    jr z,+
	    ei		; Restauramos estado de las interrupciones

+	    pop af
	    pop bc
	    pop de
	    pop hl	
	  endif
	endif
     endm
  	


pushlist macro reg
       if "reg" <> ""
          pushlist CDRARGS
          pusht reg
       endif
       endm

      			
pusht	macro r		
      if  (upstring("r")=="AF") || (upstring("r")=="BC") 
	push r
      elseif (upstring("r")=="DE") || (upstring("r")=="HL") 
	push r
      elseif (upstring("r")=="IX") || (upstring("r")=="IY")
	push r
      elseif (upstring("r")=="SP")
	ld hl,(old_sp)
	push hl
	ld hl,(pushls)
      elseif strstr("r","(") <> -1
	if strstr(upstring("r"),"(SP)") <> -1
	   ld hl,(old_sp)
	   push af
	   ld a,(hl)
	   inc hl
	   ld h,(hl)
	   ld l,a
	   pop af
	   push hl
	   ld hl,(pushls)	   
	else
	   push8b r
	endif
      elseif (upstring("r")=="A") 
      	push8b r
      elseif (upstring("r")=="B")   || (upstring("r")=="C") 
	push8b r
      elseif (upstring("r")=="D")   || (upstring("r")=="E") 
	push8b r
      elseif (upstring("r")=="H")   || (upstring("r")=="L") 
	push8b r
      elseif (upstring("r")=="IYH") || (upstring("r")=="IHL")
	push8b r
      elseif (upstring("r")=="IYH") || (upstring("r")=="IHL") 
	push8b r
      else		
	ld hl,r
	push hl
	ld hl,(pushls)
      endif
      endm


push8b macro r	
	push af
	ld a,r	
	ld l,a
	pop af
	ld h,0
	push hl
	ld hl,(pushls)
	endm



	






