import Foundation
//extension SAPVMInterface {

  
  
  //-----------error codes-----------//

  
    func ErrInvalidStartingState(){
      print("""
            \u{001B}[0;31mInvalid Starting State. This file most likley has the wrong format.\u{001B}[0;37m
      """)
    }

    func ErrInvalidStartPos(){
      print("""
            
            \u{001B}[0;31mThe starting position of this file is out of bounds\u{001B}[0;37m
            
            """)
    }
  
    func ErrInvalidLength(){
      print("""
            \u{001B}[0;31mThe file length is not correct, thats all we know\u{001B}[0;37m        
      """)
  
    }

 func unicodeValueToCharacter(_ n: Int)->Character{
      return Character(UnicodeScalar(n)!)
  }
  
  func readFromFile(_ filename: String) -> (String, Bool) {
    var textFromFile: String = ""
    do {
  	  textFromFile = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)
      return (textFromFile, true)
    }
    catch {
      return ("", false)
    }
  }
  func splitStringIntoLines(_ expression: String)->[String]{
      return expression.split{$0 == "\n"}.map{ String($0) }
  }
  
  func splitStringIntoParts(_ expression: String)->[String]{
      return expression.split{$0 == " "}.map{ String($0) }
  }
  
  func stringToIntArray(_ string: String) -> [Int]?{
    var intArray = [Int]()
    let splitString = splitStringIntoLines(string)
    for i in splitString {
      if Int(i) == nil {
        ErrInvalidStartingState()
        return nil
      }
    }
    for str in splitString{
      intArray.append(Int(str) ?? -1)
    }
    return intArray
  }
  
  func fileCheck(_ code: [Int]) -> Bool
{
    if code[0] != code.count-2 {
      ErrInvalidLength()
      return false
    }
    if code[1] < 0 || code[1] > code[0] {
      ErrInvalidStartPos()
      return false
    }
    return true
  }

  struct Stack<Element> : CustomStringConvertible, Sequence, IteratorProtocol{
    var size: Int
    var count: Int = 0
    var stack: [Element?] = []
    init(size: Int) {
        self.size = size
        stack = Array(repeating: nil, count: size)
    }
    func isEmpty()->Bool {return count == 0}
    func isFull()->Bool {return count == size}
    mutating func push(_ element: Element?) {
        if !isFull(){ //success
            stack[count] = element
            count += 1
        }else{ //fail to add element
            ErrInvalidPush()
        }
    }
    mutating func pop()->Element? {
        if !isEmpty(){ //success
            let n = stack[count-1]
            stack.remove(at: count-1)
            count -= 1
            stack.append(nil)
            return n
        }
      ErrInvalidPop()
      return nil
    }
    var description: String{
        var st:String = "B "
        for i in 0..<count {
            if let _ = stack[i] {st += "\(stack[i]!) "}
        }
        st += "T"
        return st
    }
    mutating func next() -> Element? {
        if count == 0 {
            return nil
        } else {
            defer { count -= 1 }
            defer { push(stack[count]) }
            return pop()
        }
    }
    
  }

  func ErrInvalidPush(){
       print("\u{001B}[0;31mInvalid Push\n\u{001B}[0;37m")
       exit(0)
    }
  
    func ErrInvalidPop(){
      print("\u{001B}[0;31mInvalid Pop\n\u{001B}[0;37m")
      exit(0)
    }

func characterToUnicodeValue(_ c: Character)->Int{
      let s = String(c)
      return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
}


func writeTextFile(_ path: String, data: String)->String? {
  do {
  // Write contents to file
    try data.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
  }
  catch let error as NSError {
    return "\(error)"
  }
  return nil
}

extension String {
  func isNotBlank() -> Bool {
    for char in self {
      if char != " "{
        return true
      }
    }
    return false
  }
}

func fileNotFound(){
  print("\u{001B}[0;31m404: File not found :(\u{001B}[0;37m")
}