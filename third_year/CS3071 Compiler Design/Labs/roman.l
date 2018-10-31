%{
#include "roman.tab.h"
void yyerror(char *s);
%}

%%
I 	{yylval = 1; return ONE;}
IV	{yylval = 4; return FOUR;}
V	{yylval = 5; return FIVE;}
IX 	{yylval = 9; return NINE;}
X	{yylval = 10; return TEN;}
XL	{yylval = 40; return FOURTY;}
L	{yylval = 50; return FIFTY;}
XC	{yylval = 90; return NINETY;}
C	{yylval = 100; return HUNDRED;}
CD	{yylval = 400; return FOUR_HUNDRED;}
D	{yylval = 500; return FIVE_HUNDRED;}
CM	{yylval = 900; return NINE_HUNDRED;}
M	{yylval = 1000; return THOUSAND;}
\n	{return EOL;}
[^IVXLCDM\n]* {return 0;}
%%