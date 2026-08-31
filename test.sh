#!/usr/bin/env bash

set -uo pipefail

TEST_DATA="test_data/sample_app.log"

LOG_FILE="test_data/sample_app.log"
HISTORY_FILE="test_data/history_log.log"
SCRIPT_LOG="test_data/script_log.log"

PASSED=0
FAILED=0


# --------------------------------------------------
# Test helpers
# --------------------------------------------------

pass() {
    echo "PASS: $1"
    ((PASSED+=1))
}

fail() {
    echo "FAIL: $1"
    ((FAILED+=1))
}

run_test() {
    local name="$1"
    shift

    if "$@"; then
        pass "$name"
    else
        fail "$name"
    fi
}


# --------------------------------------------------
# Test environment
# --------------------------------------------------

cleanup() {
    rm -f "$LOG_FILE"
    rm -f "$HISTORY_FILE"
    rm -f "$SCRIPT_LOG"
}

setup_runtime() {
    mkdir -p runtime_logs
}

setup_sample_log() {
    setup_runtime
    cp "$TEST_DATA" "$LOG_FILE"
}


# Always clean runtime files when the test suite exits
trap cleanup EXIT


# --------------------------------------------------
# Test 1 — Healthy application
# --------------------------------------------------

test_healthy() {

    cleanup
    setup_sample_log

    local output
    local exit_code

    set +e
    output=$(./main.sh 2>&1)
    exit_code=$?
    set -e

    [[ "$exit_code" -eq 0 ]] &&
    [[ "$output" == *"System status : OK"* ]]
}


# --------------------------------------------------
# Test 2 — Error threshold
# --------------------------------------------------

test_error_threshold() {

    cleanup
    setup_runtime

    {
        for _ in {1..30}; do
            echo "2026-08-25 10:00:00 INFO 200 ResponseTime=100ms"
        done

        for _ in {1..20}; do
            echo "2026-08-25 10:00:01 ERROR 500 ResponseTime=500ms"
        done
    } > "$LOG_FILE"

    local output
    local exit_code

    set +e
    output=$(./main.sh 2>&1)
    exit_code=$?
    set -e

    [[ "$exit_code" -eq 1 ]] &&
    [[ "$output" == *"System status : WARNING"* ]]
}


# --------------------------------------------------
# Test 3 — Critical threshold
# --------------------------------------------------

test_critical() {

    cleanup
    setup_runtime

    {
        for _ in {1..20}; do
            echo "2026-08-25 10:00:00 INFO 200 ResponseTime=100ms"
        done

        for _ in {1..5}; do
            echo "2026-08-25 10:00:01 CRITICAL 503 ResponseTime=3000ms"
        done
    } > "$LOG_FILE"

    local output
    local exit_code

    set +e
    output=$(./main.sh 2>&1)
    exit_code=$?
    set -e

    [[ "$exit_code" -eq 2 ]] &&
    [[ "$output" == *"System status : CRITICAL"* ]]
}


# --------------------------------------------------
# Test 4 — History creation
# --------------------------------------------------

test_history_creation() {

    cleanup
    setup_sample_log

    local output
    local exit_code

    set +e
    output=$(./main.sh 2>&1)
    exit_code=$?
    set -e

    [[ -f "$HISTORY_FILE" ]] &&
    grep -q "timestamp,errors,critical,warnings" "$HISTORY_FILE"
}


# --------------------------------------------------
# Test 5 — Runtime logging
# --------------------------------------------------

test_runtime_logging() {

    [[ -f "$SCRIPT_LOG" ]] &&
    [[ -s "$SCRIPT_LOG" ]]
}


# --------------------------------------------------
# Test suite
# --------------------------------------------------

echo
echo "========================================"
echo " Log Analytics Toolkit Test Suite"
echo "========================================"
echo

run_test "Healthy application" test_healthy
run_test "Error threshold" test_error_threshold
run_test "Critical threshold" test_critical
run_test "History creation" test_history_creation
run_test "Runtime logging" test_runtime_logging


# --------------------------------------------------
# Summary
# --------------------------------------------------

echo
echo "========================================"
echo " Test Summary"
echo "========================================"
echo "Passed : $PASSED"
echo "Failed : $FAILED"
echo "========================================"


if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0