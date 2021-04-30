LEX=lex
YACC=bison
CC=g++ -std=c++11
OBJECT=main

$(OBJECT): lex.yy.o 180101038_yacc.tab.o 
	$(CC) lex.yy.o 180101038_yacc.tab.o -o $(OBJECT)

lex.yy.o: lex.yy.c 180101038_yacc.tab.h
	$(CC) -c lex.yy.c

180101038_yacc.tab.o: 180101038_yacc.tab.c
	$(CC) -c 180101038_yacc.tab.c

lex.yy.c: 180101038_lex.l 180101038_yacc.tab.h
	$(LEX) 180101038_lex.l	

180101038_yacc.tab.c 180101038_yacc.tab.h: 180101038_yacc.y
	$(YACC) -d 180101038_yacc.y

clean:
	@rm -f $(OBJECT)  *.o 180101038_yacc.tab.c 180101038_yacc.tab.h lex.yy.c