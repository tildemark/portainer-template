#!/bin/bash
#
# Setup script for Portainer Template
# Usage: ./setup.sh
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════╗
║   Portainer Template Setup Script    ║
║        Dockerized PHP Apps            ║
╚═══════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root${NC}"
    exit 1
fi

# Check for required commands
echo -e "${YELLOW}Checking prerequisites...${NC}"

for cmd in docker docker-compose git; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}✗ $cmd is not installed${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ $cmd is installed${NC}"
    fi
done

# Create directory structure
echo -e "\n${YELLOW}Creating directory structure...${NC}"

directories=(
    "nginx/logs"
    "php/app"
    "mariadb/init"
    "mariadb/data"
)

for dir in "${directories[@]}"; do
    mkdir -p "$dir"
    echo -e "${GREEN}✓ Created $dir${NC}"
done

# Create .gitkeep files
touch php/app/.gitkeep
touch mariadb/init/.gitkeep
touch mariadb/data/.gitkeep
touch nginx/logs/.gitkeep

# Setup .env file
echo -e "\n${YELLOW}Setting up environment variables...${NC}"

if [ -f .env ]; then
    echo -e "${YELLOW}⚠ .env file already exists${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Skipping .env setup${NC}"
    else
        setup_env=true
    fi
else
    setup_env=true
fi

if [ "$setup_env" = true ]; then
    # Prompt for configuration
    read -p "Enter application name [my-app]: " APP_NAME
    APP_NAME=${APP_NAME:-my-app}
    
    read -p "Enter application port [8081]: " APP_PORT
    APP_PORT=${APP_PORT:-8081}
    
    read -p "Enter database name: " DB_NAME
    read -p "Enter database user: " DB_USER
    
    # Generate secure passwords
    ROOT_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    USER_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    
    # Create .env file
    cat > .env << EOF
# Application Configuration
APP_NAME=${APP_NAME}
APP_PORT=${APP_PORT}

# Database Configuration
MYSQL_ROOT_PASSWORD=${ROOT_PASS}
MYSQL_DATABASE=${DB_NAME}
MYSQL_USER=${DB_USER}
MYSQL_PASSWORD=${USER_PASS}

# PHP Configuration
PHP_MEMORY_LIMIT=256M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M
PHP_MAX_EXECUTION_TIME=300
PHP_MAX_INPUT_TIME=300

# Timezone
TZ=Asia/Manila

# Debug (set to Off in production)
PHP_DISPLAY_ERRORS=Off
PHP_ERROR_REPORTING=E_ALL
EOF
    
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Save these credentials!${NC}"
    echo -e "Database root password: ${ROOT_PASS}"
    echo -e "Database user password: ${USER_PASS}"
fi

# Make scripts executable
echo -e "\n${YELLOW}Making scripts executable...${NC}"
chmod +x backup.sh
chmod +x setup.sh
echo -e "${GREEN}✓ Scripts are now executable${NC}"

# Set proper permissions
echo -e "\n${YELLOW}Setting directory permissions...${NC}"
sudo chown -R $(id -u):$(id -g) .
sudo chown -R 999:999 mariadb/data 2>/dev/null || true
echo -e "${GREEN}✓ Permissions set${NC}"

# Summary
echo -e "\n${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Setup Complete!                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"

echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Copy your PHP application to: ${YELLOW}./php/app/${NC}"
echo -e "2. Export your database to: ${YELLOW}./mariadb/init/01-database.sql${NC}"
echo -e "3. Update database config in your PHP app to use host: ${YELLOW}mariadb${NC}"
echo -e "4. Deploy: ${YELLOW}docker-compose up -d${NC}"
echo -e "5. Access your app: ${YELLOW}http://localhost:${APP_PORT:-8081}${NC}"

echo -e "\n${BLUE}Useful commands:${NC}"
echo -e "  View logs:     ${YELLOW}docker-compose logs -f${NC}"
echo -e "  Stop:          ${YELLOW}docker-compose down${NC}"
echo -e "  Backup:        ${YELLOW}./backup.sh${NC}"

echo -e "\n${GREEN}Happy containerizing! 🐳${NC}"