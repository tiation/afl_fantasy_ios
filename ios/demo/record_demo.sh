#!/bin/bash
set -euo pipefail

# Build and run demo target
xcrun simctl boot "iPhone 15"
xcrun xcodebuild -scheme "AFLFantasyApp" -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 15" \
  -configuration Debug demo/RunDemo.swift SYMROOT=build

# Wait for simulator and run demo
sleep 5
xcrun simctl launch booted com.afl.fantasy.demo

# Record 30s demo video
xcrun simctl io booted recordVideo --codec=h264 --force demo.mp4 --mask=ignored &
RECORD_PID=$!

# Wait for demo to complete
sleep 30
kill $RECORD_PID

# Convert to web-friendly format
ffmpeg -i demo.mp4 -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k \
  -movflags +faststart demo_web.mp4

echo "Demo video saved to demo_web.mp4"
