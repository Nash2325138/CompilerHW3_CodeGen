%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"
    #include "symbol_table.h"
    #define GREEN "\033[0;32;32m"
    #define NONE "\033[m"

    extern char* yytext;
    extern int lineCount;
    extern char lineStr[10000];

    FILE* f_asm;
    extern int cur_scope;
    extern int cur_counter;
    extern int cur_offset;
    int cur_label = 0;
    void add_label() {
        fprintf(f_asm, "L%d:\n", cur_label++);
    }

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
%token Function_key

%token DigitalWrite
%token LOW
%token HIGH
%token Delay

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

program: { fprintf(f_asm, "\n# ---- Program start\n");
           fprintf(f_asm, "swi\t$fp,\t[$sp]\n");
           fprintf(f_asm, "addi\t$sp,\t$sp,\t-4\n");
           fprintf(f_asm, "addi\t$fp,\t$sp,\t0\n");} program_element_list {
    fprintf(f_asm, "# ---- Program stop\n");
    fprintf(f_asm, "addi\t$sp,\t$fp,\t4\n");
    fprintf(f_asm, "lwi\t$fp,\t[$sp]\n");
}

program_element_list: mix_declare ';' program_element_list
        | func_definition program_element_list2
program_element_list2: program_element program_element_list2
        | 
program_element: mix_declare ';'
        | func_definition


compound_statements: '{' {cur_scope++;} type_id_declare_list stmt_list '}' {
    pop_up_symbol(cur_scope);
    cur_scope--;
}


mix_declare: func_declare
        | type_id_declare


func_declare: Type_key func_ID '(' declare_para_list ')'
        | Void_key func_ID '(' declare_para_list ')'
        | Type_key func_ID '(' ')'
        | Void_key func_ID '(' ')'
func_ID: ID
        | Function_key
declare_para_list: declare_para
        | declare_para ',' declare_para_list
declare_para: Type_key ID array_size_list

type_id_declare_list: 
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
id_declare: ID {
            install_symbol($1);
        }
        | ID { install_symbol($1); } '=' expr {
            assign_symbol_to_top($1);
            stack_pop_word();
        }
        | ID '[' Int ']' array_size_list array_initial
// ID_inital: 
//         | '=' expr {
//             fprintf(f_asm, "Addi [$fp+(some_number)], $r0\n");
//         }


array_size_list: '[' Int ']' array_size_list
        | 
array_initial: 
        | '=' '{' expr_list '}'
        | '=' '{' '}'
expr_list: expr ',' expr_list
        | expr


func_definition: func_declare compound_statements 


stmt_list: 
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
        | function_call ';'

        | DigitalWrite '(' Int ',' HIGH ')' ';' {
            fprintf(f_asm, "# ---- DigitalWrite HIGH\n");
            fprintf(f_asm, "movi\t$r0,\t13\n");
            fprintf(f_asm, "movi\t$r1,\t1\n");
            fprintf(f_asm, "bal\tdigitalWrite\n");
        }
        | DigitalWrite '(' Int ',' LOW ')' ';'{
            fprintf(f_asm, "# ---- DigitalWrite LOW\n");
            fprintf(f_asm, "movi\t$r0,\t13\n");
            fprintf(f_asm, "movi\t$r1,\t0\n");
            fprintf(f_asm, "bal\tdigitalWrite\n");
        }
        | Delay '(' ID ')' ';' {
            fprintf(f_asm, "# ---- Delay %s\n", $3);
            fprintf(f_asm, "lwi\t$r0,\t[$fp+(%d)]\n", get_offset($3));
            fprintf(f_asm, "bal\tdelay\n");
        }

simple_stmt: ID '=' expr {
    assign_symbol_to_top($1);
    stack_pop_word();
}
| ID locate_list '=' expr{

}

if_else_stmt: If_key '(' expr ')' {
    fprintf(f_asm, "# ---- Branching to L%d if(expr) not success\n", cur_label);
    fprintf(f_asm, "lwi\t$r0,\t[$sp+4]\n");
    stack_pop_word();
    fprintf(f_asm, "beqz\t$r0,\tL%d\n", cur_label);
} compound_statements nullable_else

nullable_else: {
    add_label();
}
| Else_key {
    fprintf(f_asm, "# ---- Jumping through L%d to L%d\n", cur_label, cur_label+1);
    fprintf(f_asm, "J\tL%d\n", cur_label+1);
    add_label();
} compound_statements {
    add_label();
}

while_stmt: While_key {
    fprintf(f_asm, "# ---- While starts\n");
    add_label();
} '(' expr ')' {
    fprintf(f_asm, "# ---- break out while loop if expr is true\n");
    fprintf(f_asm, "lwi\t$r0,\t[$sp+4]\n");
    stack_pop_word();
    fprintf(f_asm, "beqz\t$r0,\tL%d\n", cur_label);
} compound_statements {
    fprintf(f_asm, "j L%d\n", cur_label-1);
    add_label();
    fprintf(f_asm, "# ---- While ends\n");
}

do_while_stmt: Do_key compound_statements While_key '(' expr ')' ';'

for_stmt: For_key '(' nullable_expr ';' nullable_expr ';' nullable_expr ')' compound_statements
nullable_expr: expr
        | 

switch_stmt: Switch_key '(' ID ')' '{' case_stmt case_list '}'
case_list: case_stmt case_list
        | case_stmt 
        | Default_key ':' stmt_list
case_stmt: Case_key int_char_constant ':' stmt_list
int_char_constant: Int
        | Char


expr: expr '+' expr {
            fprintf(f_asm, "# ----  '+' top two word on stack([$sp+8] + [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");
            fprintf(f_asm, "add\t$r0,\t$r0,\t$r1\n");
            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr '-' expr {
            fprintf(f_asm, "# ----  '-' top two word on stack([$sp+8] - [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");
            fprintf(f_asm, "sub\t$r0,\t$r0,\t$r1\n");
            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr '*' expr {
            fprintf(f_asm, "# ----  '*' top two word on stack([$sp+8] * [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");
            fprintf(f_asm, "mul\t$r0,\t$r0,\t$r1\n");
            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr '/' expr {
            fprintf(f_asm, "# ----  '/' top two word on stack([$sp+8] / [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");
            fprintf(f_asm, "divsr\t$r0,\t$r1,\t$r0,\t$r1\n");
            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr '%' expr {
            fprintf(f_asm, "# ----  '/' top two word on stack([$sp+8] %% [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");
            fprintf(f_asm, "divsr\t$r0,\t$r1,\t$r0,\t$r1\n");
            fprintf(f_asm, "swi\t$r1,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr And_operator expr  {
            fprintf(f_asm, "# ----  '&&' top two word on stack([$sp+8] && [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");

            set_if_not_zero("$r0");
            set_if_not_zero("$r1");
            fprintf(f_asm, "and\t$r0,\t$r0,\t$r1\n");

            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr Or_operator expr  {
            fprintf(f_asm, "# ----  '||' top two word on stack([$sp+8] && [$sp+4]) and store at [$sp+8]\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");

            set_if_not_zero("$r0");
            set_if_not_zero("$r1");
            fprintf(f_asm, "or\t$r0,\t$r0,\t$r1\n");

            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | expr Compare_operator expr {
            
            fprintf(f_asm, "lwi\t$r0,\t[$sp+8]\n");
            fprintf(f_asm, "lwi\t$r1,\t[$sp+4]\n");
            if (strcmp($2, ">") == 0) {
                fprintf(f_asm, "# ----  compare if $r0 > $r1\n");
                fprintf(f_asm, "slts $r0, $r1, $r0\n");
            } else if (strcmp($2, "<") == 0) {
                fprintf(f_asm, "# ----  compare if $r0 < $r1\n");
                fprintf(f_asm, "slts $r0, $r0, $r1\n");
            } else {
                if (strcmp($2, "==") == 0) {
                    fprintf(f_asm, "# ----  compare if $r0 == $r1\n");
                    fprintf(f_asm, "slts $r2, $r0, $r1\n");
                    fprintf(f_asm, "slts $r3, $r1, $r0\n");

                    set_if_zero("$r2");
                    set_if_zero("$r3");

                    fprintf(f_asm, "and $r0, $r2, $r3\n");
                }
                else if (strcmp($2, "!=") == 0) {
                    fprintf(f_asm, "# ----  compare if $r0 != $r1\n");
                    fprintf(f_asm, "slts $r2, $r0, $r1\n");
                    fprintf(f_asm, "slts $r3, $r1, $r0\n");

                    fprintf(f_asm, "or $r0, $r2, $r3\n");
                }
                else if (strcmp($2, "<=") == 0) {
                    fprintf(f_asm, "# ----  compare if $r0 <= $r1\n");
                    fprintf(f_asm, "slts $r0, $r1, $r0\n");
                    set_if_zero("$r0");
                }
                else if (strcmp($2, ">=") == 0) {
                    fprintf(f_asm, "# ----  compare if $r0 >= $r1\n");
                    fprintf(f_asm, "slts $r0, $r0, $r1\n");
                    set_if_zero("$r0");
                }  
            } 
            fprintf(f_asm, "# ---- Store the compared result in [$sp+8]\n");
            fprintf(f_asm, "swi\t$r0,\t[$sp+8]\n");
            stack_pop_word();
        }
        | '!' expr {
            fprintf(f_asm, "# ----  '!' top one word on stack(![$sp+4])\n");
            fprintf(f_asm, "lwi\t$r0,\t[$sp+4]\n");
            set_if_zero("$r0");
            fprintf(f_asm, "swi\t$r0,\t[$sp+4]\n");
        }
        | const_value 
        | '&' var 
        | var Right_unary_operator 
        | '-' expr %prec UMINUS 
        | function_call 
        | var 
        | '(' expr ')'

const_value: Int {
    push_int_to_stack($1);
}
        | Float
        | SciNum
        | True_False
        | String
        | Char

var: ID locate_list
   | ID {
        push_symbol_to_stack($1);
   }
locate_list: '[' expr ']' locate_list
        | '[' expr ']'

function_call: func_ID '(' expr_list ')'
        | func_ID '(' ')'
// para_list: para para_list2
//         |  
// para_list2: ',' para para_list2
//         | 
// para: const_value
//         | var

%%

int main(void)
{
    if ((f_asm = fopen("assembly", "w")) == NULL) {
        perror("f_asm open error");
    }
    init_symbol_table();
    yyparse();
    printf("No syntax error\n");
    fclose(f_asm);
    return 0;
}

int yyerror(char *msg){
    fprintf(stderr, "*** Error at line %d: %s\n", lineCount, lineStr);
    fprintf(stderr, "\n" );
    fprintf(stderr, "Unmatched token: %s\n", yytext);
    fprintf(stderr, "*** syntax error\n");
    exit(-1);
}

