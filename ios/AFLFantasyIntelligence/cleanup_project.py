#!/usr/bin/env python3

import re
import os

def remove_file_references():
    project_file = "AFL Fantasy Intelligence.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return
    
    # Files to remove
    files_to_remove = [
        "MissingServices.swift",
        "Alert.swift"
    ]
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Store original content
    original_content = content
    
    # Find and collect all file reference IDs for the files we want to remove
    file_ids_to_remove = []
    
    for file_name in files_to_remove:
        # Find file reference entries
        pattern = r'([A-Z0-9]{24})\s*\/\*\s*' + re.escape(file_name) + r'\s*\*\/\s*=\s*\{[^}]*\};'
        matches = re.finditer(pattern, content)
        for match in matches:
            file_id = match.group(1)
            file_ids_to_remove.append(file_id)
            print(f"Found file reference for {file_name}: {file_id}")
    
    # Remove file reference entries
    for file_name in files_to_remove:
        pattern = r'[A-Z0-9]{24}\s*\/\*\s*' + re.escape(file_name) + r'\s*\*\/\s*=\s*\{[^}]*\};\n'
        content = re.sub(pattern, '', content)
        print(f"Removed file reference for {file_name}")
    
    # Remove build file entries that reference these files
    for file_id in file_ids_to_remove:
        # Remove build file entries
        pattern = r'[A-Z0-9]{24}\s*\/\*\s*' + file_id + r'[^\/]*\/\*[^}]*\};\n'
        content = re.sub(pattern, '', content)
        
        # Remove from PBXBuildFile references
        pattern = r'[A-Z0-9]{24}\s*\/\*[^\/]*' + file_id + r'[^}]*\};\n'
        content = re.sub(pattern, '', content)
    
    # Remove from PBXGroup children arrays
    for file_id in file_ids_to_remove:
        # Pattern to match file references in children arrays
        pattern = r',?\s*' + file_id + r'\s*\/\*[^\/]*\*\/,?'
        content = re.sub(pattern, '', content)
        
        # Clean up any double commas or trailing commas
        content = re.sub(r',\s*,', ',', content)
        content = re.sub(r',(\s*\)\s*;)', r'\1', content)
        content = re.sub(r'\(\s*,', '(', content)
    
    # Remove from PBXSourcesBuildPhase
    for file_id in file_ids_to_remove:
        pattern = r',?\s*[A-Z0-9]{24}\s*\/\*[^\/]*' + file_id + r'[^\/]*\*\/,?'
        content = re.sub(pattern, '', content)
        
        # Clean up any double commas or trailing commas
        content = re.sub(r',\s*,', ',', content)
        content = re.sub(r',(\s*\)\s*;)', r'\1', content)
        content = re.sub(r'\(\s*,', '(', content)
    
    # Only write if content changed
    if content != original_content:
        # Backup original
        backup_file = project_file + ".backup2"
        with open(backup_file, 'w') as f:
            f.write(original_content)
        print(f"Backed up original to {backup_file}")
        
        # Write cleaned content
        with open(project_file, 'w') as f:
            f.write(content)
        print("Project file cleaned successfully!")
    else:
        print("No changes needed in project file")

if __name__ == "__main__":
    remove_file_references()
