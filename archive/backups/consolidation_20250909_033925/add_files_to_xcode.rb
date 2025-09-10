#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'AFLFantasy.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'AFLFantasy' }
raise 'AFLFantasy target not found' unless target

# Find the main group (where we'll add files)
main_group = project.main_group

# Files to add (relative to project root)
files_to_add = [
  # Core Services
  'AFLFantasy/Services/AFLFantasyDataService.swift',
  'AFLFantasy/Services/AFLFantasyToolsClient.swift', 
  'AFLFantasy/Services/AFLFantasyAPIClient.swift',
  'AFLFantasy/Services/KeychainManager.swift',
  
  # Core Infrastructure
  'AFLFantasy/Core/AFLFantasyError.swift',
  'AFLFantasy/Models/AppDataModels.swift',
  'AFLFantasy/Models/TabItem.swift',
  
  # Essential Views
  'AFLFantasy/Views/EnhancedDashboardView.swift',
  'AFLFantasy/Views/CaptainAnalysisView.swift',
  'AFLFantasy/Views/AdvancedCaptainAI.swift',
  'AFLFantasy/Views/IntelligentTradesView.swift',
  'AFLFantasy/Views/AdvancedCashCowTracker.swift'
]

files_to_add.each do |file_path|
  # Check if file exists
  full_path = File.join(Dir.pwd, file_path)
  unless File.exist?(full_path)
    puts "⚠️  File not found: #{file_path}"
    next
  end
  
  # Add file to project
  begin
    file_ref = main_group.new_file(file_path)
    target.add_file_references([file_ref])
    puts "✅ Added: #{file_path}"
  rescue => e
    puts "❌ Error adding #{file_path}: #{e.message}"
  end
end

# Save the project
project.save

puts "\n🎉 Project updated! You may need to clean and rebuild."
