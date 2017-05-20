%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    #define GREEN "\033[0;32;32m"
    #define NONE "\033[m"

    extern char* yytext;
    extern int lineCount;
    extern char lineStr[10000];
    int yylex();
    int yyerror(char *msg);
    void print_grammer_used(const char* str) {
        // printf(GREEN "%s" NONE, str);
    }
%}

%start program
%union { 
    int integer;
    double float_num;
    char punctuation;
    char char_op;
    char str_op[100];

    char ident[100];
    char char_specify[100];
    char str_specify[100];
}
%token ID
%token Keyword
%token Punctuation
%token Int
%token Float
%token SciNum
%token Char
%token String
%token '+' '-' '/' '%' '*'
%token Left_unary_operator
%token Right_unary_operator
%token Compare_operator
%token Or_operator
%token And_operator
%token Assign_operator
%token Type_key
%token Void_key
%token Const_key
%token True_False

%type <integer> Int
%type <ident> ID
%type <float_num> Float
%type <float_num> SciNum;

//
%type <char_op> '+' '-' '/' '%' '*'
%type <str_op> Left_unary_operator
%type <str_op> Right_unary_operator
%type <str_op> Compare_operator
%type <str_op> Or_operator
%type <str_op> And_operator
%type <char_op> Assign_operator

%type <punctuation> ':' ';' ',' '.' '[' ']' '(' ')' '{' '}'

%left Or_operator
%left And_operator
%nonassoc Left_unary_operator
%left Compare_operator
%right '='
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS
%nonassoc Right_unary_operator

// %left SCSPEC TYPESPEC TYPEMOD
// %left  ','
// %right '='
// %right ASSIGN 
// %left OROR
// %left ANDAND
// %left EQCOMPARE
// %left ARITHCOMPARE  '>' '<' 
// %left '+' '-'
// %left '*' '/' '%'
// %right UNARY

%%

program: mix_declare_list
| %empty



mix_declare_list: mix_declare ';'
| mix_declare ';' mix_declare_list

mix_declare: func_declare
| type_id_declare
| const_id_declare



func_declare: Type_key ID '(' declare_para_list ')'
| Type_key ID '(' ')'

declare_para_list: declare_para
| declare_para ',' declare_para_list

declare_para: Type_key ID array_size_list


// type_id_declare_list: type_id_declare ';'
// | type_id_declare ';' type_id_declare_list

type_id_declare: Type_key id_declare_list
| Const_key Type_key const_id_declare_list



const_id_declare_list: const_id_declare ',' const_id_declare_list
| const_id_declare

const_id_declare: ID const_ID_inital
| ID '[' Int ']' array_size_list const_array_initial

const_ID_inital: '=' expr
const_array_initial: '=' '{' expr_list '}'
| '=' '{' '}'



id_declare_list: id_declare ',' id_declare_list
| id_declare

id_declare: ID ID_inital
| ID '[' Int ']' array_size_list array_initial

ID_inital: %empty
| '=' expr


array_size_list: '[' Int ']' array_size_list
| %empty

array_initial: %empty
| '=' '{' expr_list '}'
| '=' '{' '}'

expr_list: expr ',' expr_list
| expr



expr: expr '+' expr{print_grammer_used("(expr '+' expr to expr)\n");}
| expr '-' expr {print_grammer_used("(expr '-' expr to expr)\n");}
| expr '*' expr {print_grammer_used("(expr '*' expr to expr)\n");}
| expr '/' expr {print_grammer_used("(expr '/' expr to expr)\n");}
| expr '%' expr {print_grammer_used("(expr '%%' expr to expr)\n");}
| expr And_operator expr {print_grammer_used("(expr && expr to expr)\n");}
| expr Or_operator expr {print_grammer_used("(expr || expr to expr)\n");}
| const_value {print_grammer_used("(const_value to expr)\n");}
| Left_unary_operator var {}
| var Right_unary_operator {}
| '-' expr %prec UMINUS {}
| function_call {print_grammer_used("(function_call to expr)\n");}
| var {print_grammer_used("(var to expr)\n");}

const_value: Int
| Float
| SciNum
| True_False
| String
| Char

var: ID locate_list

locate_list: '[' expr ']' locate_list
| %empty

function_call: ID '(' para_list ')'

para_list: para para_list2
| %empty 

para_list2: ',' para para_list2
| %empty

para: const_value
| var

%%

int main(void)
{
    yyparse();
    printf("No syntax error\n");
    return 0;
}

int yyerror(char *msg){
    fprintf(stderr, "*** Error at line %d: %s\n", lineCount, lineStr);
    fprintf(stderr, "\n" );
    fprintf(stderr, "Unmatched token: %s\n", yytext);
    fprintf(stderr, "*** syntax error\n");
    exit(-1);
}

