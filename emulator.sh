#! /bin/bash
x=$1              # samples        $x  = 10
tw=$2              # time window    $tw = 10
dt=$(($tw/$x))   # time interval  $dt
j=$tw          # window interval
INTERVAL1=1     # sleep time     

LOGFILE1=./Emulator/rs1.dat
LOGFILE2=./Emulator/rs2.dat
ARR_RS1=./Emulator/arr_RS1.dat
ARR_RS2=./Emulator/arr_RS2.dat
MAINFILE=./Emulator/statistics.dat
 
while true
do

  if [ $dt -le $tw ]
  then
    date +"%Y-%m-%d %T $di" >> $LOGFILE1 >> $LOGFILE2
    echo "sample $dt"
    echo "$((-113 + $RANDOM % -51))" >> ./Emulator/arrRS1.dat | tr '\n' ' ' >> $LOGFILE1
    echo "$((-113 + $RANDOM % -51))" >> ./Emulator/arrRS2.dat | tr '\n' ' ' >> $LOGFILE2
    sleep $INTERVAL1

    if [ $dt -eq $tw ]
    then
      echo "compute mean, SD, SEmean, SEpla, IntervalPLA at $tw" 
      awk 'NF > 0' ./Emulator/arrRS1.dat > $ARR_RS1
      awk 'NF > 0' ./Emulator/arrRS2.dat > $ARR_RS2

      date +"%Y-%m-%d %T" | tr '\n' ' ' >> $MAINFILE
      echo "calculate predicted sample mean X"
      echo "|Mean:" | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE

      RS_MEAN1="$(awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS1)"
      echo "Mean1 $RS_MEAN1"
      #ADD=$(echo "scale=3; $SQ_MEAN1 + $RS_MEAN1" | bc)
      #echo "$ADD"
      #echo "Mean1 ${RS_MEAN1%.f}"
      RS_MEAN2="$(awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS2)"
      echo "Mean2 $RS_MEAN2"
      #ADD=$(echo "scale=3; $SQ_MEAN2 + $RS_MEAN2" | bc)
      #echo "$ADD"
      #echo "Mean2 ${RS_MEAN2%.f}"

      echo "compute sample standard deviation (s)"
      echo "|SD:" | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      
      RS_SD1="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS1)"
      #echo $RS_SD1
      #echo ${RS_SD1%.f} | tr '\n' ' ' >> ./Data/rs_mean_modal.dat
      echo "SD1 ${RS_SD1%.f}"
      RS_SD2="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS2)"
      #echo ${RS_SD2%.f} | tr '\n' ' ' >> ./Data/rs_mean_modal.dat
      echo "SD2 ${RS_SD2%.f}"

      echo "compute standard error mean (SEmean) = s/sqrt(n)"
      echo "|SEmean:" | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
     
      RS_SEmean1="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS1)"
      echo "SEMean1 $RS_SEmean1"
      RS_SEmean2="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS2)"
      echo "SEMean2 $RS_SEmean2"

      echo "compute standard error of predicted link availability (SEpla3) = s*sqrt(1+1/n)"
      echo "|SEPLA:" | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      
      RS_SEpla1="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS1)"
      echo "SEPLA1 $RS_SEpla1"
      RS_SEpla2="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS2)"
      echo "SEPLA2 $RS_SEpla2"


      echo "compute 95% of prediction interval = X +/- t-value *s*sqrt(1+1/n)"    
      echo "|INTERVAL1:" | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) - (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) + (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS1 | tr '\n' ' '>> $MAINFILE
      
      RS_MIN_INTERVAL1="$(awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) - (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS1)"
      echo "$RS_MIN_INTERVAL1"
      RS_MAX_INTERVAL1="$(awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) + (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS1)"
      echo "$RS_MAX_INTERVAL1"
      echo "============="
      RS_INTERVAL1=$(echo "scale=3; $RS_MAX_INTERVAL1 - $RS_MIN_INTERVAL1" | bc)
      echo "Interval1 $RS_INTERVAL1"
      echo "============="

      
      echo "|INTERVAL2:" | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) - (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) + (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS2 | tr '\n' ' '>> $MAINFILE
      
      RS_MIN_INTERVAL2="$(awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) - (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS2)"
      echo "$RS_MIN_INTERVAL2"
      RS_MAX_INTERVAL2="$(awk 'BEGIN{s=0;}{s=s+$1;delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg);} END {print (s/NR) + (2.262) * ( sqrt(mean2 / NR-1) * sqrt(1+1/(NR)) );}' $ARR_RS2)"
      echo "$RS_MAX_INTERVAL2"
      echo "============="
      RS_INTERVAL2=$(echo "scale=3; $RS_MAX_INTERVAL2 - $RS_MIN_INTERVAL2" | bc)
      echo "Interval2 $RS_INTERVAL2"
      echo "============="


      echo "compute mean, SD, SEmean, SEpla, IntervalPLA for the next $tw seconds at $(($tw+$j))"
      
      echo "calculate probability of samples x or integral area"
      echo "|Integral:" | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;t=0;p=0;}{t = $1*1+113;}{s = s + t/2;}{p=s/310;}END{print p;}' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;t=0;p=0;}{t = $1*1+113;}{s = s + t/2;}{p=s/310;}END{print p;}' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      
      echo "routing decision"
      echo "|Routing:" | tr '\n' ' ' >> $MAINFILE
      echo "|Routing:" >> $MAINFILE
     
      #if [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "0" | tr '\n' ' ' >> $MAINFILE 
      #  echo "1" >> $MAINFILE 
      #elif [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -lt ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "1" | tr '\n' ' ' >> $MAINFILE 
      #  echo "0" >> $MAINFILE    
      #elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "0" | tr '\n' ' '>> $MAINFILE 
      #  echo "10" >> $MAINFILE    
      #elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -le ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "10" | tr '\n' ' ' >> $MAINFILE 
      #  echo "0"  >> $MAINFILE 
      ##  
      #elif [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "0" | tr '\n' ' ' >> $MAINFILE 
      #  echo "10" >> $MAINFILE    
      #elif [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -le ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "1" | tr '\n' ' ' >> $MAINFILE 
      #  echo "0" >> $MAINFILE 
      ##
      #elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "0" | tr '\n' ' ' >> $MAINFILE 
      #  echo "1" >> $MAINFILE    
      #elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -le ${RS_INTERVAL2%.*} ]]
      #then
      #  echo "10" | tr '\n' ' ' >> $MAINFILE 
      #  echo "0" >> $MAINFILE         
      #else
      #  echo "Undefined" | tr '\n' ' ' >> $MAINFILE 
      #  echo "Undefined" >> $MAINFILE    
      #fi


      j=$(($j+10))
      echo $j
      
      echo "delete lines from memory array's files"
      sudo rm -f ./Emulator/arrRS1.dat
      sudo rm -f $ARR_RS1
      sudo rm -f ./Emulator/arrRS2.dat
      sudo rm -f $ARR_RS2  
      
    fi        
      dt=$(($dt + 1))
  else
    dt=$(($tw/$x))
  fi

done
