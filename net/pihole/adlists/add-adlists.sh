#!/bin/bash

set -e
set -u

LISTS_FILE="/etc/custom.d/02-adlists/lists.txt"
GRAVITY_DB="/etc/pihole/gravity.db"

if [ ! -f "$LISTS_FILE" ]; then
    echo "Error: Lists file $LISTS_FILE not found."
    exit 1
fi

echo "Starting adlist import process..."

while IFS= read -r url; do
    if [ -z "$url" ]; then
        continue  # Skip empty lines
    fi

    echo "Checking URL: $url"

    # Check if the URL exists in the database
    exists=$(pihole-FTL sqlite3 "$GRAVITY_DB" "SELECT COUNT(*) FROM adlist WHERE address = '$url';")

    if [ "$exists" -eq 0 ]; then
        echo "Adding new URL: $url"
        pihole-FTL sqlite3 "$GRAVITY_DB" "INSERT INTO adlist (address, enabled, comment) VALUES ('$url', 1, 'Added via script');"
    else
        echo "Updating existing URL: $url"
        pihole-FTL sqlite3 "$GRAVITY_DB" "UPDATE adlist SET enabled = 1, comment = 'Updated via script' WHERE address = '$url';"
    fi
done < "$LISTS_FILE"

# Update the gravity database
echo "Updating Pi-hole gravity..."
pihole -g

echo "Process completed successfully."
echo