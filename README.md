# TaskForge

TaskForge is an offline-first task manager and productivity dashboard built with Flutter. It includes task creation, editing, completion, deletion, search, category and priority filters, profile settings, analytics, and rule-based productivity insights.

## Run locally

Install the Flutter stable SDK, then run these commands from the project directory:

```sh
flutter pub get
flutter run -d chrome
```

For desktop or mobile, list available targets with `flutter devices`, then pass the selected device to `flutter run -d <device>`.

## Data storage

Android, iOS, Windows, Linux, and macOS use a local SQLite database. The web app stores tasks and the profile in the browser's local storage, so data remains after reloads in that browser. Browser data is local to that device and browser profile; it is not synced between devices. Clearing browser site data removes it.

## Deploy to GitHub Pages

The workflow at `.github/workflows/deploy.yml` builds the Flutter web app and publishes it to GitHub Pages whenever changes are pushed to `main` (it can also be started manually).

1. Push this project to a GitHub repository and make sure its default deployment branch is `main`.
2. In the repository, open **Settings → Pages** and set the build and deployment source to **GitHub Actions**.
3. Push a commit to `main`, or run **Deploy web app** from the repository's **Actions** tab.
4. When the workflow finishes, open the Pages URL shown in the workflow summary.

The workflow sets the repository subpath as Flutter's base URL, which supports standard project Pages URLs. For another static host, run `flutter build web --release --base-href /` and publish the contents of `build/web` to the host's web root. For a subdirectory, set `--base-href` to that directory including leading and trailing slashes.

## Native builds

Build Android with `flutter build apk --release`, iOS with `flutter build ios --release` on macOS, or Windows with `flutter build windows --release` on Windows. Store listings and signed distribution require platform-specific signing credentials.
