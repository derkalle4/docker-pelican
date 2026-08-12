#!/bin/bash

set -Eeuo pipefail

cd /home/container

export DISPLAY="${DISPLAY:-:0}"

echo "Running on:"
if [[ -f /etc/debian_version ]]; then
    cat /etc/debian_version
fi

if [[ -f /etc/timezone ]]; then
    echo "Current timezone: $(cat /etc/timezone)"
fi

echo "Wine version:"
wine --version

# Determine the internal Docker IP address.
INTERNAL_IP="$(
    ip route get 1 2>/dev/null |
    awk '
        {
            for (i = 1; i <= NF; i++) {
                if ($i == "src") {
                    print $(i + 1)
                    exit
                }
            }
        }
    '
)"

export INTERNAL_IP

echo "Internal IP: ${INTERNAL_IP:-unknown}"
echo "Display: ${DISPLAY}"

XVFB_PID=""

cleanup() {
    if [[ -n "${XVFB_PID}" ]] &&
       kill -0 "${XVFB_PID}" 2>/dev/null; then
        kill "${XVFB_PID}" 2>/dev/null || true
        wait "${XVFB_PID}" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

# Start the virtual X server.
if [[ "${XVFB:-1}" == "1" ]]; then
    echo "Starting Xvfb on ${DISPLAY}"

    Xvfb "${DISPLAY}" \
        -screen 0 "${DISPLAY_WIDTH:-1280}x${DISPLAY_HEIGHT:-720}x${DISPLAY_DEPTH:-24}" \
        -nolisten tcp \
        >/tmp/xvfb.log 2>&1 &

    XVFB_PID=$!

    sleep 1

    if ! kill -0 "${XVFB_PID}" 2>/dev/null; then
        echo "ERROR: Xvfb failed to start."
        cat /tmp/xvfb.log
        exit 1
    fi
fi

# Replace startup placeholders:
# {{SERVER_PORT}} becomes ${SERVER_PORT}.
STARTUP_COMMAND="$(
    printf '%b' "${STARTUP:-}" |
    sed \
        -e 's/{{/${/g' \
        -e 's/}}/}/g'
)"

if [[ -z "${STARTUP_COMMAND}" ]]; then
    echo "ERROR: STARTUP is empty."
    exit 1
fi

echo "Running:"
echo "${STARTUP_COMMAND}"

# Run the server as PID 1 so it receives container signals correctly.
exec bash -c "${STARTUP_COMMAND}"