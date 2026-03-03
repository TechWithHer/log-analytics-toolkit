#!/bin/bash

set -euo pipefail

echo "========== Log Analysis Summary =========="

CONFIG_FILE="./config.cfg"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[ERROR] Config file not found at $CONFIG_FILE"
  exit 3
fi

source "$CONFIG_FILE"

required_vars=(HISTORY_FILE ROLLING_WINDOW Z_THRESHOLD MAX_HISTORY_LINES CRITICAL_THRESHOLD ERROR_THRESHOLD SCRIPT_LOG)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "[ERROR] Missing config variable: $var"
    exit 5
  fi
done

LOG_FILE="${1:-}"

if [[ -z "$LOG_FILE" || ! -f "$LOG_FILE" ]]; then
  echo "[ERROR] Invalid log file path"
  exit 2
fi

start_time=$(date +%s)

# -------------------------------
# Parse Logs
# -------------------------------
lines=$(wc -l < "$LOG_FILE")
errors=$(grep -c "\bERROR\b" "$LOG_FILE" || true)
warnings=$(grep -c "\bWARNING\b" "$LOG_FILE" || true)
critical=$(grep -c "\bCRITICAL\b" "$LOG_FILE" || true)

# -------------------------------
# Prepare History File
# -------------------------------
if [[ ! -f "$HISTORY_FILE" ]]; then
  mkdir -p "$(dirname "$HISTORY_FILE")"
  echo "timestamp,errors,critical,warnings" > "$HISTORY_FILE"
fi

# -------------------------------
# Calculate Statistics
# -------------------------------
data_lines=$(tail -n +2 "$HISTORY_FILE" | tail -n "$ROLLING_WINDOW")

count=$(echo "$data_lines" | wc -l)

mean=0
std_dev=0
z_score=0

if [[ "$count" -gt 1 ]]; then
  mean=$(echo "$data_lines" | awk -F ',' '{sum+=$2} END{print sum/NR}')
  std_dev=$(echo "$data_lines" | awk -F ',' -v mean="$mean" '{sum+=($2-mean)^2} END{print sqrt(sum/NR)}')

  if [[ "$std_dev" != "0" ]]; then
    z_score=$(echo "scale=4; ($errors - $mean)/$std_dev" | bc -l)
  fi
fi

abs_z=$(echo "$z_score" | awk '{print ($1<0)?-$1:$1}')

# -------------------------------
# Determine Status
# Priority: CRITICAL > THRESHOLD > ANOMALY > OK
# -------------------------------
STATUS="OK"
EXIT_CODE=0

if [[ "$critical" -ge "$CRITICAL_THRESHOLD" ]]; then
  STATUS="CRITICAL"
  EXIT_CODE=2

elif [[ "$errors" -ge "$ERROR_THRESHOLD" ]]; then
  STATUS="WARNING"
  EXIT_CODE=1

elif (( $(echo "$abs_z > $Z_THRESHOLD" | bc -l) )); then
  STATUS="ANOMALY"
  EXIT_CODE=1
fi

# -------------------------------
# Update History (after calculation)
# -------------------------------
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo "$timestamp,$errors,$critical,$warnings" >> "$HISTORY_FILE"

{
  head -n 1 "$HISTORY_FILE"
  tail -n "$MAX_HISTORY_LINES" "$HISTORY_FILE"
} > temp && mv temp "$HISTORY_FILE"

# -------------------------------
# Runtime + Logging
# -------------------------------
end_time=$(date +%s)
runtime=$((end_time - start_time))

mkdir -p "$(dirname "$SCRIPT_LOG")"
echo "$(date) | Status: $STATUS | Errors: $errors | Critical: $critical | Z: $z_score | Runtime: ${runtime}s" >> "$SCRIPT_LOG"

# -------------------------------
# Output Summary
# -------------------------------
echo "Total Lines: $lines"
echo "Errors: $errors | Critical: $critical | Warnings: $warnings"
echo "Mean: $mean | StdDev: $std_dev | Z-Score: $z_score"
echo "Runtime: ${runtime}s"
echo "SYSTEM STATUS: $STATUS"
echo "=========================================="

exit $EXIT_CODE