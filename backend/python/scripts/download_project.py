"""
AFL Fantasy Manager Project Download Script

This simple script creates a Flask server that allows you to download
the entire project as a ZIP file.

Usage:
1. Run this script: python download_project.py
2. Open the URL shown in the console (usually http://localhost:8000)
3. Click the download button to get the ZIP file
"""

import os
import zipfile
import io
from flask import Flask, send_file, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    """Home page with download button"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>AFL Fantasy Manager - Download Project</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                text-align: center;
            }
            h1 {
                color: #4a5568;
            }
            .download-btn {
                display: inline-block;
                background-color: #4299e1;
                color: white;
                padding: 12px 24px;
                text-decoration: none;
                font-weight: bold;
                border-radius: 4px;
                margin-top: 20px;
                font-size: 18px;
            }
            .download-btn:hover {
                background-color: #3182ce;
            }
            .note {
                margin-top: 40px;
                font-size: 14px;
                color: #718096;
                text-align: left;
            }
        </style>
    </head>
    <body>
        <h1>AFL Fantasy Manager Project Download</h1>
        <p>Click the button below to download the entire project as a ZIP file.</p>
        <a href="/download" class="download-btn">Download Project</a>
        
        <div class="note">
            <p><strong>After downloading:</strong></p>
            <ol>
                <li>Extract the ZIP file</li>
                <li>Create a GitHub repository</li>
                <li>Upload the files to GitHub using the GitHub web interface or Git commands:
                    <pre>
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
                    </pre>
                </li>
                <li>To clone the repository, use: <code>git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git</code></li>
            </ol>
        </div>
    </body>
    </html>
    """
    return render_template_string(html)

@app.route('/download')
def download():
    """Create and send a ZIP file with the project contents"""
    memory_file = io.BytesIO()
    
    excluded_paths = [
        '.git', '__pycache__', 'node_modules', '.env',
        'download_project.py', 'venv', 'env'
    ]
    
    with zipfile.ZipFile(memory_file, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk('.'):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in excluded_paths]
            
            for file in files:
                file_path = os.path.join(root, file)
                
                # Skip the file if it's in an excluded path
                if any(excluded in file_path for excluded in excluded_paths):
                    continue
                
                # Add the file to the ZIP
                arcname = file_path[2:]  # Remove './' from the beginning
                zf.write(file_path, arcname)
    
    memory_file.seek(0)
    return send_file(
        memory_file,
        mimetype='application/zip',
        as_attachment=True,
        download_name='afl_fantasy_manager.zip'
    )

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    print(f"Starting download server on port {port}")
    print(f"Open this URL in your browser: http://localhost:{port}")
    app.run(host='0.0.0.0', port=port)