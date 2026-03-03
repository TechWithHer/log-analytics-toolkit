import time
import random
from datetime import datetime
import os

LOG_FILE = "LOG_GENERATOR/app.log"
MAX_LINES = 500  # Keep last 1000 log entries

def generate_log():
    levels = ["INFO", "WARNING", "ERROR", "CRITICAL"]
    status_codes = [200, 200, 200, 200, 404, 500, 503]

    level = random.choice(levels)
    status = random.choice(status_codes)
    response_time = random.randint(50, 3000)

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return f"{timestamp} {level} {status} ResponseTime={response_time}ms\n"

def trim_log():
    if not os.path.exists(LOG_FILE):
        return

    with open(LOG_FILE, "r") as f:
        lines = f.readlines()

    if len(lines) > MAX_LINES:
        with open(LOG_FILE, "w") as f:
            f.writelines(lines[-MAX_LINES:])

def main():
    while True:
        with open(LOG_FILE, "a") as f:
            f.write(generate_log())

        trim_log()
        time.sleep(60)

if __name__ == "__main__":
    main()