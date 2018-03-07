// import ANTLR runtime libraries
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

// import Java Map Libs
import java.util.HashMap;
import java.util.Map;

// import Java Stack Libs
import java.util.*;

// import Java console IO
import java.io.Console;
import java.io.IOException;

import java.io.*;

import java.lang.*;

class PTXADDINSTRUCTIONListener extends PTXBaseListener {

  Stack<StringBuilder> out = new Stack<StringBuilder>();
  PTXParser parser;
  PTXADDINSTRUCTIONListener(PTXParser parser){
    out.push(new StringBuilder(""));
    this.parser = parser;
  }
  String labelName;
  String instructionList;
  boolean labelExist=false, labelIn=false;;
  PTXADDINSTRUCTIONListener(PTXParser parser, String labelName, String instructionList){
    out.push(new StringBuilder(""));
    this.parser = parser;
    this.labelName = labelName;
    this.instructionList = instructionList;
  }

  @Override  public void exitModDirective(PTXParser.ModDirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void exitDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDeclarationList(PTXParser.DeclarationListContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\t");
  }
  @Override public void exitDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterInstructionList(PTXParser.InstructionListContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterInstruction(PTXParser.InstructionContext ctx){
    if(ctx.getChild(0) instanceof PTXParser.LabelNameContext==false){
      out.peek().append("\t");
    } else{
      out.peek().append("\n");
    }
  }
  @Override public void exitInstruction(PTXParser.InstructionContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterOperandList(PTXParser.OperandListContext ctx){
    out.peek().append(" ");
  }
  @Override public void visitTerminal(TerminalNode node){
    out.peek().append(node.getText());
    out.peek().append(" ");
  }
}

class PTXADDLABELListener extends PTXBaseListener {

  Stack<StringBuilder> out = new Stack<StringBuilder>();
  PTXParser parser;
  String funcName;
  String labelName;
  boolean funcExist=false, funcIn=false;;
  PTXADDLABELListener(PTXParser parser, String funcName, String labelName){
    out.push(new StringBuilder(""));
    this.parser = parser;
    this.funcName = funcName;
    this.labelName = labelName;
  }

  @Override public void enterKernelDirective(PTXParser.KernelDirectiveContext ctx){
    if(ctx.getChild(1).getText().equals(funcName)){
      funcExist=true;
      funcIn=true;
    }
  }
  @Override public void enterFunctionDirective(PTXParser.FunctionDirectiveContext ctx){
    int idx=0;
    for(int i=0; i<ctx.getChildCount(); i++){
      if(ctx.getChild(i) instanceof PTXParser.IdentifierContext==true){
        idx=i; break;
      }
    }
    if(ctx.getChild(idx).equals(funcName)){
      funcExist=true;
      funcIn=true;
    }
  }

  @Override public void exitModDirective(PTXParser.ModDirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void exitDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDeclarationList(PTXParser.DeclarationListContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\t");
  }
  @Override public void exitDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterInstructionList(PTXParser.InstructionListContext ctx){
    out.peek().append("\n");
  }
  @Override public void exitInstructionList(PTXParser.InstructionListContext ctx){
    if(funcIn){
      out.peek().append("\n"+labelName+" :\n");
      funcIn=false;
    }
  }
  @Override public void enterInstruction(PTXParser.InstructionContext ctx){
    if(ctx.getChild(0) instanceof PTXParser.LabelNameContext==false){
      out.peek().append("\t");
    } else{
      out.peek().append("\n");
    }
  }
  @Override public void exitInstruction(PTXParser.InstructionContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterOperandList(PTXParser.OperandListContext ctx){
    out.peek().append(" ");
  }
  @Override public void visitTerminal(TerminalNode node){
    out.peek().append(node.getText());
    out.peek().append(" ");
  }

}

class PTX2PTXListener extends PTXBaseListener {

  Stack<StringBuilder> out = new Stack<StringBuilder>();
  PTXParser parser;
  PTX2PTXListener(PTXParser parser){
    out.push(new StringBuilder(""));
    this.parser = parser;
  }

  @Override  public void exitModDirective(PTXParser.ModDirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void exitDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDeclarationList(PTXParser.DeclarationListContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\t");
  }
  @Override public void exitDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterInstructionList(PTXParser.InstructionListContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterInstruction(PTXParser.InstructionContext ctx){
    if(ctx.getChild(0) instanceof PTXParser.LabelNameContext==false){
      out.peek().append("\t");
    } else{
      out.peek().append("\n");
    }
  }
  @Override public void exitInstruction(PTXParser.InstructionContext ctx){
    out.peek().append("\n");
  }
  @Override public void enterOperandList(PTXParser.OperandListContext ctx){
    out.peek().append(" ");
  }
  @Override public void visitTerminal(TerminalNode node){
    out.peek().append(node.getText());
    out.peek().append(" ");
    /*if(node.getText().equals(",")){
      out.peek().append(" ");
    }
    else if(node.getParent() instanceof PTXParser.ModDirectiveContext==true){
      out.peek().append(" ");
    }*/
  }
}

public class PTX2PTX {

  public static String printPTX(String inputPTX, String outputName) throws IOException {
    // Get lexer
    PTXLexer lexer = new PTXLexer(CharStreams.fromString(inputPTX)); //**problem
    //PTXLexer lexer = new PTXLexer(CharStreams.fromFileName(input)); //**problem
    // Get a list of matched tokens
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    // Pass tokens to parser
    PTXParser parser = new PTXParser(tokens);
    // Walk parse-tree and attach our listener
    ParseTreeWalker walker = new ParseTreeWalker();
    PTX2PTXListener listener = new PTX2PTXListener(parser);
    walker.walk(listener, parser.program());// walk from the root of parse tree

    // Output file
    FileOutputStream output = new FileOutputStream(new File("output_"+outputName));
    System.out.println("PTX 2 PTX output file name:  output_"+outputName);
    output.write(listener.out.peek().toString().getBytes());
    output.flush();
    output.close();

    return listener.out.peek().toString();
  }

  public static String addLabelName(String inputPTX, String funcName, String labelName, String outputName) throws IOException {

    PTXLexer lexer = new PTXLexer(CharStreams.fromString(inputPTX));
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    PTXParser parser = new PTXParser(tokens);
    ParseTreeWalker walker = new ParseTreeWalker();
    PTXADDLABELListener listener = new PTXADDLABELListener(parser, funcName, labelName);
    walker.walk(listener, parser.program());

    if(!listener.funcExist){
      System.err.println("No Such a Function...");
      System.exit(1);
    }

    // Output file
    FileOutputStream output = new FileOutputStream(new File("output_"+outputName));
    System.out.println("Add basicblock ["+labelName+"] into function ["+funcName+"] output file name:  output_"+outputName);
    output.write(listener.out.peek().toString().getBytes());
    output.flush();
    output.close();

    return listener.out.peek().toString();
  }

  public static void addInstructionList(String inputPTX, String labelName, String instructionList, String outputName){

    PTXLexer lexer = new PTXLexer(CharStreams.fromString(inputPTX));
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    PTXParser parser = new PTXParser(tokens);
    ParseTreeWalker walker = new ParseTreeWalker();
    PTXADDINSTRUCTIONListener listener = new PTXADDINSTRUCTIONListener(parser, labelName, instructionList);
    walker.walk(listener, parser.program());

    if(!listener.labelExist){
      System.err.println("No Such a Basicblock...");
      System.exit(1);
    }

    // Output file
    FileOutputStream output = new FileOutputStream(new File("output_"+outputName));
    System.out.println("Add basicblock ["+labelName+"] into function ["+funcName+"] output file name:  output_"+outputName);
    output.write(listener.out.peek().toString().getBytes());
    output.flush();
    output.close();

    return listener.out.peek().toString();
  }

   public static void main(String[] args) throws IOException {
    String input="", tmp;
    try {
      BufferedReader rd = new BufferedReader(new FileReader(args[0]));
      while ((tmp = rd.readLine()) != null) {
        input += tmp;
        input += "\n";  //??
      }
      rd.close();
    } catch (IOException e) {
        System.err.println(e); //it there is any ERROR, print
        System.exit(1);
    }
    if (args.length == 0) {
      System.err.println("Input Filename...");
      System.exit(1);
    }

    input = addLabelName(input, "_ZN8dwt_cuda12rdwt53KernelILi64ELi8EEEvPKiPiiii", "LABEL", "NEWLABEL");

    input = printPTX(input, args[0]);


    /*// Get lexer
    PTXLexer lexer = new PTXLexer(CharStreams.fromString(input)); //**problem
    //PTXLexer lexer = new PTXLexer(CharStreams.fromFileName(input)); //**problem
    // Get a list of matched tokens
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    // Pass tokens to parser
    PTXParser parser = new PTXParser(tokens);
    // Walk parse-tree and attach our listener
    ParseTreeWalker walker = new ParseTreeWalker();
    PTX2PTXListener listener = new PTX2PTXListener(parser);
    walker.walk(listener, parser.program());// walk from the root of parse tree

    FileOutputStream output = new FileOutputStream(new File("2222"));
    System.out.println("Output file name:  2222");
    output.write(listener.out.peek().toString().getBytes());
    output.flush();
    output.close();*/

  }
}
/*
antlr4 PTX.g4
javac PTX*.java
java PTX2PTX test.ptx

grun PTX program -gui < test.ptx
grun Expr prog -gui
*/
