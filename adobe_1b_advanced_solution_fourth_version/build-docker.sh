#!/bin/bash

# Advanced Document Processing System - Docker Build Script
# This script provides an easy way to build and run the Docker container

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is available and running"
}

# Check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    print_success "Docker Compose is available"
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p docs outputs cache
    
    if [ ! -f docs/README.md ]; then
        cat > docs/README.md << EOF
# Documents Directory

Place your PDF documents in this directory for processing.

## Supported Formats
- PDF files (.pdf)

## Usage
1. Copy your PDF files to this directory
2. Run the processing pipeline
3. Check the outputs directory for results
EOF
        print_success "Created docs/README.md"
    fi
    
    print_success "Directories created successfully"
}

# Build the Docker image
build_image() {
    print_status "Building Docker image..."
    
    # Use docker compose if available, otherwise use docker build
    if docker compose version &> /dev/null; then
        docker compose build --no-cache
    else
        docker-compose build --no-cache
    fi
    
    print_success "Docker image built successfully"
}

# Run the container
run_container() {
    print_status "Starting the container..."
    
    if docker compose version &> /dev/null; then
        docker compose up -d
    else
        docker-compose up -d
    fi
    
    print_success "Container started successfully"
}

# Show usage information
show_usage() {
    print_status "Container is ready!"
    echo ""
    echo "Available commands:"
    echo "  docker compose exec document-processor python run_pipeline.py"
    echo "  docker compose logs document-processor"
    echo "  docker compose down"
    echo ""
    echo "Directories:"
    echo "  ./docs/     - Place your PDF documents here"
    echo "  ./outputs/  - Processing results will be saved here"
    echo "  ./cache/    - Processing cache for performance"
    echo ""
    echo "To access the container shell:"
    echo "  docker compose exec document-processor bash"
}

# Main execution
main() {
    echo "=== Advanced Document Processing System - Docker Setup ==="
    echo ""
    
    check_docker
    check_docker_compose
    create_directories
    build_image
    run_container
    show_usage
}

# Handle command line arguments
case "${1:-}" in
    "build")
        check_docker
        check_docker_compose
        build_image
        ;;
    "run")
        check_docker
        check_docker_compose
        run_container
        show_usage
        ;;
    "clean")
        print_status "Cleaning up Docker resources..."
        if docker compose version &> /dev/null; then
            docker compose down --volumes --remove-orphans
        else
            docker-compose down --volumes --remove-orphans
        fi
        docker system prune -f
        print_success "Cleanup completed"
        ;;
    "logs")
        if docker compose version &> /dev/null; then
            docker compose logs -f document-processor
        else
            docker-compose logs -f document-processor
        fi
        ;;
    "shell")
        if docker compose version &> /dev/null; then
            docker compose exec document-processor bash
        else
            docker-compose exec document-processor bash
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  build    - Build the Docker image only"
        echo "  run      - Start the container only"
        echo "  clean    - Clean up Docker resources"
        echo "  logs     - Show container logs"
        echo "  shell    - Access container shell"
        echo "  help     - Show this help message"
        echo ""
        echo "If no command is provided, the script will build and run the container."
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
