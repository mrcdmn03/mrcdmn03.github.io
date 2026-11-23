# Lingo Isles — Product Architecture Notes

The following is a **source-informed architecture overview**, not an independent production security audit.

## Application layers

1. **Presentation:** SwiftUI screens under `LingoIsles/UI` include Home, Learning Path, Adventure, Grammar, Practice, Pronunciation and Profile interfaces.
2. **Domain and state:** `Core` contains models and observable stores for progress, grammar academy, adventure tasks, vocabulary mastery, profile settings and rewards.
3. **Bundled learning data:** Versioned JSON assets package curriculum, grammar, vocabulary, listening, stories and missions inside the app.
4. **On-device capabilities:** UserDefaults retains local progress; AVFoundation supports audio playback, speech synthesis and optional voice recording.
5. **Optional iCloud backup:** CloudKit private database offers manual backup and restore for eligible profiles. The source says backup schema excludes voice recordings and contact data; production verification is still required.
6. **Optional marketing:** Adults may open a separately hosted Brevo form. The form is distinct from the learning progression and does not replace the local-first workflow.

## Design choices and trade-offs

- **Offline availability:** a bundled curriculum lets learning continue without a server.
- **Data minimisation:** optional cloud features are separated from core progression; the user can continue without them.
- **Gamification:** XP, streaks, coins and island building are product-engagement mechanisms, not formal language certifications.
- **Content integrity:** versioned JSON resources and regression tests help maintain stable learning paths.
- **Release constraints:** v6.3.2 source integration is not equivalent to signed Xcode builds, production CloudKit deployment, privacy compliance approval or verified marketing delivery.

## Privacy and public repository policy

The full application sources, local marketing configuration, historic cloud migrations and backend setup scripts are not included. This case study contains no API keys, credentials, service endpoints, user-account data or bulk proprietary curriculum content.
