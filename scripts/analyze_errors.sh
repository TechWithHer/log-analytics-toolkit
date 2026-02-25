#!/bin/bash

echo "========== Log Analysis Summary =========="
LOG_FILE=$1
echo "Verifying log file destination..."
sleep 3
echo "Reading the file $1..."
sleep 3
echo "Please note: ERROR_THRESHOLD=20"
sleep 3
if [ ! -e "$1" ]; then
  echo "[ERROR] log file/path is incorrect: $1"
  exit 2
fi

lines=$(wc -l <"$LOG_FILE")
echo "LINES Count: $lines"

errors=$(grep "ERROR" "$LOG_FILE" | wc -l)
echo "ERROR Count: $errors"

warning=$(grep "WARNING" "$LOG_FILE" | wc -l)
echo "WARNING Count: $warning"

critical=$(grep "CRITICAL" "$LOG_FILE" | wc -l)
echo "CRITICAL Count: $critical"

if [[ $errors -ge 20 ]]; then
	echo "ANOMOLY DETECTED, ERROR >= 20"
else
	echo "SYSTEM IS GOOD"
fi

