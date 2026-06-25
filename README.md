# Smart Energy Management System ⚡

A Flutter-based mobile application designed to help users monitor, analyze, and optimize household energy consumption.

The Smart Energy Management System provides users with tools to track appliance usage, manage energy goals, estimate consumption costs, and receive smart energy recommendations through an intuitive mobile interface.

The application is built using Flutter with Firebase and Supabase integration prepared for future backend expansion.

---

# 📱 Project Overview

Smart Energy Management System is a mobile application developed using Flutter and Dart.

The main goal of this application is to provide an intelligent platform where users can:

- Monitor energy consumption
- Manage household appliances
- Track energy usage patterns
- Set energy-saving goals
- Analyze estimated costs
- Receive optimization suggestions


The current version focuses on the complete Flutter application interface and core functionality.

Backend services are prepared for future implementation:

- Firebase → Authentication
- Supabase → Database management


---

# ✨ Features

## 🔐 Authentication Interface

Includes:

- Login screen
- Signup screen
- User onboarding flow
- Profile management interface

Firebase Authentication integration is configured for future activation.


---

## 📊 Energy Dashboard

Features:

- Energy usage overview
- Consumption statistics
- Estimated electricity cost
- Saving analysis
- Usage status monitoring


---

## 🔌 Appliance Management

Users can:

- Add appliances
- Select appliance category
- Enter wattage details
- Configure usage hours
- Monitor appliance consumption


Usage status:

🟢 Optimal  
🟡 Normal  
🔴 High Usage


---

## 🏠 Smart Home Setup

Users can configure:

- Home type
- Number of family members
- Monthly budget
- Electricity unit price
- Target consumption


---

## 🤖 Smart Energy Assistant

Provides:

- Energy-saving recommendations
- Optimization suggestions
- Smart usage guidance


---

# 🏗️ Technology Stack


## Frontend

### Flutter

Used for complete mobile application development:

- UI implementation
- Screen navigation
- Widgets
- Application interface


### Dart

Used for:

- Application logic
- Data handling
- Business rules


---

## Backend Integration


### Firebase

Firebase integration is prepared for:

- User authentication
- Email/password login
- Google authentication
- User session handling


Currently authentication is not actively used.


---

### Supabase

Supabase integration is prepared for future database implementation:

- User data storage
- Appliance records
- Energy consumption data
- Application database management


Currently database operations are not active.


---

# 🏛️ Application Architecture


```
Flutter Application

        |
        ↓

Presentation Layer
(Screens + Widgets)

        |
        ↓

Logic Layer
(Application Logic + Calculations)

        |
        ↓

Backend Integration Layer

Firebase Authentication
(Future)

Supabase Database
(Future)

```


---

# 🚀 Getting Started

Follow these steps to run the project locally.


## Prerequisites

Before running the application, install:


### Flutter SDK

Download Flutter:

https://flutter.dev/docs/get-started/install


Check Flutter installation:

```bash
flutter doctor
```


Make sure:

- Flutter SDK is installed
- Android Studio is installed
- Emulator or physical device is available


---

# 📥 Installation


## 1. Clone Repository


```bash
git clone https://github.com/yourusername/smart-energy-management-system.git
```


Navigate into project:


```bash
cd smart-energy-management-system
```


---

## 2. Install Dependencies


Run:


```bash
flutter pub get
```


This downloads all required Flutter packages.


---

## 3. Configure Firebase (Future Use)


If Firebase authentication is activated later:

Add:

```
android/app/google-services.json
```

inside:

```
android/app/
```


Do not upload this file to GitHub.


---

## 4. Configure Supabase (Future Use)


Create environment configuration:


```
.env
```


Example:


```
SUPABASE_URL=your_project_url

SUPABASE_KEY=your_project_key
```


Keep these values private.


---

# ▶️ Running the Application


To run the Flutter application:


```bash
flutter run
```


Flutter will launch the application on:

- Android Emulator
- Physical Android device
- Supported Flutter platforms


---

# 🏗️ Build Application


## Android APK


Generate APK:


```bash
flutter build apk
```


The APK will be generated inside:


```
build/app/outputs/flutter-apk/
```


---

# 📂 Project Structure


```
lib/

│
├── screens/
├── widgets/
├── models/
├── services/
├── utils/


android/

ios/

assets/

pubspec.yaml

README.md

```


---

# 🔒 Security Notes


The following files should not be committed to GitHub:


```
google-services.json

.env

Firebase private keys

Supabase secret keys
```


These files should remain local and be configured separately.


---

# 🧮 Energy Calculation Logic


## Energy Consumption


```
Consumption =
(Wattage × Usage Hours) ÷ 1000
```


## Electricity Cost


```
Cost =
Monthly Consumption × Unit Price
```


## Saving Potential


```
Saving =
Current Cost - Optimized Cost
```


---

# 🚀 Future Enhancements


Planned improvements:

- Real-time energy monitoring
- IoT smart meter integration
- Smart appliance automation
- Active Firebase authentication
- Supabase database integration
- AI-based energy prediction
- Energy reports export
- Dark mode
- Multi-language support


---

# 🤝 Contribution


1. Fork the repository

2. Create a branch:


```bash
git checkout -b feature-name
```


3. Commit changes:


```bash
git commit -m "Added new feature"
```


4. Push changes:


```bash
git push
```


---

# 📄 License


MIT License


---

# 📸 Screenshots

(Add your application screenshots below)

