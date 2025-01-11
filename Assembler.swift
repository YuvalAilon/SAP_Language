class Assembler {
  var file: String;
  var splitFile: [String]
  var tokenizedFile: [TokenLine]
  var firstFourAddedTerms: [Int]
  var hadError : Bool
  var programLength: Int
  var programStart: Int
  let legalDirectives = [".START" , ".END" , ".INTEGER" , ".STRING" , ".ALLOCATE"]
  var symTable: [String: Int]
  var pc: Int

  var lst: String
  var bin: String

  
  init(_ file:String) {
    self.file = readFromFile(file).0
    splitFile = splitStringIntoLines(self.file)
    symTable = [String: Int]()
    pc = 0
    tokenizedFile = [TokenLine]()
    firstFourAddedTerms = [Int]()
    lst = ""
    bin = ""
    hadError = false
    programLength = 0
    programStart = -1
  }
  
  func reset() {
    tokenizedFile = [TokenLine]()
    firstFourAddedTerms = [Int]()
    lst = ""
    bin = ""
    pc = 0 
    programLength = 0
    programStart = -1
    hadError = false
    symTable = [String: Int]()
  }
  
  func assemble(_ fileName: String){ 
    reset()
    let rawFile = readFromFile(fileName)
    if rawFile.1 == false {
      fileNotFound()
      return
    }else{
      splitFile = splitStringIntoLines(rawFile.0)
    }
    
    for line in splitFile {
      if line.isNotBlank() {
        var tokenLine = chunker(line)
        tokenLine = makeCommentTokens(tokenLine)    
        tokenLine = validate(tokenLine)
        if tokenLine.line[0].type == .LabelDefinition {
          symTable[tokenLine.line[0].stringValue!.uppercased()] = pc - 1
        }        
        tokenLine.memoryLocation = pc
        movePC(tokenLine)
        tokenizedFile.append(tokenLine) 
      }

    }


    lst += ";;─────────────────────<<\(fileName.uppercased()) LST>>─────────────────────;;\n"
    
    for lineIndex in 0 ..< tokenizedFile.count{

      
      tokenizedFile[lineIndex] = validateLabels(tokenizedFile[lineIndex])
      
      if pc != -1 {
        addLineToBIN(tokenizedFile[lineIndex])
      }
      addLineToLST(tokenizedFile[lineIndex])
    }


    if pc != -1 {
      lst += "\n\n;;───<<SYMBOL TABLE>>───;;\n"
      for (label,memlocation) in symTable {
        lst += "| \(memlocation)"
        if memlocation < 100 {
          lst += " "
        }
        if memlocation < 10 {
          lst += " "
        }
        lst += " | \(label)\n"
      }
      lst += ";;──────────────────────;;"

    bin = String(programLength) + "\n" + String(programStart) + "\n"  + bin
      _ = writeTextFile("\(fileName).bin",data: bin)
    }    
    
    _ = writeTextFile("\(fileName).lst",data: lst)
    lst = ""
    bin = ""

    if hadError {
      print("Found error(s), check LST file for details\nNo BIN file created")
    } else {
      print("ASSEMBLY SUCCESSFUL 😎")
    }
  }

  func chunker(_ line: String) -> TokenLine{
    if line.contains("\"") {
      return TokenLine(pc, createTokenLnFromChunks(makeQuoteArray(line)))
    }
    return TokenLine(pc, createTokenLnFromChunks(splitStringIntoParts(line))) 
  }

  func makeQuoteArray(_ line: String) -> [String]{
    var quoteArray: [String] = []
    let lineArray = Array(line)
    var temp: String = ""
    var isString: Bool = false
    for i in 0..<lineArray.count {
      if lineArray[i] != "\"" {
      temp += String(lineArray[i])
      } else {
      isString = !isString
      quoteArray.append(temp)
      temp = "\""
      }
    }

    var returnArray = splitStringIntoParts(quoteArray.remove(at: 0))
    returnArray.append(contentsOf: quoteArray)
    
    return returnArray
  }
  
  func createTokenLnFromChunks(_ line: [String]) -> [Token]{
    var tokenArray = [Token]()
    for chunk in line {
      tokenArray.append(tokenize(chunk))
    }
    return(tokenArray)
  }

  
  func tokenize(_ chunk: String) -> Token{
    var chunkArray = [String]()
    for i in chunk {
      chunkArray.append(String(i))
    }
    switch chunkArray[0]{
      case ".": 
        return CreateDirectiveToken(chunkArray)
      case "\"" :
        return CreateImmediateStringToken(chunkArray)
      case "r": 
        if chunkArray.count == 2 && Int(chunkArray[1] ) != nil {
          return CreateRegisterToken(chunkArray)    
        }else{
         break;
        }
      case "#":
        return CreateImmediateInt(chunkArray)
      case ";":
        return CreateCommentToken(chunkArray)
      default : break;
    }
 
    if chunkArray[chunkArray.count - 1] == ":" {
      return CreateLabelDefinitionToken(chunkArray)
    }

    if let instructionToken = CreateInstructionToken(chunkArray){
      return instructionToken
    }
    
    return Token(.Label, nil,  stringFromArraySub(chunkArray,0, chunkArray.count - 1))

  }

  func CreateDirectiveToken(_ chunkArray: [String]) -> Token{
    if legalDirectives.contains(stringFromArraySub(chunkArray,0, chunkArray.count - 1).uppercased){
      return Token(.Directive, nil,  stringFromArraySub(chunkArray,1, chunkArray.count - 1))
    }
     return Token(.BadDirective, nil,  stringFromArraySub(chunkArray,1, chunkArray.count - 1))
  }

  func CreateImmediateStringToken(_ chunkArray: [String]) -> Token{
    return Token(.ImmediateString , nil , stringFromArraySub(chunkArray, 1, chunkArray.count - 1 ) )
  }

  func CreateCommentToken(_ chunkArray: [String]) -> Token{
    return Token(.Comment , nil , stringFromArraySub(chunkArray, 1, chunkArray.count - 1 ) )
  }

  func CreateRegisterToken(_ chunkArray: [String]) -> Token {
    return Token(.Register, Int(chunkArray[1]), nil)
  }

  func CreateImmediateInt(_ chunkArray: [String]) -> Token {
    for characterIndex in 1 ..< chunkArray.count {
      if Int(chunkArray[characterIndex]) == nil{
        return Token(.BadIntToken, nil, stringFromArraySub(chunkArray, 1, chunkArray.count - 1))
      }
    }
    return Token(.ImmediateInt, Int(stringFromArraySub(chunkArray, 1, chunkArray.count - 1)), nil)
  }

  func CreateLabelDefinitionToken(_ chunkArray: [String]) -> Token{
    symTable[stringFromArraySub(chunkArray, 0, chunkArray.count - 2).uppercased()] = -1
    return Token(.LabelDefinition, nil, stringFromArraySub(chunkArray, 0, chunkArray.count - 2))
  }

  func CreateInstructionToken(_ chunkArray: [String]) -> Token? {
    if InstructionCodeString.allCases.contains(where: { $0.rawValue == stringFromArraySub(chunkArray,0,chunkArray.count - 1).uppercased() }){
      return Token(.Instruction,instructionDictionary[stringFromArraySub(chunkArray,0,chunkArray.count - 1).uppercased], stringFromArraySub(chunkArray,0,chunkArray.count - 1))
      
    }
    return nil
  }

  func validateLabels(_ tokenLine: TokenLine) -> TokenLine {
    var returnTokenLine = tokenLine
    for tokenIndex in 0 ..< removeComments(tokenLine).line.count {
      if tokenLine.line[tokenIndex].type == .Label && symTable[tokenLine.line[tokenIndex].stringValue!.uppercased()] == nil{
        returnTokenLine.line[tokenIndex] = Token(.BadLabelToken, tokenLine.line[tokenIndex].intValue, tokenLine.line[tokenIndex].stringValue)
        //returnTokenLine.line[tokenIndex] = Token(tokenLine.line[tokenIndex].type, -1, tokenLine.line[tokenIndex].stringValue)
      }
    }
    return(returnTokenLine)
  }

  func makeCommentTokens(_ tokenLine: TokenLine) -> TokenLine{
    var returnTokenLine = TokenLine(0 , [Token]())
    var reachedComment = false
    for token in tokenLine.line{
      if !reachedComment{
        returnTokenLine.line.append(token)
        if token.type == .Comment{
          reachedComment = true
        }
      }else{
        returnTokenLine.line.append(Token(.CommentMiddle, nil, token.stringValue))
      }
    }
    return returnTokenLine
  }

  func movePC(_ tokenLine: TokenLine){
    for token in tokenLine.line {
      if pc != -1 {
        switch token.type {
          case .Comment: break
          case .CommentMiddle: break
          case .LabelDefinition: break 
          case .Label: pc += 1
          case .Instruction: pc += 1
          case .ImmediateInt: pc += 1   
          case .ImmediateString: pc += (token.stringValue!.count + 1)
          case .Register: pc += 1    
          case .Directive: break      
          case .BadDirective: pc = -1 
          case .BadLabelToken: pc = -1 
          case .BadIntToken: pc = -1
          case .BadInstructionToken: pc = -1
          case .BadStringToken: pc = -1
          case .BadRegisterToken: pc = -1
          case .BadLabelDefinition: pc = -1
        }
      }
    }
  
  }

  func validate(_ tokenLine: TokenLine) -> TokenLine{
    var validatedTokenLine = TokenLine(tokenLine.memoryLocation, tokenLine.line)
    switch tokenLine.line[0].type{
          case .Comment: return tokenLine
          case .CommentMiddle: return tokenLine
          case .LabelDefinition: return validateLabelLine(tokenLine)
          case .Label: validatedTokenLine.line[0] = Token(.BadLabelToken, nil, tokenLine.line[0].stringValue)
                       return validatedTokenLine
          case .Instruction: return validateInstructionLine(tokenLine)
          case .ImmediateInt: validatedTokenLine.line[0] = Token(.BadIntToken, tokenLine.line[0].intValue, nil )  
                              return validatedTokenLine
          case .ImmediateString: validatedTokenLine.line[0] = Token(.BadStringToken, nil , tokenLine.line[0].stringValue )
                                 return validatedTokenLine
          case .Register: validatedTokenLine.line[0] = Token(.BadRegisterToken, tokenLine.line[0].intValue, nil ) 
                          return validatedTokenLine
          case .Directive:  
            switch tokenLine.line[0].stringValue!.uppercased() {
              case "START": 
                if removeComments(tokenLine).line.count == 2 && tokenLine.line[1].type == .Label {
                  return tokenLine
                }else{
                   validatedTokenLine.line[0] = Token(.BadDirective, nil , tokenLine.line[0].stringValue ) 
                   return validatedTokenLine
                }
              case "END" :
                if removeComments(tokenLine).line.count == 1 {
                  return tokenLine
                }else{
                  validatedTokenLine.line[0] = Token(.BadDirective, nil , tokenLine.line[0].stringValue ) 
                  return validatedTokenLine
                }
              default : validatedTokenLine.line[0] = Token(.BadDirective, nil , tokenLine.line[0].stringValue)
                        return validatedTokenLine
            }
          default: return tokenLine
    }
  }


  func validateLabelLine(_ tokenLine: TokenLine) -> TokenLine{
    var validatedTokenLine = tokenLine
    if removeComments(tokenLine).line.count >= 2 && tokenLine.line[1].type == .Directive{
      switch tokenLine.line[1].stringValue!.uppercased(){
        case "STRING": 
          if removeComments(tokenLine).line.count == 3 && tokenLine.line[2].type == .ImmediateString{
            return tokenLine
          }else{
            validatedTokenLine.line[0].type = .BadLabelDefinition
            return validatedTokenLine
          }
        case "INTEGER" , "ALLOCATE" :
          if removeComments(tokenLine).line.count == 3 && tokenLine.line[2].type == .ImmediateInt{
            return tokenLine
          }else{
            validatedTokenLine.line[0].type = .BadLabelDefinition
            return validatedTokenLine
          }
        default: validatedTokenLine.line[0].type = .BadLabelDefinition
                 return validatedTokenLine
      
      }
    } 

    if removeComments(tokenLine).line.count >= 2 && (tokenLine.line[1].type == .LabelDefinition || tokenLine.line[1].type == .ImmediateInt || tokenLine.line[1].type == .ImmediateString) {
      validatedTokenLine.line[0].type = .BadLabelDefinition
      return validatedTokenLine
    }

    if removeComments(validatedTokenLine).line.count == 1 {
        validatedTokenLine.line[0].type = .BadLabelDefinition
        return validatedTokenLine
    }

    var LineMinusLabel = tokenLine
    let OnlyLabel = LineMinusLabel.line.remove(at: 0)
    if LineMinusLabel.line[0].type == .Instruction {
        LineMinusLabel = validate(LineMinusLabel)
    }

    LineMinusLabel.line.insert(OnlyLabel, at: 0)
    return LineMinusLabel

  }

  func addLineToLST(_ tokenLine: TokenLine){
    var errorMessage: String? = nil
    lst += tokenLine.generateMemoryString()
    if pc != -1 {
      for term in firstFourAddedTerms {
        if term < 10 {
          lst += " "
        }
        if term < 100 {
          lst += " "
        }
        lst += String(term)
        lst += " "
      }
      if firstFourAddedTerms.count < 4 {
        for _ in 1 ... 4 - firstFourAddedTerms.count {
          lst += "    "
        }
      }

      lst += "| "
    }
    for token in tokenLine.line{
      lst += token.generateString()
      lst += " "
      if token.isBad(){
        errorMessage = token.writeErrorMessage()
        hadError = true
      }
    }
    if let error = errorMessage {
      lst += "\n"
      lst += error
    }
    lst += "\n"
  }

  func addLineToBIN(_ tokenLine: TokenLine) {
    var binArray = [Int]()
    firstFourAddedTerms = [Int]()
    if tokenLine.line[0].stringValue?.uppercased() == "START" && removeComments(tokenLine).line.count == 2 {
      programStart = symTable[tokenLine.line[1].stringValue!.uppercased()] ?? -1
    } else {
      for token in tokenLine.line {
      switch token.type {
          case .Label: binArray.append(symTable[token.stringValue!.uppercased()]!)
          case .Instruction: binArray.append(token.intValue!) 
          case .ImmediateInt: binArray.append(token.intValue!)  
          case .ImmediateString: binArray.append(contentsOf: stringToBinary(token.stringValue!))
          case .Register: binArray.append(token.intValue!)  
          default: break
        } 
      }
    
    }

    var amountofMem = 3
    if binArray.count - 1 < 3 {
      amountofMem = binArray.count - 1
    }
    if binArray.count > 0 {
      for i in 0 ... amountofMem {
        firstFourAddedTerms.append(binArray[i])
      }
    }

    for number in binArray {
      bin += String(number)
      bin += "\n"
    }

    programLength += binArray.count
    
  }

  

  func validateInstructionLine(_ tokenLine: TokenLine) -> TokenLine{
      var validatedTokenLine = tokenLine
      if removeComments(tokenLine).line.count == 1 && tokenLine.line[0].stringValue != nil {
        if tokenLine.line[0].stringValue!.uppercased() == "HALT" || tokenLine.line[0].stringValue!.uppercased() == "RET" || tokenLine.line[0].stringValue!.uppercased() == "BRK" || tokenLine.line[0].stringValue!.uppercased() == "NOP" {
          return tokenLine
        }else{
          validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue )
        return validatedTokenLine
        }
      }

      if tokenLine.line[0].stringValue!.uppercased().hasPrefix("MOV") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("ADD") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("SUB") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("MUL") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("DIV") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("CMP")  {
        return validateTwoLetterSuffixes(tokenLine)
      }

      if tokenLine.line[0].stringValue!.uppercased().hasPrefix("CLR") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("OUTC") {
        return validateOneLetterSuffixes(tokenLine)
      }

      if tokenLine.line[0].stringValue!.uppercased.hasPrefix("JMP") || tokenLine.line[0].stringValue!.uppercased.hasPrefix("JSR") || tokenLine.line[0].stringValue!.uppercased == "OUTS" {
        if removeComments(tokenLine).line.count == 2 && tokenLine.line[1].type == .Label {
          return validatedTokenLine
        }else {
          validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue )
          return validatedTokenLine
        }
      }

      if tokenLine.line[0].stringValue!.uppercased() == "PUSH" || tokenLine.line[0].stringValue!.uppercased() == "POP" || tokenLine.line[0].stringValue!.uppercased() == "STACKC" || tokenLine.line[0].stringValue!.uppercased() == "PRINTI" {
        if removeComments(tokenLine).line.count == 2 && tokenLine.line[1].type == .Register {
          return validatedTokenLine
        }else{
          validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue )
          return validatedTokenLine
        }
      }


      if tokenLine.line[0].stringValue!.uppercased().hasPrefix("SO") || tokenLine.line[0].stringValue!.uppercased().hasPrefix("AO") {
        if removeComments(tokenLine).line.count == 3 && tokenLine.line[1].type == .Register && tokenLine.line[2].type == .Label {
          return validatedTokenLine
        }else {
          validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue )
          return validatedTokenLine
        }

        
      }

      if removeComments(tokenLine).line.count == 1 {
          return validatedTokenLine
      }else{
          validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue )
          return validatedTokenLine
      }
  }

  func validateTwoLetterSuffixes(_ tokenLine: TokenLine) -> TokenLine {
    var validatedTokenLine = tokenLine
    if tokenLine.line[0].stringValue! == "MOVB" {
      if removeComments(tokenLine).line.count == 4 && validatedTokenLine.line[1].type == .Register && validatedTokenLine.line[2].type == .Register && validatedTokenLine.line[3].type == .Register {
        return tokenLine
      }else{
        validatedTokenLine.line[0] = Token(.BadLabelToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue)
        return validatedTokenLine
      }
    }
    
    var argumentOneType : TokenType = .Comment
    var argumentTwoType : TokenType = .Comment
  
    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("IR") {
      argumentOneType = .ImmediateInt
      argumentTwoType = .Register
    }
  
    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("RR") {
      argumentOneType = .Register
      argumentTwoType = .Register
    }
  
    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("MR") {
      argumentOneType = .Label
      argumentTwoType = .Register
    }

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("RM") {
      argumentOneType = .Register
      argumentTwoType = .Label
    }
  
    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("XR") {
      argumentOneType = .Register
      argumentTwoType = .Register
    }

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("AR") {
      argumentOneType = .Label
      argumentTwoType = .Register
    }

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("RX") {
      argumentOneType = .Register
      argumentTwoType = .Register
    }

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("XX") {
      argumentOneType = .Register
      argumentTwoType = .Register
    }

    
  
      if removeComments(validatedTokenLine).line.count == 3 && validatedTokenLine.line[1].type == argumentOneType && validatedTokenLine.line[2].type == argumentTwoType {
        return validatedTokenLine
      }
    
      validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue,           validatedTokenLine.line[0].stringValue )
    return validatedTokenLine
  }


  func validateOneLetterSuffixes(_ tokenLine: TokenLine) -> TokenLine {
    var validatedTokenLine = tokenLine

    if tokenLine.line[0].stringValue!.uppercased().hasSuffix("B") {
      if removeComments(tokenLine).line.count == 3 && validatedTokenLine.line[1].type == .Register && validatedTokenLine.line[2].type == .Register {
        return tokenLine
      }else{
        validatedTokenLine.line[0] = Token(.BadLabelToken, validatedTokenLine.line[0].intValue, validatedTokenLine.line[0].stringValue)
        return validatedTokenLine
      }
    }
 
    var argumentOneType : TokenType = .Comment

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("R") || validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("X")  {
      argumentOneType = .Register
    }

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("M"){
      argumentOneType = .Label
    }

    if validatedTokenLine.line[0].stringValue!.uppercased().hasSuffix("I"){
      argumentOneType = .ImmediateInt
    }

    if removeComments(validatedTokenLine).line.count == 2 && validatedTokenLine.line[1].type == argumentOneType{
        return validatedTokenLine
      }
      validatedTokenLine.line[0] = Token(.BadInstructionToken, validatedTokenLine.line[0].intValue,           validatedTokenLine.line[0].stringValue )
    return validatedTokenLine

    
  }

  func stringToBinary(_ string: String) -> [Int] {
    var returnArray = [string.count]
    for character in string{
      returnArray.append(characterToUnicodeValue(character))
    }
    return returnArray
  }



  
}

func stringFromArraySub(_ array: [String],_ start: Int, _ end: Int) -> String{
  var returnString = ""

  if start <= end {
    for i in start ... end{
      returnString += array[i]
    }
  }

  return returnString
}



enum TokenType {
  case Comment
  case CommentMiddle
  case LabelDefinition
  case Label
  case Instruction 
  case ImmediateInt    
  case ImmediateString 
  case Register        
  case Directive       
  case BadDirective
  case BadLabelToken       
  case BadIntToken
  case BadInstructionToken
  case BadStringToken
  case BadRegisterToken
  case BadLabelDefinition
}

struct TokenLine : CustomStringConvertible{
   var line : [Token]
   var memoryLocation : Int
   init(_  memoryLocation: Int, _ line: [Token]){
     self.line = line 
     self.memoryLocation = memoryLocation
   }
  
  var description : String {
    var returnString = generateMemoryString()
    for token in line {
      returnString += token.description
      returnString += " "
    }
    return returnString
  }

  func generateMemoryString() -> String {
    var returnString = String(memoryLocation)
    if returnString == "-1" {
      returnString = "___"
    }else {
      if memoryLocation < 10 {
        returnString += " "
      }
      if memoryLocation < 100 {
        returnString += " "
      }
    }
    returnString += ": "
    return returnString
  }




}

struct Token : CustomStringConvertible{
  var type: TokenType
  var intValue: Int?
  var stringValue: String?
  var description: String {

    var returnString = ("<Type: \(type)")
    if let intValue = intValue {
      returnString +=  " | IntVal: \(intValue)"
    }
    if let stringValue = stringValue {
      returnString +=  " | StringVal: \(stringValue)"
    }
    returnString += ">"
    return returnString
  }
  init(_ type: TokenType, _ intValue: Int?, _ stringValue: String?){
    self.type = type
    self.intValue = intValue
    self.stringValue = stringValue
  }

  func isBad() -> Bool{
    if type == .BadDirective || type == .BadLabelToken || type == .BadIntToken || type == .BadInstructionToken || type == .BadStringToken || type == .BadRegisterToken  || type == .BadLabelDefinition {
      return true
    }
    return false
  }

  func writeErrorMessage() -> String {
    let topCharacter = "↑"
    let bottomCharacter = "─"
    var rawErrorMessage = ""
    var fullErrorMessage = ""
    switch type {
      case .BadDirective: rawErrorMessage = "The DIRECTIVE you entered is invalid, or has incorrect arguments"
      case .BadLabelToken: rawErrorMessage = "The LABEL or INSTRUCTION \(stringValue ?? "") is not defined"
      case .BadIntToken: rawErrorMessage = "This INTEGER definition is not in the correct location"
      case .BadInstructionToken: rawErrorMessage = "The INSTRUCTION \(stringValue ?? "") has incorrect arguments"
      case .BadStringToken: rawErrorMessage = "This STRING definition is not in the correct location"
      case .BadRegisterToken: rawErrorMessage = "This REGISTER is not in the correct location"
      case .BadLabelDefinition: rawErrorMessage = "This LABEL DEFINITION is not in the correct location, or has incorrect arguments"
      default: rawErrorMessage = "idk how you even did this -_-"
    }
    let messageLength = rawErrorMessage.count
    for _ in 1 ... messageLength/2 + 1 {
      fullErrorMessage += topCharacter
      fullErrorMessage += " "
    }
    fullErrorMessage += "\n"
    fullErrorMessage += rawErrorMessage
    fullErrorMessage += "\n"
    for _ in 1 ... messageLength{
      fullErrorMessage += bottomCharacter
    }
    if messageLength%2 == 0 {
      fullErrorMessage += bottomCharacter
    }
    return fullErrorMessage
  }

  func generateString() -> String {
    switch type {
      case .CommentMiddle , .Label , .Instruction , .BadLabelToken, .BadInstructionToken : return (stringValue ?? "")
      case .Comment: return (";" + (stringValue ?? ""))
      case .ImmediateInt , .BadIntToken : return ("#" + String(intValue ?? 0))
      case .LabelDefinition , .BadLabelDefinition: return ((stringValue ?? "") + ":")
      case .ImmediateString , .BadStringToken: return ("\"" + (stringValue ?? "") + "\"")
      case .Directive, .BadDirective: return ("." + (stringValue ?? ""))
      case .Register, .BadRegisterToken: return("r" + String(intValue ?? 0))
    }
  }
}

func removeComments(_ tokenLine: TokenLine) -> TokenLine {
    var returnTokenLine = TokenLine(tokenLine.memoryLocation, [Token]())
    for tokenIndex in 0 ..< tokenLine.line.count {
      if tokenLine.line[tokenIndex].type != .Comment && tokenLine.line[tokenIndex].type != .CommentMiddle {
        returnTokenLine.line.append(tokenLine.line[tokenIndex])
      }
    }
    return returnTokenLine
  }

//struct Tuple {}
/*  This is snippet of code that may be useful in the future.
if currentToken.type == TokenType.directive {
assembleDirective(currentToken)
continue
}*/ 