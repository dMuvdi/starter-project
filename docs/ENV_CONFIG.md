# Environment Configuration Guide

This document explains how to configure environment variables for the News App.

## Overview

The app uses build-time environment variables injected via `--dart-define` flags. This keeps sensitive data out of the repository while allowing easy configuration for different environments.

---

## Required Services

### 1. Cloudinary (Image Storage)

We use Cloudinary instead of Firebase Storage to reduce costs (free tier available).

**Setup Steps:**
1. Create a free account at [cloudinary.com](https://cloudinary.com)
2. Get your **Cloud Name** from the Dashboard
3. Go to **Settings → Upload → Upload Presets**
4. Click **Add upload preset**
5. Configure:
   - **Preset name:** `symmetry_news_unsigned`
   - **Signing Mode:** `Unsigned`
   - **Folder:** `articles`
6. Save the preset

**Required Variables:**
| Variable | Description |
|----------|-------------|
| `CLOUDINARY_CLOUD_NAME` | Your cloud name from Dashboard |
| `CLOUDINARY_UPLOAD_PRESET` | Upload preset name (default: `symmetry_news_unsigned`) |

---

### 2. News API (News Data)

We use NewsAPI.org to fetch news articles.

**Setup Steps:**
1. Create a free account at [newsapi.org](https://newsapi.org/register)
2. Get your **API Key** from the account page

**Required Variables:**
| Variable | Description |
|----------|-------------|
| `NEWS_API_KEY` | Your API key from NewsAPI.org |

---

### 3. Firebase

Firebase handles authentication (Firebase Auth) and database (Firestore).

**Setup Steps:**
1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Firestore Database** (start in test mode)
3. Enable **Authentication** → **Email/Password** provider
4. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Configure Firebase for Flutter:
   ```bash
   cd frontend
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` automatically.

6. Deploy Firestore security rules:
   ```bash
   cd backend
   firebase deploy --only firestore
   ```

**Note:** Firebase configuration is primarily handled by the auto-generated `firebase_options.dart` file. Optional overrides are available via environment variables.

---

## Running the App

### Development

```bash
cd frontend

flutter run \
  --dart-define=NEWS_API_KEY=your_news_api_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned \
  --dart-define=ENV=development
```

### Production

```bash
flutter run --release \
  --dart-define=NEWS_API_KEY=your_news_api_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned \
  --dart-define=ENV=production
```

### Using a Shell Script (Recommended)

Create a `run_dev.sh` script for convenience:

```bash
#!/bin/bash
# run_dev.sh - Run app in development mode

flutter run \
  --dart-define=NEWS_API_KEY=your_news_api_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned \
  --dart-define=ENV=development
```

Make it executable:
```bash
chmod +x run_dev.sh
./run_dev.sh
```

---

## Environment Variables Reference

### Required Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NEWS_API_KEY` | **Yes** | - | NewsAPI.org API key |
| `CLOUDINARY_CLOUD_NAME` | **Yes** | - | Cloudinary cloud name |
| `CLOUDINARY_UPLOAD_PRESET` | No | `xg3gxg9w` | Upload preset for images |
| `ENV` | No | `development` | Environment: `development` or `production` |

### Optional Firebase Overrides

These are optional and only needed if you want to override `firebase_options.dart`:

| Variable | Description |
|----------|-------------|
| `FIREBASE_API_KEY` | Firebase API Key |
| `FIREBASE_PROJECT_ID` | Firebase Project ID |
| `FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase Messaging Sender ID |
| `FIREBASE_APP_ID` | Firebase App ID |

---

## For Reviewers

To run this project:

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd starter-project
   ```

2. **Set up Firebase**
   ```bash
   cd frontend
   flutterfire configure
   ```

3. **Set up Cloudinary**
   - Create account at [cloudinary.com](https://cloudinary.com)
   - Note your Cloud Name
   - Create unsigned upload preset

4. **Set up News API**
   - Create account at [newsapi.org](https://newsapi.org/register)
   - Note your API Key

5. **Deploy backend rules**
   ```bash
   cd backend
   firebase deploy --only firestore
   ```

6. **Run the app**
   ```bash
   cd frontend
   flutter run \
     --dart-define=NEWS_API_KEY=your_news_api_key \
     --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
     --dart-define=ENV=development
   ```

---

## Troubleshooting

### "Missing required environment variables" Error

Make sure you're passing the `--dart-define` flags when running:
```bash
flutter run \
  --dart-define=NEWS_API_KEY=your_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_name
```

### Firebase not configured

Run `flutterfire configure` to generate `firebase_options.dart`.

### Cloudinary upload fails

1. Verify your cloud name is correct
2. Ensure the upload preset exists and is set to "Unsigned"
3. Check that the preset folder matches your configuration

---

## Security Notes

- Never commit actual credentials to the repository
- Use `--dart-define` for build-time injection
- The `.env.example` file shows required variables without actual values
- Firebase credentials in `firebase_options.dart` are safe to commit (they're restricted by Firebase Security Rules)
