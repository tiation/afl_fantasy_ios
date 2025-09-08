#!/usr/bin/env python3
"""
Analyze Scraped AFL Fantasy Data
Quick analysis of the collected player data
"""

import os
import pandas as pd
from pathlib import Path

def analyze_scraped_data():
    """Analyze the scraped data and generate a summary report"""
    print("📊 Analyzing scraped AFL Fantasy data...")
    
    data_folder = "dfs_player_summary"
    
    if not os.path.exists(data_folder):
        print(f"❌ Data folder not found: {data_folder}")
        return
    
    # Find all Excel files
    excel_files = list(Path(data_folder).glob("*.xlsx"))
    print(f"📁 Found {len(excel_files)} Excel files")
    
    if len(excel_files) == 0:
        print("❌ No data files found")
        return
    
    # Analyze files
    file_analysis = []
    total_sheets = 0
    total_rows = 0
    
    print("\n🔍 Analyzing files...")
    for i, file_path in enumerate(excel_files):
        try:
            # Read Excel file to get sheet info
            xl_file = pd.ExcelFile(file_path)
            sheets = xl_file.sheet_names
            
            file_rows = 0
            for sheet_name in sheets:
                df = pd.read_excel(file_path, sheet_name=sheet_name)
                file_rows += len(df)
            
            file_analysis.append({
                'filename': file_path.name,
                'sheets': len(sheets),
                'total_rows': file_rows,
                'sheet_names': ', '.join(sheets)
            })
            
            total_sheets += len(sheets)
            total_rows += file_rows
            
            # Show progress every 20 files
            if (i + 1) % 20 == 0:
                print(f"📊 Processed {i+1}/{len(excel_files)} files...")
                
        except Exception as e:
            print(f"⚠️ Error reading {file_path.name}: {e}")
            file_analysis.append({
                'filename': file_path.name,
                'sheets': 0,
                'total_rows': 0,
                'sheet_names': 'ERROR'
            })
    
    # Create analysis DataFrame
    analysis_df = pd.DataFrame(file_analysis)
    
    # Generate summary statistics
    print("\n" + "="*60)
    print("📊 SCRAPING ANALYSIS SUMMARY")
    print("="*60)
    print(f"📁 Total files: {len(excel_files)}")
    print(f"📋 Total sheets: {total_sheets}")
    print(f"📊 Total data rows: {total_rows:,}")
    print(f"📈 Average sheets per file: {total_sheets/len(excel_files):.1f}")
    print(f"📈 Average rows per file: {total_rows/len(excel_files):.1f}")
    
    # Sheet distribution
    sheet_counts = analysis_df['sheets'].value_counts().sort_index()
    print(f"\n📋 Sheet count distribution:")
    for sheets, count in sheet_counts.items():
        print(f"   {sheets} sheets: {count} files")
    
    # Files with most data
    top_files = analysis_df.nlargest(10, 'total_rows')
    print(f"\n🏆 Top 10 files by data volume:")
    for i, (_, row) in enumerate(top_files.iterrows(), 1):
        print(f"   {i:2d}. {row['filename']:<25} - {row['total_rows']:,} rows, {row['sheets']} sheets")
    
    # Files with errors
    error_files = analysis_df[analysis_df['sheet_names'] == 'ERROR']
    if len(error_files) > 0:
        print(f"\n❌ Files with errors: {len(error_files)}")
        for _, row in error_files.iterrows():
            print(f"   - {row['filename']}")
    
    # Save analysis report
    report_file = "scraping_analysis_report.xlsx"
    analysis_df.to_excel(report_file, index=False)
    print(f"\n💾 Detailed analysis saved to: {report_file}")
    
    # Sample some actual data
    print(f"\n📋 Sample data from first few files:")
    sample_files = excel_files[:3]
    for file_path in sample_files:
        try:
            print(f"\n📄 {file_path.name}:")
            xl_file = pd.ExcelFile(file_path)
            for sheet_name in xl_file.sheet_names[:2]:  # First 2 sheets only
                df = pd.read_excel(file_path, sheet_name=sheet_name)
                print(f"   📋 {sheet_name}: {df.shape[0]} rows x {df.shape[1]} cols")
                if len(df) > 0:
                    print(f"      Columns: {', '.join(df.columns[:5].tolist())}{'...' if len(df.columns) > 5 else ''}")
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print(f"\n🎉 Analysis complete!")

if __name__ == "__main__":
    analyze_scraped_data()
