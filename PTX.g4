/* PTX 5.0 */

grammar PTX;

program
: modDirective? directiveList?
;

modDirective
: '.version' Decdigit '.' Decdigit
| '.target' targetSpecifiersList
| '.address_size' '32' | '.address_size' '64'
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
: '.func' ('(' param ')')? nameString (paramList)? statementList
;

controlDirective
: labelName ':' '.branchtargets' labelName+ ';'
| labelName ':' '.calltargets' nameString+ ';'
| labelName ':' '.callprototype' ('(' param ')')? '_' ('(' paramList ')')? ';'
;

labelName
: nameString
;

performDirective
: '.maxnreg' Digit | '.maxntid' Digit (',' Digit)* | '.reqntid' Digit (',' Digit)* | '.minnctapersm' Digit |'.maxnctapersm' Digit |'.pragma'  '"' nameString '"'
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
: '.byte' Hexdigit (',' Hexdigit)*
| '.4byte' Hexdigit (',' Hexdigit)*
| '.quad' Hexdigit (',' Hexdigit)*
| '4byte' nameString
| 'quad' nameString
;

sectionDebug
: '.section' nameString '{' dwarfLines '}'
;

dwarfLines
: '.b8' Hexdigit (',' Hexdigit)*
| '.b32' Hexdigit (',' Hexdigit)*
| '.b64' Hexdigit (',' Hexdigit)*
| '.b32' nameString
| '.b64' nameString
| '.b32' nameString '+' Hexdigit (',' Hexdigit)*
| '.b64' nameString '+' Hexdigit (',' Hexdigit)*
;

fileDebug
: '.file' Hexdigit '"' nameString '"' (',' Hexdigit ',' Hexdigit)?
;

locDebug
: '.loc' Hexdigit Hexdigit Hexdigit
;

linkingDirective
: '.extern' | '.visible' | '.weak'
;

paramList
: '(' param (',' param)* ')'
;

param
: '.param' type nameString
;

statementList
: '{' instructionList? '}'
;

instructionList
: instruction+
;

instruction
:  '//' nameString
| nameString ':' 
| declaration
| guardPred? opcode operand? (',' operand)* ';'
;

declaration
: stateSpace alignment? type variableInit ';'
;

alignment
: '.align' Digit
;

variableInit
: variable '=' initialVal
;

variable
: registerVal | vectorVal | arrayVal
;

initialVal
: '{' initialVal '}'
| initialVal (',' initialVal)*
| Digit (',' Digit)*
;

registerVal
: '%' nameString '<'? Digit? '>'?
;

vectorVal
: nameString
;

arrayVal
: nameString ('[' Digit? ']')*
;

guardPred
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
: '%' regString Digit?
;

regString
: cchar+
;

addressExpression
: registerVariable
| HexadecimalLiteral
| nameString
| addressExpression '+' Digit
;

opcode
: nameString ('.' nameString)*
;

stateSpace
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

HexadecimalLiteral : Unaryop? '0' [xX] Hexdigit+ 'U'?;
OctalLiteral : Unaryop? '0' Octdigit+ 'U'?;	
BinaryLiteral : Unaryop? '0' [bB] Hexdigit+ 'U'?;
DecimalLiteral : Unaryop? [1-9] Decdigit* 'U'?;

FloatConst: '0' [fFdD] Hexdigit+;

nameString
: (Decdigit | cchar)+
;

Digit
: Hexdigit+ | Decdigit+ | Octdigit+ | Bidigit+
;

Hexdigit : [0-9a-fA-F];
Decdigit : [0-9];
Octdigit : [0-7];
Bidigit : [01];

Nondigit : [a-zA-z];

Priop : '(' | ')';
Unaryop : '+' | '-' | '!' | '~';
Castop : '.u64' | '.s64';
Binaryop : '*' | '/' | '%'
	  | '+' | '-'  | '>>' | '<<'
	  | '<' | '>' | '<=' | '>='
	  | '==' | '!='
	  | '&' | '^' | '|' | '&&' | '||' ;
Ternaryop : '?:';

WhiteSpace : [ \t]+ -> skip;
Newline : ( '\r' '\n'? | '\n' ) -> skip;

cchar
: Nondigit | ssymbol
;

ssymbol
: Priop | Unaryop | Binaryop | grave | atsign | crosshatch | dollarsign | underscore | equalsign | commasign | dotsign | backslash | questionmark | colonsign | semicolonsign | apostrophe | quotation | lbracket | rbracket | lbrace | rbrace
;

grave : '`' ;
atsign : '@' ;
crosshatch : '#' ;
dollarsign : '$' ;
underscore : '_' ;
equalsign : '=' ;
commasign : ',' ;
dotsign : '.' ;
backslash : '\'? ;
questionmark : '?' ;
colonsign : ':' ;
semicolonsign : ';' ;
apostrophe : ''' ;
quotation : '"' ;
lbracket : '[' ;
rbracket : ']' ;
lbrace : '{';
rbrace : '}';

Followsym: [a-zA-Z0-9_$];
Identifier: [a-zA-Z] Followsym* | [_$%] Followsym+;
