#!/usr/bin/env python3

import re
import uuid

def generate_xcode_uuid():
    """Generate a 24-character hex string for Xcode UUIDs"""
    return uuid.uuid4().hex[:24].upper()

def add_files_to_xcode_project():
    project_path = "AFL Fantasy Intelligence.xcodeproj/project.pbxproj"
    
    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Generate UUIDs for the new files
    openai_service_uuid = generate_xcode_uuid()
    keychain_service_uuid = generate_xcode_uuid()
    ai_settings_view_uuid = generate_xcode_uuid()
    ai_recommendation_detail_view_uuid = generate_xcode_uuid()
    
    # Build file UUIDs
    openai_build_uuid = generate_xcode_uuid()
    keychain_build_uuid = generate_xcode_uuid() 
    ai_settings_build_uuid = generate_xcode_uuid()
    ai_recommendation_build_uuid = generate_xcode_uuid()
    
    # Group UUIDs
    core_ai_group_uuid = generate_xcode_uuid()
    core_security_group_uuid = generate_xcode_uuid()
    
    # Add PBXBuildFile entries
    build_file_section = re.search(r'(\/\* Begin PBXBuildFile section \*\/\n)(.*?)(\/\* End PBXBuildFile section \*\/)', content, re.DOTALL)
    if build_file_section:
        build_files = build_file_section.group(2)
        new_build_files = build_files + f"""\t\t{openai_build_uuid} /* OpenAIService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {openai_service_uuid} /* OpenAIService.swift */; }};
\t\t{keychain_build_uuid} /* KeychainService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {keychain_service_uuid} /* KeychainService.swift */; }};
\t\t{ai_settings_build_uuid} /* AISettingsView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {ai_settings_view_uuid} /* AISettingsView.swift */; }};
\t\t{ai_recommendation_build_uuid} /* AIRecommendationDetailView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {ai_recommendation_detail_view_uuid} /* AIRecommendationDetailView.swift */; }};
"""
        content = content.replace(build_file_section.group(0), 
                                  f"/* Begin PBXBuildFile section */\n{new_build_files}/* End PBXBuildFile section */")
    
    # Add PBXFileReference entries
    file_ref_section = re.search(r'(\/\* Begin PBXFileReference section \*\/\n)(.*?)(\/\* End PBXFileReference section \*\/)', content, re.DOTALL)
    if file_ref_section:
        file_refs = file_ref_section.group(2)
        new_file_refs = file_refs + f"""\t\t{openai_service_uuid} /* OpenAIService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OpenAIService.swift; sourceTree = "<group>"; }};
\t\t{keychain_service_uuid} /* KeychainService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = KeychainService.swift; sourceTree = "<group>"; }};
\t\t{ai_settings_view_uuid} /* AISettingsView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AISettingsView.swift; sourceTree = "<group>"; }};
\t\t{ai_recommendation_detail_view_uuid} /* AIRecommendationDetailView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AIRecommendationDetailView.swift; sourceTree = "<group>"; }};
"""
        content = content.replace(file_ref_section.group(0), 
                                  f"/* Begin PBXFileReference section */\n{new_file_refs}/* End PBXFileReference section */")
    
    # Add Core/AI and Core/Security groups to PBXGroup section, just before "/* End PBXGroup section */"
    group_end_match = re.search(r'(.*?)(\/\* End PBXGroup section \*\/)', content, re.DOTALL)
    if group_end_match:
        groups_content = group_end_match.group(1)
        new_groups = f"""{groups_content}\t\t{core_ai_group_uuid} /* AI */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{openai_service_uuid} /* OpenAIService.swift */,
\t\t\t);
\t\t\tpath = AI;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{core_security_group_uuid} /* Security */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{keychain_service_uuid} /* KeychainService.swift */,
\t\t\t);
\t\t\tpath = Security;
\t\t\tsourceTree = "<group>";
\t\t}};
"""
        content = content.replace(group_end_match.group(0), f"{new_groups}/* End PBXGroup section */")
    
    # Update Core group to include AI and Security subgroups
    core_group_pattern = r'(\t\t[A-F0-9]+ \/\* Core \*\/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\t\t\t\);\n\t\t\tpath = Core;\n\t\t\tsourceTree = "<group>";\n\t\t\};)'
    core_group_match = re.search(core_group_pattern, content, re.DOTALL)
    if core_group_match:
        core_children = core_group_match.group(2)
        new_core_children = core_children + f"\t\t\t\t{core_ai_group_uuid} /* AI */,\n\t\t\t\t{core_security_group_uuid} /* Security */,\n"
        content = content.replace(core_group_match.group(0), 
                                  f"{core_group_match.group(1)}{new_core_children}{core_group_match.group(3)}")
    
    # Update Features/AI group to include the UI files
    ai_features_pattern = r'(\t\t[A-F0-9]+ \/\* AI \*\/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)(.*?)(\t\t\t\);\n\t\t\tpath = AI;\n\t\t\tsourceTree = "<group>";\n\t\t\};)'
    ai_features_match = re.search(ai_features_pattern, content, re.DOTALL)
    if ai_features_match:
        ai_children = ai_features_match.group(2)
        new_ai_children = ai_children + f"\t\t\t\t{ai_settings_view_uuid} /* AISettingsView.swift */,\n\t\t\t\t{ai_recommendation_detail_view_uuid} /* AIRecommendationDetailView.swift */,\n"
        content = content.replace(ai_features_match.group(0), 
                                  f"{ai_features_match.group(1)}{new_ai_children}{ai_features_match.group(3)}")
    
    # Add files to Sources build phase
    sources_phase_pattern = r'(\t\tB7434DCC4A45DC236AEF4C8A \/\* Sources \*\/ = \{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = \(\n)(.*?)(\t\t\t\);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\};)'
    sources_match = re.search(sources_phase_pattern, content, re.DOTALL)
    if sources_match:
        sources_files = sources_match.group(2)
        new_sources_files = sources_files + f"\t\t\t\t{openai_build_uuid} /* OpenAIService.swift in Sources */,\n\t\t\t\t{keychain_build_uuid} /* KeychainService.swift in Sources */,\n\t\t\t\t{ai_settings_build_uuid} /* AISettingsView.swift in Sources */,\n\t\t\t\t{ai_recommendation_build_uuid} /* AIRecommendationDetailView.swift in Sources */,\n"
        content = content.replace(sources_match.group(0), 
                                  f"{sources_match.group(1)}{new_sources_files}{sources_match.group(3)}")
    
    # Write the updated project file
    with open(project_path, 'w') as f:
        f.write(content)
    
    print("Successfully added missing AI files to Xcode project:")
    print(f"  - OpenAIService.swift (Core/AI)")
    print(f"  - KeychainService.swift (Core/Security)")
    print(f"  - AISettingsView.swift (Features/AI)")
    print(f"  - AIRecommendationDetailView.swift (Features/AI)")

if __name__ == "__main__":
    add_files_to_xcode_project()
