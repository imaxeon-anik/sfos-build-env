# Security

- Build only source you trust. RPM specs and build systems execute arbitrary commands.
- Clean staging is not a security sandbox. A malicious build can access the SDK host.
- Never expose a persistent self-hosted runner to untrusted pull requests or unrestricted pushes.
- Keep tokens minimal and short lived; checkout credentials are not persisted.
- Review logs and artifacts for secrets before sharing them, even in a private repository.
- Do not upload a personal VM, SDK installer, target image or proprietary dependency without
  checking redistribution terms and scrubbing all credentials and personal data.
- Scripts do not install onto phones, disable Sailjail, sign packages or publish releases.
- Report sensitive issues privately to the repository owner; do not include credentials in issues.