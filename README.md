# 💊 MedTrack

### Smart Medicine Tracking & Expiry Reminder App

> **MedTrack** is a Flutter-based mobile application designed to help users manage their medicines, track expiry dates, and receive timely reminders before medicines expire.

MedTrack provides a simple and user-friendly way to keep medicine records organized in one place. Users can securely log in, add and manage medicines, monitor expiry status, search their medicine list, and receive notifications when medicines are approaching their expiry date.

---

## 📱 Project Overview

Keeping track of medicine expiry dates can be difficult, especially when multiple medicines are stored at home.

**MedTrack** aims to solve this problem by providing a digital medicine management system where users can:

* 🔐 Create an account and securely log in
* 💊 Add medicine information
* 📅 Track medicine expiry dates
* ⚠️ Identify medicines that are close to expiry
* ❌ Identify medicines that have already expired
* 🔔 Receive expiry reminders
* ✏️ Edit medicine records
* 🗑️ Delete medicine records
* 🔎 Search medicines by name

The project is developed as a **college project** using Flutter.

---

## ✨ Features

### 🔐 User Authentication

Users can securely access their personal medicine records.

* User registration
* User login
* Secure authentication
* User logout
* Personal medicine data

---

### 💊 Medicine Management

Users can maintain detailed records of their medicines.

Each medicine can contain:

| Information      | Description               |
| ---------------- | ------------------------- |
| 💊 Medicine Name | Name of the medicine      |
| 🔢 Quantity      | Number/quantity available |
| 📅 Expiry Date   | Medicine expiration date  |

Users can:

* Add a medicine
* View medicine details
* Edit medicine information
* Delete a medicine

---

### 📅 Expiry Tracking

MedTrack automatically categorizes medicines according to their expiry status.

Possible statuses include:

🟢 **Safe**
Medicine has sufficient time before expiry.

🟠 **Expiring Soon**
Medicine is approaching its expiry date.

🔴 **Expired**
Medicine has already passed its expiry date.

This makes it easier for users to identify medicines that need attention.

---

### 🔔 Expiry Reminders

MedTrack provides notifications to remind users when a medicine is approaching its expiry date.

For example:

> 🔔 **Medicine Expiry Reminder**
> Your medicine **Paracetamol** is approaching its expiry date.

The reminder system helps users avoid accidentally keeping expired medicines.

---

### 🔎 Medicine Search

Users can quickly find a medicine by searching its name.

Example:

```text
Search: Paracetamol
        ↓
💊 Paracetamol 500mg
💊 Paracetamol Syrup
```

This becomes especially useful when the medicine list contains many records.

---

## 🛠️ Technology Stack

| Technology            | Purpose                             |
| --------------------- | ----------------------------------- |
| 🐦 **Flutter**        | Mobile application development      |
| 🎯 **Dart**           | Programming language                |
| 🔐 **Authentication** | User registration and login         |
| 🗄️ **Database**      | Store user and medicine information |
| 🔔 **Notifications**  | Medicine expiry reminders           |
| 🧩 **Git & GitHub**   | Version control and collaboration   |

> The exact backend/database technology can be updated here once it is finalized.

---

## 🏗️ Application Architecture

A possible high-level architecture for MedTrack:

```text
                   ┌─────────────────────┐
                   │     MedTrack App    │
                   │       Flutter       │
                   └──────────┬──────────┘
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
      ┌────────────┐   ┌──────────────┐  ┌──────────────┐
      │    Auth    │   │   Medicine   │  │ Notifications│
      │            │   │  Management  │  │              │
      └────────────┘   └──────┬───────┘  └──────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │   Database   │
                       └──────────────┘
```

---

## 📱 Main Screens

The application is planned to include the following screens:

### 1. 🔐 Login Screen

Allows existing users to securely log in.

**Components:**

* Email/username
* Password
* Login button
* Registration navigation

---

### 2. 📝 Registration Screen

Allows new users to create an account.

**Components:**

* Name
* Email
* Password
* Confirm password
* Register button

---

### 3. 🏠 Home / Dashboard

Provides an overview of the user's medicines.

Possible sections:

```text
┌─────────────────────────────┐
│        Hello, User 👋       │
├─────────────────────────────┤
│                             │
│  💊 Total Medicines     12  │
│  🟠 Expiring Soon        3  │
│  🔴 Expired              1  │
│                             │
├─────────────────────────────┤
│     Recent Medicines        │
│                             │
│  Paracetamol       🟢       │
│  Cetirizine        🟠       │
│  Amoxicillin       🔴       │
│                             │
└─────────────────────────────┘
```

---

### 4. 💊 Medicine List

Displays all medicines added by the user.

Users can:

* View medicines
* Search medicines
* Check expiry status
* Open medicine details
* Edit records
* Delete records

---

### 5. ➕ Add Medicine

Allows users to create a new medicine record.

Example:

```text
Medicine Name
[ Paracetamol              ]

Quantity
[ 20                      ]

Expiry Date
[ 15 / 10 / 2027          ]

        [ Add Medicine ]
```

---

### 6. ✏️ Edit Medicine

Users can modify existing medicine information.

---

### 7. 🔔 Notifications

Displays expiry reminders and other medicine-related notifications.

---

## 📊 Medicine Expiry Logic

MedTrack can categorize medicines based on the difference between the current date and expiry date.

For example:

```text
Expiry Date
     │
     ▼
Calculate remaining days
     │
     ├── Expired
     │
     ├── Expiring Soon
     │
     └── Safe
```

A possible rule could be:

| Condition                  | Status           |
| -------------------------- | ---------------- |
| Expiry date has passed     | 🔴 Expired       |
| Expires within 7 days      | 🟠 Expiring Soon |
| More than 7 days remaining | 🟢 Safe          |

> The number of reminder days can be changed according to the final project requirements.

---

## 🔔 Notification Flow

```text
User adds medicine
        │
        ▼
Store expiry date
        │
        ▼
System checks expiry date
        │
        ▼
Is medicine approaching expiry?
        │
       Yes
        │
        ▼
Schedule notification
        │
        ▼
🔔 Notify user
```

---

## 🗂️ Suggested Project Structure

A clean Flutter project structure could look like:

```text
lib/
│
├── main.dart
│
├── models/
│   └── medicine.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── medicine_list_screen.dart
│   ├── add_medicine_screen.dart
│   └── edit_medicine_screen.dart
│
├── services/
│   ├── auth_service.dart
│   ├── medicine_service.dart
│   └── notification_service.dart
│
├── widgets/
│   ├── medicine_card.dart
│   ├── search_bar.dart
│   └── expiry_badge.dart
│
├── utils/
│   ├── expiry_helper.dart
│   └── validators.dart
│
└── theme/
    └── app_theme.dart
```

This structure can be modified as the project grows.

---

## 🚀 Getting Started

### Prerequisites

Before running MedTrack, make sure you have:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Android Emulator / physical Android device
* Git

Check your Flutter installation:

```bash
flutter doctor
```

---

### Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/medtrack.git
```

Navigate into the project:

```bash
cd medtrack
```

---

### Install Dependencies

```bash
flutter pub get
```

---

### Run the Application

Connect an Android device or start an emulator, then run:

```bash
flutter run
```

---

## 🧪 Testing

Testing will be performed to verify important application functionality.

### Authentication

* [ ] User registration works
* [ ] User login works
* [ ] Invalid credentials are handled
* [ ] User can log out

### Medicine Management

* [ ] Medicine can be added
* [ ] Medicine can be edited
* [ ] Medicine can be deleted
* [ ] Medicine list displays correctly

### Expiry Tracking

* [ ] Expired medicines are identified
* [ ] Medicines approaching expiry are identified
* [ ] Safe medicines are displayed correctly

### Search

* [ ] Medicine search works
* [ ] Search handles partial names
* [ ] No-result state is handled

### Notifications

* [ ] Expiry notifications are scheduled
* [ ] Notification appears at the expected time
* [ ] Notification information is correct

---

## 🎯 Project Objectives

The main objectives of MedTrack are:

1. To develop a simple and user-friendly medicine management application.
2. To allow users to maintain digital medicine records.
3. To help users monitor medicine expiry dates.
4. To notify users when medicines are approaching expiry.
5. To provide secure user authentication.
6. To demonstrate practical mobile application development using Flutter.
7. To gain experience with database management, authentication, notifications, and collaborative software development.

---

## 🔮 Future Enhancements

The project can be extended with additional features in the future:

* 📷 Scan medicine using barcode/QR code
* 🤖 OCR-based medicine information extraction
* 💊 Medicine dosage reminders
* 📈 Medicine usage history
* ☁️ Cloud synchronization
* 👨‍👩‍👧 Family medicine management
* 📊 Medicine statistics and analytics
* 🌐 Multi-language support
* 🌙 Dark mode
* 📸 Medicine image upload
* 🏥 Nearby pharmacy information
* 🔄 Automatic medicine information lookup

---

## 📚 Learning Goals

Through this project, we aim to gain practical experience in:

* Flutter application development
* Dart programming
* Mobile UI/UX design
* Authentication
* Database management
* Local/cloud data storage
* Push/local notifications
* Git and GitHub
* Git branching and Pull Requests
* Software testing
* Application architecture

---

<div align="center">

### 💊 MedTrack

**Track your medicines. Know their expiry. Stay organized.**

Made with ❤️ using Flutter

</div>
