#!/bin/bash -x
DEVICE_IDS=`conch -j ws GLOBAL devices | jq '.[] | select(.health | contains("PASS")) | .id' | sort -R | head -n 10 | tr -d '"'`

for DEVICE in $DEVICE_IDS
do
    conch api get "/device/$DEVICE" > t/_assets/conch-device-$DEVICE.json
done
