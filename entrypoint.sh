#!/bin/bash

# Start log generator in background
python LOG_GENERATOR/generator.py &

GEN_PID=$!

# Run main.sh periodically
while true; do
    # Provide log file path inside container
    bash main.sh LOG_GENERATOR/app.log
    sleep 5   # every 5 seconds; adjust as needed
done

# If container stops, kill background generator
trap "kill $GEN_PID" EXIT