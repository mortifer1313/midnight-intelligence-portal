# Midnight Intelligence Corp.

A comprehensive Next.js 15+ application featuring 8 specialized AI-powered investigation domains. Each category is equipped with intelligent operatives that continuously learn and adapt to provide superior intelligence gathering capabilities.

## 🚀 Features

- **8 Specialized Investigation Categories:**
  1. **Web Information Remover** - Advanced digital privacy protection and information removal
  2. **Track & Trace** - Digital forensics and location analysis
  3. **Social Media Investigator** - Comprehensive social media analysis and investigation
  4. **Device Info Hunter** - Advanced device fingerprinting and information gathering
  5. **Facial Recognition** - AI-powered biometric analysis and identity verification
  6. **Flooded** - Data flooding and information saturation analysis
  7. **Account Report** - Comprehensive account analysis and reporting
  8. **LPR Cameras** - License Plate Recognition and vehicle tracking

- **AI-Powered Operatives** - Each category features intelligent operatives that learn and adapt
- **Modern UI** - Clean, responsive design with Tailwind CSS
- **Real-time Processing** - Live chat interface with AI responses
- **Simulation Mode** - Works with or without API keys for demonstration

## 🛠 Tech Stack

- **Framework:** Next.js 15+ with TypeScript
- **Styling:** Tailwind CSS with custom design system
- **UI Components:** shadcn/ui components
- **AI Integration:** OpenRouter API with Claude 3.5 Sonnet
- **Fonts:** Google Fonts (Inter)

## 📋 Prerequisites

- Node.js 18+
- npm, yarn, pnpm, or bun
- OpenRouter API key (optional for simulation mode)

## 🚀 Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd ai-investigation-portal
   ```

2. **Install dependencies:**
   ```bash
   npm install
   # or
   yarn install
   # or
   pnpm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.local.example .env.local
   ```
   
   Edit `.env.local` and add your OpenRouter API key:
   ```env
   OPENROUTER_API_KEY=your_actual_api_key_here
   ```

4. **Run the development server:**
   ```bash
   npm run dev
   # or
   yarn dev
   # or
   pnpm dev
   ```

5. **Open your browser:**
   Navigate to [http://localhost:3000](http://localhost:3000)

## 🔑 API Configuration

### Getting OpenRouter API Key

1. Visit [OpenRouter.ai](https://openrouter.ai/)
2. Sign up for an account
3. Navigate to the API Keys section
4. Generate a new API key
5. Add it to your `.env.local` file

### Simulation Mode

If no API key is provided, the application runs in simulation mode, demonstrating the interface and providing mock responses for testing purposes.

## 🏗 Project Structure

```
src/
├── app/                          # Next.js App Router
│   ├── api/bot/[category]/      # API routes for bot interactions
│   ├── [category-pages]/        # Individual category pages
│   ├── globals.css              # Global styles
│   ├── layout.tsx               # Root layout
│   └── page.tsx                 # Homepage
├── components/
│   └── ui/
│       └── BotInterface.tsx     # Reusable bot chat interface
└── lib/
    └── utils.ts                 # Utility functions
```

## 🤖 API Endpoints

### Bot Interaction Endpoint

**POST** `/api/bot/[category]`

**Request Body:**
```json
{
  "userInput": "Your investigation query here"
}
```

**Response:**
```json
{
  "botResponse": "AI-generated response based on category and query"
}
```

**Categories:**
- `web-information-remover`
- `track-trace`
- `social-media-investigator`
- `device-info-hunter`
- `facial-recognition`
- `flooded`
- `account-report`
- `lpr-cameras`

## 🧪 Testing

### Manual Testing

1. **Start the development server:**
   ```bash
   npm run dev
   ```

2. **Test the homepage:**
   - Navigate to `http://localhost:3000`
   - Verify all 8 category cards are displayed
   - Test navigation to each category page

3. **Test bot interactions:**
   - Click on any category card
   - Enter a test query in the bot interface
   - Verify the response (simulation or real AI response)

### API Testing with curl

Test the bot API endpoints directly:

```bash
# Test Web Information Remover bot
curl -X POST http://localhost:3000/api/bot/web-information-remover \
     -H "Content-Type: application/json" \
     -d '{"userInput": "How can I remove my personal information from search engines?"}' \
     -w "\nHTTP: %{http_code}\nTime: %{time_total}s\n" | jq '.'

# Test Track & Trace bot
curl -X POST http://localhost:3000/api/bot/track-trace \
     -H "Content-Type: application/json" \
     -d '{"userInput": "How can I trace the origin of an IP address?"}' \
     -w "\nHTTP: %{http_code}\nTime: %{time_total}s\n" | jq '.'

# Test Social Media Investigator bot
curl -X POST http://localhost:3000/api/bot/social-media-investigator \
     -H "Content-Type: application/json" \
     -d '{"userInput": "How can I verify if a social media account is authentic?"}' \
     -w "\nHTTP: %{http_code}\nTime: %{time_total}s\n" | jq '.'
```

## 🎨 Customization

### Adding New Categories

1. **Create a new page:**
   ```bash
   mkdir src/app/new-category
   touch src/app/new-category/page.tsx
   ```

2. **Add to homepage:**
   Update the `categories` array in `src/app/page.tsx`

3. **Add API support:**
   Add the category prompt in `src/app/api/bot/[category]/route.ts`

### Styling Modifications

- **Global styles:** Edit `src/app/globals.css`
- **Component styles:** Modify Tailwind classes in individual components
- **Theme colors:** Update the gradient colors in category cards

## 🚀 Deployment

### Vercel (Recommended)

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Deploy to Vercel:**
   - Visit [vercel.com](https://vercel.com)
   - Import your GitHub repository
   - Add environment variables in Vercel dashboard
   - Deploy

### Other Platforms

The application can be deployed to any platform that supports Next.js:
- Netlify
- Railway
- DigitalOcean App Platform
- AWS Amplify

## 🔒 Security Considerations

- **API Keys:** Never commit API keys to version control
- **Rate Limiting:** Consider implementing rate limiting for production
- **Input Validation:** All user inputs are validated before processing
- **CORS:** Configure CORS policies for production deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation above
- Review the code comments
- Test in simulation mode first
- Verify API key configuration

## 🔄 Updates

The AI bots are designed to continuously learn and adapt. Regular updates may include:
- New investigation techniques
- Enhanced AI capabilities
- Additional category features
- Performance improvements

---

**Note:** This application is designed for educational and legitimate investigation purposes. Always comply with applicable laws and ethical guidelines when using investigation tools.
