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

class PTX2PTXListener extends PTXBaseListener {

  Stack<StringBuilder> out = new Stack<StringBuilder>();
  PTXParser parser;
  PTX2PTXListener(PTXParser parser){
    out.push(new StringBuilder(""));
    this.parser = parser;
  }

  @Override
  public void enterProgram(PTXParser.ProgramContext ctx){
    System.out.println("Enter Program ~~\n");
  }

  @Override 
  public void exitModDirective(PTXParser.ModDirectiveContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void enterDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void exitDirective(PTXParser.DirectiveContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void enterDeclarationList(PTXParser.DeclarationListContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void enterDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\t");
  }

  @Override 
  public void exitDeclaration(PTXParser.DeclarationContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void enterInstructionList(PTXParser.InstructionListContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void enterInstruction(PTXParser.InstructionContext ctx){
    if(ctx.getChild(0) instanceof PTXParser.LabelNameContext==false){
      out.peek().append("\t");
    }
    else{
      out.peek().append("\n");
    }
  }

  @Override 
  public void exitInstruction(PTXParser.InstructionContext ctx){
    out.peek().append("\n");
  }

  @Override 
  public void enterOperandList(PTXParser.OperandListContext ctx){
    out.peek().append(" ");
  }

  @Override 
  public void visitTerminal(TerminalNode node){
    out.peek().append(node.getText());
    if(node.getText().equals(",")){
      out.peek().append(" ");
    }
  }
}

public class PTX2PTX {

   public static void printPTX(String inputPTX, String[] args) throws IOException {
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
    FileOutputStream output = new FileOutputStream(new File("output_"+args[0]));
    System.out.println("Output file name:  output_"+args[0]);
    output.write(listener.out.peek().toString().getBytes());
    output.flush();
    output.close();
  }

   public static void main(String[] args) throws IOException {
    String input="", tmp;
    if (args.length == 0) {
      System.err.println("Input Filename...");
      System.exit(1);
    }
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

    printPTX(input, args);

  }
}
/*
antlr4 PTX.g4
javac PTX*.java
java PTX2PTX test.ptx

grun PTX program -gui < test.ptx
grun Expr prog -gui
*/
