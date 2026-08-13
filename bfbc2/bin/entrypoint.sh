#!/bin/bash

set -Eeuo pipefail

cd /home/container

export DISPLAY="${DISPLAY:-:0}"
export WINEPREFIX="${WINEPREFIX:-/home/container/.wine_bfbc2}"
export WINEARCH="${WINEARCH:-win32}"
export WINEDEBUG="${WINEDEBUG:--all}"

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

ensure_wine_prefix() {
    if [[ ! -d "${WINEPREFIX}" || ! -f "${WINEPREFIX}/system.reg" ]]; then
        log "Initializing Wine prefix: ${WINEPREFIX}"
        xvfb-run -a -s "-screen 0 ${DISPLAY_WIDTH:-1280}x${DISPLAY_HEIGHT:-720}x${DISPLAY_DEPTH:-24}" wineboot --init
    fi
}

install_mono_if_needed() {
    if [[ "${INSTALL_WINE_MONO:-1}" != "1" ]]; then
        return 0
    fi

    local mono_installed=0
    if [[ -d "${WINEPREFIX}/drive_c/windows/mono" ]] || [[ -f "${WINEPREFIX}/winetricks.log" ]] && grep -Eq '(^| )mono( |$)' "${WINEPREFIX}/winetricks.log" 2>/dev/null; then
        mono_installed=1
    fi

    if [[ "${mono_installed}" == "1" ]]; then
        log "Wine Mono already present in prefix."
        return 0
    fi

    local mono_url="${WINE_MONO_URL:-https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.msi}"
    local mono_msi="${WINE_MONO_MSI:-/tmp/wine-mono.msi}"

    if [[ -f "${mono_msi}" ]]; then
        log "Installing Wine Mono from local MSI: ${mono_msi}"
    else
        log "Downloading Wine Mono from: ${mono_url}"
        wget -O "${mono_msi}" "${mono_url}"
    fi

    log "Installing Wine Mono into prefix"
    xvfb-run -a -s "-screen 0 ${DISPLAY_WIDTH:-1280}x${DISPLAY_HEIGHT:-720}x${DISPLAY_DEPTH:-24}" \
        wine msiexec /i "${mono_msi}" /qn
}

ensure_winefonts() {
    if [[ "${INSTALL_WINE_FONTS:-1}" != "1" ]]; then
        return 0
    fi

    if [[ -f "${WINEPREFIX}/drive_c/windows/Fonts/arial.ttf" ]]; then
        return 0
    fi

    log "Installing core Windows fonts"
    xvfb-run -a -s "-screen 0 ${DISPLAY_WIDTH:-1280}x${DISPLAY_HEIGHT:-720}x${DISPLAY_DEPTH:-24}" \
        winetricks -q corefonts
}

install_extras() {
    if [[ "${INSTALL_BFBC2_COMPONENTS:-1}" != "1" ]]; then
        return 0
    fi

    log "Installing BFBC2 runtime components"
    xvfb-run -a -s "-screen 0 ${DISPLAY_WIDTH:-1280}x${DISPLAY_HEIGHT:-720}x${DISPLAY_DEPTH:-24}" \
        winetricks -q \
            dinput8 \
            vcrun2005 \
            vcrun2008 \
            vcrun2010
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
ensure_wine_prefix
install_winefonts
install_extras
install_mono_if_needed

STARTUP_COMMAND="$(resolve_startup)"
log "Running:"
log "${STARTUP_COMMAND}"

exec bash -c "${STARTUP_COMMAND}"