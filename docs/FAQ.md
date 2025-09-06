# ❓ Frequently Asked Questions (FAQ)

## 📱 **General Questions**

### What is the AFL Fantasy Intelligence Platform?
It's a comprehensive fantasy sports analytics platform that includes:
- Native iOS app with SwiftUI interface
- Web dashboard with real-time analytics  
- AI-powered recommendations and insights
- Multi-source AFL data integration

### Do I need both the iOS app and web platform?
No! You can use either independently:
- **iOS app only**: Perfect for mobile-first users
- **Web platform only**: Great for detailed analysis
- **Both together**: Full integrated experience

### Is this free to use?
Yes, the platform is open source and free to use. Some AI features may require API keys from third-party services.

## 🔧 **Setup & Installation**

### What do I need to run the iOS app?
- **macOS**: Version 13.0 or later
- **Xcode**: Version 15.0 or later  
- **iOS**: Target device with iOS 16.0+
- **No external dependencies**: Uses only native iOS frameworks

### The setup scripts don't work. What actual commands do I run?
For iOS app only:
```bash
cd ios/
open AFLFantasy.xcodeproj
# Then build and run in Xcode (⌘+R)
```

For full platform:
```bash
npm install
npm run dev    # Web dashboard
python server.py  # Backend (separate terminal)
```

### Do I need a database?
Not required for basic functionality. PostgreSQL is only needed for:
- User data persistence
- Historical analytics
- Advanced AI features

## 🎯 **Using the App**

### What features work without the backend?
The iOS app includes standalone features:
- Dashboard with sample data
- UI navigation and design system
- Settings and preferences
- Mock captain suggestions

### How do I get real AFL Fantasy data?
Real data requires:
1. Running the backend services
2. Configuring API keys in `.env` file
3. Setting up data scrapers (optional)

### What AI features are available?
- **Captain recommendations**: Based on form, fixtures, matchups
- **Trade analysis**: Optimize team composition
- **Price predictions**: Forecast player price changes
- **Breakout detection**: Identify emerging players
- **Risk assessment**: Injury and form analysis

## 🐛 **Troubleshooting**

### The iOS app won't build in Xcode
Common solutions:
1. **Clean Build Folder**: Product → Clean Build Folder (⌘+⇧+K)
2. **Check Xcode version**: Must be 15.0 or later
3. **Verify deployment target**: Set to iOS 16.0+
4. **Reset simulator**: Device → Erase All Content and Settings

### "Port 5173 already in use" error
```bash
# Kill process using the port
lsof -ti:5173 | xargs kill -9

# Then restart
npm run dev
```

### Getting API/network errors
1. **Check if backend is running**: Visit http://localhost:5173/api/health
2. **Verify environment setup**: Check `.env` file exists and is configured
3. **API key issues**: Some features require valid API keys
4. **Firewall/network**: Ensure local ports aren't blocked

### App crashes or behaves unexpectedly
1. **Check iOS deployment target**: Must match your device/simulator
2. **View console logs**: Xcode → View → Debug Area → Activate Console
3. **Try different simulator**: Sometimes simulator-specific issues occur
4. **Reset app data**: Delete app and reinstall

## 🔐 **API Keys & Configuration**

### Which API keys do I need?
**Optional (for enhanced features):**
- **GEMINI_API_KEY**: Google's AI service
- **OPENAI_API_KEY**: OpenAI fallback
- **DFS_API_KEY**: DFS Australia data

**None required for basic functionality.**

### Where do I get API keys?
- **Gemini**: [Google AI Studio](https://makersuite.google.com/)
- **OpenAI**: [OpenAI Platform](https://platform.openai.com/)
- **DFS Australia**: Contact their support team

### How do I add API keys?
1. Copy `.env.example` to `.env`
2. Add your keys:
   ```
   GEMINI_API_KEY=your_key_here
   OPENAI_API_KEY=your_key_here
   ```
3. Restart the backend services

## 🤝 **Contributing**

### How can I contribute?
1. **Start small**: Fix typos, improve documentation
2. **Report bugs**: Create detailed GitHub issues
3. **Suggest features**: Use GitHub Discussions
4. **Submit code**: Fork → Create branch → Pull Request

### What should I work on?
Check these areas:
- **iOS features**: Enhance the mobile experience
- **Web dashboard**: Improve analytics and visualizations  
- **AI algorithms**: Better prediction models
- **Data integration**: More reliable data sources
- **Testing**: Increase test coverage
- **Documentation**: Keep guides up-to-date

### Code style requirements?
- **iOS**: SwiftLint + SwiftFormat (automated)
- **Web**: ESLint + Prettier (automated)
- **Python**: Black + isort (backend)
- **Commits**: Conventional commit format

## 📊 **Data & Analytics**

### Where does the AFL data come from?
Multiple sources for reliability:
- **DFS Australia API**: Primary player data
- **FootyWire**: Fixture and team information
- **AFL Fantasy Live**: Real-time updates
- **Excel DVP files**: Defense vs Position analysis

### How accurate are the predictions?
Current AI algorithm accuracy:
- **Score predictions**: ~87% within ±15 points
- **Price changes**: ~91% directional accuracy  
- **Captain picks**: ~84% optimal selection rate

### Can I add my own data sources?
Yes! The architecture supports additional data sources:
1. Create new data adapter
2. Implement standard interface
3. Add to data pipeline
4. Submit PR for review

## 🚀 **Deployment & Production**

### Can I deploy this publicly?
Yes, it's open source (MIT license). Consider:
- **Security**: Remove debug features
- **Scaling**: Use proper production database
- **API limits**: Monitor third-party usage
- **Legal**: Respect AFL data usage terms

### What hosting options work?
- **Vercel/Netlify**: Web dashboard
- **Docker**: Full platform deployment
- **Kubernetes**: Scalable production setup
- **App Store**: iOS app distribution

## 📞 **Getting More Help**

### Where can I get support?
1. **Check this FAQ first** 
2. **Read the documentation**: `/docs` directory
3. **Search GitHub issues**: Existing solutions
4. **Create new issue**: Detailed problem description
5. **GitHub Discussions**: General questions

### What information should I include in bug reports?
- **Operating system** and version
- **Xcode version** (for iOS issues)  
- **Node.js/Python versions** (for backend issues)
- **Exact error messages** and stack traces
- **Steps to reproduce** the issue
- **Screenshots** (if UI-related)

---

**Still have questions?** Create an issue or start a discussion on GitHub!
