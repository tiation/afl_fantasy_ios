#!/usr/bin/env python3

import os
import subprocess
import sys

def find_swift_files():
    """Find all Swift files in the project."""
    swift_files = []
    for root, dirs, files in os.walk('.'):
        # Skip certain directories
        if any(skip in root for skip in ['.build', '.git', 'Archive', 'Tests']):
            continue
        
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))
    
    return swift_files

def add_files_to_project():
    """Add Swift files to the Xcode project."""
    project_file = "AFL Fantasy Intelligence.xcodeproj"
    
    # Find all Swift files
    swift_files = find_swift_files()
    
    print(f"Found {len(swift_files)} Swift files:")
    for file in swift_files:
        print(f"  {file}")
    
    # Build the project first to see what's missing
    print("\nBuilding project to check for missing files...")
    result = subprocess.run(['xcodebuild', '-scheme', 'AFL Fantasy Intelligence', '-destination', 'platform=iOS Simulator,name=iPhone 16 Pro', 'build'], 
                          capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ Build successful! All files are properly included.")
        return True
    else:
        print("❌ Build failed. Let's check what files need to be added...")
        print("Build errors:")
        print(result.stderr)
        return False

if __name__ == "__main__":
    if not add_files_to_project():
        print("\nTo manually add missing files to your Xcode project:")
        print("1. Open the project in Xcode")
        print("2. Right-click on the project root")
        print("3. Select 'Add Files to [Project]...'")
        print("4. Navigate to the missing files and add them")
        print("5. Make sure they're added to the correct target")
