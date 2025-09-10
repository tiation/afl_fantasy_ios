#!/usr/bin/env ruby

project_dir = File.dirname(__FILE__)
project_file = File.join(project_dir, "AFLFantasy.xcodeproj", "project.pbxproj")

# Read project file
content = File.read(project_file)

# Replace old file references with new ones
old_filenames = [
  'ContentView.swift',
  'IntegratedAFLFantasyApp.swift'
]

old_filenames.each do |filename|
  content.gsub!(/[A-F0-9]{24} \/\* #{filename} \*\/.*$/, '')
  content.gsub!(/#{filename} in Sources.*$/, '')
end

# Write back the changes
File.write(project_file, content)

puts "Project file updated successfully"
