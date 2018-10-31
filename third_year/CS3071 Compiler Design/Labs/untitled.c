^(M*)(D?C{0,3}|CM|CD)(L?X{0,3}|XC|XL)(V?I{0,3}|IX|IV)$	{ 	
															str_len = strlen(yytext);
															for(int i=0; i<str_len; i++)
															{
																switch (yytext[i])
																{
																	case 'M':
																		yylval = 1000;
																		return THOUSAND;
																		break;
																	case 'D':
																		yylval = 500;
																		return FIVE_HUNDRED;
																		break;
																	case 'C':
																		if(yytext[i+1] == 'M')
																		{
																			yylval = 900;
																			return NINE_HUNDRED;
																			i++;
																		}		
																		else if(yytext[i+1] == 'D')
																		{
																			yylval = 400;
																			return FOUR_HUNDRED;
																			i++;
																		}
																		else
																		{
																			yylval = 100;
																			return HUNDRED;
																		}
																		break;
																	case 'L':
																		yylval = 50;
																		return FIFTY;
																		break;	
																	case 'X':
																		if(yytext[i+1] == 'C')
																		{
																			yylval = 90;
																			return NINETY;
																			i++;
																		}
																		else if(yytext[i+1] == 'L')
																		{
																			yylval = 40;
																			return FOURTY;
																			i++;
																		}
																		else
																		{
																			yylval = 10;
																			return TEN;
																		}	
																		break;
																	case 'V':
																		yylval = 5;
																		return FIVE;
																		break;
																	case 'I':
																		if(yytext[i+1] == 'X')
																		{
																			yylval = 9;
																			return NINE;
																			i++;
																		}
																		else if(yytext[i+1] == 'V')
																		{
																			yylval = 4;
																			return FOUR;
																			i++;
																		}		
																		else
																		{
																			yylval = 1;
																			return ONE;
																		}
																		break;
																	default:
																		break;	
																}
															}	
														}