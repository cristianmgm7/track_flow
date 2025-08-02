#!/bin/bash

# TrackFlow Project Health Check Script
# Monitors project health and identifies potential issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
ISSUES_COUNT=0
WARNINGS_COUNT=0

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS_COUNT++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ISSUES_COUNT++))
}

log_section() {
    echo -e "\n${PURPLE}🔍 $1${NC}"
    echo "----------------------------------------"
}

# Check Flutter environment
check_flutter_env() {
    log_section "Flutter Environment"
    
    # Check Flutter installation
    if command -v flutter &> /dev/null; then
        local flutter_version=$(flutter --version | head -n 1)
        log_success "Flutter installed: $flutter_version"
    else
        log_error "Flutter not installed or not in PATH"
        return
    fi
    
    # Check Flutter doctor
    log_info "Running Flutter doctor..."
    if flutter doctor --android-licenses > /dev/null 2>&1; then
        log_success "Android licenses accepted"
    else
        log_warning "Android licenses may need acceptance"
    fi
    
    # Check for Flutter doctor issues
    local doctor_output=$(flutter doctor 2>&1)
    local issues=$(echo "$doctor_output" | grep -c "✗" || true)
    local warnings=$(echo "$doctor_output" | grep -c "!" || true)
    
    if [[ $issues -gt 0 ]]; then
        log_error "Flutter doctor found $issues issue(s)"
    elif [[ $warnings -gt 0 ]]; then
        log_warning "Flutter doctor found $warnings warning(s)"
    else
        log_success "Flutter doctor checks passed"
    fi
}

# Check project dependencies
check_dependencies() {
    log_section "Dependencies"
    
    # Check pubspec.yaml exists
    if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
        log_error "pubspec.yaml not found"
        return
    fi
    
    # Check if dependencies are fetched
    if [[ ! -d "$PROJECT_ROOT/.dart_tool" ]]; then
        log_warning "Dependencies not fetched. Run 'flutter pub get'"
    else
        log_success "Dependencies appear to be fetched"
    fi
    
    # Check for outdated dependencies
    log_info "Checking for outdated dependencies..."
    local outdated_output=$(flutter pub outdated 2>&1 || true)
    local outdated_count=$(echo "$outdated_output" | grep -c "has newer" || true)
    
    if [[ $outdated_count -gt 0 ]]; then
        log_warning "$outdated_count outdated dependencies found"
    else
        log_success "Dependencies are up to date"
    fi
    
    # Check for dependency conflicts
    if echo "$outdated_output" | grep -q "version solving failed"; then
        log_error "Dependency conflicts detected"
    fi
}

# Check code generation
check_code_generation() {
    log_section "Code Generation"
    
    # Check if generated files exist
    local generated_files=(
        "lib/core/di/injection.config.dart"
        "lib/features/projects/data/models/project_document.g.dart"
    )
    
    local missing_count=0
    for file in "${generated_files[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            ((missing_count++))
        fi
    done
    
    if [[ $missing_count -gt 0 ]]; then
        log_warning "$missing_count generated files missing. Run code generation."
    else
        log_success "Generated files present"
    fi
    
    # Check build.yaml configuration
    if [[ ! -f "$PROJECT_ROOT/build.yaml" ]]; then
        log_error "build.yaml configuration missing"
    else
        log_success "build.yaml configuration found"
    fi
}

# Check project structure
check_project_structure() {
    log_section "Project Structure"
    
    # Check core directories
    local core_dirs=(
        "lib/core/di"
        "lib/core/domain"
        "lib/core/error"
        "lib/core/theme"
        "lib/features"
        "test"
    )
    
    for dir in "${core_dirs[@]}"; do
        if [[ ! -d "$PROJECT_ROOT/$dir" ]]; then
            log_error "Missing core directory: $dir"
        fi
    done
    
    # Check feature structure consistency
    local feature_count=$(find "$PROJECT_ROOT/lib/features" -maxdepth 1 -type d | wc -l)
    log_info "Found $((feature_count - 1)) feature modules"
    
    # Check for proper clean architecture structure
    local features_with_domain=$(find "$PROJECT_ROOT/lib/features" -name "domain" -type d | wc -l)
    local features_with_data=$(find "$PROJECT_ROOT/lib/features" -name "data" -type d | wc -l)
    local features_with_presentation=$(find "$PROJECT_ROOT/lib/features" -name "presentation" -type d | wc -l)
    
    if [[ $features_with_domain -gt 0 && $features_with_data -gt 0 && $features_with_presentation -gt 0 ]]; then
        log_success "Clean Architecture structure maintained"
    else
        log_warning "Some features may not follow Clean Architecture structure"
    fi
}

# Check code quality
check_code_quality() {
    log_section "Code Quality"
    
    # Run Flutter analyze
    log_info "Running static analysis..."
    local analyze_output=$(flutter analyze 2>&1)
    local analyze_exit_code=$?
    
    if [[ $analyze_exit_code -eq 0 ]]; then
        log_success "No static analysis issues found"
    else
        local error_count=$(echo "$analyze_output" | grep -c "error •" || true)
        local warning_count=$(echo "$analyze_output" | grep -c "warning •" || true)
        local info_count=$(echo "$analyze_output" | grep -c "info •" || true)
        
        if [[ $error_count -gt 0 ]]; then
            log_error "$error_count analysis errors found"
        fi
        if [[ $warning_count -gt 0 ]]; then
            log_warning "$warning_count analysis warnings found"
        fi
        if [[ $info_count -gt 0 ]]; then
            log_info "$info_count analysis info messages found"
        fi
    fi
    
    # Check code formatting
    log_info "Checking code formatting..."
    local format_output=$(dart format --set-exit-if-changed lib/ test/ 2>&1 || true)
    if [[ -n "$format_output" ]]; then
        log_warning "Code formatting issues found"
    else
        log_success "Code is properly formatted"
    fi
}

# Check test coverage
check_tests() {
    log_section "Tests"
    
    # Count test files
    local test_count=$(find "$PROJECT_ROOT/test" -name "*_test.dart" | wc -l)
    log_info "Found $test_count test files"
    
    # Check if tests run successfully
    log_info "Running tests..."
    local test_output=$(flutter test --reporter=json 2>&1 || true)
    
    if echo "$test_output" | grep -q '"success":true'; then
        local passed_tests=$(echo "$test_output" | grep -o '"testCount":[0-9]*' | tail -1 | cut -d: -f2)
        log_success "All tests passed ($passed_tests tests)"
    else
        local failed_tests=$(echo "$test_output" | grep -c '"result":"error"' || true)
        if [[ $failed_tests -gt 0 ]]; then
            log_error "$failed_tests test(s) failed"
        else
            log_warning "Could not determine test results"
        fi
    fi
}

# Check Firebase configuration
check_firebase_config() {
    log_section "Firebase Configuration"
    
    # Check Firebase config files
    local firebase_files=(
        "android/app/google-services.json"
        "ios/Runner/GoogleService-Info.plist"
        "firebase.json"
    )
    
    for file in "${firebase_files[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            log_warning "Firebase config file missing: $file"
        fi
    done
    
    # Check if Firebase is properly initialized
    if grep -q "Firebase.initializeApp" "$PROJECT_ROOT/lib/main"*.dart; then
        log_success "Firebase initialization found"
    else
        log_warning "Firebase initialization not found in main files"
    fi
}

# Check platform-specific configurations
check_platform_config() {
    log_section "Platform Configuration"
    
    # Android configuration
    if [[ -f "$PROJECT_ROOT/android/app/build.gradle" ]]; then
        # Check for flavor configurations
        if grep -q "flavorDimensions" "$PROJECT_ROOT/android/app/build.gradle"; then
            log_success "Android flavors configured"
        else
            log_warning "Android flavors not configured"
        fi
        
        # Check minimum SDK version
        local min_sdk=$(grep "minSdkVersion" "$PROJECT_ROOT/android/app/build.gradle" | grep -o '[0-9]*' || echo "unknown")
        log_info "Android minSdkVersion: $min_sdk"
    fi
    
    # iOS configuration
    if [[ -f "$PROJECT_ROOT/ios/Runner/Info.plist" ]]; then
        log_success "iOS Info.plist found"
    else
        log_warning "iOS Info.plist missing"
    fi
}

# Check database files and size
check_database() {
    log_section "Database"
    
    # Check for Isar database files
    local isar_files=$(find "$PROJECT_ROOT" -name "*.isar*" 2>/dev/null || true)
    if [[ -n "$isar_files" ]]; then
        log_info "Local database files found:"
        echo "$isar_files" | while read -r file; do
            if [[ -f "$file" ]]; then
                local size=$(du -h "$file" | cut -f1)
                echo "  - $(basename "$file"): $size"
            fi
        done
    else
        log_info "No local database files found"
    fi
}

# Generate summary report
generate_summary() {
    log_section "Health Check Summary"
    
    echo -e "${CYAN}Project: TrackFlow${NC}"
    echo -e "${CYAN}Checked: $(date)${NC}"
    echo ""
    
    if [[ $ISSUES_COUNT -eq 0 && $WARNINGS_COUNT -eq 0 ]]; then
        echo -e "${GREEN}🎉 Project health is excellent!${NC}"
    elif [[ $ISSUES_COUNT -eq 0 ]]; then
        echo -e "${YELLOW}✨ Project health is good with $WARNINGS_COUNT warning(s)${NC}"
    else
        echo -e "${RED}🚨 Project has $ISSUES_COUNT issue(s) and $WARNINGS_COUNT warning(s)${NC}"
    fi
    
    echo ""
    echo "Next steps:"
    if [[ $ISSUES_COUNT -gt 0 ]]; then
        echo "  1. Address the $ISSUES_COUNT critical issue(s) above"
    fi
    if [[ $WARNINGS_COUNT -gt 0 ]]; then
        echo "  2. Review and resolve $WARNINGS_COUNT warning(s)"
    fi
    echo "  3. Run './scripts/dev_automation.sh fix' to auto-fix common issues"
    echo "  4. Run health check regularly for continuous monitoring"
}

# Main execution
main() {
    echo -e "${PURPLE}🏥 TrackFlow Project Health Check${NC}"
    echo -e "${PURPLE}===================================${NC}"
    
    cd "$PROJECT_ROOT"
    
    check_flutter_env
    check_dependencies
    check_code_generation
    check_project_structure
    check_code_quality
    check_tests
    check_firebase_config
    check_platform_config
    check_database
    
    generate_summary
}

# Run main function
main "$@"