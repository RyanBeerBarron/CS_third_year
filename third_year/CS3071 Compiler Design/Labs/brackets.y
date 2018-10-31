%{ 
#  include <stdio.h>
#  include <stdlib.h>
void yyerror(char *s);
int yylex();
int yyparse();
%}
%output "brackets.c"

%token OP CP N EOL
%%

calclist: /* nothing */ {}
| calclist expr EOL { printf("Input conforms to grammar\n");  }
;

//expr: N N N { }
//;

expr: OP expr CP 
 | N
 ;
%%
void yyerror(char *s)
{
  printf("error: %s\n", s);
}


int
main()
{
//  yydebug = 1;
  yyparse();
  return 0;
}
