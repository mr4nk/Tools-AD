#!/bin/bash

# Ask user for subnet (e.g., 192.168.1)
read -p "Enter IP range (e.g., 192.168.1): " SUBNET

# Validate input
if [[ ! $SUBNET =~ ^([0-9]{1,3}\.){2}[0-9]{1,3}$ ]]; then
    echo "Invalid IP range format. Use format like 192.168.1"
    exit 1
fi

OUTPUT_FILE="open_ssh_hosts.txt"
> "$OUTPUT_FILE"  # Clear file if exists

echo "[*] Scanning subnet: $SUBNET.1 - $SUBNET.254"
echo "[*] Saving results to $OUTPUT_FILE"
echo ""

for i in {1..254}; do
    IP="$SUBNET.$i"

    ping -c 1 -W 1 $IP &> /dev/null
    if [ $? -eq 0 ]; then
        echo "[+] Host is up: $IP"

        nc -z -w2 $IP 22 &> /dev/null
        if [ $? -eq 0 ]; then
            echo "    [✔] Port 22 is OPEN"
            echo "$IP" >> "$OUTPUT_FILE"
        else
            echo "    [✘] Port 22 is CLOSED"
        fi
    fi
done

echo ""
echo "[✓] Scan complete. Live hosts with port 22 open saved to $OUTPUT_FILE"
