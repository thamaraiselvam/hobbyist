# GitHub Actions CI/CD Pipeline

This directory contains the CI/CD pipeline configuration for the Hobbyist app.

## Pipeline Overview

The pipeline runs automatically on:
- Pushes to `main` or `develop` branches
- Pull requests targeting `main` or `develop` branches
- Manual triggers via workflow dispatch

## Pipeline Jobs

### 1. Pre-checks
- **Flutter Analyze**: Checks for code quality issues and potential bugs
- **Dart Format Check**: Ensures consistent code formatting

### 2. Security Checks
- **Dependency Audit**: Checks for outdated dependencies and vulnerabilities
- **Secret Scanning**: Scans for accidentally committed secrets (API keys, passwords)
- **Security TODOs**: Identifies security-related TODO items

### 3. Unit Tests
- Runs all unit tests from `test/unit/`
- Runs widget tests from `test/widget/`
- Generates code coverage report
- Uploads coverage report as artifact

### 4. Integration Tests
- Builds integration test APK
- Note: Actual test execution requires emulator/device (run locally)

### 5. Build Android
- Builds both debug and release APKs
- Renames APKs to `hobbyist-debug.apk` and `hobbyist-release.apk`
- Uploads both APKs as downloadable artifacts
- Artifacts are retained for 30 days

### 6. Build iOS (Currently Disabled)
- iOS build job is commented out
- Requires macOS runner and proper code signing setup
- Enable by uncommenting the job and setting `if: true`

### 7. Build Summary
- Generates a summary of all job results
- Lists downloadable artifacts

## Downloading APKs

After a successful pipeline run:

1. Go to the **Actions** tab in GitHub
2. Click on the completed workflow run
3. Scroll to the **Artifacts** section
4. Download:
   - `hobbyist-debug-apk` - Debug build for testing
   - `hobbyist-release-apk` - Release build for distribution
   - `coverage-report` - Test coverage data

## Running Locally

### Pre-checks
```bash
flutter analyze
dart format --set-exit-if-changed .
```

### Security Checks
```bash
flutter pub outdated
grep -r "api[_-]key\s*=\s*['\"]" lib/
```

### Tests
```bash
# Unit tests
flutter test test/unit/ --coverage

# Widget tests
flutter test test/widget/

# Integration tests (requires device/emulator)
flutter test integration_test/
```

### Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## Pipeline Configuration

### Flutter Version
- Version: 3.24.0
- Channel: stable

### Java Version (Android builds)
- Distribution: Zulu
- Version: 17

### Artifact Retention
- All artifacts are kept for 30 days

## Enabling iOS Builds

To enable iOS builds:

1. Open `.github/workflows/ci.yml`
2. Uncomment the `build-ios` job
3. Change `if: false` to `if: true`
4. Add code signing certificates as GitHub secrets:
   - `IOS_CERTIFICATE_BASE64`
   - `IOS_PROVISIONING_PROFILE_BASE64`
   - `IOS_CERTIFICATE_PASSWORD`
5. Update the build-ios job with signing configuration

## Troubleshooting

### Pipeline Fails on Format Check
Run locally: `dart format .` to format all files

### Pipeline Fails on Analyze
Run locally: `flutter analyze` to see issues

### Tests Fail in CI but Pass Locally
- Check Flutter version matches (3.24.0 stable)
- Ensure all dependencies are in `pubspec.yaml`
- Check for environment-specific code

### APK Download Issues
- Artifacts expire after 30 days
- Re-run the workflow to generate new artifacts
- Check artifact size limits (GitHub has limits)

## Customization

### Change Flutter Version
Edit the `flutter-version` in each job:
```yaml
uses: subosito/flutter-action@v2
with:
  flutter-version: '3.24.0'  # Change this
```

### Add More Security Checks
Add steps to the `security-checks` job:
```yaml
- name: Custom security check
  run: your-command-here
```

### Modify Artifact Retention
Change `retention-days`:
```yaml
uses: actions/upload-artifact@v4
with:
  retention-days: 30  # Change this
```

## CI/CD Best Practices

1. **Always run locally first**: Test changes locally before pushing
2. **Keep secrets secure**: Never commit API keys or passwords
3. **Monitor pipeline performance**: Optimize slow steps
4. **Review artifacts regularly**: Clean up old artifacts
5. **Update dependencies**: Keep Flutter and packages up to date

## Support

For issues with the pipeline:
1. Check the Actions logs for detailed error messages
2. Ensure all required secrets are configured
3. Verify Flutter version compatibility
4. Test locally with the same Flutter version

## Future Enhancements

Potential improvements:
- [ ] Add automated deployment to Play Store
- [ ] Add automated deployment to App Store
- [ ] Integrate code coverage reporting (Codecov/Coveralls)
- [ ] Add automated changelog generation
- [ ] Set up nightly builds
- [ ] Add performance testing
- [ ] Integrate security scanning tools (Snyk, etc.)
