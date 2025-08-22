#!/bin/bash

# MIDNIGHT Cyber Security Division - Hostinger VPS Deployment Script
# Optimized for Hostinger VPS infrastructure

set -e

echo "🚀 MIDNIGHT Cyber Security Division - Hostinger VPS Deployment"
echo "============================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_hostinger() {
    echo -e "${PURPLE}[HOSTINGER]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   exit 1
fi

print_hostinger "Starting Hostinger VPS optimized deployment..."

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
print_status "Installing essential packages..."
sudo apt install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release htop

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    
    # Hostinger VPS Docker optimizations
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "5m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF
    
    sudo systemctl restart docker
    print_success "Docker installed with Hostinger optimizations"
else
    print_success "Docker already installed"
fi

# Install Docker Compose
print_status "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
else
    print_success "Docker Compose already installed"
fi

# Install Node.js (for local development)
print_status "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js installed"
else
    print_success "Node.js already installed"
fi

# Install PM2 for process management
print_status "Installing PM2..."
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
    print_success "PM2 installed"
else
    print_success "PM2 already installed"
fi

# Create directories
print_status "Creating application directories..."
mkdir -p ssl logs logs/nginx

# Set up firewall
print_status "Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable
print_success "Firewall configured"

# Install and configure Fail2Ban
print_status "Installing Fail2Ban..."
sudo apt install -y fail2ban

sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
bantime = 1800
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
print_success "Fail2Ban configured"

# Create Hostinger environment file
print_status "Creating Hostinger environment file..."
if [ ! -f .env.hostinger ]; then
    cat > .env.hostinger << EOF
# MIDNIGHT Cyber Security Division - Hostinger VPS Environment
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://your-domain.com
OPENROUTER_API_KEY=your_openrouter_api_key_here

# Security
NEXT_TELEMETRY_DISABLED=1

# Performance (Hostinger VPS optimized)
NEXT_SHARP=1
NODE_OPTIONS="--max-old-space-size=2048"

# Docker
PORT=3000
HOSTNAME=0.0.0.0
EOF
fi
print_success "Hostinger environment file created"

# Create systemd service for Hostinger
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/midnight-hostinger.service > /dev/null <<EOF
[Unit]
Description=MIDNIGHT Cyber Security Division (Hostinger VPS)
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PWD
ExecStart=/usr/local/bin/docker-compose -f docker-compose.hostinger.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.hostinger.yml down
User=$USER
Group=$USER
Environment=PATH=/usr/local/bin:/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable midnight-hostinger.service
print_success "Systemd service created and enabled"

# Create Hostinger monitoring script
print_status "Creating Hostinger monitoring script..."
cat > monitor-hostinger.sh << 'EOF'
#!/bin/bash
# MIDNIGHT Hostinger VPS Monitoring Script

LOG_FILE="logs/monitor-hostinger.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$DATE] $1" >> $LOG_FILE
}

# Check if containers are running
if ! docker-compose -f docker-compose.hostinger.yml ps | grep -q "Up"; then
    log_message "ALERT: MIDNIGHT containers are down, restarting..."
    docker-compose -f docker-compose.hostinger.yml up -d
    log_message "Containers restarted"
fi

# Check disk space (important for VPS)
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    log_message "WARNING: Disk usage is at ${DISK_USAGE}%"
    # Clean up old logs
    find logs/ -name "*.log" -mtime +7 -delete
    docker system prune -f
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $MEM_USAGE -gt 85 ]; then
    log_message "WARNING: Memory usage is at ${MEM_USAGE}%"
fi

# Check if Hostinger VPS is healthy
if curl -s --max-time 5 http://localhost/health > /dev/null 2>&1; then
    log_message "INFO: Application health check passed"
else
    log_message "WARNING: Application health check failed"
fi
EOF

chmod +x monitor-hostinger.sh

# Add monitoring to crontab
print_status "Setting up monitoring cron job..."
(crontab -l 2>/dev/null; echo "*/5 * * * * $PWD/monitor-hostinger.sh") | crontab -
print_success "Monitoring cron job added"

# Create backup script for Hostinger VPS
print_status "Creating backup script..."
cat > backup-hostinger.sh << 'EOF'
#!/bin/bash
# MIDNIGHT Hostinger VPS Backup Script

BACKUP_DIR="/home/$USER/backups"
DATE=$(date +%Y%m%d_%H%M%S)
APP_DIR="$PWD"

mkdir -p $BACKUP_DIR

# Backup application data
tar -czf "$BACKUP_DIR/midnight_hostinger_backup_$DATE.tar.gz" \
    --exclude=node_modules \
    --exclude=.next \
    --exclude=logs \
    --exclude=backups \
    $APP_DIR

# Keep only last 5 backups (save space on VPS)
find $BACKUP_DIR -name "midnight_hostinger_backup_*.tar.gz" -mtime +5 -delete

echo "Backup completed: midnight_hostinger_backup_$DATE.tar.gz"
EOF

chmod +x backup-hostinger.sh

# Add daily backup to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * $PWD/backup-hostinger.sh") | crontab -
print_success "Backup script created and scheduled"

# System optimizations for Hostinger VPS
print_status "Applying Hostinger VPS optimizations..."

# Increase file limits (conservative for VPS)
echo "* soft nofile 32768" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 32768" | sudo tee -a /etc/security/limits.conf

# Network optimizations for VPS
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF

# Hostinger VPS network optimizations
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.ipv4.tcp_rmem = 4096 32768 67108864
net.ipv4.tcp_wmem = 4096 32768 67108864
net.core.netdev_max_backlog = 2500
EOF

sudo sysctl -p
print_success "System optimizations applied"

# Create swap file if not exists (important for VPS)
print_status "Checking swap configuration..."
if [ $(swapon --show | wc -l) -eq 0 ]; then
    print_warning "No swap detected, creating 2GB swap file..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    print_success "Swap file created"
else
    print_success "Swap already configured"
fi

echo ""
print_success "🎉 MIDNIGHT Cyber Security Division Hostinger VPS deployment setup complete!"
echo ""
print_hostinger "Hostinger VPS specific features configured:"
echo "  ✅ Resource-optimized Docker configuration"
echo "  ✅ VPS-friendly monitoring and cleanup"
echo "  ✅ Automatic swap management"
echo "  ✅ Conservative resource limits"
echo "  ✅ Space-efficient backups"
echo ""
print_warning "Next steps:"
echo "1. Update .env.hostinger with your actual values"
echo "2. Add SSL certificates to the ssl/ directory"
echo "3. Run: docker-compose -f docker-compose.hostinger.yml up -d"
echo ""
print_status "Deployment directory: $PWD"
print_status "Logs directory: $PWD/logs"
print_status "SSL directory: $PWD/ssl"
print_status "Backups directory: /home/$USER/backups"
echo ""
print_success "Your MIDNIGHT Cyber Security Division is ready for Hostinger VPS deployment! 🔥"
