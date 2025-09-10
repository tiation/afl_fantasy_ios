#!/usr/bin/env python3
import re
import random
import string

def generate_xcode_id():
    """Generate a random Xcode-style ID"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=24))

def add_files_to_xcode_project():
    project_file = "AFL Fantasy.xcodeproj/project.pbxproj"
    
    # Generate unique IDs
    keychain_manager_file_id = generate_xcode_id()
    avatar_loader_file_id = generate_xcode_id()
    afl_import_view_file_id = generate_xcode_id()
    afl_import_vm_file_id = generate_xcode_id()
    team_import_group_id = generate_xcode_id()
    
    # Build file IDs
    keychain_manager_build_id = generate_xcode_id()
    avatar_loader_build_id = generate_xcode_id()
    afl_import_view_build_id = generate_xcode_id()
    afl_import_vm_build_id = generate_xcode_id()
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Add PBXBuildFile entries (after the existing ones)
    build_files_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?)(/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if build_files_section:
        existing_build_files = build_files_section.group(1)
        new_build_files = f"""		{keychain_manager_build_id} /* KeychainManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {keychain_manager_file_id} /* KeychainManager.swift */; }};
		{avatar_loader_build_id} /* AvatarLoader.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {avatar_loader_file_id} /* AvatarLoader.swift */; }};
		{afl_import_view_build_id} /* AFLFantasyImportView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {afl_import_view_file_id} /* AFLFantasyImportView.swift */; }};
		{afl_import_vm_build_id} /* AFLFantasyImportViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {afl_import_vm_file_id} /* AFLFantasyImportViewModel.swift */; }};
"""
        content = content.replace(build_files_section.group(1), existing_build_files + new_build_files)
    
    # Add PBXFileReference entries (after the existing ones)
    file_refs_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?)(/\* End PBXFileReference section \*/)', content, re.DOTALL)
    if file_refs_section:
        existing_file_refs = file_refs_section.group(1)
        new_file_refs = f"""		{keychain_manager_file_id} /* KeychainManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = KeychainManager.swift; sourceTree = "<group>"; }};
		{avatar_loader_file_id} /* AvatarLoader.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AvatarLoader.swift; sourceTree = "<group>"; }};
		{afl_import_view_file_id} /* AFLFantasyImportView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AFLFantasyImportView.swift; sourceTree = "<group>"; }};
		{afl_import_vm_file_id} /* AFLFantasyImportViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AFLFantasyImportViewModel.swift; sourceTree = "<group>"; }};
"""
        content = content.replace(file_refs_section.group(1), existing_file_refs + new_file_refs)
    
    # Add TeamImport group to Features
    features_group_pattern = r'(6285B56AEDB46E4E27F65C83 /\* Features \*/ = \{[\s\S]*?children = \(\s*)([\s\S]*?)(\s*\);\s*path = Features;)'
    features_match = re.search(features_group_pattern, content)
    if features_match:
        existing_children = features_match.group(2)
        new_child = f"				{team_import_group_id} /* TeamImport */,\n"
        content = content.replace(features_match.group(2), existing_children + new_child)
    
    # Add TeamImport group definition
    team_management_group_pattern = r'(D9E64F29403CE287191AE6D2 /\* TeamManagement \*/ = \{[\s\S]*?\};)'
    team_management_match = re.search(team_management_group_pattern, content)
    if team_management_match:
        team_import_group = f"""		{team_import_group_id} /* TeamImport */ = {{
			isa = PBXGroup;
			children = (
				{afl_import_view_file_id} /* AFLFantasyImportView.swift */,
				{afl_import_vm_file_id} /* AFLFantasyImportViewModel.swift */,
			);
			path = TeamImport;
			sourceTree = "<group>";
		}};
"""
        content = content.replace(team_management_match.group(1), team_management_match.group(1) + "\n" + team_import_group)
    
    # Add files to Services group
    services_group_pattern = r'(6FE5B93CBDB3F03CDEDBE19A /\* Services \*/ = \{[\s\S]*?children = \(\s*)([\s\S]*?)(\s*7175B0F2309CE79D8D980866 /\* Alert \*/)'
    services_match = re.search(services_group_pattern, content)
    if services_match:
        existing_children = services_match.group(2)
        new_files = f"""				{keychain_manager_file_id} /* KeychainManager.swift */,
				{avatar_loader_file_id} /* AvatarLoader.swift */,
"""
        content = content.replace(services_match.group(2), existing_children + new_files)
    
    # Add build files to Sources build phase
    sources_phase_pattern = r'(8E60D4C88560ABD820943279 /\* Sources \*/ = \{[\s\S]*?files = \(\s*)([\s\S]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)'
    sources_match = re.search(sources_phase_pattern, content)
    if sources_match:
        existing_sources = sources_match.group(2)
        new_sources = f"""				{keychain_manager_build_id} /* KeychainManager.swift in Sources */,
				{avatar_loader_build_id} /* AvatarLoader.swift in Sources */,
				{afl_import_view_build_id} /* AFLFantasyImportView.swift in Sources */,
				{afl_import_vm_build_id} /* AFLFantasyImportViewModel.swift in Sources */,
"""
        content = content.replace(sources_match.group(2), existing_sources + new_sources)
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added files to Xcode project:")
    print("   - KeychainManager.swift")
    print("   - AvatarLoader.swift") 
    print("   - AFLFantasyImportView.swift")
    print("   - AFLFantasyImportViewModel.swift")
    print("   - Created TeamImport group")

if __name__ == "__main__":
    add_files_to_xcode_project()
