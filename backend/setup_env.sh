#!/bin/bash

# AFL Fantasy Environment Setup Script
# Sets up environment variables and configuration for scrapers

echo "🔧 Setting up AFL Fantasy environment..."

# Create .env file if it doesn't exist
ENV_FILE="/Users/tiaastor/workspace/10_projects/afl_fantasy_ios/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "📝 Creating .env file..."
    cat > "$ENV_FILE" << 'EOF'
# AFL Fantasy API Configuration
AFL_FANTASY_TEAM_ID=your_team_id_here
AFL_FANTASY_SESSION_COOKIE=your_session_cookie_here
AFL_FANTASY_API_TOKEN=your_api_token_here

# Server Configuration
FLASK_ENV=development
FLASK_DEBUG=false
FLASK_HOST=127.0.0.1
FLASK_PORT=9001

# Cache Configuration
CACHE_DURATION=300

# Scraper Configuration
SCRAPER_TIMEOUT=120
SCRAPER_USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
EOF
    echo "✅ Created .env file at $ENV_FILE"
else
    echo "✅ .env file already exists"
fi

# Set proper permissions
chmod 600 "$ENV_FILE"

# Check if .env is in .gitignore
GITIGNORE_FILE="/Users/tiaastor/workspace/10_projects/afl_fantasy_ios/.gitignore"
if ! grep -q "^\.env$" "$GITIGNORE_FILE" 2>/dev/null; then
    echo ".env" >> "$GITIGNORE_FILE"
    echo "✅ Added .env to .gitignore"
fi

echo "🔒 Environment configuration complete!"
echo "📝 Edit $ENV_FILE to add your actual AFL Fantasy credentials"
