# 📁 How to Upload Your Project Files to Hostinger VPS

## Method 1: Using SCP (Secure Copy Protocol) - Recommended

### From Windows (using Command Prompt or PowerShell):
```bash
# Navigate to your project directory
cd C:\path\to\your\midnight-project

# Upload entire project to VPS
scp -r . root@31.97.117.55:/home/midnight/midnight-app
```

### From Mac/Linux Terminal:
```bash
# Navigate to your project directory
cd /path/to/your/midnight-project

# Upload entire project to VPS
scp -r . root@31.97.117.55:/home/midnight/midnight-app
```

### If you get "Host key verification failed":
```bash
# First time connecting, accept the host key
ssh root@31.97.117.55
# Type 'yes' when prompted, then exit
exit

# Now try the scp command again
scp -r . root@31.97.117.55:/home/midnight/midnight-app
```

## Method 2: Using Git (if your project is in a repository)

### Step 1: Push your project to GitHub/GitLab
```bash
# In your local project directory
git add .
git commit -m "Ready for Hostinger deployment"
git push origin main
```

### Step 2: Clone on your VPS
```bash
# SSH into your VPS
ssh root@31.97.117.55

# Create directory and clone
mkdir -p /home/midnight
cd /home/midnight
git clone https://github.com/yourusername/your-repo-name.git midnight-app
```

## Method 3: Using FileZilla (GUI Method)

### Step 1: Download FileZilla
- Download from: https://filezilla-project.org/

### Step 2: Connect to your VPS
- **Host**: 31.97.117.55
- **Username**: root
- **Password**: [your VPS password]
- **Port**: 22

### Step 3: Upload files
- Navigate to `/home/midnight/` on the remote side
- Create folder `midnight-app`
- Drag and drop your entire project folder

## Method 4: Using WinSCP (Windows only)

### Step 1: Download WinSCP
- Download from: https://winscp.net/

### Step 2: Connect
- **File protocol**: SFTP
- **Host name**: 31.97.117.55
- **User name**: root
- **Password**: [your VPS password]

### Step 3: Upload
- Navigate to `/home/midnight/`
- Create `midnight-app` folder
- Upload all your project files

## Method 5: Using Hostinger File Manager (via Codify Panel)

### Step 1: Access Codify Panel
- Log into your Hostinger account
- Go to VPS management
- Open Codify Panel

### Step 2: Use File Manager
- Navigate to `/home/midnight/`
- Create `midnight-app` folder
- Upload files using the web interface

## After Upload - Verify Files

### SSH into your VPS and check:
```bash
ssh root@31.97.117.55
cd /home/midnight/midnight-app
ls -la

# You should see files like:
# - deploy-to-hostinger.sh
# - docker-compose.hostinger.yml
# - nginx.hostinger.conf
# - .env.hostinger
# - package.json
# - src/
# - etc.
```

## Troubleshooting Upload Issues

### Permission Denied:
```bash
# Create the directory first on VPS
ssh root@31.97.117.55
mkdir -p /home/midnight/midnight-app
exit

# Then try upload again
scp -r . root@31.97.117.55:/home/midnight/midnight-app
```

### Large File Upload (if using SCP):
```bash
# Upload in compressed format
tar -czf midnight-project.tar.gz .
scp midnight-project.tar.gz root@31.97.117.55:/home/midnight/

# Then extract on VPS
ssh root@31.97.117.55
cd /home/midnight
tar -xzf midnight-project.tar.gz
mv [extracted-folder-name] midnight-app
```

### Connection Timeout:
```bash
# Use compression and keep-alive
scp -C -o ServerAliveInterval=60 -r . root@31.97.117.55:/home/midnight/midnight-app
```

## Quick Upload Command (Copy & Paste Ready)

**Replace `/path/to/your/project` with your actual project path:**

```bash
# For Windows (PowerShell/CMD)
scp -r C:\path\to\your\midnight-project\* root@31.97.117.55:/home/midnight/midnight-app/

# For Mac/Linux
scp -r /path/to/your/project/* root@31.97.117.55:/home/midnight/midnight-app/
```

## Next Step After Upload

Once files are uploaded, run the deployment:
```bash
ssh root@31.97.117.55
cd /home/midnight/midnight-app
./deploy-to-hostinger.sh
```

Choose the method that works best for your operating system and comfort level!
