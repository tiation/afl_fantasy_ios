#!/usr/bin/env ruby

require 'securerandom'
require 'fileutils'

# Path to the Xcode project file
project_path = "AFLFantasy.xcodeproj/project.pbxproj"
file_path = "AFLFantasy/Models/AppState.swift"

# Read the project file
content = File.read(project_path)

# Generate UUIDs for the new file references
file_ref_uuid = SecureRandom.hex(12).upcase
build_file_uuid = SecureRandom.hex(12).upcase

# Get the file path and name
file_name = File.basename(file_path)
relative_path = file_path

# Add file reference in PBXFileReference section
file_ref_section = content[/\/\* Begin PBXFileReference section \*\/(.*?)\/\* End PBXFileReference section \*\//m, 1]
if file_ref_section
  new_file_ref = "\t\t#{file_ref_uuid} /* #{file_name} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"#{file_name}\"; sourceTree = \"<group>\"; };"
  content.sub!(/(\/\* End PBXFileReference section \*\/)/, "#{new_file_ref}\n\t\t\\1")
end

# Add build file in PBXBuildFile section  
build_file_section = content[/\/\* Begin PBXBuildFile section \*\/(.*?)\/\* End PBXBuildFile section \*\//m, 1]
if build_file_section
  new_build_file = "\t\t#{build_file_uuid} /* #{file_name} in Sources */ = {isa = PBXBuildFile; fileRef = #{file_ref_uuid} /* #{file_name} */; };"
  content.sub!(/(\/\* End PBXBuildFile section \*\/)/, "#{new_build_file}\n\t\t\\1")
end

# Add to group (find Models group)
models_group_match = content.match(/(\w+) \/\* Models \*\/ = \{.*?children = \((.*?)\);/m)
if models_group_match
  group_uuid = models_group_match[1]
  children_content = models_group_match[2]
  new_child_ref = "\t\t\t\t#{file_ref_uuid} /* #{file_name} */,"
  content.sub!(/(\w+ \/\* Models \*\/ = \{.*?children = \()(.*?)(\);)/m) do |match|
    "#{$1}#{$2}#{new_child_ref}\n#{$3}"
  end
end

# Add to compile sources build phase
sources_phase_match = content.match(/(\w+) \/\* Sources \*\/ = \{.*?files = \((.*?)\);/m)
if sources_phase_match
  files_content = sources_phase_match[2]  
  new_file_entry = "\t\t\t\t#{build_file_uuid} /* #{file_name} in Sources */,"
  content.sub!(/(\w+ \/\* Sources \*\/ = \{.*?files = \()(.*?)(\);)/m) do |match|
    "#{$1}#{$2}#{new_file_entry}\n#{$3}"
  end
end

# Write back the modified content
File.write(project_path, content)

puts "✅ Added AppState.swift to Xcode project"
