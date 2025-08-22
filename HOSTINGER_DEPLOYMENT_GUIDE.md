# 🚀 MIDNIGHT Cyber Security Division - Hostinger VPS Deployment Guide

## Complete Step-by-Step Deployment Instructions

### Prerequisites
- Hostinger VPS account with root access
- Domain name (optional but recommended)
- OpenRouter API key
- Basic knowledge of SSH and command line

---

## 📋 Phase 1: VPS Setup & Initial Configuration

### Step 1: Connect to Your Hostinger VPS

```bash
# SSH into your VPS (replace with your actual IP)
ssh root@your-vps-ip

# Create a non-root user for security
adduser midnight
usermod -aG sudo midnight

# Switch to the new user
su - midnight
```

### Step 2: Upload Your Application Files

**Option A: Using SCP (from your local machine)**
```bash
# From your local machine, upload the entire project
scp -r /path/to/your/midnight-project midnight@your-vps-ip:/home/midnight/
```

**Option B: Using Git (recommended)**
```bash
# On your VPS, clone your repository
cd /home/midnight
git clone https://github.com/yourusername/midnight-cyber-security.git
cd midnight-cyber-security
```

### Step 3: Run the Hostinger Deployment Script

```bash
# Make the script executable
chmod +x deploy-hostinger.shc

# Run the deployment script
./deploy-hostinger.sh
```

**What this script does:**
- Installs Docker and Docker Compose
- Sets up system optimizations for VPS
- Configures firewall and security
- Creates monitoring and backup scripts
- Sets up systemd service for auto-start

---

## 🔧 Phase 2: Environment Configuration

### Step 4: Configure Environment Variables

```bash
# Edit the Hostinger environment file
nano .env.hostinger
```

**Update with your actual values:**
```env
# MIDNIGHT Cyber Security Division - Hostinger VPS Environment
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://your-domain.com
OPENROUTER_API_KEY=your_actual_openrouter_api_key_here

# Security
NEXT_TELEMETRY_DISABLED=1

# Performance (Hostinger VPS optimized)
NEXT_SHARP=1
NODE_OPTIONS="--max-old-space-size=2048"

# Docker
PORT=3000
HOSTNAME=0.0.0.0
```

### Step 5: SSL Certificate Setup (Optional but Recommended)

**Option A: Let's Encrypt (Free SSL)**
```bash
# Install Certbot
sudo apt install certbot

# Stop any running services on port 80
sudo systemctl stop nginx 2>/dev/null || true
docker-compose -f docker-compose.hostinger.yml down 2>/dev/null || true

# Get SSL certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates to your project
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/key.pem
sudo chown midnight:midnight ssl/*
```

**Option B: Self-Signed Certificate (for testing)**
```bash
# Create self-signed certificate
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"
```

---

## 🚀 Phase 3: Application Deployment

### Step 6: Deploy the Application

```bash
# Build and start the application using Hostinger configuration
docker-compose -f docker-compose.hostinger.yml up -d

# Check if containers are running
docker-compose -f docker-compose.hostinger.yml ps
```

**Expected output:**
```
NAME                    COMMAND                  SERVICE             STATUS              PORTS
midnight-app-1          "node server.js"         midnight-app        running             0.0.0.0:3000->3000/tcp
nginx-1                 "/docker-entrypoint.…"   nginx               running             0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
redis-1                 "docker-entrypoint.s…"   redis               running             6379/tcp
```

### Step 7: Verify Deployment

```bash
# Check application logs
docker-compose -f docker-compose.hostinger.yml logs -f midnight-app

# Test local connection
curl http://localhost:3000

# Check system resources
htop

# View monitoring logs
tail -f logs/monitor-hostinger.log
```

---

## 🔒 Phase 4: Security & Domain Configuration

### Step 8: Configure Domain (if using one)

**Update DNS Records:**
- Point your domain's A record to your VPS IP address
- Wait for DNS propagation (can take up to 24 hours)

**Update Nginx Configuration:**
```bash
# Edit the Nginx configuration if needed
nano nginx.hostinger.conf

# Update server_name from _ to your actual domain
# server_name your-domain.com www.your-domain.com;
```

### Step 9: Enable Systemd Service (Auto-start on boot)

```bash
# Enable the service to start on boot
sudo systemctl enable midnight-hostinger.service

# Start the service
sudo systemctl start midnight-hostinger.service

# Check service status
sudo systemctl status midnight-hostinger.service
```

---

## 📊 Phase 5: Monitoring & Maintenance

### Step 10: Set Up Monitoring

The deployment script automatically sets up:

**Monitoring Script** (runs every 5 minutes):
```bash
# View monitoring logs
tail -f logs/monitor-hostinger.log

# Manual monitoring check
./monitor-hostinger.sh
```

**Backup Script** (runs daily at 2 AM):
```bash
# Manual backup
./backup-hostinger.sh

# View backups
ls -la /home/midnight/backups/
```

### Step 11: Performance Optimization

**Check Resource Usage:**
```bash
# Memory usage
free -h

# Disk usage
df -h

# Docker stats
docker stats

# Container logs
docker-compose -f docker-compose.hostinger.yml logs --tail=50
```

**Optimize if needed:**
```bash
# Clean up Docker
docker system prune -f

# Restart services if high memory usage
docker-compose -f docker-compose.hostinger.yml restart
```

---

## 🚨 Troubleshooting Guide

### Common Issues & Solutions

**1. Port 3000 already in use:**
```bash
sudo lsof -i :3000
sudo kill -9 <PID>
docker-compose -f docker-compose.hostinger.yml restart
```

**2. SSL certificate issues:**
```bash
# Renew Let's Encrypt certificate
sudo certbot renew
sudo systemctl reload nginx
```

**3. High memory usage:**
```bash
# Check what's using memory
ps aux --sort=-%mem | head

# Restart containers
docker-compose -f docker-compose.hostinger.yml restart
```

**4. Application not accessible:**
```bash
# Check firewall
sudo ufw status

# Ensure ports are open
sudo ufw allow 80
sudo ufw allow 443

# Check if services are running
docker-compose -f docker-compose.hostinger.yml ps
```

**5. Database connection issues:**
```bash
# Check Redis
docker-compose -f docker-compose.hostinger.yml exec redis redis-cli ping

# Restart Redis
docker-compose -f docker-compose.hostinger.yml restart redis
```

---

## 🔄 Updates & Maintenance

### Updating the Application

```bash
# Pull latest changes (if using Git)
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.hostinger.yml down
docker-compose -f docker-compose.hostinger.yml up -d --build

# Check logs
docker-compose -f docker-compose.hostinger.yml logs -f
```

### Regular Maintenance Tasks

**Weekly:**
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean Docker
docker system prune -f

# Check disk space
df -h
```

**Monthly:**
```bash
# Rotate logs
sudo logrotate -f /etc/logrotate.conf

# Update SSL certificates
sudo certbot renew

# Review monitoring logs
grep -i error logs/monitor-hostinger.log
```

---

## 📈 Performance Monitoring

### Key Metrics to Monitor

**System Resources:**
- CPU usage: Should stay below 80%
- Memory usage: Should stay below 85%
- Disk usage: Should stay below 80%

**Application Health:**
- Response time: Should be under 2 seconds
- Error rate: Should be below 1%
- Uptime: Should be above 99.5%

**Monitoring Commands:**
```bash
# Real-time system monitoring
htop

# Check application response time
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000

# View error logs
grep -i error logs/*.log
```

---

## 🎯 Success Checklist

- [ ] VPS connected and user created
- [ ] Application files uploaded
- [ ] Deployment script executed successfully
- [ ] Environment variables configured
- [ ] SSL certificate installed (optional)
- [ ] Application deployed and running
- [ ] Domain configured (if applicable)
- [ ] Systemd service enabled
- [ ] Monitoring and backups working
- [ ] Application accessible from internet

---

## 🆘 Support & Resources

### Getting Help

1. **Check logs first:**
   ```bash
   docker-compose -f docker-compose.hostinger.yml logs
   tail -f logs/monitor-hostinger.log
   ```

2. **System status:**
   ```bash
   sudo systemctl status midnight-hostinger.service
   docker-compose -f docker-compose.hostinger.yml ps
   ```

3. **Resource usage:**
   ```bash
   htop
   df -h
   docker stats
   ```

### Useful Commands Reference

```bash
# Start application
docker-compose -f docker-compose.hostinger.yml up -d

# Stop application
docker-compose -f docker-compose.hostinger.yml down

# Restart application
docker-compose -f docker-compose.hostinger.yml restart

# View logs
docker-compose -f docker-compose.hostinger.yml logs -f

# Update application
git pull && docker-compose -f docker-compose.hostinger.yml up -d --build

# Backup application
./backup-hostinger.sh

# Monitor system
./monitor-hostinger.sh
```

---

## 🎉 Congratulations!

Your MIDNIGHT Cyber Security Division is now successfully deployed on Hostinger VPS with:

✅ **Advanced cyber hacker theme** with deep shocking orange and dark bright turquoise colors  
✅ **Enhanced BotInterface** with cyber styling and animations  
✅ **Complete logo and branding** assets  
✅ **Advanced CSS effects** and animations  
✅ **Production-ready deployment** on Hostinger VPS  
✅ **Automated monitoring** and backup systems  
✅ **SSL security** and firewall protection  
✅ **Resource optimization** for VPS environment  

Your elite cyber intelligence platform is now operational! 🔥

**Access your application at:** `https://your-domain.com` or `http://your-vps-ip`
