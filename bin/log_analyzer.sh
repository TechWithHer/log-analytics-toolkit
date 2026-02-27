#!/bin/bash

echo "========== Log Analysis Summary =========="

# Load Config
CONFIG_FILE="/Users/apple/desktop/TechWithHer/log-analytics-toolkit/config
/config.cfg"

if [[ ! -e "$CONFIG_FILE" ]]; then
  echo "[ERROR] Config file not found!"
  exit 3
fi

source "$CONFIG_FILE"
LOG_FILE="$1"

# -------------------------------
# Validate Input
validate_input() {
  if [[ -z "$LOG_FILE" || ! -f "$LOG_FILE" ]]; then
    echo "[ERROR] Invalid log file path."
    exit 2
  fi
}

# -------------------------------
# Parse Logs
parse_logs() {
  lines=$(wc -l < "$LOG_FILE")
  errors=$(grep -c "ERROR" "$LOG_FILE")
  warning=$(grep -c "WARNING" "$LOG_FILE")
  critical=$(grep -c "CRITICAL" "$LOG_FILE")
}

# -------------------------------
# Prepare History File
prepare_history() {
  if [[ ! -f "$HISTORY_FILE" ]]; then
    mkdir -p "$(dirname "$HISTORY_FILE")"
    echo "timestamp,errors,critical,warning" > "$HISTORY_FILE"
  fi
}

# -------------------------------
# Calculate Statistics
calculate_stats() {
  last_values=$(tail -n "$ROLLING_WINDOW" "$HISTORY_FILE" | awk -F ',' '{print $2}')

  mean=$(echo "$last_values" | awk '
  { sum += $1 }
  END { if (NR > 0) print sum / NR; else print 0 }')

  std_dev=$(echo "$last_values" | awk -v mean="$mean" '
  { sum += ($1 - mean)^2 }
  END { if (NR > 0) print sqrt(sum / NR); else print 0 }')
}

# -------------------------------
# Detect Anomaly
detect_anomaly() {
  if [[ "$std_dev" == "0" ]]; then
    echo "Not enough variation to calculate anomaly."
    return
  fi

  z_score=$(echo "scale=4; ($errors - $mean) / $std_dev" | bc -l)

  abs_z=$(echo "$z_score" | awk '{print ($1<0)?-$1:$1}')

  if (( $(echo "$abs_z > $Z_THRESHOLD" | bc -l) )); then
    echo "ALERT: Statistical anomaly detected! Z-Score: $z_score"
  fi
}

# -------------------------------
# Update History
update_history() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp,$errors,$critical,$warning" >> "$HISTORY_FILE"

  # Retention control
  tail -n "$MAX_HISTORY_LINES" "$HISTORY_FILE" > temp && mv temp "$HISTORY_FILE"
}

# -------------------------------
# Determine Status
determine_status() {
  STATUS="OK"
  EXIT_CODE=0

  if [[ $critical -ge $CRITICAL_THRESHOLD ]]; then
    STATUS="CRITICAL"
    EXIT_CODE=2
  elif [[ $errors -ge $ERROR_THRESHOLD ]]; then
    STATUS="WARNING"
    EXIT_CODE=1
  fi
}

# -------------------------------
# Log Execution
log_execution() {
  mkdir -p "$(dirname "$SCRIPT_LOG")"
  echo "$(date) | File: $LOG_FILE | Status: $STATUS | Errors: $errors | Critical: $critical" >> "$SCRIPT_LOG"
}

# -------------------------------
# MAIN EXECUTION FLOW
validate_input
parse_logs
prepare_history
calculate_stats
detect_anomaly
determine_status
update_history
log_execution

echo "SYSTEM STATUS: $STATUS"
echo "=========================================="

exit $EXIT_CODE
