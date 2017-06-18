combine: parser
	./parser < ./test.c > /dev/null
	cp assembly Assembly_Combiner/
	cd Assembly_Combiner; sh create.sh
	cp Assembly_Combiner/Blink.s .
parser: hw2.l hw2.y symbol_table.c symbol_table.h
	flex hw2.l
	yacc -d -v --report=all hw2.y
	gcc -o parser lex.yy.c y.tab.c symbol_table.c
clean:
	rm -f lex.yy.c parser y.tab.h y.tab.c yacc.report y.output assembly Blink.s
test: parser ./test.c
	./parser < ./test.c
	cat ./assembly