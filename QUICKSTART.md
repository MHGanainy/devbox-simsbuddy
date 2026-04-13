# 🚀 Quick Start Guide - SimsBuddy Staging Environment

Welcome! This guide will help you set up the SimsBuddy staging environment in just a few minutes.

---

## 📖 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [First Time Setup](#-first-time-setup)
3. [Daily Usage](#-daily-usage)
4. [Updating Code](#-updating-code)
5. [Troubleshooting](#-troubleshooting)
6. [FAQ](#-frequently-asked-questions)
7. [Additional Resources](#-additional-resources)

---

## 📋 Prerequisites

Before you begin, make sure you have these installed:

### 1. **Docker Desktop** 🐳
Docker Desktop lets us run all the services in containers.

**Download:**
- **Mac:** [Download Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
- **Windows:** [Download Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- **Linux:** [Install Docker Engine](https://docs.docker.com/engine/install/)

**After installing:**
1. Open Docker Desktop
2. Wait for it to show "Docker Desktop is running"
3. Keep it running in the background

### 2. **Git** 📦
Git helps us download and manage the code.

**Check if you have it:**
```bash
git --version
```

**If not installed, download:**
- **Mac:** [Download Git for Mac](https://git-scm.com/download/mac) or use `brew install git`
- **Windows:** [Download Git for Windows](https://git-scm.com/download/win)
- **Linux:** `sudo apt-get install git` (Ubuntu/Debian) or `sudo yum install git` (CentOS/RHEL)

### 3. **Text Editor** (Recommended)
- **VS Code:** [Download VS Code](https://code.visualstudio.com/) (Recommended)
- Or any text editor you prefer (Sublime, Atom, Notepad++, etc.)

### 4. **Disk Space**
- At least **10 GB free** disk space
- The setup script will check this for you

---

## 🎬 First Time Setup

### Step 1: Install Prerequisites

Make sure you have Docker Desktop and Git installed (see above).

### Step 2: Clone This Repository

```bash
# Clone the dev-environment repository
git clone <your-repo-url> dev-environment
cd dev-environment
```

### Step 3: Create Your .env File

```bash
# Copy the example file
cp .env.example .env

# Edit it with your favorite text editor
code .env              # VS Code
nano .env              # Nano
vim .env               # Vim
notepad .env           # Windows Notepad
```

**Fill in these required values:**

| Variable | Where to Get It |
|----------|----------------|
| `DATABASE_URL` | Railway dashboard → PostgreSQL → Connect |
| `LIVEKIT_URL` | https://cloud.livekit.io/ → Project Settings |
| `LIVEKIT_API_KEY` | https://cloud.livekit.io/ → Project Settings → Keys |
| `LIVEKIT_API_SECRET` | https://cloud.livekit.io/ → Project Settings → Keys |
| `GROQ_API_KEY` | https://console.groq.com/keys |
| `ASSEMBLY_API_KEY` | https://www.assemblyai.com/app/account |
| `INWORLD_API_KEY` | https://studio.inworld.ai/workspaces |
| `OPENAI_API_KEY` | https://platform.openai.com/api-keys |
| `NEXT_PUBLIC_GOOGLE_CLIENT_ID` | Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client IDs |
| `NEXT_PUBLIC_EMAIL_JS_*` (4 vars) | https://dashboard.emailjs.com/admin |
| `STRIPE_SECRET_KEY` | https://dashboard.stripe.com/test/apikeys |
| `STRIPE_WEBHOOK_SECRET` | https://dashboard.stripe.com/test/webhooks |

**Optional:** Leave other variables (DEEPGRAM, ELEVEN, AWS, Google Cloud) blank if you don't need them.

**Tip:** Ask your team lead for shared development API keys to save time!

### Step 4: Run the Setup Script

```bash
./start-staging.sh
```

**That's it!** The script will:
1. ✅ Check that everything is ready (pre-flight checks)
2. ✅ Download the latest code from staging branch
3. ✅ Build Docker images
4. ✅ Start all services
5. ✅ Verify everything is working

**Expected time:** 3-5 minutes (first run), ~1 minute for subsequent runs

---

## 💼 Daily Usage

Once you've completed the first-time setup, here's how to use the staging environment day-to-day:

### Starting the Environment

```bash
./start-staging.sh
```

This will:
- Check prerequisites are still met
- Pull latest code from staging branch
- Start all services
- Show you the URLs when ready

**Time:** ~1 minute (much faster after first time)

### Stopping the Environment

**Option 1 - Keyboard Shortcut (if script is running):**
```bash
Press Ctrl+C
```

**Option 2 - Stop Script:**
```bash
./stop-staging.sh
```

**Option 3 - Manual:**
```bash
docker-compose -f docker-compose.staging.yml down
```

### Checking Service Status

```bash
docker-compose -f docker-compose.staging.yml ps
```

You should see all 4 services with "Up" status:
- `dev-environment-redis-1` - Up (healthy)
- `dev-environment-frontend-1` - Up
- `dev-environment-backend-1` - Up
- `dev-environment-voice-agent-1` - Up

### Viewing Logs

```bash
# View all logs (live updates)
docker-compose -f docker-compose.staging.yml logs -f

# View specific service logs
docker-compose -f docker-compose.staging.yml logs frontend -f
docker-compose -f docker-compose.staging.yml logs backend -f
docker-compose -f docker-compose.staging.yml logs voice-agent -f
docker-compose -f docker-compose.staging.yml logs redis -f

# View last 50 lines
docker-compose -f docker-compose.staging.yml logs --tail=50

# Stop following logs
Press Ctrl+C
```

### Restarting a Single Service

```bash
# Restart just the backend
docker-compose -f docker-compose.staging.yml restart backend

# Restart just the frontend
docker-compose -f docker-compose.staging.yml restart frontend

# Restart just the voice-agent
docker-compose -f docker-compose.staging.yml restart voice-agent
```

---

## 🔄 Updating Code

When your team pushes new code to the staging branch, use the update manager:

### Interactive Update Manager

```bash
./update-staging.sh
```

This opens an interactive menu:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📦 UPDATE OPTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [1] Update all repositories
  [2] Update frontend only
  [3] Update backend only
  [4] Update voice-agent only
  [5] Check status only (no updates)
  [0] Exit
```

**What it does:**
- ✅ Shows current status of each repo (commit hash, commits behind)
- ✅ Detects uncommitted changes
- ✅ Offers to stash your local changes
- ✅ Pulls latest code from staging
- ✅ Shows what changed (commit log)
- ✅ Restores your stashed changes
- ✅ Asks if you want to restart the service
- ✅ Backs up your .env file automatically

### Quick Update (All Repos)

```bash
./update-staging.sh
# Then press: 1 (for "Update all")
```

### When to Update

**Recommended:**
- At the start of each work day
- Before starting a new feature
- After team members merge changes
- When you see "X commits behind" in the status

**How often:** Daily or as needed

---

## ⏱️ What to Expect

### First Time Setup Timeline

| Step | What's Happening | Time |
|------|------------------|------|
| 🔍 **Pre-flight Checks** | Verifying Docker, Git, ports, .env | 10 seconds |
| 📥 **Downloading Code** | Cloning 3 repos from GitHub | 30-60 seconds |
| 🏗️ **Building Services** | Building voice-agent Docker image | 2-3 minutes |
| 🚀 **Starting Services** | Starting all 4 containers | 30-40 seconds |
| ✅ **Ready!** | All services running | Done! |

**Total:** 3-5 minutes first time, ~1 minute after that

---

## ✅ How to Verify It's Working

After the script finishes, you should see:

```
✅ All services are running!

🌐 Access your services:
   Frontend:    http://localhost:5173
   Backend API: http://localhost:3000
   Voice Agent: http://localhost:8000

Press Ctrl+C to stop all services
```

### Quick Browser Checks:

1. **Open Frontend:** http://localhost:5173
   - You should see the SimsBuddy login page
   - ✅ **Working** = Page loads

2. **Check Backend:** http://localhost:3000/api/health
   - You should see: `{"status":"OK","timestamp":"..."}`
   - ✅ **Working** = JSON response appears

3. **Check Voice Agent:** http://localhost:8000/
   - You should see: `{"service":"Voice Assistant Orchestrator","status":"running"...}`
   - ✅ **Working** = JSON response appears

---

## 🛠️ Troubleshooting

### Problem: "Docker Desktop is not running"

**Solution:**
1. Open Docker Desktop application
2. Wait for the whale icon to show "Docker Desktop is running"
3. Run `./start-staging.sh` again

---

### Problem: "Port already in use"

This means another application is using one of our ports (3000, 5173, 6379, or 8000).

**Find what's using the port:**
```bash
# Mac/Linux
lsof -i :3000
lsof -i :5173
lsof -i :6379
lsof -i :8000

# Windows (PowerShell)
netstat -ano | findstr :3000
```

**Solutions:**
1. **Stop the conflicting service**
2. **Or restart your computer** (easiest option)
3. Run `./start-staging.sh` again

---

### Problem: "Git authentication failed"

**Solution:**
When prompted, choose option **1 (HTTPS)** - it works without SSH setup.

If you still have issues:
```bash
# Check your Git credentials
git config --global user.name
git config --global user.email

# Set them if needed
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

### Problem: ".env file is missing"

**Solution:**
1. Copy the example file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` in a text editor
3. Fill in the required values (ask your team lead for API keys)
4. Run `./start-staging.sh` again

**Note:** The start-staging.sh script will offer to create .env for you automatically!

---

### Problem: "Services start but pages won't load"

**Solution:**
1. Wait an extra 30 seconds (services might still be initializing)
2. Check Docker Desktop - all containers should show "Running"
3. Try accessing the URLs again
4. If still not working, restart:
   ```bash
   # Press Ctrl+C to stop
   # Then run again
   ./start-staging.sh
   ```

---

### Problem: "Build failed" or "Docker error"

**Solution:**
1. Make sure you have at least **10 GB free disk space**
2. Restart Docker Desktop (quit and open again)
3. Clean up old Docker data:
   ```bash
   docker system prune -a
   ```
   **Warning:** This removes all unused Docker images
4. Run `./start-staging.sh` again

---

### Problem: "Hot reload not working"

**Solution:**
1. Make sure you're editing files in the correct directories:
   - Frontend: `./frontend-ssr/src/...`
   - Backend: `./backend/src/...`
   - Voice-agent: `./voice-agent/backend/...`
2. Check Docker Desktop → Settings → Resources → File Sharing
3. Restart the affected service:
   ```bash
   docker-compose -f docker-compose.staging.yml restart frontend
   ```

---

### Problem: "Database connection errors"

**Solution:**
1. Check your `.env` file has correct `DATABASE_URL`
2. Verify you can access Railway database:
   ```bash
   # From backend container
   docker exec -it dev-environment-backend-1 sh
   npx prisma studio
   # Should open Prisma Studio if DB connection works
   ```
3. Ask team lead to verify Railway database is accessible

---

### Problem: "Voice-agent service won't start"

**Solution:**
1. Check Redis is running:
   ```bash
   docker-compose -f docker-compose.staging.yml ps redis
   # Should show "Up (healthy)"
   ```
2. Check voice-agent logs:
   ```bash
   docker-compose -f docker-compose.staging.yml logs voice-agent --tail=50
   ```
3. Restart voice-agent:
   ```bash
   docker-compose -f docker-compose.staging.yml restart voice-agent
   ```

---

## 🤔 Frequently Asked Questions

### Q: How long does setup take?
**A:** First time: 3-5 minutes. Subsequent runs: ~1 minute.

### Q: Do I need to run start-staging.sh every time?
**A:** Yes, whenever you want to start the services. But it's quick after the first time!

### Q: Will my local changes be lost when I update?
**A:** No! The update script automatically stashes your changes and restores them after updating.

### Q: Can I work on multiple branches?
**A:** This setup is specifically for the staging branch. For other branches, use the main start.sh script.

### Q: What if I need to change my .env file?
**A:**
1. Stop services: `./stop-staging.sh`
2. Edit `.env` file
3. Start services: `./start-staging.sh`

### Q: How do I know if services are running?
**A:** Check:
- Frontend: http://localhost:5173 (should load the app)
- Backend: http://localhost:3000/api/health (should show `{"status":"OK"}`)
- Voice Agent: http://localhost:8000/ (should show JSON response)

### Q: Can I run this alongside the local environment?
**A:** No, they use the same ports. Stop one before starting the other.

### Q: What's the difference between staging and production?
**A:**
- **Staging:** For testing new features before production
- **Production:** Live environment for real users
- This setup is for staging only

### Q: Do I need all the API keys?
**A:**
- **Required:** DATABASE_URL, LIVEKIT_*, GROQ_API_KEY, ASSEMBLY_API_KEY, INWORLD_API_KEY, OPENAI_API_KEY, NEXT_PUBLIC_GOOGLE_CLIENT_ID, NEXT_PUBLIC_EMAIL_JS_*, Stripe
- **Optional:** DEEPGRAM, ELEVEN, AWS, Google Cloud, etc.

### Q: How do I get API keys?
**A:** See the links in `.env.example` or ask your team lead for shared development keys.

### Q: Services started but I see warnings about missing variables?
**A:** Optional AI service keys (DEEPGRAM, ELEVEN, etc.) can be left blank. Core functionality works without them.

### Q: How much disk space do I need?
**A:** At least 10GB free. The script will warn you if you're running low.

### Q: Can I use this on Windows?
**A:** Yes! The scripts work on Mac, Linux, and Windows (with Git Bash or WSL).

### Q: Hot reload isn't working. What's wrong?
**A:**
1. Make sure you're editing files in the mounted directories
2. Check Docker Desktop has file sharing enabled
3. Try restarting the affected service

### Q: How do I completely clean everything and start fresh?
**A:**
```bash
# Stop and remove all data
docker-compose -f docker-compose.staging.yml down -v

# Then start again
./start-staging.sh
```

### Q: Where are the logs saved?
**A:** Check the `logs/` directory. Each run creates a timestamped log file like `logs/staging_20251104_163000.log`

### Q: What services are running?
**A:** 4 services:
- **Redis** - Session storage and Celery message broker
- **Frontend** - Next.js 16 SSR (React 19, Turbopack, Ant Design)
- **Backend** - Fastify API server with Prisma ORM
- **Voice-Agent** - AI voice conversation system (FastAPI + Celery)

### Q: How do I update just one service?
**A:** Use the update manager:
```bash
./update-staging.sh
# Then select [2] for frontend, [3] for backend, or [4] for voice-agent
```

### Q: What if I accidentally delete something?
**A:** The update-staging.sh script backs up your .env file before every update. Check for `.env.backup.*` files in the directory.

---

## 📖 Additional Resources

### Documentation
- **Quick Start:** You're reading it! (QUICKSTART.md)
- **Environment Template:** See `.env.example` for all configuration options
- **Full Documentation:** See [README.md](README.md) for technical details

### External Resources
- **Docker Documentation:** https://docs.docker.com/
- **Git Documentation:** https://git-scm.com/doc
- **LiveKit Documentation:** https://docs.livekit.io/
- **Fastify Documentation:** https://www.fastify.io/docs/
- **React Documentation:** https://react.dev/
- **Prisma Documentation:** https://www.prisma.io/docs

### Getting Help
1. Check the [Troubleshooting](#-troubleshooting) section above
2. Check the logs: `logs/staging_*.log`
3. Ask your team in Slack/Discord
4. Create an issue in the repository

---

## 📝 Summary Cheat Sheet

```bash
# First time setup
cp .env.example .env              # Create config
# (edit .env with real values)   # Fill in API keys
./start-staging.sh                # Start everything

# Daily usage
./start-staging.sh                # Start services
./update-staging.sh               # Update code
./stop-staging.sh                 # Stop services

# Checking status
docker-compose -f docker-compose.staging.yml ps           # Service status
docker-compose -f docker-compose.staging.yml logs -f      # View logs

# Individual service control
docker-compose -f docker-compose.staging.yml restart backend
docker-compose -f docker-compose.staging.yml logs backend -f

# Clean restart
docker-compose -f docker-compose.staging.yml down -v
./start-staging.sh
```

---

## 🎉 You're Ready!

Once you see the success message with URLs, you're all set to:
- ✅ Access the frontend at http://localhost:5173
- ✅ Test API endpoints at http://localhost:3000
- ✅ Develop with hot reload enabled
- ✅ Update code with one command
- ✅ Stop/start services easily

**Welcome to the team!** 🚀

---

**Last Updated:** 2025-11-04
**Version:** Staging Environment v2.0
**Maintained by:** SimsBuddy DevOps Team
