# Log Analytics Toolkit

## Lightweight CLI-Based Log Analytics & Statistical Anomaly Detection

A lightweight **CLI-based log analytics and anomaly detection tool** designed for **DevOps and SRE environments**.

The project simulates application logs, analyzes operational health, maintains a small historical baseline, detects abnormal error patterns using statistical analysis, and exposes meaningful exit codes that can be consumed by automation and CI/CD pipelines.

The goal is simple:

> **Turn raw application logs into an actionable system health signal.**

---

## Overview

Applications continuously generate logs containing information about their operational state:

- INFO
- WARNING
- ERROR
- CRITICAL

Manually reviewing these logs becomes inefficient as the volume increases.

This project provides a lightweight automated approach to:

1. Generate realistic application logs.
2. Analyze log severity patterns.
3. Count errors, warnings, and critical events.
4. Maintain a rolling historical baseline.
5. Calculate statistical deviation using Z-score.
6. Detect abnormal application behavior.
7. Return meaningful Linux exit codes.
8. Automatically test the analyzer.
9. Run those tests through GitHub Actions CI.
10. Package and release the validated tool.

The project intentionally avoids unnecessary infrastructure and focuses on the core DevOps/SRE problem:

```text
Application Logs
       |
       v
   Log Analysis
       |
       v
Historical Baseline
       |
       v
Statistical Analysis
       |
       v
System Health Status
       |
       v
Automation / CI
````

---

# Problem Statement

In a production environment, applications can generate thousands of log entries.

A simple approach might be:

```text
ERROR count > 20
        |
        v
      ALERT
```

However, fixed thresholds do not always represent abnormal behavior.

For example:

```text
Application A

Normal:
5 errors

Current:
15 errors

15 may be a significant increase.
```

While another application may normally produce:

```text
100 errors
```

and suddenly produce:

```text
115 errors
```

The same absolute increase does not necessarily indicate the same level of concern.

Therefore, this project combines:

* **Threshold-based detection**
* **Historical baseline analysis**
* **Statistical anomaly detection**

to provide a more meaningful operational signal.

---

# Project Objectives

The project is designed to demonstrate practical DevOps and SRE concepts:

* Linux shell automation
* Python scripting
* Log processing
* Operational monitoring concepts
* Statistical anomaly detection
* Historical baselines
* Exit-code driven automation
* Automated testing
* GitHub Actions CI
* Packaging and release automation
* Clean separation between source, test data, and runtime data

---

# Architecture

```text
                    +-------------------+
                    |   generator.py    |
                    |                   |
                    | Simulates traffic |
                    +---------+---------+
                              |
                              v
                    +-------------------+
                    |      app.log      |
                    |                   |
                    | Application logs  |
                    +---------+---------+
                              |
                              v
                    +-------------------+
                    |      main.sh      |
                    |                   |
                    | Log Analyzer      |
                    +---------+---------+
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
         Error Count     Critical Count    Warnings
              |               |               |
              +---------------+---------------+
                              |
                              v
                    Historical Baseline
                              |
                              v
                         Z-Score
                              |
                              v
                    +-------------------+
                    |   System Status   |
                    +-------------------+
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
            OK             WARNING          CRITICAL
                              |
                              v
                           ANOMALY
                              |
                              v
                        Exit Code
                              |
                              v
                     CI/CD Automation
```

---

# Project Structure

```text
Log-Analytics-ToolKit/
│
├── generator.py
├── main.sh
├── test.sh
├── README.md
├── CHANGELOG.md
├── .gitignore
│
├── test_data/
│   └── sample_app.log
│
└── runtime_logs/
    ├── app.log
    ├── run_history.csv
    └── script_log.log
```

## Source Files

### `generator.py`

Generates simulated application logs.


Stop the generator with:

```text
Ctrl+C
```

---

# `main.sh`

The primary log analysis engine.

It:

1. Reads `runtime_logs/app.log`.
2. Counts total log entries.
3. Counts ERROR events.
4. Counts WARNING events.
5. Counts CRITICAL events.
6. Maintains historical analysis data.
7. Calculates the recent error baseline.
8. Calculates standard deviation.
9. Calculates Z-score.
10. Determines the system status.
11. Records the analysis result.
12. Returns a meaningful exit code.

Run it with:

```bash
./main.sh
```

Example output:

```text
========== Log Analysis ==========
Log file      : runtime_logs/app.log
Total lines   : 525
Errors        : 12
Warnings      : 18
Critical      : 1

Mean errors   : 8.40
Std deviation : 1.72
Z-score       : 2.09

System status : ANOMALY
===================================
```

---

# `test.sh`

`test.sh` is the automated test suite for the analyzer.

It validates the expected behavior of the application rather than relying on manual testing.

The current tests cover:

* Healthy application
* Error threshold
* Critical threshold
* History creation
* Runtime logging

Run the test suite:

```bash
./test.sh
```

Expected result:

```text
========================================
 Log Analytics Toolkit Test Suite
========================================

PASS: Healthy application
PASS: Error threshold
PASS: Critical threshold
PASS: History creation
PASS: Runtime logging

========================================
 Test Summary
========================================
Passed : 5
Failed : 0
========================================
```

The test suite creates and removes runtime data automatically so tests do not depend on previous executions.

---

# Test Data

The repository contains deterministic test data:

```text
test_data/sample_app.log
```

This file is intentionally committed to Git.

It provides a predictable baseline for testing the analyzer.

This is different from runtime data.

```text
test_data/
    |
    +-- sample_app.log
        |
        +-- Version controlled
        +-- Deterministic
        +-- Used by tests
```

---

# Runtime Data

Runtime-generated files are stored separately:

```text
runtime_logs/
```

The directory may contain:

```text
runtime_logs/
├── app.log
├── run_history.csv
└── script_log.log
```

These files are intentionally excluded from Git.

They represent runtime state rather than source code or test fixtures.

---

# Statistical Anomaly Detection

The analyzer maintains a rolling history of recent error counts.

The current error count is compared against the historical baseline.

The project uses the Z-score:

```text
Z = (X - μ) / σ
```

Where:

```text
X = current error count

μ = historical mean

σ = historical standard deviation
```

The configured anomaly threshold is:

```text
Z_THRESHOLD=2
```

Therefore, when:

```text
|Z| > 2
```

the current error rate is considered statistically unusual.

This allows the system to detect changes in behavior rather than relying only on absolute thresholds.

---

# Detection Rules

The analyzer currently uses the following priority:

```text
CRITICAL
    ↓
ERROR THRESHOLD
    ↓
STATISTICAL ANOMALY
    ↓
OK
```

The thresholds are:

```text
ERROR_THRESHOLD=20
CRITICAL_THRESHOLD=5
Z_THRESHOLD=2
```

Therefore:

### Critical

```text
CRITICAL >= 5
```

Result:

```text
SYSTEM STATUS = CRITICAL
EXIT CODE = 2
```

### Warning

```text
ERROR >= 20
```

Result:

```text
SYSTEM STATUS = WARNING
EXIT CODE = 1
```

### Anomaly

```text
|Z-score| > 2
```

Result:

```text
SYSTEM STATUS = ANOMALY
EXIT CODE = 1
```

### Healthy

If none of the above conditions are met:

```text
SYSTEM STATUS = OK
EXIT CODE = 0
```

---

# Exit Codes

Exit codes make the tool useful for automation.

| Exit Code | Meaning                        |
| --------- | ------------------------------ |
| `0`       | Healthy / OK                   |
| `1`       | Warning or statistical anomaly |
| `2`       | Critical condition             |
| `2`       | Invalid or missing log input   |

Example:

```bash
./main.sh

echo $?
```

A CI/CD pipeline can use these exit codes to determine whether a stage should succeed or fail.

---

# Why Exit Codes Matter

A monitoring script becomes much more useful when another system can consume its result.

For example:

```text
main.sh
   |
   +-- exit 0 --> healthy
   |
   +-- exit 1 --> warning/anomaly
   |
   +-- exit 2 --> critical
```

This makes the tool suitable for:

* CI pipelines
* Scheduled jobs
* Cron
* Server automation
* Health checks
* Monitoring wrappers
* Incident automation

---

# CI — Continuous Integration

The project uses GitHub Actions to automatically execute the test suite.

The intended CI workflow is:

```text
Developer
    |
    v
git push / Pull Request
    |
    v
GitHub Actions
    |
    v
Checkout repository
    |
    v
Run test.sh
    |
    +-------- PASS --------+
    |                      |
    v                      v
 CI GREEN              CI FAILED
```

The important principle is that GitHub Actions runs the **same test suite used locally**.

Local:

```bash
./test.sh
```

CI:

```bash
./test.sh
```

This prevents the CI environment from having a completely different testing process from the developer environment.

---

# Continuous Delivery

The project does not require a traditional production deployment environment.

Instead, the planned Continuous Delivery stage focuses on:

```text
CI
 |
 v
Tests pass
 |
 v
Package project
 |
 v
Create version
 |
 v
Create release artifact
 |
 v
Publish release
```

For example:

```text
log-analytics-toolkit-v1.0.0.tar.gz
```

The goal is to keep the project in a **releasable state**.

This demonstrates Continuous Delivery without inventing an unnecessary production deployment environment.

---

# Continuous Delivery vs Continuous Deployment

This project follows the Continuous Delivery model.

### Continuous Delivery

```text
Code
 ↓
Test
 ↓
Package
 ↓
Release
 ↓
Ready to deploy
```

A release may still require manual approval before production deployment.

### Continuous Deployment

```text
Code
 ↓
Test
 ↓
Package
 ↓
Release
 ↓
Automatic production deployment
```

Continuous Deployment would require an actual deployment target.

For this project, automatic deployment is intentionally outside the current scope.

---

# DevOps / SRE Use Cases

## 1. CI/CD Quality Gate

The analyzer can be executed as part of a pipeline:

```bash
./main.sh
```

Its exit code can determine whether the pipeline should continue.

---

## 2. Scheduled Log Monitoring

The analyzer could be executed periodically:

```text
cron
  |
  v
main.sh
  |
  v
Analyze application logs
  |
  v
Return health status
```

---

## 3. Lightweight Server Monitoring

For a small application running on a Linux server, a lightweight shell-based analyzer can be useful when a full observability platform is unnecessary.

---

## 4. Anomaly Detection

The historical baseline can identify unusual behavior even when an absolute threshold has not been crossed.

For example:

```text
Normal:
5 errors

Current:
15 errors

Absolute threshold:
20

Threshold detection:
OK

Statistical detection:
ANOMALY
```

This demonstrates why statistical analysis can complement traditional threshold monitoring.

---

# Why Python + Bash?

The project intentionally uses both.

## Python

Python is responsible for:

* Simulating application behavior
* Generating realistic logs
* Generating controlled anomaly scenarios

## Bash

Bash is responsible for:

* Linux automation
* Log processing
* Operational analysis
* Exit codes
* CI/CD integration
* Runtime file management

This reflects a practical DevOps approach where different tools are used for different responsibilities.

---

# Design Principles

The project follows a few simple principles.

### Keep runtime data separate

```text
Source code
    ≠
Runtime state
```

### Keep tests deterministic

Tests should not depend on whatever happened on a developer's machine.

### Keep the tool lightweight

The project deliberately avoids unnecessary dependencies.

### Prefer automation over manual verification

```text
Manual test
    ↓
Automated test
    ↓
CI validation
```

### Build only what the project needs

The project is intentionally not turning into a large observability platform.

---

# Current Technology Stack

```text
Python 3
Bash
Linux
Git
GitHub
GitHub Actions
AWK
Grep
Core Unix utilities
```

---

# Running the Project Locally

## 1. Clone the repository

```bash
git clone <repository-url>
cd Log-Analytics-ToolKit
```

## 2. Make scripts executable

```bash
chmod +x main.sh
chmod +x test.sh
```

## 3. Generate logs

Run:

```bash
python3 generator.py
```

Stop with:

```text
Ctrl+C
```

## 4. Analyze logs

```bash
./main.sh
```

## 5. Run automated tests

```bash
./test.sh
```

---

# Running an Anomaly Scenario

Generate abnormal traffic:

```bash
python3 generator.py --anomaly
```

Allow enough log entries to accumulate and then stop the generator.

Run:

```bash
./main.sh
```

The analyzer will evaluate the current log behavior against the historical baseline.

---

# Configuration

The project currently keeps its core thresholds directly within `main.sh`.

Current values:

```text
ERROR_THRESHOLD=20
CRITICAL_THRESHOLD=5
Z_THRESHOLD=2
ROLLING_WINDOW=10
MAX_HISTORY_LINES=20
```

These values control:

* Error threshold
* Critical threshold
* Statistical anomaly threshold
* Historical window size
* Runtime history retention

The configuration is intentionally kept simple for the current project scope.

---

# Reliability Considerations

The project includes several safeguards:

* Missing log file detection
* Controlled exit codes
* Runtime history retention
* Test isolation
* Deterministic test data
* Separate runtime and test data
* Automated regression testing

The analyzer also maintains only a limited amount of history rather than allowing the history file to grow indefinitely.

---

# Project Workflow

The overall development workflow is:

```text
1. Develop
     |
     v
2. Run locally
     |
     v
3. Run ./test.sh
     |
     v
4. Push to GitHub
     |
     v
5. GitHub Actions CI
     |
     v
6. Package
     |
     v
7. Release
```

---

# Project Scope

## Included

* Application log simulation
* Normal and anomaly log generation
* CLI log analysis
* Error/warning/critical detection
* Historical baseline
* Z-score anomaly detection
* Exit-code based status
* Automated Bash tests
* Deterministic test data
* GitHub Actions CI
* Continuous Delivery through packaging and release

## Intentionally Not Included

The project intentionally does not attempt to become a full observability platform.

The following are outside the current scope:

* Kubernetes
* Prometheus
* Grafana
* Elasticsearch
* Logstash
* Kafka
* Cloud infrastructure
* Distributed tracing
* Full production deployment infrastructure
* Complex monitoring dashboards

Those technologies solve different problems and are not required to demonstrate the objective of this project.

---

# Future Improvements

Possible future enhancements include:

* Structured JSON log support
* Additional anomaly detection methods
* Configurable thresholds
* More sophisticated test coverage
* Packaging as an installable CLI
* Automated versioning
* GitHub Release automation
* Optional alert integrations
* Additional CI quality checks

These will only be introduced if they provide meaningful value to the project.

---

# Learning Outcomes

This project demonstrates practical understanding of:

* Linux shell scripting
* Bash automation
* Python scripting
* Log processing
* Operational monitoring
* Statistical reasoning
* Z-score anomaly detection
* Historical baselines
* Exit codes
* Automated testing
* Test fixtures
* CI pipelines
* Continuous Delivery
* Release automation
* DevOps/SRE thinking

---

# License

This project is intended for learning, experimentation, and demonstration of DevOps/SRE concepts.

## Related Projects

This project is part of the **DevOps Learning Journey** by TechWithHer.

Explore the complete course and project series:

[DevOps Learning Journey — TechWithHer](https://ayushisingh.notion.site/Learn-Complete-DevOps-with-TechWithHer-d60df188b81e8221a5570156f5f8b477?source=copy_link)

