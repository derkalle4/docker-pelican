#!/bin/bash

set -Eeuo pipefail

cd /home/container

export DISPLAY="${DISPLAY:-:0}"

log() {
    echo "$*"
}

start_xvfb() {
    if [[ "${XVFB:-1}" != "1" ]]; then
        return 0
    fi

    log "Starting Xvfb on ${DISPLAY}"
    Xvfb "${DISPLAY}" \
        -screen 0 "${DISPLAY_WIDTH:-1280}x${DISPLAY_HEIGHT:-720}x${DISPLAY_DEPTH:-24}" \
        -nolisten tcp \
        >/tmp/xvfb.log 2>&1 &
    XVFB_PID=$!
    sleep 1

    if ! kill -0 "${XVFB_PID}" 2>/dev/null; then
        log "ERROR: Xvfb failed to start."
        cat /tmp/xvfb.log || true
        exit 1
    fi
}

resolve_startup() {
    local startup_raw="${STARTUP:-}"
    if [[ -z "${startup_raw}" ]]; then
        log "ERROR: STARTUP is empty."
        exit 1
    fi

    printf '%b' "${startup_raw}" | sed -e 's/{{/${/g' -e 's/}}/}/g'
}

cleanup() {
    if [[ -n "${XVFB_PID:-}" ]] && kill -0 "${XVFB_PID}" 2>/dev/null; then
        kill "${XVFB_PID}" 2>/dev/null || true
        wait "${XVFB_PID}" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

log "Running on:"
[[ -f /etc/debian_version ]] && cat /etc/debian_version
[[ -f /etc/timezone ]] && log "Current timezone: $(cat /etc/timezone)"
log "Wine version:"
wine --version

INTERNAL_IP="$(ip route get 1 2>/dev/null | awk '($i=="src"){print $(i+1); exit} {for (i=1; i<=NF; i++) if ($i=="src") {print $(i+1); exit}}')"
export INTERNAL_IP
log "Internal IP: ${INTERNAL_IP:-unknown}"
log "Display: ${DISPLAY}"

start_xvfb

STARTUP_COMMAND="$(resolve_startup)"
log "Running:"
log "${STARTUP_COMMAND}"

exec bash -c "${STARTUP_COMMAND}"
