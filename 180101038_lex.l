%{ 

#include <bits/stdc++.h>
#include "180101038_yacc.tab.h" /* Include the token definitions and union structur*/

using namespace std;

extern void error(char *s);




%}

%option noyywrap
%option yylineno


%%


"PROGRAM" 			{return t_PROGRAM;}
"VAR" 				{return t_VAR;}
"BEGIN" 			{return t_BEGIN;}
"END"				{return t_END;}
"END."          	{return t_END_DOT;}
"INTEGER"         	{return t_INT_TYPE;}
"REAL"				{return t_REAL_TYPE;}
"FOR" 				{return t_FOR;}	
"READ" 				{return t_READ;}
"WRITE" 				{return t_WRITE;}
"TO"  				{return t_TO;}
"DO" 					{return t_DO;}
";" 				{return t_SEMICOLON;}
":" 				{return t_COLON;}
"," 				{return t_COMMA;}
":="  				{return t_ASSIGN;}
"+" 				{return t_PLUS;}
"-" 				{return t_MINUS;}
"*" 				{return t_MULT;}
"DIV" 				{return t_DIV;}
"(" 				{return t_OPEN_BRACKET;}
")"					{return t_CLOSE_BRACKET;}

[0-9]+				{ string temp(yytext);
						yylval.ival =stoi(temp);
						return t_INT;}

[A-Z]([A-Z0-9])* 	{yylval.sval = (char *)malloc(yyleng + 1);strcpy(yylval.sval, yytext);return t_ID;}

[0-9]+"."[0-9]+		{ string temp(yytext);yylval.dval = stof(temp);return t_REAL;}

[\t]				{}
" "					{}
"\n"				{}
.					{error(yytext);}/* If no rules matched then it's a foregin character*/


%%


