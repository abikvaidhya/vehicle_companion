# vehicle_companion
<h1 align="center">
    <br>
    Vehicle Companion
</h1>
<h4 align="center">
Flutter + Kotlin / Jetpack Compose hybrid
</h4>
<hr>

## Purpose

A practical companion app for car owners. Log trips, track fuel/charging costs, set maintenance reminders, view trip history on a map, and explore Bluetooth integration.

This project is designed for the strong automotive / connected-vehicle ecosystem in Göteborg and demonstrates real hybrid skills that many Swedish companies use.

## What it shows:

- Clean Flutter architecture using GetX
- Native Android feature in Kotlin + Jetpack Compose
- Communication via MethodChannel and EventChannel
- Clear separation between UI, state, and platform code



## Dependencies

  cupertino_icons: ^1.0.2<br/>
  get:<br/>

## How to use

To clone and run this application, you'll need [Git](https://git-scm.com/downloads)
and [Flutter](https://flutter.dev/docs/get-started/install) installed on your computer.

### Clone this repo

```
gh repo clone abikvaidhya/vehicle_companion
```

### Navigate to the repo

```
cd vehicle_companion
```

### Install dependencies

```
flutter pub get
```

### Add your Google Maps API Key
goto vehicle_companion/android/local.properties
add 'MAP_API_KEY=<your API_key here>'

### Clean
```
flutter clean
flutter pub get
```

### Run the app
