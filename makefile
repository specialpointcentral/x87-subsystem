root: root.o
	gcc -g -Wall -o root root.o
root.o: root.asm
	nasm -g -f elf64 -w+all root.asm -o root.o
.PHONY: clean

clean:
	rm -f *.o root
