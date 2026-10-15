#!/usr/bin/env bash
# ==============================================================================
# Entrypoint script for MCPxA2AxAgentic-RAG Deployment
# Runs both the backend agent system (main.py) and the frontend (Streamlit)
# ==============================================================================

set -e

# Configure port (default to 8501 or use cloud-provided PORT variable)
PORT="${PORT:-8501}"

echo "=========================================================="
echo " Starting MCPxA2AxAgentic-RAG System in Cloud Environment"
echo " Web Port: ${PORT}"
echo "=========================================================="

# 1. Start the Backend Agents (Host Agent on 10001 & RAG Agent on 10002)
echo "[1/2] Starting backend agents (main.py)..."
python main.py &
MAIN_PID=$!

# Wait for backend servers to spin up and bind to ports 10001 and 10002
echo "Waiting 8 seconds for Host Agent & RAG Agent to initialize..."
sleep 8

# 2. Start the Streamlit Frontend on the public port
echo "[2/2] Starting Streamlit UI on port ${PORT}..."
streamlit run app/streamlit_ui.py \
    --server.port="${PORT}" \
    --server.address="0.0.0.0" \
    --server.enableCORS=false \
    --server.enableXsrfProtection=false \
    --browser.gatherUsageStats=false &
STREAMLIT_PID=$!

echo "=========================================================="
echo " System started successfully!"
echo " Backend PID: ${MAIN_PID}"
echo " Frontend PID: ${STREAMLIT_PID}"
echo "=========================================================="

# Forward termination signals gracefully
trap 'echo "Stopping services..."; kill ${MAIN_PID} ${STREAMLIT_PID}; exit 0' SIGINT SIGTERM

# Wait for processes
wait -n ${MAIN_PID} ${STREAMLIT_PID}
