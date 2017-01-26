AS 	= asl	
GB 	= p2bin
SRC	= ${wildcard *.asm}
INC	= ${wildcard ../*.inc}
FLAGS	= -gnuerrors -cpu z80 -L -C -D OPENMSX -D DEBUG


game.com: game.p
	$(GB) game.p game.com

game.p: $(SRC) $(INC)
	$(AS) $(FLAGS) game.asm

