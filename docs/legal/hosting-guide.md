# Legal Documents Hosting Guide

This guide explains how to host the legal documents (privacy.md and terms.md) so they're accessible at the URLs referenced in the iOS app.

## Current URLs in App

The app settings view links to:
- Privacy Policy: `https://afl.ai/privacy`
- Terms of Service: `https://afl.ai/terms`

## Option 1: GitHub Pages (Recommended)

1. **Enable GitHub Pages:**
   ```bash
   # In your repository settings → Pages
   # Set source to "Deploy from a branch" 
   # Choose "main" branch and "/docs" folder
   ```

2. **Create redirect files:**
   ```bash
   # Create docs/_redirects (for Netlify compatibility)
   echo "/privacy   /privacy.md   200" > docs/_redirects
   echo "/terms     /terms.md     200" >> docs/_redirects
   
   # Or create HTML redirects
   mkdir -p docs/privacy docs/terms
   echo '<meta http-equiv="refresh" content="0;URL=../privacy.md">' > docs/privacy/index.html
   echo '<meta http-equiv="refresh" content="0;URL=../terms.md">' > docs/terms/index.html
   ```

3. **Update DNS (if using custom domain):**
   - Point `afl.ai` to your GitHub Pages URL
   - Or use temporary GitHub Pages URL: `https://yourusername.github.io/afl_fantasy_ios/privacy`

## Option 2: Netlify (Simple)

1. **Deploy to Netlify:**
   ```bash
   # Connect your GitHub repo to Netlify
   # Set build command: echo "Building docs"
   # Set publish directory: docs
   ```

2. **Add _redirects file:**
   ```bash
   # docs/_redirects
   /privacy    /privacy.md    200
   /terms      /terms.md      200
   ```

3. **Custom domain:** Point `afl.ai` to Netlify

## Option 3: Vercel

1. **Deploy with vercel.json:**
   ```json
   {
     "rewrites": [
       { "source": "/privacy", "destination": "/privacy.md" },
       { "source": "/terms", "destination": "/terms.md" }
     ]
   }
   ```

## Temporary Solution

While setting up hosting, you can use temporary URLs:

```swift
// In SettingsView, temporarily use:
if let privacyURL = URL(string: "https://raw.githubusercontent.com/yourusername/afl_fantasy_ios/main/docs/privacy.md") {
    Link("Privacy Policy", destination: privacyURL)
}
if let termsURL = URL(string: "https://raw.githubusercontent.com/yourusername/afl_fantasy_ios/main/docs/terms.md") {
    Link("Terms of Service", destination: termsURL)
}
```

## Testing

Test that URLs work:
```bash
curl -I https://afl.ai/privacy
curl -I https://afl.ai/terms
```

Should return HTTP 200 and serve the Markdown content.

## Legal Compliance Notes

- Ensure URLs are accessible before App Store submission
- Apple requires privacy policy links to work during review
- Keep documents updated and versioned
- Consider GDPR/CCPA requirements for international users

## File Structure

```
docs/
├── privacy.md          # Main privacy policy
├── terms.md           # Main terms of service
├── legal/
│   ├── hosting-guide.md  # This file
│   └── requirements.md   # Compliance checklist
└── _redirects         # Netlify redirects (if using)
```
