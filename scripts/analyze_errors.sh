#!/bin/bash

echo "========== Log Analysis Summary =========="

#Step 1: Accept an Argument.
LOG_FILE=$1

#Verbose
echo "Verifying log file destination..."
sleep 3
echo "Reading the file $1..."
sleep 3
echo "Please note: ERROR_THRESHOLD=20"
sleep 3

#------------------------------------------------

#Step 2: Check if argument is provided and if provided, the path is valid
if [ -z "LOG_FILE" ] || [ ! -e "$1" ]; then
  echo "[ERROR] log file/path is incorrect: $1. Please provide a valid path"
  exit 2
fi

#------------------------------------------------

#Step 3: Define Threshold Values
ERROR_THRESHOLD=20
CRITICAL_THRESHOLD=5

#------------------------------------------------

#Step 4: Count Log Entries
lines=$(wc -l <"$LOG_FILE")
echo "LINES Count: $lines"
errors=$(grep "ERROR" "$LOG_FILE" | wc -l)
echo "ERROR Count: $errors"
warning=$(grep "WARNING" "$LOG_FILE" | wc -l)
echo "WARNING Count: $warning"
critical=$(grep "CRITICAL" "$LOG_FILE" | wc -l)
echo "CRITICAL Count: $critical"

#------------------------------------------------

#Step 4.1:Creating History File Logic
HISTORY_FILE="run_history.csv"
if [ ! -f "$HISTORY_FILE" ]; then
        echo "timestamp,errors,critical,warning" > "$HISTORY_FILE"
fi
timestamp=$(date +"%Y-%m-%d  %H:%M:%S")
echo "$timestamp,$errors,$critical,$warning" >> "$HISTORY_FILE"

#-------------------------------------------------

#Step 4.2: Get Last 10 Error Counts
last_10_values=$(tail -n 11 "$HISTORY_FILE" | tail -n 10 | awk -F ',' '{print $2}' )

#-------------------------------------------------

#Step 4.3: Calculate Mean
mean=$(echo "$last_10_values" | awk '
{
    sum += $1
}
END {
    if (NR > 0)
        print sum / NR
}')


#-------------------------------------------------

#Step 4.4:Calculate Standard Deviation and Error Handling
std_dev=$(echo "$last_10_values" | awk -v mean="$mean" '
{
    sum += ($1 - mean)^2
}
END {
    if (NR > 0)
        print sqrt(sum / NR)
}')

if (( $(echo "$std_dev == 0" | bc -l) )); then
    echo "Not enough variation to calculate anomaly."
    exit 0
fi

#-------------------------------------------------

#Step 4.5:Calculate Z-Score
z_score=$(echo "scale=4; ($errors - $mean) / $std_dev" | bc -l)

#-------------------------------------------------

#Step 4.6:Alert Logic
threshold=2

if (( $(echo "$z_score > $threshold" | bc -l) )); then
    echo "ALERT: Statistical anomaly detected!"
fi

if (( $(echo "$z_score > $threshold" | bc -l) )); then
    echo "ALERT: Statistical anomaly detected! Z-Score: $z_score"
fi
#-------------------------------------------------

#Step 5: Determine System Status
STATUS="OK"
EXIT_CODE=0
if [[ $critical -ge $CRITICAL_THRESHOLD ]]; then
    STATUS="CRITICAL"
    EXIT_CODE=2
elif [[ $errors -ge $ERROR_THRESHOLD ]]; then
    STATUS="WARNING"
    EXIT_CODE=1
else
    STATUS="OK"
    EXIT_CODE=0
fi

echo "SYSTEM STATUS: $STATUS"

#------------------------------------------------

#Step 6: Log Execution Result 
SCRIPT_LOG="analytics.log"
echo "$(date) | File:"$LOG_FILE" | Status: $STATUS | Errors: $errors | Critical: $critical" >> '$SCRIPT_LOG'

#------------------------------------------------

#Step 7: Trigger Alert
if [[ "$STATUS" != "OK" ]]; then
    echo "ALERT: $STATUS detected in $LOG_FILE"
fi
echo "=========================================="

#------------------------------------------------

#Step 8: Exit with Proper Code
exit $EXIT_CODE

#------------------------------------------------



