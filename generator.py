import argparse
import random
import time
from datetime import datetime
from pathlib import Path


LOG_FILE = Path("runtime_logs/app.log")
MAX_LINES = 1000
INTERVAL_SECONDS = 2


def generate_log(anomaly: bool = False) -> str:
    """Generate a simulated application log entry."""

    if anomaly:
        levels = ["INFO", "WARNING", "ERROR", "CRITICAL"]
        weights = [0.40, 0.15, 0.30, 0.15]
    else:
        levels = ["INFO", "WARNING", "ERROR", "CRITICAL"]
        weights = [0.80, 0.15, 0.04, 0.01]

    status_codes = [200, 200, 200, 404, 500, 503]

    level = random.choices(levels, weights=weights)[0]
    status = random.choice(status_codes)
    response_time = random.randint(50, 3000)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return (
        f"{timestamp} {level} {status} "
        f"ResponseTime={response_time}ms\n"
    )


def trim_log() -> None:
    """Keep only the most recent MAX_LINES log entries."""

    if not LOG_FILE.exists():
        return

    lines = LOG_FILE.read_text().splitlines(keepends=True)

    if len(lines) > MAX_LINES:
        LOG_FILE.write_text("".join(lines[-MAX_LINES:]))


def main() -> None:
    """Generate application logs continuously."""

    parser = argparse.ArgumentParser(
        description="Generate simulated application logs."
    )

    parser.add_argument(
        "--anomaly",
        action="store_true",
        help="Generate an abnormal error rate.",
    )

    args = parser.parse_args()

    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

    mode = "ANOMALY" if args.anomaly else "NORMAL"

    print(f"Log generator started in {mode} mode.")
    print(f"Writing logs to: {LOG_FILE}")

    try:
        while True:
            with LOG_FILE.open("a") as log_file:
                log_file.write(generate_log(args.anomaly))

            trim_log()
            time.sleep(INTERVAL_SECONDS)

    except KeyboardInterrupt:
        print("\nLog generator stopped.")


if __name__ == "__main__":
    main()