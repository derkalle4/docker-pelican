#!/bin/bash
cd /home/container

## with the help of https://github.com/pelican-eggs/yolks/blob/master/wine/entrypoint.sh (many thanks!)

# info output
echo "Running on:"
echo "$(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# start xvfb
if [[ $XVFB == 1 ]]; then
    Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e "running: ${MODIFIED_STARTUP}"

# Run the Server
bash -c "${MODIFIED_STARTUP}"