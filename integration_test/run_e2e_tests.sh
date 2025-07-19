#!/bin/bash

# TrackFlow End-to-End Test Suite
# This script runs all E2E tests to validate user flows and detect errors

set -e  # Exit on any error

echo "🚀 Starting TrackFlow End-to-End Test Suite"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test file
run_test_file() {
    local test_file=$1
    local test_name=$2
    
    echo -e "\n${BLUE}Running: ${test_name}${NC}"
    echo "----------------------------------------"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if flutter test integration_test/$test_file --reporter=expanded; then
        echo -e "${GREEN}✅ ${test_name} PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ ${test_name} FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to run tests with specific device
run_test_on_device() {
    local device_id=$1
    local test_file=$2
    local test_name=$3
    
    echo -e "\n${BLUE}Running: ${test_name} on device ${device_id}${NC}"
    echo "----------------------------------------"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if flutter test integration_test/$test_file --device-id=$device_id --reporter=expanded; then
        echo -e "${GREEN}✅ ${test_name} PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ ${test_name} FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to print test summary
print_summary() {
    echo -e "\n${BLUE}Test Summary${NC}"
    echo "============"
    echo -e "Total Tests: ${TOTAL_TESTS}"
    echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
    echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}💥 Some tests failed!${NC}"
        exit 1
    fi
}

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Please run this script from the project root directory${NC}"
    exit 1
fi

# Get available devices
echo -e "${YELLOW}📱 Available devices:${NC}"
flutter devices

# Ask user for device selection
echo -e "\n${YELLOW}Select device for testing:${NC}"
echo "1. Use first available device (default)"
echo "2. Select specific device"
echo "3. Run on all available devices"
read -p "Enter choice (1-3): " device_choice

case $device_choice in
    2)
        echo -e "${YELLOW}Available devices:${NC}"
        flutter devices
        read -p "Enter device ID: " selected_device
        ;;
    3)
        echo -e "${YELLOW}Running tests on all available devices${NC}"
        devices=$(flutter devices --machine | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        ;;
    *)
        selected_device=""
        ;;
esac

# Run tests based on device selection
if [ "$device_choice" = "3" ]; then
    # Run on all devices
    for device in $devices; do
        echo -e "\n${BLUE}Testing on device: $device${NC}"
        
        # New User Flow Tests
        run_test_on_device "$device" "new_user_flow_test.dart" "New User Flow Tests"
        
        # Returning User Flow Tests  
        run_test_on_device "$device" "returning_user_flow_test.dart" "Returning User Flow Tests"
        
        # State Transition Tests
        run_test_on_device "$device" "state_transition_test.dart" "State Transition Tests"
        
        # Error Detection Tests
        run_test_on_device "$device" "error_detection_test.dart" "Error Detection Tests"
    done
else
    # Run on single device
    if [ -n "$selected_device" ]; then
        # New User Flow Tests
        run_test_on_device "$selected_device" "new_user_flow_test.dart" "New User Flow Tests"
        
        # Returning User Flow Tests
        run_test_on_device "$selected_device" "returning_user_flow_test.dart" "Returning User Flow Tests"
        
        # State Transition Tests
        run_test_on_device "$selected_device" "state_transition_test.dart" "State Transition Tests"
        
        # Error Detection Tests
        run_test_on_device "$selected_device" "error_detection_test.dart" "Error Detection Tests"
    else
        # New User Flow Tests
        run_test_file "new_user_flow_test.dart" "New User Flow Tests"
        
        # Returning User Flow Tests
        run_test_file "returning_user_flow_test.dart" "Returning User Flow Tests"
        
        # State Transition Tests
        run_test_file "state_transition_test.dart" "State Transition Tests"
        
        # Error Detection Tests
        run_test_file "error_detection_test.dart" "Error Detection Tests"
    fi
fi

# Print summary
print_summary 