require 'xcodeproj'

def clean_project(project_path)
  project = Xcodeproj::Project.open(project_path)
  main_target = project.targets.first
  
  # Get all source files in the project
  main_target.source_build_phase.files.to_a.each do |build_file|
    # Skip if no file reference
    next unless build_file.file_ref && build_file.file_ref.path
    
    # Check if there are other build files with the same path
    duplicates = main_target.source_build_phase.files.select do |other_build_file|
      other_build_file != build_file && 
      other_build_file.file_ref && 
      other_build_file.file_ref.path == build_file.file_ref.path
    end
    
    # Remove duplicates if any found
    duplicates.each do |dup|
      main_target.source_build_phase.remove_build_file(dup)
    end
  end

  project.save
end

clean_project("AFLFantasy.xcodeproj")
