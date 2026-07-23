# SG Bus Arrival

[![Swift 6.4](https://img.shields.io/badge/Swift-6.4-F05138?logo=swift&logoColor=white)](https://www.swift.org)
[![iOS 26](https://img.shields.io/badge/iOS-26%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![App Store](https://img.shields.io/badge/Download_on_the-App_Store-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/sg/app/sg-bus-arrival/id6760894143)

A modern, native iOS app for checking real-time Singapore bus arrivals. SG Bus Arrival provides nearby stops, route information, live maps, saved arrivals, and a home-screen widget in a focused, ad-free experience.

## Features

- Real-time arrival timings and bus occupancy information
- Nearby bus stops using the device's current location
- Searchable bus stops and bus services
- Detailed routes and stop sequences
- Live bus and route maps
- Saved arrivals for frequently used services
- Wheelchair-accessibility and monitored-arrival indicators
- Home-screen widget for quick arrival checks
- Local persistence with SwiftData

## Technology

- Swift 6.4
- SwiftUI
- Swift Concurrency
- SwiftData
- MapKit and Core Location
- WidgetKit and ActivityKit
- Swift Package Manager

Transit information is supplied by the [Land Transport Authority DataMall](https://datamall.lta.gov.sg/content/datamall/en.html).

## Requirements

- macOS with Xcode supporting iOS 26
- iOS 26 or later
- An [LTA DataMall](https://datamall.lta.gov.sg/content/datamall/en/request-for-api.html) account key

## Getting Started

1. Clone the repository.

   ```bash
   git clone https://github.com/jonahaung2/SgBusStops.git
   cd SgBusStops
   ```

2. Create the local secrets configuration.

   ```bash
   cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
   ```

3. Add your LTA DataMall account key to `Config/Secrets.xcconfig`.

   ```xcconfig
   PUBLIC_API_KEY = your_account_key
   ```

4. Open `SgBusStops.xcodeproj` in Xcode.

5. Select the `SgBusStops` scheme, configure your development team, and run the app.

`Config/Secrets.xcconfig` is intended for local credentials. Never commit a production API key.

## Project Structure

```text
SgBusStops/
├── Config/                 Build settings and local secrets template
├── Packages/
│   ├── Anima/             Animation effects and transitions
│   ├── Client/            Networking, repositories, and credential access
│   ├── Models/            Domain and persistence models
│   ├── Services/          App services, routing, location, and data storage
│   ├── SGToolTip/         Tooltip presentation
│   ├── SgMaps/            Singapore transit map resources
│   └── UI/                Shared SwiftUI components and styles
├── SgBusArrivalWidget/    Widget extension
├── SgBusStops/            Main application target
├── SgBusStopsTests/       Unit tests
├── SgBusStopsUITests/     UI tests
└── Shared/                Code shared by the app and widget
```

All local packages are tracked directly in this repository and resolve through relative Swift Package Manager paths.

## Privacy

Location access is used to find nearby bus stops. Review the app's [privacy policy](https://jonahaung2.github.io/sg-bus-app-privacy/) for more information.

## Download

[Download SG Bus Arrival on the App Store](https://apps.apple.com/sg/app/sg-bus-arrival/id6760894143)

## Author

Developed by [Aung Ko Min](https://github.com/jonahaung).
