# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial repository setup
- Docker Compose configuration for Nginx, PHP-FPM, and MariaDB
- Interactive setup script (setup.sh)
- Automated backup script (backup.sh)
- Comprehensive documentation (README.md)
- Quick reference guide (QUICK_REFERENCE.md)
- Contributing guidelines (CONTRIBUTING.md)
- Repository structure documentation (STRUCTURE.md)
- Environment variable template (.env.example)
- Custom PHP Dockerfile with common extensions
- Nginx configuration with PHP-FPM integration
- MariaDB initialization support
- Health checks for all services
- Portainer integration instructions

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- Proper file permissions for sensitive data
- .gitignore to prevent committing secrets
- Environment variable isolation

---

## [1.0.0] - 2025-01-24

### Added
- Initial release of Portainer Template
- Multi-container PHP application stack
- Support for multiple applications on different ports
- Database migration tools
- Comprehensive troubleshooting guides
- Backup and restore functionality

---

## Template for Future Releases

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature descriptions

### Changed
- Changes in existing functionality

### Deprecated
- Features that will be removed in upcoming releases

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements and patches
```

---

## Version History

- **1.0.0** (2025-01-24) - Initial release
- **Unreleased** - Current development version