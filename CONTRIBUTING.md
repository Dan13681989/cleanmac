# Contributing to CleanMac

We love your input! We want to make contributing to CleanMac as easy and transparent as possible.

## Development Setup

### Prerequisites
- macOS 11.0 or later
- Bash 4.0+
- Swift 5.0+ (for security modules)

### Getting Started
1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/cleanmac.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes and test thoroughly
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## Pull Request Process

1. Ensure your code follows existing style conventions
2. Update documentation for any new features
3. Add tests if possible (place in `scripts/test.sh`)
4. Update CHANGELOG.md with your changes
5. Request review from maintainers

## Code Style Guidelines

### Shell Scripts
- Use 2-space indentation
- Quote all variables: `"$variable"`
- Use `[[ ]]` for conditionals in bash
- Include shebang: `#!/bin/bash`

### Swift Code
- Follow Swift API design guidelines
- Use meaningful variable names
- Include documentation comments

## Reporting Bugs

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) and include:
- macOS version
- CleanMac version
- Steps to reproduce
- Expected vs actual behavior

## Suggesting Features

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) and describe:
- The problem you're solving
- Your proposed solution
- Alternative solutions considered

## Questions?

Open a discussion in GitHub Issues or contact the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
