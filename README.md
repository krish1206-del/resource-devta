## Resource-Devta (Flutter + Supabase)

### Setup
- **Prereqs**: Flutter SDK, Android Studio/Xcode, a Supabase project.
- **Env**: copy `.env.example` to `.env` and fill values.

### Run
```bash
flutter pub get
flutter run
```

### Platform permissions (manual)
- **Android**: add `ACCESS_FINE_LOCATION` to `android/app/src/main/AndroidManifest.xml`
- **iOS**: add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist`

### Supabase
- Apply `supabase/schema.sql` in the Supabase SQL editor.
- Create bucket(s) if you plan to store attachments.

