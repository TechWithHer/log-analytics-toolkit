# Production-Grade Log Analytics Toolkit (Bash + awk + grep)

## 🎯 Objective

Build a CLI-based log analysis toolkit that:

* Parses large application & Nginx logs
* Detects anomalies (error spikes, brute force attempts, latency issues)
* Generates summary reports
* Simulates real-world DevOps monitoring workflows
* Is fully automated via shell scripts

This shows:

* Shell scripting mastery
* awk/grep/sed fluency
* Log parsing skills
* Basic security detection
* Production-style automation

---

# 📁 Project Structure

```
log-analytics-toolkit/
│
├── logs/
│   ├── app.log
│   ├── nginx.log
│
├── scripts/
│   ├── analyze_errors.sh
│   ├── detect_bruteforce.sh
│   ├── latency_report.sh
│   ├── summary_dashboard.sh
│
├── reports/
│   └── daily_report.txt
│
├── generate_fake_logs.sh
├── run_pipeline.sh
└── README.md
```

---

# 🧪 Step 1: Simulated Real Logs

## Sample `app.log`

```
2026-02-20 10:12:01 INFO User login success user_id=101 ip=192.168.1.10
2026-02-20 10:12:05 ERROR DB connection timeout
2026-02-20 10:12:08 WARN High memory usage 85%
2026-02-20 10:13:01 ERROR Payment service failed user_id=203
```

## Sample `nginx.log`

```
192.168.1.10 - - [20/Feb/2026:10:12:01 +0000] "GET /api/login HTTP/1.1" 200 512 "-" "Mozilla" 0.245
192.168.1.15 - - [20/Feb/2026:10:12:02 +0000] "POST /api/login HTTP/1.1" 401 128 "-" "Mozilla" 0.310
192.168.1.15 - - [20/Feb/2026:10:12:03 +0000] "POST /api/login HTTP/1.1" 401 128 "-" "Mozilla" 0.295
```

---

# 🔍 Script 1: Error Analysis (Industry-Style)

### `analyze_errors.sh`

✅ Demonstrates:

* Pattern matching
* Aggregation
* Sorting by frequency

---

# 🔐 Script 2: Brute Force Detection

Detect IPs with more than 5 failed logins (401 errors).

### `detect_bruteforce.sh`


Industry relevance:

* Security monitoring
* SOC-style log filtering
* Incident detection simulation

---

# 📊 Script 3: Latency Analysis

Assuming response time is last field in nginx log.

### `latency_report.sh`

This shows:

* Real metrics extraction
* Numeric calculations in awk
* Performance monitoring capability

---

# 📈 Script 4: Daily Dashboard Generator

### `summary_dashboard.sh`

Now you look like you built a mini monitoring pipeline.

---

# 🔄 Step 5: Full Pipeline Runner

---

# 🔥 Optional Advanced Add-Ons (Industry-Level Upgrade)

If you want to stand out as a DevOps engineer:

### 1️⃣ Log Rotation Handling

* Automatically process latest rotated file (`app.log.1`)
* Detect log size growth

### 2️⃣ Cron Integration

Document how to schedule:

```
0 0 * * * /path/to/run_pipeline.sh
```

### 3️⃣ Alert System

Add:

```bash
if [ $(grep -c "ERROR" ../logs/app.log) -gt 50 ]; then
    echo "High error rate detected!"
fi
```

### 4️⃣ Dockerize It

Create Dockerfile to run pipeline inside container.

That shows modern DevOps thinking.

## Addons (Advanced)
Threshold-based alerting

Exit code severity

Config file support

Simple HTML dashboard output

Threshold-based alerting (email/Slack/webhook)

Historical trend comparison

Config-driven thresholds (not hardcoded)

Exit codes for CI/CD integration

Containerized deployment

Cron-based scheduling with logging

Self-healing trigger (optional but impressive)

---

# 🧠 What This Demonstrates on GitHub

When recruiters see this, they’ll see:

* Strong CLI fundamentals
* Production-style thinking
* Security awareness
* Monitoring mindset
* Automation culture
* Clean project structure

Not just “I know grep.”

---

# 📝 README Should Include

* Problem statement
* Architecture diagram (even simple ASCII)
* Sample log format explanation
* How to run
* Real-world use case mapping
* Future improvements

---

