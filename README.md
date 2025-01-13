# SAP_Language

## Project Description

This program is an assembler and compiler for the SAP (Simple Assembly Programming) Language. SAP is a language based on the language of the [PDP-11](https://en.wikipedia.org/wiki/PDP-11).

This project contains three sample programs:
- An exponent function
- Sum of Squares
- A Turing Machine (my favourite :P )

## Running Your Programs

To run your own program first assemble it using the ```asm``` command. Assembling you program will always produce an LST file. This file shows the first 4 bytes contained in each line of you program, as well as a symbol table. If any errors are present, they will apear in the LST file as well.

If your program has no errors, a BIN file will also be created. This is the file that the compiler uses to run your code. However, make sure you do not include the BIN file ending when running your program, or it will not work.

### <span style="color:green">Correct</span>
```
run myProgram
```
### <span style="color:red">Incorrect</span>
```
run myProgram.bin
```

Below is a list of all instructions in the SAP Language. The language is [Turing Complete](https://en.wikipedia.org/wiki/Turing_completeness), allowing you to create pretty much anything. Have fun!

## Instructions
```
%r -> Register
%i -> Integer
%l -> Label
%m -> Memory Location
```
###	HALT
```HALT```

Halts the program.
###	CLRR
```CLRR %r```

Sets r to 0.
###	CLRX
```CLRX %r```
 
 Sets the memory location stored in r to 0.
###	CLRM
```CLRM %l```

Sets the memory location stored in l to 0.
###	CLRB
```CLRB %i1 %i2```

Sets all memory locations in the range i1 to i2 (inclusive) to 0.
###	MOVIR
```MOVIR %i %i```

Sets the value of r to i.
###	MOVRR
```MOVRR %r1 %r2```

Sets the value of r2 to the value of r1.
###	MOVRM
```MOVRM %r %l```

Sets the value of l to the value of r.
###	MOVMR 
```MOVMR %l %r```

Sets the value of r to the value of l.
###	MOVXR
```MOVXR %r1 %r2```

Sets r2 to the value of the memory location stored in r1.
###	MOVRX
```MOVRX %r1 %r2```

Sets the memory location stored in r2 to r1. 
###	MOVAR
```MOVAR %l %r```

Sets r to the memory adress of l.
###	MOVXX
```MOVXX %r1 %r2```

Sets the memory address stored in r2 to the value of the memory address stored in r1.
###	MOVB
```MOVB %r1 %r2 %3```

Moves a block of memory. r1 is the address of source, r2 is the address of the destination, and r3 is the size of the block.
###	ADDIR
```ADDIR %i %r```

Adds i to r.
###	ADDRR 
```ADDIR %r1 %r2```

Adds the value of r1 to r2.
###	ADDMR
```ADDMR %l %r```

Adds the value of l to r2.
###	ADDXR
```ADDXR %r1 %r2```

Adds the value of the memory location stored in r1 to r2.
###	SUBIR
```SUBIR %i %r```

Subtracts i from r.
###	SUBRR 
```SUBIR %r1 %r2```

Subtracts the value of r1 from r2.
###	SUBMR
```SUBMR %l %r```

Subtracts the value of l from r2.
###	SUBXR
```SUBXR %r1 %r2```

Subtracts the value of the memory location stored in r1 from r2.
###	MULIR
```MULIR %i %r```

Stores the product of i and r in r.
###	MULRR
```MULRR %r1 %r2```

Stores the product of r1 and r2 in r2.
###	MULMR
```MULMR %l %r```

Stores the product of l and r in r.
###	MULXR
```MULXR %r1 %r2```

Stores the product of the value of the memory location stored in r1 and r2 in r2.
###	DIVIR
```DIVIR %i %r```

Stores the quotient of i and r in r.
###	DIVRR
```DIVRR %r1 %r2```

Stores the quotient of r1 and r2 in r2.
###	DIVMR
```DIVMR %l %r```

Stores the quotient of l and r in r.
###	DIVXR
```DIVXR %r1 %r2```

Stores the quotient of the value of the memory location stored in r1 and r2 in r2.
###	JMP
```JMP %l```

Sets the program counter to l
###	SOJZ
```SOJZ %r %l```

**S**ubtract **O**ne **J**ump **Z**ero. Decrements r by one, and sets the program counter to l if the new value of r is equal to 0.
###	SOJNZ
```SOJNZ %r %l```

**S**ubtract **O**ne **J**ump **N**ot **Z**ero. Decrements r by one, and sets the program counter to l if the new value of r is not equal to 0.
###	AOJZ
```AOJZ %r %l```

**A**dd **O**ne **J**ump **Z**ero. Increments r by one, and sets the program counter to l if the new value of r is equal to 0.
###	AOJNZ
```AOJNZ %r %l```

**A**dd **O**ne **J**ump **N**ot **Z**ero. Increments r by one, and sets the program counter to l if the new value of r is not equal to 0.
###	CMPIR
```CMPIR %i %r```

Sets the compare register to i minus the value of r.
###	CMPRR 
```CMPRR %r1 %r2```

Sets the compare register to r2 minus the value or r1.
###	CMPMR
```CMPMR %l %r```

Sets the compare register to l minus the value or r.
###	JMPNE 
```JMPNE %l```

**J**u**mp** **N**ot **E**qual. Jumps to l if the compare register does not equal zero.
###	JMPN
```JMPN %l```

**J**u**mp** **N**egative. Sets the program counter to l if the value in the compare register is less than zero.
###	JMPZ
```JMPN %l```

**J**u**mp** **Z**ero. Sets the program counter to l if the value in the compare register is equal to zero.
###	JMPP
```JMPN %l```

**J**u**mp** **P**ositive. Sets the program counter to l if the value in the compare register is greater than zero.
###	JSR
```JSR %l```

**J**ump to **S**ub**R**outine. Jumps to subroutine l. Temporarily sets registers r5 through r9 to zero, to be used in the subroutine.
###	RET
```RET```

**Ret**urn. Returns from the current subroutine. Recovers value of registers r5 through r9 before the jump to this subroutine.
###	PUSH
```PUSH %r```

Pushes r onto the stack.
###	POP
```Pop %r```

Pops r from the stack, overwriting its current value.
###	STACKC
```STACKC```

**Stack** **C**heck. Prints the following codes to the console based on the stack's state:

- ```0``` | Stack is not empty, but not at capacity
- ```1``` | Stack is full
- ```2``` | Stack is empty

This function can be used for debugging, but has no effect on memory or registers.
###	OUTCI
```OUTCI %i```

Prints the unicode character with code i.
###	OUTCR 
```OUTCR %r```

Prints the unicode character with the value stored in r.
###	OUTCX
```OUTCX %r```

Prints the unicode character with the value of the memory location stored in r.
###	OUTCB
```OUTCB %r1 %r2```

Prints a block of unicode characters. Starts at the memory location stored in r1, and prints r2 characters.
###	PRINTI 
```PRINTI %r```

**Print** **I**nteger. Prints the integer value stored in r.
###	OUTS 
```OUTS %l```

Prints the string stored in l.
###	NOP
```NOP```

**N**o **Op**eration. Does nothing :/


## Datatypes
### String
Stored as a a sequnce of ASCII codes. The number at the memory adress of the string corresponds to it's length.

For example, the string "[Ada Lovelace](https://en.wikipedia.org/wiki/Ada_Lovelace)" would be stored like this:
```
12 65 100 97 32 76 111 118 101 108 97 99 101
↑   A   d  a     L   o   v   e   l  a  c   e
↑
Length of string
```
### Integer
The datatype stored in memory and registers.
### Tuple
The "Turing Tuple" was created to aid with implementation of a turing machine. A tuple holds 5 characters and is denoted with the use of backslash characters:

```
\a b c d e\
```
Tuple Components:
- ```a``` | Current State
- ```b``` | Current Tape Character
- ```c``` | New State
- ```d``` | New Tape Character
- ```e``` | Move left, right, or none

The tuple takes up 5 spaces in memory. **States** are stored as integers, and **Tape Characters** are stored as ascii codes. Direction is stored as an integer as follows:
- ```l``` | left, -1
- ```r``` | right, 1
- ```n``` | none, 0

---
This project was developed by Yuval Ailon (me) in collaboration with Jake McPherson.
