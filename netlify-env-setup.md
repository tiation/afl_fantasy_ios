# Netlify Environment Variables Setup

## Required Environment Variables

### Essential Configuration
```
NODE_ENV=production
```

### Database Configuration (if needed for build-time data fetching)
```
DATABASE_URL=your_production_database_url
```

### API Keys (add only if required during build)
```
OPENAI_API_KEY=your_openai_api_key
GEMINI_API_KEY=your_gemini_api_key
DFS_AUSTRALIA_API_KEY=your_dfs_api_key
CHAMPION_DATA_API_KEY=your_champion_data_api_key
```

### Security (if needed for build process)
```
SESSION_SECRET=your_secure_session_secret
JWT_SECRET=your_secure_jwt_secret
```

## How to Add Environment Variables in Netlify:

1. Go to your Netlify site dashboard
2. Navigate to **Site settings**
3. Click **Build & deploy** in the left sidebar
4. Scroll down to **Environment variables**
5. Click **Add variable** for each environment variable
6. Enter the key-value pairs from above

## Important Notes:
- Only add variables that are actually used during the build process
- Keep sensitive keys secure and never commit them to your repository
- Some variables (like database connections) may not be needed for a frontend-only build
