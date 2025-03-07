enum InstructionCode : Int , CaseIterable {
  case	HALT  
  case	CLRR
  case	CLRX
  case	CLRM
  case	CLRB
  case	MOVIR
  case	MOVRR
  case	MOVRM
  case	MOVMR 
  case	MOVXR
  case	MOVAR
  case	MOVB
  case	ADDIR 
  case	ADDRR 
  case	ADDMR
  case	ADDXR
  case	SUBIR
  case	SUBRR
  case	SUBMR
  case	SUBXR
  case	MULIR
  case	MULRR
  case	MULMR
  case	MULXR
  case	DIVIR
  case	DIVRR
  case	DIVMR
  case	DIVXR
  case	JMP
  case	SOJZ
  case	SOJNZ
  case	AOJZ
  case	AOJNZ
  case	CMPIR
  case	CMPRR 
  case	CMPMR
  case	JMPN
  case	JMPZ
  case	JMPP
  case	JSR
  case	RET
  case	PUSH
  case	POP
  case	STACKC
  case	OUTCI
  case	OUTCR 
  case	OUTCX
  case	OUTCB
  case	READI
  case	PRINTI 
  case	READC
  case	READLN
  case	BRK
  case	MOVRX
  case	MOVXX
  case	OUTS 
  case	NOP
  case	JMPNE 
}

enum InstructionCodeString : String , CaseIterable {
  case	HALT  
  case	CLRR
  case	CLRX
  case	CLRM
  case	CLRB
  case	MOVIR
  case	MOVRR
  case	MOVRM
  case	MOVMR 
  case	MOVXR
  case	MOVAR
  case	MOVB
  case	ADDIR 
  case	ADDRR 
  case	ADDMR
  case	ADDXR
  case	SUBIR
  case	SUBRR
  case	SUBMR
  case	SUBXR
  case	MULIR
  case	MULRR
  case	MULMR
  case	MULXR
  case	DIVIR
  case	DIVRR
  case	DIVMR
  case	DIVXR
  case	JMP
  case	SOJZ
  case	SOJNZ
  case	AOJZ
  case	AOJNZ
  case	CMPIR
  case	CMPRR 
  case	CMPMR
  case	JMPN
  case	JMPZ
  case	JMPP
  case	JSR
  case	RET
  case	PUSH
  case	POP
  case	STACKC
  case	OUTCI
  case	OUTCR 
  case	OUTCX
  case	OUTCB
  case	READI
  case	PRINTI 
  case	READC
  case	READLN
  case	BRK
  case	MOVRX
  case	MOVXX
  case	OUTS 
  case	NOP
  case	JMPNE 
}