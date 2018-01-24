/* PTX 5.0 */

grammar PTX;

program
: modDirectiveList? directiveList?
;

modDirectiveList
: modDirective+
;

modDirective
: '.version' versionNumber
| '.target' targetSpecifiersList
| '.address_size' '32' | '.address_size' '64'
;

versionNumber
: DECDIGIT Dotsign DECDIGIT
;

targetSpecifiersList
: targetSpecifier (',' targetSpecifier)*
;

targetSpecifier
: 'sm_60' | 'sm_61' 
| 'sm_50' | 'sm_52' | 'sm_53' |
| 'sm_30' | 'sm_32' | 'sm_35' | 'sm_37' 
| 'sm_20' 
| 'sm_10' | 'sm_11' | 'sm_12' | 'sm_13' 
| 'texmode_unified' | 'texmode_independent' 
| 'debug' 
| 'map_f64_to_f32'
;

directiveList
: directive+
;

directive
: linkingDirective? kernelDirective
| linkingDirective? functionDirective
| controlDirective
| performDirective
| debugDirective
;

kernelDirective
: '.entry' nameString performDirective* ( '(' paramList ')' )? statementList
;

functionDirective
: '.func' ( '(' param ')' )? nameString (paramList)? statementList
;

controlDirective
: labelName ':' '.branchtargets' labelName+ ';'
| labelName ':' '.calltargets' nameString+ ';'
| labelName ':' '.callprototype' ('(' param ')')? '_' ('(' paramList ')')? ';'
;

labelName
: identifier
;

performDirective
: '.maxnreg' digit | '.maxntid' digit (',' digit)* | '.reqntid' digit (',' digit)* | '.minnctapersm' digit |'.maxnctapersm' digit |'.pragma'  '"' nameString '"'
;

debugDirective
: dwarfDebug 
| sectionDebug
| fileDebug
| locDebug
;

dwarfDebug
: '@@DWARF' dwarfStringList
;

dwarfStringList
: '.byte' HEXDIGIT (',' HEXDIGIT)*
| '.4byte' HEXDIGIT (',' HEXDIGIT)*
| '.quad' HEXDIGIT (',' HEXDIGIT)*
| '4byte' nameString
| 'quad' nameString
;

sectionDebug
: '.section' nameString '{' dwarfLines '}'
;

dwarfLines
: '.b8' HEXDIGIT (',' HEXDIGIT)*
| '.b32' HEXDIGIT (',' HEXDIGIT)*
| '.b64' HEXDIGIT (',' HEXDIGIT)*
| '.b32' nameString
| '.b64' nameString
| '.b32' nameString '+' HEXDIGIT (',' HEXDIGIT)*
| '.b64' nameString '+' HEXDIGIT (',' HEXDIGIT)*
;

fileDebug
: '.file' HEXDIGIT '"' nameString '"' (',' HEXDIGIT ',' HEXDIGIT)?
;

locDebug
: '.loc' HEXDIGIT HEXDIGIT HEXDIGIT
;

linkingDirective
: '.extern' | '.visible' | '.weak'
;

paramList
: '(' param (',' param)* ')'
;

param
: '.param' type identifier
;

statementList
: '{' instructionList? '}'
;

instructionList
: instruction+
;

instruction
: nameString ':' 
| declaration
| GuardPred? opcode operand? (',' operand)* ';'
;

declaration
: StateSpace alignment? type variableInit ';'
;

alignment
: '.align' digit
;

variableInit
: variable '=' initialVal
;

variable
: registerVal | vectorVal | arrayVal
;

initialVal
: '{' initialVal '}'
| ',' initialVal
| digit (',' digit)*
;

registerVal
: '%' nameString '<'? digit? '>'?
;

vectorVal
: nameString
;

arrayVal
: nameString ('[' digit? ']')*
;

GuardPred
: '@' '!'? ('p' | 'q' | 'r' | 's')
;

operand
: registerVariable
| constantExpression
| '[' addressExpression ']'
| labelName
| vectorOperand
;

vectorOperand
: '{' nameString (',' nameString)* '}'
;

registerVariable
: '%' regString digit?
;

regString
: cchar+
;

addressExpression
: registerVariable
| HexadecimalLiteral
| nameString
| addressExpression '+' digit
;

opcode
: nameString ('.' nameString)*
;

StateSpace
: '.reg' | '.sreg' | '.const' | '.global' | '.local' | ('ld')? '.param' | ('st')? '.param' | '.shared' | '.tex'
;

type
: signedInt | unsignedInt | floatingPoint | bits | predicate
| '.v2' type | '.v4' type
;

signedInt
: '.s8' | '.s16' | '.s32' | '.s64'
;
unsignedInt
: '.u8' | '.u16' | '.u32' | '.u64'
;
floatingPoint
: '.f16' | '.f16x2' | '.f32' | '.f64'
;
bits
: '.b8' | '.b16' | '.b32' | '.b64'
;
predicate
: '.pred'
;

constantExpression
: constantExpression Binaryop constantExpression
| Unaryop constantExpression
| '(' constantExpression ')'
| HexadecimalLiteral
| OctalLiteral
| BinaryLiteral
| DecimalLiteral
| FloatConst
;

HexadecimalLiteral : Unaryop? '0' [xX] HEXDIGIT+ 'U'?;
OctalLiteral : Unaryop? '0' OCTDIGIT+ 'U'?;	
BinaryLiteral : Unaryop? '0' [bB] HEXDIGIT+ 'U'?;
DecimalLiteral : Unaryop? [1-9] DECDIGIT* 'U'?;

FloatConst: '0' [fFdD] HEXDIGIT+;

nameString
: (DECDIGIT | cchar)+
;

cchar
: NONDIGIT | symbol
;

symbol
: Priop | Unaryop | Binaryop | Grave | Atsign | Crosshatch | Dollarsign | Underscore | Equalsign | Commasign | Dotsign | Questionmark | Colonsign | Semicolonsign | Quotation | Lbracket | Rbracket | Lbrace | Rbrace | Backslash | Apostrophe
;

fragment FOLLOWSYM: [a-zA-Z0-9_$];
identifier
: NONDIGIT FOLLOWSYM* 
| (Underscore | Dollarsign | '%') FOLLOWSYM+
;

digit
: HEXDIGIT+ | DECDIGIT+ | OCTDIGIT+ | BIDIGIT+
;

fragment BIDIGIT : [01];
fragment OCTDIGIT : [0-7];
fragment DECDIGIT : [0-9];
fragment HEXDIGIT : [0-9a-fA-F];

fragment NONDIGIT : [a-zA-Z];

Priop : '(' | ')';
Unaryop : '+' | '-' | '!' | '~';
Binaryop : '*' | '/' | '%'
	  | '+' | '-'  | '>>' | '<<'
	  | '<' | '>' | '<=' | '>='
	  | '==' | '!='
	  | '&' | '^' | '|' | '&&' | '||' ;
Ternaryop : '?:';

Grave : '`' ;
Atsign : '@' ;
Crosshatch : '#' ;
Dollarsign : '$' ;
Underscore : '_' ;
Equalsign : '=' ;
Commasign : ',' ;
Dotsign : '.' ;
Questionmark : '?' ;
Colonsign : ':' ;
Semicolonsign : ';' ;
Quotation : '"' ;
Lbracket : '[' ;
Rbracket : ']' ;
Lbrace : '{';
Rbrace : '}';
Backslash : '\\';
Apostrophe : '\'';

WhiteSpace : [ \t]+ -> skip;
Newline : ( '\r' '\n'? | '\n' ) -> skip;
LineComment : '//' ~[\r\n]* -> skip;
