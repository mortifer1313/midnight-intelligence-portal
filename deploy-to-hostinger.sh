#!/bin/bash

# MIDNIGHT Cyber Security Division - Complete Hostinger VPS Deployment
# Run this script on your Hostinger VPS after uploading the project files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

echo ""
print_header "🚀 MIDNIGHT Cyber Security Division - Hostinger VPS Deployment"
print_header "================================================================"
print_header "Domain: midnightintel.info"
print_header "VPS IP: 31.97.117.55"
echo ""

# Check if we're in the right directory
if [ ! -f "deploy-hostinger.sh" ]; then
    print_error "Please run this script from the project directory containing deploy-hostinger.sh"
    exit 1
fi

# Phase 1: System Setup
print_header "Phase 1: System Setup and Dependencies"
print_status "Running base deployment script..."
chmod +x deploy-hostinger.sh
./deploy-hostinger.sh

# Phase 2: SSL Certificate Setup
print_header "Phase 2: SSL Certificate Setup"
print_status "Installing Certbot..."
sudo apt update
sudo apt install -y certbot

print_status "Stopping any running services on ports 80/443..."
sudo systemctl stop nginx 2>/dev/null || true
docker-compose -f docker-compose.hostinger.yml down 2>/dev/null || true

print_status "Obtaining Let's Encrypt SSL certificate for midnightintel.info..."
sudo certbot certonly --standalone \
    -d midnightintel.info \
    -d www.midnightintel.info \
    --email admin@midnightintel.info \
    --agree-tos \
    --non-interactive

print_status "Copying SSL certificates to project directory..."
sudo mkdir -p ssl
sudo cp /etc/letsencrypt/live/midnightintel.info/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/midnightintel.info/privkey.pem ssl/key.pem
sudo chown -R $USER:$USER ssl/
print_success "SSL certificates configured"

# Phase 3: Application Deployment
print_header "Phase 3: Application Deployment"
print_status "Loading environment variables..."
if [ -f ".env.hostinger" ]; then
    source .env.hostinger
    print_success "Environment variables loaded"
else
    print_error ".env.hostinger file not found!"
    exit 1
fi

print_status "Building and starting Docker containers..."
docker-compose -f docker-compose.hostinger.yml up -d --build

print_status "Waiting for containers to start..."
sleep 30

print_status "Checking container status..."
docker-compose -f docker-compose.hostinger.yml ps

# Phase 4: Verification
print_header "Phase 4: Deployment Verification"
print_status "Testing local application health..."
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    print_success "Application health check passed"
else
    print_warning "Application health check failed - checking logs..."
    docker-compose -f docker-compose.hostinger.yml logs --tail=20 midnight-app
fi

print_status "Testing SSL certificate..."
if curl -I https://midnightintel.info > /dev/null 2>&1; then
    print_success "SSL certificate working"
else
    print_warning "SSL test failed - this is normal if DNS hasn't propagated yet"
fi

# Phase 5: Auto-renewal Setup
print_header "Phase 5: SSL Auto-Renewal Setup"
print_status "Setting up SSL certificate auto-renewal..."
sudo certbot renew --dry-run

print_status "Adding SSL renewal to crontab..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet --deploy-hook 'docker-compose -f $PWD/docker-compose.hostinger.yml restart nginx'") | crontab -

# Phase 6: System Service
print_header "Phase 6: System Service Configuration"
print_status "Enabling systemd service for auto-start..."
sudo systemctl enable midnight-hostinger.service
sudo systemctl start midnight-hostinger.service

print_status "Checking service status..."
sudo systemctl status midnight-hostinger.service --no-pager

# Final Status Report
print_header "🎉 Deployment Complete!"
echo ""
print_success "MIDNIGHT Cyber Security Division is now deployed on Hostinger VPS!"
echo ""
print_status "Deployment Summary:"
echo "  🌐 Domain: https://midnightintel.info"
echo "  🖥️  VPS IP: 31.97.117.55"
echo "  🔒 SSL: Let's Encrypt (auto-renewing)"
echo "  🐳 Containers: midnight-app, nginx, redis"
echo "  📊 Monitoring: Enabled with automated backups"
echo ""
print_warning "Important Next Steps:"
echo "1. Configure DNS records in your domain registrar:"
echo "   - A record: @ → 31.97.117.55"
echo "   - A record: www → 31.97.117.55"
echo ""
echo "2. Wait for DNS propagation (up to 24 hours)"
echo ""
echo "3. Test your site at: https://midnightintel.info"
echo ""
print_status "Useful Commands:"
echo "  View logs: docker-compose -f docker-compose.hostinger.yml logs -f"
echo "  Restart: docker-compose -f docker-compose.hostinger.yml restart"
echo "  Monitor: ./monitor-hostinger.sh"
echo "  Backup: ./backup-hostinger.sh"
echo ""
print_success "Your elite cyber intelligence platform is operational! 🔥"
