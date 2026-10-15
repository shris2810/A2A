# ==============================================================================
# Production Dockerfile for MCPxA2AxAgentic-RAG System
# Packages both backend agent microservices and Streamlit UI in one container
# ==============================================================================

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OMP_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    TOKENIZERS_PARALLELISM=false \
    TRANSFORMERS_OFFLINE=0 \
    PORT=8501

# Install system dependencies (curl, build tools, OpenMP for FAISS)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency definition
COPY requirements.txt .

# Install dependencies (CPU-optimized torch to keep image size reasonable)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r requirements.txt

# Pre-cache the HuggingFace sentence transformer weights to avoid cold-start delays
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')"

# Copy the application source code
COPY . .

# Ensure start script has executable permissions
RUN chmod +x start.sh

# Expose Streamlit port
EXPOSE 8501

# Start both main.py backend and Streamlit frontend
CMD ["./start.sh"]
