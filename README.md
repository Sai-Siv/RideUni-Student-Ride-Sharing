# RideUni-Student-Ride-Sharing

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Mappls GL](https://img.shields.io/badge/Mappls-GL-2E7D32)
![Geoapify](https://img.shields.io/badge/Geoapify-API-8E44AD)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-555)

RideUni is a Flutter app for campus ride sharing. Students can offer rides or find rides to and from their university, college, or school.

## Features
- Offer or find rides with seat and price validation
- Map-based location picker with search and reverse geocoding
- Firebase authentication and Firestore-backed rides
- Profile, vehicles, wallet, and history pages

## Tech Stack
- Flutter (Dart)
- Firebase: `firebase_auth`, `cloud_firestore`, `firebase_core`
- Maps: `mappls_gl`
- Geocoding: Geoapify HTTP APIs
- Firebase: `firebase_auth`, `cloud_firestore`, `firebase_core`
- Maps: `mappls_gl`
- Geocoding: Geoapify HTTP APIs

## Configuration
Provide secrets via `--dart-define` (never commit keys):
- `MAPPLS_MAP_SDK_KEY`
- `MAPPLS_REST_API_KEY`
- `MAPPLS_ATLAS_CLIENT_ID`
- `MAPPLS_ATLAS_CLIENT_SECRET`
- `GEOAPIFY_API_KEY`

Firebase config files are required locally (ignored by Git):
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Setup
1. Install Flutter and run `flutter doctor`.
2. Create a Firebase project; enable Authentication and Firestore.
3. Download and place:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Obtain Mappls and Geoapify keys.


## Run
Single line (works everywhere):
```
flutter run --dart-define=MAPPLS_MAP_SDK_KEY=your_mapsdk_key --dart-define=MAPPLS_REST_API_KEY=your_restapi_key --dart-define=MAPPLS_ATLAS_CLIENT_ID=your_atlas_client_id --dart-define=MAPPLS_ATLAS_CLIENT_SECRET=your_atlas_client_secret --dart-define=GEOAPIFY_API_KEY=your_geoapify_key
```

Windows PowerShell (multi-line):
```
flutter run `
  --dart-define=MAPPLS_MAP_SDK_KEY=your_mapsdk_key `
  --dart-define=MAPPLS_REST_API_KEY=your_restapi_key `
  --dart-define=MAPPLS_ATLAS_CLIENT_ID=your_atlas_client_id `
  --dart-define=MAPPLS_ATLAS_CLIENT_SECRET=your_atlas_client_secret `
  --dart-define=GEOAPIFY_API_KEY=your_geoapify_key
```

Build APK:
```
flutter build apk --dart-define=MAPPLS_MAP_SDK_KEY=your_mapsdk_key --dart-define=MAPPLS_REST_API_KEY=your_restapi_key --dart-define=MAPPLS_ATLAS_CLIENT_ID=your_atlas_client_id --dart-define=MAPPLS_ATLAS_CLIENT_SECRET=your_atlas_client_secret --dart-define=GEOAPIFY_API_KEY=your_geoapify_key
```

## Screenshots

<p>
    <img src="assets/login.jpeg" alt="Onboarding" width="30%" />
  <img src="assets/home.jpeg" alt="Login" width="30%" />
  <img src="assets/profile.jpeg" alt="Profile" width="30%" />
  <img src="assets/myvechile.jpeg" alt="My Vehicles" width="30%" />
  <img src="assets/myride.jpeg" alt="My Ride" width="30%" />
</p>

## Architecture

```mermaid
flowchart LR
  App[Flutter App] --> Auth[Firebase Auth]
  App --> DB[Firestore]
  App --> Maps[Mappls GL SDK]
  App --> Geo[Geoapify HTTP APIs]

  subgraph UI
    Home[Home & Forms]
    Picker[Map Picker]
    Login[Login/Signup]
    Rides[Rides Listing]
  end

  Home --> DB
  Picker --> Maps
  Picker --> Geo
  Login --> Auth
  Rides --> DB
```

## Security
- Do not commit `google-services.json` or `GoogleService-Info.plist`.
- Use `--dart-define` for secrets; never hardcode keys.
- Keep keystores and signing files private.

## App Structure
- `lib/main.dart` — App init and Mappls keys
- `lib/home_screen.dart` — Find/Offer forms
- `lib/search_screen_selector.dart` — Map picker and search
- `lib/find_ride_details_page.dart` — Ride discovery
- `lib/ride_details_page.dart` — Create offered rides
- `lib/login_screen.dart` — Auth flows

## App Structure
- `lib/main.dart` — App init and Mappls keys
- `lib/home_screen.dart` — Find/Offer forms
- `lib/search_screen_selector.dart` — Map picker and search
- `lib/find_ride_details_page.dart` — Ride discovery
- `lib/ride_details_page.dart` — Create offered rides
- `lib/login_screen.dart` — Auth flows

## Troubleshooting
- If Firebase init fails, add platform config files.
- If maps/geocoding fail, set `--dart-define` values correctly.
#
