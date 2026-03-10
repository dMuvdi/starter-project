# Environment Setup

## Firebase Configuration

1. Get your Firebase config from Firebase Console → Project Settings → Your Apps
2. You'll need these values for Flutter setup:
   - `apiKey`
   - `authDomain`
   - `projectId`
   - `storageBucket`
   - `messagingSenderId`
   - `appId`

## Cloudinary Configuration

Store these values securely (never commit to git):

| Variable | Description | Where to Find |
|----------|-------------|---------------|
| `CLOUDINARY_CLOUD_NAME` | Your cloud name | Dashboard → Cloud Name |
| `CLOUDINARY_API_KEY` | API Key | Dashboard → API Key |
| `CLOUDINARY_API_SECRET` | API Secret | Dashboard → API Secret |
| `CLOUDINARY_UPLOAD_PRESET` | Unsigned upload preset | Settings → Upload → Upload Presets |

## Upload Presets

| Preset Name | Purpose | Folder |
|-------------|---------|--------|
| `symmetry_news_unsigned` | Article thumbnails | `/articles` |
| `symmetry_profiles_unsigned` | Profile pictures | `/profiles` |

## Flutter Environment Setup

Create a `.env` file in the `frontend` folder (add to `.gitignore`):

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned
```

Or use `--dart-define` when running:

```bash
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name --dart-define=CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned
```
