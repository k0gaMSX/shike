MAKE 	= make
TMP 	= build
PJS	= pjs
PAG	= ./pagger.sh

all:
	cd $(PJS) && $(MAKE) 
	cp $(PJS)/$(TMP)/*.pck $(TMP) 
	$(PAG) $(TMP) pers.pag pers.lst
	


.PHONY: clean

clean:
	rm -f $(TMP)/*
	rm -f pers.pag
	rm -f pers.lst
	cd $(PJS) && $(MAKE) clean

