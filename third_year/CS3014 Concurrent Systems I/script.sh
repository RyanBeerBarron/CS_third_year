#!/bin/sh

# Add length input managing, if not provided, just do 1, else, run the program that number of times
# and write correct iterations and average time.
# Change syntax for time 

OUTPUT="timing.txt"
FUNCTION=`cat conv-harness.c | pcregrep -M 'void\ team_conv(.|\n)*(^}\n\n)'`
INPUTS=$@
TIME=`./conv-harness $INPUTS | grep Team`

echo "The function was:\n$FUNCTION\n" >> $OUTPUT
echo "Inputs were: $INPUTS\n" >> $OUTPUT
echo "Iterations: 1\n" >> $OUTPUT
echo "Time was: $TIME\n\n" >> $OUTPUT
