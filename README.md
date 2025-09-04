AI Chatbot - Flutter App
A modern, cross-platform AI chatbot application built with Flutter and powered by Google Gemini AI. This app provides an intuitive chat interface with advanced AI capabilities including text conversations, image analysis, and AI-generated images.

✨ Features
🤖 AI Conversations
Text Chat: Natural language conversations with Google Gemini 2.0 Flash
Image Analysis: Upload photos for AI-powered image recognition and analysis
Vision AI: Camera integration for real-time photo capture and analysis
Streaming Responses: Real-time typing indicators and response streaming
🎨 Image Generation
AI Image Creation: Generate images from text prompts using AI
Gallery Integration: Save generated images directly to device gallery
Image Commands: Use /img <prompt> for quick image generation
💾 Smart History Management
Persistent Chat History: Automatic conversation saving and loading
Multiple Conversations: Manage multiple chat sessions
Smart Titles: Auto-generated conversation titles from first message
History Screen: Browse and resume previous conversations
🎨 Modern UI/UX
Material Design 3: Beautiful, modern interface following Material Design guidelines
Dark/Light Themes: Toggle between dark and light modes
Smooth Animations: Polished animations and transitions
Custom Chat Bubbles: Elegant message bubbles with syntax highlighting
Responsive Design: Optimized for all screen sizes
📱 Cross-Platform Support
Android - Native Android experience
iOS - Native iOS experience
Web - Progressive Web App
Windows - Desktop application
macOS - Native macOS app
Linux - Linux desktop support
🛠️ Technical Stack
Framework: Flutter 3.5.4+
State Management: GetX
AI Integration: Google Gemini API
Storage: SharedPreferences for local data persistence
Image Handling: Image picker, camera integration
Permissions: Runtime permission handling
Audio: Audio playback support
File Management: Path provider for file operations
📦 Key Dependencies
yaml
dependencies:
  flutter: sdk
  get: ^4.7.2                    # State management
  http: ^1.1.0                   # API calls
  chat_bubbles: ^1.7.0           # Chat UI components
  shared_preferences: ^2.2.2     # Local storage
  flutter_highlight: ^0.7.0      # Code syntax highlighting
  image_picker: ^1.0.4           # Image selection
  camera: ^0.10.5+5              # Camera functionality
  permission_handler: ^11.0.1    # Runtime permissions
  audioplayers: ^5.2.1           # Audio playback
  path_provider: ^2.1.1          # File system paths
  share_plus: ^10.0.2            # Share functionality
  gal: ^2.3.0                    # Gallery operations
🚀 Getting Started
Prerequisites
Flutter SDK 3.5.4 or higher
Dart SDK
Google Gemini API key
Installation
Clone the repository
bash
git clone https://github.com/yourusername/chatbot.git
cd chatbot
Install dependencies
bash
flutter pub get
Configure API Key
Update 
lib/constant/api_constant.dart
 with your Google Gemini API key
dart
class ApiConstant {
  static const String apiKey = "YOUR_GEMINI_API_KEY_HERE";
}
Run the app
bash
flutter run
🎯 Usage
Basic Chat
Type messages in the input field and press send
The AI will respond with intelligent, contextual answers
Image Features
Camera Button: Capture photos directly from camera
Image Analysis: Send images with optional text prompts for AI analysis
Image Generation: Use the magic wand button or /img <prompt> command
Navigation
History Button: Access previous conversations
Theme Toggle: Switch between dark and light modes
Menu Options: Start new conversations and access settings
🏗️ Architecture
The app follows a clean architecture pattern with:

Controllers: Business logic and state management (GetX)
Services: API communication and data persistence
Models: Data structures for conversations and messages
Screens: UI components and user interfaces
Widgets: Reusable UI components
Theme: Centralized styling and theming
🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments
Google Gemini AI for powering the conversational AI
Flutter team for the amazing cross-platform framework
GetX for efficient state management


Note: Remember to keep your API keys secure and never commit them to version control. Consider using environment variables or secure storage for production deployments.
