#!/bin/bash

# Compress the demo video for web
ffmpeg -i ~/Desktop/demo.mov \
  -c:v libx264 -preset medium -crf 23 \
  -c:a aac -b:a 128k \
  -movflags +faststart \
  ~/Desktop/demo_web.mp4

echo "Compressed video saved to ~/Desktop/demo_web.mp4"
