# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of AudioGen seriously. If you discover a security vulnerability, please report it privately using GitHub's **Private Vulnerability Reporting** feature.

1. Navigate to the **Security** tab on the repository homepage.
2. Click on **Report a vulnerability**.
3. Fill out the form with details about the issue.

This allows us to discuss and fix the issue before it is disclosed to the public.

**Please do not report security vulnerabilities through public GitHub issues.**

## Important Security Considerations

AudioGen is designed as a **client-side macOS application**.

- **API Key Storage**: OpenAI API keys are stored securely in the macOS Keychain. They are never logged or exported.
- **Direct Communication**: The application communicates directly with OpenAI's API (`api.openai.com`) over HTTPS. No intermediate servers are used.
- **Data Privacy**: Audio generation requests are sent directly to OpenAI. Please refer to OpenAI's data usage policies regarding API usage.
- **Local Files**: Generated audio files and metadata are stored locally on your machine.

## Vulnerability Disclosure Process

We follow GitHub's coordinated disclosure process:
1. You privately report a vulnerability.
2. We acknowledge the report and begin investigation.
3. We will work with you to understand and fix the issue.
4. Once fixed, we will publish a security advisory and credit you for the discovery (if desired).
