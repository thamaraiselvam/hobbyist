# Quick Start Guide - CI/CD Pipeline

## 🚀 Getting Started

### 1. Push to GitHub
```bash
git add .github/
git commit -m "feat: Add CI/CD pipeline with GitHub Actions"
git push origin main
```

### 2. View Pipeline
1. Go to your GitHub repository
2. Click on the **Actions** tab
3. You should see the "CI/CD Pipeline" workflow running

### 3. Monitor Progress
The pipeline will execute these jobs in order:
1. ✅ Pre-checks (analyze & format)
2. 🔒 Security Checks
3. 🧪 Unit Tests
4. 📦 Build Android APK

### 4. Download APKs
After successful build:
1. Click on the completed workflow run
2. Scroll to **Artifacts** section
3. Download:
   - `hobbyist-debug-apk` - For testing
   - `hobbyist-release-apk` - For release
   - `coverage-report` - Test coverage

## 🔧 Local Testing

Before pushing, test locally:

```bash
# 1. Run pre-checks
flutter analyze
dart format --set-exit-if-changed .

# 2. Run tests
flutter test test/unit/ --coverage
flutter test test/widget/

# 3. Build APK
flutter build apk --debug
```

## ⚡ Manual Trigger

To manually trigger the pipeline:
1. Go to **Actions** tab
2. Click on "CI/CD Pipeline"
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## 📊 Pipeline Results

### Success ✅
All jobs pass, APKs available for download

### Failure ❌
Check the failed job logs:
1. Click on the failed workflow run
2. Click on the failed job
3. Expand the failed step
4. Review error messages
5. Fix locally and push again

## 🎯 Common Issues

### Format Check Fails
```bash
# Fix locally
dart format .
git add .
git commit -m "style: Format code"
git push
```

### Analyze Fails
```bash
# Check issues locally
flutter analyze

# Fix issues in code
# Then commit and push
```

### Tests Fail
```bash
# Run tests locally
flutter test

# Fix failing tests
# Then commit and push
```

## 📦 APK Installation

### Debug APK
```bash
# Download from artifacts
# Install on device
adb install hobbyist-debug.apk
```

### Release APK
```bash
# Download from artifacts
# Sign if needed (for production)
# Install on device
adb install hobbyist-release.apk
```

## 🔄 Continuous Integration

The pipeline runs automatically on:
- Every push to `main` or `develop`
- Every pull request to `main` or `develop`
- Manual workflow dispatch

## 📈 Next Steps

1. **Add Status Badge** to README.md:
   ```markdown
   ![CI/CD](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg)
   ```

2. **Set up Branch Protection**:
   - Require CI to pass before merge
   - Require pull request reviews

3. **Configure Secrets** (if needed):
   - Go to Settings → Secrets → Actions
   - Add signing keys, API keys, etc.

4. **Enable iOS builds** (when ready):
   - Uncomment iOS job in `ci.yml`
   - Add code signing certificates
   - Set `if: true` for the job

## 💡 Tips

- **Cache Dependencies**: The pipeline caches Flutter and Gradle to speed up builds
- **Artifact Retention**: APKs are kept for 30 days by default
- **Parallel Jobs**: Some jobs run in parallel to save time
- **Coverage Reports**: Download coverage reports to analyze test coverage
- **Workflow Logs**: All logs are retained for 90 days

## 🆘 Getting Help

If you encounter issues:
1. Check workflow logs in Actions tab
2. Review the README.md in workflows directory
3. Test locally with same Flutter version (3.24.0)
4. Check GitHub Actions documentation

## 📝 Customization

Edit `.github/workflows/ci.yml` to:
- Change Flutter version
- Modify test commands
- Add more checks
- Change artifact retention
- Customize build steps

Happy building! 🎉
