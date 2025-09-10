#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = File.expand_path('../AFLFantasy.xcodeproj', File.dirname(__FILE__))
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'AFLFantasy' }

# Get the compile sources build phase
compile_phase = target.source_build_phase

# Track seen file paths
seen_files = {}

# Go through files in reverse order (to keep most recent)
compile_phase.files.reverse_each do |build_file|
  next unless build_file.file_ref

  file_path = build_file.file_ref.path
  if seen_files[file_path]
    # Remove duplicate
    compile_phase.remove_build_file(build_file)
  else
    seen_files[file_path] = true
  end
end

# Save changes
project.save

#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = File.expand_path('../AFLFantasy.xcodeproj', File.dirname(__FILE__))
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'AFLFantasy' }

# Get the compile sources build phase
compile_phase = target.source_build_phase

# Track seen file paths
seen_files = {}

# Go through files in reverse order (to keep most recent)
compile_phase.files.reverse_each do |build_file|
  next unless build_file.file_ref

  file_path = build_file.file_ref.path
  if seen_files[file_path]
    # Remove duplicate
    compile_phase.remove_build_file(build_file)
  else
    seen_files[file_path] = true
  end
end

# Save changes
project.save
