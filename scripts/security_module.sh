#!/bin/bash

LOG_FILE="../logs/nginx.log"

echo "===== Brute Force Detection ====="

grep ' 401 ' $LOG_FILE | awk '{print $1}' | sort | uniq -c | awk '$1 > 5'