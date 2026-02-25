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

#Step 2: Check if argument is provided and if provided, the path is valid
if [ -z "LOG_FILE" ] && [ ! -e "$1" ]; then
  echo "[ERROR] log file/path is incorrect: $1. Please provide a valid path"
  exit 2
fi

#Step 3: Define Threshold Values

ERROR_THRESHOLD=20
CRITICAL_THRESHOLD=5

#Step 4: Count Log Entries
lines=$(wc -l <"$LOG_FILE")
echo "LINES Count: $lines"
errors=$(grep "ERROR" "$LOG_FILE" | wc -l)
echo "ERROR Count: $errors"
warning=$(grep "WARNING" "$LOG_FILE" | wc -l)
echo "WARNING Count: $warning"
critical=$(grep "CRITICAL" "$LOG_FILE" | wc -l)
echo "CRITICAL Count: $critical"

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

#Step 6: Log Execution Result 
SCRIPT_LOG="analytics.log"

echo "$(date) | File:"$LOG_FILE" | Status: $STATUS | Errors: $errors | Critical: $critical" >> SCRIPT_LOG

#Step 7: Trigger Alert
if [[ "$STATUS" != "OK" ]]; then
    echo "ALERT: $STATUS detected in $LOG_FILE"
fi

echo "=========================================="


#Step 8: Exit with Proper Code
exit $EXIT_CODE
