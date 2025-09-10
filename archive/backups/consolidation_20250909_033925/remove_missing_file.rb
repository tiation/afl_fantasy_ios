#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'AFLFantasy.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'AFLFantasy' }

# Find and remove the missing AppDataModels.swift reference
file_to_remove = 'AppDataModels.swift'

target.source_build_phase.files.each do |build_file|
  file_ref = build_file.file_ref
  if file_ref && file_ref.path && file_ref.path.include?(file_to_remove)
    puts "Removing #{file_ref.path} from target"
    build_file.remove_from_project
    file_ref.remove_from_project
  end
end

project.save
puts "Removed missing file reference from Xcode project"
