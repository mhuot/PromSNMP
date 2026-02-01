# PromSNMP Demo Recording
# Usage: vhs record-demo.tape
#
# Prerequisites:
#   - Install VHS: brew install vhs (or go install github.com/charmbracelet/vhs@latest)
#   - Install ttyd: brew install ttyd
#   - Ensure gh, jenv, make, docker are available
#   - Clean environment (no existing PromSNMP clone)

# Configuration
Output promsnmp-demo.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 50ms
Set PlaybackSpeed 0.5

# Start recording
Sleep 500ms

# Clone the repository
Type "gh repo clone pbrane/promsnmp-metrics"
Sleep 300ms
Enter
Sleep 3s

# Change into directory
Type "cd promsnmp-metrics"
Sleep 200ms
Enter
Sleep 500ms

# Set Java version
Type "jenv local 21"
Sleep 200ms
Enter
Sleep 1s

# Build the project
Type "make"
Sleep 200ms
Enter
Sleep 30s

# Change to deployment directory
Type "cd deployment"
Sleep 200ms
Enter
Sleep 500ms

# Start Docker Compose stack
Type "docker compose up -d"
Sleep 200ms
Enter
Sleep 10s

# Wait for services to be ready
Type "# Waiting for services to start..."
Enter
Sleep 5s

# Test the hello endpoint
Type "curl -s http://localhost:8080/promsnmp/hello"
Sleep 200ms
Enter
Sleep 2s

# Show targets endpoint
Type "curl -s http://localhost:8080/targets | head -20"
Sleep 200ms
Enter
Sleep 2s

# Show a sample SNMP query (if available)
Type "curl -s 'http://localhost:8080/snmp?target=demo' | head -30"
Sleep 200ms
Enter
Sleep 3s

# Final pause
Sleep 2s
