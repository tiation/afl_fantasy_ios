# How to Find Website APIs

## Method 1: Browser Developer Tools
1. Open the website (e.g., AFL Fantasy)
2. Press F12 to open Developer Tools
3. Go to the Network tab
4. Filter by "XHR" or "Fetch"
5. Refresh the page or click around
6. Look for requests that return JSON data

### Example AFL Fantasy API Endpoints Found:
- `https://fantasy.afl.com.au/api/players/all`
- `https://fantasy.afl.com.au/api/fixtures/current`
- `https://fantasy.afl.com.au/api/teams/rankings`

## Method 2: Check Common API Patterns
Many sites follow predictable patterns:
- `/api/...`
- `/v1/...` or `/v2/...`
- `/data/...`
- `/json/...`
- `api.sitename.com`

## Method 3: Search Documentation
- Look for developer.sitename.com
- Check sitename.com/api
- Search GitHub for "sitename API"
- Google "sitename API documentation"

## Method 4: Inspect Mobile Apps
Mobile apps often use cleaner APIs:
1. Use a proxy tool like Charles or Fiddler
2. Route phone traffic through proxy
3. Watch API calls the app makes

## Method 5: Check JavaScript Files
1. View page source
2. Look for .js files
3. Search for "api", "endpoint", "fetch"
4. Often reveals API URLs

## AFL Fantasy Specific APIs
Based on network analysis, AFL Fantasy uses:
- Player data: `/classic/api/bootstrap-static/`
- Live scores: `/api/fixtures/gameweek/live/`
- Team data: `/api/my-team/{teamId}/`