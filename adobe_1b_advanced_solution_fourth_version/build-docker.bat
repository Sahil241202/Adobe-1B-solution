@echo off
REM Advanced Document Processing System - Docker Build Script for Windows
REM This script provides an easy way to build and run the Docker container on Windows

setlocal enabledelayedexpansion

REM Colors for output (Windows 10+)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Function to print colored output
:print_status
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM Check if Docker is installed and running
:check_docker
docker --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not installed. Please install Docker Desktop first."
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not running. Please start Docker Desktop first."
    exit /b 1
)

call :print_success "Docker is available and running"
goto :eof

REM Check if Docker Compose is available
:check_docker_compose
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose --version >nul 2>&1
    if errorlevel 1 (
        call :print_error "Docker Compose is not available. Please install Docker Compose."
        exit /b 1
    )
)

call :print_success "Docker Compose is available"
goto :eof

REM Create necessary directories
:create_directories
call :print_status "Creating necessary directories..."

if not exist "docs" mkdir docs
if not exist "outputs" mkdir outputs
if not exist "cache" mkdir cache

if not exist "docs\README.md" (
    echo # Documents Directory > docs\README.md
    echo. >> docs\README.md
    echo Place your PDF documents in this directory for processing. >> docs\README.md
    echo. >> docs\README.md
    echo ## Supported Formats >> docs\README.md
    echo - PDF files (.pdf) >> docs\README.md
    echo. >> docs\README.md
    echo ## Usage >> docs\README.md
    echo 1. Copy your PDF files to this directory >> docs\README.md
    echo 2. Run the processing pipeline >> docs\README.md
    echo 3. Check the outputs directory for results >> docs\README.md
    call :print_success "Created docs\README.md"
)

call :print_success "Directories created successfully"
goto :eof

REM Build the Docker image
:build_image
call :print_status "Building Docker image..."

docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose build --no-cache
) else (
    docker compose build --no-cache
)

if errorlevel 1 (
    call :print_error "Docker build failed"
    exit /b 1
)

call :print_success "Docker image built successfully"
goto :eof

REM Run the container
:run_container
call :print_status "Starting the container..."

docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose up -d
) else (
    docker compose up -d
)

if errorlevel 1 (
    call :print_error "Failed to start container"
    exit /b 1
)

call :print_success "Container started successfully"
goto :eof

REM Show usage information
:show_usage
call :print_status "Container is ready!"
echo.
echo Available commands:
echo   docker compose exec document-processor python run_pipeline.py
echo   docker compose logs document-processor
echo   docker compose down
echo.
echo Directories:
echo   .\docs\     - Place your PDF documents here
echo   .\outputs\  - Processing results will be saved here
echo   .\cache\    - Processing cache for performance
echo.
echo To access the container shell:
echo   docker compose exec document-processor bash
goto :eof

REM Main execution
:main
echo === Advanced Document Processing System - Docker Setup ===
echo.

call :check_docker
if errorlevel 1 exit /b 1

call :check_docker_compose
if errorlevel 1 exit /b 1

call :create_directories
call :build_image
call :run_container
call :show_usage
goto :eof

REM Handle command line arguments
if "%1"=="" goto main
if "%1"=="build" (
    call :check_docker
    if errorlevel 1 exit /b 1
    call :check_docker_compose
    if errorlevel 1 exit /b 1
    call :build_image
    goto :eof
)
if "%1"=="run" (
    call :check_docker
    if errorlevel 1 exit /b 1
    call :check_docker_compose
    if errorlevel 1 exit /b 1
    call :run_container
    call :show_usage
    goto :eof
)
if "%1"=="clean" (
    call :print_status "Cleaning up Docker resources..."
    docker compose version >nul 2>&1
    if errorlevel 1 (
        docker-compose down --volumes --remove-orphans
    ) else (
        docker compose down --volumes --remove-orphans
    )
    docker system prune -f
    call :print_success "Cleanup completed"
    goto :eof
)
if "%1"=="logs" (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        docker-compose logs -f document-processor
    ) else (
        docker compose logs -f document-processor
    )
    goto :eof
)
if "%1"=="shell" (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        docker-compose exec document-processor bash
    ) else (
        docker compose exec document-processor bash
    )
    goto :eof
)
if "%1"=="help" (
    echo Usage: %0 [command]
    echo.
    echo Commands:
    echo   build    - Build the Docker image only
    echo   run      - Start the container only
    echo   clean    - Clean up Docker resources
    echo   logs     - Show container logs
    echo   shell    - Access container shell
    echo   help     - Show this help message
    echo.
    echo If no command is provided, the script will build and run the container.
    goto :eof
)

call :print_error "Unknown command: %1"
echo Use '%0 help' for usage information
exit /b 1
