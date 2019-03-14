#!/bin/sh

OUTPUT="timing.txt"
FUNCTION=`cat conv-harness.c | pcregrep -M 'void\ team_conv(.|\n)*(^}\n\n)'`
INPUTS=$@
TIME=`./conv-harness $INPUTS | grep Team`

echo "The function was:\n$FUNCTION\n" >> $OUTPUT
echo "Inputs were: $INPUTS\n" >> $OUTPUT
echo "Iterations: 1\n" >> $OUTPUT
echo "Time was: $TIME\n\n" >> $OUTPUT
