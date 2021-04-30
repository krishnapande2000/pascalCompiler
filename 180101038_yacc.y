%{

	/*
	NAME:KRISHNA PANDE
	ROLL NO: 180101038

	The following file is an implementation of the parser for pascal grammar.
	THe lex file attached creates the token for identification and the parser 
	executes the required actions for each kind of token.
	
	It identifies errors of following types:
	1) syntax errors : where charaters are not recognized by the grammar
	2) DUplicate declaration of variables
	3) Incompatible data types used in an expression or assigment
	4) Variable not declared in scope
	5) Variable name is reserved keyword is caught and shown as a syntax error
	and lists these errors along with the line number at the end of parsing.
	parsing terminates at syntax errors.



	*/

	#include <bits/stdc++.h> 
	using namespace std;

	extern FILE* yyin; // input file to lexer and parser
	extern int yylex(void); //function created for the lexer in lex.yy.c
	extern int yylineno;
	
	struct variable
	{ 
		// Structure ised to store a variable
		string name; // Name of the variable
		int type; // t_INT_TYPE, t_REAL_TYPE
		int line_num; // line num where the variable is defined

		variable()
		{
			name = "";
			type = 0;
			line_num = 0;

		}
		variable(string nam,int typ,int lineno)
		{
			name = nam;
			type = typ;
			line_num = lineno;
		}


	};

	bool VAR=false; // A flag used to find the variable declaration

	vector<variable> variables; // List of all the variables in current declaration statement
	unordered_map<string,variable> Symbol_Table; // Symbol Table to store variables
	vector<string> errorsMessages; //store error messages to display
    map<string,int> reservedKeywords; // keywords reserved by the grammar, e.g. FOR, TO, BEGIN, etc.
	
	void typeMatchError(int t1); // function to handle the case of type mismatch
	void yyerror(string s); //handles errors
	void error(char *s); //handles syntax errors found from lex

   
%}

%token t_PROGRAM 1
%token t_VAR 2
%token t_BEGIN 3
%token t_END 4
%token t_END_DOT 5
%token <ival> t_INT_TYPE 6
%token <ival> t_REAL_TYPE 7
%token t_FOR 8
%token t_READ 9
%token t_WRITE 10
%token t_TO 11
%token t_DO 12
%token t_SEMICOLON 13
%token t_COLON 14
%token t_COMMA 15
%token t_ASSIGN 16
%token t_PLUS 17
%token t_MINUS 18
%token t_MULT 19
%token t_DIV 20
%token t_OPEN_BRACKET 21
%token t_CLOSE_BRACKET 22
%token <sval> t_ID 23
%token <ival> t_INT 24
%token <dval> t_REAL 25

%union{
	int ival; // to record integer type
	double dval; // to record real type
	char *sval; // to record identifiers
}

// Need to specify the return type of the rules
%type <sval> ID
%type <ival> type exp term factor
%%

prog 			: t_PROGRAM prog_name t_VAR {VAR =true;} dec_list {VAR =false;} t_BEGIN stmt_list t_END_DOT
				  /* If encountered "VAR" then set VAR */
				  /* After the declarations are complete reset VAR */
				  ;
prog_name 		: ID
				  ;
dec_list 		: dec dec_list | dec
				  ;
dec 			: id_list t_COLON type {
					for(auto l:variables)
					{ 
						// traverse the declaration list
						auto itr = Symbol_Table.find(l.name); // find whether the variable was defined before or not
						if(itr == Symbol_Table.end())
						{ 
							// If not defined
							l.type=$3;
							Symbol_Table[l.name]=l; // Insert new variable in Symbol Table
						}
						else
						{ 
							// If found
							string errstr = "Error at line " + to_string(yylineno) + " -> " + "Duplicate Variable definition " + l.name + " is already defined at line " + to_string(itr->second.line_num);
							errorsMessages.push_back(errstr); // Add error to the list of errors
						}
					}
					variables.clear(); // clear the list of variables in the current declarative statement
				}
				  ;

id_list 		: ID {
					if(VAR){ // if VAR statement is being processed
						string varName=$1;
						variable tempVar(varName,0,yylineno);
						variables.push_back(tempVar); // push the variable into list
					}
				}
				| id_list t_COMMA ID { // if VAR statement is being processed
					if(VAR){
						string varName=$3;
						variable tempVar(varName,0,yylineno);
						variables.push_back(tempVar); // push the variable into list
					}
				} 
				  ;
type 			: t_INT_TYPE {$$ = t_INT_TYPE;}
				| t_REAL_TYPE {$$ = t_REAL_TYPE;}
				  /* return the type of the variable or constant */ 
				  ;				  

stmt_list 		: stmt | stmt_list t_SEMICOLON stmt
				  ;
term 			: factor {$$ = $1;} /* If single term then the type is same as that of term */
				| term t_DIV factor {
					if($1 == $3){ // If two terms are of same type
						$$ = $1;
					}
					else{
						typeMatchError($1);
					}
				}
				| term t_MULT factor {
					if($1 == $3){ // If two terms are of same type
						$$ = $1;
					}
					else{
						typeMatchError($1);
					}
				}
				  ;				  
assign 			: ID t_ASSIGN exp {
					string varName($1);
					 // search for the variable in Symbol_Table
					if(Symbol_Table.find(varName) == Symbol_Table.end()){ // If not found 
						string errstr = "Error at line " + to_string(yylineno) + " -> " + "Variable not declared in scope -> " + varName;
						errorsMessages.push_back(errstr);
					}
					else if(Symbol_Table[varName].type != $3){
							// If type is not matched between ariable and the expression
							typeMatchError(Symbol_Table[varName].type); // handle the type error using typeMatchError function
					}
					
					
				}
				  ;
stmt 			: assign | read | write | for
				  ;				  
exp 			: term {$$ = $1;} /* If single term then the type is same as that of term */
				| exp t_PLUS term {
					if($1 == $3){ // If two terms are of same type
						$$ = $1;
					}
					else{ // otherwise handle different types
						typeMatchError($1);
					}
				}
				| exp t_MINUS term {
				  	if($1 == $3){ // If two terms are of same type
						$$ = $1;
					}
					else{
						typeMatchError($1);
					}
				}
				  ;

factor 			: ID {
					string varName($1);
					 // find the variable in Symbol_Table
					if(Symbol_Table.find(varName) == Symbol_Table.end()){ // If not found
						string errstr = "Error at line " + to_string(yylineno) + " -> " + "Variable not declared in scope -> " + varName;
						errorsMessages.push_back(errstr);
					}
					else{
						$$ = Symbol_Table[varName].type; // If found then return the type of the variable
					}
				}
				| t_REAL {$$ = t_REAL_TYPE;}
				| t_INT {$$ = t_INT_TYPE;} 
				| t_OPEN_BRACKET exp t_CLOSE_BRACKET {$$ = $2;} // return the type of the exp
				  ;
for 			: t_FOR index_exp t_DO body
				  ;
read 			: t_READ t_OPEN_BRACKET id_list t_CLOSE_BRACKET
				  ;				  
write 			: t_WRITE t_OPEN_BRACKET id_list t_CLOSE_BRACKET
				  ;				  
index_exp 		: ID t_ASSIGN exp t_TO exp
				  ;
ID 				: t_ID
				  {
				  	string varName=yylval.sval;
				  	 // check for reserved keywords
				  		if(reservedKeywords.find(varName)!=reservedKeywords.end()){ // if found then error
				  			string errstr = "Error at line " + to_string(yylineno) + " -> " + "Variable name cannot be the keyword " + varName;
						errorsMessages.push_back(errstr);
				  		}
				  	
				  	$$ = yylval.sval; // otherwise return the variable name
				  }
				  ;
body 			: stmt | t_BEGIN stmt_list t_END
				  ;				  

%%

void error(char *s){
	string temp(s);
	string errstr = "Illegal character found : " + temp; 
	errorsMessages.push_back(errstr); // add the error to the vector of arrays
}


void init()
{ 
	reservedKeywords["PROGRAM"]=1;
	reservedKeywords["VAR"]=1;
	reservedKeywords["BEGIN"]=1;
	reservedKeywords["END"]=1;
	reservedKeywords["END."]=1;
	reservedKeywords["INTEGER"]=1;
	reservedKeywords["REAL"]=1;
	reservedKeywords["FOR"]=1;
	reservedKeywords["READ"]=1;
	reservedKeywords["WRITE"]=1;
	reservedKeywords["TO"]=1;
	reservedKeywords["DO"]=1;
	reservedKeywords["DIV"]=1;
}
// function to handle the syntax errors from parser
void yyerror(string s){ 
	string errstr = "Error at line " + to_string(yylineno) + " -> " + s;
	errorsMessages.push_back(errstr);
}

// function to handle Type error
void typeMatchError(int t1){ // t1 define the type of the first term in an expression
	
	string errstr;
	if(t1 == (int)t_INT_TYPE)
	{
	 	errstr= "Error at line " + to_string(yylineno) + " -> " + "Incompatible types INTEGER and REAL";
	}
	else
	{
	 	errstr= "Error at line " + to_string(yylineno) + " -> " + "Incompatible types REAL and INTEGER";
	}
	
	errorsMessages.push_back(errstr);
}



int main(){
	
	
	yyin = fopen("input.txt","r"); //input file
	if(!yyin){
		cout<<"Cannot open file\n"; // if cannot open the input file, then terminate
		exit(1);
	}
	
	cout<<"*****Compilation Begin*******\n";

	init();

	if(yyparse()==0){
		cout<<"successful parse\n";
		
	}
	else{
		cout<<"Unsuccessful parse errors encountered\n";
	}
	cout<<"****Done******\n";
	fclose(yyin); // Close the input file

	if(errorsMessages.size()!=0){ // If there are error messages then print them to terminal
		cout<<"Errors: \n";
		for(auto l:errorsMessages)
		{
			cout<<l<<endl;
		}
	}
	else{
		cout<<"No syntax or sematic errors found!\n";
	}
	return 0;
}
