# LogSentinel
### Lightweight CLI-Based Log Analytics & Statistical Anomaly Detection System for DevOps and SRE environments.

---

## Overview

LogSentinel is a shell-based log analytics tool designed to perform statistical anomaly detection using Z-score methodology.

It is built to simulate production-ready log monitoring logic in lightweight environments and CI/CD pipelines.

The project demonstrates:

* CLI engineering
* Statistical anomaly detection
* Automation readiness
* CI/CD integration capability
* Containerized execution
* DevOps-oriented system thinking

---

## Core Features

* Argument-driven log input
* Statistical anomaly detection (Z-score)
* Configurable threshold
* Structured output (JSON/Text)
* Proper exit codes for CI/CD
* Docker support
* GitHub Actions integration
* Alert-ready architecture

---

## Version History

### Version 1

Basic log parsing and error counting.

### Version 2

Error summaries and log classification.

### Version 3

Statistical anomaly detection using Z-score (mean and standard deviation).

### Version 4

Production-ready CLI tool:

* Argument parsing
* Configurable thresholds
* Structured output
* Exit codes
* Robust error handling

### Version 5

DevOps integration:

* Docker containerization
* GitHub Actions CI pipeline
* Pipeline failure on anomaly detection

### Version 6

Monitoring integration:

* Prometheus-style metrics output
* Slack webhook alert support
* Time-window based anomaly detection

---

## Statistical Model

Anomalies are detected using Z-score:

Z = (X - Mean) / StandardDeviation

Default threshold: 2
(Threshold is configurable via CLI flag.)

This allows detection of abnormal log behavior based on deviation from baseline error rates.

---

## Installation

Clone repository:

```bash
git clone https://github.com/yourusername/logsentinel.git
cd logsentinel
chmod +x logsentinel.sh
```

---

## Usage

Basic usage:

```bash
./logsentinel.sh --file /var/log/nginx/access.log
```

Custom threshold:

```bash
./logsentinel.sh --file app.log --threshold 3
```

JSON output:

```bash
./logsentinel.sh --file app.log --format json
```

Exit Codes:

* 0 → No anomaly
* 1 → Anomaly detected
* 2 → Invalid input

---

## CI/CD Example

Fail pipeline on anomaly:

```bash
./logsentinel.sh --file app.log
if [ $? -eq 1 ]; then
  exit 1
fi
```

---

## Docker Usage

Build:

```bash
docker build -t logsentinel .
```

Run:

```bash
docker run -v $(pwd)/logs:/logs logsentinel --file /logs/app.log
```

---

## Use Cases

* Small teams without enterprise monitoring tools
* CI/CD anomaly detection
* Pre-production log validation
* Security log spike detection
* Lightweight DevOps observability simulation

---

## Why This Project

This project demonstrates applied DevOps engineering practices including:

* Statistical reasoning in operations
* CLI tool design
* Production thinking
* CI/CD pipeline integration
* Containerized deployment
* Automation-first architecture

---

