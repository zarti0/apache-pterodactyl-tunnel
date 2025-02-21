#!/bin/bash

# Header
echo -e " "
echo -e "\033[0;34m───────────────────────────────────────────────\033[0m"
echo -e "\033[1;34m[Apache2] Loading setup\033[0m"
echo -e "\033[0;34m───────────────────────────────────────────────\033[0m"

# [Cleanup] Removing temporary files
echo -e "\033[0;35m[Cleanup] Removing temporary files\033[0m"
rm -rf /home/container/tmp/*
rm -rf /home/container/apache2/socks/*
rm -rf /home/container/apache2.pid

# Clean up PID files
echo -e "\033[0;35m[Cleanup] Removing old PID files\033[0m"
rm -rf /home/container/logs/*.pid

# [Cleanup] Checking & Deleting Old or Large Logs
LOG_FILES=(
    "/home/container/logs/error.log"
    "/home/container/logs/php_errors.log"
    "/home/container/logs/php-fpm.log"
)
MAX_SIZE_MB=10
MAX_AGE_DAYS=30

echo -e "\033[0;35m[Cleanup] Checking log files for deletion...\033[0m"

for FILE in "${LOG_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        FILE_SIZE_MB=$(( $(stat -c%s "$FILE") / 1024 / 1024 ))
        FILE_AGE_DAYS=$(( ($(date +%s) - $(stat -c %Y "$FILE")) / 86400 ))

        if [[ $FILE_SIZE_MB -gt $MAX_SIZE_MB || $FILE_AGE_DAYS -gt $MAX_AGE_DAYS ]]; then
            echo -e "\033[0;33m[Cleanup] Deleting: $FILE (Size: ${FILE_SIZE_MB}MB, Age: ${FILE_AGE_DAYS} days)\033[0m"
            rm "$FILE"
        else
            echo -e "\033[0;32m[Cleanup] Keeping: $FILE (Size: ${FILE_SIZE_MB}MB, Age: ${FILE_AGE_DAYS} days)\033[0m"
        fi
    fi
done

echo -e "\033[0;35m[Cleanup] Log file cleanup complete.\033[0m"
echo -e " "

# [Setup] Loading PHP version
echo -e "\033[0;37m[Apache2] Loading PHP version\033[0m"
PHP_VERSION=$(cat "/home/container/php_version.txt")

# Start PHP-FPM with custom PHP configuration file
echo -e "\033[0;37m[Apache2] Starting PHP-FPM (PHP $PHP_VERSION)\033[0m"
php-fpm$PHP_VERSION -c /home/container/php/php.ini --fpm-config /home/container/php/php-fpm.conf --pid /home/container/tmp/php-fpm.pid --daemonize
 > /dev/null 2>&1

# Check if PHP-FPM started successfully
if [ -f /home/container/tmp/php-fpm.pid ]; then
    echo -e "\033[0;32m[Apache2] PHP-FPM started successfully (PID: $(cat /home/container/tmp/php-fpm.pid))\033[0m"
else
    echo -e "\033[0;31m[Apache2] PHP-FPM failed to start.\033[0m"
fi

# [Docker] Starting Apache
echo -e "\033[0;37m[Apache2] Starting Apache\033[0m"

# Source the envvars file to load Apache environment variables
source /home/container/apache2/envvars

# Start Apache and create the PID file in /home/container/logs/
apache2 -f /home/container/apache2/apache2.conf -DFOREGROUND &
sleep 2

# Check if Apache started successfully
if [ -f /home/container/tmp/apache2.pid ]; then
    echo -e "\033[0;32m[Apache2] Apache started successfully (PID: $(cat /home/container/tmp/apache2.pid))\033[0m"
else
    echo -e "\033[0;31m[Apache2] Apache failed to start.\033[0m"
fi

# Tail Apache access logs
echo -e "\033[0;37m[Apache2] Showing Apache logs...\033[0m"
tail -f /home/container/logs/access.log


