#!/bin/bash

# MIDNIGHT Cyber Security Division - DigitalOcean Deployment Script
# This script sets up the application on a DigitalOcean GPU droplet

set -e

echo "🚀 MIDNIGHT Cyber Security Division - Deployment Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   exit 1
fi

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed successfully"
else
    print_success "Docker already installed"
fi

# Install Docker Compose
print_status "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed successfully"
else
    print_success "Docker Compose already installed"
fi

# Install NVIDIA Docker (for GPU support)
print_status "Installing NVIDIA Docker for GPU support..."
if ! dpkg -l | grep -q nvidia-docker2; then
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt update
    sudo apt install -y nvidia-docker2
    sudo systemctl restart docker
    print_success "NVIDIA Docker installed successfully"
else
    print_success "NVIDIA Docker already installed"
fi

# Install Node.js (for local development)
print_status "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js installed successfully"
else
    print_success "Node.js already installed"
fi

# Install PM2 for process management
print_status "Installing PM2..."
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
    print_success "PM2 installed successfully"
else
    print_success "PM2 already installed"
fi

# Create application directory
print_status "Setting up application directory..."
APP_DIR="/opt/midnight"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Create SSL directory
print_status "Creating SSL directory..."
mkdir -p ssl
mkdir -p logs

# Set up firewall
print_status "Configuring firewall..."
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# Create environment file template
print_status "Creating environment file template..."
cat > .env.production << EOF
# MIDNIGHT Cyber Security Division - Production Environment
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://your-domain.com
OPENROUTER_API_KEY=your_openrouter_api_key_here

# Security
NEXT_TELEMETRY_DISABLED=1

# Performance
NEXT_SHARP=1
EOF

print_success "Environment file template created (.env.production)"

# Create systemd service for auto-start
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/midnight.service > /dev/null << EOF
[Unit]
Description=MIDNIGHT Cyber Security Division
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable midnight.service

print_success "Systemd service created and enabled"

# Create backup script
print_status "Creating backup script..."
cat > backup.sh << 'EOF'
#!/bin/bash
# MIDNIGHT Backup Script

BACKUP_DIR="/opt/backups/midnight"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup application data
tar -czf "$BACKUP_DIR/midnight_backup_$DATE.tar.gz" \
    --exclude=node_modules \
    --exclude=.next \
    --exclude=logs \
    .

# Keep only last 7 backups
find $BACKUP_DIR -name "midnight_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: midnight_backup_$DATE.tar.gz"
EOF

chmod +x backup.sh

# Create monitoring script
print_status "Creating monitoring script..."
cat > monitor.sh << 'EOF'
#!/bin/bash
# MIDNIGHT Monitoring Script

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "$(date): MIDNIGHT containers are down, restarting..." >> logs/monitor.log
    docker-compose up -d
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "$(date): Disk usage is at ${DISK_USAGE}%" >> logs/monitor.log
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $MEM_USAGE -gt 80 ]; then
    echo "$(date): Memory usage is at ${MEM_USAGE}%" >> logs/monitor.log
fi
EOF

chmod +x monitor.sh

# Add monitoring to crontab
print_status "Setting up monitoring cron job..."
(crontab -l 2>/dev/null; echo "*/5 * * * * $PWD/monitor.sh") | crontab -

print_success "Monitoring cron job added"

echo ""
print_success "🎉 MIDNIGHT Cyber Security Division deployment setup complete!"
echo ""
print_warning "Next steps:"
echo "1. Copy your application files to this directory"
echo "2. Update .env.production with your actual values"
echo "3. Add SSL certificates to the ssl/ directory"
echo "4. Run: docker-compose up -d"
echo ""
print_warning "For GPU support, make sure to:"
echo "1. Install NVIDIA drivers on your droplet"
echo "2. Verify GPU access with: nvidia-smi"
echo ""
print_status "Deployment directory: $PWD"
print_status "Logs directory: $PWD/logs"
print_status "SSL directory: $PWD/ssl"
echo ""
print_success "Your MIDNIGHT Cyber Security Division is ready for deployment! 🔥"
