<div align="center">

# 💰 Finora

### Your Calm AI-Powered Personal Finance Companion

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Gemini](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<img src="https://img.shields.io/badge/Status-🚧_Under_Construction-yellow?style=for-the-badge" alt="Under Construction"/>

---

**Privacy-first • No accounts required • Your data stays local**

</div>

---

## 🚧 Project Status

<div align="center">
<img src="assets/images/construction_icon.avif" width="120" alt="Under Construction"/>
</div>

> **This repository is actively under development!**
> 
> We're building the MVP version of Finora. Features are being added regularly.
> Contributions, suggestions, and feedback are warmly welcomed! 🙌

---

## ✨ Features

| Feature | Status |
|---------|--------|
| 🔑 API Key Entry (Optional) | ✅ Completed |
| 🏠 Home Dashboard | ✅ Completed |
| 📊 Expense Tracking | ✅ Completed |
| 🎯 Goal Planning | ✅ Completed |
| 💬 AI Chat Assistant | ✅ Completed |
| 📈 Monthly Reports | ✅ Completed |
| 🌙 Dark/Light Theme | ✅ Completed |
| 📤 Data Export | ✅ Completed |
| 🤖 Auto Model Detection | ✅ **NEW** |
| 🔔 Notifications | 🚧 Coming Soon |
| 📱 Bank Sync | 🚧 Planned |

---

## 🤖 Smart AI Model Detection

Finora automatically detects and uses the best available Gemini model for your API key:

```
Gemini 3 → Gemini 2.5 → Gemini 2.0 → Gemini 1.5 → Legacy
```

**Supported Models:**
- `gemini-3-pro-preview`, `gemini-3-flash-preview`
- `gemini-2.5-flash`, `gemini-2.5-pro`
- `gemini-2.0-flash`, `gemini-2.0-flash-lite`
- `gemini-1.5-flash`, `gemini-1.5-pro`
- `gemini-pro`, `gemini-1.0-pro`

No manual configuration needed - the app finds what works! 🎉

---

## 🛠️ Tech Stack

<div align="center">

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI |
| **Dart** | Programming language |
| **Gemini AI** | Financial insights & chat |
| **Hive** | Local database |
| **Provider** | State management |
| **fl_chart** | Beautiful charts |

</div>

---

## 🏗️ Architecture

```mermaid
graph TB
    subgraph UI["📱 UI Layer"]
        WS[Welcome Screen]
        HS[Home Screen]
        DS[Dashboard]
        CS[Chat Screen]
        GS[Goals Screen]
        SS[Settings]
    end

    subgraph State["🔄 State Management"]
        AP[AppProvider]
        FP[FinanceProvider]
        CP[ChatProvider]
    end

    subgraph Services["⚙️ Services"]
        GS2[GeminiService]
        STS[StorageService]
        EXS[ExportService]
    end

    subgraph Data["💾 Data Layer"]
        HV[(Hive DB)]
        SP[(SharedPrefs)]
    end

    subgraph External["☁️ External"]
        GAI[Gemini AI API]
    end

    UI --> State
    State --> Services
    GS2 --> GAI
    STS --> HV
    STS --> SP
    FP --> STS
    FP --> GS2
    CP --> GS2
    AP --> STS
    AP --> GS2
```

<div align="center">

**Data Flow**: UI → Providers → Services → Local Storage / Gemini API

</div>

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.4)
- Dart SDK
- A [Gemini API Key](https://aistudio.google.com/app/apikey) *(optional - app works without it)*

### Installation

```bash
# Clone the repository
git clone https://github.com/AditthyaSS/Finance.ai.git

# Navigate to project
cd Finance.ai

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> 💡 **Tip:** You can explore the app without an API key! Add one later in Settings to unlock AI features.

---

## 🤝 Contributing

**Contributions are welcome and appreciated!** 🙌

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest new features
- 📖 Improve documentation
- 🎨 Enhance UI/UX
- 🔧 Fix issues

---

## 🔒 Privacy

Finora is **privacy-first**:

- ✅ All data stored locally on your device
- ✅ No accounts or sign-ups required
- ✅ API key stored securely on device
- ✅ No analytics or tracking
- ✅ No data sent to our servers
- ✅ Works offline (except AI features)

---

## 📸 Screenshots

<div align="center">

<img src="assets/images/1000052093.jpg" width="180"/>
<img src="assets/images/1000052094.jpg" width="180"/>
<img src="assets/images/1000052095.jpg" width="180"/>
<img src="assets/images/1000052096.jpg" width="180"/>

<img src="assets/images/1000052097.jpg" width="180"/>
<img src="assets/images/1000052098.jpg" width="180"/>
<img src="assets/images/1000052099.jpg" width="180"/>
<img src="assets/images/1000052100.jpg" width="180"/>

<img src="assets/images/1000052101.jpg" width="180"/>

</div>

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

<img src="assets/images/flutter_icon.png" width="60" alt="Built with Flutter"/>

### Made with ❤️ by Aditthya

**⭐ Star this repo if you find it useful!**

[![GitHub stars](https://img.shields.io/github/stars/AditthyaSS/Finance.ai?style=social)](https://github.com/AditthyaSS/Finance.ai)

</div>
