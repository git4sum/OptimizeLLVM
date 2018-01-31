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
: VersionNum
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

controlDirective
: labelName ':' '.branchtargets' labelName+ ';'
| labelName ':' '.calltargets' identifier ';'
| labelName ':' '.callprototype' ('(' param ')')? '_' paramList? ';'
;

labelName
: identifier
;

performDirective
: PerformanceDirectives
| '.pragma'  '"' identifier '"' ';'
;

PerformanceDirectives
: '.maxnreg' Digits | '.maxntid' Digits (',' Digits)* | '.reqntid' Digits (',' Digits)* | '.minnctapersm' Digits |'.maxnctapersm' Digits
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
: DwarfStrings
| '4byte' identifier
| 'quad' identifier
;

DwarfStrings
: '.byte' Hexdigits (',' Hexdigits)*
| '.4byte' Hexdigits (',' Hexdigits)*
| '.quad' Hexdigits (',' Hexdigits)*

;

sectionDebug
: '.section' identifier '{' dwarfLine '}'
;

dwarfLine
: '.b8' Hexlists
| '.b32' Hexlists
| '.b64' Hexlists
| '.b32' identifier
| '.b64' identifier
| '.b32' identifier '+' Hexlists
| '.b64' identifier '+' Hexlists
;

Hexlists
: Hexdigits (',' Hexdigits)*
;

fileDebug
: Fileindex '"' identifier '"' Fileoption?
;

Fileindex
: '.file' Digits
;

Fileoption
: ',' Hexdigits ',' Digits
;

locDebug
: '.loc' Locindex
;

Locindex
: Digits Digits Digits
;

kernelDirective
: '.entry' identifier performDirective* paramList? '{' statementList '}'
;

functionDirective
: '.func' ( '(' param ')' )? identifier paramList? '{' statementList '}'
;

linkingDirective
: '.extern' | '.visible' | '.weak'
;

paramList
: '(' param (',' param)* ')'
;

param
: '.param' Type identifier
;

statementList
: declarationList instructionList
;

declarationList
: declaration+
;

declaration
: variableInit ';'
;

Decltype
: StateSpace Alignment? Type
;

instructionList
: instruction+
;

instruction
: labelName ':' 
| GuardPred? opcode operand? (',' operand)* ';'
;

Alignment
: '.align' Digits
;

variableInit
: variable ('=' initialVal)?
;

variable
: registerVal | vectorVal | arrayVal
;

initialVal
: '{' initialVal '}'
| ',' initialVal
| Digitlists
;


Digitlists
: Digits (',' Digits)*
;

registerVal
: '%' identifier RegisterIndex?
;

RegisterIndex
: '<' Digits? '>'
;

vectorVal
: identifier
;

arrayVal
: identifier ArrayIndex*
;

ArrayIndex
: '[' Digits? ']'
;

operand
: registerVariable
| constantExpression
| '[' addressExpression ']'
| labelName
| vectorOperand
;

vectorOperand
: '{' identifier (',' identifier)* '}'
;

registerVariable
: Regexpression
;

Regexpression
: '%' RegString Digits?
;

fragment
RegString
: (NONDIGIT | Symbol)+
;

addressExpression
: registerVariable
| IntegerLiteral
| identifier
| addressExpression AddrOffset
;

AddrOffset
: '+' Digits
;

opcode
: identifier ('.' identifier)*
;

constantExpression
: constantExpression Binaryop constantExpression
| Unaryop constantExpression
| '(' constantExpression ')'
| IntegerLiteral
| FloatLiteral
;

fragment
Followsym: [a-zA-Z0-9_$]
;

identifier
: IdentifierString
;

IdentifierString
: NONDIGIT Followsym*
| ( Dollarsign | Percentsign) Followsym+
;

VersionNum
: Digits+ Dotsign Digits+
;

IntegerLiteral
: Unaryop? DecimalLiteral
| Unaryop? OctalLiteral
| Unaryop? HexadecimalLiteral
| Unaryop? BinaryLiteral
;

FloatLiteral
: Unaryop? FloatConst
;

fragment HexadecimalLiteral : '0' [xX] Hexdigits+ 'U'?;
fragment OctalLiteral : '0' [0-7]+ 'U'?;	
fragment BinaryLiteral : '0' [bB] [01]+ 'U'?;
fragment DecimalLiteral : [1-9] Digits* 'U'?;

fragment FloatConst: '0' [fFdD] Hexdigits+;


fragment
Symbol
: Priop | Unaryop | Binaryop | Grave | Atsign | Crosshatch | Dollarsign | Underscore | Equalsign | Commasign | Dotsign | Questionmark | Colonsign | Semicolonsign | Quotation | Lbracket | Rbracket | Lbrace | Rbrace | Backslash | Apostrophe
;

fragment
Digits
: DIGIT+
;

fragment
Hexdigits
: HEXDIGIT+
;

fragment
HEXDIGIT : DIGIT | [a-fA-F]
;
fragment
DIGIT : [0-9]
;
fragment
NONDIGIT : [a-zA-Z_]
;

Priop : '(' | ')';
Unaryop : '+' | '-' | '!' | '~';
Binaryop : '*' | '/' | Percentsign
	  | '+' | '-'  | '>>' | '<<'
	  | '<' | '>' | '<=' | '>='
	  | '==' | '!='
	  | '&' | '^' | '|' | '&&' | '||' ;
Ternaryop : '?:';

Percentsign : '%' ;

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

GuardPred
: '@' '!'? ('p' | 'q' | 'r' | 's')
;

fragment
StateSpace
: '.reg' | '.sreg' | '.const' | '.global' | '.local' | '.param' | 'ld' '.param' | 'st' '.param' | '.shared' | '.tex'
;

Type
: SignedInt | UnsignedInt | FloatingPoint | Bits | Predicate 
| '.v2' SignedInt | '.v2' UnsignedInt | '.v2' FloatingPoint | '.v2' Bits | '.v2' Predicate
| '.v4' SignedInt | '.v4' UnsignedInt | '.v4' FloatingPoint | '.v4' Bits | '.v4' Predicate 
;

fragment
SignedInt
: '.s8' | '.s16' | '.s32' | '.s64'
;
fragment
UnsignedInt
: '.u8' | '.u16' | '.u32' | '.u64'
;
fragment
FloatingPoint
: '.f16' | '.f16x2' | '.f32' | '.f64'
;
fragment
Bits
: '.b8' | '.b16' | '.b32' | '.b64'
;
fragment
Predicate
: '.pred'
;

WhiteSpace : [ \t]+ -> skip;
Newline : ( '\r' '\n'? | '\n' ) -> skip;
LineComment : '//' ~[\r\n]* -> skip;

//nameString: .+ ;
