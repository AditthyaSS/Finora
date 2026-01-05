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
| 🔑 API Key Entry | ✅ Completed |
| 🏠 Home Dashboard | ✅ Completed |
| 📊 Expense Tracking | 🧪 Testing Ongoing |
| 🎯 Goal Planning | 🧪 Testing Ongoing |
| 💬 AI Chat Assistant | 🧪 Testing Ongoing |
| 📈 Monthly Reports | 🧪 Testing Ongoing |
| 🌙 Dark/Light Theme | ✅ Completed |
| 📤 Data Export | 🧪 Testing Ongoing |
| 🔔 Notifications | 🚧 Coming Soon |
| 📱 Bank Sync | 🚧 Planned |

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
- A [Gemini API Key](https://aistudio.google.com/app/apikey)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/finora.git

# Navigate to project
cd finora

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🤝 Contributing

**Contributions are welcome and appreciated!** �

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

---

## 📸 Screenshots

> 📷 *Screenshots coming soon...*

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
