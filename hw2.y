%{
    #include <stdio.h>
    #include <stdlib.h>
    #define GREEN "\033[0;32;32m"
    #define NONE "\033[m"
    extern char* yytext;
    extern int lineCount;
    extern char* lineStr;
    int yylex();
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
%token Unary_operator
%token Compare_operator
%token Or_operator
%token And_operator
%token Assign_operator

%type <integer> Int
%type <ident> ID
%type <float_num> Float
%type <float_num> SciNum;

//
%type <char_op> '+' '-' '/' '%' '*'
%type <str_op> Unary_operator
%type <str_op> Compare_operator
%type <str_op> Or_operator
%type <str_op> And_operator
%type <char_op> Assign_operator

%type <punctuation> ':' ';' ',' '.' '[' ']' '(' ')' '{' '}'

%left ';'
%left ID

%left '+' '-'
%left '*' '/'
%left '%'
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

program: expr {
    print_grammer_used("(Reduce expr to program)\n");
}
expr: expr '+' expr{
    print_grammer_used("(Reduce expr '+' expr to expr)\n");
}
| expr '-' expr {
    print_grammer_used("(Reduce expr '-' expr to expr)\n");
}
| expr '*' expr {
    print_grammer_used("(Reduce expr '*' expr to expr)\n");
}
| expr '/' expr {
    print_grammer_used("(Reduce expr '/' expr to expr)\n");
}
| expr '%' expr {
    print_grammer_used("(Reduce expr '%%' expr to expr)\n");
}
| Int {
    print_grammer_used("(Reduce Int to expr)\n");
}
| ID {
    print_grammer_used("(Reduce ID to expr)\n");
}

%%

int main(void)
{
    yyparse();
    printf("No syntax error\n");
    return 0;
}

int yyerror(char *msg){
    fprintf( stderr, "*** Error at line %d: %s\n", lineCount, lineStr);
    fprintf( stderr, "\n" );
    fprintf( stderr, "Unmatched token: %s\n", yytext);
    fprintf( stderr, "*** syntax error\n");
    exit(-1);
}

