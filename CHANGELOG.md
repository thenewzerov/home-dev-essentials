# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-01-27

### Added
- New configuration keys to control Istio Helm chart flags without hardcoding a platform:
  - `APPLICATIONS.ISTIO.GLOBAL.PLATFORM` (any Istio-supported platform value, or `none`). Reference: https://istio.io/latest/docs/ambient/install/platform-prerequisites/
  - `APPLICATIONS.ISTIO.CNI.CHAINED` (e.g. `true|false|none`)
- Windows templating script: `scripts/template-substitute.ps1` to safely substitute template variables (including blank values) and emit derived placeholders.

### Changed
- Linux templating now:
  - Supports blank values and values containing `:`.
  - Escapes replacement values safely for `sed`.
  - Provides derived placeholders:
    - `${APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG}`
    - `${APPLICATIONS.ISTIO.CNI.CHAINED.SETARG}`
  - Keeps back-compat with the legacy typo key `APPLICATIONS.ISTIO.GLOBAL.PLATOFORM`.
- Istio deployment commands now use derived placeholders instead of hardcoding `--set global.platform=k3s`.
- cert-manager Helm install now waits with a timeout and disables Istio sidecar injection on the startup API check pod.

### Fixed
- Typo in README: “sidcar-less” -> “sidecar-less”.

### Security
- NGINX stream proxy timeout increased to 1 hour to reduce long-lived connection drops.
