%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "parser.tab.h"

int nbrLine = 1;

void verifieLength(){
        if ( yyleng <= 10 ) return;
        else {printf("Line: %d , IDF LENGTH > 10 ",nbrLine);
             exit(EXIT_FAILURE);}
}

%}

digit [0-9]
char [a-zA-Z]

number (("-"{digit})|{digit})+
floatNum {number}"."{digit}+
boolC "true"|"false"

biOp "+"|"-"|"*"|"/"
compOp "=="|"<"|">"|"<="|">="

str {digit}|{char}
idf [A-Z]({str}|"_"{str})+

%%
[ \t] ;
[\n] {nbrLine = nbrLine + 1; }

"begin"  { yylval.strV = strdup(yytext); return BEG;}
"end"    { yylval.strV = strdup(yytext); return END;}

"if"     { yylval.strV = strdup(yytext); return IF;}
"else"   { yylval.strV = strdup(yytext); return ELSE;}
"for"    { yylval.strV = strdup(yytext); return FOR;}
"while"  { yylval.strV = strdup(yytext); return WHILE;}

"int"    { yylval.strV = strdup(yytext); return INT;}
"float"  { yylval.strV = strdup(yytext); return FLOAT;}
"bool"   { yylval.strV = strdup(yytext); return BOOL;}
"const"  { yylval.strV = strdup(yytext); return CONST;}

{digit}  { yylval.intV = atoi(yytext); return DIG;}
{number} { yylval.intV = atoi(yytext); return NUMBER;}

{floatNum} { yylval.floatV = strtof(yytext, NULL); return FLOATnum;}
{boolC} { yylval.strV = strdup(yytext); return BOOLc;}
{char}  { yylval.strV = strdup(yytext); return CHAR;}

{idf}   { verifieLength();
        yylval.strV = strdup(yytext); return IDF;}

{biOp} { yylval.strV = strdup(yytext); return OP;}
{compOp} { yylval.strV = strdup(yytext); return COMP;}

";"     { yylval.strV = strdup(yytext); return SEMI;}
"="     { yylval.strV = strdup(yytext); return EQ;}

"("     { yylval.strV = strdup(yytext); return LP;}
")"     { yylval.strV = strdup(yytext); return RP;}
"{"     { yylval.strV = strdup(yytext); return LC;}
"}"     { yylval.strV = strdup(yytext); return RC;}

.       {printf("SYNTAX ERROR .. EXIT ..");exit(0);}

%%

int yywrap(){
    return 1;
};
