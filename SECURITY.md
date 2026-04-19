# Security

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Report privately via GitHub Security Advisories:
<https://github.com/fabioknoedt/YCFirstTime/security/advisories/new>

You can expect an acknowledgement within 7 days and a fix (or a
detailed response) within 30 days for any reproducible issue.

## Scope

This library writes to `UserDefaults.standard`. On jailbroken or
compromised devices, `UserDefaults` is trivially editable by the user,
so YCFirstTime is **not** a suitable gate for security-sensitive
decisions. Treat its state as a UX hint, not a trust boundary.

## Supported versions

Security fixes are published only for the latest `2.x` minor release.
Older versions are not maintained.
