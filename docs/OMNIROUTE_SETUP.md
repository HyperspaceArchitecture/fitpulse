# FitPulse + OmniRoute AI Coach Setup

FitPulse AI Coach is powered by **OmniRoute**, a free MIT gateway that unifies 352+ AI providers (150+ free) through one endpoint.

## What is OmniRoute?

<cite index="5-1">OmniRoute provides one endpoint across 352 AI providers including Claude, GPT-5, Gemini, Kimi K3, DeepSeek, Qwen, and others—with auto-fallback, token compression (15-95% savings), and ~1.47B free tokens per month from 150+ free tiers.</cite>

**Key benefits for FitPulse:**
- ✅ **Free** — No API keys required; free tiers (OpenCode, Mistral, Groq) work out of the box
- ✅ **Resilient** — Auto-fallback if one provider hits quota or rate limits
- ✅ **Smart routing** — OmniRoute picks the best provider (`auto` model)
- ✅ **Token savings** — RTK + Caveman compression saves 15–95% on eligible workloads
- ✅ **Graceful offline** — If OmniRoute is down, AI Coach falls back to safe offline responses

---

## Quick Setup (3 minutes)

### 1. Install OmniRoute

```bash
npm install -g omniroute
```

### 2. Start OmniRoute server

```bash
omniroute
# Listening on http://localhost:20128
```

> **Tip:** Leave this running in a terminal while developing FitPulse.

### 3. Run FitPulse

```bash
cd /path/to/fitpulse
flutter pub get
flutter run
```

The AI Coach will now route requests through OmniRoute. No additional config needed! 🚀

---

## How It Works

### Request Flow

```
FitPulse (Flutter)
    ↓
    └─→ OmniRouteCoachService
         └─→ http://localhost:20128/v1/chat/completions
              └─→ OmniRoute Smart Router (19 strategies)
                   └─→ 352+ AI Providers (auto-fallback)
                        ├─ Tier 1: Free (OpenCode, Mistral, Groq, etc.)
                        ├─ Tier 2: API Key (if you add one)
                        ├─ Tier 3: Cheap ($0.01–0.10 per million tokens)
                        └─ Tier 4: Subscription (Claude, GPT, Gemini)
```

### Offline Fallback

If OmniRoute is unavailable (network down, server not running), `OmniRouteCoachService` gracefully falls back to a safe offline response in **<500ms**.

---

## Configuration

### Local vs Remote OmniRoute

By default, FitPulse looks for OmniRoute at `http://localhost:20128`.

To use a **remote OmniRoute** (VPS, cloud, Tailnet):

```dart
// In lib/features/coach/data/offline_coach_service.dart
return OmniRouteCoachService(
  endpoint: 'http://192.168.1.100:20128',  // or https://omniroute.example.com
  model: 'auto',
  apiKey: 'your_omniroute_key',  // optional; free tiers don't need one
);
```

### Routing Strategy

The `model` parameter controls OmniRoute's routing:

| Model | What it does |
|-------|-------------|
| `auto` | OmniRoute picks the best provider (default, recommended) |
| `auto/cheap` | Lowest cost first |
| `auto/fast` | Lowest latency first |
| `auto/offline` | Most remaining quota first |
| `claude-opus-4-8` | Force a specific model |
| `kimi-k3` | Force a specific provider model |

---

## Adding an API Key (Optional)

Free tiers work without credentials. To unlock paid providers (Claude Opus, GPT-5, etc.):

1. **Generate an OmniRoute API key**:
   ```bash
   omniroute setup-claude
   # or manually at dashboard: http://localhost:20128/dashboard/tokens
   ```

2. **Pass it to FitPulse**:
   ```dart
   return OmniRouteCoachService(
     endpoint: 'http://localhost:20128',
     model: 'auto',
     apiKey: 'oma_live_xxx',  // from step 1
   );
   ```

---

## Toggle Coach Mode (Settings)

Users can switch between OmniRoute and offline-only from **Settings → Theme**:

```dart
// In settings_page.dart (example)
Switch(
  value: ref.watch(coachModeProvider),
  onChanged: (value) {
    ref.read(coachModeProvider.notifier).state = value;
  },
  title: 'AI Coach',
  subtitle: value ? 'Online (OmniRoute)' : 'Offline only',
),
```

---

## Monitoring Usage

Open the OmniRoute dashboard:
```
http://localhost:20128/dashboard
```

You'll see:
- ✅ Free token budget (~1.47B/month)
- ✅ Live usage + remaining quota
- ✅ Cost savings from compression
- ✅ Per-provider health & latency
- ✅ Requests and fallback events

---

## Deployment

### Local Development
```bash
omniroute  # Terminal 1
flutter run  # Terminal 2
```

### Remote VPS / Cloud
```bash
# On your VPS:
docker run -p 20128:20128 diegosouzapw/omniroute:latest

# In FitPulse, point to your server:
return OmniRouteCoachService(
  endpoint: 'https://omniroute.your-domain.com',
);
```

### Docker Compose
```yaml
version: '3'
services:
  omniroute:
    image: diegosouzapw/omniroute:latest
    ports:
      - "20128:20128"
  fitpulse_backend:
    # Your FitPulse backend (if any)
    environment:
      OMNIROUTE_URL: http://omniroute:20128
```

---

## Troubleshooting

### "Connection refused" at localhost:20128

**Fix:** Start OmniRoute:
```bash
omniroute
```

### "429 Rate Limited" (too many requests)

**Fix:** OmniRoute auto-retries with backoff. If quota is exhausted:
- Wait for the reset window (visible in dashboard)
- Or add an API key to unlock paid tiers

### Responses are slow

**Try:**
1. Check latency in dashboard: `http://localhost:20128/dashboard`
2. Switch routing: `model: 'auto/fast'` (lowest latency first)
3. Run OmniRoute locally (not over network)

### "OmniRoute is offline" fallback response

This is **intentional**—the app gracefully degrades:
- ✅ User still gets a helpful offline message
- ✅ No crashes or error screens
- ✅ AI Coach comes back when OmniRoute recovers

---

## Free Tier Breakdown

OmniRoute catalogs 444 free-tier entries across 34 recurring pool keys:

| Provider | Tokens/month | Model |
|----------|-------------|-------|
| Mistral | 500M | `mistral-small`, `mistral-large` |
| Groq | 300M | `llama-3.1-70b`, `mixtral-8x7b` |
| OpenCode | 250M | `oc/openchat-3.5` |
| GLM (Qwen) | 150M | `glm-5.2`, `qwen-plus` |
| DeepSeek | 100M | `deepseek-chat` |
| +6 more | +300M | Mixed |
| **Total** | **~1.47B** | — |

All share one endpoint. OmniRoute auto-routes based on availability, quota, latency, and cost.

---

## Further Reading

- **OmniRoute GitHub**: https://github.com/diegosouzapw/OmniRoute
- **Auto-Combo Engine**: https://github.com/diegosouzapw/OmniRoute/blob/main/docs/routing/AUTO-COMBO.md
- **Free Tiers Catalog**: https://github.com/diegosouzapw/OmniRoute/blob/main/docs/reference/FREE_TIERS.md
- **CLI Integrations**: https://github.com/diegosouzapw/OmniRoute/blob/main/docs/guides/CLI-INTEGRATIONS.md
- **Resilience**: https://github.com/diegosouzapw/OmniRoute/blob/main/docs/architecture/RESILIENCE_GUIDE.md

---

## Questions?

- **OmniRoute Support**: [Discord](https://discord.gg/U47eFqAXCn) | [Telegram](https://t.me/omnirouteOficial)
- **FitPulse Issues**: [GitHub Issues](https://github.com/HyperspaceArchitecture/fitpulse/issues)
