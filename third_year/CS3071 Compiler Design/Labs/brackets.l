%{
# include "brackets.h"

void yyerror(char *s);
int yylex();


%}

%%
"(" { return OP; }
")" { return CP; }
"N" { return N; }
\n  { return EOL; }
.	{ yyerror("Mystery character\n"); }
%%
