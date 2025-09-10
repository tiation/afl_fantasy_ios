#!/usr/bin/env ruby

require 'fileutils'

# Path to the Xcode project file
project_path = "AFLFantasy.xcodeproj/project.pbxproj"

# Read the project file
content = File.read(project_path)

# Remove references to AFLFantasyApp.swift (keep SimpleAFLFantasyApp.swift)
# Remove file references
content.gsub!(/ "AFLFantasyApp\.swift".*?;/, "")
content.gsub!(/.*AFLFantasyApp\.swift.*\n/, "")

# Write back the cleaned content
File.write(project_path, content)

puts "Fixed Xcode project file by removing duplicate AFLFantasyApp.swift references"
