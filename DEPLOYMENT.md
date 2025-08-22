# MIDNIGHT Cyber Security Division - DigitalOcean Deployment Guide

## 🚀 Quick Deployment Guide

### Recommended DigitalOcean Configuration

**For Minimal Restrictions & Maximum Performance:**

1. **Droplet Type**: GPU-Optimized Droplet
2. **GPU**: NVIDIA RTX A4000 or A5000 (best price/performance)
3. **OS**: Ubuntu 22.04 LTS (most flexible, fewer restrictions)
4. **RAM**: 16GB minimum (32GB recommended for heavy AI workloads)
5. **Storage**: 320GB+ SSD
6. **Location**: Choose based on your target audience

### Why This Configuration?

- **Ubuntu 22.04 LTS**: Fewer restrictions, better package support
- **GPU Support**: Essential for running local AI models if needed
- **High RAM**: Handles multiple concurrent AI requests
- **SSD Storage**: Fast I/O for better performance

## 📋 Pre-Deployment Checklist

1. ✅ DigitalOcean account with GPU droplet access
2. ✅ Domain name (optional but recommended)
3. ✅ OpenRouter API key
4. ✅ SSL certificates (Let's Encrypt recommended)

## 🛠 Deployment Steps

### Step 1: Create DigitalOcean Droplet

```bash
# Using DigitalOcean CLI (optional)
doctl compute droplet create midnight-cyber \
  --image ubuntu-22-04-x64 \
  --size g-2vcpu-8gb \
  --region nyc1 \
  --ssh-keys your-ssh-key-id
```

### Step 2: Connect to Your Droplet

```bash
ssh root@your-droplet-ip
```

### Step 3: Create Non-Root User

```bash
adduser midnight
usermod -aG sudo midnight
su - midnight
```

### Step 4: Upload Application Files

```bash
# From your local machine
scp -r . midnight@your-droplet-ip:/home/midnight/midnight-app
```

### Step 5: Run Deployment Script

```bash
cd /home/midnight/midnight-app
chmod +x deploy.sh
./deploy.sh
```

### Step 6: Configure Environment

```bash
# Edit the environment file
nano .env.production

# Add your actual values:
NEXT_PUBLIC_APP_URL=https://your-domain.com
OPENROUTER_API_KEY=your_actual_api_key
```

### Step 7: Set Up SSL (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/key.pem
sudo chown midnight:midnight ssl/*
```

### Step 8: Deploy Application

```bash
# Build and start the application
docker-compose up -d

# Check status
docker-compose ps
```

## 🔧 Configuration Options

### For Maximum Performance

```bash
# In .env.production, add:
NODE_OPTIONS="--max-old-space-size=4096"
NEXT_SHARP=1
```

### For GPU Utilization

```bash
# Add to docker-compose.yml under midnight-app service:
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

## 🛡 Security Hardening

### Firewall Configuration

```bash
# Basic firewall setup
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### SSH Hardening

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Add these lines:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Port 2222  # Change default port

sudo systemctl restart ssh
```

### Fail2Ban Setup

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📊 Monitoring & Maintenance

### View Logs

```bash
# Application logs
docker-compose logs -f midnight-app

# Nginx logs
docker-compose logs -f nginx

# System logs
tail -f logs/monitor.log
```

### Performance Monitoring

```bash
# Check resource usage
htop

# Check GPU usage (if applicable)
nvidia-smi

# Check Docker stats
docker stats
```

### Backup

```bash
# Manual backup
./backup.sh

# Automated backups are set up via cron
```

## 🚨 Troubleshooting

### Common Issues

1. **Port 3000 already in use**
   ```bash
   sudo lsof -i :3000
   sudo kill -9 <PID>
   ```

2. **Docker permission denied**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **SSL certificate issues**
   ```bash
   # Renew certificates
   sudo certbot renew
   ```

4. **High memory usage**
   ```bash
   # Restart containers
   docker-compose restart
   ```

## 🔄 Updates & Scaling

### Update Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

### Horizontal Scaling

```bash
# Scale to multiple instances
docker-compose up -d --scale midnight-app=3
```

## 💡 Optimization Tips

1. **Use CDN**: CloudFlare for static assets
2. **Database**: Consider Redis for session storage
3. **Load Balancer**: DigitalOcean Load Balancer for multiple droplets
4. **Monitoring**: Set up Prometheus + Grafana
5. **Alerts**: Configure email/Slack notifications

## 🎯 Cost Optimization

- **GPU Droplet**: $0.75-$2.00/hour (depending on GPU type)
- **Storage**: Use block storage for large files
- **Bandwidth**: 1TB included, additional at $0.01/GB
- **Snapshots**: Regular snapshots for backup ($0.05/GB/month)

## 📞 Support

For deployment issues:
1. Check logs: `docker-compose logs`
2. Verify environment: `cat .env.production`
3. Test connectivity: `curl http://localhost:3000`
4. Check firewall: `sudo ufw status`

Your MIDNIGHT Cyber Security Division is now ready for production deployment! 🔥
