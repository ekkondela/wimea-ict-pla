#! /bin/bash
x=$3           # samples
tw=$4          # time window
dt=$(($tw/$x)) # time interval
j=$tw          # window interval
dt=1 
INTERVAL1=3     # sleep time
INTERVAL2=0
MODEM1=/dev/$1
MODEM2=/dev/$2
MODEMCMD=AT+CSQ
LOGFILE1=./PLA/link_RS1.dat
LOGFILE2=./PLA/link_RS2.dat
ARR_RS1=./PLA/arr_RS1.dat
ARR_RS2=./PLA/arr_RS2.dat
MAINFILE=./PLA/pla_mean_modal.dat

# first modem
wrmodem1 () {
    echo -ne "$*"'\r\n' >"$MODEM1"
    #log "--- sent: $*"
}
# logger
{
    trap 'log "=== logger stopped $BASHPID"' EXIT
    #log "=== logger started: $BASHPID"
    while true ; do
        if read ; then
            echo $REPLY | grep '+CSQ:' | awk -F'[ , ]+' '/+CSQ/{c=($2*2)-113} END {print c}' >> ./PLA/arrRS1.dat
            echo $REPLY | grep '+CSQ:' | awk -F'[ , ]+' '/+CSQ/{c=($2*2)-113} END {print c}' >> $LOGFILE1
        fi
    done
} < "$MODEM1" &
LOGGERPID=$!
trap 'kill $LOGGERPID' EXIT

# second modem
wrmodem2 () {
    echo -ne "$*"'\r\n' >"$MODEM2"
    #log "--- sent: $*"
}
# logger
{
    trap 'log "=== logger stopped $BASHPID"' EXIT
    #log "=== logger started: $BASHPID"
    while true ; do
        if read ; then
            echo $REPLY | grep '+CSQ:' | awk -F'[ , ]+' '/+CSQ/{c=($2*2)-113} END {print c}' >> ./PLA/arrRS2.dat
            echo $REPLY | grep '+CSQ:' | awk -F'[ , ]+' '/+CSQ/{c=($2*2)-113} END {print c}' >> $LOGFILE2
        fi
    done
} < "$MODEM2" &
LOGGERPID=$!
trap 'kill $LOGGERPID' EXIT


while true
do
  if [ $dt -le $tw ]
  then
    #echo "record RSSI values from several links Li,L2,L3, ... and insert into arrays"
    date +"%Y-%m-%d %T $di" >> $LOGFILE1
    wrmodem1 "$MODEMCMD"
    
    date +"%Y-%m-%d %T $di" >> $LOGFILE2
    wrmodem2 "$MODEMCMD"

    echo "sample $dt"   # print sample value
    
    sleep $INTERVAL1
    
    if [ $dt -eq $tw ]
    then
      #sleep $INTERVAL2
       
      echo "compute mean, SD, SEmean, SEpla, IntervalPLA at $tw"
      awk 'NF > 0' ./Data/arrRS1.dat > $ARR_RS1
      awk 'NF > 0' ./Data/arrRS2.dat > $ARR_RS2
      
      date +"%Y-%m-%d %T" | tr '\n' ' ' >> $MAINFILE
      echo "calculate predicted sample mean X"
      echo "|Mean:" | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
    
      RS_MEAN1="$(awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS1)"
      echo "$RS_MEAN1"
      #ADD=$(echo "scale=3; $SQ_MEAN1 + $RS_MEAN1" | bc)
      #echo "$ADD"
      echo "${RS_MEAN1%.f}"
      RS_MEAN2="$(awk 'BEGIN{s=0;}{s = s + $1;}END{print s/NR;}' $ARR_RS2)"
      echo "$RS_MEAN2"
      #ADD=$(echo "scale=3; $SQ_MEAN2 + $RS_MEAN2" | bc)
      #echo "$ADD"
      echo "${RS_MEAN2%.f}"

      echo "compute sample standard deviation (s)"
      echo "|SD:" | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      
      RS_SD1="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS1)"
      #echo ${RS_SD1%.f} | tr '\n' ' ' >> ./Data/rs_mean_modal.dat
      echo ${RS_SD1%.f}
      RS_SD2="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1); }' $ARR_RS2)"
      #echo ${RS_SD2%.f} | tr '\n' ' ' >> ./Data/rs_mean_modal.dat
      echo ${RS_SD2%.f}
      
      echo "compute standard error mean (SEmean) = s/sqrt(n)"
      echo "|SEmean:" | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
     
      RS_SEmean1="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS1)"
      echo "$RS_SEmean1"
      RS_SEmean2="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1)/sqrt(NR); }' $ARR_RS2)"
      echo "$RS_SEmean2"
      
      echo "compute standard error of predicted link availability (SEpla3) = s*sqrt(1+1/n)"
      echo "|SEPLA:" | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      
      RS_SEpla1="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS1)"
      echo "$RS_SEpla1"
      RS_SEpla2="$(awk '{delta = $1 - avg; avg += delta / NR-1; mean2 += delta * ($1 - avg); } END { print sqrt(mean2 / NR-1) * sqrt(1+1/(NR)); }' $ARR_RS2)"
      echo "$RS_SEpla2"
      
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
      echo "$RS_INTERVAL1"
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
      echo "$RS_INTERVAL2"
      echo "============="
        
      echo "compute mean, SD, SEmean, SEpla, IntervalPLA for the next $tw seconds at $(($tw+$j))"
      
      echo "calculate probability of samples x or integral area"
      echo "|Integral:" | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;t=0;p=0;}{t = $1*1+113;}{s = s + t/2;}{p=s/310;}END{print p;}' $ARR_RS1 | tr '\n' ' ' >> $MAINFILE
      awk 'BEGIN{s=0;t=0;p=0;}{t = $1*1+113;}{s = s + t/2;}{p=s/310;}END{print p;}' $ARR_RS2 | tr '\n' ' ' >> $MAINFILE
      
      echo "routing decision"
      echo "|Routing:" | tr '\n' ' ' >> $MAINFILE
     
      if [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      then
        echo "0" | tr '\n' ' ' >> $MAINFILE 
        echo "1" >> $MAINFILE 
      elif [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -lt ${RS_INTERVAL2%.*} ]]
      then
        echo "1" | tr '\n' ' ' >> $MAINFILE 
        echo "0" >> $MAINFILE    
      elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      then
        echo "0" | tr '\n' ' '>> $MAINFILE 
        echo "10" >> $MAINFILE    
      elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -le ${RS_INTERVAL2%.*} ]]
      then
        echo "10" | tr '\n' ' ' >> $MAINFILE 
        echo "0"  >> $MAINFILE 
      #  
      elif [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      then
        echo "0" | tr '\n' ' ' >> $MAINFILE 
        echo "10" >> $MAINFILE    
      elif [[ ${RS_MEAN1%.*} -gt -86 ]] && [[ ${RS_MEAN2%.*} -le -86 ]] && [[ ${RS_INTERVAL1%.*} -le ${RS_INTERVAL2%.*} ]]
      then
        echo "1" | tr '\n' ' ' >> $MAINFILE 
        echo "0" >> $MAINFILE 
      #
      elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -gt ${RS_INTERVAL2%.*} ]]
      then
        echo "0" | tr '\n' ' ' >> $MAINFILE 
        echo "1" >> $MAINFILE    
      elif [[ ${RS_MEAN1%.*} -le -86 ]] && [[ ${RS_MEAN2%.*} -gt -86 ]] && [[ ${RS_INTERVAL1%.*} -le ${RS_INTERVAL2%.*} ]]
      then
        echo "10" | tr '\n' ' ' >> $MAINFILE 
        echo "0" >> $MAINFILE         
      else
        echo "Undefined" | tr '\n' ' ' >> $MAINFILE 
        echo "Undefined" >> $MAINFILE    
      fi
      
      j=$(($j+10))
      
      echo "delete lines from memory array's files"
      sudo rm -f ./PLA/arrRS1.dat
      sudo rm -f $ARR_RS1
      sudo rm -f ./PLA/arrRS2.dat
      sudo rm -f $ARR_RS2
    fi        
    dt=$(($dt + 1))
    di=$(($di + 1))
  else
    dt=$(($tw/$x))
  fi
done

