
#!/usr/bin/env bash
set -u

echo "========================================"
echo "       ORION FORENSIC LAB START"
echo "========================================"

if ! command -v systemctl >/dev/null 2>&1; then
    echo "ERROR: systemctl is not available on this system."
    exit 1
fi

echo
echo "Starting NGINX..."
sudo systemctl start nginx || {
    echo "ERROR: Could not start NGINX."
    exit 1
}

echo "Starting Tor..."
if systemctl list-unit-files tor@default.service --no-legend 2>/dev/null |
    grep -q 'tor@default'; then
    sudo systemctl start tor@default || {
        echo "WARNING: Could not start tor@default."
    }
else
    echo "NOTE: tor@default service was not found."
fi

echo
echo "SERVICE STATUS"
echo "NGINX: $(systemctl is-active nginx 2>/dev/null || true)"
echo "TOR:   $(systemctl is-active tor@default 2>/dev/null || true)"

echo
echo "NGINX CONFIGURATION TEST"
sudo nginx -t || {
    echo "WARNING: NGINX configuration test failed."
}

echo
echo "LOCAL WEB TEST"
if command -v curl >/dev/null 2>&1; then
    curl -I --max-time 10 http://127.0.0.1/ 2>/dev/null |
        head -n 1 || echo "Local web test failed."
else
    echo "curl is not installed."
fi

# Only display the onion address when explicitly requested.
if [[ "${ORION_SHOW_ONION:-0}" == "1" ]]; then
    HOSTNAME_FILE="/var/lib/tor/orion/hostname"
    if [[ -r "$HOSTNAME_FILE" ]]; then
        echo
        echo "ORION ONION ADDRESS:"
        sudo cat "$HOSTNAME_FILE"
    else
        echo "Onion hostname file is not readable."
    fi
else
    echo
    echo "Onion address hidden by default."
    echo "Set ORION_SHOW_ONION=1 to display it locally."
fi

echo
echo "========================================"
echo "       ORION STARTUP CHECK FINISHED"
echo "========================================"
