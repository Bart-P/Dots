#!/bin/sh

DEVICE=$(ls /dev/v4l/by-id/*Logitech*StreamCam*video-index0 2>/dev/null | head -n 1)

if [ -z "$DEVICE" ]; then
  echo "StreamCam not found."
  exit 1
fi

echo "Using $DEVICE"

v4l2-ctl -d "$DEVICE" -c auto_exposure=1
v4l2-ctl -d "$DEVICE" -c exposure_time_absolute=200
v4l2-ctl -d "$DEVICE" -c gain=60
v4l2-ctl -d "$DEVICE" -c sharpness=150
v4l2-ctl -d "$DEVICE" -c focus_automatic_continuous=1
v4l2-ctl -d "$DEVICE" -c power_line_frequency=1
