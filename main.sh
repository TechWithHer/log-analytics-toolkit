#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="runtime_logs/app.log"
HISTORY_FILE="runtime_logs/run_history.csv"
SCRIPT_LOG="runtime_logs/script_log.log"

ERROR_THRESHOLD=20
CRITICAL_THRESHOLD=5
Z_THRESHOLD=2
ROLLING_WINDOW=10
MAX_HISTORY_LINES=20


# --------------------------------------------------
# Validate
# --------------------------------------------------

if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Log file not found: $LOG_FILE"
    exit 2
fi

mkdir -p runtime_logs


# --------------------------------------------------
# Analyze logs
# --------------------------------------------------

total_lines=$(wc -l < "$LOG_FILE")

errors=$(grep -c " ERROR " "$LOG_FILE" || true)
warnings=$(grep -c " WARNING " "$LOG_FILE" || true)
critical=$(grep -c " CRITICAL " "$LOG_FILE" || true)


# --------------------------------------------------
# Prepare history
# --------------------------------------------------

if [[ ! -f "$HISTORY_FILE" ]]; then
    echo "timestamp,errors,critical,warnings" > "$HISTORY_FILE"
fi


# --------------------------------------------------
# Calculate baseline
# --------------------------------------------------

history=$(tail -n "$ROLLING_WINDOW" "$HISTORY_FILE" | tail -n +2)
count=$(printf '%s\n' "$history" | grep -c . || true)

mean=0
std_dev=0
z_score=0

if [[ "$count" -gt 1 ]]; then

    mean=$(printf '%s\n' "$history" |
        awk -F',' '{sum += $2} END {printf "%.2f", sum / NR}')

    std_dev=$(printf '%s\n' "$history" |
        awk -F',' -v mean="$mean" \
        '{sum += ($2 - mean)^2}
         END {printf "%.2f", sqrt(sum / NR)}')

    if [[ "$std_dev" != "0.00" ]]; then
        z_score=$(awk \
            -v errors="$errors" \
            -v mean="$mean" \
            -v std="$std_dev" \
            'BEGIN {
                printf "%.2f", (errors - mean) / std
            }')
    fi
fi


# --------------------------------------------------
# Determine status
# --------------------------------------------------

status="OK"
exit_code=0

abs_z=$(awk -v z="$z_score" \
    'BEGIN { print (z < 0) ? -z : z }')

if [[ "$critical" -ge "$CRITICAL_THRESHOLD" ]]; then
    status="CRITICAL"
    exit_code=2

elif [[ "$errors" -ge "$ERROR_THRESHOLD" ]]; then
    status="WARNING"
    exit_code=1

elif awk -v z="$abs_z" -v threshold="$Z_THRESHOLD" \
    'BEGIN { exit !(z > threshold) }'; then
    status="ANOMALY"
    exit_code=1
fi


# --------------------------------------------------
# Update history
# --------------------------------------------------

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo "$timestamp,$errors,$critical,$warnings" >> "$HISTORY_FILE"

{
    head -n 1 "$HISTORY_FILE"
    tail -n "$MAX_HISTORY_LINES" "$HISTORY_FILE"
} > "${HISTORY_FILE}.tmp"

mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"


# --------------------------------------------------
# Runtime log
# --------------------------------------------------

echo "$timestamp | status=$status errors=$errors critical=$critical z_score=$z_score" \
    >> "$SCRIPT_LOG"


# --------------------------------------------------
# Output
# --------------------------------------------------

cat <<EOF

========== Log Analysis ==========
Log file      : $LOG_FILE
Total lines   : $total_lines
Errors        : $errors
Warnings      : $warnings
Critical      : $critical

Mean errors   : $mean
Std deviation : $std_dev
Z-score       : $z_score

System status : $status
===================================

EOF

exit "$exit_code"