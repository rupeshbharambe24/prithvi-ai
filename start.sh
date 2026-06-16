#!/usr/bin/env bash
# Start both backend and frontend for local development
# Usage: bash start.sh

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND_PORT=${BACKEND_PORT:-8000}
FRONTEND_PORT=${FRONTEND_PORT:-5173}

cleanup() {
  echo ""
  echo "Shutting down..."
  kill $BE_PID $FE_PID 2>/dev/null
  wait $BE_PID $FE_PID 2>/dev/null
  echo "Done."
}
trap cleanup EXIT INT TERM

# Backend
echo "Starting backend on port $BACKEND_PORT..."
cd "$ROOT/backend"
pip install -e . --quiet 2>/dev/null
uvicorn backend.app.main:app --port "$BACKEND_PORT" &
BE_PID=$!

# Wait for backend to be ready
echo "Waiting for backend..."
for i in $(seq 1 30); do
  if curl -sf "http://localhost:$BACKEND_PORT/api/v1/health" >/dev/null 2>&1; then
    echo "Backend ready."
    break
  fi
  sleep 1
done

# Frontend
echo "Starting frontend..."
cd "$ROOT/frontend"
npm install --silent 2>/dev/null
npm run dev -- --port "$FRONTEND_PORT" &
FE_PID=$!

sleep 3
echo ""
echo "========================================="
echo "  Backend:  http://localhost:$BACKEND_PORT"
echo "  Frontend: http://localhost:$FRONTEND_PORT"
echo "  Login:    admin@example.com / Admin123!"
echo "========================================="
echo "Press Ctrl+C to stop both."
echo ""

wait
