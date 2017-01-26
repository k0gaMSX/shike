TMP	= build
INT	= interior
EXT	= exterior
MAKE	= make


all:
	cd $(INT) && $(MAKE)
	cd $(EXT) && $(MAKE)
	cp $(INT)/* $(TMP)
	cp $(EXT)/* $(TMP)

.PHONY: clean

clean: 
	rm -f $(TMP)/*
	cd $(INT) && $(MAKE) clean
	cd $(EXT) && $(MAKE) clean
			
