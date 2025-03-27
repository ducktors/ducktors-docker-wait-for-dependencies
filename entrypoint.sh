#!/bin/bash

set -euo pipefail

# Default configuration
SLEEP_LENGTH=${SLEEP_LENGTH:-2}
TIMEOUT_LENGTH=${TIMEOUT_LENGTH:-300}

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [host:port]...

Wait for services to become available on specified ports.

Environment variables:
    SLEEP_LENGTH    Time to wait between checks (default: 2)
    TIMEOUT_LENGTH  Maximum time to wait in seconds (default: 300)

Example:
    $(basename "$0") localhost:5432 redis:6379
EOF
    exit 0
}

# Validate input arguments
if [ $# -eq 0 ]; then
    echo "Error: No host:port arguments provided"
    show_help
fi

# Validate environment variables
if ! [[ "$SLEEP_LENGTH" =~ ^[0-9]+$ ]] || [ "$SLEEP_LENGTH" -le 0 ]; then
    echo "Error: SLEEP_LENGTH must be a positive number"
    exit 1
fi

if ! [[ "$TIMEOUT_LENGTH" =~ ^[0-9]+$ ]] || [ "$TIMEOUT_LENGTH" -le 0 ]; then
    echo "Error: TIMEOUT_LENGTH must be a positive number"
    exit 1
fi

# Function to validate host:port format
validate_host_port() {
    local input=$1
    if ! [[ "$input" =~ ^[^:]+:[0-9]+$ ]]; then
        echo "Error: Invalid format. Expected 'host:port', got '$input'"
        return 1
    fi
    return 0
}

wait_for() {
    local host=$1
    local port=$2
    local start_time=$(date +%s)
    local end_time=$((start_time + TIMEOUT_LENGTH))

    echo "Waiting for $host to listen on port $port (timeout: ${TIMEOUT_LENGTH}s)..."
    
    while true; do
        if nc -z "$host" "$port" 2>/dev/null; then
            local elapsed_time=$(($(date +%s) - start_time))
            echo "✓ $host:$port is available (waited ${elapsed_time}s)"
            return 0
        fi

        if [ $(date +%s) -ge $end_time ]; then
            echo "✗ Timeout: $host:$port did not become available within ${TIMEOUT_LENGTH}s"
            return 1
        fi

        echo "  Waiting... (${SLEEP_LENGTH}s)"
        sleep "$SLEEP_LENGTH"
    done
}

# Main execution
for arg in "$@"; do
    if ! validate_host_port "$arg"; then
        exit 1
    fi
    
    host=${arg%:*}
    port=${arg#*:}
    
    if ! wait_for "$host" "$port"; then
        exit 1
    fi
done

echo "All services are available!"
