# TODO: Fix "failed to fetch" on profile name edit

## Approved Plan Steps:
1. [x] Add debug logging to lib/services/api_service.dart (log statusCode, response body on error)
2. [x] Update lib/screens/edit_profile_screen.dart to show detailed error (status + message)
3. [x] Add error logging to php/api/auth/update.php (entry, token validation, DB errors)
4. [ ] flutter pub get
5. [ ] Test profile edit, capture Flutter logs & new error details
6. [ ] Test API endpoint directly (curl/Postman)
7. [ ] Check Hostinger cPanel error logs
8. [ ] Implement root cause fix based on logs (CORS, token, DB, network config)
9. [ ] [DONE] Remove debug logs, test final

Progress: Debug logging added to Flutter & PHP. Next: Run `flutter pub get && flutter run` (hot reload), try edit profile, share Flutter console logs / snackbar error / Hostinger logs.

