#!/bin/bash
cd /home/container

# Detect system architecture
ARCH=$(uname -m)

if [[ "$ARCH" == "aarch64" ]]; then
    ARCH_TEXT="ARM"
elif [[ "$ARCH" == "x86_64" ]]; then
    ARCH_TEXT="AMD"
else
    ARCH_TEXT="UNKNOWN"
fi

# Fetch PHP version if not already set and extract only the major and minor version (e.g., 8.4 from 8.4.2)
if [ -z "$PHP_VERSION" ]; then
    PHP_VERSION=$(php -v | head -n 1 | awk '{print $2}' | cut -d. -f1,2)
fi

# Custom ASCII art for ZARI0 with blue and purple colors
echo -e "\e[1;36m"  # Cyan text color
echo "***********************************************"
echo "*                                             *"
echo "*         APACHE2 + PHP VERSION $PHP_VERSION           *"
echo "*                BASE ON $ARCH_TEXT                  *"
echo "*                                             *"
echo "***********************************************"
echo -e "\e[0m"  # Reset color to default


# Custom ASCII art for ZARI0 with blue and purple colors
echo -e "\e[1;34m
███████╗ \e[1;35m█████╗ \e[1;34m██████╗ \e[1;35m████████╗\e[1;34m██╗ \e[1;35m██████╗ 
\e[1;34m╚══███╔╝\e[1;35m██╔══██╗\e[1;34m██╔══██╗\e[1;35m╚══██╔══╝\e[1;34m██║\e[1;35m██╔═══██╗
\e[1;34m  ███╔╝ \e[1;35m███████║\e[1;34m██████╔╝   \e[1;35m██║   \e[1;34m██║██║   ██║
\e[1;34m ███╔╝  \e[1;35m██╔══██║\e[1;34m██╔═██╗    \e[1;35m██║   \e[1;34m██║██║   ██║
\e[1;34m███████╗\e[1;35m██║  ██║\e[1;34m██║ ██║    \e[1;35m██║   \e[1;34m██║\e[1;35m╚██████╔╝
\e[1;34m╚══════╝\e[1;35m╚═╝  ╚═╝\e[1;34m╚═╝ ╚═╝    \e[1;35m╚═╝   \e[1;34m╚═╝ \e[1;35m╚═════╝ 
\e[0m"

# Print custom fingerprint message

# Print custom fingerprint message with email and GitHub
echo -e "\e[1;36m"
echo "***********************************************"
echo "*                                             *"
echo "*     This container was built with ♥ by      *"
echo "*                  Zarti0                      *"
echo "*                                             *"
echo "***********************************************"
echo -e "\e[0m"

echo -e "\e[1;35m"
echo "***********************************************"
echo "*                                             *"
echo "*       For any inquiries, reach out at:      *"
echo "*             zarti0@zarti.cfd                *"
echo "*                                             *"
echo "*            Check out my GitHub:             *"
echo "*             github.com/zarti0               *"
echo "*                                             *"
echo "***********************************************"
echo -e "\e[0m"

echo -e "\e[1;34m"
echo "***********************************************"
echo "*                                             *"
echo "*   Thank you for using this container!       *"
echo "*       Enjoy your experience! 🚀            *"
echo "*                                             *"
echo "***********************************************"
echo -e "\e[0m"


echo -e " "

echo -e "\033[0;34m ─────────────────────────────────────────────────\033[0m"
echo -e "|                                                |"
echo -e "|   \033[1;32m█████████████████████\033[1;37m█████████████████████\033[0m   |"
echo -e "|   \033[1;32m█████████████████\033[1;31m████████\033[1;37m█████████████████\033[0m   |"
echo -e "|   \033[1;32m██████████████\033[1;31m███        ███\033[1;37m██████████████\033[0m   |"
echo -e "|   \033[1;32m████████████\033[1;31m██              \033[1;31m██\033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m██████████\033[1;31m██       ⢀⣼         \033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m█████████\033[1;31m█      ⢳⣶⣶⣿⣿⣇⣀       \033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m████████\033[1;31m██       ⣹⣿⣿⣿⣿⠿⠋⠁     \033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m█████████\033[1;31m█      ⢰⠿⠛⠻⢿⡇        \033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m██████████\033[1;31m██         ⠋        \033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m████████████\033[1;31m██              \033[1;31m██\033[1;37m████████████\033[0m   |"
echo -e "|   \033[1;32m██████████████\033[1;31m███        ███\033[1;37m██████████████\033[0m   |"
echo -e "|   \033[1;32m█████████████████\033[1;31m████████\033[1;37m█████████████████\033[0m   |"
echo -e "|   \033[1;32m█████████████████████\033[1;37m█████████████████████\033[0m   |"
echo -e "|                                                |"
echo -e "\033[0;34m ─────────────────────────────────────────────────\033[0m"

echo -e " "


# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}