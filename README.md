# 🇰🇭 Cambodia Air Quality Analysis Pipeline

Real-time air quality monitoring for 5 Cambodian cities using PySpark, SQL Server, and Power BI.

---

## 📊 Dashboard Preview

> Power BI dashboard with live auto-refresh every 60 seconds.

---

## 🏙️ Cities Monitored
| City | Latitude | Longitude |
|------|----------|-----------|
| Phnom Penh | 11.5564 | 104.9282 |
| Siem Reap | 13.3671 | 103.8448 |
| Battambang | 13.1024 | 103.1988 |
| Kampot | 10.6108 | 104.1812 |
| Sihanoukville | 10.6097 | 103.5297 |

---

## 🛠️ Tech Stack
| Layer | Technology |
|-------|-----------|
| Data Source | Open-Meteo Air Quality API |
| Processing | Apache PySpark (local mode) |
| Storage | Microsoft SQL Server |
| Dashboard | Power BI Desktop |
| Language | Python 3.x |

---

## 🏗️ Pipeline Architecture
Open-Meteo API

↓ (every 60s)

api_to_csv.ipynb

↓

air_quality_combined.csv

↓ (every 60s)

test.ipynb (PySpark)

↓

SQL Server (AirQualityDB)

↓ (auto-refresh 60s)

Power BI Dashboard

---

## 📁 Project Structure
cambodia-air-quality-pipeline/

├── api_to_csv.ipynb          # Fetches API data every 60s → CSV

├── test.ipynb                # PySpark pipeline → SQL Server

├── live_input/               # CSV data folder (gitignored)

│   └── air_quality_combined.csv

├── .gitignore

└── README.md
---

## 🗄️ Database Schema (AirQualityDB)

### CleanedAirQuality
| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| city | NVARCHAR | City name |
| latitude | FLOAT | GPS latitude |
| longitude | FLOAT | GPS longitude |
| datetime | DATETIME2 | Measurement time |
| aqi | FLOAT | Air Quality Index |
| pm25 | FLOAT | PM2.5 (μg/m³) |
| pm10 | FLOAT | PM10 (μg/m³) |
| co | FLOAT | Carbon monoxide |
| no2 | FLOAT | Nitrogen dioxide |
| so2 | FLOAT | Sulphur dioxide |
| o3 | FLOAT | Ozone |
| air_quality_category | NVARCHAR | Good/Moderate/Unhealthy/etc |

### Other Tables
- **CitySummary** — avg/max PM2.5 per city
- **PollutantAvg** — average of all pollutants per city
- **DangerousAirQuality** — records with unhealthy/hazardous levels

---

## 🌍 Air Quality Categories (US EPA Standard)
| PM2.5 (μg/m³) | Category |
|----------------|----------|
| 0 – 12.0 | 🟢 Good |
| 12.1 – 35.4 | 🟡 Moderate |
| 35.5 – 55.4 | 🟠 Unhealthy for Sensitive Groups |
| 55.5 – 150.4 | 🔴 Unhealthy |
| 150.5 – 250.4 | 🟣 Very Unhealthy |
| 250.5+ | 🔴 Hazardous |

---

## ⚙️ Setup & Installation

### Prerequisites
- Python 3.x
- Java JDK 17
- Apache Spark
- Microsoft SQL Server
- Power BI Desktop

### Install Dependencies
```bash
pip install pyspark pandas sqlalchemy pyodbc requests
```

### SQL Server Setup
1. Create database `AirQualityDB`
2. Create login `airuser` with password
3. Run table creation scripts

### Run Pipeline
```bash
# Step 1: Start API fetcher
# Open api_to_csv.ipynb → Run All

# Step 2: Start PySpark pipeline
# Open test.ipynb → Run All

# Step 3: Open Power BI dashboard → Refresh

---

