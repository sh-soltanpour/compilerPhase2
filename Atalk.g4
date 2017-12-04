grammar Atalk;
@members{
	void print(String str){
        System.out.println(str);
    }
	void beginScope() {
    	int offset = 0;
    	if(SymbolTable.top != null)
        	offset = SymbolTable.top.getOffset(Register.SP);
      SymbolTable.push(new SymbolTable());
      SymbolTable.top.setOffset(Register.SP, offset);
    }
	void endScope(){
		 print("Stack offset: " + SymbolTable.top.getOffset(Register.SP));
  	SymbolTable.pop();
	}
	void putLocalVar(String name, Type type) throws ItemAlreadyExistsException{
		SymbolTable.top.put(
            new SymbolTableLocalVariableItem(
                new Variable(name, type),
                SymbolTable.top.getOffset(Register.SP)
            )
        );
	 }
	 void putGlobalVar(String name, Type type) throws ItemAlreadyExistsException{
		SymbolTable.top.put(
            new SymbolTableGlobalVariableItem(
                new Variable(name, type),
                SymbolTable.top.getOffset(Register.GP)
            )
        );
	 }
}
program:
		{beginScope();}(actor | NL)*{endScope();}
	;

actor:
		'actor' name=ID '<' mailboxSize=CONST_NUM '>' NL
		 {
				try{
					Tools.putActor($name.text,Integer.parseInt($mailboxSize.text));
				}
				catch(ItemAlreadyExistsException e) {
            	print("Exists");
        }
				finally{beginScope(); }
			}
			(state | receiver | NL)*
		'end' (NL | EOF)
		{endScope();}
	;
state:
			type name = ID (',' ID)* NL 
			{
				try{
					putGlobalVar($name.text,$type.return_type);
				}
				catch(ItemAlreadyExistsException e) {
            	print("Exists");
        }
			}
	;

receiver:
		'receiver' ID '(' (type ID (',' type ID)*)? ')' NL
			statements
		'end' NL
	;

type returns [Type return_type]:
		'char' ('[' CONST_NUM ']')* {$return_type = CharType.getInstance();}
	|	'int' ('[' CONST_NUM ']')* 	{$return_type = IntType.getInstance();}
	;

block:
		'begin' NL
			statements
		'end' NL
	;

statements:
		(statement | NL)*
	;

statement:
		stm_vardef
	|	stm_assignment
	|	stm_foreach
	|	stm_if_elseif_else
	|	stm_quit
	|	stm_break
	|	stm_tell
	|	stm_write
	|	block
	;

stm_vardef:
	 type ID ('=' expr)? (',' ID ('=' expr)?)* NL 
	;

stm_tell:
		(ID | 'sender' | 'self') '<<' ID '(' (expr (',' expr)*)? ')' NL
	;

stm_write:
		'write' '(' expr ')' NL
	;

stm_if_elseif_else:
		'if' expr NL statements
		('elseif' expr NL statements)*
		('else' NL statements)?
		'end' NL
	;

stm_foreach:
		'foreach' ID 'in' expr NL
			statements
		'end' NL
	;

stm_quit:
		'quit' NL
	;

stm_break:
		'break' NL
	;

stm_assignment:
		expr NL
	;

expr:
		expr_assign
	;

expr_assign:
		expr_or '=' expr_assign
	|	expr_or
	;

expr_or:
		expr_and expr_or_tmp
	;

expr_or_tmp:
		'or' expr_and expr_or_tmp
	|
	;

expr_and:
		expr_eq expr_and_tmp
	;

expr_and_tmp:
		'and' expr_eq expr_and_tmp
	|
	;

expr_eq:
		expr_cmp expr_eq_tmp
	;

expr_eq_tmp:
		('==' | '<>') expr_cmp expr_eq_tmp
	|
	;

expr_cmp:
		expr_add expr_cmp_tmp
	;

expr_cmp_tmp:
		('<' | '>') expr_add expr_cmp_tmp
	|
	;

expr_add:
		expr_mult expr_add_tmp
	;

expr_add_tmp:
		('+' | '-') expr_mult expr_add_tmp
	|
	;

expr_mult:
		expr_un expr_mult_tmp
	;

expr_mult_tmp:
		('*' | '/') expr_un expr_mult_tmp
	|
	;

expr_un:
		('not' | '-') expr_un
	|	expr_mem
	;

expr_mem:
		expr_other expr_mem_tmp
	;

expr_mem_tmp:
		'[' expr ']' expr_mem_tmp
	|
	;

expr_other:
		CONST_NUM
	|	CONST_CHAR
	|	CONST_STR
	|	ID
	|	'{' expr (',' expr)* '}'
	|	'read' '(' CONST_NUM ')'
	|	'(' expr ')'
	;

CONST_NUM:
		[0-9]+
	;

CONST_CHAR:
		'\'' . '\''
	;

CONST_STR:
		'"' ~('\r' | '\n' | '"')* '"'
	;

NL:
		'\r'? '\n' { setText("new_line"); }
	;

ID:
		[a-zA-Z_][a-zA-Z0-9_]*
	;

COMMENT:
		'#'(~[\r\n])* -> skip
	;

WS:
    	[ \t] -> skip
    ;