# Android build from GitHub Actions

This project is configured for Godot 4.6.2 and an Android debug APK build.

## What is committed

- `project.godot`
- `export_presets.cfg`
- `.github/workflows/android-debug.yml`
- Project assets, scenes, scripts, and `.import` metadata

The `.godot/` directory is intentionally excluded because it is editor-generated state.

## Build from GitHub

1. Create a GitHub repository.
2. Push the project folder to the repository.
3. Push to `main` (or `master`) or run the workflow manually from **Actions → Android Debug APK → Run workflow**.
4. Open the completed workflow run.
5. In **Artifacts**, download `Akhoond-V1-debug-apk`.
6. The artifact contains `Akhoond-V1-debug.apk`.

The workflow installs Android SDK components, Java 17, Godot 4.6.2, and matching export templates on the GitHub runner. It creates a temporary debug keystore during the build; no signing key is stored in the repository.

## Local export

In Godot, open **Project → Export**, select the existing Android preset, and use **Export Project**. For a test build, keep **Export With Debug** enabled and do not use **Export As Patch**.

## Release later

For Google Play release, create and protect a real release keystore. Do not commit the keystore or passwords. Store them as GitHub Actions secrets and switch the workflow to a release build/AAB when the project is ready for publication.
