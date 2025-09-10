#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project = Xcodeproj::Project.open('AFLFantasy.xcodeproj')

# Get the main target
target = project.targets.first

# Remove any references to deleted files
files_to_remove = [
  'ContentView.swift',
  'IntegratedAFLFantasyApp.swift'
]

files_to_remove.each do |filename|
  # Find and remove the reference
  file_ref = project.files.find { |f| f.path == filename }
  file_ref&.remove_from_project

  # Remove from build phases
  target.source_build_phase.files.each do |build_file|
    if build_file.file_ref && build_file.file_ref.path == filename
      target.source_build_phase.remove_build_file(build_file)
    end
  end
end

# Save changes
project.save

puts "Project file updated successfully"
