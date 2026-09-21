# english-helper

A cross-platform personal utility application developed using **Flutter** and **Dart**, specifically designed to track, manage, and facilitate English language learning progress. 

The application implements a local-first data paradigm, allowing users to serialize their learning milestones, export physical backups, and dynamically load progress files from external storage providers.

---

## Key Architectural Components & Tech Stack

The application leverages a modular pipeline to handle state persistence, local file-system accessibility, and system-level file sharing utilities:

* **State Serialization (`json_serializable`):** Ensures robust, type-safe data conversion by programmatically generating JSON serialization boilerplate code for the application's underlying data models.
* **Local Sandboxed Storage (`path_provider`):** Locates correct, platform-specific sandboxed directories (such as temporary or document storage) to ensure safe data read/write cycles across multiple operating systems.
* **Inter-App Sharing (`share_plus`):** Interacts with native operating system share sheets, enabling the immediate transfer of generated progress files into preferred user destinations (e.g., Google Drive, iCloud, or external messaging applications).
* **Dynamic File Access (`file_picker`):** Integrates an abstract native document picking interface, allowing users to locate and load external `.json` backup profiles back into the active application workspace.

---

## Getting Started & Installation

### Prerequisites
Before compiling the project, make sure you have the Flutter SDK installed on your workstation. 

```bash
# Verify your local Flutter environment installation
flutter doctor
```

### Installation Steps
1. Clone this repository onto your machine:
   ```bash
   git clone https://github.com
   cd english-helper
   ```
2. Fetch the required pub packages defined in `pubspec.yaml`:
   ```bash
   flutter pub get
   ```
3. Generate the automated JSON serialization classes via the build runner:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Launch the application on your active connected emulator or device:
   ```bash
   flutter run
   ```

---

## Repository Structure Overview

* **`lib/`**: Contains the core Dart source files, state management, models, and UI layout definitions.
* **`assets/`**: Houses structural design items and configuration media (such as custom icons).
* **Native Wrappers (`android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`)**: Platform-specific entry points required for compiling and packaging the native binaries.

---

## 📄 License
This project is licensed under the **MIT License** - see the `LICENSE` file for details.
