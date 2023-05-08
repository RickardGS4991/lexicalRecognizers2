/* Archivo con el reconocedor léxico para la calculadora */
%{
#include<stdlib.h>
#include<math.h>
  /* Se incluye el archivo generado por bison para tener las definiciones
     de los tokens */
#include "calculadoraAsr.tab.h"
%}

LETRA [A-Za-z]
DIGITO [0-9]

%%

{DIGITO}* {yylval.valor = atoi(yytext); return NUM; /* Convierte el NUM a nÃºmero */}
"+"       {return SUMA; /* Se encontró un símbolo de suma */}
"-"       {return RESTA;/* Se encontró un símbolo de resta */}
"*"       {return MULTI;/* Se encontró un símbolo de multiplicación */}
"/"       {return DIVIDE;/* Se encontró un símbolo de división */}
"^"       {return EXPON; /*Se encontró un símbolo de exponenciación*/}
"%"       {return MODU; /*Se encontró un símbolo de modulo*/}
"("       {return PARENI;/* Se encontró un "(" */}
")"       {return PAREND;/* Se encontró un ")" */}
"$"       {return FINEXP;/* Se encontró un $, que es símbolo de fin de expr */}
[ \n\t]   { }
.         {return -1;}

%%
