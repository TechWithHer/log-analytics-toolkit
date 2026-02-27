#!/bin/bash

# ======================================================
# Log Analysis Script - Production Ready
# ======================================================

# -------------------------------
# Script Header
echo "========== Log Analysis Summary =========="

# -------------------------------
# Load Configuration
CONFIG_FILE="/Users/apple/Desktop/TechWithHer/log-analytics-toolkit/config.cfg"

# Check if configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[ERROR] Config file not found at $CONFIG_FILE"
  exit 3
fi

# Load variables from config
source "$CONFIG_FILE"

# -------------------------------
# Validate Required Config Variables
required_vars=(HISTORY_FILE ROLLING_WINDOW Z_THRESHOLD MAX_HISTORY_LINES CRITICAL_THRESHOLD ERROR_THRESHOLD SCRIPT_LOG)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "[ERROR] Missing config variable: $var"
    exit 5
  fi
done

# -------------------------------
# Get Log File from Command Line Argument
LOG_FILE="$1"

# Function: Validate Input Log File
validate_input() {
  if [[ -z "$LOG_FILE" || ! -f "$LOG_FILE" ]]; then
    echo "[ERROR] Invalid log file path: $LOG_FILE"
    exit 2
  fi
}

# Function: Parse Logs and Count Entries
parse_logs() {
  # Total lines in log
  lines=$(wc -l < "$LOG_FILE")

  # Count errors strictly
  errors=$(grep -c "\bERROR\b" "$LOG_FILE")
  warnings=$(grep -c "\bWARNING\b" "$LOG_FILE")
  critical=$(grep -c "\bCRITICAL\b" "$LOG_FILE")
}

# Function: Prepare History File (for statistics)
prepare_history() {
  # If history file does not exist, create with header
  if [[ ! -f "$HISTORY_FILE" ]]; then
    mkdir -p "$(dirname "$HISTORY_FILE")"
    echo "timestamp,errors,critical,warning" > "$HISTORY_FILE"
  fi
}

# Function: Calculate Statistics (mean & std deviation for anomaly detection)
calculate_stats() {
  # Get last N error values (skip header)
  last_values=$(tail -n "$ROLLING_WINDOW" "$HISTORY_FILE" | awk -F ',' 'NR>1 {print $2}')

  # Mean calculation
  mean=$(echo "$last_values" | awk '
    { sum += $1 }
    END { if (NR > 0) print sum / NR; else print 0 }'
  )

  # Standard deviation calculation
  std_dev=$(echo "$last_values" | awk -v mean="$mean" '
    { sum += ($1 - mean)^2 }
    END { if (NR > 0) print sqrt(sum / NR); else print 0 }'
  )
}

# Function: Detect Statistical Anomaly
detect_anomaly() {
  if [[ "$std_dev" == "0" ]]; then
    echo "Not enough variation to calculate anomaly."
    return
  fi

  # Z-score calculation
  z_score=$(echo "scale=4; ($errors - $mean) / $std_dev" | bc -l)

  # Absolute value
  abs_z=$(echo "$z_score" | awk '{print ($1<0)?-$1:$1}')

  # Compare against threshold
  if (( $(echo "$abs_z > $Z_THRESHOLD" | bc -l) )); then
    echo "ALERT: Statistical anomaly detected! Z-Score: $z_score"
  fi
}

# Function: Update History File
update_history() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp,$errors,$critical,$warnings" >> "$HISTORY_FILE"

  # Retain only last MAX_HISTORY_LINES + 1 (header)
  {
    head -n 1 "$HISTORY_FILE"          # Keep header
    tail -n "$MAX_HISTORY_LINES" "$HISTORY_FILE"
  } > temp && mv temp "$HISTORY_FILE"
}

# Function: Determine System Status
determine_status() {
  STATUS="OK"
  EXIT_CODE=0

  if [[ "$critical" -ge "$CRITICAL_THRESHOLD" ]]; then
    STATUS="CRITICAL"
    EXIT_CODE=2
  elif [[ "$errors" -ge "$ERROR_THRESHOLD" ]]; then
    STATUS="WARNING"
    EXIT_CODE=1
  fi
}

# Function: Log Execution to Script Log
log_execution() {
  mkdir -p "$(dirname "$SCRIPT_LOG")"
  echo "$(date) | File: $LOG_FILE | Status: $STATUS | Errors: $errors | Critical: $critical" >> "$SCRIPT_LOG"
}

# ======================================================
# MAIN EXECUTION FLOW
# ======================================================
validate_input
parse_logs
prepare_history
calculate_stats
detect_anomaly
determine_status
update_history
log_execution

# Display Status Summary
echo "SYSTEM STATUS: $STATUS"
echo "=========================================="

exit $EXIT_CODE
