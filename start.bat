@echo off
echo =======================================
echo    Starting Development Environment
echo    (devbox branch)
echo =======================================
echo.

echo Checking prerequisites...
echo.

:: Check if Git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Git is not installed!
    echo.
    echo Please install Git from:
    echo https://git-scm.com/download/win
    echo.
    echo After installing Git, run this script again.
    pause
    exit /b 1
) else (
    echo ✅ Git is installed
)

:: Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker is not installed!
    echo.
    echo Please install Docker Desktop from:
    echo https://www.docker.com/products/docker-desktop
    echo.
    echo After installing Docker Desktop, restart your computer and run this script again.
    pause
    exit /b 1
) else (
    echo ✅ Docker is installed
)

:: Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker Desktop is not running!
    echo.
    echo Please:
    echo 1. Start Docker Desktop application
    echo 2. Wait 30 seconds for it to fully start
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Docker Desktop is running
)

:: Check SSH key
if exist "%USERPROFILE%\.ssh\id_ed25519" (
    echo ✅ SSH key exists
) else if exist "%USERPROFILE%\.ssh\id_rsa" (
    echo ✅ SSH key exists
) else (
    echo ⚠️  No SSH key found. Run setup-github-ssh.bat first
    pause
    exit /b 1
)

echo.

:: Database Selection
echo =======================================
echo Select Database Option:
echo =======================================
echo 1) Local PostgreSQL (Docker)
echo 2) Railway Cloud Database
echo.
set /p db_choice="Enter your choice (1 or 2): "

if "%db_choice%"=="1" (
    echo ✅ Using Local PostgreSQL
    set COMPOSE_FILE=docker-compose.local.yml
    set DB_NAME=Local PostgreSQL
) else if "%db_choice%"=="2" (
    echo ✅ Using Railway Cloud Database
    set COMPOSE_FILE=docker-compose.cloud.yml
    set DB_NAME=Railway Cloud
) else (
    echo Invalid choice. Defaulting to Local PostgreSQL
    set COMPOSE_FILE=docker-compose.local.yml
    set DB_NAME=Local PostgreSQL
)

echo.
echo =======================================
echo Managing devbox branches...
echo =======================================
echo.

:: Setup Frontend devbox branch
echo Setting up Frontend...
if not exist "frontend" (
    echo Cloning Frontend repository ^(devbox branch^)...
    git clone -b devbox git@github.com:omarelmoghazy/simsbuddy.git frontend 2>nul
    if %errorlevel% neq 0 (
        echo devbox branch doesn't exist, cloning main and creating devbox...
        git clone git@github.com:omarelmoghazy/simsbuddy.git frontend
        cd frontend
        git checkout -b devbox
        cd ..
    )
) else (
    echo Updating Frontend repository...
    cd frontend
    
    :: Get current branch
    for /f "tokens=*" %%i in ('git branch --show-current') do set current_branch=%%i
    
    if not "%current_branch%"=="devbox" (
        echo Switching to devbox branch...
        git checkout devbox 2>nul
        if %errorlevel% neq 0 (
            git checkout -b devbox
        )
    )
    
    :: Fetch latest changes
    echo Fetching latest changes...
    git fetch origin
    
    :: Merge main into devbox
    echo Syncing with main branch...
    git merge origin/main --no-edit 2>nul
    
    if %errorlevel% equ 0 (
        echo ✅ Frontend synced with main
    ) else (
        echo ⚠️  Merge conflicts detected in Frontend
        echo Attempting to resolve automatically...
        git merge --abort
        git reset --hard origin/devbox
        echo Reset to remote devbox. Manual merge with main may be needed.
    )
    
    cd ..
)

:: Setup Backend devbox branch
echo.
echo Setting up Backend...
if not exist "backend" (
    echo Cloning Backend repository ^(devbox branch^)...
    git clone -b devbox git@github.com:MHGanainy/mvp-backend.git backend 2>nul
    if %errorlevel% neq 0 (
        echo devbox branch doesn't exist, cloning main and creating devbox...
        git clone git@github.com:MHGanainy/mvp-backend.git backend
        cd backend
        git checkout -b devbox
        cd ..
    )
) else (
    echo Updating Backend repository...
    cd backend
    
    :: Get current branch
    for /f "tokens=*" %%i in ('git branch --show-current') do set current_branch=%%i
    
    if not "%current_branch%"=="devbox" (
        echo Switching to devbox branch...
        git checkout devbox 2>nul
        if %errorlevel% neq 0 (
            git checkout -b devbox
        )
    )
    
    :: Fetch latest changes
    echo Fetching latest changes...
    git fetch origin
    
    :: Merge main into devbox
    echo Syncing with main branch...
    git merge origin/main --no-edit 2>nul
    
    if %errorlevel% equ 0 (
        echo ✅ Backend synced with main
    ) else (
        echo ⚠️  Merge conflicts detected in Backend
        echo Attempting to resolve automatically...
        git merge --abort
        git reset --hard origin/devbox
        echo Reset to remote devbox. Manual merge with main may be needed.
    )
    
    cd ..
)

:: Setup Voice Agent devbox branch
echo.
echo Setting up Voice Agent...
if not exist "voice-agent" (
    echo Cloning Voice Agent repository ^(devbox branch^)...
    git clone -b devbox git@github.com:MHGanainy/realtime-voice-assistant.git voice-agent 2>nul
    if %errorlevel% neq 0 (
        echo devbox branch doesn't exist, cloning main and creating devbox...
        git clone git@github.com:MHGanainy/realtime-voice-assistant.git voice-agent
        cd voice-agent
        git checkout -b devbox
        cd ..
    )
) else (
    echo Updating Voice Agent repository...
    cd voice-agent
    
    :: Get current branch
    for /f "tokens=*" %%i in ('git branch --show-current') do set current_branch=%%i
    
    if not "%current_branch%"=="devbox" (
        echo Switching to devbox branch...
        git checkout devbox 2>nul
        if %errorlevel% neq 0 (
            git checkout -b devbox
        )
    )
    
    :: Fetch latest changes
    echo Fetching latest changes...
    git fetch origin
    
    :: Merge main into devbox
    echo Syncing with main branch...
    git merge origin/main --no-edit 2>nul
    
    if %errorlevel% equ 0 (
        echo ✅ Voice Agent synced with main
    ) else (
        echo ⚠️  Merge conflicts detected in Voice Agent
        echo Attempting to resolve automatically...
        git merge --abort
        git reset --hard origin/devbox
        echo Reset to remote devbox. Manual merge with main may be needed.
    )
    
    cd ..
)

echo.
echo =======================================
echo Starting all services...
echo =======================================
echo.
echo Database: %DB_NAME%
echo Branch: devbox (synced with main)
echo.
echo Services will be available at:
echo   📱 Frontend:    http://localhost:5173
echo   ⚡ Backend API: http://localhost:3000
echo   🎤 Voice Agent: http://localhost:8000
echo.
echo Press Ctrl+C to stop all services
echo.

docker-compose -f %COMPOSE_FILE% up

pause