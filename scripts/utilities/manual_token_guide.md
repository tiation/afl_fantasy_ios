# Manual AFL Fantasy Token Extraction Guide

Since automated login is blocked, follow these steps to extract your authentication tokens manually:

## Step 1: Login to AFL Fantasy
1. Open your browser and go to https://fantasy.afl.com.au
2. Login with your credentials normally

## Step 2: Open Developer Tools
1. Press F12 (or right-click → Inspect → Network tab)
2. Click on the "Network" tab
3. Make sure "All" or "XHR/Fetch" filter is selected

## Step 3: Navigate to Your Team
1. Click on your team or dashboard
2. Look for API calls in the Network tab that contain your team data

## Step 4: Find Your Team ID
Look for network requests with URLs like:
- `/api/teams/[NUMBER]` - The number is your team ID
- `/api/user/teams` - May contain your team ID in response

## Step 5: Extract Session Cookie
1. In Network tab, click on any successful API request
2. Look in "Request Headers" section
3. Find the "Cookie" header
4. Copy the entire cookie string

## Step 6: Test API Access
Try this URL in your browser while logged in:
`https://fantasy.afl.com.au/api/teams/YOUR_TEAM_ID`

If it returns JSON data, you have the right team ID.

## What I Need:
1. Your Team ID (number from the API URLs)
2. Your session cookie string
3. Any authorization headers you see in the requests

Once you provide these, I can fetch your real AFL Fantasy data for the dashboard.