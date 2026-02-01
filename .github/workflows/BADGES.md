# GitHub Actions Status Badges

Add these badges to your `README.md` to show the build status:

## CI/CD Pipeline Badge

```markdown
![CI/CD Pipeline](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg)
```

Replace `YOUR_USERNAME` with your GitHub username.

## Individual Job Badges

You can also create badges for specific jobs:

### Pre-checks Badge
```markdown
![Pre-checks](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg?job=prechecks)
```

### Security Checks Badge
```markdown
![Security](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg?job=security-checks)
```

### Tests Badge
```markdown
![Tests](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg?job=unit-tests)
```

### Android Build Badge
```markdown
![Android Build](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg?job=build-android)
```

## Usage in README.md

Add to the top of your README.md:

```markdown
# Hobbyist

[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Track your hobbies with GitHub-style contribution charts.

...rest of README...
```

## Alternative Shields.io Badges

You can also use shields.io for more customization:

```markdown
![Build](https://img.shields.io/github/actions/workflow/status/YOUR_USERNAME/hobbyist/ci.yml?branch=main&label=build&style=flat-square)
![Tests](https://img.shields.io/github/actions/workflow/status/YOUR_USERNAME/hobbyist/ci.yml?branch=main&label=tests&style=flat-square)
```

## Branch-Specific Badges

To show status for specific branches:

### Main Branch
```markdown
![Main Branch](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg?branch=main)
```

### Develop Branch
```markdown
![Develop Branch](https://github.com/YOUR_USERNAME/hobbyist/actions/workflows/ci.yml/badge.svg?branch=develop)
```
