#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    """Generate a 24-character UUID for Xcode project file"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_files_to_xcode_project():
    project_file = "AFL Fantasy Intelligence.xcodeproj/project.pbxproj"
    
    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Files to add with their paths
    files_to_add = [
        {
            'name': 'OpenAIService.swift',
            'path': 'Sources/Core/AI/OpenAIService.swift',
            'group': 'AI'  # Will be added to Core/AI group
        },
        {
            'name': 'KeychainService.swift', 
            'path': 'Sources/Core/Security/KeychainService.swift',
            'group': 'Security'  # New group under Core
        },
        {
            'name': 'AISettingsView.swift',
            'path': 'Sources/Features/AI/AISettingsView.swift',
            'group': 'AI'  # Features/AI group
        },
        {
            'name': 'AIRecommendationDetailView.swift',
            'path': 'Sources/Features/AI/AIRecommendationDetailView.swift', 
            'group': 'AI'  # Features/AI group
        }
    ]
    
    # Generate UUIDs for each file
    file_refs = {}
    build_files = {}
    
    for file_info in files_to_add:
        file_refs[file_info['name']] = generate_uuid()
        build_files[file_info['name']] = generate_uuid()
    
    # Generate UUID for Security group
    security_group_uuid = generate_uuid()
    ai_core_group_uuid = generate_uuid()
    
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
    
    # Create Security group under Core
    security_group = f"""		{security_group_uuid} /* Security */ = {{
			isa = PBXGroup;
			children = (
				{file_refs['KeychainService.swift']} /* KeychainService.swift */,
			);
			path = Security;
			sourceTree = "<group>";
		}};
"""
    
    # Create AI group under Core  
    ai_core_group = f"""		{ai_core_group_uuid} /* AI */ = {{
			isa = PBXGroup;
			children = (
				{file_refs['OpenAIService.swift']} /* OpenAIService.swift */,
			);
			path = AI;
			sourceTree = "<group>";
		}};
"""
    
    # Add groups before the end of PBXGroup section
    group_pattern = r"(/* End PBXGroup section */)"
    content = re.sub(group_pattern, f"{security_group}{ai_core_group}\\1", content)
    
    # Add Security and AI groups to Core group
    core_group_pattern = r"(7D2414AFE075C92F6D9BB0A8 /\* Core \*/ = \{[^}]+children = \([^)]+)(\s+\);)"
    content = re.sub(core_group_pattern, f"\\1\n\t\t\t\t{ai_core_group_uuid} /* AI */,\n\t\t\t\t{security_group_uuid} /* Security */,\\2", content)
    
    # Add AI files to existing AI group under Features
    ai_features_pattern = r"(61C8554E2810440545D4D88B /\* AI \*/ = \{[^}]+children = \([^)]+)(\s+\);)"
    ai_files_addition = f"\n\t\t\t\t{file_refs['AISettingsView.swift']} /* AISettingsView.swift */,\n\t\t\t\t{file_refs['AIRecommendationDetailView.swift']} /* AIRecommendationDetailView.swift */,"
    content = re.sub(ai_features_pattern, f"\\1{ai_files_addition}\\2", content)
    
    # Add build files to the main target sources
    sources_pattern = r"(B7434DCC4A45DC236AEF4C8A /\* Sources \*/ = \{[^}]+files = \([^)]+)(\s+\);)"
    sources_addition = ""
    for file_info in files_to_add:
        sources_addition += f"\n\t\t\t\t{build_files[file_info['name']]} /* {file_info['name']} in Sources */,"
    content = re.sub(sources_pattern, f"\\1{sources_addition}\\2", content)
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added the following files to Xcode project:")
    for file_info in files_to_add:
        print(f"   - {file_info['name']}")

if __name__ == "__main__":
    add_files_to_xcode_project()
