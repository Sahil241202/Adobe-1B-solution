# Multi-stage build for optimized Advanced Document Section Selection System
# Stage 1: Build stage for dependencies and model download
FROM python:3.11-slim as builder

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for building
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy and install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Download BGE model in build stage
RUN python -c "\
import os; \
from sentence_transformers import SentenceTransformer; \
print('Downloading BGE-small-en-v1.5 model...'); \
model = SentenceTransformer('BAAI/bge-small-en-v1.5'); \
model.save('/tmp/models/bge-small-en-v1.5'); \
print('Model downloaded successfully')"

# Stage 2: Production stage
FROM python:3.11-slim as production

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser -d /app appuser

# Set working directory
WORKDIR /app

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Create necessary directories with proper permissions
RUN mkdir -p /app/models /app/docs /app/outputs /app/cache /app/src && \
    chown -R appuser:appuser /app

# Copy model from builder stage
COPY --from=builder /tmp/models/bge-small-en-v1.5 /app/models/bge-small-en-v1.5

# Copy application source code
COPY --chown=appuser:appuser src/ /app/src/
COPY --chown=appuser:appuser run_pipeline.py /app/
COPY config.json /app/config.json

# Create startup script with proper permissions
RUN echo '#!/bin/bash\n\
echo "=== Advanced Document Section Selection System ==="\n\
echo "Container started successfully!"\n\
echo ""\n\
echo "Available commands:"\n\
echo "  python run_pipeline.py          - Run the document processing pipeline"\n\
echo "  python -c \"import sys; print(sys.path)\" - Check Python path"\n\
echo "  ls -la docs/                    - Check documents directory"\n\
echo "  ls -la outputs/                 - Check outputs directory"\n\
echo "  cat config.json                 - View current configuration"\n\
echo ""\n\
echo "Directories:"\n\
echo "  /app/docs/     - Place your PDF documents here"\n\
echo "  /app/outputs/  - Processing results will be saved here"\n\
echo "  /app/models/   - BGE embedding model location"\n\
echo "  /app/cache/    - Processing cache for performance"\n\
echo ""\n\
echo "Model status:"\n\
if [ -d "/app/models/bge-small-en-v1.5" ]; then\n\
    echo "  ✅ BGE model loaded successfully"\n\
else\n\
    echo "  ❌ BGE model not found"\n\
    exit 1\n\
fi\n\
echo ""\n\
echo "Ready to process documents! 🚀"\n\
exec "$@"' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh && \
    chown appuser:appuser /app/entrypoint.sh

# Set proper permissions for data directories
RUN chmod -R 755 /app && \
    chmod -R 777 /app/outputs /app/cache /app/docs

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import sys; sys.path.append('/app'); from src.embedder import PersonaEmbedder; print('System healthy')" || exit 1

# Expose port for potential future web interface
EXPOSE 8000

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD ["bash"]

# Metadata
LABEL maintainer="Advanced Document Processing System"
LABEL version="4.0"
LABEL description="AI-powered document section selection with persona-aware content extraction"
LABEL gpu_support="false"
LABEL model="BGE-small-en-v1.5"
