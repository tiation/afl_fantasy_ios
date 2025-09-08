#!/bin/bash

# List of files to remove from project.pbxproj
REMOVE_FILES=(
  "AFLAudioManager.swift"
  "AFLHapticsManager.swift"
  "Models/TabItem.swift"
  "Views/EnhancedDashboardView.swift"
  "Views/CaptainAnalysisView.swift"
  "Views/AdvancedCaptainAI.swift"
  "PerformanceMonitor.swift"
  "Views/IntelligentTradesView.swift"
  "Views/AdvancedCashCowTracker.swift"
  "Models/AppState.swift"
)

# Backup original project file
cp AFLFantasy.xcodeproj/project.pbxproj AFLFantasy.xcodeproj/project.pbxproj.bak

# Process each file
for file in "${REMOVE_FILES[@]}"; do
  echo "Removing references to $file"
  sed -i '' "/$(echo $file | sed 's/\//\\\//g')/d" AFLFantasy.xcodeproj/project.pbxproj
done
