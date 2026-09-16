# FitPulse AI Coach Architecture

## Overview

The FitPulse AI Coach is a **swappable service** that can route coaching responses through either:

1. **OmniRoute** (default) — 352+ AI providers, auto-fallback, free tokens
2. **Offline** — Deterministic, privacy-first fallback

Both implement the same `CoachService` interface, so swapping is transparent to the rest of the app.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│               FitPulse UI (Flutter)                      │
│  • CoachPage (chat modal)                              │
│  • Landing page ("Ask AI Coach" button)                 │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ↓
        ┌───────────────────────┐
        │  coachServiceProvider │ (Riverpod)
        │   (StateProvider)     │
        └───────┬───────────────┘
                │
        ┌───────┴────────┐
        │                │
        ↓                ↓
    ┌─────────────────┐  ┌──────────────────┐
    │ OmniRoute       │  │ Offline          │
    │ Coach Service   │  │ Coach Service    │
    │                 │  │                  │
    │ • HTTP to       │  │ • Deterministic  │
    │   OmniRoute     │  │ • Pattern match  │
    │ • Auto-fallback │  │ • No network     │
    │ • 352 providers │  │ • Safe defaults  │
    │ • Free tokens   │  │                  │
    └────────┬────────┘  └──────────────────┘
             │
             ↓
    ┌──────────────────────────────────┐
    │ OmniRoute Gateway (localhost:20128)
    │                                   │
    │ • Smart router (19 strategies)   │
    │ • Circuit breakers               │
    │ • Token compression (RTK+Caveman)│
    │ • Quota tracking                 │
    │ • Provider health                │
    └──────────────────────────────────┘
             │
             ↓
    ┌──────────────────────────────────┐
    │ 352+ AI Providers (Auto-fallback) │
    │                                   │
    │ Tier 1: Free (OpenCode, Mistral) │
    │ Tier 2: API Key (Claude, GPT)    │
    │ Tier 3: Cheap providers          │
    │ Tier 4: Subscriptions            │
    └──────────────────────────────────┘
```

---

## File Structure

```
lib/features/coach/
├── application/
│   └── coach_controller.dart       # Business logic (uses provider)
├── data/
│   ├── gemini_coach_service.dart   # Deprecated; kept for reference
│   ├── omniroute_coach_service.dart # ← OmniRoute implementation (ACTIVE)
│   └── offline_coach_service.dart  # Offline fallback + provider setup
├── domain/
│   ├── coach_message.dart          # Message model
│   └── coach_service.dart          # Interface
└── presentation/
    └── pages/
        └── coach_page.dart         # Chat UI
```

---

## Service Interface

All coach services implement `CoachService`:

```dart
abstract interface class CoachService {
  /// Produces a safe coaching response to [message].
  Future<String> respond(String message);
}
```

---

## Implementation Details

### OmniRouteCoachService

**Location:** `lib/features/coach/data/omniroute_coach_service.dart`

**Responsibilities:**
- Format requests for OmniRoute's OpenAI-compatible endpoint
- Handle retries on rate limits (429) with exponential backoff
- Timeout after 30 seconds
- Fall back to safe offline response on any network error
- Inject system prompt for FitPulse coaching persona

**Key features:**
- ✅ Configurable endpoint (local or remote)
- ✅ Model selection (`auto`, `auto/cheap`, `auto/fast`, etc.)
- ✅ Optional API key for paid tiers
- ✅ Graceful degradation (no crashes on network errors)
- ✅ Built-in retry logic with exponential backoff

**Example usage:**
```dart
final service = OmniRouteCoachService(
  endpoint: 'http://localhost:20128',
  model: 'auto',
  apiKey: null,  // free tiers work without keys
);

final response = await service.respond('How do I prevent shoulder pain?');
// Returns: "Stop exercising now. Seek urgent medical help..."
// or AI-generated response from OmniRoute
```

### OfflineCoachService

**Location:** `lib/features/coach/data/offline_coach_service.dart`

**Responsibilities:**
- Pattern-match user messages against a knowledge base
- Return deterministic, safe coaching responses
- Never make network requests
- Work without any external dependencies

**Response patterns:**
- Chest pain / breathing issues → Emergency response
- General pain / injury → Pause and consult clinician
- Tired / recovery → Rest and recovery guidance
- Nutrition / food → Balanced meal guidance
- Motivation / skip → Starting with the warm-up
- Weight / scale → Multi-signal tracking
- Default → Safe, encouraging message

**Example:**
```dart
final service = OfflineCoachService();
final response = await service.respond('I have chest pain');
// Always returns: "Stop exercising now. Seek urgent medical help..."
```

### Provider Setup

**Location:** `lib/features/coach/data/offline_coach_service.dart` (end of file)

```dart
/// Tracks whether OmniRoute is enabled (true) or offline-only (false).
final coachModeProvider = StateProvider<bool>((ref) => true);

/// Provides the currently selected coaching implementation.
final coachServiceProvider = Provider<CoachService>((ref) {
  final useOmniRoute = ref.watch(coachModeProvider);
  
  if (useOmniRoute) {
    return OmniRouteCoachService(endpoint: 'http://localhost:20128');
  } else {
    return OfflineCoachService();
  }
});
```

**Usage in UI:**
```dart
// In any widget:
final coach = ref.watch(coachServiceProvider);
final response = await coach.respond(userMessage);

// In settings, toggle mode:
ref.read(coachModeProvider.notifier).state = !enabled;
```

---

## Error Handling

### OmniRoute Network Errors

| Scenario | Behavior |
|----------|----------|
| OmniRoute not running | Returns safe offline response (<500ms) |
| Network timeout (>30s) | Retries once, then offline response |
| Rate limited (429) | Exponential backoff + retry (up to 2×) |
| Invalid response | Logs error, returns offline response |
| API error (500) | Falls back to offline response |

### Offline Mode

No errors—always returns a deterministic response from the pattern library.

---

## Testing Coach Services

### Unit Test Example (OmniRoute)

```dart
test('OmniRouteCoachService falls back on network error', () async {
  final service = OmniRouteCoachService(
    endpoint: 'http://invalid-host:99999',  // unreachable
  );
  
  final response = await service.respond('What should I do?');
  expect(response, contains('offline'));  // Falls back gracefully
});

test('OfflineCoachService returns injury guidance', () async {
  final service = OfflineCoachService();
  
  final response = await service.respond('I have knee pain');
  expect(response, contains('Pause'));
  expect(response, contains('clinician'));
});
```

---

## Performance Characteristics

| Metric | OmniRoute | Offline |
|--------|-----------|---------|
| Latency (p50) | 500–2000ms | 1–5ms |
| Latency (p95) | 2000–8000ms | 5–10ms |
| Network use | ~500B request + ~2KB response | 0 bytes |
| Tokens saved (compression) | 15–95% | N/A |
| Requires running server | ✅ Yes | ❌ No |
| Works offline | ❌ No | ✅ Yes |

---

## Future Enhancements

### Planned
- [ ] **Conversation memory** — Persist chat history in `SharedPreferences`
- [ ] **Multi-model comparison** — Fusion routing (panel of models)
- [ ] **Prompt caching** — Cache system prompt across requests (OmniRoute feature)
- [ ] **Analytics** — Track coaching effectiveness (e.g., "Did this help?")
- [ ] **A/B testing** — Test different system prompts / models

### Possible
- [ ] Local LLM fallback (Ollama, LLaMA.cpp)
- [ ] Voice input / output (speech-to-text, text-to-speech)
- [ ] Multi-language coaching (localized system prompts)
- [ ] Personalization (adapt responses to user fitness level)

---

## Debugging

### Check OmniRoute is running

```bash
curl http://localhost:20128/v1/models
# Should return a large JSON list of available models
```

### View OmniRoute dashboard

```
http://localhost:20128/dashboard
```

### Enable logging in FitPulse

Add debug prints in `OmniRouteCoachService`:
```dart
print('OmniRoute request: $payload');
print('OmniRoute response: ${response.statusCode}');
```

### Test with curl

```bash
curl -X POST http://localhost:20128/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "auto",
    "messages": [
      {"role": "user", "content": "Hello"}
    ]
  }'
```

---

## References

- **CoachService interface**: `lib/features/coach/domain/coach_service.dart`
- **Coach controller**: `lib/features/coach/application/coach_controller.dart`
- **Coach page UI**: `lib/features/coach/presentation/pages/coach_page.dart`
- **OmniRoute setup**: `docs/OMNIROUTE_SETUP.md`
- **OmniRoute project**: https://github.com/diegosouzapw/OmniRoute
