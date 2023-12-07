%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yyparse(void);
extern char *yytext;
extern FILE* yyin;
extern int nbrLine;
extern void yyerror(const char *s);

typedef struct symTable{
    char *name;
    char *type;
    char *code;
    char *isConst;
}symTable;

typedef struct node{
    symTable data;
	struct node *next;
}list;

list *linkedL = NULL,*declaredVar;

list *initialize(char *type, char *name, char *code, char *isConst)
{
    list *linkedL = (list *)malloc(sizeof(list));
    if (linkedL == NULL) {
        printf("\nMemory allocation failed\n");
        exit(EXIT_FAILURE);}
    linkedL->data.type = type;
    linkedL->data.name = name;
    linkedL->data.code = code;
    linkedL->data.isConst = isConst;
    linkedL->next = NULL;
    return linkedL;
}

list *addUnit(list *linkedL, char *type, char *name, char *code, char *isConst)
{
    if (linkedL == NULL)    
        return initialize(type,name,code,isConst);
    else{
        linkedL->next = addUnit(linkedL->next,type,name,code,isConst);
    }
    return linkedL;
}

void printList(list *linkedL)
{
    while (linkedL){
        printf("|%10s |%10s |%10s |%10s |\n", linkedL->data.type, linkedL->data.name, linkedL->data.code, linkedL->data.isConst);
        linkedL = linkedL->next;
    }
}

void freeLinkedList(list *linkedL) {
    while (linkedL) {
        list *currNode = linkedL;
        linkedL = linkedL->next;
        free(currNode);
    }
}


void verifyDoubleDeclaration(list *linkedL){
    list *currNode = linkedL;

    while(currNode){

        list *nextNode = currNode;
            while(nextNode){
                if(strcmp(currNode->data.name,nextNode->data.name) == 0 && strcmp(currNode->data.type,nextNode->data.type) != 0){
                    printf("Error DOUBLE DECLARATION \t %s has two types [ %s : %s]",currNode->data.name,currNode->data.type,nextNode->data.type);
                    exit(EXIT_FAILURE);}
                nextNode = nextNode->next; 
            }
    currNode = currNode->next;}
}

void deleteOtherOccurances(list *linkedL){

    if (linkedL == NULL) return;

    list *nextNode = linkedL;

        while (nextNode->next != NULL) {
            if (strcmp(linkedL->data.name,nextNode->next->data.name) == 0 
                && strcmp(linkedL->data.type,nextNode->next->data.type) == 0
                && strcmp(linkedL->data.code,nextNode->next->data.code) == 0 
                && strcmp(linkedL->data.isConst,nextNode->next->data.isConst) == 0) {
                    list *temp = nextNode->next;
                    nextNode->next = nextNode->next->next;
                    free(temp);
            } else { nextNode = nextNode->next; }
        }
        deleteOtherOccurances(linkedL->next);
}

char *getTypeOfVar(list *linkedL,char *name){

    while(linkedL != NULL){
        if( strcmp(linkedL->data.name,name) == 0  ) return linkedL->data.type;
        linkedL = linkedL->next;
    }
    return NULL;
}

int verifyCompatibility(list *linkedL,char *type){

        if ( strcmp(linkedL->data.type,type) == 0 ) return 1;
        else{
            printf("Line: %d , Error Type Compatibility Variable { %s } is not '%s' , its a '%s'",nbrLine,linkedL->data.name,type,linkedL->data.type);
            return 0;
        }
}

void verifyDeclarationAndConst(list *linkedL,char *name,char *type){

    while(linkedL != NULL){
        if( strcmp(linkedL->data.name,name) == 0  ){
            if( strcmp(linkedL->data.isConst,"true") == 0 ){
                printf("Line : %d , Const Variable { %s } Changed Value",nbrLine,name);
                exit(EXIT_FAILURE);
            }
            list *checkL = linkedL;
            if ( verifyCompatibility(checkL,type) == 1 ) return ;
                else{exit(EXIT_FAILURE);}
        }
        linkedL = linkedL->next;
    }

    printf("\nLine: %d , Error The Variable { %s } Not Declared",nbrLine,name);
    exit(EXIT_FAILURE);
}

%}

%union {
    int intV;
    float floatV;
    char* booleanV;
    char* strV;
}

%token <strV>BEG <strV>END
%token <strV>INT <strV>FLOAT <strV>BOOL <strV>CONST
%token <intV>DIG <intV>NUMBER <floatV>FLOATnum <booleanV>BOOLc <strV>CHAR <strV>IDF
%token <strV>SEMI <strV>EQ <strV>OP <strV>COMP
%token <strV>LP <strV>RP <strV>LC <strV>RC <strV>IF <strV>ELSE <strV>FOR <strV>WHILE

%start beg

%%

beg: 
    declaration beg
    | declaration program
    ;

declaration:INT IDF SEMI { linkedL = addUnit(linkedL,$1,$2,"idf","false");
                         linkedL = addUnit(linkedL,"SemiColon",$3,"endKey","");
                          } 
    |FLOAT IDF SEMI { linkedL = addUnit(linkedL,$1,$2,"idf","false");
                    linkedL = addUnit(linkedL,"SemiColon",$3,"endKey",""); 
                     }
    |BOOL IDF SEMI { linkedL = addUnit(linkedL,$1,$2,"idf","false"); 
                    linkedL = addUnit(linkedL,"SemiColon",$3,"endKey","");
                     }
    |INT IDF EQ NUMBER SEMI { linkedL = addUnit(linkedL,$1,$2,"idf","false");
                                  linkedL = addUnit(linkedL,"operator",$3,"keyEQ","");
                                  linkedL = addUnit(linkedL,"SemiColon",$5,"endKey","");
                                   }
    |FLOAT IDF EQ FLOATnum SEMI { linkedL = addUnit(linkedL,$1,$2,"idf","false");
                                      linkedL = addUnit(linkedL,"operator",$3,"keyEQ","");
                                      linkedL = addUnit(linkedL,"SemiColon",$5,"endKey","");
                                       }
    |BOOL IDF EQ BOOLc SEMI { linkedL = addUnit(linkedL,$1,$2,"idf","false"); 
                                  linkedL = addUnit(linkedL,"operator",$3,"keyEQ","");
                                  linkedL = addUnit(linkedL,"SemiColon",$5,"endKey","");
                                   }
    |CONST INT IDF EQ NUMBER SEMI {  linkedL = addUnit(linkedL,$2,$3,"idf","true");
                                  linkedL = addUnit(linkedL,"SemiColon",$6,"endKey","");
                                   }
    |CONST FLOAT IDF EQ FLOATnum SEMI { linkedL = addUnit(linkedL,$2,$3,"idf","true");
                                      linkedL = addUnit(linkedL,"SemiColon",$6,"endKey","");
                                       }
    |CONST BOOL IDF EQ BOOLc SEMI { linkedL = addUnit(linkedL,$2,$3,"idf","true"); 
                                  linkedL = addUnit(linkedL,"SemiColon",$6,"endKey","");
                                   }
    ;

program: BEG { verifyDoubleDeclaration(linkedL); declaredVar = linkedL;
             printf("START PROGRAM ....\n");
             linkedL = addUnit(linkedL,"start",$1,"keyword","");} code
    ;

code: assign code
    | statements
    | /* epsilon */
    | end
    ;

assign: IDF EQ IDF OP IDF SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 ){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                        verifyDeclarationAndConst(declaredVar,$3,type);
                                        verifyDeclarationAndConst(declaredVar,$5,type);
                                    }else{
                                        verifyDeclarationAndConst(declaredVar,$1,type);}
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); }
        | IDF EQ num OP IDF SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 && strcmp(type,"int") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                        verifyDeclarationAndConst(declaredVar,$5,type);
                                    }else if(strcmp(type,"float") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,"float");
                                    }
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); }
        | IDF EQ FLOATnum OP IDF SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 && strcmp(type,"float") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                        verifyDeclarationAndConst(declaredVar,$5,type);
                                    }else if(strcmp(type,"int") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,"int");
                                    }
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); }
        | IDF EQ IDF OP num SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 && strcmp(type,"int") == 0 ){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                        verifyDeclarationAndConst(declaredVar,$3,type);
                                    }else if(strcmp(type,"float") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,"float");
                                    }
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); } 
        | IDF EQ IDF OP FLOATnum SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 && strcmp(type,"float") == 0 ){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                        verifyDeclarationAndConst(declaredVar,$3,type);
                                    }else if(strcmp(type,"int") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,"int");
                                    }
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); }
        | IDF EQ FLOATnum OP FLOATnum SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 && strcmp(type,"float") == 0 ){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                    }else if(strcmp(type,"int") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,"int");
                                    }
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); } 
        | IDF EQ num OP num SEMI { char *type = getTypeOfVar(declaredVar,$1);
                                    if( strcmp(type,"bool") != 0 && strcmp(type,"int") == 0 ){
                                        verifyDeclarationAndConst(declaredVar,$1,type);
                                    }else if(strcmp(type,"float") == 0){
                                        verifyDeclarationAndConst(declaredVar,$1,"float");
                                    }
                                    linkedL = addUnit(linkedL,"operator",$4,"biOperator",""); }    
        | IDF EQ BOOLc SEMI { verifyDeclarationAndConst(declaredVar,$1,"bool"); }
                                                                      
    ;

statements: ifElseS code
    |forS code
    |whileS code
    ;

ifElseS: IF LP condition RP LC code RC { linkedL = addUnit(linkedL,"IF-cond",$1,"keyCond","");
                                        linkedL = addUnit(linkedL,"LeftPar",$2,"key","");
                                        linkedL = addUnit(linkedL,"RightPar",$4,"key","");
                                        linkedL = addUnit(linkedL,"LeftCur",$5,"key","");
                                        linkedL = addUnit(linkedL,"RightCur",$7,"key",""); } 
    |IF LP condition RP LC code RC ELSE LC code RC { linkedL = addUnit(linkedL,"iF-cond",$1,"keyCond","");
                                        linkedL = addUnit(linkedL,"LeftPar",$2,"key","");
                                        linkedL = addUnit(linkedL,"RightPar",$4,"key","");
                                        linkedL = addUnit(linkedL,"LeftCur",$5,"key","");
                                        linkedL = addUnit(linkedL,"RightCur",$7,"key","");
                                        linkedL = addUnit(linkedL,"ELSEcond",$8,"keyCond","");
                                                                                            }
    ;

forS: FOR LP assign condition SEMI counter SEMI RP LC code RC { linkedL = addUnit(linkedL,"FOR-cond",$1,"keyCond","");
                                                                linkedL = addUnit(linkedL,"LeftPar",$2,"key","");
                                                                linkedL = addUnit(linkedL,"RightPar",$8,"key","");
                                                                linkedL = addUnit(linkedL,"LeftCur",$9,"key","");
                                                                linkedL = addUnit(linkedL,"RightCur",$11,"key",""); }
    ;

whileS: WHILE LP condition RP LC code RC
    ;

condition: num COMP num  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | FLOATnum COMP FLOATnum  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | IDF COMP num  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | IDF COMP FLOATnum  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | num COMP IDF  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | FLOATnum COMP IDF  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | IDF COMP IDF  {linkedL = addUnit(linkedL,"COMPop",$2,"keyCond",""); }
    | BOOLc "==" IDF  {linkedL = addUnit(linkedL,"COMPop","==","keyCond",""); }
    | IDF "==" BOOLc  {linkedL = addUnit(linkedL,"COMPop","==","keyCond",""); }
    | BOOLc "==" BOOLc  {linkedL = addUnit(linkedL,"COMPop","==","keyCond",""); }
    ; 

counter: CHAR "++" { linkedL = addUnit(linkedL,"operator","++","counter",""); }
    | CHAR "--" { linkedL = addUnit(linkedL,"operator","--","counter",""); }
    | CHAR "/" DIG 
    | CHAR "*" DIG
    ;

num: NUMBER
    | DIG
    ;

end: END { printf("EXIT PROGRAM .... "); 
            linkedL = addUnit(linkedL,"finish",$1,"keyword","");
            YYACCEPT }

%%

void yyerror(const char *s) 
{
    fprintf(stderr, "Line: %d , SYNTAX ERROR: %s\tits => %s <=",nbrLine,s,yytext);

    exit(EXIT_FAILURE);
}

int main() 
{
    FILE *fp = fopen("input.txt", "r");
    if (fp == NULL) {
        fprintf(stderr, "Error opening file\n");
        return -1;
    }
    printf("READING FILE\n");

    yyin = fp; // yyin in a pointe to a file from which the lexer read the inputs
    yyparse();
    fclose(fp);
    deleteOtherOccurances(linkedL);
    printf("\n/*************** Sym - Table ******************/\n");
    printf("________________________________________________\n");
    printf("|  TypeEnt  |  NameEnt  |  CodeEnt  |  isConst |\n");
    printf("________________________________________________\n");
    printList(linkedL);
    freeLinkedList(linkedL);
    
    return 1;
}