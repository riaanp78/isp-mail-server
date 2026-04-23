#!/bin/bash
# DKIM Auto-Generator for MailStack
# Runs via systemd timer to check for new domains
# Includes randomized delay and file locking to prevent race conditions

LOG_FILE="/var/log/dkim-autogen.log"
DKIM_GEN_CMD="/usr/local/bin/generate-dkim-keys"
LOCK_FILE="/var/run/dkim-autogen.lock"
MAX_LOG_SIZE=10485760  # 10MB
MAX_RANDOM_DELAY=30

# Rotate log if too large
if [ -f "$LOG_FILE" ] && [ $(stat -c %s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
fi

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$(hostname)] $1" >> "$LOG_FILE"
}

# Function to acquire lock
acquire_lock() {
    local lock_file="$1"
    local max_wait=60
    local wait_time=0
    local sleep_interval=2
    
    while [ $wait_time -lt $max_wait ]; do
        if mkdir "$lock_file" 2>/dev/null; then
            log "Lock acquired successfully"
            return 0
        else
            log "Lock held by another process, waiting..."
            sleep $sleep_interval
            wait_time=$((wait_time + sleep_interval))
        fi
    done
    
    log "ERROR: Could not acquire lock after ${max_wait} seconds"
    return 1
}

# Function to release lock
release_lock() {
    local lock_file="$1"
    if [ -d "$lock_file" ]; then
        rmdir "$lock_file" 2>/dev/null
        log "Lock released"
    fi
}

# Function to get deterministic delay
get_deterministic_delay() {
    local hostname=$(hostname)
    local hash=$(echo "$hostname" | md5sum | cut -c1-8)
    local delay=$((0x$hash % $MAX_RANDOM_DELAY))
    echo $delay
}

# Function to get random delay
get_random_delay() {
    echo $((RANDOM % MAX_RANDOM_DELAY))
}

# Main execution
log "=== Starting DKIM auto-generation ==="

DETERMINISTIC_DELAY=$(get_deterministic_delay)
TRUE_RANDOM_DELAY=$(get_random_delay)
TOTAL_DELAY=$((DETERMINISTIC_DELAY + TRUE_RANDOM_DELAY))

log "Hostname: $(hostname)"
log "Deterministic delay: ${DETERMINISTIC_DELAY}s"
log "Random delay: ${TRUE_RANDOM_DELAY}s"
log "Total delay: ${TOTAL_DELAY}s"

log "Waiting ${TOTAL_DELAY} seconds to stagger execution..."
sleep $TOTAL_DELAY

if [ ! -x "$DKIM_GEN_CMD" ]; then
    log "ERROR: generate-dkim-keys command not found"
    exit 1
fi

if acquire_lock "$LOCK_FILE"; then
    log "Starting DKIM key generation..."
    
    # Run DKIM generation for all domains
    $DKIM_GEN_CMD -a 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log "DKIM auto-generation completed successfully"
    else
        log "DKIM auto-generation failed with exit code $?"
    fi
    
    release_lock "$LOCK_FILE"
else
    log "ERROR: Failed to acquire lock, exiting"
    exit 1
fi

log "=== DKIM auto-generation finished ==="