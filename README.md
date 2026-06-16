<div align="center">

# 🌍 PRITHVI-AI

### Climate-Driven Public-Health Early-Warning & Decision-Support Platform

*Turning open environmental data into explainable, actionable health-risk forecasts.*

<br/>

[![Backend](https://img.shields.io/badge/Backend-FastAPI%20%C2%B7%20XGBoost-009688?logo=fastapi&logoColor=white)](https://github.com/rupeshbharambe24/prithvi-ai-backend)
[![Frontend](https://img.shields.io/badge/Frontend-React%20%C2%B7%20Vite%20%C2%B7%20TS-61DAFB?logo=react&logoColor=black)](https://github.com/rupeshbharambe24/prithvi-ai-frontend)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](#-license)
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

</div>

---

> [!NOTE]
> **PRITHVI** (पृथ्वी) is Sanskrit for *"Earth."* PRITHVI-AI forecasts how a changing climate
> threatens human health — **heatwaves, vector-borne disease, hospital surges, and air
> pollution** — and helps public-health teams act *before* a crisis, not after.

This is the **umbrella repository**. The platform is built as two independent applications,
included here as git submodules:

| Component | Repository | Stack |
|-----------|-----------|-------|
| 🧠 **Backend** | [`prithvi-ai-backend`](https://github.com/rupeshbharambe24/prithvi-ai-backend) | FastAPI · SQLAlchemy (async) · XGBoost · APScheduler |
| 🖥️ **Frontend** | [`prithvi-ai-frontend`](https://github.com/rupeshbharambe24/prithvi-ai-frontend) | React 18 · Vite · TypeScript · shadcn/ui · MapLibre |

---

## 📑 Table of Contents

- [Why it matters](#-why-it-matters)
- [What it does](#-what-it-does)
- [System architecture](#-system-architecture)
- [The continuous ML loop](#-the-continuous-ml-loop)
- [Quick start](#-quick-start)
- [Repository layout](#-repository-layout)
- [Working with submodules](#-working-with-submodules)
- [License](#-license)

---

## 🔥 Why it matters

India and the wider Global South face compounding climate-health threats — deadly **heatwaves**,
monsoon-driven **dengue** outbreaks, seasonal **PM2.5** spikes, and the **emergency-department
surges** they cause. These hit hardest where surveillance is weakest. PRITHVI-AI gives
epidemiologists, hospital operations teams, and field officers a **7–14 day operational
forecast** of four coupled risks per region — each with uncertainty bands, the scientific
evidence behind it, and an optimizer that says *where to send resources*.

The pilot covers three cities with distinct risk profiles: **Mumbai · Delhi · Chennai.**

## ✨ What it does

<table>
<tr>
<td width="50%" valign="top">

**🛰️ Real data ingestion**
- Weather (Open-Meteo / ERA5 → NASA POWER fallback)
- Air quality (OpenAQ → AQICN fallback)
- Search-trend surveillance (Google Trends)
- WHO GHO disease counts · population vulnerability

**📈 Explainable forecasting**
- XGBoost per region × target with p05/p95 bands
- SHAP top-5 drivers on every prediction
- Honest skill-vs-persistence baseline scoring

</td>
<td width="50%" valign="top">

**🧩 Decision support**
- 📚 Evidence **knowledge graph** (OpenAlex → NER → graph)
- 🎯 LP **resource optimizer** (staff allocation by risk)
- 🧪 **Scenario** planner (what-if interventions)
- 🔔 Rule-based **alerts** with multi-channel delivery

**🛡️ Trust & ops**
- ⚖️ **Fairness** — per-region error/coverage gaps
- 📉 **Drift** — PSI/KS with auto-retrain triggers
- 🔄 Continuous **train → predict → verify → retrain** loop

</td>
</tr>
</table>

## 🏗️ System architecture

```mermaid
flowchart LR
    subgraph SRC["🌐 Open Data Sources"]
        A1[Open-Meteo / ERA5]
        A2[OpenAQ]
        A3[Google Trends]
        A4[WHO GHO]
        A5[OpenAlex]
    end

    subgraph BE["🧠 Backend · FastAPI"]
        ETL[ETL pipelines<br/>+ fallbacks + lineage]
        FEAT[(Features &<br/>Observations)]
        ML[XGBoost models<br/>+ SHAP + quantiles]
        FC[(Forecasts<br/>p05/p95)]
        OPS[Alerts · Optimizer ·<br/>Scenario · Fairness · Drift]
        KG[(Knowledge Graph)]
    end

    subgraph FE["🖥️ Frontend · React"]
        MAP[Maps · Risk dashboards]
        EXPL[KG explorer · Evidence]
        MON[Models · Fairness · Alerts]
    end

    A1 & A2 & A3 & A4 --> ETL --> FEAT --> ML --> FC --> OPS
    A5 --> KG
    FC --> MAP
    KG --> EXPL
    OPS --> MON
    ML --> MON
```

## 🔄 The continuous ML loop

```mermaid
flowchart TD
    D1["🗓️ DAILY"] --> D2[Ingest latest data]
    D2 --> D3[Score matured forecasts<br/>vs realized actuals]
    D3 --> D4[Refresh forward forecasts]
    D4 --> D5{Drift PSI ≥ 0.25?}
    D5 -- yes --> W1
    D5 -- no --> DONE([wait for next tick])

    W1["📅 WEEKLY / drift-triggered"] --> W2[Retrain all models → shadow]
    W2 --> W3{Challenger beats<br/>champion?}
    W3 -- yes --> W4[Promote · ≤1 active per target]
    W3 -- no --> W5[Reject · keep champion]
    W4 --> W6[Backtest + fairness] --> DONE
    W5 --> W6
```

> [!TIP]
> **Daily inference + weekly retrain** is the design: weather forecasts change daily (so
> re-predict daily), but learned relationships change slowly (so retrain weekly), with an
> **off-cycle retrain** the moment data drift turns critical. Run any stage on demand:
> ```bash
> python -m backend.app.scripts.run_pipeline daily|weekly|score|forecast
> ```

## 🚀 Quick start

```bash
# Clone WITH submodules (important — otherwise backend/ & frontend/ are empty)
git clone --recursive https://github.com/rupeshbharambe24/prithvi-ai.git
cd prithvi-ai
```

<details>
<summary><b>▶️ Run the backend</b> (Python 3.11+)</summary>

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate        # Windows  (use: source .venv/bin/activate on macOS/Linux)
pip install -e .
uvicorn backend.app.main:app --port 8000 --reload
```
Runs in **local mode** by default: SQLite, in-memory cache, seeded demo users — no Docker/Redis needed.
API docs at `http://localhost:8000/docs`.
</details>

<details>
<summary><b>▶️ Run the frontend</b> (Node 18+)</summary>

```bash
cd frontend
npm install
npm run dev
```
Open the printed URL (usually `http://localhost:5173`).
</details>

**Demo login:** `admin@example.com` / `Admin123!`

## 📂 Repository layout

```
prithvi-ai/                  ← this umbrella repo
├── backend/                 ← submodule → prithvi-ai-backend
├── frontend/                ← submodule → prithvi-ai-frontend
├── start.sh                 ← launch both for local dev
└── README.md
```

## 🔗 Working with submodules

```bash
# Already cloned without --recursive?
git submodule update --init --recursive

# Pull the latest of each component:
git submodule update --remote backend frontend

# After pushing changes to a component repo, bump its pointer here:
git add backend frontend
git commit -m "chore: bump submodule pointers"
git push
```

## 📜 License

Released under the **MIT License**.

<div align="center">
<sub>Built for resilient public health in a warming world. 🌡️🩺</sub>
</div>
