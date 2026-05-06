<div align="center">
  <h1>🛡️ Smart Emergency Response App</h1>
  <p>Flutter-based Smart Emergency Response & Incident Reporting App with offline support, priority handling, dashboard analytics, and admin management.</p>

  [![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
  [![Provider](https://img.shields.io/badge/State_Management-Provider-4A148C)](https://pub.dev/packages/provider)
  [![Hive](https://img.shields.io/badge/Storage-Hive-FFCA28)](https://pub.dev/packages/hive)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)]()
</div>

<br>

## 📝 Problem Statement
During critical emergencies (Medical, Fire, Security, Accident), every second counts. Traditional manual or fragmented reporting systems delay the response time, causing a higher risk to life and property. There is a need for a unified, offline-first mobile application that allows rapid incident logging, automatic urgency assignment (color-coded priorities), and real-time dashboard analytics to help response teams dispatch the closest available responders immediately.

## ✨ Features Implemented
* **Incident Reporting**: Form with validation to ensure no missing details. Auto-generates standard IDs (e.g., `INC123456789`).
* **Incident Tracking**: Robust tracking list sorted dynamically by priority (`Critical` first) and timestamp.
* **Admin Dashboard**: Comprehensive visual analytics including priority distribution progress bars and category breakdown.
* **Search & Filter**: Powerful real-time search by ID/Title and filtering by exact Priority, Status, and Category.
* **Offline Hive Storage**: Uses NoSQL Hive to persist all data locally, meaning the app works securely even without connectivity.
* **Priority-based Action Flow**: Distinct routing and UI badges for `Critical`, `High`, `Medium`, and `Low` emergencies.
* **Color-Coded Status Management**: Dynamic `Active` / `Resolved` states integrated globally.

---

## 🛠 Modules & Technologies Used
* **Framework**: Flutter (Dart)
* **Architecture**: MVVM-inspired Provider Pattern
* **State Management**: `provider` pattern for reactive UI updates across dashboards and lists.
* **Offline Database**: `hive` and `hive_flutter` for lighting-fast NoSQL storage.
* **Unique Identification**: `uuid` timestamp hashing approach.
* **Date Parsing**: `intl` for professional timestamp localization.

## 📱 Screens Included

| Screen | Description |
|---|---|
| **1. Admin Dashboard Screen** | Overview of all app statistics, quick actions, and urgent active task spotlights. |
| **2. Incident Reporting Screen** | Clean, validated form for submitting strict emergency details. |
| **3. Incident List Screen** | The master tracker sorted by Criticality and Recency. |
| **4. Incident Details Screen** | Dedicated view displaying assigned responders, exact status, full descriptions, and action markers. |
| **5. Search & Filter Screen** | Advanced lookup combining multiple enums (Status, Category, Level) to pinpoint specific incidents. |

---

## 🚦 Priority Handling Logic
The application enforces strict visual and sorting hierarchies:
1. **Critical (Red)**: Displayed first in all lists, triggers highlighted red borders, adds to the Dashboard warning queue.
2. **High (Orange)**: Displayed second, noticeable orange tags. 
3. **Medium (Amber)**: Displayed third, standard warning.
4. **Low (Green)**: Displayed last, standard informational urgency.

## 📂 Folder Structure
```text
lib/
├── models/
│   └── incident_model.dart            # Data layer, enums, & Hive TypeAdapters
├── providers/
│   └── incident_provider.dart         # Business logic layer, data routing
├── screens/
│   ├── dashboard_screen.dart          # Entry Admin analytical screen
│   ├── incident_list_screen.dart      # Master list view
│   ├── incident_detail_screen.dart    # Specific record view
│   ├── report_screen.dart             # Form intake
│   └── search_filter_screen.dart      # Filtering overlay / separate view
├── services/
│   └── hive_service.dart              # Core offline DB initialization & mocking
├── widgets/
│   ├── incident_card.dart             # Reusable List Tile card
│   ├── priority_badge.dart            # Automated color badge component
│   └── stat_card.dart                 # Interactive analytical card
└── main.dart                          # Root bindings and ThemeData configurations
```

---

## 🚀 Installation & How to Run Project

### Prerequisites
- Flutter SDK (`>= 3.0.0`)
- Dart SDK
- Android Studio / VS Code with modern Flutter integrations.

### Steps
1. **Clone the repository:**
   ```bash
   git clone <your-repository-url>
   ```
2. **Navigate into the directory:**
   ```bash
   cd smart_emergency_response_app
   ```
3. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the Project (Chrome/Web/Emulator):**
   ```bash
   flutter run
   ```

*(Note: The app will safely auto-purge old data schemas and mock 4 realistic emergency items to showcase the dashboard immediately on run).*

---

## 🔮 Future Enhancements
* **Cloud Sync (Firebase/Supabase)**: Push the offline Hive changes confidently to a remote database when the connection is restored.
* **Push Notifications**: Integrate FCM to instantly notify the exact assigned responder of a new Critical case.
* **Geo-Fencing Maps Integration**: Display incidents natively on a Google Map view clustered by region.

## 🏁 Conclusion
The Smart Emergency Response App provides an immediate, offline-ready interface ensuring critical dispatches are never lost due to systemic failures or connection drops. Designed with clean modern Material principles and scalable provider architectures, it is perfectly positioned for production environments.
