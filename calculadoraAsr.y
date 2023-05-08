/* Este archivo contiene un reconocedor de expresiones aritméticas. Durante el
 * reconocimiento se construye un árbol sintáctico reducido de las expresiones
 * aritméticas que después se interpreta al hacer un recorrido del mismo.

   Para compilar y ejecutar:
   flex calculadorAsr.lex
   bison -d calculadoraAsr.y
   gcc lex.yy.c calculadoraAsr.tab.c -lfl
   ./a.out

   Autor: Ricardo Garcia Sedano*/

%{
#include<stdlib.h>
#include<stdio.h>

// Definimos una estructura para hacer el árbol sintáctico reducido.
typedef struct asr ASR;
struct asr{
   unsigned char tipo;  // Indica si es una operación o un número: 1 = operación, 0 = operando.
   int valor; // Si es un número es el valor del número. Si no, es la operación.
   ASR * izq; // La subexpresión a la izquierda
   ASR * der; // La subexpresión a la derecha
};

extern int yylex();
int yyerror(char const * s);
ASR * nuevoNodo(unsigned char, int, ASR *, ASR *);
int recorre(ASR *);
extern char * yytext;
int potenci(int numero, int poten);

%}

%union{
   int valor;  // Para las constantes numéricas
   struct asr * arbol;  // Para los apuntadores a árbol sintáctico
}

/* Los elementos terminales de la gramática. La declaración de abajo se
   convierte en definición de constantes en el archivo calculadora.tab.h
   que hay que incluir en el archivo de flex. */

%token SUMA RESTA DIVIDE MULTI EXPON MODU PAREND PARENI FINEXP
%token<valor> NUM
%type <arbol> expr term factor
%start exp

%%

exp : expr FINEXP {printf("resultado = %d\n", recorre($1)); exit(0);}
;

expr : expr SUMA term    {$$ = nuevoNodo(1,SUMA,$1, $3);}
     | expr RESTA term   {$$ = nuevoNodo(1,RESTA, $1, $3);}
     | term
;

term : term MULTI factor   {$$ = nuevoNodo(1,MULTI,$1,$3);}
     | term DIVIDE factor  {$$ = nuevoNodo(1,DIVIDE,$1,$3);}
     | term EXPON factor   {$$ = nuevoNodo(1,EXPON,$1,$3);}
     | term MODU factor    {$$ = nuevoNodo(1,MODU,$1,$3);}
     | factor
;

factor : PARENI expr PAREND  {$$ = $2;}
       | NUM   {$$ = nuevoNodo(0,$1,NULL, NULL);}
;

%%

int yyerror(char const * s) {
  fprintf(stderr, "%s,%s\n", s,yytext);
}

void main() {

  yyparse();
}

/* La función nuevoNodo crea un nuevo nodo para un árbol sintáctico reducido.
   Los parámetros son el tipo de nodo (operación u operando), el valor que
   representa qué operando se está usando o el valor del número en cuestión y
   los apuntadores a los subárboles correspondientes.
*/

ASR * nuevoNodo(unsigned char tipo, int valor, ASR * izq, ASR * der) {

   ASR * aux = (ASR *) malloc(sizeof(ASR));
   aux -> tipo = tipo;
   aux -> valor = valor;
   aux -> izq = izq;
   aux -> der = der;
   return aux;
}

/* La función recorre es el intérprtete en este caso. Simplemente recorre
   el árbol en postorden para obtner los valores correspondientes.
*/

int recorre(ASR * raiz) {
   int aux1, aux2;

   if (raiz == NULL) return 0;

   if (raiz -> tipo == 1) { // Se trata de un operando, hay que recorrer sus subárboles
      aux1 = recorre(raiz -> izq);
      aux2 = recorre(raiz -> der);
      // Ya tenemos los valores correspondientes, ahora hay que operar y devolver el
      // valor de la operación.
      if (raiz -> valor == SUMA) return aux1 + aux2;
      if (raiz -> valor == RESTA) return aux1 - aux2;
      if (raiz -> valor == MULTI) return aux1 * aux2;
      if (raiz -> valor == DIVIDE) return aux1 / aux2;
      if (raiz -> valor == EXPON) return potenci(aux1,aux2);
      if (raiz -> valor == MODU) return aux1 % aux2;
   }
   else // El valor de tipo debe ser 0 y por tanto es un operando
      return raiz -> valor;
}

//Creamos una funcion que nos calcule la exponenciacion
int potenci(int numero, int poten){
  int resultado = numero;
  while (poten > 1){
    resultado = resultado * numero;
    poten--;
  }
  return resultado;
}
