# 📱 Budget Scanner: SMS-First Expense Tracker

[![Flutter](https://img.shields.io/badge/Flutter-v3.2.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![ObjectBox](https://img.shields.io/badge/Database-ObjectBox-orange?logo=sqlite&logoColor=white)](https://objectbox.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance, local-first Flutter application designed to automate your financial tracking by scanning bank SMS notifications. No cloud, no trackers—just your data, on your device.

![App Mockup](assets/header_mockup.png)

## 🌟 Key Features

-   **🤖 Automated Parsing**: Intelligently extracts transaction details (Amount, Ref ID, Payee, Bank) from incoming SMS messages.
-   **🔒 Privacy-First**: 100% local processing using [ObjectBox](https://objectbox.io/). Your financial data never leaves your device.
-   **📈 Spending Insights**: Clean UI for categorizing and analyzing your expenses.
-   **⚡ High Performance**: Optimized C++ backend via ObjectBox for near-instant data retrieval.
-   **🎨 Dark Mode Support**: Sleek, modern interface designed for focus and clarity.

## 🛠️ Built With

-   **Frontend**: [Flutter](https://flutter.dev) (Dart)
-   **Database**: [ObjectBox](https://objectbox.io) (NoSQL, C++ Backend)
-   **Permissions**: `permission_handler` (SMS Access Management)
-   **Parsing**: `flutter_sms_inbox` + Custom Regex logic

---

## 🚀 Getting Started

### Prerequisites

-   Flutter SDK (`^3.2.0`)
-   Android SDK (for SMS permissions)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/cosmic399/expense-tracker.git
    cd expense-tracker
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate ObjectBox Code**:
    Since this project uses ObjectBox, you must generate the C++ bridge:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the application**:
    ```bash
    flutter run
    ```

---

## 🏗️ Architecture

The project follows a modular Flutter architecture:

-   **`lib/models/`**: Defines the `Transaction` entity for the ObjectBox database.
-   **`lib/helpers/`**: Contains the core logic for SMS parsing and database interaction.
-   **`lib/screens/`**: UI screens for the dashboard and settings.
-   **`lib/widgets/`**: Reusable UI components.

## 🛡️ Privacy & Security

Budget Scanner is designed with one goal: **Data Sovereignty**.
-   **No Internet Permission**: The app logic is fully offline.
-   **Edge AI**: SMS parsing happens entirely on-device.
-   **Local Storage**: All data is encrypted at rest by the OS and managed by ObjectBox.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
