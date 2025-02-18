#!/bin/bash

if [ -z "$1" ]; then
    echo "Polls the HTTP server at the given IP address and port for log messages every 0.25s"
    echo "Usage: $0 <IP_ADDRESS> [PORT]"
    exit 1
fi

IP_ADDRESS=$1
PORT=${2:-18018}

while true; do
    curl -s http://$IP_ADDRESS:$PORT/get | tac | while read -r line; do
        if [[ $line == ERROR:* ]]; then
            echo -e "\e[38;5;196m$line\e[0m"  # Light red color for ERROR
        elif [[ $line == INFO:* ]]; then
            echo -e "\e[38;5;69m$line\e[0m"  # Light blue color for INFO
        elif [[ $line == WARN:* ]]; then
            echo -e "\e[38;5;214m$line\e[0m"  # Orange color for WARN
        else
            echo "$line"  # No color for DEBUG
        fi
    done
    # Don't poll too much...
    sleep 0.25
done
