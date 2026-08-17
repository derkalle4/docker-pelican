#!/bin/bash
cd /home/container

## with the help of https://github.com/pelican-eggs/yolks/blob/master/wine/entrypoint.sh (many thanks!)

# info output
echo "Running on:"
[ -f /etc/debian_version ] && cat /etc/debian_version
[ -f /etc/timezone ] && echo "Current timezone: $(cat /etc/timezone)"

# Official SuperTuxKart Linux builds ship shared libraries next to the binary.
if [ -d /home/container/lib ]; then
    export LD_LIBRARY_PATH="/home/container/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# Dedicated servers have no display; allow override if a real X server is provided.
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-dummy}"

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e "running: ${MODIFIED_STARTUP}"

# Run the Server
bash -c "${MODIFIED_STARTUP}"
