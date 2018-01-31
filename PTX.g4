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
: TargetSpecifier (',' TargetSpecifier)*
;

fragment
TargetSpecifier
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
: LinkingDirective? kernelDirective
| LinkingDirective? functionDirective
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
: Dwarftype Hexlists
| Dwarftype identifier
| Dwarftype identifier '+' Hexlists
;

Dwarftype
: Bits
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
: '.entry' identifier performDirective* paramList? ('{' statementList '}')?
;

functionDirective
: '.func' ('(' param ')')? identifier paramList? ('{' statementList '}')?
;

LinkingDirective
: '.extern' | '.visible' | '.weak'
;

paramList
: '(' param (',' param)* ')'
;

param
: Paramfront type identifier
;

Paramfront
: PARAM 
;

//Paramtype
//: type
//;

statementList
: declarationList instructionList
;

declarationList
: declaration+
;

declaration
: Decfront type variableInit ';'
;

Decfront
: StateSpace Alignment? 
;

//Dectype
//: type
//;

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
: '%' identifier Registernum?
;

Registernum
: Digits
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
| ('$' | '%') Followsym+
;

VersionNum
: Digits+ '.' Digits+
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
Binaryop : '*' | '/' | '%'
	  | '+' | '-'  | '>>' | '<<'
	  | '<' | '>' | '<=' | '>='
	  | '==' | '!='
	  | '&' | '^' | '|' | '&&' | '||' ;
//Ternaryop : '?:';

GuardPred
: '@' '!'? ('p' | 'q' | 'r' | 's')
;

StateSpace
: REG | SREG | CONST | GLOBAL | LOCAL | PARAM | LDPARAM | STPARAM | SHARED | TEX
;

fragment REG : '.reg' ;
fragment SREG : '.sreg' ;
fragment CONST : '.const' ;
fragment GLOBAL : '.global' ;
fragment LOCAL : '.local' ;
fragment PARAM : '.param' ;
fragment LDPARAM : '.ld.param';
fragment STPARAM : '.st.param' ;
fragment SHARED : '.shared' ;
fragment TEX : '.tex' ;

type
: Types
;

Types
//: SIGN8 | SIGN16 | SIGN32 | SIGN64 | UNSIGN8 | UNSIGN16 | UNSIGN32 | UNSIGN64 | FLOAT16 | FLOAT16X | FLOAT32 | FLOAT64 | BITS8 | BITS16 | BITS32 | BITS64
: SignedInt | UnsignedInt | FloatingPoint | Bits | Predicate 
//| VECTOR2 SignedInt | VECTOR2 UnsignedInt | VECTOR2 FloatingPoint | VECTOR2 Bits | VECTOR2 Predicate
//| VECTOR4 SignedInt | VECTOR4 UnsignedInt | VECTOR4 FloatingPoint | VECTOR4 Bits | VECTOR4 Predicate 
;

//fragment
SignedInt
: SIGN8 | SIGN16 | SIGN32 | SIGN64
;
//fragment
UnsignedInt
: UNSIGN8 | UNSIGN16 | UNSIGN32 | UNSIGN64
;
//fragment
FloatingPoint
: FLOAT16 | FLOAT16X | FLOAT32 | FLOAT64
;
//fragment
Bits
: BITS8 | BITS16 | BITS32 | BITS64
;
//fragment
Predicate
: '.pred'
;

fragment 
SIGN8 :'.s8' ;
fragment 
SIGN16 : '.s16' ;
fragment 
SIGN32 : '.s32' ;
fragment 
SIGN64 : '.s64' ;
fragment 
UNSIGN8 :'.u8' ;
fragment 
UNSIGN16 : '.u16' ;
fragment 
UNSIGN32 : '.u32' ;
fragment 
UNSIGN64 : '.u64' ;
fragment 
FLOAT16 :'.f16' ;
fragment 
FLOAT16X : '.f16x2' ;
fragment 
FLOAT32 : '.f32' ;
fragment 
FLOAT64 : '.f64' ;
fragment 
BITS8 :'.b8' ;
fragment 
BITS16 : '.b16' ;
fragment 
BITS32 : '.b32' ;
fragment 
BITS64 : '.b64' ;
fragment 
VECTOR2 : '.v2' ;
fragment 
VECTOR4 : '.v4' ;


WhiteSpace : [ \t]+ -> skip;
Newline : ( '\r' '\n'? | '\n' ) -> skip;
LineComment : '//' ~[\r\n]* -> skip;
