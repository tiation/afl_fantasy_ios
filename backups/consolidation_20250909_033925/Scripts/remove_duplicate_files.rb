#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = File.expand_path('../AFLFantasy.xcodeproj', File.dirname(__FILE__))
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'AFLFantasy' }

# Get all build phases
compile_phases = target.build_phases.select { |phase| phase.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase) }

compile_phases.each do |phase|
  # Track files we've seen
  seen_files = {}
  
  # Go through files in reverse order (to keep most recent)
  phase.files.reverse.each do |build_file|
    next unless build_file.file_ref
    
    file_path = build_file.file_ref.real_path.to_s
    if seen_files[file_path]
      # Remove duplicate
      phase.remove_build_file(build_file)
    else
      # Mark as seen
      seen_files[file_path] = true
    end
  end
end

# Remove any disabled files that we cleaned up
files_to_remove = [
  'AFLFantasyApp.swift.backup',
  'IntegratedAFLFantasyApp.swift',
  'ContentView.swift.disabled',
  'EnhancedDashboardView.swift.disabled', 
  'IntelligentTradesView.swift.disabled',
  'UpdatedAFLFantasyApp.swift.disabled'
]

# Remove files from project
files_to_remove.each do |filename|
  project.files.each do |file|
    if file.path == filename
      file.remove_from_project
    end
  end
end

# Save changes
project.save
