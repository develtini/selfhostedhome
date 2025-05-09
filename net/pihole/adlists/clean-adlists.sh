#!/bin/bash

set -e
set -u

GRAVITY_DB="/etc/pihole/gravity.db"

echo "Starting adlist cleaning process..."

if [ ! -f "$GRAVITY_DB" ]; then
    echo "Error: Gravity database $GRAVITY_DB not found."
    exit 1
fi

# Check if the database is empty
count=$(pihole-FTL sqlite3 "$GRAVITY_DB" "SELECT COUNT(*) FROM adlist WHERE enabled = 1;")
echo "Current number of adlists: $count"

if [ "$count" -eq 0 ]; then
    echo "No adlists to clean."
    exit 0
fi

# Delete all adlists from the database
pihole-FTL sqlite3 "$GRAVITY_DB" "UPDATE adlist SET enabled = 0;"

# Update the gravity database
echo "Updating Pi-hole gravity..."
pihole -g

echo "Adlist cleaning process completed successfully."