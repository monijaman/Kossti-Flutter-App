# Kossti Flutter App

A multilingual Flutter mobile application for [kossti.com](https://kossti.com) — a product review platform supporting **English** and **Bengali (বাংলা)**.

## Features

- 🌐 **Multilingual** — English & Bengali (বাংলা) support
- 🏷️ **Product Browsing** — Browse, search, and filter products by category, brand, and price
- ⭐ **Product Reviews** — Read and write product reviews with ratings
- 📁 **Categories** — Browse all product categories
- 🏢 **Brands** — Explore products by brand
- 👤 **User Authentication** — Login, register, and manage your profile
- 🛠️ **Admin Dashboard** — Manage products, categories, brands, and reviews (admin only)
- 🌙 **Dark / Light Mode** — System-aware theme with manual override
- 📱 **Android-first** — Optimized Material Design 3 interface

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | Provider |
| HTTP Client | `http` package |
| Local Storage | `shared_preferences` |
| Image Loading | `cached_network_image` |
| Ratings UI | `flutter_rating_bar` |
| Localization | `flutter_localizations` |

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App colors, strings, API constants
│   ├── network/         # API client
│   └── theme/           # Light & dark themes
├── models/              # Data models (Product, Category, Brand, Review, User)
├── services/            # API service layer
├── providers/           # State management (ChangeNotifier)
├── screens/
│   ├── splash/          # Splash screen
│   ├── auth/            # Login & Register
│   ├── home/            # Home tab with search, featured, categories, brands
│   ├── products/        # Product list & detail
│   ├── categories/      # All categories
│   ├── brands/          # All brands
│   ├── profile/         # User profile
│   ├── settings/        # Language, theme, account settings
│   └── admin/           # Admin dashboard, manage products/categories/brands/reviews
├── widgets/
│   └── common/          # Reusable cards & UI components
└── main.dart            # App entry point
l10n/
├── app_en.arb           # English strings
└── app_bn.arb           # Bengali strings
```

## Getting Started

### Prerequisites

- **Flutter SDK ≥ 3.0.0**
- **Dart SDK ≥ 3.0.0**
- **Android Studio** (for Android development)
- **Android SDK** (API level 21 or higher)

### Installing Flutter (Windows)

1. Download Flutter SDK from [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
2. Extract the zip file to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH environment variable
4. Run `flutter doctor` to verify installation
5. Install Android Studio and set up an Android emulator

### Setup

```bash
# Clone the repository
git clone https://github.com/monijaman/Kossti-Flutter-App.git
cd Kossti-Flutter-App

# Install dependencies
flutter pub get

# Run the app (connect device or start emulator first)
flutter run
```

### API Configuration

Update the `baseUrl` in `lib/core/constants/app_constants.dart`:

```dart
// For local development:
static const String baseUrl = 'http://localhost:8080';

// For production:
static const String baseUrl = 'https://kossti.com';
```

**Note:** The app is configured to work with the Go backend (gocrit_server) API endpoints:
- `GET /products` — List products with pagination
- `GET /popular-products` — Featured products
- `GET /categories` — All categories
- `GET /brands` — All brands
- `GET /product-reviews?productId={id}` — Product reviews
- `POST /api/login` — User login
- `POST /api/register` — User registration

## Running Tests

```bash
flutter test
```

## Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Localization

The app supports **English (`en`)** and **Bengali (`bn`)**. Language files are in `l10n/`.

To add a new language:
1. Create `l10n/app_<locale>.arb`
2. Add the new `Locale` to `supportedLocales` in `main.dart`
3. Update the language selection in `lib/screens/settings/settings_screen.dart`
