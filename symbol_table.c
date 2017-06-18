
/*
   This is a very simple c compiler written by Prof. Jenq Kuen Lee,
   Department of Computer Science, National Tsing-Hua Univ., Taiwan,
   Fall 1995.

   This is used in compiler class.
   This file contains Symbol Table Handling.

*/

#include <stdio.h>  
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

extern FILE *f_asm;
int cur_counter = 0;
int cur_scope = 1;
int cur_offset = 0;

char *copys(char *s) {
    char *ret = malloc(sizeof(char) * strlen(s));
    strcpy(ret, s);
    return ret;
}

void init_symbol_table() {
    memset(&table[0], 0, sizeof(struct symbol_entry)*MAX_TABLE_SIZE);
}

char *install_symbol(char *s)
{
    if (cur_counter >= MAX_TABLE_SIZE) {
        fprintf(stderr, "Symbol Table Full");
    }
    else {
        fprintf(f_asm, "# ---- Installing symbol: %s on $fp+(%d)\n", s, cur_offset);
        table[cur_counter].scope = cur_scope;

        table[cur_counter].name = copys(s);
        table[cur_counter].offset = cur_offset;
        cur_offset -= 4;
        fprintf(f_asm, "addi\t$sp,\t$sp,\t-4\n");
        cur_counter++;
    }
    return(s);
}


// To return an integer as an index of the symbol table
int look_up_symbol(char *s) {
    int i;
    // for (i=0; i<cur_counter; i++) {
    //     fprintf(f_asm, "# ---[$fp+(%d)] is %s\n", table[i].offset, table[i].name);    
    // }
    if (cur_counter == 0) return (-1);
    for (i = cur_counter - 1; i >= 0; i--) {
        if (!strcmp(s,table[i].name)) return i;
    }
    return (-1);
}


// Pop up symbols of the given scope from the symbol table upon the
// exit of a given scope.
void pop_up_symbol(int scope) {
    int i;
    if (cur_counter == 0) return;
    for (i = cur_counter-1; i >= 0; i--) {
        if (table[i].scope != scope) break;
    }
    if (i < 0) cur_counter = 0;
    cur_counter = i + 1;
}

void push_symbol_to_stack(char *s) {
    fprintf(f_asm, "lwi\t$r0,\t[$fp+(%d)]\n", get_offset(s));
    fprintf(f_asm, "swi\t$r0,\t[$sp]\n");

    cur_offset -= 4;
    fprintf(f_asm, "addi $sp, $sp, -4\n");
}
void push_int_to_stack(int i) {
    fprintf(f_asm, "movi\t$r0,\t%d\n", i);
    fprintf(f_asm, "swi\t$r0,\t[$sp]\n");

    cur_offset -= 4;
    fprintf(f_asm, "addi\t$sp,\t$sp,\t-4\n");
}
void stack_pop_word() {
    fprintf(f_asm, "# ---- stack poping\n");
    cur_offset += 4;
    fprintf(f_asm, "addi\t$sp,\t$sp,\t4\n");
}

void assign_symbol_to_top(char *s) {
    fprintf(f_asm, "# ---- Assigning symbol: \"%s\" to the content of stack top\n", s);
    fprintf(f_asm, "lwi\t$r0,\t[$sp+4]\n");
    fprintf(f_asm, "swi\t$r0,\t[$fp+(%d)]\n", get_offset(s));
}

int get_offset(char *s) {
    return table[look_up_symbol(s)].offset;
}
          


void set_if_not_zero(char *reg) {
    fprintf(f_asm, "# ---- Set %s if not zero\n", reg);
    fprintf(f_asm, "slti\t%s,\t%s,\t1\n", reg, reg);
    fprintf(f_asm, "zeb\t%s,\t%s\n", reg, reg);
    fprintf(f_asm, "slti\t%s,\t%s,\t1\n", reg, reg);
}
void set_if_zero(char *reg) {
    fprintf(f_asm, "# ---- Set %s if zero (negation)\n", reg);
    fprintf(f_asm, "slti\t%s,\t%s,\t1\n", reg, reg);
    fprintf(f_asm, "zeb\t%s,\t%s\n", reg, reg);
}
// // Set up parameter scope and offset
// void set_scope_and_offset_of_param(char *s)
// {

//   int i,j,index;
//   int total_args;

//    index = look_up_symbol(s);
//    if (index<0) err("Error in function header");
//    else {
//       table[index].type = T_FUNCTION;
//       total_args = cur_counter -index -1;
//       table[index].total_args=total_args;
//       for (j=total_args, i=cur_counter-1;i>index; i--,j--)
//         {
//           table[i].scope= cur_scope;
//           table[i].offset= j;
//           table[i].mode  = ARGUMENT_MODE;
//         }
//    }

// }




// // Set up local var offset
// void set_local_vars(char *functor) {
//     int i,j,index,index1;
//     int total_locals;

//     index = look_up_symbol(functor);
//     index1 = index + table[index].total_args;
//     total_locals= cur_counter -index1 -1;
//     if (total_locals < 0) {
//         err("Error in number of local variables");      
//     }
//     table[index].total_locals=total_locals;
//     for (j = total_locals, i = cur_counter-1; j>0; i--, j--)
//     {
//         table[i].scope= cur_scope;
//         table[i].offset= j;
//         table[i].mode  = LOCAL_MODE;
//     }
// }


// // Set GLOBAL_MODE to global variables
// void set_global_vars(char *s)
// {
//     int index;
//     index = look_up_symbol(s);
//     table[index].mode = GLOBAL_MODE;
//     table[index].scope = 1;
// }


// /*

// To generate house-keeping work at the beginning of the function

// */

// code_gen_func_header(functor)
// char *functor;
// {

// fprintf(f_asm,"   ;    %s\n",functor);
// fprintf(f_asm,"        assume cs:_TEXT\n");
// fprintf(f_asm,"_%s      proc  near\n",functor);
// fprintf(f_asm,"        push bp\n");
// fprintf(f_asm,"        mov  bp,sp\n");
// fprintf(f_asm,"   ;    \n");

// }

// /*

//   To generate global symbol vars

// */
// code_gen_global_vars()
// {
//   int i;

//   fprintf(f_asm,"_BSS     segment word public 'BSS'\n");
//   for (i=0; i<cur_counter; i++)
//      {
//        if (table[i].mode == GLOBAL_MODE)
// 	 {
//             fprintf(f_asm,"_%s	label	word\n",table[i].name);
//             fprintf(f_asm,"	db	2 dup (?)\n");
//          }
//      }
//  fprintf(f_asm,"_BSS    ends\n");

// }


// /*

//  To geenrate house-keeping work at the end of a function

// */

// code_gen_at_end_of_function_body(functor)
// char *functor;
// {
//   int i;

//   fprintf(f_asm,"   ;    \n");
//   fprintf(f_asm,"        mov sp, bp\n");
//   fprintf(f_asm,"        pop bp\n");
//   fprintf(f_asm,"        ret\n");
//   fprintf(f_asm,"_%s     endp\n",functor);

// }