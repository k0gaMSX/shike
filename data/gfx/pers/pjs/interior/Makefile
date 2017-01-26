COMP 	=	pack
GFX	= 	${addsuffix .pck, ${wildcard *.RAW}}


all: ${GFX}

$(GFX):	%.pck : %	
	$(COMP) $<

.PHONY: clean

clean:
	rm -f *.pck


