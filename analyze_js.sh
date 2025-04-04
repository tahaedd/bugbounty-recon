#!/bin/bash

DOMAIN=$1
RECON_DIR="recon/$DOMAIN"
SUBS_DIR="$RECON_DIR/urls_by_subdomain"
JS_DIR="$RECON_DIR/js_downloads"
OUT_DIR="$RECON_DIR/js_output"

mkdir -p "$JS_DIR" "$OUT_DIR"

echo "[+] Starting JS analysis for $DOMAIN..."

for FILE in "$SUBS_DIR"/*.txt; do
    SUBDOMAIN=$(basename "$FILE" .txt)
    mkdir -p "$JS_DIR/$SUBDOMAIN" "$OUT_DIR/$SUBDOMAIN"

    echo "[*] Processing $SUBDOMAIN"

    # Extract .js links
    grep -Ei '\.js($|\?)' "$FILE" | sort -u > "$JS_DIR/$SUBDOMAIN/js_links.txt"

    # Download JS files
    cd "$JS_DIR/$SUBDOMAIN"
    while read JSURL; do
        wget --no-check-certificate -q "$JSURL" -P .
    done < js_links.txt
    cd - > /dev/null

    # Run JS tools
    for JSFILE in "$JS_DIR/$SUBDOMAIN"/*.js; do
        [[ -f "$JSFILE" ]] || continue

        # jslinkfinder
        python3 /opt/golinkfinder/golinkfinder.py -i "$JSFILE" >> "$OUT_DIR/$SUBDOMAIN/jslinkfinder.txt"

        # LinkFinder
        python3 /opt/LinkFinder/linkfinder.py -i "$JSFILE" -o cli >> "$OUT_DIR/$SUBDOMAIN/linkfinder.txt"

        # xnLinkFinder
        python3 /opt/xnLinkFinder/xnLinkFinder.py -i "$JSFILE" -o cli >> "$OUT_DIR/$SUBDOMAIN/xnlinkfinder.txt"

        # subjs: already handled in gau sometimes, skip

        # JSScanner (assumes pip install)
        python3 /opt/JSScanner/jsscanner.py -f "$JSFILE" >> "$OUT_DIR/$SUBDOMAIN/jsscanner.txt"

        # SecretFinder
        python3 /opt/SecretFinder/SecretFinder.py -i "$JSFILE" -o cli >> "$OUT_DIR/$SUBDOMAIN/secretfinder.txt"
    done
done

echo "[+] JS analysis complete. Results in $OUT_DIR/"
