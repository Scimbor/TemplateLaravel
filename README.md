# TemplateLaravel - Docker

- PHP 8.4
- Docker Compose 3.8
- Laravel 12.0
- NodeJS 23.x
- Composer 2.8.4
- Vite 6.0.5

## Technology Stack

**Backend:**
- PHP 8.4 (with latest extensions)
- Laravel 12.0 (latest framework version)
- Composer 2.8.4

**Frontend:**
- Node.js 23.x
- Vite 6.0.5
- Laravel Vite Plugin 1.1.0

**Database:**
- SQLite (default)
- MySQL/PostgreSQL support

**Server:**
- Nginx (lightweight)
- PHP-FPM 8.4
- SSL (self-signed)

## Usage Instructions

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd TemplateLaravel
   ```

2. **Build Docker image**
   ```bash
   docker build -t laravel_image:v7 .
   ```

3. **Start container**
   ```bash
   docker-compose up -d
   ```

4. **Open in browser**
   - HTTP: `http://localhost/`
   - HTTPS: `https://localhost/`

## Automatic Features

On first run, the container automatically:
- Creates a new Laravel 12 project (if it doesn't exist)
- Installs all PHP dependencies (composer install)
- Installs all JS dependencies (npm install)
- Generates application key (APP_KEY)
- Creates .env file from .env.example
- Runs database migrations
- Optimizes the application

## Project Structure

```
├── app/              # Laravel 12 application
├── nginx/            # Nginx configuration
├── php/              # PHP-FPM configuration
├── Dockerfile        # Image definition
├── docker-compose.yaml
└── start.sh          # Container startup script
```

## Ports

- **80** - HTTP
- **443** - HTTPS
- **9000** - PHP-FPM

## Development

The `app/` folder is mounted as a volume, so code changes are immediately visible in the container.

## Optimizations

### Docker Infrastructure
- **Minimal Docker image** - removed unnecessary tools (nano, mc, supervisor, logrotate, cron, rsync, exim4)
- **.dockerignore** - excludes node_modules, vendor, build artifacts for faster builds
- **Line endings** - .gitattributes ensures proper LF line endings for shell scripts
- **SSL certificates** - auto-generated self-signed certificates with proper config

### Startup Script
- **Error handling** - `set -e` stops on first error
- **Silent SSL generation** - errors suppressed with `2>/dev/null`
- **Asset building** - automatic `npm run build` for Vite
- **Optimized permissions** - efficient directory creation and chmod

### Configuration
- **PHP 8.4** - consistent across all configs (Nginx, PHP-FPM, Docker)
- **OPcache enabled** - production-ready PHP configuration
- **Proper FastCGI** - correct socket path in Nginx