# Quick Reference Guide

## 🚀 Common Commands

### Starting and Stopping

```bash
# Start all containers
docker-compose up -d

# Stop all containers
docker-compose down

# Restart all containers
docker-compose restart

# Stop and remove everything (including volumes)
docker-compose down -v
```

### Viewing Logs

```bash
# View all logs (follow mode)
docker-compose logs -f

# View specific service logs
docker-compose logs -f nginx
docker-compose logs -f php
docker-compose logs -f mariadb

# View last 100 lines
docker-compose logs --tail=100

# View logs since specific time
docker-compose logs --since 2h
```

### Container Management

```bash
# List running containers
docker-compose ps

# Execute command in container
docker-compose exec php bash
docker-compose exec nginx sh
docker-compose exec mariadb mysql -u root -p

# Rebuild containers
docker-compose up -d --build

# Pull latest images
docker-compose pull
```

## 🗄️ Database Operations

### Accessing Database

```bash
# Access MariaDB CLI
docker-compose exec mariadb mysql -u root -p

# Run SQL query directly
docker-compose exec mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} \
  -e "SHOW DATABASES;"

# Access with specific database
docker-compose exec mariadb mysql -u root -p your_database
```

### Backup and Restore

```bash
# Backup database
docker-compose exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
  --all-databases > backup_$(date +%Y%m%d).sql

# Restore database
docker-compose exec -T mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} \
  < backup_20250124.sql

# Import specific database
docker-compose exec -T mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} \
  your_database < your_database.sql
```

### Database Queries

```sql
-- Show all databases
SHOW DATABASES;

-- Show tables in database
USE your_database;
SHOW TABLES;

-- Show table structure
DESCRIBE your_table;

-- Check database size
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES 
GROUP BY table_schema;
```

## 🔧 Troubleshooting

### Container Won't Start

```bash
# Check container status
docker-compose ps -a

# View error logs
docker-compose logs [service_name]

# Check if port is already in use
sudo netstat -tulpn | grep [port_number]

# Check Docker daemon
sudo systemctl status docker
```

### Permission Issues

```bash
# Fix application permissions
sudo chown -R www-data:www-data ./php/app

# Fix database permissions
sudo chown -R 999:999 ./mariadb/data

# Fix nginx logs
sudo chown -R $(id -u):$(id -g) ./nginx/logs
```

### Database Connection Issues

```bash
# Check if database is running
docker-compose exec mariadb mysqladmin -u root -p ping

# Check database logs
docker-compose logs mariadb

# Test connection from PHP container
docker-compose exec php php -r "echo mysqli_connect('mariadb', 'user', 'pass', 'db') ? 'OK' : mysqli_connect_error();"
```

### Network Issues

```bash
# List Docker networks
docker network ls

# Inspect network
docker network inspect [network_name]

# Check container IP addresses
docker-compose exec php hostname -i

# Test connectivity between containers
docker-compose exec php ping -c 3 mariadb
docker-compose exec nginx ping -c 3 php
```

### Performance Issues

```bash
# Check container resource usage
docker stats

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a

# Check PHP-FPM status
docker-compose exec php php-fpm -t

# Restart PHP-FPM
docker-compose restart php
```

## 📦 Application Updates

### Update PHP Application

```bash
# Copy new files
sudo cp -r /path/to/new/files/* ./php/app/

# Set permissions
sudo chown -R www-data:www-data ./php/app

# Clear PHP opcache (if enabled)
docker-compose exec php php -r "opcache_reset();"

# No restart needed - files are mounted
```

### Update Configuration

```bash
# Edit nginx config
nano nginx/default.conf

# Test nginx config
docker-compose exec nginx nginx -t

# Reload nginx
docker-compose exec nginx nginx -s reload

# Edit PHP config
nano php/php.ini

# Restart PHP to apply changes
docker-compose restart php
```

### Update Docker Images

```bash
# Pull latest images
docker-compose pull

# Rebuild and restart
docker-compose up -d --build

# Remove old images
docker image prune -a
```

## 🔍 Monitoring

### Check Service Health

```bash
# Check all services
docker-compose ps

# Check specific service health
docker inspect --format='{{.State.Health.Status}}' [container_name]

# View health check logs
docker inspect --format='{{json .State.Health}}' [container_name] | jq
```

### Monitor Logs in Real-time

```bash
# All services with timestamps
docker-compose logs -f -t

# Filter logs by service
docker-compose logs -f nginx | grep error

# Monitor multiple services
docker-compose logs -f nginx php
```

### Resource Monitoring

```bash
# Live resource usage
docker stats

# Container processes
docker-compose top

# Disk usage by container
docker ps -s
```

## 🔐 Security

### Update Passwords

```bash
# Update root password
docker-compose exec mariadb mysql -u root -p
> ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';
> FLUSH PRIVILEGES;

# Update user password
> ALTER USER 'username'@'%' IDENTIFIED BY 'new_password';
> FLUSH PRIVILEGES;

# Update .env file
nano .env
```

### Check Open Ports

```bash
# List all open ports
sudo netstat -tulpn

# Check specific port
sudo lsof -i :8081

# Check Docker port mappings
docker-compose port nginx 80
```

### File Permissions

```bash
# Secure .env file
chmod 600 .env

# Secure database files
sudo chmod 700 mariadb/data

# Secure config files
chmod 644 nginx/default.conf php/php.ini
```

## 🔄 Migration Between Servers

### Export Everything

```bash
# Run backup script
./backup.sh

# Or manual backup
docker-compose exec mariadb mysqldump -u root -p --all-databases > full_backup.sql
tar -czf app_files.tar.gz php/app/
tar -czf configs.tar.gz .env docker-compose.yml nginx/ php/php.ini
```

### Import on New Server

```bash
# Clone repository
git clone https://github.com/tildemark/portainer-template.git
cd portainer-template

# Run setup
./setup.sh

# Copy application files
tar -xzf app_files.tar.gz -C php/

# Copy configs
tar -xzf configs.tar.gz

# Import database
docker-compose up -d mariadb
sleep 10
docker-compose exec -T mariadb mysql -u root -p < full_backup.sql

# Start all services
docker-compose up -d
```

## 📊 Performance Tuning

### Nginx Optimization

```nginx
# In nginx/default.conf

# Enable gzip compression
gzip on;
gzip_vary on;
gzip_types text/plain text/css application/json application/javascript text/xml;

# Enable caching
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 365d;
    add_header Cache-Control "public, immutable";
}

# Increase buffer sizes for large requests
client_body_buffer_size 16K;
client_header_buffer_size 1k;
client_max_body_size 8m;
large_client_header_buffers 4 16k;
```

### PHP Optimization

```ini
# In php/php.ini

# OPcache settings
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.validate_timestamps=0
opcache.revalidate_freq=0

# Realpath cache
realpath_cache_size=4096K
realpath_cache_ttl=600
```

### MariaDB Optimization

```bash
# Add to docker-compose.yml under mariadb service
command:
  - --max_connections=200
  - --innodb_buffer_pool_size=512M
  - --innodb_log_file_size=128M
  - --query_cache_type=1
  - --query_cache_size=64M
```

## 🐛 Debugging

### Enable PHP Error Reporting

```bash
# Temporary - in running container
docker-compose exec php sh -c "echo 'display_errors = On' >> /usr/local/etc/php/php.ini"
docker-compose restart php

# Permanent - edit php/php.ini
display_errors = On
error_reporting = E_ALL
log_errors = On
error_log = /var/log/php_errors.log
```

### Enable Nginx Debug Logging

```nginx
# In nginx/default.conf
error_log /var/log/nginx/error.log debug;
```

### Check PHP-FPM Status

```bash
# Add to nginx config
location ~ ^/(status|ping)$ {
    access_log off;
    fastcgi_pass php:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
}

# Then access
curl http://localhost:8081/status
```

## 📝 Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Docker Compose aliases
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'
alias dcps='docker-compose ps'
alias dcrestart='docker-compose restart'

# Container access
alias phpsh='docker-compose exec php bash'
alias nginxsh='docker-compose exec nginx sh'
alias dbsh='docker-compose exec mariadb mysql -u root -p'

# Quick checks
alias dcstats='docker stats'
alias dcclean='docker system prune -a'
```

## 🆘 Emergency Procedures

### Container Crash Recovery

```bash
# 1. Check what happened
docker-compose logs [service_name] --tail=100

# 2. Stop everything
docker-compose down

# 3. Check for port conflicts
sudo netstat -tulpn | grep [port]

# 4. Start with fresh logs
docker-compose up -d

# 5. Monitor startup
docker-compose logs -f
```

### Database Corruption Recovery

```bash
# 1. Stop database
docker-compose stop mariadb

# 2. Backup current state
sudo cp -r mariadb/data mariadb/data.backup

# 3. Try to repair
docker-compose up -d mariadb
docker-compose exec mariadb mysqlcheck -u root -p --auto-repair --all-databases

# 4. If still broken, restore from backup
docker-compose down
sudo rm -rf mariadb/data/*
docker-compose up -d mariadb
# Import latest backup
```

### Rollback to Previous Version

```bash
# 1. Stop current version
docker-compose down

# 2. Restore from backup
tar -xzf /opt/backups/app_20250123_020000.tar.gz -C php/

# 3. Restore database if needed
docker-compose up -d mariadb
docker-compose exec -T mariadb mysql -u root -p < backup.sql

# 4. Start services
docker-compose up -d
```

## 📞 Getting Help

- **Documentation**: Check README.md for detailed setup
- **Logs**: Always check logs first: `docker-compose logs -f`
- **GitHub Issues**: https://github.com/tildemark/portainer-template/issues
- **Docker Docs**: https://docs.docker.com
- **Portainer Docs**: https://docs.portainer.io

## 💡 Pro Tips

1. **Always use `.env` file** for sensitive data
2. **Regular backups** - run `./backup.sh` daily via cron
3. **Monitor logs** - set up log rotation to prevent disk full
4. **Test changes** - use staging environment before production
5. **Keep images updated** - run `docker-compose pull` weekly
6. **Document changes** - keep notes of configuration changes
7. **Use health checks** - ensure containers restart on failure
8. **Network isolation** - use separate networks for different apps