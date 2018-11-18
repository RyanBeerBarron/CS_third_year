%{
	#include "calcwithvariables.tab.h"
%}

%%
[a-z] 	{yylval = yytext[0]; return VARIABLE;}
[0-9]+ 	{yylval = atoi(yytext); return IMMEDIATE_VALUE;}
:=		{return ASSIGN_OPERATOR;}
;		{return SEMICOLON;}
\+		{return PLUS;}
\-		{return MINUS;}
\*		{return MULT;}
\/		{return DIV;}
print 	{return PRINT;}
\ 		{return SPACE;}
[^ (print)(a-z)(0-9)(:=);\+\-\*\/\n]* {}
\n		{}
%%