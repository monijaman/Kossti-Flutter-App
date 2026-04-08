# Setup Guide for Kossti Flutter App

## Quick Start Checklist

### 1. Install Flutter
- [ ] Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
- [ ] Extract to `C:\flutter`
- [ ] Add `C:\flutter\bin` to PATH
- [ ] Run `flutter doctor` and fix any issues

### 1.5. Install Android Studio (for Android Development)
- [ ] Download Android Studio from [developer.android.com/studio](https://developer.android.com/studio)
- [ ] Run the installer (`android-studio-{version}.exe`)
- [ ] During installation, make sure to install:
  - Android SDK
  - Android SDK Platform
  - Android Virtual Device (AVD)
- [ ] On first launch, complete the Android Studio Setup Wizard:
  - Choose "Standard" installation type
  - Select your preferred theme
  - Let it download the Android SDK components (this may take 10-30 minutes)
- [ ] After installation, configure Flutter:
  ```bash
  flutter config --android-sdk C:\Users\{YourUsername}\AppData\Local\Android\Sdk
  ```
- [ ] Accept Android licenses:
  ```bash
  flutter doctor --android-licenses
  ```
  (Type `y` to accept all licenses)
- [ ] Run `flutter doctor` to verify Android setup is complete

### 2. Configure Backend API
- [ ] Update `baseUrl` in `lib/core/constants/app_constants.dart`
  - Local dev: `http://localhost:8080`
  - Production: `https://kossti.com`

### 3. Install Dependencies
```bash
cd i:\GO\kossti\Kossti-Flutter-App
flutter pub get
```

### 4. Create Android Emulator (First Time Only)
- [ ] Open Android Studio
- [ ] Click on "More Actions" → "Virtual Device Manager" (or "AVD Manager")
- [ ] Click "Create Device"
- [ ] Select a device (recommended: Pixel 5 or Pixel 6)
- [ ] Select a system image (recommended: latest Android API level with Google Play)
  - If not downloaded, click "Download" next to the system image
- [ ] Click "Next" → "Finish"
- [ ] Click the "Play" button to start the emulator

### 5. Run the App
```bash
# Make sure an Android emulator is running or device is connected
flutter devices

# Run the app
flutter run
```

## Backend Requirements

The Flutter app expects the Go backend (gocrit_server) to be running with these endpoints:

### Public Endpoints
- `GET /products?page=1&pageSize=20` — List products
- `GET /popular-products` — Featured products
- `GET /categories` — All categories
- `GET /brands` — All brands
- `GET /product-reviews?productId={id}` — Product reviews
- `GET /specifications?productId={id}` — Product specifications

### Authentication Endpoints
- `POST /api/login` — Login (body: `{email, password}`)
- `POST /api/register` — Register (body: `{name, email, password}`)
- `POST /api/v1/logout` — Logout (requires Bearer token)

### Authenticated Endpoints (Require `Authorization: Bearer {token}`)
- `GET /users` — Get current user
- `POST /product-reviews` — Create review
- `PUT /product-reviews/{id}` — Update review
- `DELETE /product-reviews/{id}` — Delete review

## Testing the Connection

1. Start your Go backend server
2. Update the `baseUrl` in `app_constants.dart`
3. Run the Flutter app
4. Check the home screen loads products

## Common Issues

### "Flutter command not found"
- Add Flutter to PATH: `C:\flutter\bin`
- Restart terminal after updating PATH

### "No devices found"
- Install Android Studio (see step 1.5 above)
- Create an AVD (Android Virtual Device) using AVD Manager
- Start the emulator before running `flutter run`
- Or connect a physical Android device with USB debugging enabled

### "Android SDK not found"
- Install Android Studio completely with SDK components
- Run: `flutter config --android-sdk C:\Users\{YourUsername}\AppData\Local\Android\Sdk`
- Replace `{YourUsername}` with your actual Windows username
- Run: `flutter doctor --android-licenses` and accept all

### "cmdline-tools component is missing"
- Open Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK
- Go to "SDK Tools" tab
- Check "Android SDK Command-line Tools (latest)"
- Click "Apply" to install

### "API connection failed"
- Verify Go backend is running
- Check `baseUrl` in `app_constants.dart`
- For localhost on Android emulator, use `http://10.0.2.2:8080` instead of `localhost:8080`

### "Localization files not generated"
- Run `flutter pub get` to generate localization files
- Check `l10n/app_en.arb` and `l10n/app_bn.arb` exist

## Optional: Add Custom Fonts

For better Bengali text rendering:
1. Download Cairo font from [Google Fonts](https://fonts.google.com/specimen/Cairo)
2. Place files in `assets/fonts/`:
   - `Cairo-Regular.ttf`
   - `Cairo-Bold.ttf`
3. Uncomment the fonts section in `pubspec.yaml`
4. Run `flutter pub get`

## Next Steps

1. **Test the app** — Browse products, search, filter
2. **Test authentication** — Register/login
3. **Test reviews** — Submit a review (requires login)
4. **Customize theme** — Modify colors in `lib/core/constants/app_colors.dart`
5. **Add app icon** — Use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
6. **Build release APK** — `flutter build apk --release`
