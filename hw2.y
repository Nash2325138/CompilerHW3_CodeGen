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
        printf(GREEN "%s" NONE, str);
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
%token For_key
%token While_key
%token Do_key
%token If_key
%token Else_key
%token Switch_key
%token Return_key
%token Break_key
%token Continue_key
%token Case_key
%token Default_key

%type <integer> Int
%type <ident> ID
%type <float_num> Float
%type <float_num> SciNum;

//
%type <char_op> '+' '-' '/' '%' '*'
%type <str_op> '!' '&'
%type <str_op> Right_unary_operator
%type <str_op> Compare_operator
%type <str_op> Or_operator
%type <str_op> And_operator
%type <char_op> Assign_operator

%type <punctuation> ':' ';' ',' '.' '[' ']' '(' ')' '{' '}'

// %left ';'
// %left ','
%right '='
%left Or_operator
%left And_operator
%nonassoc '!' '&'
%left Compare_operator
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS
%nonassoc Right_unary_operator
%left '[' ']'

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

program: program_element_list

program_element_list: mix_declare ';' program_element_list
        | func_definition program_element_list2
program_element_list2: program_element program_element_list2
        | %empty
program_element: mix_declare ';'
        | func_definition


compound_statements: '{' type_id_declare_list stmt_list '}'


mix_declare: func_declare
        | type_id_declare


func_declare: Type_key ID '(' declare_para_list ')'
        | Void_key ID '(' declare_para_list ')'
        | Type_key ID '(' ')'
        | Void_key ID '(' ')'
declare_para_list: declare_para
        | declare_para ',' declare_para_list
declare_para: Type_key ID array_size_list

type_id_declare_list: %empty
        | type_id_declare ';' type_id_declare_list
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


func_definition: func_declare compound_statements 


stmt_list: %empty
        | stmt stmt_list
stmt: simple_stmt ';' {
            print_grammer_used("simple_stmt ';' to stmt\n");
        }
        | if_else_stmt {
            print_grammer_used("if_else_stmt ';' to stmt\n");
        }
        | ';' {
            print_grammer_used("';' to stmt\n");
        }
        | while_stmt {
            print_grammer_used("while_stmt to stmt\n");
        }
        | do_while_stmt {
            print_grammer_used("do_while_stmt to stmt\n");
        }
        | for_stmt {
            print_grammer_used("for_stmt to stmt\n");
        }
        | switch_stmt {
            print_grammer_used("switch_stmt to stmt\n");
        }
        | Return_key expr ';'
        | Break_key ';'
        | Continue_key ';'

simple_stmt: var '=' expr

if_else_stmt: If_key '(' expr ')' compound_statements
        | If_key '(' expr ')' compound_statements Else_key compound_statements

while_stmt: While_key '(' expr ')' compound_statements

do_while_stmt: Do_key compound_statements While_key '(' expr ')' ';'

for_stmt: For_key '(' nullable_expr ';' nullable_expr ';' nullable_expr ')' compound_statements
nullable_expr: expr
        | %empty

switch_stmt: Switch_key '(' ID ')' '{' case_stmt case_list '}'
case_list: case_stmt case_list
        | case_stmt 
        | Default_key ':' stmt_list
case_stmt: Case_key int_char_constant ':' stmt_list
int_char_constant: Int
        | Char


expr: expr '+' expr
        | expr '-' expr 
        | expr '*' expr 
        | expr '/' expr 
        | expr '%' expr 
        | expr And_operator expr 
        | expr Or_operator expr 
        | expr Compare_operator expr
        | '!' expr
        | const_value 
        | '&' var 
        | var Right_unary_operator 
        | '-' expr %prec UMINUS 
        | function_call 
        | var 

const_value: Int
        | Float
        | SciNum
        | True_False
        | String
        | Char

var: ID locate_list
locate_list: '[' expr ']' locate_list
        | %empty

function_call: ID '(' expr_list ')'
        | ID '(' ')'
// para_list: para para_list2
//         | %empty 
// para_list2: ',' para para_list2
//         | %empty
// para: const_value
//         | var

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

