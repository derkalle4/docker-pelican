#!/bin/bash

set -Eeuo pipefail

cd /home/container

export DISPLAY="${DISPLAY:-:0}"

INSTANCE_DIR="${INSTANCE_DIR:-/home/container/instance}"
LOG_WAIT_SECONDS="${LOG_WAIT_SECONDS:-10}"

SERVER_PID=""
TAIL_PID=""
XVFB_PID=""

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

cleanup_instance_artifacts() {
    rm -f "${INSTANCE_DIR}"/*.log "${INSTANCE_DIR}"/*.dmp 2>/dev/null || true
}

wait_for_instance_log() {
    local i count
    local -a logs

    for ((i = 1; i <= LOG_WAIT_SECONDS; i++)); do
        mapfile -t logs < <(find "${INSTANCE_DIR}" -maxdepth 1 -name '*.log' -type f 2>/dev/null | sort)
        count=${#logs[@]}
        if [[ "${count}" -eq 1 ]]; then
            printf '%s\n' "${logs[0]}"
            return 0
        fi
        sleep 1
    done

    return 1
}

# STARTUP runs under setsid, so SERVER_PID is the process-group leader.
# kill -- -PID signals the whole group (Frost + background helpers).
stop_server_group() {
    local pid="${1:-}"
    [[ -z "${pid}" ]] && return 0
    if ! kill -0 "${pid}" 2>/dev/null; then
        return 0
    fi

    kill -INT -- "-${pid}" 2>/dev/null || kill -INT "${pid}" 2>/dev/null || true

    local i
    for i in 1 2 3 4 5; do
        kill -0 "${pid}" 2>/dev/null || break
        sleep 0.2
    done

    if kill -0 "${pid}" 2>/dev/null; then
        kill -TERM -- "-${pid}" 2>/dev/null || kill -TERM "${pid}" 2>/dev/null || true
        sleep 0.5
    fi

    if kill -0 "${pid}" 2>/dev/null; then
        kill -KILL -- "-${pid}" 2>/dev/null || kill -KILL "${pid}" 2>/dev/null || true
    fi

    wait "${pid}" 2>/dev/null || true
    wineserver -k 2>/dev/null || true
}

cleanup() {
    if [[ -n "${TAIL_PID}" ]] && kill -0 "${TAIL_PID}" 2>/dev/null; then
        kill "${TAIL_PID}" 2>/dev/null || true
        wait "${TAIL_PID}" 2>/dev/null || true
    fi

    if [[ -n "${SERVER_PID}" ]]; then
        stop_server_group "${SERVER_PID}"
        SERVER_PID=""
    fi

    if [[ -n "${XVFB_PID}" ]] && kill -0 "${XVFB_PID}" 2>/dev/null; then
        kill "${XVFB_PID}" 2>/dev/null || true
        wait "${XVFB_PID}" 2>/dev/null || true
    fi
}

on_signal() {
    cleanup
    exit 130
}

trap cleanup EXIT
trap on_signal INT TERM

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

cleanup_instance_artifacts

STARTUP_COMMAND="$(resolve_startup)"
log "Running:"
log "${STARTUP_COMMAND}"

# Own session/process group so Ctrl+C can stop Frost and background helpers together.
setsid bash -c "${STARTUP_COMMAND}" &
SERVER_PID=$!

LOG_FILE=""
if LOG_FILE="$(wait_for_instance_log)"; then
    log "Tailing ${LOG_FILE}"
    tail -n +1 -F "${LOG_FILE}" &
    TAIL_PID=$!
else
    log "No single instance/*.log within ${LOG_WAIT_SECONDS}s; continuing without tail."
fi

set +e
wait "${SERVER_PID}"
EXIT_CODE=$?
set -e

if [[ -n "${TAIL_PID}" ]] && kill -0 "${TAIL_PID}" 2>/dev/null; then
    kill "${TAIL_PID}" 2>/dev/null || true
    wait "${TAIL_PID}" 2>/dev/null || true
    TAIL_PID=""
fi

SERVER_PID=""
exit "${EXIT_CODE}"
