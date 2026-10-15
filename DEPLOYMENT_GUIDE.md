# 🚀 Deployment Guide: Getting a Live Public Link

This comprehensive guide covers all proven methods to deploy the **MCP × A2A × Agentic-RAG** system and get a live public link, from **instant zero-cost tunnels (2 minutes)** to **permanent free cloud hosting (Hugging Face Spaces)**, **cloud containers (Render/Railway)**, and **dedicated cloud VMs (AWS/DigitalOcean)**.

---

## 📌 Architecture Considerations Before Deploying

Before deploying, keep these core architectural facts in mind:

1. **Multi-Process Architecture**:
   - **Backend (`main.py`)**: Runs the Host Agent on port `10001` and the Agentic RAG Agent on port `10002`, plus local MCP subprocesses.
   - **Frontend (`streamlit`)**: Runs on port `8501` (or dynamic cloud `$PORT`) and connects to `localhost:10001` & `localhost:10002` over loopback.
   - 👉 **Key Takeaway**: Both `main.py` and Streamlit **must run inside the same container or virtual machine**. You only need to publicly expose the Streamlit web port!
2. **Resource Requirements (RAM)**:
   - Local CPU embeddings (`sentence-transformers/all-MiniLM-L6-v2`) + PyTorch + FAISS require **at least 1.5 GB to 2 GB of RAM**.
   - Free tiers with only 512 MB of RAM (e.g., Render free tier) will experience Out-Of-Memory (OOM) crashes. Ensure your host has at least **2 GB RAM** (or use Hugging Face Spaces which provides **16 GB RAM for free**).
3. **Required Environment Variables**:
   - `GOOGLE_API_KEY`: Google AI Studio Gemini API key.
   - `SERPAPI_KEY`: SerpAPI key for MCP real-time web search.

---

## 🧭 Comparison of Deployment Methods

| Method | Setup Time | Cost | RAM / Specs | Best For | Live Link Type |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Method 1: Cloudflare Tunnel** | 2 mins | Free | Your PC's specs | Quick live demo, client review, zero setup | `https://*.trycloudflare.com` |
| **Method 2: Hugging Face Spaces** | 5 mins | **Free** | **16 GB RAM**, 2 vCPU | Permanent public AI app, zero cost | `https://huggingface.co/spaces/*` |
| **Method 3: Cloud Container (Railway/Render)** | 5 mins | $5–$7/mo | 2 GB+ RAM | Production container, custom domains | `https://*.up.railway.app` |
| **Method 4: Dedicated Cloud VM (EC2/DigitalOcean)**| 15 mins | $6–$12/mo | 2–4 GB RAM | Full control, 24/7 reliability, custom domain + SSL | `https://rag.yourdomain.com` |

---

## Method 1: Instant Public URL via Cloudflare Tunnel (Recommended for Quick Demos)

If you already have the project running locally and just want a **secure public HTTPS link right now** to share with anyone in the world:

### Step 1: Start the System Locally
Open two terminal windows:
```powershell
# Terminal 1: Backend Agents
python main.py

# Terminal 2: Streamlit Frontend
streamlit run app/streamlit_ui.py
```
Ensure Streamlit is running at `http://localhost:8501`.

### Step 2: Launch Cloudflare Tunnel (No Account Required)
1. Download `cloudflared`:
   - **Windows** (via winget or direct download):
     ```powershell
     winget install Cloudflare.cloudflared
     ```
   - **macOS** (via brew):
     ```bash
     brew install cloudflared
     ```
   - **Linux**:
     ```bash
     curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && sudo dpkg -i cloudflared.deb
     ```

2. Start the quick tunnel:
   ```bash
   cloudflared tunnel --url http://localhost:8501
   ```

3. **Get Your Live Link**:
   In the console output, look for a URL formatted like:
   ```
   https://random-words-generated.trycloudflare.com
   ```
   Anyone who visits that HTTPS link will access your live Streamlit interface and can upload PDFs and ask questions in real time!

> **Alternative (ngrok)**:
> ```bash
> ngrok http 8501
> ```

---

## Method 2: Hugging Face Spaces (Best Permanent Free Cloud Hosting)

Hugging Face Spaces is the **ideal free cloud host** for AI applications. It gives you **2 vCPUs and 16 GB RAM completely free**, which easily handles PyTorch, FAISS, and Streamlit without any OOM issues.

### Step 1: Create a New Space
1. Go to [huggingface.co/spaces](https://huggingface.co/spaces) and log in.
2. Click **Create new Space**.
3. Choose:
   - **Space Name**: e.g., `agentic-rag-system`
   - **Space SDK**: Select **Docker** (Blank)
   - **License**: Apache 2.0 / MIT
   - **Space Hardware**: **CPU basic (2 vCPU · 16 GB RAM - Free)**

### Step 2: Add Secrets (Environment Variables)
In your Space, go to **Settings** $\rightarrow$ **Variables and Secrets** $\rightarrow$ **New secret**:
- Name: `GOOGLE_API_KEY` | Value: `your_gemini_api_key`
- Name: `SERPAPI_KEY` | Value: `your_serpapi_key`

### Step 3: Configure Port for Hugging Face
Hugging Face Spaces expects the container to listen on port `7860`.
In the repository:
1. Ensure the provided [`start.sh`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/start.sh) and [`Dockerfile`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/Dockerfile) are in the root directory.
2. Add an environment variable in Hugging Face Space Settings:
   - Name: `PORT` | Value: `7860`

### Step 4: Push the Code
Clone your Space repository and push your project files:
```bash
git remote add hf https://huggingface.co/spaces/YOUR_USERNAME/YOUR_SPACE_NAME
git add .
git commit -m "Deploy MCP A2A Agentic RAG"
git push hf main
```
Hugging Face will automatically build the Docker image, download dependencies, and give you a permanent live link:
`https://huggingface.co/spaces/YOUR_USERNAME/YOUR_SPACE_NAME`

---

## Method 3: Cloud Container Platforms (Railway / Render / Fly.io)

### Option A: Railway (Easiest Container Deploy)
Railway automatically detects the `Dockerfile` and scales memory dynamically.

1. Create an account at [railway.app](https://railway.app).
2. Click **New Project** $\rightarrow$ **Deploy from GitHub repo**.
3. Select your repository.
4. Go to **Variables** and add:
   - `GOOGLE_API_KEY = your_gemini_api_key`
   - `SERPAPI_KEY = your_serpapi_key`
   - `PORT = 8501`
5. Go to **Settings** $\rightarrow$ **Networking** $\rightarrow$ **Generate Domain**.
6. Railway will build the container using our [`Dockerfile`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/Dockerfile) and [`start.sh`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/start.sh). You'll receive a live link like `https://agentic-rag-production.up.railway.app`.

### Option B: Render
1. Create an account at [render.com](https://render.com).
2. Click **New +** $\rightarrow$ **Web Service**.
3. Connect your GitHub repository.
4. Set:
   - **Environment**: **Docker**
   - **Instance Type**: **Starter (2 GB RAM)** *(Avoid the 512MB free tier as PyTorch requires ~1.5 GB)*.
5. In **Environment Variables**, add `GOOGLE_API_KEY` and `SERPAPI_KEY`.
6. Click **Create Web Service**. Render gives you a live `https://*.onrender.com` URL.

---

## Method 4: Dedicated Cloud VM (AWS EC2 / DigitalOcean Droplet)

For full 24/7 control, custom domain support, and production privacy:

### Step 1: Provision the Server
- **OS**: Ubuntu 22.04 or 24.04 LTS
- **Hardware**: Minimum 2 vCPU, 2 GB RAM (e.g. AWS `t3.small` / `t3.medium`, DigitalOcean $12/month Droplet).

### Step 2: Install Docker on the Server
SSH into your server:
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### Step 3: Clone Repository and Build Container
```bash
git clone https://github.com/your-username/mcp_a2a_agentic_rag.git
cd mcp_a2a_agentic_rag

# Create your .env file
cat <<EOF > .env
GOOGLE_API_KEY=your_key_here
SERPAPI_KEY=your_key_here
EOF

# Build and run the Docker container
docker build -t mcp-agentic-rag .
docker run -d \
  --name rag-system \
  --restart unless-stopped \
  --env-file .env \
  -p 8501:8501 \
  mcp-agentic-rag
```

### Step 4: Configure Nginx & Free SSL (Let's Encrypt)
To link your own domain (e.g., `rag.yourdomain.com`):

1. Install Nginx and Certbot:
   ```bash
   sudo apt install -y nginx certbot python3-certbot-nginx
   ```
2. Create an Nginx site configuration:
   ```bash
   sudo nano /etc/nginx/sites-available/rag
   ```
   Paste the following:
   ```nginx
   server {
       server_name rag.yourdomain.com;

       location / {
           proxy_pass http://localhost:8501;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_read_timeout 86400;
       }
   }
   ```
3. Enable the site and request an SSL certificate:
   ```bash
   sudo ln -s /etc/nginx/sites-available/rag /etc/nginx/sites-enabled/
   sudo nginx -t && sudo systemctl reload nginx
   sudo certbot --nginx -d rag.yourdomain.com
   ```

Your system is now live at `https://rag.yourdomain.com` with automatic HTTPS renewal!

---

## 🛠️ Ready-to-Use Deployment Files in this Repo

The repository already includes all necessary container configuration files:

1. [`Dockerfile`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/Dockerfile):
   - Uses `python:3.11-slim` with CPU-optimized PyTorch wheels.
   - Pre-downloads `sentence-transformers/all-MiniLM-L6-v2` at build time so the first user query doesn't experience cold-start lag.
2. [`start.sh`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/start.sh):
   - Starts `python main.py` in the background (initializing ports `10001` and `10002`).
   - Waits 8 seconds for agents to bind.
   - Starts Streamlit on port `$PORT` with CORS/XSRF settings tuned for reverse proxies.
3. [`.dockerignore`](file:///c:/Users/shres/Desktop/proj/MCP_A2A/langgraph-ai/agentic-rag/agentic-rag-systems/mcp_a2a_agentic_rag/.dockerignore):
   - Prevents your local `.env`, `venv`, logs, and temporary files from being exposed in the image.

---

## ⚠️ Common Deployment Gotchas & Tips

1. **Never commit `.env` into GitHub**:
   Always set `GOOGLE_API_KEY` and `SERPAPI_KEY` via the hosting provider's **Environment Secrets/Variables** settings.
2. **PyTorch CPU Image Size**:
   Always install PyTorch with `--index-url https://download.pytorch.org/whl/cpu` (configured in our Dockerfile). This saves ~3 GB of image size compared to the default CUDA PyTorch build.
3. **Streamlit WebSocket Connection**:
   If deploying behind Nginx or a cloud proxy, ensure WebSocket upgrade headers (`Upgrade $http_upgrade`, `Connection "upgrade"`) are enabled so Streamlit's live chat streaming functions smoothly.
