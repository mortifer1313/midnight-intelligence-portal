# MIDNIGHT Cyber Security Division - Hostinger VPS Deployment TODO

## ✅ Pre-Deployment Setup (COMPLETED)
- [x] Created nginx.hostinger.conf with domain configuration
- [x] Created .env.hostinger with your API key and domain
- [x] Verified all deployment files are ready

## 🚀 Deployment Steps

### Phase 1: Connect to VPS and Upload Files
- [ ] **Step 1**: Connect to your Hostinger VPS
  ```bash
  ssh root@31.97.117.55
  ```

- [ ] **Step 2**: Create deployment directory
  ```bash
  mkdir -p /home/midnight
  cd /home/midnight
  ```

- [ ] **Step 3**: Upload project files (choose one method)
  
  **Option A: Using SCP (from your local machine)**
  ```bash
  scp -r /path/to/your/project root@31.97.117.55:/home/midnight/midnight-app
  ```
  
  **Option B: Using Git (recommended)**
  ```bash
  git clone https://github.com/yourusername/your-repo.git midnight-app
  cd midnight-app
  ```

### Phase 2: Run Deployment Script
- [ ] **Step 4**: Make deployment script executable and run
  ```bash
  cd /home/midnight/midnight-app
  chmod +x deploy-hostinger.sh
  ./deploy-hostinger.sh
  ```

### Phase 3: SSL Certificate Setup
- [ ] **Step 5**: Install Certbot and get Let's Encrypt certificate
  ```bash
  # Install Certbot
  sudo apt update
  sudo apt install -y certbot
  
  # Stop any services using port 80
  sudo systemctl stop nginx 2>/dev/null || true
  docker-compose -f docker-compose.hostinger.yml down 2>/dev/null || true
  
  # Get SSL certificate for midnightintel.info
  sudo certbot certonly --standalone -d midnightintel.info -d www.midnightintel.info --email admin@midnightintel.info --agree-tos --non-interactive
  
  # Copy certificates to project
  sudo mkdir -p ssl
  sudo cp /etc/letsencrypt/live/midnightintel.info/fullchain.pem ssl/cert.pem
  sudo cp /etc/letsencrypt/live/midnightintel.info/privkey.pem ssl/key.pem
  sudo chown -R $USER:$USER ssl/
  ```

### Phase 4: Deploy Application
- [ ] **Step 6**: Start the application
  ```bash
  # Load environment variables
  source .env.hostinger
  
  # Build and start containers
  docker-compose -f docker-compose.hostinger.yml up -d
  
  # Check if containers are running
  docker-compose -f docker-compose.hostinger.yml ps
  ```

- [ ] **Step 7**: Verify deployment
  ```bash
  # Check application logs
  docker-compose -f docker-compose.hostinger.yml logs -f midnight-app
  
  # Test local connection
  curl http://localhost:3000/health
  
  # Check if site is accessible
  curl -I https://midnightintel.info
  ```

### Phase 5: DNS Configuration
- [ ] **Step 8**: Configure DNS records (do this in your domain registrar)
  ```
  Type: A
  Name: @
  Value: 31.97.117.55
  TTL: 3600
  
  Type: A  
  Name: www
  Value: 31.97.117.55
  TTL: 3600
  ```

### Phase 6: Enable Auto-Start
- [ ] **Step 9**: Enable systemd service
  ```bash
  sudo systemctl enable midnight-hostinger.service
  sudo systemctl start midnight-hostinger.service
  sudo systemctl status midnight-hostinger.service
  ```

### Phase 7: Set Up SSL Auto-Renewal
- [ ] **Step 10**: Configure automatic SSL renewal
  ```bash
  # Test renewal
  sudo certbot renew --dry-run
  
  # Add to crontab for automatic renewal
  (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet --deploy-hook 'docker-compose -f /home/midnight/midnight-app/docker-compose.hostinger.yml restart nginx'") | crontab -
  ```

## 🔍 Verification Checklist
- [ ] VPS accessible via SSH
- [ ] All containers running (midnight-app, nginx, redis)
- [ ] SSL certificate installed and working
- [ ] Domain pointing to VPS IP (31.97.117.55)
- [ ] Site accessible at https://midnightintel.info
- [ ] API endpoints working
- [ ] Monitoring scripts running
- [ ] Backup system configured

## 🚨 Troubleshooting Commands

### Check Service Status
```bash
# Check containers
docker-compose -f docker-compose.hostinger.yml ps

# Check logs
docker-compose -f docker-compose.hostinger.yml logs -f

# Check system resources
htop
df -h
free -h
```

### Restart Services
```bash
# Restart all containers
docker-compose -f docker-compose.hostinger.yml restart

# Restart specific service
docker-compose -f docker-compose.hostinger.yml restart nginx
docker-compose -f docker-compose.hostinger.yml restart midnight-app
```

### SSL Issues
```bash
# Check SSL certificate
sudo certbot certificates

# Renew SSL certificate
sudo certbot renew

# Check nginx configuration
docker-compose -f docker-compose.hostinger.yml exec nginx nginx -t
```

## 📊 Monitoring Commands
```bash
# View monitoring logs
tail -f logs/monitor-hostinger.log

# Manual monitoring check
./monitor-hostinger.sh

# Check application health
curl https://midnightintel.info/health

# View system stats
docker stats
```

## 🎯 Success Indicators
- ✅ Site loads at https://midnightintel.info
- ✅ SSL certificate shows as valid
- ✅ All bot interfaces work correctly
- ✅ API responses are fast (< 2 seconds)
- ✅ No errors in application logs
- ✅ System resources under 80% usage

## 📞 Support Information
- **VPS IP**: 31.97.117.55
- **Domain**: midnightintel.info
- **SSH**: ssh root@31.97.117.55
- **Application Port**: 3000 (internal)
- **Web Ports**: 80 (HTTP), 443 (HTTPS)
