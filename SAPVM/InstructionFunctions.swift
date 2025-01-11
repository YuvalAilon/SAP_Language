import Foundation
extension SAPVM {
  mutating func halt() {
    quit = true;
  }
  mutating func clrr(_ r: Int){
    if CheckRegister(r){
      Register[r] = 0
    }
  }
  mutating func clrx(_ r: Int){
    if CheckRegister(r) {
      Memory[Register[r]] = 0
    }
  }
  mutating func clrm(_ label: Int){
    if CheckMemory(label){
      Memory[label] = 0
    }

  }
  mutating func clrb(_ start: Int,_ end: Int){
    for i in start...end {
      if CheckMemory(i) {
        Memory[i] = 0
      }
    }
  }
  mutating func movir(_ int: Int, _ r: Int){
    if CheckRegister(r) {
      Register[r] = int
    }
  }
  mutating func movrr(_ r1: Int,_ r2: Int) {
    if CheckRegister(r1) && CheckRegister(r2) {
      Register[r2] = Register[r1]
    } 
  }
  mutating func movrm(_ r: Int,_ label: Int){
    if CheckRegister(r) && CheckMemory(label) {
      Memory[label] = Register[r]
    }
    
  }
  mutating func movmr(_ label: Int,_ r: Int) {
    if CheckRegister(r) && CheckMemory(label){
      Register[r] = Memory[label]
    }
  }
  mutating func movxr(_ r1: Int,_ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckMemory(Register[r1]){
      Register[r2] = Memory[Register[r1]]
    }
  }
  mutating func movar(_ label: Int,_ r: Int){
    if CheckRegister(r) && CheckMemory(label) {
      Register[r] = label
    }
  }
  mutating func movb(_ r1: Int, _ r2: Int, _ r3: Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckRegister(r3){
      var memToMove = [Int]()

      for i in Register[r1] ..< Register[r1] + Register[r3]{
        if CheckMemory(i){
          memToMove.append(Memory[i])
        }
      }
  
      for i in  0 ..< memToMove.count {
        if CheckMemory(Register[r2] + i){
          Memory[Register[r2] + i] = memToMove[i]
        }  
      }
    }
    
    //Move a block of memory. The source is specified by r1, the destination by r2, the count is in r3

    
  }
  mutating func addir(_ int: Int, _ r: Int){
    if CheckRegister(r) {
      Register[r] += int  
    }
    
  }
  mutating func addrr(_ r1: Int,_ r2:Int){
    if CheckRegister(r1) && CheckRegister(r2){
      Register[r2] += Register[r1]
    }
  }
  mutating func addmr(_ label: Int,_ r:Int){
    if CheckRegister(r) && CheckMemory(label){
      Register[r] += Memory[label]
    } 
  }
  mutating func addxr(_ r1: Int,_ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2){
      Register[r2] += Memory[Register[r1]]
    }
  }
   mutating func subir(_ int: Int, _ r: Int){
    if CheckRegister(r){
      Register[r] = Register[r] - int
    }
    
  }
  mutating func subrr(_ r1: Int,_ r2:Int){
    if CheckRegister(r1) && CheckRegister(r2){
      Register[r2] = Register[r2]-Register[r1]
    } 
  }
  mutating func submr(_ label: Int,_ r:Int){
    if CheckRegister(r) && CheckMemory(label){
      Register[r] = Register[r]-Memory[label]
    }
  }
  mutating func subxr(_ r1: Int,_ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckMemory(Register[r1]){
      Register[r2] = Register[r2] - Memory[Register[r1]]
    }
  }
  mutating func mulir(_ int: Int, _ r: Int){
    if CheckRegister(r){
      Register[r] *= int
    }
  }
  mutating func mulrr(_ r1: Int,_ r2:Int){
    if CheckRegister(r1) && CheckRegister(r2){
      Register[r2] *= Register[r1]
    }
  }
  mutating func mulmr(_ label: Int,_ r:Int){
    if CheckRegister(r) && CheckMemory(label){
      Register[r] *= Memory[label]
    }
  }
  mutating func mulxr(_ r1: Int,_ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckMemory(Register[r1]){
      Register[r2] *= Memory[Register[r1]]
    }
  }
  mutating func divir(_ int: Int, _ r: Int){
    if CheckRegister(r) && CheckDivisior(Register[r]){
      Register[r] = int/Register[r]
    }
  }
  mutating func divrr(_ r1: Int,_ r2:Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckDivisior(Register[r2]){
      Register[r2] = Register[r1]/Register[r2]
    }
    
  }
  mutating func divmr(_ label: Int,_ r:Int){
    if CheckRegister(r) && CheckMemory(label) && CheckDivisior(Register[r]){
      Register[r] = Memory[label]/Register[r]
    }
  }
  mutating func divxr(_ r1: Int,_ r2:Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckMemory(Register[r1]) && CheckDivisior(Register[r2]){
      Register[r2] = Memory[Register[r1]]/Register[r2]
    }
    
  }
  mutating func jmp(_ label: Int){
    if CheckMemory(label){
      rPC = label
    }
  }
  mutating func sojz(_ r: Int, _ label: Int){
    if CheckRegister(r) && CheckMemory(label){
        Register[r] -= 1
      if Register[r] == 0{
        rPC = label
      }
    }
    
  }
  mutating func sojnz(_ r: Int, _ label: Int){
    if CheckRegister(r) && CheckMemory(label) {
      Register[r] -= 1
      if Register[r] != 0{
        rPC = label
      }
    }
    
  }
  mutating func aojz(_ r: Int, _ label: Int){
    if CheckRegister(r) && CheckMemory(label){
      Register[r] += 1
      if Register[r] == 0{
        rPC = label
      }
    }
  }
  mutating func aojnz(_ r: Int, _ label: Int){
    if CheckRegister(r) && CheckMemory(label){
      Register[r] += 1
      if Register[r] != 0{
        rPC = label
      }
    }  
  }
  mutating func cmpir(_ i: Int, _ r: Int){  
    if CheckRegister(r){
      rCP = i-Register[r]
    }
    
  }
  mutating func cmprr(_ r1: Int, _ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2){
      rCP = Register[r2]-Register[r1]
    }
  }
  mutating func cmpmr(_ label: Int, _ r: Int){
    if CheckMemory(label) && CheckRegister(r){
      rCP = Memory[label] - Register[r]
    }
    
  }
  
  mutating func jmpn(_ label: Int){
    if CheckMemory(label){
      if rCP < 0 {
        rPC = label
      }
    }
    
  }
  mutating func jmpz(_ label: Int){
    if CheckMemory(label){
      if rCP == 0 {
        rPC = label
      }
    }
    
  }
  mutating func jmpp(_ label: Int){
    if CheckMemory(label) {
      if rCP > 0 {
        rPC = label
      }
    }
    
  }
  mutating func jsr(_ label: Int){
    if CheckMemory(label) {
      stack.push(rPC)
      for r in 5...9 {
        stack.push(Register[r])
        Register[r] = 0
      }
      rPC = label
      } 
  }
  mutating func ret(){
    for r in 5...9 {
      Register[r] = stack.pop()!
    }
    rPC = stack.pop()!
  }
  mutating func push(_ r: Int){
    if CheckRegister(r) {
      stack.push(Register[r])
    }
  }
  mutating func pop(_ r: Int){
    if CheckRegister(r) {
      Register[r] = stack.pop()!
    }   
  }
  mutating func stackc(){
    if stack.isEmpty() {
      print(2)
    }
    else if stack.isFull() {
      print(1)
    } else{
      print(0)}
  }
  mutating func outci(_ i:Int){
    print(unicodeValueToCharacter(i), terminator:"")
  }
  mutating func outcr(_ r: Int){
    if CheckRegister(r){
      print(unicodeValueToCharacter(Register[r]), terminator:"")
    }
  }
  mutating func outcx(_ r: Int){
    if CheckRegister(r) && CheckMemory(Register[r]) {
      print(unicodeValueToCharacter(Memory[Register[r]]), terminator:"")
    }
  }
  mutating func outcb(_ r1: Int, _ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2){
      for i in 0 ... r2 - 1{
        if CheckMemory(Register[r1] + i){
          print(unicodeValueToCharacter(Memory[Register[r1 + i]]), terminator:"")
        }
      }
    } 
  }
  mutating func readi(){}
  mutating func printi(_ r: Int) {
    if CheckRegister(r){
      print(Register[r], terminator: "")
    }
  }
  
  mutating func brk(){
  }
  
  mutating func movrx(_ r1: Int, _ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckMemory(Register[r2]){
      Memory[Register[r2]] = Register[r1]
    }
  }
  mutating func movxx(_ r1: Int, _ r2: Int){
    if CheckRegister(r1) && CheckRegister(r2) && CheckMemory(Register[r1]) && CheckMemory(Register[r2]){
      Memory[Register[r2]] = Memory[Register[r1]]
    }
    
  }
  mutating func outs(_ label: Int){
    if CheckMemory(label){
      let length = Memory[label]
      var returnString = ""
      for i in 1 ... length {
        if CheckMemory(i + label){
          returnString += String(unicodeValueToCharacter(Memory[i + label]))
        }
        
      }
      print(returnString, terminator: "")
    }
      
    }
  
  mutating func nop(){
  }
  
  mutating func jmpne(_ label: Int){
    if rCP != 0 {
      if CheckMemory(label){
        rPC = label
      } 
    }
  }

}


