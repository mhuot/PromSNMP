#!/usr/bin/env bash
#
# promsnmp-metrics Demo GIF Recorder
#
# This script creates an animated GIF demonstrating promsnmp-metrics setup.
# Uses VHS (charmbracelet/vhs) for terminal recording.
#
# Prerequisites:
#   brew install vhs ffmpeg ttyd
#   gh auth login
#   jenv (with Java 21 configured)
#   docker
#
# Usage:
#   ./record-demo.sh [--quick]
#
# Options:
#   --quick    Skip build, assume promsnmp-metrics is already built
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${TMPDIR:-/tmp}/promsnmp-demo-$$"
OUTPUT_FILE="${SCRIPT_DIR}/../docs/images/promsnmp-demo.gif"
QUICK_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prereqs() {
    local missing=()

    command -v vhs >/dev/null 2>&1 || missing+=("vhs (brew install vhs)")
    command -v gh >/dev/null 2>&1 || missing+=("gh (brew install gh)")
    command -v docker >/dev/null 2>&1 || missing+=("docker")
    command -v jenv >/dev/null 2>&1 || missing+=("jenv")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing prerequisites:"
        printf '  - %s\n' "${missing[@]}"
        exit 1
    fi

    # Check if Java 21 is available
    if ! jenv versions 2>/dev/null | grep -q "21"; then
        echo "Warning: Java 21 not found in jenv. Recording may fail."
    fi
}

# Cleanup function
cleanup() {
    echo "Cleaning up..."

    # Stop any running containers from the demo
    if [[ -d "$WORK_DIR/promsnmp-metrics/deployment" ]]; then
        (cd "$WORK_DIR/promsnmp-metrics/deployment" && docker compose down 2>/dev/null) || true
    fi

    # Remove work directory
    rm -rf "$WORK_DIR"

    echo "Cleanup complete."
}

# Set trap for cleanup
trap cleanup EXIT

# Main recording function
record_demo() {
    echo "=== promsnmp-metrics Demo Recorder ==="
    echo ""
    echo "Work directory: $WORK_DIR"
    echo "Output file: $OUTPUT_FILE"
    echo ""

    check_prereqs

    # Create work directory
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    # Create the VHS tape file dynamically
    cat > demo.tape << 'TAPE'
# promsnmp-metrics Demo Recording
Output promsnmp-demo.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 40ms

Sleep 500ms

# Clone the repository
Type "gh repo clone pbrane/promsnmp-metrics"
Enter
Sleep 4s

# Change into directory
Type "cd promsnmp-metrics"
Enter
Sleep 500ms

# Set Java version
Type "jenv local 21"
Enter
Sleep 1s

# Build the project
Type "make"
Enter
Sleep 45s

# Change to deployment directory
Type "cd deployment"
Enter
Sleep 500ms

# Start Docker Compose stack
Type "docker compose up -d"
Enter
Sleep 8s

# Wait message
Type "echo 'Waiting for services...'; sleep 10"
Enter
Sleep 12s

# Test the hello endpoint
Type "curl -s http://localhost:8080/promsnmp/hello"
Enter
Sleep 2s

# Show inventory
Type "curl -s http://localhost:8080/promsnmp/inventory | jq ."
Enter
Sleep 3s

Sleep 2s
TAPE

    # Run VHS to create the recording
    echo "Starting recording..."
    vhs demo.tape

    # Move output to final location
    if [[ -f "promsnmp-demo.gif" ]]; then
        mv promsnmp-demo.gif "$OUTPUT_FILE"
        echo ""
        echo "=== Recording Complete ==="
        echo "Output saved to: $OUTPUT_FILE"
        echo ""
        echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    else
        echo "Error: Recording failed - no output file created"
        exit 1
    fi
}

# Quick mode - record against existing setup
record_quick() {
    echo "=== Quick Recording Mode ==="
    echo "Recording against existing promsnmp-metrics installation..."

    check_prereqs

    cd "$SCRIPT_DIR"

    cat > /tmp/quick-demo.tape << 'TAPE'
Output promsnmp-demo.gif
Set FontSize 14
Set Width 1000
Set Height 500
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 50ms

Sleep 500ms

Type "# promsnmp-metrics Quick Demo"
Enter
Sleep 1s

Type "curl -s http://localhost:8080/promsnmp/hello"
Enter
Sleep 2s

Type "curl -s http://localhost:8080/targets | head -10"
Enter
Sleep 2s

Type "curl -s http://localhost:8080/promsnmp/inventory | jq '.devices | length' "
Enter
Sleep 2s

Sleep 1s
TAPE

    cd /tmp
    vhs quick-demo.tape
    mv promsnmp-demo.gif "$OUTPUT_FILE"

    echo "Quick recording saved to: $OUTPUT_FILE"
}

# Run appropriate mode
if $QUICK_MODE; then
    record_quick
else
    record_demo
fi
