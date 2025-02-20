#!/bin/bash

# Header
echo -e " "
echo -e "\033[0;34m───────────────────────────────────────────────\033[0m"
echo -e "\033[1;34m🇩🇿 [Tunnel] Cloudflare Tunnel\033[0m"
echo -e "\033[0;34m───────────────────────────────────────────────\033[0m"


LOG_FILE="/home/container/logs/cloudflared.log"
LOG_LIMIT=$((10 * 1024 * 1024))  # 10 MB in bytes
DOMAIN_FILE="/home/container/tunnel_domain.txt"

# Function to clear log if it exceeds 10 MB
check_log_size() {
    if [ -f "$LOG_FILE" ]; then
        FILE_SIZE=$(stat -c%s "$LOG_FILE")
        if [ "$FILE_SIZE" -ge "$LOG_LIMIT" ]; then
            echo -e "\033[0;33m[Tunnel] Log file size exceeds 10 MB. Clearing log...\033[0m"
            > "$LOG_FILE"  # Truncate the log file
        fi
    fi
}

# [Tunnel] Check if cloudflared_token.txt exists and has content
if [ -s "/home/container/cloudflared_token.txt" ]; then
    echo -e "\033[0;37m[Tunnel] Starting Cloudflared with token\033[0m"

    # Check and clear log file if necessary
    check_log_size

    # Start cloudflared in the background and store the PID
    cloudflared tunnel --no-autoupdate run --token "$(cat /home/container/cloudflared_token.txt)" > "$LOG_FILE" 2>&1 &
    CLOUD_FLARED_PID=$!

    echo $CLOUD_FLARED_PID > /home/container/tmp/cloudflared.pid

    MAX_ATTEMPTS=130
    ATTEMPT=0

    # Times for status messages (seconds)
    STATUS_TIMES=(5 10 15 30 60 90 120)

    # Display waiting message
    echo -e "\033[0;33m[Tunnel] Waiting for Cloudflared to start...\033[0m"

    # Monitor log file in real-time for a success or failure message
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        sleep 1
        ATTEMPT=$((ATTEMPT + 1))

        if [[ " ${STATUS_TIMES[@]} " =~ " $ATTEMPT " ]]; then
            echo -e "\033[0;33m[Tunnel] Still waiting... ($ATTEMPT sec)\033[0m"
        fi

        # Check if cloudflared has exited
        if ! kill -0 $CLOUD_FLARED_PID 2>/dev/null; then
            echo -e "\033[0;31m[Tunnel] Cloudflared failed to start. Check logs at $LOG_FILE\033[0m"
            echo -e "\033[0;31m$(tail -n 10 $LOG_FILE)\033[0m"
            exit 1
        fi

        # Check log file for success messages
        if grep -qE "Registered tunnel connection|Updated to new configuration" "$LOG_FILE"; then
            echo -e "\033[0;32m[Tunnel] Connected after $ATTEMPT seconds\033[0m"
            echo -e "\033[0;32m[Tunnel] Cloudflared is running successfully!\033[0m"
            
            # Check if tunnel_domain.txt exists and has content
            if [ -s "$DOMAIN_FILE" ]; then
                DOMAIN=$(cat "$DOMAIN_FILE")
                echo -e "\033[0;32m[Tunnel] Your website is up: \033[1;34m\033[4mhttps://$DOMAIN\033[0m\033[0;32m\033[0m"
                # FOOTER
                echo -e " "
                echo -e "\033[0;34m───────────────────────────────────────────────\033[0m"
                echo -e "\033[1;34m[Tunnel] Cloudflare Tunnel\033[0m"
                echo -e "\033[0;34m───────────────────────────────────────────────\033[0m"
            fi

            exit 0
        fi
    done

    # If we reach here, max attempts were reached without confirmation
    echo -e "\n\033[0;31m[Tunnel] Cloudflared did not confirm a successful connection. Check logs at $LOG_FILE\033[0m"
    echo -e "\033[0;31m$(tail -n 10 $LOG_FILE)\033[0m"
    exit 1

else
    echo -e "\033[0;31m[Tunnel] cloudflared_token.txt is empty or does not exist. Skipping Cloudflared startup.\033[0m"
fi
