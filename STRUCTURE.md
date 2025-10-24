# Repository Structure

This document explains the structure and purpose of each file and directory in the Portainer Template repository.

```
portainer-template/
│
├── 📄 README.md                    # Main documentation
├── 📄 QUICK_REFERENCE.md          # Command quick reference
├── 📄 CONTRIBUTING.md             # Contribution guidelines
├── 📄 STRUCTURE.md                # This file
├── 📄 LICENSE                     # MIT License
├── 📄 .gitignore                  # Git ignore rules
│
├── 🐳 docker-compose.yml          # Main Docker orchestration file
├── 🔧 .env.example                # Environment variables template
├── 🔒 .env                        # Your environment variables (gitignored)
│
├── 🔨 setup.sh                    # Interactive setup script
├── 💾 backup.sh                   # Backup script
│
├── 📁 nginx/                      # Nginx web server configuration
│   ├── default.conf               # Server block configuration
│   └── logs/                      # Nginx log files (gitignored)
│       ├── access.log
│       ├── error.log
│       └── .gitkeep
│
├── 📁 php/                        # PHP-FPM configuration
│   ├── Dockerfile                 # Custom PHP image with extensions
│   ├── php.ini                    # PHP configuration
│   └── app/                       # Your PHP application (gitignored)
│       ├── index.php
│       ├── config.php
│       └── .gitkeep
│
├── 📁 mariadb/                    # MariaDB database
│   ├── init/                      # Database initialization scripts
│   │   ├── 01-database.sql       # Your database dump (gitignored)
│   │   └── .gitkeep
│   └── data/                      # Database files (gitignored)
│       └── .gitkeep
│
└── 📁 traefik/                    # Optional: Reverse proxy (future use)
    └── docker-compose.yml         # Traefik configuration
```

## File Descriptions

### Root Files

#### 📄 README.md
**Purpose**: Main project documentation
**Content**:
- Project overview and features
- Quick start guide
- Complete installation instructions
- Configuration options
- Troubleshooting guide
- Multiple application deployment
**Audience**: New users, administrators

#### 📄 QUICK_REFERENCE.md
**Purpose**: Quick command reference for daily operations
**Content**:
- Common Docker commands
- Database operations
- Troubleshooting steps
- Performance tuning
- Emergency procedures
**Audience**: Active users, system administrators

#### 📄 CONTRIBUTING.md
**Purpose**: Guidelines for contributors
**Content**:
- How to contribute
- Code style guidelines
- Pull request process
- Testing requirements
**Audience**: Developers, contributors

#### 📄 STRUCTURE.md
**Purpose**: Explain repository organization
**Content**: This document
**Audience**: Developers, new contributors

#### 📄 LICENSE
**Purpose**: Legal license for the project
**Content**: MIT License text
**Audience**: Users, legal review

#### 📄 .gitignore
**Purpose**: Specify files Git should ignore
**Content**:
- Environment files (.env)
- Application files (php/app/*)
- Database files (mariadb/data/*)
- Log files (*.log)
- Backup files (*.sql, *.tar.gz)

### Docker Configuration

#### 🐳 docker-compose.yml
**Purpose**: Define and orchestrate all containers
**Services**:
- `mariadb`: Database server
- `php`: PHP-FPM processor
- `nginx`: Web server

**Key Features**:
- Service dependencies
- Health checks
- Volume mappings
- Network configuration
- Environment variables

**Example Structure**:
```yaml
services:
  mariadb:
    image: mariadb:10.11
    environment: # Database credentials
    volumes:     # Data persistence
    networks:    # Internal network
    healthcheck: # Service monitoring
  
  php:
    build: ./php
    volumes:     # Application code
    depends_on:  # Wait for database
  
  nginx:
    image: nginx:alpine
    ports:       # Expose to host
    volumes:     # Config and code
```

#### 🔧 .env.example
**Purpose**: Template for environment variables
**Content**:
- Application settings (name, port)
- Database credentials (placeholder values)
- PHP configuration
- Timezone settings

**Usage**:
```bash
cp .env.example .env
# Edit .env with actual values
```

#### 🔒 .env
**Purpose**: Actual environment variables (not in Git)
**Security**: Contains sensitive data
**Usage**: Automatically loaded by docker-compose

### Scripts

#### 🔨 setup.sh
**Purpose**: Interactive setup wizard
**Features**:
- Creates directory structure
- Generates secure passwords
- Creates .env file
- Sets permissions
- Makes scripts executable

**Usage**:
```bash
chmod +x setup.sh
./setup.sh
```

**Process Flow**:
1. Check prerequisites
2. Create directories
3. Prompt for configuration
4. Generate .env file
5. Set permissions
6. Display summary

#### 💾 backup.sh
**Purpose**: Automated backup script
**Backups**:
- Database (mysqldump)
- Application files
- Configuration files

**Features**:
- Timestamped backups
- Compression
- Retention policy (7 days default)
- Backup verification
- Size reporting

**Usage**:
```bash
./backup.sh
# Or via cron
0 2 * * * /opt/docker/my-app/backup.sh
```

### Nginx Directory

#### 📁 nginx/
**Purpose**: Web server configuration

#### nginx/default.conf
**Purpose**: Nginx server block configuration
**Content**:
- Server settings
- PHP-FPM proxy configuration
- Static file handling
- Security headers
- Logging configuration

**Key Sections**:
```nginx
server {
    listen 80;                    # Listen port
    root /var/www/html;          # Document root
    
    location / {                  # Default location
        try_files $uri $uri/ /index.php;
    }
    
    location ~ \.php$ {          # PHP processing
        fastcgi_pass php:9000;
        # FastCGI parameters
    }
}
```

#### nginx/logs/
**Purpose**: Store Nginx logs
**Files**:
- `access.log`: HTTP requests
- `error.log`: Errors and warnings
**Rotation**: Use logrotate for management

### PHP Directory

#### 📁 php/
**Purpose**: PHP-FPM configuration and application

#### php/Dockerfile
**Purpose**: Build custom PHP image with extensions
**Content**:
- Base PHP-FPM image
- System dependencies
- PHP extensions
- Composer (if needed)
- User permissions

**Common Extensions**:
```dockerfile
RUN docker-php-ext-install \
    pdo_mysql \      # Database
    mysqli \         # MySQL improved
    gd \             # Image processing
    zip \            # Zip compression
    opcache          # Performance
```

#### php/php.ini
**Purpose**: PHP runtime configuration
**Settings**:
- Memory limits
- Upload size
- Execution time
- Timezone
- Error reporting
- Session handling

**Key Settings**:
```ini
memory_limit = 256M
upload_max_filesize = 100M
max_execution_time = 300
date.timezone = Asia/Manila
```

#### php/app/
**Purpose**: Your PHP application directory
**Content**: (copied by you)
- index.php
- config files
- application code
- assets

**Note**: This directory is in .gitignore

### MariaDB Directory

#### 📁 mariadb/
**Purpose**: Database storage and initialization

#### mariadb/init/
**Purpose**: Database initialization scripts
**Usage**: SQL files here run once on first container start
**Files**: (you add)
- `01-database.sql`: Your database dump
- `02-users.sql`: Additional users
- `03-permissions.sql`: Grant permissions

**Execution Order**: Alphabetically by filename

#### mariadb/data/
**Purpose**: Persistent database storage
**Content**: MariaDB data files
**Permissions**: Owned by UID 999 (mysql user)
**Backup**: Use mysqldump, not direct copy

### Traefik Directory (Optional)

#### 📁 traefik/
**Purpose**: Reverse proxy for multiple applications
**Use Case**:
- Route multiple apps through port 80/443
- Automatic SSL with Let's Encrypt
- Load balancing

**Future Enhancement**: See README for implementation

## Directory Permissions

```bash
# Application files
php/app/          # 755 or 775, owned by www-data

# Database files
mariadb/data/     # 700, owned by UID 999 (mysql)

# Configuration files
nginx/*.conf      # 644
php/php.ini       # 644
.env              # 600 (sensitive data)

# Scripts
*.sh              # 755 (executable)

# Logs
nginx/logs/       # 755
```

## Data Flow

```
User Request
    ↓
[Host Port 8081]
    ↓
[Nginx Container :80]
    ↓
[PHP-FPM Container :9000]
    ↓
[MariaDB Container :3306]
    ↓
Response
```

## Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `./php/app` | `/var/www/html` | Application code |
| `./nginx/default.conf` | `/etc/nginx/conf.d/default.conf` | Nginx config |
| `./nginx/logs` | `/var/log/nginx` | Nginx logs |
| `./php/php.ini` | `/usr/local/etc/php/php.ini` | PHP config |
| `./mariadb/data` | `/var/lib/mysql` | Database storage |
| `./mariadb/init` | `/docker-entrypoint-initdb.d` | Init scripts |

## Networks

**Default Network**: `[app-name]_gpsmaps-network`
- Type: Bridge
- Purpose: Internal container communication
- Services: nginx, php, mariadb

**Container Communication**:
- Use service names as hostnames
- Example: PHP connects to `mariadb:3306`

## Security Considerations

### Gitignored Files
These contain sensitive data and should NEVER be committed:
- `.env` - Database passwords
- `php/app/*` - May contain API keys
- `mariadb/data/*` - Database contents
- `mariadb/init/*.sql` - May contain user data

### File Permissions
- `.env` should be 600 (owner read/write only)
- Scripts should be 755 (owner read/write/execute, others read/execute)
- Database directory should be 700 (owner only)

## Best Practices

1. **Never commit sensitive data**
   - Use .env for secrets
   - Keep .env in .gitignore

2. **Keep structure consistent**
   - Follow naming conventions
   - Maintain directory organization

3. **Document changes**
   - Update README when adding features
   - Update this file for structure changes

4. **Test before committing**
   - Ensure setup.sh works
   - Verify docker-compose up
   - Test on clean system

5. **Version control**
   - Commit configuration templates
   - Don't commit application code
   - Don't commit generated files