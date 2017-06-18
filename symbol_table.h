#define MAX_TABLE_SIZE 5000

// typedef struct symbol_entry *PTR_SYMB;
struct symbol_entry {
   char *name;
   int scope;
   // offset from fp
   int offset;
   // int id;
   // int variant;
   int type;
   int total_args;
   int total_locals;
   int mode;
}table[MAX_TABLE_SIZE];
void init_symbol_table();
char *install_symbol(char *s);
int look_up_symbol(char *s);
void pop_up_symbol(int scope);
void push_symbol_to_stack(char *s);
void push_int_to_stack(int i);
void stack_pop_word();
void assign_symbol_to_top(char *s);
int get_offset(char *s);
void set_if_not_zero(char *reg);
void set_if_zero(char *reg);
// #define T_FUNCTION 1
// #define ARGUMENT_MODE   2
// #define LOCAL_MODE      4
// #define GLOBAL_MODE     8

extern int cur_scope;
extern int cur_counter;
