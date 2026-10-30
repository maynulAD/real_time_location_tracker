# 📍 Real-Time Location Tracker

A Flutter application that tracks the user's current location in real time using **Google Maps** and **Geolocator**. The application automatically moves the map to the user's current position, updates the location every 10 seconds, and draws a polyline to visualize location changes.

## ✨ Features

- **Google Maps Integration:** Displays an interactive Google Map.
- **Automatic Map Animation:** Automatically moves the camera to the user's current GPS location.
- **Real-Time Location Updates:** Fetches the user's current location every 10 seconds.
- **Dynamic Marker:** Updates the marker position whenever the location changes.
- **Polyline Tracking:** Draws a blue polyline connecting previous and current locations.
- **Marker Information Window:** Displays the title "My current location" along with latitude and longitude.
- **Current Coordinates:** Shows the user's current latitude and longitude on the map.
- **Location Permissions:** Handles location permissions and GPS availability.

## 🛠️ Technologies Used

- Flutter
- Dart
- Google Maps Flutter
- Geolocator

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.12.3
  geolocator: ^14.0.2
```

**Important:** Enable Maps SDK for Android in Google Cloud Console and configure your API key before running the application.

**6. Run the Application**



## 📱 How to Use

1. Launch the application on your Android device.
2. Enable GPS/location services.
3. Grant the required location permission.
4. The Google Map automatically animates to your current location.
5. The application fetches your location every 10 seconds.
6. The marker updates whenever a new location is received.
7. A blue polyline displays the movement history.
8. Tap the marker to view your current latitude and longitude.

## 📂 Project Structure

```text
real_time_location_tracker/
│
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml
│
├── lib/
│   └── main.dart
│
├── test/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## 📍 Location Tracking Details

| Feature | Description |
|---|---|
| Initial Location | Gets the device's current GPS position |
| Update Interval | Every 10 seconds |
| Marker | Displays the latest location |
| Polyline | Connects recorded location points |
| Info Window | Shows latitude and longitude |
| Camera | Automatically animates to the latest position |

## ⚙️ Requirements

- Flutter SDK installed
- Dart SDK
- Android Studio or VS Code
- Android device or emulator
- Internet connection
- Google Maps API key
- GPS/location services enabled

## 👨‍💻 Author

**Md Gazi Maynul Hassan Moin**

GitHub: [@maynulAD](https://github.com/maynulAD)

---

⭐ If you find this project useful, feel free to star the repository!