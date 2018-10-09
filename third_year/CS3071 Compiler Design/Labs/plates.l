%{
int CURRENT_YEAR = 2018;
int string_length;
int year;
char s[2];
int invalid_registration;
%}
YEAR [0-9]{2,3}
COUNTY C|CE|CN|CW|D|DL|G|KE|KK|KY|L|LD|LH|LK|LM|LS|MH|MN|MO|OY|RN|SO|T|TN|TS|W|WD|WH|WX|WW
NUMBER [0-9]{1,6}
%%
{YEAR}\-{COUNTY}\-{NUMBER}[\t ]*	{ 	invalid_registration = 0;
								if( yytext[2] == '-')
								{
									year = (yytext[0]-'0')*10 + (yytext[1]-'0');
									if(year < 13) year = 2000 + year;
									else if(year <= 99 && year >= 87) year = 1900 + year;
									else invalid_registration = 1;
									if( yytext[4] == '-' && yytext[3] == 'T') invalid_registration = 1;
									if(!invalid_registration) printf("%d\n", CURRENT_YEAR - year);
								}
								else
								{
									year = (yytext[0]-'0') * 100 + (yytext[1]-'0') * 10 + (yytext[2]-'0');
									if( (yytext[2]-'0') != 1 && (yytext[2]-'0') != 2) invalid_registration = 1;
									year = year / 10;
									if( year < 13 || year > 18) invalid_registration = 1;
									year = 2000 + year;
									s[0] = yytext[4];
									s[1] = yytext[5];
									if ( year == 2013 && yytext[4] == 'T' && yytext[5] == '-') invalid_registration = 1;
									else if (strcmp(s, "LK") == 0 || strcmp(s, "TN") == 0 || strcmp(s, "TS") == 0 || strcmp(s, "WD") == 0) 
										invalid_registration = 1;
									if(!invalid_registration) printf("%d\n", CURRENT_YEAR - year);
								}	
								if (invalid_registration) printf("INVALID\n");
							}

[\n\t] {}
[^\n\t]* {printf("INVALID\n");}

%%

int main()
{
	yylex();
	return 0;
}