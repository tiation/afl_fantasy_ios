#!/usr/bin/env python3
import re
import random
import string

def generate_xcode_id():
    """Generate a random Xcode-style ID"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=24))

def add_profile_to_xcode_project():
    project_file = "AFL Fantasy.xcodeproj/project.pbxproj"
    
    # Generate unique IDs
    profile_view_file_id = generate_xcode_id()
    edit_profile_view_file_id = generate_xcode_id()
    profile_group_id = generate_xcode_id()
    
    # Build file IDs
    profile_view_build_id = generate_xcode_id()
    edit_profile_view_build_id = generate_xcode_id()
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Add PBXBuildFile entries
    build_files_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?)(/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if build_files_section:
        existing_build_files = build_files_section.group(1)
        new_build_files = f"""		{profile_view_build_id} /* ProfileView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {profile_view_file_id} /* ProfileView.swift */; }};
		{edit_profile_view_build_id} /* EditProfileView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {edit_profile_view_file_id} /* EditProfileView.swift */; }};
"""
        content = content.replace(build_files_section.group(1), existing_build_files + new_build_files)
    
    # Add PBXFileReference entries
    file_refs_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?)(/\* End PBXFileReference section \*/)', content, re.DOTALL)
    if file_refs_section:
        existing_file_refs = file_refs_section.group(1)
        new_file_refs = f"""		{profile_view_file_id} /* ProfileView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileView.swift; sourceTree = "<group>"; }};
		{edit_profile_view_file_id} /* EditProfileView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EditProfileView.swift; sourceTree = "<group>"; }};
"""
        content = content.replace(file_refs_section.group(1), existing_file_refs + new_file_refs)
    
    # Add Profile group to Features
    features_group_pattern = r'(6285B56AEDB46E4E27F65C83 /\* Features \*/ = \{[\s\S]*?children = \(\s*)([\s\S]*?)(\s*\);\s*path = Features;)'
    features_match = re.search(features_group_pattern, content)
    if features_match:
        existing_children = features_match.group(2)
        new_child = f"				{profile_group_id} /* Profile */,\n"
        content = content.replace(features_match.group(2), existing_children + new_child)
    
    # Add Profile group definition
    team_import_group_pattern = r'(H2MV9PQKGEF23RDFIZNC9BAW /\* TeamImport \*/ = \{[\s\S]*?\};)'
    team_import_match = re.search(team_import_group_pattern, content)
    if team_import_match:
        profile_group = f"""		{profile_group_id} /* Profile */ = {{
			isa = PBXGroup;
			children = (
				{profile_view_file_id} /* ProfileView.swift */,
				{edit_profile_view_file_id} /* EditProfileView.swift */,
			);
			path = Profile;
			sourceTree = "<group>";
		}};
"""
        content = content.replace(team_import_match.group(1), team_import_match.group(1) + "\n" + profile_group)
    else:
        # Find any group definition and add after it
        any_group_pattern = r'(D9E64F29403CE287191AE6D2 /\* TeamManagement \*/ = \{[\s\S]*?\};)'
        any_group_match = re.search(any_group_pattern, content)
        if any_group_match:
            profile_group = f"""		{profile_group_id} /* Profile */ = {{
			isa = PBXGroup;
			children = (
				{profile_view_file_id} /* ProfileView.swift */,
				{edit_profile_view_file_id} /* EditProfileView.swift */,
			);
			path = Profile;
			sourceTree = "<group>";
		}};
"""
            content = content.replace(any_group_match.group(1), any_group_match.group(1) + "\n" + profile_group)
    
    # Add build files to Sources build phase
    sources_phase_pattern = r'(8E60D4C88560ABD820943279 /\* Sources \*/ = \{[\s\S]*?files = \(\s*)([\s\S]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_phase_pattern, content)
    if sources_match:
        existing_sources = sources_match.group(2)
        new_sources = f"""				{profile_view_build_id} /* ProfileView.swift in Sources */,
				{edit_profile_view_build_id} /* EditProfileView.swift in Sources */,
"""
        content = content.replace(sources_match.group(2), existing_sources + new_sources)
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added Profile files to Xcode project:")
    print("   - ProfileView.swift")
    print("   - EditProfileView.swift")
    print("   - Created Profile group")

if __name__ == "__main__":
    add_profile_to_xcode_project()
