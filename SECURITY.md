# FitPulse security boundary

- Password fields are validated for UX only and are never stored or transmitted.
- Health and profile data currently stays in platform preferences on the member's device.
- Compressed meal-photo thumbnails stay on the device and are never uploaded by this build.
- Photo-derived nutrition values are labelled low-confidence and require member review.
- The offline coach is informational, identifies urgent symptom language, and does not diagnose.
- External exercise videos open on YouTube and are clearly attributed before navigation.
- Release builds deny administrator access until a trusted backend verifies an administrator role.
- Do not place API keys, admin secrets, service credentials, or private health data in source control.

Before a commercial launch, select a non-Firebase backend and complete threat modelling,
encrypted-at-rest storage, consent and retention policies, account deletion, audit logging,
rate limiting, abuse controls, observability, and independent security/privacy review.
