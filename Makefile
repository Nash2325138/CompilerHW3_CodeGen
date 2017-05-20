parser: hw2.l hw2.y
	flex hw2.l
	yacc -d -v hw2.y --report=all --report-file=yacc.report
	gcc -o parser lex.yy.c y.tab.c
clean:
	rm -f lex.yy.c parser y.tab.h y.tab.c yacc.report
test: parser test.c
	./parser < ./test/1.c
