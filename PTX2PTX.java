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

  @Override
  public void enterProgram(PTXParser.ProgramContext ctx){
    System.out.println("Hi\n");
  }
}

public class PTX2PTX {
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
        }
        rd.close();
      } catch (IOException e) {
          System.err.println(e); //it there is any ERROR, print
          System.exit(1);
      }

      // Get lexer
      PTXLexer lexer = new PTXLexer(CharStreams.fromString(input)); //**prob
      // Get a list of matched tokens
      CommonTokenStream tokens = new CommonTokenStream(lexer);
      // Pass tokens to parser
      PTXParser parser = new PTXParser(tokens);
      // Walk parse-tree and attach our listener
      ParseTreeWalker walker = new ParseTreeWalker();
      PTX2PTXListener listener = new PTX2PTXListener();
      walker.walk(listener, parser.program());// walk from the root of parse tree


  
    // Output file

   }
} 
