AS 	= asl	
GB 	= p2bin
MAKE 	= make
TMP 	= tmp
ASM	= asm
DATA	= data
WDSK	= wrdsk


rpg:
	cd $(ASM) && $(MAKE) game.com
	cp $(ASM)/game.com $(TMP)
	if [ -x rpg.dsk ] ; then rm rpg.dsk ; fi
	cp game.dsk rpg.dsk
	$(WDSK) rpg.dsk $(TMP)/game.com

test:	rpg
	openmsx -machine turbor -ext debugdevice rpg.dsk 

.PHONY: clean

clean:
	cd $(ASM) && $(MAKE) clean
	cd $(DATA) && $(MAKE) clean
	rm -f rpg.dsk
	rm -f $(TMP)/*
	

