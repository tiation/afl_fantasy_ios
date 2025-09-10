#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    """Generate a 24-character UUID for Xcode project file"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_filter_files_to_xcode_project():
    project_file = "AFL Fantasy Intelligence.xcodeproj/project.pbxproj"
    
    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Files to add
    files_to_add = [
        {
            'name': 'FilterTypes.swift',
            'path': 'Sources/Core/Filters/FilterTypes.swift'
        },
        {
            'name': 'AFLTeams.swift', 
            'path': 'Sources/Core/Filters/AFLTeams.swift'
        },
        {
            'name': 'AdvancedFilteringService.swift',
            'path': 'Sources/Core/Filters/AdvancedFilteringService.swift'
        },
        {
            'name': 'DSExtensions.swift',
            'path': 'Sources/Core/DesignSystem/DSExtensions.swift'
        }
    ]
    
    # Generate UUIDs for each file
    file_refs = {}
    build_files = {}
    
    for file_info in files_to_add:
        file_refs[file_info['name']] = generate_uuid()
        build_files[file_info['name']] = generate_uuid()
    
    # Generate UUID for Filters group
    filters_group_uuid = generate_uuid()
    
    # Add PBXFileReference entries
    file_ref_section = ""
    for file_info in files_to_add:
        file_ref_section += f"\t\t{file_refs[file_info['name']]} /* {file_info['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_info['name']}; sourceTree = \"<group>\"; }};\n"
    
    # Add PBXBuildFile entries  
    build_file_section = ""
    for file_info in files_to_add:
        build_file_section += f"\t\t{build_files[file_info['name']]} /* {file_info['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[file_info['name']]} /* {file_info['name']} */; }};\n"
    
    # Add file references to the PBXFileReference section
    file_ref_pattern = r"(/* End PBXFileReference section */)"
    content = re.sub(file_ref_pattern, f"{file_ref_section}\\1", content)
    
    # Add build files to the PBXBuildFile section
    build_file_pattern = r"(/* End PBXBuildFile section */)"
    content = re.sub(build_file_pattern, f"{build_file_section}\\1", content)
    
    # Create Filters group under Core
    filters_group = f"""\t\t{filters_group_uuid} /* Filters */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{file_refs['FilterTypes.swift']} /* FilterTypes.swift */,
\t\t\t\t{file_refs['AFLTeams.swift']} /* AFLTeams.swift */,
\t\t\t\t{file_refs['AdvancedFilteringService.swift']} /* AdvancedFilteringService.swift */,
\t\t\t);
\t\t\tpath = Filters;
\t\t\tsourceTree = "<group>";
\t\t}};
"""
    
    # Add group before the end of PBXGroup section
    group_pattern = r"(/* End PBXGroup section */)"
    content = re.sub(group_pattern, f"{filters_group}\\1", content)
    
    # Find and add Filters group to Core group
    # This is a simplified approach - may need adjustment based on actual project structure
    core_group_pattern = r"(/\* Core \*/ = \{[^}]+children = \([^)]+)(\s+\);)"
    filters_addition = f"\n\t\t\t\t{filters_group_uuid} /* Filters */,"
    content = re.sub(core_group_pattern, f"\\1{filters_addition}\\2", content)
    
    # Add DSExtensions to DesignSystem group (simplified approach)
    design_system_pattern = r"(/\* DesignSystem \*/ = \{[^}]+children = \([^)]+)(\s+\);)"
    ds_extension_addition = f"\n\t\t\t\t{file_refs['DSExtensions.swift']} /* DSExtensions.swift */,"
    content = re.sub(design_system_pattern, f"\\1{ds_extension_addition}\\2", content)
    
    # Add build files to the main target sources
    sources_pattern = r"(/\* Sources \*/ = \{[^}]+files = \([^)]+)(\s+\);)"
    sources_addition = ""
    for file_info in files_to_add:
        sources_addition += f"\n\t\t\t\t{build_files[file_info['name']]} /* {file_info['name']} in Sources */,"
    content = re.sub(sources_pattern, f"\\1{sources_addition}\\2", content)
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added the following filter files to Xcode project:")
    for file_info in files_to_add:
        print(f"   - {file_info['name']}")

if __name__ == "__main__":
    add_filter_files_to_xcode_project()
