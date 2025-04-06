#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error when substituting

TEMPLATE_FILE="/etc/custom.d/01-static-entries/selfhosted-static-record.conf.template"
OUTPUT_FILE="/etc/dnsmasq.d/custom-dns.conf"


pihole-FTL --config misc.etc_dnsmasq_d true

echo "Starting dnsmasq configuration update..."

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Check if environment variables are set
if [ -z "${PROXY_IP}" ] || [ -z "${PROXY_DOMAIN}" ]; then
    echo "Error: Environment variables PROXY_IP or PROXY_DOMAIN are not set."
    exit 1
fi

# Generate the configuration file with substituted variables
sed "s|\$PROXY_DOMAIN|${PROXY_DOMAIN}|g; s|\$PROXY_IP|${PROXY_IP}|g" "$TEMPLATE_FILE" > "$OUTPUT_FILE"

# Display the generated file for verification
echo "Configuration file successfully generated at $OUTPUT_FILE."
echo "Generated file content:"
cat "$OUTPUT_FILE"

# Restart Pi-hole DNS to apply changes
echo "Checking syntax of dnsmasq configuration..."
pihole-FTL dnsmasq-test

pihole g

echo "Configuration update completed successfully."
