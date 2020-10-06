%{
    #include "final.tab.h"
    #include "string.h"
	#include <stdlib.h>
	#include "stdbool.h"
    void yyerror();
%}

%%
\t|\r|[ ]              {;}
\n			{;}

[0][0-9]+                  {printf("syntax error\n"); exit(0);}
0                          {yylval.word = strdup(yytext); push(strdup(yytext)); return(number);}
[1-9][0-9]*   {yylval.word = strdup(yytext); push(strdup(yytext)); return(number); }

print-num             {return(print_num);}
print-bool               {return(print_bool);}
define                   {return(define);}
mod                      {push(strdup(yytext)); return(mod);}
and                      {push(strdup(yytext)); return(and);}
or                       {push(strdup(yytext)); return(or);}
not                     {push(strdup(yytext)); return(not);}
fun			{push(strdup(yytext)); return(fun);}
if			{push(strdup(yytext)); return(IF);}

[a-z]([a-z]|[0-9]|[-])*    {yylval.word = strdup(yytext); push(strdup(yytext)); return(id);}

\#t                   {
                                yylval.ival = 1;
                                push(strdup(yytext));
                                return(bool_val);
                            }
\#f                  {
                                yylval.ival= 0;
                                push(strdup(yytext));
                                return(bool_val);
                            }

"("|")"                     {push(strdup(yytext)); return(yytext[0]);}

"+"|"-"|"*"|"/"|">"|"<"|"=" {yylval.word = strdup(yytext); push(strdup(yytext)); return(yytext[0]);}

.                          {printf("syntax error\n"); exit(0);}
%%