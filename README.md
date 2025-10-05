# SimsBuddy Development Environment

## 🎯 What This Does

This setup creates a complete testing environment for SimsBuddy on your computer. Everything runs locally - no coding knowledge needed!

## 📋 Before You Start (One-Time Setup)

### Step 1: Install Docker Desktop
Docker makes everything work together. Think of it as a container that holds all the parts.

**Windows Users:**
1. Download from: https://www.docker.com/products/docker-desktop
2. Run the installer (click "OK" or "Yes" to all prompts)
3. **IMPORTANT**: Restart your computer after installation
4. Docker Desktop should start automatically (look for the whale icon in your system tray)

**Mac Users:**
1. Download from: https://www.docker.com/products/docker-desktop
2. Open the downloaded file and drag Docker to Applications
3. Start Docker from Applications (look for the whale icon in your menu bar)

### Step 2: Install Git (Windows Only)
Git helps manage the code files. Mac already has this!

**Windows Users:**
1. Download from: https://git-scm.com/download/win
2. Run the installer (keep all default settings)
3. No restart needed

### Step 3: Set Up GitHub Access (Optional but Recommended)
This makes updates faster and more reliable.

**Windows:** Double-click `setup-github-ssh.bat`
**Mac:** Double-click `setup-github-ssh.sh`

Follow the instructions that appear. You'll need to copy a key to GitHub (the script will show you how).

## 🚀 Daily Use - Starting SimsBuddy

### To Start Everything:
1. **Make sure Docker Desktop is running** (look for the whale icon)
2. Double-click the appropriate file:
   - **Windows:** Double-click `start.bat`
   - **Mac:** Double-click `start.sh`
3. Choose your database option when prompted:
   - Press `1` for Local Database (works offline)
   - Press `2` for Cloud Database (requires internet)
4. **Wait 3-5 minutes** the first time (it's downloading everything needed)

### When It's Ready:
Open your web browser and go to:
- **Main App:** http://localhost:5173 (this is what users see)
- **Admin Panel:** http://localhost:3000 (backend controls)
- **Voice System:** http://localhost:8000 (handles voice features)

### To Stop Everything:
Press `Ctrl+C` in the black window (terminal) where it's running.

## 📝 About the DevBox Branch

This environment uses a special "devbox" branch - think of it as a testing copy that:
- Automatically updates with the latest changes from the main system
- Keeps your testing separate from the live product
- Syncs every time you start the environment

**You don't need to do anything special** - it handles this automatically!

## 🔧 Troubleshooting

### "Docker Desktop is not running"
**Solution:** 
1. Start Docker Desktop from your Start Menu (Windows) or Applications (Mac)
2. Wait for the whale icon to appear (about 30 seconds)
3. Try running the start script again

### "Port already in use"
**Solution:** Something else is using the same address.
1. Close any other development tools
2. If that doesn't work, restart your computer
3. Run the start script again

### Black window closes immediately
**Solution:** There's an error starting up.
1. Right-click the start script
2. Select "Edit" 
3. Add `pause` at the very end
4. Save and run again to see the error message

### Everything seems frozen or slow
**Solution:** First-time setup takes longer.
1. Wait up to 10 minutes on first run
2. Check if Docker Desktop shows activity
3. If nothing happens after 10 minutes, press Ctrl+C and try again

### Want to start completely fresh?
1. Stop everything with Ctrl+C
2. Delete these folders: `frontend`, `backend`, `voice-agent`
3. In a terminal/command prompt, run: `docker system prune -a` (type 'y' when asked)
4. Run the start script again

## 💡 Quick Tips

- **First time is always slowest** - it's downloading everything needed (can take 10+ minutes)
- **Keep Docker Desktop running** - you need it open for SimsBuddy to work
- **Updates happen automatically** - each time you start, it gets the latest code
- **Your work is saved** - stopping doesn't lose your testing data

## 📞 Getting Help

If something isn't working:

1. **Check Docker Desktop is running** (whale icon visible)
2. **Check your internet connection** (especially for Railway/Cloud database)
3. **Take a screenshot of any error messages**
4. **Note which step you're on when it fails**

### Common Success Signs:
- Docker Desktop shows "Running" 
- The terminal shows lots of text scrolling (this is normal!)
- You see "Services will be available at:" message
- Browser can open http://localhost:5173

### Still Stuck?
- Try restarting your computer (fixes 90% of issues!)
- Make sure no antivirus is blocking Docker
- Windows users: Run as Administrator if needed

## 🎉 You're Ready!

Once everything is running, you can test SimsBuddy just like a real user would. Any changes developers make will automatically appear when you restart the environment.

Remember: This is for TESTING ONLY - don't enter real patient data or sensitive information!