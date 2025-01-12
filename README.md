# Urban Guide

## Overview
This Flutter application allows users to create personalized scheduled visits using the **Google Maps API** and connects to a **Django backend** for data management and scheduling. The app provides a seamless user experience for planning visits, managing schedules, and interacting with maps for real-time guidance.

---

## Features
- **Google Maps Integration**: Interactive maps to visualize locations and plan routes.
- **Personalized Scheduling**: Create and manage visits tailored to user preferences.
- **Backend Connectivity**: Connects to a Django backend for data storage and retrieval.
- **Real-time Updates**: Sync schedules and updates between the app and backend.
- **User Authentication**: Secure login and registration powered by Django.
- **Responsive UI**: Optimized for both iOS and Android devices.

---

## Tech Stack
### **Frontend**
- **Flutter**: Cross-platform mobile app development framework.
- **Google Maps API**: For location visualization and routing.
- **HTTP Library**: For communication with the Django backend.

### **Backend**
- **Django**: Robust and scalable backend framework.
- **Django Rest Framework (DRF)**: For building RESTful APIs.
- **PostgreSQL**: Database for storing user and schedule data.

---

## Installation

### Prerequisites
- Flutter SDK installed ([Flutter Installation Guide](https://flutter.dev/docs/get-started/install)).
- Google Maps API Key ([Generate API Key](https://developers.google.com/maps/documentation/javascript/get-api-key)).
- Django backend running ([Django Setup](https://www.djangoproject.com/)).

## Steps
**Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```
### Configure Flutter App:

Add your Google Maps API Key in `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```
For iOS, add the API key in `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```
### Install Dependencies:

```flutter pub get```

Run the App:

```flutter run```

### Setup Django Backend:

- Clone the backend repository or set up the Django project.
- Add required environment variables to the .env file (e.g., database credentials).
Start the Django server:

```python .\manage.py runserver 192.168.242.48:8000```