%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  char lineStr[10000];
  int lineCount = 1;
  int source = 1;
  int token = 1;

  int sameLine = 1;
  enum{state_pragma, state_line, state_zero};
  int last_state;

  int pragma_pieces;
  enum{turn_none, turn_source, turn_token};
  int turn;
  int turn_on;

  void errorExit() {
    fprintf(stderr, "Error at line %d: %s\n", lineCount, yytext);
    exit(1); 
  }
  void printLine() {
    if (lineStr[strlen(lineStr)-1] != '\n') {
      strcat(lineStr, "\n");
    }
    if (source) {
      fprintf(stdout, "%d:%s", lineCount, lineStr);
    }
    lineCount++;
    lineStr[0] = '\0';
  }
  void printToken(const char* str) {
    if (token) {
      fprintf(stdout, "#%s:%s\n", str, yytext); 
    }
  }
  void printTokenString(const char* str) {
    static char temp[10000];
    strncpy(temp, yytext+1, strlen(yytext)-2);
    temp[strlen(yytext)-2] = '\0';
    if (token) {
      fprintf(stdout, "#%s:%s\n", str, temp); 
    }
    
  }
%}

Keyword {stdio}|{stdfile}|{stdchio}|{stdblio}|{stdfilepos}|{stderror}|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"struct"|"case"|"default"
Type_key "int"|"double"|"bool"|"char"
Void_key "void"
Const_key "const"
True_False "true"|"false"
stdio "printf"|"scanf"|"fprintf"|"fscanf"|"sprintf"|"sscanf"|"vfprintf"|"vprintf"|"vsprintf"
stdfile "fclose"|"fflush"|"fopen"|"freopen"|"remove"|"rename"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"
stdchio "fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"
stdblio "fread"|"fwrite"
stdfilepos "fgetpos"|"fseek"|"fsetpos"|"ftell"|"rewind"
stderror "clearerr"|"feof"|"ferror"|"perror"

And_operator "&&"
Or_operator "||"
Modify_operator "+"|"-"|"*"|"%"|"/"
Left_unary_operator "!"|"&"
Right_unary_operator "++"|"--"
Compare_operator "<"|"<="|">"|">="|"=="|"!="
Assign_operator "="

Punctuation ":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}"  

Int 0?|[1-9][0-9]*
Float ([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*)
SciNum ({Float}|[0-9]+)[Ee][+-]?[0-9]+

ID [a-zA-Z_][a-zA-Z_0-9]*

InvalidInt 0[0-9]+
InvalidSciNum ({Float}|[0-9])+[Ee][+-]?[0-9]*\.[0-9]*
InvalidID [0-9]+[a-zA-Z_]
InvalidChar '.[^\']+'
InvalidString {Quote}[^"\n]*\n

END [ \t\n]

Char '.'|'\\n'|'\\t'
String {Quote}([^"\n]|\\\")*{Quote}

Quote "\""

%x LINE
%x COMMENT
%x PRAGMA

%%
" ".*\n {
  // puts("LOL");
  yyless(1);
  strcat(lineStr, " ");
}
"\t".*\n {
  // puts("LOL");
  yyless(1);
  strcat(lineStr, "\t");
}
"/*".*\n {
  // puts("OK");
  last_state = state_zero;
  sameLine = 0;
  strcat(lineStr, "/*");
  yyless(2);
  BEGIN COMMENT;
}
#.*\n {
  // if (strcmp(yytext+strlen(yytext)-strlen("#pragma"), "#pragma") != 0) {
  //  errorExit();
  // }
  // puts("YA!");
  strcat(lineStr, yytext);
  yyless(1);
  pragma_pieces = 0;
  BEGIN PRAGMA;
}
.*\n {
  // puts("WHY");
  strcat(lineStr, yytext);
  sameLine = 1;
  yyless(0);
  BEGIN LINE;
}

<PRAGMA>" "|"\t" {}
<PRAGMA>"pragma"/{END} {
  if (pragma_pieces != 0) {
    errorExit();
  }
  pragma_pieces++;
}
<PRAGMA>"source"/{END} {
  if (pragma_pieces != 1) {
    errorExit();
  }
  turn = turn_source;
  pragma_pieces++;
}
<PRAGMA>"token"/{END} {
  if (pragma_pieces != 1) {
    errorExit();
  }
  turn = turn_token;
  pragma_pieces++;
}
<PRAGMA>"on"/{END} {
  if (pragma_pieces != 2) {
    errorExit();
  }
  turn_on = 1;
  pragma_pieces++;
}
<PRAGMA>"off"/{END} {
  if (pragma_pieces != 2) {
    errorExit();
  }
  turn_on = 0;
  pragma_pieces++;
}
<PRAGMA>"/*".* {
  last_state = state_pragma;
  yyless(2);
  sameLine = 1;
  BEGIN COMMENT;
}
<PRAGMA>\n {
  if (pragma_pieces != 3) {
    errorExit();
  }
  if (!sameLine) {
    strcat(lineStr, "\n");
  }
  if (turn == turn_token) {
    token = turn_on;
    // puts("hi");
  } else if (turn == turn_source) {
    source = turn_on;
    // puts("yo");
  }
  printLine();
  BEGIN 0;
}
<PRAGMA>"//".*\n {
  if (!sameLine) strcat(lineStr, yytext);
  printLine();
  BEGIN 0;
}
<PRAGMA>[^ \t\n]* {
  errorExit();
}

<LINE>" " {}
<LINE>"//".*\n {
  if (!sameLine) strcat(lineStr, yytext);
  printLine();
  BEGIN 0;
}
<LINE>"/*" {
  last_state = state_line;
  sameLine = 1;
  BEGIN COMMENT;
}
<COMMENT>\n {
  // if(!sameLine) strcat(lineStr, yytext);
  sameLine = 0;
  printLine();
}
<COMMENT>. {
  if(!sameLine) strcat(lineStr, yytext);
}
<COMMENT>"*/".* {
  if(last_state == state_line) {
    if(!sameLine) strcat(lineStr, yytext);
    yyless(2);
    BEGIN LINE;
  } else if (last_state == state_pragma) {
    if(!sameLine) strcat(lineStr, yytext);
    yyless(2);
    BEGIN PRAGMA;
  } else if (last_state == state_zero) {
    strcat(lineStr, "*/");
    yyless(2);
    BEGIN 0;
  }
}
<LINE>{Keyword} {
  printToken("key");
}
<LINE>{Type_key} {
  printToken("key");
  return Type_key;
}
<LINE>{Void_key} {
  printToken("key");
  return Void_key;
}
<LINE>{Const_key} {
  printToken("key");
  return Const_key;
}
<LINE>{True_False} {
  printToken("key");
  return True_False;
}
<LINE>{Assign_operator} {
  printToken("op");
  yylval.char_op = yytext[0];
  return yytext[0];
}
<LINE>{Compare_operator} {
  printToken("op");
  strcpy(yylval.str_op, yytext);
  return Compare_operator;
}
<LINE>{Left_unary_operator} {
  printToken("op");
  strcpy(yylval.str_op, yytext);
  return Left_unary_operator;
}
<LINE>{Right_unary_operator} {
  printToken("op");
  strcpy(yylval.str_op, yytext);
  return Right_unary_operator;
}
<LINE>{Modify_operator} {
  printToken("op");
  yylval.char_op = yytext[0];
  return yytext[0];
}
<LINE>{And_operator} {
  printToken("op");
  strcpy(yylval.str_op, yytext);
  return And_operator;
}
<LINE>{Or_operator} {
  printToken("op");
  strcpy(yylval.str_op, yytext);
  return Or_operator;
}
<LINE>{Punctuation} {
  printToken("punc");
  yylval.punctuation = yytext[0];
  return yytext[0];
}
<LINE>{ID}  {
  printToken("id");
  strcpy(yylval.ident, yytext);
  return ID;
}
<LINE>{Int} {
  printToken("integer");
  yylval.integer = atoi(yytext);
  return Int;
}
<LINE>{Float} {
  printToken("double");
  yylval.float_num = atof(yytext);
  return Float;
}
<LINE>{SciNum} {
  printToken("sci");
  sscanf(yytext, "%lf", &yylval.float_num);
  return SciNum;
}
<LINE>{Char} {
  printToken("char");
  strcpy(yylval.char_specify, yytext);
  return Char;
}
<LINE>{String} {
  printTokenString("string");
  strcpy(yylval.str_specify, yytext);
  return String;
}
<LINE>{InvalidInt}|{InvalidSciNum}|{InvalidID}|{InvalidString}|{InvalidChar} {
  errorExit();
}
<LINE>. {
  errorExit();
}
<LINE>\n {
  // if (!sameLine) strcat(lineStr, yytext);
  printLine();
  BEGIN 0;
}

%%

// int main(int argc, char const *argv[])
// {
//   yylex();
//   return 0;
// }
int yywrap()
{
  return 1;
}