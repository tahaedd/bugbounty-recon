#!/bin/bash

DOMAIN=$1
RECON_DIR="recon/$DOMAIN"
URLS_FILE="$RECON_DIR/all_urls.txt"
SUBS_DIR="$RECON_DIR/urls_by_subdomain"

mkdir -p "$RECON_DIR" "$SUBS_DIR"

echo "[+] Gathering URLs for $DOMAIN..."

# Collect URLs
gau "$DOMAIN" >> "$URLS_FILE"
echo "$DOMAIN" | waybackurls >> "$URLS_FILE"
python3 /opt/waymore/waymore.py -i "$DOMAIN" -mode U >> "$URLS_FILE"

# Remove duplicates
sort -u "$URLS_FILE" -o "$URLS_FILE"

# Extract subdomains and split
echo "[+] Splitting by subdomain..."
cat "$URLS_FILE" | awk -F/ '{print $3}' | sort -u > "$RECON_DIR/subdomains.txt"

while read SUB; do
    grep "$SUB" "$URLS_FILE" > "$SUBS_DIR/$SUB.txt"
done < "$RECON_DIR/subdomains.txt"

echo "[+] URLs organized by subdomain in $SUBS_DIR/"
