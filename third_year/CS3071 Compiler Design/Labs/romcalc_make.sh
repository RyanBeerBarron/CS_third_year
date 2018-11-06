#!/bin/bash
bison -d romcalc.y
flex romcalc.l
gcc romcalc.tab.c lex.yy.c -lfl