import time
import random
from datetime import datetime

LOG_FILE = "../logs/app.log"
MAX_LINES = 1000  # Keep last 1000 log entries

def generate_log():
    levels = ["INFO", "WARNING", "ERROR", "CRITICAL"]
    status_codes = [200, 200, 200, 200, 404, 500, 503]  # bias toward normal responses

    level = random.choice(levels)
    status = random.choice(status_codes)
    response_time = random.randint(50, 3000)

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return f"{timestamp} {level} {status} ResponseTime={response_time}ms\n"

def trim_log():
    """Keep only the last MAX_LINES lines in the log file."""
    try:
        with open(LOG_FILE, "r") as f:
            lines = f.readlines()
        if len(lines) > MAX_LINES:
            with open(LOG_FILE, "w") as f:
                f.writelines(lines[-MAX_LINES:])
    except FileNotFoundError:
        # File might not exist yet
        pass

def main():
    while True:
        with open(LOG_FILE, "a") as f:
            f.write(generate_log())
        trim_log()  # enforce retention
        time.sleep(2)

if __name__ == "__main__":
    main()
