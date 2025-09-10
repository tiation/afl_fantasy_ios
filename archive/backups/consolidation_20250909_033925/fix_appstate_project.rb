#!/usr/bin/env ruby

# Path to the Xcode project file
project_path = "AFLFantasy.xcodeproj/project.pbxproj"

# Read the project file
content = File.read(project_path)

# Remove references to the old AppState.swift
content.gsub!(/ "AppState\.swift".*?;/, "")
content.gsub!(/.*AppState\.swift.*\n/, "")

# Write back the cleaned content
File.write(project_path, content)

puts "Removed old AppState.swift references from Xcode project"
