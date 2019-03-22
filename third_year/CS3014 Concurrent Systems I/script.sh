#!/bin/sh

INPUTS=$@
echo "Enter the number of iterations:"
read ITER

OUTPUT="timing.txt"
FUNCTION=`cat conv-harness.c`
I=1
TOTAL_TIME=0

make 

while [ $I -le $ITER ]
do
	TIME=`./conv-harness $INPUTS | tr ' ' '\n' | grep -E '^[0-9]+'`
	TOTAL_TIME=`expr $TOTAL_TIME + $TIME`
	I=`expr $I + 1`
done	

TIME=`expr $TOTAL_TIME / $ITER`
echo "The function was:\n${FUNCTION}\n\n" >> $OUTPUT
echo "Inputs were: ${INPUTS}\n\n" >> $OUTPUT
echo "Iterations: ${ITER}\n\n" >> $OUTPUT
echo "The average time was: ${TIME} microseconds\n\n\n" >> $OUTPUT

python3 simplify.py