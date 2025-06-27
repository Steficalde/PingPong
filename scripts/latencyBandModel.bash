#! /bin/bash
# Expect protocol name as first parameter (tcp or udp)

# Define input and output file names
ThroughFile="../data/$1_throughput.dat";
PngName="../data/LB$1.png";

#getting the first and the last line of the file
HeadLine=($(head $ThroughFile --lines=1))
TailLine=($(tail $ThroughFile --lines=1))

#getting the information from the first and the last line
FirstN=${HeadLine[0]}
LastN=${TailLine[0]}

# TO BE DONE START

FirstParam=$1

ThroughFirst=${HeadLine[1]}
ThroughLast=${TailLine[1]}

DelayFirst=$(echo "$FirstN / $ThroughFirst" | bc -l)
DelayLast=$(echo "$LastN / $ThroughLast" | bc -l)


Band=$(echo "($LastN - $FirstN) / ($DelayLast - $DelayFirst)" | bc -l)
Latency=$(echo "($DelayFirst * $LastN - $DelayLast * $FirstN) / ($LastN - $FirstN)" | bc -l)


# TO BE DONE END


# Plotting the results
gnuplot <<-eNDgNUPLOTcOMMAND
  set term png size 900, 700
  set output "${PngName}"
  set logscale x 2
  set logscale y 10
  set xlabel "msg size (B)"
  set ylabel "throughput (KB/s)"
  set xrange[$FirstN:$LastN]
  lbmodel(x)= x / ($Latency + (x/$Band))

# TO BE DONE START
 set key out above
 plot "${ThroughFile}" using 1:2 title "median Throughput" with linespoints, \
       lbmodel(x) title "${FirstParam} Latency-Bandwidth Model with L=${Latency} and B=${Band}" with linespoints
# TO BE DONE END

  clear

eNDgNUPLOTcOMMAND
