# Valid full-app status

Core app functionality is connected to Firebase Authentication and Cloud Firestore. Local expiry reminders are integrated with the current Flutter local-notifications API.

## Completed
- Auth: register, login, reset password, logout, session persistence
- Firestore: user profile, settings, documents, support messages
- Documents: add, edit, renew, delete, search, filters
- Expiry status: recalculated from the current date when cloud data loads
- Reminders: schedule, reschedule, cancel, test notification, permission handling
- Cloud refresh: profile/settings/documents reload from Firestore
- Security rules: per-user access under `users/{uid}`
- Existing polished UI retained

## One account-specific step
Run FlutterFire configure in this project so `lib/firebase_options.dart` receives your Firebase API configuration. This value cannot be reconstructed from a shared source ZIP alone.

## Intentionally local-only
Document photo selection is kept local. Cloud photo upload would require enabling Firebase Cloud Storage and may require a billed Firebase project. The rest of the app does not depend on Storage.
