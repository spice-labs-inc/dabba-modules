# Security Policy

## Reporting a vulnerability

Please **do not open a public issue** for security problems. Report privately through GitHub:
on the repository's **Security** tab, choose **Report a vulnerability**. We'll acknowledge the
report and work a fix with you before any public disclosure.

## Supported versions

Security fixes target the latest released tag. Pin modules by tag (`?ref=vX.Y.Z`) and upgrade
to pick up fixes.

## Notes

These are OpenTofu modules; they provision clusters and install the platform's bootstrap layer.
They take no shipped credentials — the `git-server` admin password is a required input the
[`dabba`](https://github.com/spice-labs-inc/dabba) CLI generates per-environment. The broader
platform security model is documented in the
[dabba SECURITY policy](https://github.com/spice-labs-inc/dabba/blob/main/SECURITY.md).
