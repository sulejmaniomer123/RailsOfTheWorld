# Rails Of The World (macOS)

This folder contains the SwiftUI source files for a native macOS app that uses:
- Apple Maps (MapKit) for the base map
- OpenRailwayMap tile overlay for railways
- Nominatim for search (light usage)
- Overpass API for station info (light usage)

## How to run (Xcode)
1. Open Xcode and create a new **macOS > App** project.
2. Name it `RailsOfTheWorld` (bundle ID can be `com.yourname.railsoftheworld`).
3. Delete the auto-generated `ContentView.swift` and `RailsOfTheWorldApp.swift`.
4. Add the files from `Sources/` into your Xcode project (drag them in).
5. Add the `Info.plist` keys below to your app target.
6. Build and run.

## Required Info.plist entries
Add these to your target Info.plist:
- `NSLocationWhenInUseUsageDescription` = `We use your location to show nearby railways and stations.`

## Important: User-Agent
Public OSM services require a valid, identifying User-Agent. Update this line in `Sources/Network.swift`:
- `static let userAgent = "RailsOfTheWorld/0.1 (you@example.com)"`

## Attribution
OSM attribution is required and is displayed in the app UI.

## Notes
- Public Nominatim/Overpass/OpenRailwayMap endpoints are for light usage. Heavy usage should move to self-hosted or paid services.

## CI build (no Xcode needed locally)
This repo includes a GitHub Actions workflow that builds an unsigned `.app` and uploads it as an artifact.

Steps:
1. Create a GitHub repo and push this folder.
2. Go to the repo **Actions** tab and run the `build-macos` workflow (or push to `main`).
3. Download the `RailsOfTheWorld-macOS` artifact and unzip it.
4. Run the app with Finder or:
   `open RailsOfTheWorld.app`

Note: The build is unsigned, so Gatekeeper may require right‑click → Open the first time.
