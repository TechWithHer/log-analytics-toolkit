#!/bin/bash

cd scripts

./analyze_errors.sh
./detect_bruteforce.sh
./latency_report.sh
./summary_dashboard.sh