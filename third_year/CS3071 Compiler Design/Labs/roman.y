%{
#include <stdio.h>
int yylex();
void yyerror(char *s);
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
%%
romanToArabic : expr EOL {printf("%d\n", $1);}
    | romanToArabic expr EOL {printf("%d\n", $2);}

;	
				

/*	
			//	-- Other version --
expr : thousand_term hundred_term ten_term unity_term {$$ = $1 + $2 + $3 + $4;}
	| thousand_term hundred_term ten_term {$$ = $1 + $2 + $3;}
	| thousand_term hundred_term unity_term {$$ = $1 + $2 + $3;}
	| thousand_term hundred_term {$$ = $1 + $2;}
	| thousand_term ten_term unity_term {$$ = $1 + $2 + $3;}
	| thousand_term ten_term {$$ = $1 + $2;}
	| thousand_term unity_term {$$ = $1 + $2;}
	| thousand_term
	| hundred_term ten_term unity_term {$$ = $1 + $2 + $3;}
	| hundred_term ten_term {$$ = $1 + $2;}
	| hundred_term unity_term {$$ = $1 + $2;}
	| hundred_term
	| ten_term unity_term {$$ = $1 + $2;}
	| ten_term
	| unity_term
	| {$$ = 0;}
    ;

thousand_term :THOUSAND
	| thousand_term THOUSAND {$$ = $1 + $2;}    	
	;

hundred_term :  NINE_HUNDRED 
	| FIVE_HUNDRED HUNDRED HUNDRED HUNDRED {$$ = $1 + $2 + $3 + $4;}
	| FIVE_HUNDRED HUNDRED HUNDRED {$$ = $1 + $2 + $3;}
	| FIVE_HUNDRED HUNDRED {$$ = $1 + $2;}
	| FIVE_HUNDRED
	| FOUR_HUNDRED
	| HUNDRED HUNDRED HUNDRED {$$ = $1 + $2 + $3;}
	| HUNDRED HUNDRED {$$ = $1 + $2;}
	| HUNDRED
	;

ten_term : NINETY
	| FIFTY TEN TEN TEN {$$ = $1 + $2 + $3 + $4;}
	| FIFTY TEN TEN {$$ = $1 + $2 + $3;}
	| FIFTY TEN {$$ = $1 + $2;}
	| FIFTY
	| FOURTY
	| TEN TEN TEN {$$ = $1 + $2 + $3;}
	| TEN TEN {$$ = $1 + $2;}
	| TEN
	;	
unity_term : NINE
	| FIVE ONE ONE ONE {$$ = $1 + $2 + $3 + $4;}
	| FIVE ONE ONE {$$ = $1 + $2 + $3;}
	| FIVE ONE {$$ = $1 + $2;}
	| FIVE
	| FOUR
	| ONE ONE ONE {$$ = $1 + $2 + $3;}
	| ONE ONE {$$ = $1 + $2;}
	| ONE
	;

*/	


expr : thousand_term hundred_term ten_term unity_term {$$ = $1 + $2 + $3 + $4;}
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