@echo off
echo =======================================
echo    GitHub SSH Configuration Setup
echo =======================================
echo.

:: Check if SSH key already exists
if exist "%USERPROFILE%\.ssh\id_ed25519" (
    echo ✅ SSH key already exists
    set SSH_KEY_FILE=%USERPROFILE%\.ssh\id_ed25519.pub
) else if exist "%USERPROFILE%\.ssh\id_rsa" (
    echo ✅ SSH key already exists
    set SSH_KEY_FILE=%USERPROFILE%\.ssh\id_rsa.pub
) else (
    echo ⚠️  No SSH key found. Creating a new one...
    echo.
    
    :: Create .ssh directory if it doesn't exist
    if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"
    
    :: Get user email
    set /p github_email="Enter your GitHub email: "
    
    :: Generate SSH key
    ssh-keygen -t ed25519 -C "!github_email!" -f "%USERPROFILE%\.ssh\id_ed25519" -N ""
    
    set SSH_KEY_FILE=%USERPROFILE%\.ssh\id_ed25519.pub
    echo.
    echo ✅ SSH key created
)

:: Start ssh-agent
echo.
echo Starting ssh-agent...
:: Check if ssh-agent is running
for /f "tokens=1 delims=;" %%i in ('ssh-agent') do @set %%i >nul 2>&1

:: Add key to ssh-agent
ssh-add "%USERPROFILE%\.ssh\id_ed25519" >nul 2>&1
if %errorlevel% neq 0 (
    ssh-add "%USERPROFILE%\.ssh\id_rsa" >nul 2>&1
)

:: Display the public key
echo.
echo ========================================
echo COPY THIS SSH KEY TO GITHUB:
echo ========================================
type "%SSH_KEY_FILE%"
echo ========================================
echo.
echo Steps to add this key to GitHub:
echo 1. Copy the SSH key above
echo 2. Go to https://github.com/settings/keys
echo 3. Click 'New SSH key'
echo 4. Give it a title (e.g., 'Dev Environment Windows')
echo 5. Paste the key and click 'Add SSH key'
echo.
pause

:: Test SSH connection
echo.
echo Testing GitHub SSH connection...
ssh -T git@github.com 2>&1 | findstr "successfully authenticated" >nul
if %errorlevel% equ 0 (
    echo ✅ SSH connection to GitHub successful!
) else (
    echo Testing connection...
    ssh -T git@github.com
)

:: Configure git to use SSH for GitHub
echo.
echo Configuring git to use SSH for GitHub...
git config --global url."git@github.com:".insteadOf "https://github.com/"
echo ✅ Git configured to use SSH for GitHub

:: Update existing repos to use SSH
echo.
echo Updating existing repositories to use SSH...

if exist "frontend" (
    cd frontend
    git remote set-url origin git@github.com:omarelmoghazy/simsbuddy.git
    cd ..
    echo ✅ Frontend updated to use SSH
)

if exist "backend" (
    cd backend
    git remote set-url origin git@github.com:MHGanainy/mvp-backend.git
    cd ..
    echo ✅ Backend updated to use SSH
)

if exist "voice-agent" (
    cd voice-agent
    git remote set-url origin git@github.com:MHGanainy/realtime-voice-assistant.git
    cd ..
    echo ✅ Voice-agent updated to use SSH
)

echo.
echo ✅ SSH setup complete!
echo.
echo Your repositories will now use SSH for all git operations.
echo This means faster clones and no password prompts!
echo.
pause