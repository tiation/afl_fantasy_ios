require 'xcodeproj'

def remove_duplicate_file_references(project_path)
  project = Xcodeproj::Project.open(project_path)
  target = project.targets.first
  
  # Get all build phase that compiles sources
  source_build_phase = target.source_build_phase
  
  # Keep track of files we've seen
  seen_files = {}
  
  # Go through all build file references
  source_build_phase.files.each do |build_file|
    next unless build_file.file_ref
    
    path = build_file.file_ref.real_path.to_s
    
    if seen_files[path]
      # Remove duplicate
      source_build_phase.remove_build_file(build_file)
    else
      seen_files[path] = true
    end
  end

  project.save
end

remove_duplicate_file_references("AFLFantasy.xcodeproj")
