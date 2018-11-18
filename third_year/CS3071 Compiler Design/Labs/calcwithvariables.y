%{
#include <stdio.h>
#include <stdlib.h>	
#define BUFFER_LENGTH 100
int yylex();
void yyerror(char *s);

char keys[BUFFER_LENGTH];
int values[BUFFER_LENGTH];

int lookup(char c, int* p)
{
	int i = 0;
	while(keys[i] != 0 && i < BUFFER_LENGTH)
	{
		if(keys[i] == c)
		{
			*p = values[i];
			return 1;
		}
		i++;	
	}
	return 0;
}

int insert(char c, int v)
{
	int i = 0;
	while(keys[i] != 0 && i < BUFFER_LENGTH)
	{
		if(keys[i] == c)
		{
			values[i] = v;
			return 1;
		}
		i++;	
	}
	if(i < BUFFER_LENGTH)
	{
		keys[i] = c;
		values[i++] = v;
		keys[i] = 0;
		return 1;
	}	
	return 0;
} 

%}

%token VARIABLE
%token IMMEDIATE_VALUE
%token ASSIGN_OPERATOR
%token SEMICOLON
%token PLUS
%token MINUS
%token MULT
%token DIV
%token PRINT
%token SPACE
%%

program : statement
	| program statement 
	;
statement : print_stmt
	| assign_statment
	;

print_stmt : PRINT SPACE addexpression SEMICOLON {printf("%d\n", $3);}
	;

assign_statment : VARIABLE ASSIGN_OPERATOR addexpression SEMICOLON {insert($1, $3);}
	;

addexpression : multexpression 
	| addexpression PLUS multexpression 	{$$ = $1 + $3;}
	| addexpression MINUS multexpression {$$ = $1 - $3;}
	;

multexpression : intermediate
	| multexpression MULT intermediate	{$$ = $1 * $3;}
	| multexpression DIV intermediate	{$$ = $1 / $3;}
	;

intermediate : VARIABLE 	{	
								int a;
								int rv = lookup($1, &a);
								if(rv)
								{
									$$ = a;
								}
								else
								{ 	
									yyerror("");
									return 0;
								}	
							}
	| IMMEDIATE_VALUE
	| MINUS intermediate { $$ = -$2;}
	;

%%
int main()
{
    yyparse();
	return 0;
}
	
void yyerror(char *s)
{
		printf("syntax error\n");
}