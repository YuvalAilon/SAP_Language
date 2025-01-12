import Foundation

struct SAPVM {
  var rPC: Int    //Program Counter
  var rCP: Int   //Compare Register
  var rST: Int     //Stack Register
  //--------------------------------------------------//
  var Memory: [Int]
  var Register: [Int]
  var stack = Stack<Int>(size: 500)
  //--------------------------------------------------//
  var quit = false
  var code : [Int]
   //--------------------------------------------------//
  init() {
    Memory = [0]
    Register = [0]
    rPC = 0
    rCP = 0
    rST = 0
    code = [0]
    Register = Array(repeating: 0, count: 10)
  }
  
  mutating func runCode(){
    if fileCheck(code){
      Memory = code
      Memory.remove(at: 0)
      Memory.remove(at: 0)
      rPC = code[1]
      rCP = 0
      rST = 0
      Register = Array(repeating: 0, count: 10)
      exectuteProgram: while !quit{
          let nextByte = NextByte()
          if CheckInstruction(nextByte) {
            executeInstruction(InstructionCode(rawValue: nextByte)!)
          }
          
      }
      quit = false
    }
  }
  
  mutating func NextByte() -> Int {
    if CheckMemory(rPC){
      let byte = Memory[rPC]
      rPC += 1
      return byte
    }
    return -1
    
  } 
  
  mutating func executeInstruction(_ code: InstructionCode){
    switch code {
      case	 .HALT  : halt()
      case	 .CLRR  : clrr(NextByte())
      case	 .CLRX  : clrx(NextByte())
      case	 .CLRM  : clrm(NextByte())
      case	 .CLRB  : clrm(NextByte())
      case	 .MOVIR : movir(NextByte() , NextByte())
      case	 .MOVRR : movrr(NextByte() , NextByte())
      case	 .MOVRM : movrm(NextByte() , NextByte())
      case	 .MOVMR : movmr(NextByte() , NextByte())
      case	 .MOVXR : movxr(NextByte() , NextByte())
      case	 .MOVAR : movar(NextByte() , NextByte())
      case	 .MOVB  :  movb(NextByte() , NextByte() , NextByte())
      case	 .ADDIR : addir(NextByte() , NextByte())
      case	 .ADDRR : addrr(NextByte() , NextByte())
      case	 .ADDMR : addmr(NextByte() , NextByte())
      case	 .ADDXR : addxr(NextByte() , NextByte())
      case	 .SUBIR : subir(NextByte() , NextByte())
      case	 .SUBRR : subrr(NextByte() , NextByte())
      case	 .SUBMR : submr(NextByte() , NextByte())
      case	 .SUBXR : subxr(NextByte() , NextByte())
      case	 .MULIR : mulir(NextByte() , NextByte())
      case	 .MULRR : mulrr(NextByte() , NextByte())
      case	 .MULMR : mulmr(NextByte() , NextByte())
      case	 .MULXR : mulxr(NextByte() , NextByte())
      case	 .DIVIR : divir(NextByte() , NextByte())
      case	 .DIVRR : divrr(NextByte() , NextByte())
      case	 .DIVMR : divmr(NextByte() , NextByte())
      case	 .DIVXR : divxr(NextByte() , NextByte())
      case	 .JMP   :   jmp(NextByte())
      case	 .SOJZ  :  sojz(NextByte() , NextByte())
      case	 .SOJNZ : sojnz(NextByte() , NextByte())
      case	 .AOJZ  :  aojz(NextByte() , NextByte())
      case	 .AOJNZ : aojnz(NextByte() , NextByte())
      case	 .CMPIR : cmpir(NextByte() , NextByte())
      case	 .CMPRR : cmprr(NextByte() , NextByte())
      case	 .CMPMR : cmpmr(NextByte() , NextByte())
      case	 .JMPN  :  jmpn(NextByte())
      case	 .JMPZ  :  jmpz(NextByte())
      case	 .JMPP  :  jmpp(NextByte())
      case	 .JSR   :   jsr(NextByte())
      case	 .RET   :   ret()
      case	 .PUSH  :  push(NextByte())
      case	 .POP   :   pop(NextByte())
      case	 .STACKC: stackc() 
      case	 .OUTCI : outci(NextByte())
      case	 .OUTCR : outcr(NextByte())
      case	 .OUTCX : outcx(NextByte())
      case	 .OUTCB : outcb(NextByte() , NextByte())
      case	 .READI : break 
      case	 .PRINTI: printi(NextByte()) 
      case	 .READC : break
      case	 .READLN: break
      case	 .BRK   : brk()
      case	 .MOVRX : movrx(NextByte() , NextByte())
      case	 .MOVXX : movxx(NextByte() , NextByte())
      case	 .OUTS  : outs(NextByte())
      case	 .NOP   : nop()
      case	 .JMPNE : jmpne(NextByte()) 
    }  
  }

  mutating func CheckRegister(_ r: Int) -> Bool{
    if r < 0 || r > 9 {
      ErrRegisterOutOfRange()
      return false
    }
    return true
  }

  mutating func CheckMemory(_ m: Int) -> Bool{
    if m < 0 || m > Memory.count {
      ErrMemoryOutOfRange()
      return false
    }
    return true
  }

  mutating func CheckDivisior(_ d: Int) -> Bool{
    if d == 0 {
      ErrDivByZero()
      return false
    }
    return true
  }

  mutating func CheckInstruction(_ i: Int) -> Bool{
    if i < 0 || i > 57 {
      ErrIllegalInstruction()
      return false
    }
    return true
  }

  
    mutating func ErrIllegalInstruction(){
      print("""
            \u{001B}[0;31mIllegal Instruction :(\u{001B}[0;37m
            
  """)
      quit = true
    }


     mutating func ErrDivByZero(){
      print("\u{001B}[0;Divide by Zero Error\u{001B}[0;37m")
       quit = true
    }
  
    mutating func ErrMemoryOutOfRange(){
      print("\u{001B}[0;31mThe memory location you were trying to access was out of range, thats all we know :/\u{001B}[0;37m")
      quit = true
    }
  
    mutating func ErrRegisterOutOfRange(){
      print("\u{001B}[0;31mThe memory location you were trying to access was out of range, thats all we know :/\u{001B}[0;37m")
      quit = true
    }
  
}
