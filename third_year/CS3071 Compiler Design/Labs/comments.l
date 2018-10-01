%{
%}

%%
(\"[^\"]*\")	{printf("%s", yytext);}
([{][^\}]*)	{printf("syntax error\n"); return(0);}
([{][^\}]*[}])	{}
[}]	{printf("syntax error\n"); return(0);}
(\*\*(.*))	{}
([^\*\n\"\{\}]*)	{printf("%s", yytext);}
\n	{printf("%s", yytext);}
%%

int main()
{
	yyin=fopen("test.txt", "r");
	yylex();
	return(0);
}