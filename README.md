# Kossti Flutter App

A multilingual Flutter mobile application for [kossti.com](https://kossti.com) — a product review platform supporting **English** and **Arabic** with RTL layout support.

## Features

- 🌐 **Multilingual** — English & Arabic with full RTL support
- 🏷️ **Product Browsing** — Browse, search, and filter products by category, brand, and rating
- ⭐ **Product Reviews** — Write, view, and rate product reviews
- 📁 **Categories** — Browse all product categories
- 🏢 **Brands** — Explore products by brand
- 👤 **User Authentication** — Login, register, and manage your profile
- 🛠️ **Admin Dashboard** — Manage products, categories, brands, and reviews
- 🌙 **Dark / Light Mode** — System-aware with manual override

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
└── app_ar.arb           # Arabic strings
```

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Setup

```bash
# Clone the repository
git clone https://github.com/monijaman/Kossti-Flutter-App.git
cd Kossti-Flutter-App

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### API Configuration

Update the `baseUrl` in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://kossti.com/api';
```

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

The app supports English (`en`) and Arabic (`ar`). Language files are in `l10n/`.

To add a new language:
1. Create `l10n/app_<locale>.arb`
2. Add the new `Locale` to `supportedLocales` in `main.dart`
