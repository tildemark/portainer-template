# Contributing to Portainer Template

First off, thank you for considering contributing to Portainer Template! It's people like you that make this project better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please be respectful, inclusive, and considerate in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Environment details** (OS, Docker version, etc.)
- **Logs and error messages**
- **Screenshots** if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** - why is this enhancement useful?
- **Possible implementation** - if you have ideas
- **Alternatives considered**

### Pull Requests

We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`
2. If you've added code, add tests if applicable
3. Ensure your code follows the style guidelines
4. Update documentation as needed
5. Write a clear commit message
6. Submit your pull request

## Getting Started

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/portainer-template.git
   cd portainer-template
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Test Your Changes**
   ```bash
   ./setup.sh
   docker-compose up -d
   # Test your changes
   docker-compose down
   ```

### Branch Naming Convention

- `feature/` - for new features
- `fix/` - for bug fixes
- `docs/` - for documentation changes
- `refactor/` - for code refactoring
- `test/` - for adding/updating tests

## Pull Request Process

1. **Update Documentation**
   - Update README.md if you change functionality
   - Update QUICK_REFERENCE.md for new commands
   - Add comments to complex code

2. **Test Thoroughly**
   - Test on clean installation
   - Test with different configurations
   - Verify existing functionality still works

3. **Write Clear Commit Messages**
   ```
   feat: add support for PostgreSQL
   
   - Add PostgreSQL docker service
   - Update documentation
   - Add migration guide from MariaDB
   ```

4. **Keep PRs Focused**
   - One feature/fix per PR
   - Small, reviewable changes
   - Split large changes into multiple PRs

5. **Request Review**
   - Assign reviewers if you know who to ask
   - Be responsive to feedback
   - Make requested changes promptly

## Style Guidelines

### Shell Scripts

```bash
#!/bin/bash
#
# Script description
# Usage: ./script.sh [args]
#

# Use meaningful variable names
DATABASE_NAME="myapp"

# Add comments for complex logic
# Calculate backup retention period
RETENTION_DAYS=7

# Use functions for reusability
function backup_database() {
    local db_name=$1
    # Function logic here
}

# Error handling
if [ ! -f ".env" ]; then
    echo "Error: .env file not found"
    exit 1
fi
```

### Docker Compose

```yaml
version: '3.8'

services:
  # Clear service names
  web:
    # Use specific versions
    image: nginx:1.21-alpine
    # Descriptive container names
    container_name: myapp-web
    # Always specify restart policy
    restart: unless-stopped
    # Group related configs
    environment:
      - KEY=value
    # Use named volumes
    volumes:
      - ./config:/etc/nginx
    # Explicit port mapping
    ports:
      - "8081:80"
```

### Documentation

- Use clear, concise language
- Include code examples
- Add screenshots for UI steps
- Keep formatting consistent
- Update table of contents
- Use proper Markdown syntax

### Commit Messages

Follow conventional commits:

- `feat:` - new feature
- `fix:` - bug fix
- `docs:` - documentation changes
- `style:` - formatting, missing semicolons, etc.
- `refactor:` - code restructuring
- `test:` - adding tests
- `chore:` - maintenance tasks

Example:
```
feat: add Redis support

- Add Redis service to docker-compose
- Update PHP Dockerfile with Redis extension
- Add Redis configuration documentation
- Update environment variables
```

## Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] Fresh installation works
- [ ] Existing setup can update
- [ ] All containers start successfully
- [ ] Application is accessible
- [ ] Database connection works
- [ ] Logs show no errors
- [ ] Backup script works
- [ ] Documentation is accurate

### Test Different Scenarios

```bash
# Test clean install
./setup.sh
docker-compose up -d

# Test with different ports
# Edit .env, change APP_PORT
docker-compose down
docker-compose up -d

# Test backup and restore
./backup.sh
# Restore and verify data
```

## Specific Contribution Areas

### Adding New Services

If adding a new service (Redis, Memcached, etc.):

1. Add service to docker-compose.yml
2. Update documentation
3. Add to setup.sh if configuration needed
4. Update QUICK_REFERENCE.md with commands
5. Test integration with existing services

### Improving Scripts

When improving setup.sh, backup.sh, etc.:

1. Maintain backward compatibility
2. Add error handling
3. Provide clear output messages
4. Test on different systems
5. Update documentation

### Documentation Improvements

- Fix typos and grammar
- Add missing information
- Improve clarity
- Add more examples
- Update outdated info

## Questions?

Don't hesitate to ask questions:

- Open an issue with the `question` label
- Reach out to maintainers
- Check existing issues for similar questions

## Recognition

Contributors will be:

- Listed in README.md
- Mentioned in release notes
- Credited in commit history

Thank you for contributing to Portainer Template! 🎉