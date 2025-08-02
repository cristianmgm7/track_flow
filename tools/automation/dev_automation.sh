#!/bin/bash

# TrackFlow Development Automation Script
# Automates common repetitive development tasks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the project root
check_project_root() {
    if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]] || [[ ! -d "$PROJECT_ROOT/lib" ]]; then
        log_error "Must run from TrackFlow project root directory"
        exit 1
    fi
}

# Full development setup
dev_setup() {
    log_info "Setting up development environment..."
    
    # Clean previous builds
    log_info "Cleaning previous builds..."
    flutter clean
    
    # Get dependencies
    log_info "Getting dependencies..."
    flutter pub get
    
    # Run code generation
    log_info "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Check environment
    log_info "Checking Flutter environment..."
    flutter doctor
    
    log_success "Development setup complete!"
}

# Quick code generation (most common task)
code_gen() {
    log_info "Running code generation..."
    cd "$PROJECT_ROOT"
    flutter packages pub run build_runner build --delete-conflicting-outputs
    log_success "Code generation complete!"
}

# Clean code generation
clean_gen() {
    log_info "Cleaning and regenerating code..."
    cd "$PROJECT_ROOT"
    flutter packages pub run build_runner clean
    flutter packages pub run build_runner build --delete-conflicting-outputs
    log_success "Clean code generation complete!"
}

# Run tests with different options
run_tests() {
    local test_type=${1:-"all"}
    cd "$PROJECT_ROOT"
    
    case $test_type in
        "unit")
            log_info "Running unit tests..."
            flutter test --exclude-tags=integration
            ;;
        "integration")
            log_info "Running integration tests..."
            flutter test integration_test/
            ;;
        "watch")
            log_info "Running tests in watch mode..."
            flutter test --watch
            ;;
        "coverage")
            log_info "Running tests with coverage..."
            flutter test --coverage
            log_info "Coverage report generated in coverage/lcov.info"
            ;;
        *)
            log_info "Running all tests..."
            flutter test
            ;;
    esac
    log_success "Tests completed!"
}

# Development server with flavor support
dev_server() {
    local flavor=${1:-"development"}
    local device=${2:-""}
    
    log_info "Starting development server with flavor: $flavor"
    
    cd "$PROJECT_ROOT"
    
    if [[ -n "$device" ]]; then
        flutter run --flavor "$flavor" -t "lib/main_$flavor.dart" -d "$device"
    else
        flutter run --flavor "$flavor" -t "lib/main_$flavor.dart"
    fi
}

# Build with flavor support
build_app() {
    local flavor=${1:-"development"}
    local platform=${2:-"android"}
    local mode=${3:-"debug"}
    
    log_info "Building app - Flavor: $flavor, Platform: $platform, Mode: $mode"
    
    cd "$PROJECT_ROOT"
    
    case $platform in
        "android")
            if [[ "$mode" == "release" ]]; then
                flutter build apk --flavor "$flavor" -t "lib/main_$flavor.dart" --release
            else
                flutter build apk --flavor "$flavor" -t "lib/main_$flavor.dart" --debug
            fi
            ;;
        "ios")
            if [[ "$mode" == "release" ]]; then
                flutter build ipa --flavor "$flavor" -t "lib/main_$flavor.dart" --release
            else
                flutter build ipa --flavor "$flavor" -t "lib/main_$flavor.dart" --debug
            fi
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
    
    log_success "Build completed!"
}

# Fix common development issues
fix_issues() {
    log_info "Running common development fixes..."
    
    # Fix Google Sign-In issues
    if [[ -f "$SCRIPT_DIR/fix_google_signin.sh" ]]; then
        log_info "Fixing Google Sign-In configuration..."
        bash "$SCRIPT_DIR/fix_google_signin.sh"
    fi
    
    # Fix emulator network issues
    if [[ -f "$SCRIPT_DIR/fix_emulator_network.sh" ]]; then
        log_info "Fixing emulator network configuration..."
        bash "$SCRIPT_DIR/fix_emulator_network.sh"
    fi
    
    # Clear Flutter cache
    log_info "Clearing Flutter cache..."
    flutter clean
    flutter pub get
    
    # Regenerate code
    log_info "Regenerating code..."
    flutter packages pub run build_runner clean
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    log_success "Common fixes applied!"
}

# Lint and analyze code
lint_code() {
    log_info "Running code analysis..."
    
    cd "$PROJECT_ROOT"
    
    # Run Flutter analyze
    log_info "Running flutter analyze..."
    flutter analyze
    
    # Check for formatting issues
    log_info "Checking code formatting..."
    dart format --set-exit-if-changed lib/ test/
    
    log_success "Code analysis complete!"
}

# Format code
format_code() {
    log_info "Formatting code..."
    
    cd "$PROJECT_ROOT"
    dart format lib/ test/
    
    log_success "Code formatting complete!"
}

# Database operations
db_operations() {
    local operation=${1:-"status"}
    
    case $operation in
        "reset")
            log_warning "Resetting local database..."
            # Clear Isar database files
            find . -name "*.isar*" -delete 2>/dev/null || true
            log_success "Database reset complete!"
            ;;
        "inspect")
            log_info "Database files:"
            find . -name "*.isar*" -type f 2>/dev/null || echo "No database files found"
            ;;
        *)
            log_info "Available database operations: reset, inspect"
            ;;
    esac
}

# Show help
show_help() {
    echo "TrackFlow Development Automation Script"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  setup                    - Full development environment setup"
    echo "  gen                      - Run code generation"
    echo "  clean-gen                - Clean and regenerate code"
    echo "  test [unit|integration|watch|coverage] - Run tests"
    echo "  dev [flavor] [device]    - Start development server"
    echo "  build [flavor] [platform] [mode] - Build app"
    echo "  fix                      - Fix common development issues"
    echo "  lint                     - Run code analysis"
    echo "  format                   - Format code"
    echo "  db [reset|inspect]       - Database operations"
    echo "  help                     - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 setup                 # Full setup"
    echo "  $0 gen                   # Quick code generation"
    echo "  $0 test unit             # Run unit tests"
    echo "  $0 dev staging           # Run staging flavor"
    echo "  $0 build production android release"
    echo ""
}

# Main command dispatcher
main() {
    check_project_root
    
    case ${1:-"help"} in
        "setup")
            dev_setup
            ;;
        "gen")
            code_gen
            ;;
        "clean-gen")
            clean_gen
            ;;
        "test")
            run_tests "$2"
            ;;
        "dev")
            dev_server "$2" "$3"
            ;;
        "build")
            build_app "$2" "$3" "$4"
            ;;
        "fix")
            fix_issues
            ;;
        "lint")
            lint_code
            ;;
        "format")
            format_code
            ;;
        "db")
            db_operations "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"