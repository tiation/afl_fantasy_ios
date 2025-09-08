#!/usr/bin/env ruby

require 'securerandom'

# Path to the Xcode project file
project_path = "AFLFantasy.xcodeproj/project.pbxproj"
file_path = "AFLFantasy/SimpleAFLFantasyApp.swift"

# Read the project file
content = File.read(project_path)

# Generate UUIDs for the new file references
file_ref_uuid = SecureRandom.hex(12).upcase
build_file_uuid = SecureRandom.hex(12).upcase

# Get the file path and name
file_name = File.basename(file_path)

# Add file reference in PBXFileReference section
new_file_ref = "\t\t#{file_ref_uuid} /* #{file_name} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = \"#{file_name}\"; path = \"#{file_path}\"; sourceTree = \"<group>\"; };"
content.sub!(/(\/\* End PBXFileReference section \*\/)/, "#{new_file_ref}\n\t\t\\1")

# Add build file in PBXBuildFile section  
new_build_file = "\t\t#{build_file_uuid} /* #{file_name} in Sources */ = {isa = PBXBuildFile; fileRef = #{file_ref_uuid} /* #{file_name} */; };"
content.sub!(/(\/\* End PBXBuildFile section \*\/)/, "#{new_build_file}\n\t\t\\1")

# Find AFLFantasy group and add file reference
group_pattern = /(\w+) \/\* AFLFantasy \*\/ = \{[^}]*children = \([^)]*\);/m
if content.match(group_pattern)
  content.sub!(group_pattern) do |match|
    match.sub(/(\);)$/, "\t\t\t\t#{file_ref_uuid} /* #{file_name} */,\n\t\t\t\\1")
  end
end

# Add to compile sources build phase
sources_pattern = /(\w+) \/\* Sources \*\/ = \{[^}]*files = \([^)]*\);/m
if content.match(sources_pattern)
  content.sub!(sources_pattern) do |match|
    match.sub(/(\);)$/, "\t\t\t\t#{build_file_uuid} /* #{file_name} in Sources */,\n\t\t\t\\1")
  end
end

# Write back the modified content
File.write(project_path, content)

puts "✅ Added SimpleAFLFantasyApp.swift to Xcode project"
