%{
#include <stdio.h>
#include <string.h>
#define BUFFER_LENGTH 1000
int yylex();
void yyerror(char *s);



void append(char* src, char* new)
{
	int len1 = strlen(src);
	int len2 = strlen(new);
	int offset = 0;
	while(len2>offset)
	{
		src[len1+offset] = new[offset];
		offset++;	
	}
	src[len1+len2] = '\0';
}


void value_to_roman_num(char* s, int value)
{
	if(value == 0)
	{
		append(s, "Z");
		return;
	}
	if(value < 0)
	{
		append(s, "-");
		value = 0 - value;
	}	
	int unity = value % 10;
	value = value / 10;
	int ten = value % 10;
	value = value / 10;
	int hundred = value % 10;
	int thousand = value / 10;
	while(thousand>0)
	{
		append(s, "M");
		thousand--;
	}
	switch (hundred) 
	{
		case 0:
			break;
		case 1:
			append(s, "C");
			break;
		case 2:
			append(s,"CC");
			break;
		case 3:
			append(s,"CCC");
			break;
		case 4:
			append(s, "CD");
			break;
		case 5:
			append(s, "D");
			break;
		case 6:
			append(s,"DC");
			break;
		case 7:
			append(s,"DCC");
			break;
		case 8:
			append(s,"DCCC");
			break;
		case 9:
			append(s,"CM");
			break;
		default:
			break;													
	}
	switch (ten) 
	{
		case 0:
			break;
		case 1:
			append(s, "X");
			break;
		case 2:
			append(s, "XX");
			break;
		case 3:
			append(s, "XXX");
			break;
		case 4:
			append(s, "XL");
			break;
		case 5:
			append(s, "L");
			break;
		case 6:
			append(s, "LX");
			break;
		case 7:
			append(s, "LXX");
			break;
		case 8:
			append(s, "LXXX");
			break;
		case 9:
			append(s, "XC");
			break;
		default:
			break;
	}
	switch (unity)
	{
		case 0:
			break;
		case 1:
			append(s, "I");
			break;
		case 2:
			append(s, "II");
			break;
		case 3:
			append(s, "III");
			break;
		case 4:
			append(s, "IV");
			break;
		case 5:
			append(s, "V");
			break;
		case 6:
			append(s, "VI");
			break;
		case 7:
			append(s, "VII");
			break;
		case 8:
			append(s, "VIII");
			break;
		case 9:
			append(s, "IX");
			break;
		default:
			break;										
	}
	return;
}


%}
  



%token THOUSAND
%token NINE_HUNDRED
%token FIVE_HUNDRED
%token FOUR_HUNDRED
%token HUNDRED
%token NINETY
%token FIFTY
%token FOURTY
%token TEN
%token NINE
%token FIVE
%token FOUR
%token ONE
%token EOL
%token ADD
%token MINUS
%token MULT
%token DIV
%token OPENP
%token CLOSEP
%%
value : statement EOL {char s[BUFFER_LENGTH] = ""; value_to_roman_num(s, $1); printf("%s\n", s);}
    | value statement EOL {char s[BUFFER_LENGTH] = ""; value_to_roman_num(s, $2); printf("%s\n", s);}


statement : multpart
	| statement ADD multpart {$$ = $1 + $3;}
	| statement MINUS multpart {$$ = $1 - $3;}
	;

multpart : expr
	| multpart MULT expr {$$ = $1 * $3;}
	| multpart DIV expr {$$ = $1 / $3;}
	;
	
expr : num 
	| OPENP statement CLOSEP {$$ = $2;}
	;


num : thousand_term hundred_term ten_term unity_term {$$ = $1 + $2 + $3 + $4;}
;

thousand_term : {$$ = 0;}
	| thousand_term THOUSAND {$$ = $1 + $2;}    	
	;

hundred_term : {$$ = 0;}| NINE_HUNDRED 
	| FIVE_HUNDRED HUNDRED HUNDRED HUNDRED {$$ = $1 + $2 + $3 + $4;}
	| FIVE_HUNDRED HUNDRED HUNDRED {$$ = $1 + $2 + $3;}
	| FIVE_HUNDRED HUNDRED {$$ = $1 + $2;}
	| FIVE_HUNDRED
	| FOUR_HUNDRED
	| HUNDRED HUNDRED HUNDRED {$$ = $1 + $2 + $3;}
	| HUNDRED HUNDRED {$$ = $1 + $2;}
	| HUNDRED
	;

ten_term : {$$ = 0;} | NINETY
	| FIFTY TEN TEN TEN {$$ = $1 + $2 + $3 + $4;}
	| FIFTY TEN TEN {$$ = $1 + $2 + $3;}
	| FIFTY TEN {$$ = $1 + $2;}
	| FIFTY
	| FOURTY
	| TEN TEN TEN {$$ = $1 + $2 + $3;}
	| TEN TEN {$$ = $1 + $2;}
	| TEN
	;

unity_term : {$$ = 0;}| NINE
	| FIVE ONE ONE ONE {$$ = $1 + $2 + $3 + $4;}
	| FIVE ONE ONE {$$ = $1 + $2 + $3;}
	| FIVE ONE {$$ = $1 + $2;}
	| FIVE
	| FOUR
	| ONE ONE ONE {$$ = $1 + $2 + $3;}
	| ONE ONE {$$ = $1 + $2;}
	| ONE
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

