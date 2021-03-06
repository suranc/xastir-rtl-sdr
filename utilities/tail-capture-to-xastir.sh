#!/bin/bash

. $(dirname $0)/../.config

echo "---Loading APRS data from $1..."
while read line; do
  if [[ $line == APRS* ]]; then
    echo $line
    xastir_udp_client localhost 2023 $callsign $xastir_pass "${line:6}"
  fi
done < <(tail -f $1)
echo "-------------------------------"
