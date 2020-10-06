%{
    #include <stdio.h>
	#include <stdlib.h>
    #include <string.h>
    #include <ctype.h>

	typedef struct{
        char *va;
        int value;
    }dict;
    
    typedef struct{
        char* fun_name;
        dict fun_ids[10];
        dict fun_body[50];
    }func;
    
    void build_fun();
    func func_list[10];
    int func_listP = -1;
    
    void push_id(char*);
    dict funID_queue[10];
    int funID_queue_last = -1;
    
    char* pop();
    void push(char*);
    dict queue[50];
    int queue_pos = -1;
	
	int pop_para();
	void push_para(int);
	int para_queue[10];
	int para_queue_last = -1;

	int define_fun = 0;

    void bind_para(char*);

	int eval(char*);
	
    dict name_dict[10];
	int dict_pos = -1;
	int check = 0;
    void yyerror();
	int find_dict (char*);
	
	void update_vari(int, char*);
	char* last_variable;
	int use_variable = 0;
%}

%code requires {
    typedef struct {
        int num;
        char* name;
    }td;
}

%union{
    int ival;
    char* word;
    td vali;
}

%token <word> number
%token <word> id
%token <ival> bool_val
%token <word> define
%token print_num
%token print_bool
%token mod
%token and
%token or
%token not
%token fun
%token IF

%type <ival> EXP
%type <ival> EXPS
%type <ival> NUM_OP
%type <ival> PLUS
%type <ival> PLUSS
%type <ival> MINUS
%type <ival> MULTIPLY
%type <ival> MULTIPLYS
%type <ival> DIVIDE
%type <ival> MODULUS
%type <ival> GREATER
%type <ival> SMALLER
%type <ival> EQUAL
%type <ival> EQUALS

%type <ival> LOGICAL_OP
%type <ival> AND_OP
%type <ival> AND_OPS
%type <ival> OR_OP
%type <ival> OR_OPS
%type <ival> NOT_OP

%type <ival> IF_EXP
%type <ival> TEST_EXP
%type <ival> THEN_EXP
%type <ival> ELSE_EXP

%type <ival> FUN_EXP
%type <word> FUN_IDs
%type <ival> FUN_BODY
%type <ival> FUN_CALL
%type <word> FUN_NAME
%type <ival> PARAM

%type <vali> VARIABLE
%nonassoc <word> '+'
%nonassoc <word> '-'
%nonassoc <word> '*'
%nonassoc <word> '/'
%nonassoc <word> '>'
%nonassoc <word> '<'
%nonassoc <word> '='

%%
PROGRAM         :STMTS 	{return (0);}
                ;
STMTS           :STMT 
		|STMTS STMT 
                ;

STMT       :EXP
		|DEF_STMT
                |PRINT_STMT
                ;

PRINT_STMT      :'(' print_num EXP ')'      {printf("%d\n", $3);}
              	|'(' print_bool EXP ')'     {
                                                if ($3 == 1)
                                                    printf("#t\n");
                                                else
                                                    printf("#f\n");
                                            }
                ;
                
EXP     :bool_val                   {$$ = $1;}
        	|number                     {$$ = atoi($1); }
		|'-' number			{$$ = 0-atoi($2);}
		|VARIABLE			{$$ = $1.num;}
       		 |NUM_OP			 {//printf("%d\n", $1); 
       		 						$$ = $1;}
		|LOGICAL_OP		{//printf("%d\n", $1); 
								$$ = $1;}
		|IF_EXP				{//printf("%d\n", $1); 
								$$ = $1;}
		|FUN_EXP			{$$ = 123;}
		|FUN_CALL
                ;

NUM_OP :PLUS
		|MINUS
		|MULTIPLY
		|DIVIDE
		|MODULUS
		|GREATER
		|SMALLER
		|EQUAL
                ;

PLUS      :'(' '+' PLUSS EXP ')'	{$$ = $3+$4; 
								        if (use_variable){
									        //update_vari($$, last_variable);
								        }
								
							 }
		|'(' '+' EXP EXP ')'		{	$$ = $3+$4; 
								if (use_variable){
									//update_vari($$, last_variable);
								}
							}
                ;
PLUSS	: EXP EXP			{$$ = $1+$2;}
		|PLUSS EXP			{$$ = $1+$2; }
		;

MINUS	:'(' '-' EXP EXP ')'	{	$$ = $3-$4; 
							if (use_variable){
								//update_vari($$, last_variable);
							}
						}
		;

MULTIPLY 	:'(' '*' MULTIPLYS EXP ')'	{	$$ = $3*$4; 
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			|'(' '*' EXP EXP ')'			{$$ = $3*$4; 
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			;
MULTIPLYS	: EXP EXP				{$$ = $1*$2; }
			|MULTIPLYS EXP			{$$ = $1*$2; }
			;

DIVIDE		:'(' '/' EXP EXP ')'			{
										if ($4 != 0){
											$$ = $3/$4; 
											if (use_variable){
												//update_vari($$, last_variable);
											}
										}
										else{
											printf("Divided by 0!\n");
											exit(0);
											}
									}
			;

MODULUS	:'(' mod EXP EXP ')'		{	$$ = $3%$4;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			;

GREATER		:'(' '>' EXP EXP ')'			{
										if ($3 > $4){
    											$$ = 1;
										}
										else{
										    $$ = 0;
										}
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			;

SMALLER	:'(' '<' EXP EXP ')'			{
										if ($3 < $4){
    											$$ = 1;
										}
										else{
										    $$ = 0;
										}
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			;

EQUAL		:'(' '=' EQUALS EXP ')'		{
										if ($3 == $4)
    											$$ = 1;
										else
										    $$ = 0;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			|'(' '=' EXP EXP ')'			{
										if ($3 == $4)
    											$$ = 1;
										else
										    $$ = 0;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			;

EQUALS		: EXP EXP				{
										if ($1 == $2)
    											$$ = $1;
										else
										    $$ = -123;
									}
			|EQUALS EXP			{
										if ($1 == $2)
    											$$ = $1;
										else
										    $$ = -123;
									}
			;

LOGICAL_OP		: AND_OP
				|OR_OP
				|NOT_OP
				;

AND_OP     	:'(' and AND_OPS EXP ')'	{
										if ($3 == 1 && $4 == 1)
    											$$ = 1;
										else
										    $$ = 0;
										  if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			|'(' and EXP EXP ')'		{
										if ($3 == 1 && $4 == 1)
    											$$ = 1;
										else
										    $$ = 0;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
                	;
AND_OPS	: EXP EXP				{
										if ($1 == 1 && $2 == 1)
    											$$ = 1;
										else
										    $$ = 0;
									}
			|AND_OPS EXP			{
										if ($1 == 1 && $2 == 1)
    											$$ = 1;
										else
										    $$ = 0;
									}
			;
OR_OP     	:'(' or OR_OPS EXP ')'	{
										if ($3 == 1 || $4 == 1)
    											$$ = 1;
										else
										    $$ = 0;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			|'(' or EXP EXP ')'		{
										if ($3 == 1 || $4 == 1)
    											$$ = 1;
										else
										    $$ = 0;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
                	;
OR_OPS	: EXP EXP				{
										if ($1 == 1 || $2 == 1)
    											$$ = 1;
										else
										    $$ = 0;
									}
			|OR_OPS EXP			{
										if ($1 == 1 || $2 == 1)
    											$$ = 1;
										else
										    $$ = 0;
									}
			;
NOT_OP		:'(' not EXP ')'				{
										if ($3==1)
											$$ = 0;
										else
											$$ = 1;
										if (use_variable){
											//update_vari($$, last_variable);
										}
									}
			;

DEF_STMT	:'(' define VARIABLE EXP ')'		{
											if (check != -123){
												printf("Redefining is not allowed.\n");
												exit(0);
											}
											else{
												$3.num = $4;
												dict_pos++;
												name_dict[dict_pos].va = $3.name ;
												name_dict[dict_pos].value = $4;
												if (define_fun){
													func_list[func_listP].fun_name = $3.name;
													define_fun = 0;
												}
											}
										}
			;
VARIABLE	:id						{
										check = find_dict($1);
										if (check != -123){
											$$.name = $1;
											$$.num = name_dict[check].value;
											use_variable = 1;
											last_variable = $1;
										}
										else{
										$$.name = $1;
										//dict_pos++;
										//name_dict[dict_pos].va = $1 ;
										//name_dict[dict_pos].value = 0;
										//$$.name = $1;
										//$$.num = 0;
										}
									}
			;

IF_EXP		:'(' IF TEST_EXP THEN_EXP ELSE_EXP ')'	{
													if ($3)
														$$ = $4;
													else
														$$ = $5;
												}
			;
TEST_EXP	:EXP
			;
THEN_EXP	:EXP
			;
ELSE_EXP	:EXP
			;
			
FUN_EXP	:'(' fun FUN_IDs EXP ')'		{
								//int i;
								//for (i=0; i<queue_pos; i++){
								//printf("%s ", queue[i].va);
								//}
                                build_fun();
								define_fun = 1;
								}
			;
FUN_IDs		:'(' FUN_IDs id ')'         {push_id($3);}
			|'(' id ')'                 {push_id($2);}
			|FUN_IDs id		{push_id($2);}
			|id                         {push_id($1);}
			|'(' ')'
			; 

			
PARAM   :EXP		{push_para($1);}
		|PARAM EXP	{push_para($2);}
		;

FUN_NAME	:id		{$$ = $1;}
			;

FUN_CALL    :'(' FUN_EXP PARAM ')'	{
                                        				bind_para("nan");
                                       					 int i;
								   int result=0;
								   result = eval("nan");
								    $$ = result;
									define_fun = 0;
								}
			|'(' FUN_NAME PARAM ')'	{
										bind_para($2);

										int i;
										int result=0;
								   		result = eval($2);
								    	$$ = result;
									}
		|'(' FUN_NAME ')'				{
										int i;
										int result=0;
								   		result = eval($2);
								    	$$ = result;
									}
            ;
%%

void yyerror(){
    printf("syntax error\n");
}

int find_dict (char *to_find){
	int found = 0;
	int i = 0;
	for (i=0; i<=dict_pos; i++){
		if (!strcmp(name_dict[i].va,to_find)){
			found = 1;
			break;
		}
	}
	if (found)
		return i;
	else
		return -123;
}

void update_vari(int new_num, char *to_check){
	int pos = find_dict(to_check);
	name_dict[pos].value = new_num;
	use_variable = 0;
}

int main(){
    yyparse();
    return 0;
}

char* pop(){
    return "aa";
}

void push(char* to_psuh){
    ++queue_pos;
    queue[queue_pos].va = to_psuh;
    queue[queue_pos].value = 0;
}

int pop_para(){
	return para_queue[para_queue_last--];
}
void push_para(int to_psuh){
	para_queue[++para_queue_last] = to_psuh;
}

void push_id(char * to_psuh){
    ++funID_queue_last;
    funID_queue[funID_queue_last].va = to_psuh;
    funID_queue[funID_queue_last].value = 0;
}

void bind_para(char *to_bind_func){
    int i;
	if (!strcmp(to_bind_func, "nan")){
		for (i=0; i<=para_queue_last; i++){
			func_list[func_listP].fun_ids[i].value = para_queue[i];
    		}
	}
	else
	{
		int kk = find_fun(to_bind_func);
		//printf("%d", kk);
		for (i=0; i<=para_queue_last; i++){
			func_list[kk].fun_ids[i].value = para_queue[i];
    	}
	}
    
}

void build_fun(){
    func_listP++;
	func_list[func_listP].fun_name = "nan";

    int i;
    for (i=0; i<=funID_queue_last; i++){
        func_list[func_listP].fun_ids[i] = funID_queue[i];
    }

    int lp_num = 0;
    int rp_num = 0;
     
    for (i=queue_pos-1; i>=0; i--){
        if(!strcmp(queue[i].va, "("))
            lp_num++;
        else if (!strcmp(queue[i].va, ")"))
            rp_num++;
        if (rp_num == lp_num)
           break;
    }
    
	int j=0;
    for (i; i<queue_pos; i++){
    //printf("%s ", queue[i].va);
        func_list[func_listP].fun_body[j++] = queue[i];
    }
    
}


int checktype(char *to_check){
	if (!strcmp(to_check,"+") || !strcmp(to_check,"-") || !strcmp(to_check,"*")
	|| !strcmp(to_check,"/")|| !strcmp(to_check,">")|| !strcmp(to_check,"<")|| !strcmp(to_check,"=")
	|| !strcmp(to_check,"mod")|| !strcmp(to_check,"and")|| !strcmp(to_check,"or")|| !strcmp(to_check,"not")
	|| !strcmp(to_check,"if"))
		return 1;
	else
		return 0;
}


int find_para(char *func_name, char *to_find){
	int i;
	if (!strcmp(func_name, "nan")){
		for (i=0; i<=funID_queue_last; i++){
			if (!strcmp(func_list[func_listP].fun_ids[i].va, to_find))
				break;
		}
		return func_list[func_listP].fun_ids[i].value;
	}
	else{
		int kk = find_fun(func_name);
		for (i=0; i<=funID_queue_last; i++){
			if (!strcmp(func_list[kk].fun_ids[i].va, to_find))
				break;
		}
		return func_list[kk].fun_ids[i].value;
	}
	
	return -123;
}

int find_fun(char *to_find){
	int k;
	//printf("%s", func_list[1].fun_name);
	for(k=0; k<=func_listP; k++){
		if (!strcmp(func_list[k].fun_name, to_find))
			break;
	}
	return k;
}

int eval(char *func_name){
	typedef struct{
        char *va;
    }stack;
	stack operator[20];
	int operatorP = -1;

	int operand[10][20];
	int operandSP = 0;
	int per_operandP[10] = {-1};

	stack functions[50];
	int functionsP = -1;
	
	if (!strcmp(func_name, "nan")){
		int i;
		for (i=0; i<50 && func_list[func_listP].fun_body[i].va!=NULL; i++){
        	if (checktype(func_list[func_listP].fun_body[i].va)){
				operator[++operatorP].va = func_list[func_listP].fun_body[i].va;
			}
			else{
				functions[++functionsP].va = func_list[func_listP].fun_body[i].va;
				}
    	}
	}
	else{
		int target_fun = find_fun(func_name);
		if (target_fun == -123){
			printf("function doesn't exist.");
		}
		int i;
		for (i=0; i<50 && func_list[target_fun].fun_body[i].va!=NULL; i++){
        	if (checktype(func_list[target_fun].fun_body[i].va)){
				operator[++operatorP].va = func_list[target_fun].fun_body[i].va;
			}
			else{
				functions[++functionsP].va = func_list[target_fun].fun_body[i].va;
				}
		}
	}
	int i;
	for (i=0; i<=operatorP; i++){
		//printf("%s ", operator[i].va);
	}

	for (i=functionsP; i>=0; i--){
		if (!strcmp(functions[i].va, ")")){
			operandSP++;
		}
		else if(!strcmp(functions[i].va, "(")){
			int temp = 0;
			int j;
			if (!strcmp(operator[operatorP].va,"+")){
				//printf("%d", per_operandP[operandSP]);
				for(j=per_operandP[operandSP]; j>0; j--){
					//printf("%d ", operand[operandSP][j]);
					temp += operand[operandSP][j];
					}
					//printf("%d %d",operandSP, per_operandP[operandSP]);
				per_operandP[operandSP] = -1;
			}
			else if(!strcmp(operator[operatorP].va,"-")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				int b = operand[operandSP][per_operandP[operandSP]--];
				temp = a-b;
			}
			else if(!strcmp(operator[operatorP].va,"*")){
				temp = 1;
				for(j=per_operandP[operandSP]; j>0; j--)
					temp *= operand[operandSP][j];
				per_operandP[operandSP] = -1;
			}
			else if(!strcmp(operator[operatorP].va,"/")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				int b = operand[operandSP][per_operandP[operandSP]--];
				temp = a/b;
			}
			else if(!strcmp(operator[operatorP].va,"mod")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				int b = operand[operandSP][per_operandP[operandSP]--];
				temp = a%b;
			}
			else if(!strcmp(operator[operatorP].va,">")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				int b = operand[operandSP][per_operandP[operandSP]--];
				if (a>b)
					temp = 1;
				else
					temp = 0;
			}
			else if(!strcmp(operator[operatorP].va,"<")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				int b = operand[operandSP][per_operandP[operandSP]--];
				if (a<b)
					temp = 1;
				else
					temp = 0;
			}
			else if(!strcmp(operator[operatorP].va,"=")){
				int equal = 1;
				temp = operand[operandSP][per_operandP[operandSP]];
				for(j=per_operandP[operandSP]-1; j>0; j--){
					if (temp != operand[operandSP][j]){
						equal = 0;
						break;
					}
				}
				if (equal)
					temp = 1;
				else
					temp = 0;
				per_operandP[operandSP] = -1;
			}
			else if(!strcmp(operator[operatorP].va,"and")){
				int and = 1;
				for(j=per_operandP[operandSP]; j>0; j--){
					if (!operand[operandSP][j]){
						and = 0;
						break;
					}
				}
				if (and)
					temp = 1;
				else
					temp = 0;
				per_operandP[operandSP] = -1;
			}
			else if(!strcmp(operator[operatorP].va,"or")){
				int or = 0;
				for(j=per_operandP[operandSP]; j>0; j--){
					if (operand[operandSP][j]){
						or = 1;
						break;
					}
				}
				if (or)
					temp = 1;
				else
					temp = 0;
				per_operandP[operandSP] = -1;
			}
			else if(!strcmp(operator[operatorP].va,"not")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				if (a)
					temp = 0;
				else
					temp = 1;
			}
			else if(!strcmp(operator[operatorP].va,"if")){
				int a = operand[operandSP][per_operandP[operandSP]--];
				int b = operand[operandSP][per_operandP[operandSP]--];
				int c = operand[operandSP][per_operandP[operandSP]--];
				if (a)
					temp = b;
				else
					temp = c;
			}
			operatorP--;
			operandSP--;
			//printf("%d %d",operandSP, per_operandP[operandSP]);
			operand[operandSP][++per_operandP[operandSP]] = temp;
		}
		else{
			if (isalpha(functions[i].va[0])){
				int temp = 0;
				if (!strcmp(func_name, "nan"))
					temp = find_para("nan", functions[i].va);
				else{
					temp = find_para(func_name, functions[i].va);
					}
				operand[operandSP][++per_operandP[operandSP]] = temp;
			}
			else{
				operand[operandSP][++per_operandP[operandSP]] = atoi(functions[i].va);
			}
		}
	}
	//printf("%d", operand[0][0]);
	para_queue_last = -1;
	funID_queue_last = -1;
	queue_pos = -1;
	return operand[0][0];
}
