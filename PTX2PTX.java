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

public class PTX2PTX {
	protected static ParserRuleContext tree;

	public static void main(String[] args) throws IOException {
		if (args.length == 0) {
	    	System.err.println("Input Filename...");
	    	System.exit(1);
	    }
	    parseInitPTX(args[0]);
	    insert("BB0_55:\nadd.s32 	%r860, %r1, 193;\nsetp.lt.s32	%p61, %r860, %r328;", "cudaMalloc2");
	    printPTX(tree, args[0]);
	}

	public static void parseInitPTX(String fileName) {
		String input = "", tmp;
		
		try {
	      BufferedReader rd = new BufferedReader(new FileReader(fileName));
	      while ((tmp = rd.readLine()) != null) {
	        input += tmp;
	        input += "\n";
	      }
	      rd.close();
	    } catch (IOException e) {
	        System.err.println(e);
	        System.exit(1);
	    }

		PTXLexer lexer = new PTXLexer(CharStreams.fromString(input));
	    CommonTokenStream tokens = new CommonTokenStream(lexer);
	    PTXParser parser = new PTXParser(tokens);
	    //this.tree = parser.program();
	    tree = parser.program();
	}

	public static void insert(String inputPTX, String funcName) { //, int offset
		// PTXsmallLexer lexer = new PTXsmallLexer(CharStreams.fromString(inputPTX));
	 //    CommonTokenStream tokens = new CommonTokenStream(lexer);
	 //    PTXsmallParser parser = new PTXsmallParser(tokens);
		PTXLexer lexer = new PTXLexer(CharStreams.fromString(inputPTX));
	    CommonTokenStream tokens = new CommonTokenStream(lexer);
	    PTXParser parser = new PTXParser(tokens);

	    ParserRuleContext subtree = findSubTree(funcName); //, offset
	    	
	    ParseTreeWalker walker = new ParseTreeWalker();
	    PTX2Listener listener = new PTX2Listener(parser, subtree);
	    walker.walk(listener, parser.instructionList());
	}

	public static ParserRuleContext findSubTree(String funcName) { //, int offset
		ParseTreeWalker walker = new ParseTreeWalker();
	    PTXfListener listener = new PTXfListener(funcName);
	    walker.walk(listener, tree);

	    if(!listener.funcExist) {
	    	System.out.println("No such a function . . .");
	    	System.exit(1);
	    }

		return listener.subtree;
	}

	public static void printPTX(ParserRuleContext inputTree, String outputName) throws IOException {
	    ParseTreeWalker walker = new ParseTreeWalker(); // create standard walker
	    PTX2PTXListener listener = new PTX2PTXListener();
	    walker.walk(listener, inputTree); // initiate walk of tree with listener

	    // Output file
	    FileOutputStream output = new FileOutputStream(new File("output_"+outputName));
	    System.out.println("PTX 2 PTX output file name:  output_"+outputName);
	    output.write(listener.out.peek().toString().getBytes());
	    output.flush();
	    output.close();
	}
}

class PTXfListener extends PTXBaseListener {
	//PTXParser parser;
	String funcName;
	ParserRuleContext subtree;
  	boolean funcExist=false, funcIn=false;

	PTXfListener(String funcName){
		//this.parser = parser;
		this.funcName = funcName;
	}
	@Override public void enterKernelDirective(PTXParser.KernelDirectiveContext ctx){
		if(ctx.getChild(1).getText().equals(funcName)){
			funcExist=true;
			funcIn=true;
		}
	}
	@Override public void enterFunctionDirective(PTXParser.FunctionDirectiveContext ctx){
		if(ctx.getChild(1).getText().equals(funcName) || ctx.getChild(4).getText().equals(funcName)){
			funcExist=true;
			funcIn=true;
		}
	}
	@Override public void enterInstructionList(PTXParser.InstructionListContext ctx){
    	if(funcIn){
  			funcIn=false;
  			subtree = ctx;
  		}
  	}
}

class PTX2Listener extends PTXBaseListener {
	PTXParser parser;
	ParserRuleContext context;
	PTX2Listener(PTXParser parser, ParserRuleContext context) {
		//super(parser);
		this.parser = parser;
		this.context = context;
	}
	@Override public void exitInstructionList(PTXParser.InstructionListContext ctx){
		for (int i = 0; i < ctx.getChildCount(); i++) {
			ParseTree child = ctx.getChild(i);
			if (child instanceof PTXParser.InstructionContext == true) {
				System.out.println("This is ParserRuleContext");
				this.context.addChild((PTXParser.InstructionContext) child);
				System.out.println(this.context.getText());
			}
			System.out.println(this.context.getChildCount());
			//context.addChild(child);
		}
	}
	/*@Override public void enterInstruction(PTXsmallParser.InstructionContext ctx) {
		context.addChild(ctx);
	}*/
}

class PTX2PTXListener extends PTXBaseListener {
	Stack<StringBuilder> out = new Stack<StringBuilder>();
	//PTXParser parser;
	PTX2PTXListener(){
		out.push(new StringBuilder(""));
		//this.parser = parser;
	}

	@Override public void exitProgram(PTXParser.ProgramContext ctx){
		out.peek().append("\n");
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
		out.peek().append(node.getText()+" ");
	}
}
/*
antlr4 PTX.g4
javac PTX*.java
java PTX2PTX test.ptx

grun PTX program -gui < test.ptx
grun Expr prog -gui
*/
