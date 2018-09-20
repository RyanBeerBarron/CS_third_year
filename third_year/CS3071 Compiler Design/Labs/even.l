%{
	int even = 0;
	int lastDigit = 0;
	int strLength = 0;
%}

%%

[0-9]+	{strLength = strlen(yytext);
		 lastDigit = yytext[strLength-1];
		 if(lastDigit%2==0) even++;}
\n	{}
.	{}

%%

int main()
{
	yylex();
	printf("Number of even number: %d\n", even);
	return 0;
}		 

