# 🚀 Getting Started with AFL Fantasy Intelligence Platform

Welcome! This guide will get you up and running with the AFL Fantasy Intelligence Platform in just a few minutes.

## 📱 What is this app?

The AFL Fantasy Intelligence Platform helps you make better AFL Fantasy decisions with:
- **AI-powered captain recommendations** based on form, fixtures, and matchups
- **Trade analysis** to optimize your team composition  
- **Cash cow tracking** to maximize team value growth
- **Real-time player insights** and price change predictions

## 🎯 Quick Setup (5 minutes)

### Option 1: iOS App Only
If you just want to use the iOS app:

1. **Open the project in Xcode:**
   ```bash
   cd ios/
   open AFLFantasy.xcodeproj
   ```

2. **Build and run:**
   - Select iPhone 15 simulator (or your device)
   - Press `⌘+R` to build and run
   - The app will open in the simulator

3. **Start using the app:**
   - Explore the dashboard, captain advisor, and other features
   - Note: Some features require backend services (see Option 2)

### Option 2: Full Platform (iOS + Web + Backend)
For the complete experience with AI features:

1. **Prerequisites check:**
   ```bash
   node --version    # Should be 18+
   python --version  # Should be 3.9+
   ```

2. **Install dependencies:**
   ```bash
   npm install
   pip install -r requirements.txt
   ```

3. **Set up environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys (optional for basic features)
   ```

4. **Start everything:**
   ```bash
   npm run dev      # Starts web dashboard
   python server.py # In another terminal - starts backend
   ```

5. **Access the platform:**
   - **Web Dashboard**: http://localhost:5173
   - **iOS App**: Build and run from Xcode
   - **API**: http://localhost:5173/api

## 🎮 Using the App

### Dashboard
- View your team score, rank, and key metrics
- See player performance summaries
- Check captain suggestions

### Captain Advisor  
- Get AI recommendations for weekly captain picks
- See confidence ratings and analysis
- Compare multiple captain options

### Trade Calculator
- Analyze potential trades
- See trade impact scores
- Get buy/sell recommendations

### Cash Cows
- Track rookie price rises
- Identify optimal sell timing
- Maximize team value growth

## 🆘 Common Issues

**"Port already in use" error:**
```bash
lsof -ti:5173 | xargs kill -9
npm run dev
```

**iOS app won't build:**
- Make sure you're using Xcode 15+
- Check that iOS deployment target is set to 16.0+
- Clean build folder (Product → Clean Build Folder)

**Missing AI features:**
- Add your API keys to `.env` file
- Make sure backend server is running
- Check the API health endpoint: http://localhost:5173/api/health

## 📚 Next Steps

- **New to the project?** Read the [Architecture Overview](./ARCHITECTURE.md)
- **Want to contribute?** See [Contributing Guidelines](../CONTRIBUTING.md)
- **Need help?** Check the [FAQ](./FAQ.md) or open an issue

## 💡 Pro Tips

1. **Start with iOS app only** if you're new - it works standalone
2. **Use the web dashboard** for detailed analysis and data exploration
3. **Enable API keys** for the full AI-powered experience
4. **Check the logs** if something isn't working - they're usually helpful

---

**Ready to dominate your AFL Fantasy league? Let's go! 🏆**
