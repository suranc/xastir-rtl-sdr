#!/bin/bash

cd $(dirname $0)

# Start xastir in background
xastir &

# Wait for udp server to be available (assume default port)
timeout 1 bash -c 'cat < /dev/null > /dev/tcp/localhost/2023'
retries=10
sleep 0.1
while [[ $? != 0 ]] && [[ $retries -gt 0 ]]
do
    retries=$((retries - 1)); sleep 0.1
    timeout 1 bash -c 'cat < /dev/null > /dev/tcp/localhost/2023'
done

# Exit if we hit max amount of retries
if [[ $retries == 0 ]]
then
    echo "Timeout waiting for port 2023 to become available on localhost"
fi

# Load all files in captured directory to xastir
for capture in $(ls ./captures)
do
    ./utilities/load-capture-to-xastir.sh captures/$capture
done

# Start capturing new data in the background
./utilities/capture-aprs-data.sh ./captures/aprs_data_$(date +%Y%m%d_%H%M%S) &

# Tail latest capture file to xastir.sh
./tail-capture-to-xastir.sh ./capture/$(echo $(ls captures/) | tail -n 1)