# Docker User Guide - Advanced Document Processing System

This guide provides comprehensive instructions for building, running, and managing the Advanced Document Processing System using Docker.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Manual Setup](#manual-setup)
4. [Usage](#usage)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Configuration](#advanced-configuration)
7. [Security Considerations](#security-considerations)

## Prerequisites

### System Requirements

- **Operating System**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 18.04+)
- **Docker**: Docker Desktop 4.0+ or Docker Engine 20.10+
- **Docker Compose**: Included with Docker Desktop or Docker Compose 2.0+
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Storage**: At least 5GB free space for the Docker image and models
- **CPU**: Multi-core processor recommended

### Installing Docker

#### Windows
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Install and start Docker Desktop
3. Enable WSL 2 backend (recommended)

#### macOS
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Install and start Docker Desktop

#### Linux (Ubuntu)
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

## Quick Start

### Option 1: Automated Setup (Recommended)

#### Windows
```cmd
# Run the automated setup script
build-docker.bat
```

#### Linux/macOS
```bash
# Make the script executable
chmod +x build-docker.sh

# Run the automated setup script
./build-docker.sh
```

The automated script will:
- Check Docker installation
- Create necessary directories
- Build the Docker image
- Start the container
- Provide usage instructions

### Option 2: Manual Setup

If you prefer manual control or the automated script fails:

```bash
# 1. Create necessary directories
mkdir -p docs outputs cache

# 2. Build the Docker image
docker compose build

# 3. Start the container
docker compose up -d

# 4. Check container status
docker compose ps
```

## Manual Setup

### Step 1: Clone and Navigate

```bash
# Navigate to the project directory
cd adobe_1b_advanced_solution_fourth_version
```

### Step 2: Prepare Directories

```bash
# Create necessary directories
mkdir -p docs outputs cache

# Verify directory structure
ls -la
```

### Step 3: Build Docker Image

```bash
# Build the image (this may take 10-15 minutes on first run)
docker compose build --no-cache

# Verify the image was created
docker images | grep document-processor
```

### Step 4: Start Container

```bash
# Start the container in detached mode
docker compose up -d

# Check container status
docker compose ps

# View logs
docker compose logs -f document-processor
```

## Usage

### Basic Operations

#### 1. Access Container Shell
```bash
# Access the container's bash shell
docker compose exec document-processor bash
```

#### 2. Process Documents
```bash
# Run the document processing pipeline
docker compose exec document-processor python run_pipeline.py
```

#### 3. View Results
```bash
# Check the outputs directory
ls -la outputs/
```

#### 4. Monitor Logs
```bash
# View real-time logs
docker compose logs -f document-processor

# View recent logs
docker compose logs --tail=100 document-processor
```

### File Management

#### Adding Documents
1. Place your PDF files in the `docs/` directory
2. The files will be automatically available in the container

#### Accessing Results
- Processed results are saved in the `outputs/` directory
- Cache files are stored in the `cache/` directory
- Both directories are mounted as volumes and persist between container restarts

### Configuration

#### Modify Configuration
1. Edit `config.json` in your host system
2. The changes are immediately available in the container
3. Restart the container if needed: `docker compose restart`

#### Environment Variables
You can override configuration by setting environment variables in `docker-compose.yml`:

```yaml
environment:
  - PYTHONPATH=/app
  - PYTHONUNBUFFERED=1
  - PYTHONDONTWRITEBYTECODE=1
  # Add custom environment variables here
```

## Troubleshooting

### Common Issues

#### 1. Docker Not Running
**Error**: `Cannot connect to the Docker daemon`

**Solution**:
- Start Docker Desktop (Windows/macOS)
- Start Docker service (Linux): `sudo systemctl start docker`
- Verify Docker is running: `docker info`

#### 2. Port Already in Use
**Error**: `Port 8000 is already in use`

**Solution**:
- Change the port in `docker-compose.yml`:
  ```yaml
  ports:
    - "8001:8000"  # Use port 8001 instead
  ```

#### 3. Insufficient Memory
**Error**: `Container killed due to memory limit`

**Solution**:
- Increase memory limits in `docker-compose.yml`:
  ```yaml
  deploy:
    resources:
      limits:
        memory: 8G  # Increase from 4G to 8G
  ```

#### 4. Model Download Issues
**Error**: `Failed to download BGE model`

**Solution**:
- Check internet connection
- Retry the build: `docker compose build --no-cache`
- Use a VPN if behind a corporate firewall

#### 5. Permission Issues
**Error**: `Permission denied` when accessing mounted volumes

**Solution**:
- On Linux/macOS, ensure proper file permissions:
  ```bash
  chmod -R 755 docs outputs cache
  ```
- On Windows, ensure Docker has access to the project directory

### Debugging Commands

#### Check Container Status
```bash
# View running containers
docker compose ps

# View container details
docker compose exec document-processor ps aux

# Check disk usage
docker compose exec document-processor df -h
```

#### View Logs
```bash
# View all logs
docker compose logs document-processor

# Follow logs in real-time
docker compose logs -f document-processor

# View logs with timestamps
docker compose logs -t document-processor
```

#### Access Container
```bash
# Access bash shell
docker compose exec document-processor bash

# Run Python interactively
docker compose exec document-processor python

# Check Python path
docker compose exec document-processor python -c "import sys; print(sys.path)"
```

### Reset and Cleanup

#### Complete Reset
```bash
# Stop and remove containers
docker compose down

# Remove volumes (WARNING: This deletes all data)
docker compose down -v

# Remove images
docker rmi $(docker images -q document-processor)

# Clean up Docker system
docker system prune -f
```

#### Partial Reset
```bash
# Restart container
docker compose restart

# Rebuild without cache
docker compose build --no-cache

# Remove only containers
docker compose down
```

## Advanced Configuration

### Resource Optimization

#### Memory and CPU Limits
Modify `docker-compose.yml` to adjust resource limits:

```yaml
deploy:
  resources:
    limits:
      memory: 8G      # Increase for large documents
      cpus: '4.0'     # Increase for faster processing
    reservations:
      memory: 4G      # Minimum memory guarantee
      cpus: '2.0'     # Minimum CPU guarantee
```

#### Storage Optimization
```yaml
volumes:
  - ./docs:/app/docs:rw
  - ./outputs:/app/outputs:rw
  - ./cache:/app/cache:rw
  # Add additional volumes as needed
```

### Network Configuration

#### Custom Network
```yaml
networks:
  document-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

#### Port Configuration
```yaml
ports:
  - "8000:8000"    # HTTP port
  - "8001:8001"    # Additional port if needed
```

### Security Enhancements

#### Read-Only Root Filesystem
```yaml
read_only: true
tmpfs:
  - /tmp:noexec,nosuid,size=100m
```

#### Security Options
```yaml
security_opt:
  - no-new-privileges:true
  - seccomp:unconfined  # Only if needed
```

## Security Considerations

### Best Practices

1. **Non-Root User**: The container runs as a non-root user (`appuser`)
2. **Read-Only Config**: Configuration file is mounted as read-only
3. **Resource Limits**: Memory and CPU limits prevent resource exhaustion
4. **Network Isolation**: Container runs in an isolated network
5. **No Privilege Escalation**: Security options prevent privilege escalation

### Security Recommendations

1. **Regular Updates**: Keep Docker and base images updated
2. **Image Scanning**: Use Docker Scout or similar tools to scan for vulnerabilities
3. **Secret Management**: Use Docker secrets for sensitive configuration
4. **Network Security**: Restrict network access when possible
5. **Audit Logs**: Monitor container logs for suspicious activity

### Production Deployment

For production environments, consider:

1. **Load Balancer**: Use a reverse proxy (nginx, traefik)
2. **SSL/TLS**: Enable HTTPS for web interfaces
3. **Monitoring**: Implement health checks and monitoring
4. **Backup**: Regular backup of data volumes
5. **Updates**: Automated security updates

## Support

### Getting Help

1. **Check Logs**: Always check container logs first
2. **Documentation**: Review this guide and project README
3. **Issues**: Check for known issues in the project repository
4. **Community**: Seek help from Docker and project communities

### Useful Commands Reference

```bash
# Container management
docker compose up -d          # Start container
docker compose down           # Stop container
docker compose restart        # Restart container
docker compose ps             # Show status

# Logs and debugging
docker compose logs -f        # Follow logs
docker compose exec bash      # Access shell
docker compose exec python    # Access Python

# Build and rebuild
docker compose build          # Build image
docker compose build --no-cache # Rebuild without cache

# Cleanup
docker system prune -f        # Clean up system
docker volume prune           # Clean up volumes
docker image prune            # Clean up images
```

---

**Note**: This Docker setup is optimized for development and testing. For production deployment, additional security and performance considerations should be implemented.
