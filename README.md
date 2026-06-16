# PRITHVI-AI

Climate-driven public-health early-warning and decision-support platform. Ingests real
environmental data (weather, air quality, search-trend and WHO surveillance signals),
forecasts heat / disease / hospital-surge / PM2.5 risk per region with uncertainty bands and
SHAP drivers, and operationalizes those forecasts into alerts, resource-allocation
optimization, scenario planning, and fairness/drift monitoring.

This is the **umbrella repository**. The application is split into two independent repositories,
included here as git submodules:

| Submodule | Repository | Stack |
|-----------|-----------|-------|
| `backend/`  | https://github.com/rupeshbharambe24/prithvi-ai-backend  | FastAPI · SQLAlchemy (async) · XGBoost · APScheduler |
| `frontend/` | https://github.com/rupeshbharambe24/prithvi-ai-frontend | React · Vite · TypeScript · shadcn/ui · MapLibre |

## Clone (with submodules)

```bash
git clone --recursive https://github.com/rupeshbharambe24/prithvi-ai.git
# or, if already cloned:
git submodule update --init --recursive
```

## Run locally

**Backend** (Python 3.11+):
```bash
cd backend
python -m venv .venv && .venv\Scripts\activate   # Windows
pip install -e .
uvicorn backend.app.main:app --port 8000 --reload
```

**Frontend** (Node 18+):
```bash
cd frontend
npm install
npm run dev
```

Login: `admin@example.com` / `Admin123!`

## Continuous ML pipeline

The backend runs a daily + weekly ML loop (see
`backend/docs/superpowers/specs/` and `backend/docs/superpowers/plans/`):

- **Daily:** ingest data → score matured forecasts against actuals → refresh forward forecasts → drift check.
- **Weekly:** retrain models (champion/challenger promotion) → backtest + fairness → refresh.
- **On demand:** `python -m backend.app.scripts.run_pipeline daily|weekly|score|forecast`

## Updating submodule pointers

After pushing changes to a component repo, bump its pointer here:

```bash
git submodule update --remote backend   # or frontend
git add backend && git commit -m "chore: bump backend submodule"
git push
```
