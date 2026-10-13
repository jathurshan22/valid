# Valid — Full Working Flutter App

Valid is a document expiry reminder app built with Flutter and Firebase.

## Working features

- Firebase Email/Password registration and sign-in
- Forgot-password email flow
- Persistent login session
- User profile stored in Firestore
- Per-user Firestore document storage
- Add, edit, renew and delete documents
- Search and filter saved documents
- Automatic Valid / Expiring soon / Expired status calculation
- Dashboard counts from real saved documents
- Local expiry notifications scheduled from each document reminder
- Reminder rescheduling after edit/renew
- Reminder cancellation after delete/logout
- Notification permission + test notification
- Cloud settings sync
- Cloud refresh screen
- Support messages stored under the signed-in user's Firestore account
- Camera/gallery document-photo picker (local preview only)

## Firebase project

This build targets:

`valid-document-reminder-2026`

Firebase configuration values are account/app-specific. The included `lib/firebase_options.dart` is a safe placeholder so the source project remains shareable. Generate the real file once on your PC:

```bat
"%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat" configure --project=valid-document-reminder-2026
```

Select Android (and any additional platforms you need). FlutterFire replaces `lib/firebase_options.dart` automatically.

Email/Password Authentication and Cloud Firestore must be enabled in Firebase Console. The project already contains `firestore.rules`.

Deploy the included rules if required:

```bat
firebase deploy --only firestore:rules
```

## Run

```bat
flutter clean
flutter pub get
flutter run
```

Or run `SETUP_AND_RUN.bat` after Firebase CLI / FlutterFire CLI are installed and logged in.

## Firestore structure

```text
users/{uid}
  name
  email
  settings
  documents/{documentId}
  supportMessages/{messageId}
```

Security rules only allow an authenticated user to access their own `users/{uid}` tree.

## Document photos

The camera/gallery picker is working, but document images are intentionally kept as local preview data in this build. Firebase Cloud Storage is not used, so the project does not require a Blaze billing upgrade just to run the core app.

## Notifications

Expiry reminders are local scheduled notifications. On Android, notification permission is requested at runtime and boot receivers are configured so scheduled reminders can survive device restarts.
