import Foundation
struct SAPVMInterface {
  var VM = SAPVM()
  var command = ""
  var path = "NO FILE SELECTED"
  var assembler = Assembler("progams/modLoop")
  init() {
    assembler.reset()
    runInterface()
  }
  mutating func runInterface(){
    printWelcome()
    while true {
      print("\n>>> ", terminator: "")
      let input = splitStringIntoParts(readLine() ?? "Bad Command")
      print("")
      switch input[0].uppercased() {
        case "RUN":
          if checkArraySize(input, 1){
          let s = "\(input[1]).bin"
            let rawFile = readFromFile(s)
            if rawFile.1 {
              VM.code = stringToIntArray(rawFile.0) ?? [0]
              VM.runCode()
              print("")
            }else{
              fileNotFound()
            }
          }
        case "ASM": 
          if checkArraySize(input, 1){
            assembler.assemble(input[1])
          }else{
            sizeError()
          }
        case "LST":
          if checkArraySize(input, 1){
            let file = readFromFile("\(input[1]).lst")
            if file.1 {
              print(file.0)
            }else{
              fileNotFound()
            }
          }else{
            sizeError()
          }
     
        case "BIN":
          if checkArraySize(input, 1){
            let file = readFromFile("\(input[1]).bin")
            if file.1 {
              print(file.0)
            }else{
              fileNotFound()
            }
          }else{
            sizeError()
          }
        case "HELP":
          printHelp()
        case "QUIT":
          print("Thank you for using SAPVM!\n\nProgram Quit")
          exit(0)
        default:
          print("\u{001B}[0;31mThe command you entered is incorrect \u{001B}[0;37m")
      }
    }
  }

  func checkArraySize(_ array: [String],_ index: Int) -> Bool{
    return array.count > index
  }

  func sizeError(){
    print("\u{001B}[0;31mThose are not the correct arguments for this function \nType \"HELP\" to learn more \u{001B}[0;37m")
  }

  func printHelp(){
    print("""
          ;;──────────────────<<HELP>>─────────────────────;;
          || 1) asm file  | Assembles file                 ||
          || 2) run file  | Runs file                      ||
          || 3) lst file  | Prints file's listing file     ||
          || 4) bin file  | Prints file's binary file      ||
          ||                                               ||
          || NOTE: LST, BIN, and RUN only function if file ||
          || has already been assembled                    ||
          ||                                               ||
          || 5) help      | Prints this message            ||
          || 6) quit      | quits the program              ||
          ;;───────────────────────────────────────────────;;
          """)
  }

  func printWelcome(){
    print("""
                 _____ _____ _____ _____ _____         
                |   __|  _  |  _  |  |  |     |   ___ ___ 
                |__   |     |   __|  |  | | | |  | . |_ -|
                |_____|__|__|__|   \\___/|_|_|_|  |___|___|
          ;;───────────────────────────────────────────────;;
          || Welcome to your SAP virtual machine.          ||
          || The machine can both assemble and run SAP code||
          ||                                               ||
          || For a more thorough explination of the machine||
          || consult your user start guide                 ||
          ||                                               ||
          || For a list of this machine's commands and     ||
          || their function, type \"HELP\"                   ||
          ;;───────────────────────────────────────────────;;
          
          
          """)
  }
  
}