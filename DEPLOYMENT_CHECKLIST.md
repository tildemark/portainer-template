# Deployment Checklist

Use this checklist to ensure smooth deployment of your containerized PHP application.

## Pre-Deployment

### System Requirements
- [ ] Ubuntu Server 20.04+ or compatible Linux distribution
- [ ] Docker 20.10+ installed
- [ ] Docker Compose 1.29+ installed
- [ ] Portainer running (if using Portainer UI)
- [ ] Minimum 2GB RAM available
- [ ] Minimum 10GB disk space available
- [ ] Required ports available (8081, 8082, etc.)

### Verify Prerequisites
```bash
# Check Docker
docker --version

# Check Docker Compose
docker-compose --version

# Check available ports
sudo netstat -tulpn | grep -E ':(8081|8082|8083)'

# Check disk space
df -h

# Check memory
free -h
```

## Initial Setup

### 1. Clone Repository
- [ ] Clone from GitHub
```bash
cd /opt/docker
git clone https://github.com/tildemark/portainer-template.git my-app
cd my-app
```

### 2. Run Setup Script
- [ ] Make setup script executable
- [ ] Run interactive setup
- [ ] Verify directory structure created
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Configure Environment
- [ ] Review .env file
- [ ] Update application name
- [ ] Set appropriate port number
- [ ] Verify database credentials are strong
- [ ] Save credentials securely
```bash
nano .env
```

**Security Check**:
- [ ] Root password is strong (25+ characters)
- [ ] User password is strong (25+ characters)
- [ ] Passwords are different from each other
- [ ] .env file has correct permissions (600)

## Application Migration

### 1. Copy Application Files
- [ ] Copy PHP application to php/app/
- [ ] Verify all files copied
- [ ] Set proper ownership
```bash
sudo cp -r /var/www/html/your-app/* ./php/app/
sudo chown -R www-data:www-data ./php/app
ls -la ./php/app
```

### 2. Export Database
- [ ] Backup existing database
- [ ] Place SQL dump in mariadb/init/
- [ ] Verify SQL file is valid
```bash
sudo mysqldump -u root -p your_database > ./mariadb/init/01-database.sql
chmod 644 ./mariadb/init/01-database.sql
head -20 ./mariadb/init/01-database.sql
```

### 3. Update Application Configuration
- [ ] Locate database config file
- [ ] Update hostname to 'mariadb'
- [ ] Update credentials to match .env
- [ ] Test config syntax
```bash
# Find config files
find ./php/app -name "config.php" -o -name "database.php" -o -name "db.php"

# Update database host
# Change: localhost → mariadb
# Change: 127.0.0.1 → mariadb
```

**Required Changes**:
```php
// OLD
$db_host = 'localhost';

// NEW
$db_host = 'mariadb';
```

### 4. Review PHP Extensions
- [ ] Check if app needs specific PHP extensions
- [ ] Update php/Dockerfile if needed
- [ ] Verify php.ini settings match requirements
```bash
# Check current extensions in Dockerfile
cat php/Dockerfile | grep docker-php-ext-install
```

**Common Extensions**:
- [ ] pdo_mysql / mysqli
- [ ] gd (image processing)
- [ ] zip
- [ ] mbstring
- [ ] curl
- [ ] xml
- [ ] json

## Configuration Review

### 1. Docker Compose
- [ ] Review service definitions
- [ ] Verify port mappings
- [ ] Check volume mounts
- [ ] Validate network configuration
```bash
# Validate syntax
docker-compose config
```

### 2. Nginx Configuration
- [ ] Review server block settings
- [ ] Check root directory path
- [ ] Verify PHP-FPM configuration
- [ ] Review upload size limits
```bash
# Test nginx config syntax
docker run --rm -v $(pwd)/nginx/default.conf:/etc/nginx/conf.d/default.conf nginx:alpine nginx -t
```

### 3. PHP Configuration
- [ ] Review memory limits
- [ ] Check upload/post size limits
- [ ] Verify timezone setting
- [ ] Review execution time limits
```bash
cat php/php.ini | grep -E 'memory_limit|upload_max|max_execution'
```

## First Deployment

### 1. Build and Start Containers
- [ ] Pull latest images
- [ ] Build custom PHP image
- [ ] Start all services
- [ ] Wait for services to be healthy
```bash
docker-compose pull
docker-compose up -d --build
sleep 15
```

### 2. Verify Container Status
- [ ] All containers are running
- [ ] No restart loops
- [ ] Health checks passing
```bash
docker-compose ps
docker ps | grep my-app
```

**Expected Output**:
```
NAME              STATUS
my-app-mariadb    Up (healthy)
my-app-php        Up
my-app-nginx      Up
```

### 3. Check Logs
- [ ] No critical errors in logs
- [ ] Database initialized successfully
- [ ] PHP-FPM started correctly
- [ ] Nginx started correctly
```bash
docker-compose logs mariadb | grep -i error
docker-compose logs php | grep -i error
docker-compose logs nginx | grep -i error
```

### 4. Test Database Connection
- [ ] Can connect to MariaDB
- [ ] Database exists
- [ ] Tables imported correctly
```bash
# Connect to database
docker-compose exec mariadb mysql -u root -p

# Run these commands inside MySQL:
SHOW DATABASES;
USE your_database;
SHOW TABLES;
SELECT COUNT(*) FROM your_table;
EXIT;
```

### 5. Test Application Access
- [ ] Application loads on localhost
- [ ] No 502/503 errors
- [ ] PHP is processing correctly
- [ ] Static files load
```bash
# Test from server
curl -I http://localhost:8081

# Should return HTTP 200
```

### 6. Test from Browser
- [ ] Open http://SERVER_IP:8081
- [ ] Homepage loads correctly
- [ ] Can login (if applicable)
- [ ] Database queries work
- [ ] Images/CSS/JS load

## Network Configuration

### 1. Firewall Rules
- [ ] Allow port 8081 (or your port) through firewall
```bash
# UFW
sudo ufw allow 8081/tcp
sudo ufw status

# iptables
sudo iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
```

### 2. Sophos Firewall Configuration
- [ ] Create NAT rule for external access
- [ ] Configure port forwarding
- [ ] Test from external network

**Sophos NAT Rule**:
- External IP: Your public IP
- External Port: 8081 (or desired)
- Internal IP: 10.10.0.3 (your server)
- Internal Port: 8081
- Protocol: TCP

### 3. DNS Configuration (Optional)
- [ ] Update DNS A record (if using domain)
- [ ] Wait for DNS propagation
- [ ] Test domain access

## Performance Optimization

### 1. Resource Allocation
- [ ] Review container resource usage
- [ ] Adjust if needed
```bash
docker stats --no-stream
```

### 2. PHP Optimization
- [ ] Enable OPcache (if not enabled)
- [ ] Configure opcache settings
```bash
# Add to php/php.ini
opcache.enable=1
opcache.memory_consumption=256
```

### 3. Database Optimization
- [ ] Review database size
- [ ] Add indexes if needed
- [ ] Configure query cache
```bash
docker-compose exec mariadb mysql -u root -p -e "
SELECT 
    table_schema, 
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES 
GROUP BY table_schema;"
```

## Monitoring Setup

### 1. Enable Logging
- [ ] Verify log directories exist
- [ ] Check log file permissions
- [ ] Test log rotation
```bash
ls -la nginx/logs/
```

### 2. Setup Log Rotation
- [ ] Create logrotate config
```bash
sudo nano /etc/logrotate.d/my-app
```

Add:
```
/opt/docker/my-app/nginx/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    missingok
    sharedscripts
    postrotate
        docker-compose exec nginx nginx -s reload > /dev/null 2>&1
    endscript
}
```

### 3. Setup Backup Automation
- [ ] Test backup script
- [ ] Create backup directory
- [ ] Setup cron job
```bash
# Test backup
./backup.sh

# Add to crontab
crontab -e

# Add line:
0 2 * * * /opt/docker/my-app/backup.sh >> /var/log/my-app-backup.log 2>&1
```

## Security Hardening

### 1. File Permissions
- [ ] Verify .env is not world-readable
- [ ] Check application file ownership
- [ ] Secure database directory
```bash
chmod 600 .env
sudo chown -R www-data:www-data php/app
sudo chmod 700 mariadb/data
```

### 2. Network Security
- [ ] Disable external access to Portainer (if not needed)
- [ ] Use firewall to restrict ports
- [ ] Consider VPN for admin access

### 3. SSL/TLS (Production)
- [ ] Setup Traefik with Let's Encrypt (recommended)
- [ ] Or use reverse proxy with SSL
- [ ] Redirect HTTP to HTTPS

### 4. Regular Updates
- [ ] Document update schedule
- [ ] Plan maintenance windows
```bash
# Weekly update check
docker-compose pull
docker-compose up -d
docker image prune -a
```

## Migration from Legacy

### 1. Parallel Running
- [ ] Old app still running on port 80
- [ ] New app running on port 8081
- [ ] Both are functional

### 2. Testing Period
- [ ] Test new app thoroughly (1-7 days)
- [ ] Verify all features work
- [ ] Monitor for errors
- [ ] Compare performance

### 3. Switchover Plan
Choose one method:

**Option A: Port Redirect in Sophos**
- [ ] Change Sophos NAT rule
- [ ] Redirect port 80 traffic to 8081
- [ ] Old app still available locally if needed

**Option B: DNS Update**
- [ ] Update DNS to point to new port
- [ ] Wait for TTL expiration
- [ ] Verify all users migrated

**Option C: Stop Old App**
- [ ] Stop old app on port 80
- [ ] Update Nginx config to use port 80
- [ ] Restart containers

### 4. Rollback Plan
- [ ] Document rollback steps
- [ ] Keep old app backup
- [ ] Test rollback procedure

## Post-Deployment

### 1. Verification (24 hours)
- [ ] Monitor application logs
- [ ] Check error rates
- [ ] Verify backups running
- [ ] Monitor resource usage
- [ ] Check user feedback

### 2. Documentation
- [ ] Document specific configuration changes
- [ ] Update internal wiki/docs
- [ ] Note any issues encountered
- [ ] Document custom modifications

### 3. Cleanup
- [ ] Remove old application files (after successful migration)
- [ ] Clean up old backups
- [ ] Remove unused Docker images
```bash
# After confirming everything works
sudo rm -rf /var/www/html/old-app
docker image prune -a
```

### 4. Monitoring Schedule
- [ ] Daily: Check logs for errors
- [ ] Weekly: Review resource usage
- [ ] Weekly: Test backup restore
- [ ] Monthly: Update Docker images
- [ ] Monthly: Review security

## Troubleshooting Checklist

If something goes wrong:

### Containers Won't Start
- [ ] Check logs: `docker-compose logs -f`
- [ ] Verify port availability
- [ ] Check .env file syntax
- [ ] Verify file permissions

### Application Not Accessible
- [ ] Test locally: `curl http://localhost:8081`
- [ ] Check firewall rules
- [ ] Verify Sophos NAT configuration
- [ ] Check Nginx logs

### Database Connection Failed
- [ ] Verify database container is running
- [ ] Check database credentials in app config
- [ ] Verify hostname is 'mariadb' not 'localhost'
- [ ] Check database logs

### 502 Bad Gateway
- [ ] PHP-FPM container status
- [ ] PHP-FPM logs
- [ ] Nginx to PHP-FPM connection
- [ ] PHP syntax errors in application

## Sign-off

### Deployment Team
- [ ] Developer sign-off
- [ ] System admin sign-off
- [ ] Security review complete
- [ ] Documentation updated

### Deployment Date/Time
```
Deployment Date: _______________
Deployment Time: _______________
Deployed By: _______________
Version: _______________
```

### Post-Deployment Notes
```
Issues Encountered:


Resolutions Applied:


Performance Observations:


Recommendations:
```

## Emergency Contacts

```
System Administrator: _______________
Database Administrator: _______________
Network Administrator: _______________
Developer: _______________
```

## Useful Commands Summary

```bash
# Quick status check
docker-compose ps

# View all logs
docker-compose logs -f

# Restart service
docker-compose restart [service]

# Stop everything
docker-compose down

# Start everything
docker-compose up -d

# Backup now
./backup.sh

# Check resource usage
docker stats --no-stream
```

---

**Remember**: Test everything in a staging environment first!