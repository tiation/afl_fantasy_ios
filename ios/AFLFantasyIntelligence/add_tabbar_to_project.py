#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    """Generate a 24-character UUID for Xcode project file"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_tabbar_to_xcode_project():
    project_file = "AFL Fantasy Intelligence.xcodeproj/project.pbxproj"
    
    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # File to add
    file_to_add = {
        'name': 'EnhancedFloatingTabBar.swift',
        'path': 'Sources/Core/DesignSystem/EnhancedFloatingTabBar.swift',
        'group': 'DesignSystem'
    }
    
    # Generate UUIDs
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    # Add PBXFileReference entry
    file_ref_entry = f"\t\t{file_ref_uuid} /* {file_to_add['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_to_add['name']}; sourceTree = \"<group>\"; }};\n"
    
    # Add PBXBuildFile entry
    build_file_entry = f"\t\t{build_file_uuid} /* {file_to_add['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_to_add['name']} */; }};\n"
    
    # Add file reference to the PBXFileReference section
    file_ref_pattern = r"(/* End PBXFileReference section */)"
    content = re.sub(file_ref_pattern, f"{file_ref_entry}\\1", content)
    
    # Add build file to the PBXBuildFile section
    build_file_pattern = r"(/* End PBXBuildFile section */)"
    content = re.sub(build_file_pattern, f"{build_file_entry}\\1", content)
    
    # Find and add to DesignSystem group (we'll add it to existing DesignSystem group)
    # First try to find existing DesignSystem group pattern
    design_system_pattern = r"(/\* DesignSystem \*/ = \{[^}]+children = \([^)]+)(\s+\);)"
    
    if re.search(design_system_pattern, content):
        # Add to existing DesignSystem group
        design_system_addition = f"\n\t\t\t\t{file_ref_uuid} /* {file_to_add['name']} */,"
        content = re.sub(design_system_pattern, f"\\1{design_system_addition}\\2", content)
    else:
        print("⚠️ Could not find DesignSystem group pattern. Adding to first group found.")
        # Fallback: add to first group we can find
        first_group_pattern = r"(isa = PBXGroup;[^}]+children = \([^)]+)(\s+\);)"
        first_group_addition = f"\n\t\t\t\t{file_ref_uuid} /* {file_to_add['name']} */,"
        content = re.sub(first_group_pattern, f"\\1{first_group_addition}\\2", content, count=1)
    
    # Add build file to the main target sources
    sources_pattern = r"(/\* Sources \*/ = \{[^}]+files = \([^)]+)(\s+\);)"
    sources_addition = f"\n\t\t\t\t{build_file_uuid} /* {file_to_add['name']} in Sources */,"
    content = re.sub(sources_pattern, f"\\1{sources_addition}\\2", content)
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print(f"✅ Successfully added {file_to_add['name']} to Xcode project")

if __name__ == "__main__":
    add_tabbar_to_xcode_project()
