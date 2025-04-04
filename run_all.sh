#!/bin/bash

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Usage: ./run_all.sh <domain>"
    exit 1
fi

full_recon.sh "$DOMAIN"
analyze_js.sh "$DOMAIN"
