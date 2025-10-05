# Development Environment Setup

## 🚀 Quick Start Guide

### Step 1: Install Required Software (One-time only)

You need to install 2 programs:

1. **Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Run the installer (click "Yes" to everything)
   - **Windows users**: Restart your computer after installation
   - Start Docker Desktop (it should start automatically)

2. **Git** 
   - **Windows**: Download from https://git-scm.com/download/win
   - **Mac**: Already installed! Skip this.
   - **Linux**: Run `sudo apt-get install git`

### Step 2: Start Everything

1. Make sure Docker Desktop is running (check system tray/menu bar)
2. Double-click the start script:
   - **Windows**: Double-click `start.bat`
   - **Mac/Linux**: Double-click `start.sh`

3. Wait 2-3 minutes (first time will take longer)

### Step 3: Access Your Applications

Once running, open your web browser and go to:
- **Main Application**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Voice Service**: http://localhost:8000

## 📝 Making Changes

1. Open any file in these folders:
   - `frontend/` - React application
   - `backend/` - Node.js API
   - `voice-agent/` - Python voice service

2. Save your changes - everything will automatically reload!

## 🛑 Stopping

Press `Ctrl+C` in the terminal window where the services are running.

## 🔄 Daily Use

1. Start Docker Desktop
2. Double-click the start script
3. Make your changes
4. Press Ctrl+C to stop

## 🆘 Troubleshooting

### "Docker Desktop is not running"
→ Start Docker Desktop application and wait 30 seconds

### "Port already in use" error
→ Another application is using the port. Restart your computer.

### Need to start fresh?
1. Stop everything (Ctrl+C)
2. Run in terminal: `docker-compose down -v`
3. Delete the folders: `frontend`, `backend`, `voice-agent`
4. Run the start script again

### View database content
The database runs at `localhost:5432`. You can connect with:
- Username: `postgres`
- Password: `postgres`
- Database: `template1`

## 📞 Need Help?

If something isn't working:
1. Make sure Docker Desktop is running
2. Check the terminal for error messages
3. Try restarting your computer
4. Run the start script again