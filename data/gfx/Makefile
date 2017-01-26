MAKE 	= make
TMP 	= tmp


gfx: cd 
	
	
	
	cd $(ASM) && $(MAKE) game.com
	cp $(ASM)/game.com $(TMP)
	if [ -x rpg.dsk ] ; then rm rpg.dsk ; fi
	cp game.dsk rpg.dsk
	$(WDSK) rpg.dsk $(TMP)/game.com

test:	rpg
	openmsx -machine msx2 -ext debugdevice rpg.dsk 

clean:

