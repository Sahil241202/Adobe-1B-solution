# Docker Deployment Guide
## Advanced Document Section Selection System

This guide provides complete instructions for running the Advanced Document Section Selection System in Docker containers.

## 🐳 Quick Start

### Prerequisites
- Docker Desktop installed and running
- At least 4GB RAM available for the container
- PDF documents ready for processing

### 1. Build and Run with Docker Compose (Recommended)

```bash
# Clone or download the project
cd adobe_1b_advanced_solution_fourth_version

# Build and start the container
docker-compose up --build

# Access the container
docker-compose exec document-processor bash
```

### 2. Alternative: Direct Docker Commands

```bash
# Build the image
docker build -t advanced-document-processor .

# Run the container
docker run -it --rm \
  -v $(pwd)/docs:/app/docs \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/cache:/app/cache \
  -v $(pwd)/config.json:/app/config.json \
  --name document-processor \
  advanced-document-processor
```

## 📁 Directory Structure in Container

```
/app/
├── src/                     # Application source code
├── models/                  # BGE embedding model (auto-downloaded)
│   └── bge-small-en-v1.5/   # Downloaded automatically
├── docs/                    # Your PDF documents (mounted)
├── outputs/                 # Processing results (mounted)
├── cache/                   # Performance cache (mounted)
├── config.json             # Configuration file (mounted)
├── requirements.txt        # Python dependencies
└── run_pipeline.py         # Main execution script
```

## 🚀 Usage Instructions

### Step 1: Add Your Documents
```bash
# Copy PDFs to the docs folder (on host machine)
cp your-documents/*.pdf docs/

# Or inside the container
docker cp document.pdf document-processor:/app/docs/
```

### Step 2: Configure Processing
Edit `config.json` on your host machine:
```json
{
  "persona": "Your Professional Role",
  "job": "Describe your specific requirements",
  "docs_folder": "docs",
  "top_k": 5,
  "max_per_doc": 2,
  "output_dir": "outputs"
}
```

### Step 3: Run Processing
```bash
# Inside the container
python run_pipeline.py

# Or from host (if container is running)
docker-compose exec document-processor python run_pipeline.py
```

### Step 4: Get Results
Results appear in the `outputs/` folder on your host machine as timestamped JSON files.

## 🔧 Container Management

### Start/Stop Services
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f document-processor
```

### Access Container Shell
```bash
# Interactive shell
docker-compose exec document-processor bash

# Run single command
docker-compose exec document-processor python --version
```

### Check System Status
```bash
# Inside container
python -c "from src.embedder import PersonaEmbedder; print('✅ System ready')"

# Check model
ls -la models/bge-small-en-v1.5/

# Check documents
ls -la docs/

# Check outputs
ls -la outputs/
```

## 📊 Performance and Monitoring

### Resource Usage
```bash
# Monitor container resources
docker stats document-processor

# Check container logs
docker logs document-processor

# Health check status
docker inspect --format='{{.State.Health.Status}}' document-processor
```

### Troubleshooting
```bash
# If model download fails, retry inside container:
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('BAAI/bge-small-en-v1.5').save('models/bge-small-en-v1.5')"

# Clear cache if needed
rm -rf cache/*

# Check Python path
python -c "import sys; print('\n'.join(sys.path))"
```

## 🔄 Data Persistence

### Mounted Volumes
- `./docs` → `/app/docs` - Your PDF documents
- `./outputs` → `/app/outputs` - Processing results
- `./cache` → `/app/cache` - Performance cache
- `./config.json` → `/app/config.json` - Configuration

### Backup Important Data
```bash
# Backup outputs
tar -czf outputs-backup-$(date +%Y%m%d).tar.gz outputs/

# Backup cache (optional, can be regenerated)
tar -czf cache-backup-$(date +%Y%m%d).tar.gz cache/
```

## 🌐 Advanced Usage

### Custom Configuration
```bash
# Use different config file
docker run -it --rm \
  -v $(pwd)/docs:/app/docs \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/my-config.json:/app/config.json \
  advanced-document-processor python run_pipeline.py
```

### Batch Processing Multiple Configs
```bash
# Process with different personas
for config in config-*.json; do
  docker run --rm \
    -v $(pwd)/docs:/app/docs \
    -v $(pwd)/outputs:/app/outputs \
    -v $(pwd)/$config:/app/config.json \
    advanced-document-processor python run_pipeline.py
done
```

### Port Forwarding (Future Web Interface)
```yaml
# In docker-compose.yml
ports:
  - "8000:8000"  # For future web interface
```

## 🛠️ Development Mode

### Live Code Development
```bash
# Mount source code for development
docker run -it --rm \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/docs:/app/docs \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/run_pipeline.py:/app/run_pipeline.py \
  advanced-document-processor bash
```

### Debugging
```bash
# Enable debug logging
docker-compose exec document-processor bash -c "
export PYTHONPATH=/app
python -c 'import logging; logging.basicConfig(level=logging.DEBUG)'
python run_pipeline.py
"
```

## 📋 Environment Variables

Available environment variables:
- `PYTHONPATH=/app` - Python module path
- `PYTHONUNBUFFERED=1` - Unbuffered Python output
- `MODEL_PATH=/app/models/bge-small-en-v1.5` - Model location

## 🔒 Security Considerations

- Container runs as root (consider adding non-root user for production)
- Mounted volumes have read/write access
- No sensitive data should be in the container image
- Use specific version tags for production deployments

## 📈 Scaling and Production

### Resource Recommendations
- **Minimum**: 2 CPU cores, 4GB RAM
- **Recommended**: 4 CPU cores, 8GB RAM
- **Storage**: 1GB for model + document storage

### Production Deployment
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  document-processor:
    image: advanced-document-processor:4.0
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 8G
          cpus: '4.0'
    restart: always
```

## 🆘 Support

### Common Issues
1. **Model download fails**: Check internet connection, retry manually
2. **Permission errors**: Ensure Docker has access to mounted directories
3. **Out of memory**: Increase Docker memory limit or reduce `top_k`
4. **No documents processed**: Check PDF files are in `docs/` folder

### Getting Help
```bash
# System information
docker-compose exec document-processor python -c "
import sys, torch
print(f'Python: {sys.version}')
print(f'PyTorch: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
"

# Application status
docker-compose exec document-processor python -c "
from src.embedder import PersonaEmbedder
embedder = PersonaEmbedder('models/bge-small-en-v1.5')
print('✅ Application ready')
"
```

---

**Container Status**: Production Ready ✅  
**Model**: BGE-small-en-v1.5 (Auto-downloaded)  
**Architecture**: CPU-optimized with Docker containerization  
**Last Updated**: July 27, 2025
