# Portainer Template - Dockerized PHP Applications

A comprehensive template for containerizing PHP+Nginx+MariaDB applications using Docker and Portainer. This template is designed for easy deployment and scaling of multiple PHP applications on a single server.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Managing Multiple Applications](#managing-multiple-applications)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Backup and Recovery](#backup-and-recovery)

## ✨ Features

- **Multi-container setup**: Nginx, PHP-FPM, MariaDB in separate containers
- **Port flexibility**: Easy port assignment for multiple apps (8081, 8082, etc.)
- **Database migration**: Simple export/import from existing MariaDB
- **Portainer integration**: Deploy and manage via Portainer UI
- **Scalable architecture**: Template for hosting multiple PHP applications
- **Custom PHP extensions**: Dockerfile for adding required PHP modules
- **Health checks**: Built-in container health monitoring
- **Production-ready**: Nginx optimization and PHP tuning included

## 🔧 Prerequisites

- Ubuntu Server (20.04 or later)
- Docker and Docker Compose installed
- Portainer running
- Existing PHP application to containerize
- Basic knowledge of Docker and Linux CLI

### Install Docker and Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
cd /opt/docker
git clone https://github.com/tildemark/portainer-template.git my-app
cd my-app
```

### 2. Copy Your PHP Application

```bash
# Copy your existing PHP app
sudo cp -r /var/www/html/your-app ./php/app

# Set proper permissions
sudo chown -R www-data:www-data ./php/app
```

### 3. Export Your Database

```bash
# Export existing database
sudo mysqldump -u root -p your_database > ./mariadb/init/01-database.sql

# Set permissions
sudo chmod 644 ./mariadb/init/01-database.sql
```

### 4. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your settings
nano .env
```

### 5. Deploy

```bash
# Deploy with Docker Compose
docker-compose up -d

# Or deploy via Portainer UI
# Stacks → Add Stack → Upload docker-compose.yml
```

## 📁 Directory Structure

```
portainer-template/
├── docker-compose.yml       # Main orchestration file
├── .env.example            # Environment variables template
├── .env                    # Your environment variables (gitignored)
├── .gitignore             # Git ignore rules
├── README.md              # This file
│
├── nginx/
│   ├── default.conf       # Nginx server configuration
│   └── logs/             # Nginx logs (gitignored)
│
├── php/
│   ├── Dockerfile        # Custom PHP image with extensions
│   ├── php.ini          # PHP configuration
│   └── app/             # Your PHP application (gitignored)
│
├── mariadb/
│   ├── init/            # Database initialization scripts
│   │   └── .gitkeep
│   └── data/            # Database files (gitignored)
│
└── traefik/             # Optional reverse proxy
    └── docker-compose.yml
```

## ⚙️ Configuration

### Environment Variables (.env)

Create a `.env` file from the template:

```bash
cp .env.example .env
```

Edit the values:

```env
# Application
APP_NAME=my-app
APP_PORT=8081

# Database
MYSQL_ROOT_PASSWORD=strong_root_password
MYSQL_DATABASE=your_database
MYSQL_USER=your_db_user
MYSQL_PASSWORD=strong_db_password

# PHP
PHP_MEMORY_LIMIT=256M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_MAX_EXECUTION_TIME=300

# Timezone
TZ=Asia/Manila
```

### Update PHP Database Configuration

Edit your application's database config file:

```php
// config.php or database.php
$db_host = 'mariadb';  // Use container name
$db_name = getenv('MYSQL_DATABASE') ?: 'your_database';
$db_user = getenv('MYSQL_USER') ?: 'your_db_user';
$db_pass = getenv('MYSQL_PASSWORD') ?: 'your_password';
```

### Customize PHP Extensions

Edit `php/Dockerfile` to add required extensions:

```dockerfile
# Add extensions
RUN docker-php-ext-install pdo_mysql mysqli gd zip opcache

# Add PECL extensions
RUN pecl install redis && docker-php-ext-enable redis
```

### Nginx Configuration

Modify `nginx/default.conf` for specific application needs:

```nginx
# Example: Add URL rewrites
location /api {
    try_files $uri $uri/ /api/index.php?$query_string;
}

# Example: Increase buffer sizes
fastcgi_buffer_size 256k;
fastcgi_buffers 512 16k;
```

## 🚢 Deployment

### Method 1: Docker Compose CLI

```bash
# Start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Rebuild after changes
docker-compose up -d --build
```

### Method 2: Portainer UI

1. Login to Portainer (usually http://your-server:9000)
2. Navigate to **Stacks** → **Add Stack**
3. Name your stack (e.g., "my-app")
4. Choose **Upload** and select `docker-compose.yml`
5. Add environment variables or upload `.env` file
6. Click **Deploy the stack**

### Method 3: Portainer Git Repository

1. In Portainer, go to **Stacks** → **Add Stack**
2. Choose **Repository**
3. Repository URL: `https://github.com/tildemark/portainer-template.git`
4. Compose path: `docker-compose.yml`
5. Add environment variables
6. Deploy

## 🔄 Managing Multiple Applications

### Port Assignment Strategy

```
Port 80   → Reserved for reverse proxy (Traefik/Nginx)
Port 8080 → Portainer
Port 8081 → First containerized app
Port 8082 → Second containerized app
Port 8083 → Third containerized app
...and so on
```

### Clone Template for New App

```bash
# Clone for new application
cd /opt/docker
git clone https://github.com/tildemark/portainer-template.git app2

cd app2
# Update .env with new port
echo "APP_PORT=8082" >> .env

# Copy new app files
cp -r /var/www/html/app2 ./php/app
```

### Using Shared Reverse Proxy

Deploy Traefik once for all apps:

```bash
cd /opt/docker/traefik
docker-compose up -d
```

Update your app's `docker-compose.yml` to use Traefik labels:

```yaml
services:
  nginx:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.example.com`)"
      - "traefik.http.services.myapp.loadbalancer.server.port=80"
    networks:
      - gpsmaps-network
      - proxy

networks:
  proxy:
    external: true
```

## 🔍 Troubleshooting

### Check Container Status

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Check specific stack
docker-compose ps
```

### View Logs

```bash
# All containers
docker-compose logs -f

# Specific service
docker-compose logs -f nginx
docker-compose logs -f php
docker-compose logs -f mariadb

# Last 100 lines
docker-compose logs --tail=100
```

### Test Database Connection

```bash
# Access MariaDB container
docker exec -it my-app-mariadb mysql -u root -p

# Run SQL query
docker exec my-app-mariadb mysql -u root -p your_database -e "SHOW TABLES;"
```

### Test PHP

```bash
# Check PHP version
docker exec my-app-php php -v

# Check PHP extensions
docker exec my-app-php php -m

# Test PHP-FPM
docker exec my-app-php php-fpm -t
```

### Test Nginx

```bash
# Test Nginx configuration
docker exec my-app-nginx nginx -t

# Reload Nginx
docker exec my-app-nginx nginx -s reload
```

### Network Issues

```bash
# Check port binding
netstat -tulpn | grep 8081

# Test local access
curl http://localhost:8081

# Check Docker networks
docker network ls
docker network inspect my-app_gpsmaps-network
```

### Permission Issues

```bash
# Fix app directory permissions
sudo chown -R www-data:www-data ./php/app

# Fix database directory
sudo chown -R 999:999 ./mariadb/data
```

## 🔒 Security Considerations

### 1. Change Default Passwords

Always change passwords in `.env`:

```bash
# Generate strong passwords
openssl rand -base64 32
```

### 2. Restrict Portainer Access

Configure firewall to allow Portainer only from trusted IPs:

```bash
# UFW example
sudo ufw allow from 10.10.0.0/24 to any port 9000
```

### 3. Use Environment Variables

Never commit sensitive data:

```bash
# Check .gitignore includes
.env
php/app/
mariadb/data/
```

### 4. Enable SSL/TLS

Use Traefik with Let's Encrypt:

```yaml
# In docker-compose.yml
- "--certificatesresolvers.myresolver.acme.email=your@email.com"
- "--certificatesresolvers.myresolver.acme.storage=/acme.json"
```

### 5. Regular Updates

```bash
# Update images
docker-compose pull
docker-compose up -d

# Prune unused resources
docker system prune -a
```

### 6. Database Security

- Use strong passwords
- Limit database user privileges
- Regular backups
- Enable binary logging for point-in-time recovery

## 💾 Backup and Recovery

### Backup Script

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/opt/backups/my-app"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker exec my-app-mariadb mysqldump -u root -p$MYSQL_ROOT_PASSWORD \
    --all-databases > $BACKUP_DIR/database_$DATE.sql

# Backup application files
tar -czf $BACKUP_DIR/app_$DATE.tar.gz ./php/app

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

### Automated Backups with Cron

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /opt/docker/my-app/backup.sh
```

### Restore from Backup

```bash
# Restore database
docker exec -i my-app-mariadb mysql -u root -p$MYSQL_ROOT_PASSWORD \
    < /opt/backups/my-app/database_20250101_020000.sql

# Restore application files
tar -xzf /opt/backups/my-app/app_20250101_020000.tar.gz -C ./php/
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Portainer Documentation](https://docs.portainer.io/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Docker Official Image](https://hub.docker.com/_/php)
- [MariaDB Docker Official Image](https://hub.docker.com/_/mariadb)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Tildemark**
- GitHub: [@tildemark](https://github.com/tildemark)
- Repository: [portainer-template](https://github.com/tildemark/portainer-template)

## ⭐ Support

If this template helped you, please give it a star on GitHub!

---

**Need Help?** Open an issue on GitHub or check the troubleshooting section above.