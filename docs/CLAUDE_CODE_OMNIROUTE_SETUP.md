# FitPulse: Claude Code + OmniRoute Setup

Use **Claude Code** as your IDE for FitPulse development, powered by **OmniRoute** for free AI models.

---

## What This Gives You

- 🤖 Claude Code IDE (write Dart, debug, test)
- 🚀 Backed by 352+ AI providers (150+ free)
- 💰 ~1.47B free tokens/month
- ⚡ Auto-fallback + token compression
- 🔄 Same endpoint as FitPulse AI Coach (`localhost:20128`)

---

## Setup (5 minutes)

### 1. Start OmniRoute Server

```bash
npm install -g omniroute
omniroute
# Listening on http://localhost:20128
```

### 2. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 3. Configure Claude Code to Use OmniRoute

**Option A: Quick Setup (Recommended)**

```bash
omniroute setup-claude
# Writes ~/.claude/profiles/<name>/settings.json for each model
```

Then launch with OmniRoute:
```bash
omniroute launch
# Claude Code starts with OmniRoute configured automatically
```

**Option B: Manual Configuration**

Set environment variables:

```bash
export ANTHROPIC_BASE_URL=http://localhost:20128
export ANTHROPIC_AUTH_TOKEN=oma_live_xxx  # optional; free tiers don't need one
claude
```

**Option C: Per-Profile (Advanced)**

Create `~/.claude/profiles/omniroute/settings.json`:

```json
{
  "models": [
    {
      "id": "claude-opus-4-8",
      "title": "Claude Opus (OmniRoute)",
      "provider": "anthropic",
      "baseUrl": "http://localhost:20128",
      "apiKey": "oma_live_xxx"
    }
  ]
}
```

Then launch:
```bash
CLAUDE_CONFIG_DIR=~/.claude/profiles/omniroute claude
```

---

## Using Claude Code with FitPulse

### 1. Open FitPulse repo

```bash
cd /path/to/fitpulse
claude  # Opens Claude Code in this directory
```

### 2. Explore OmniRoute-integrated files

Claude Code can now see:
- ✅ `lib/features/coach/data/omniroute_coach_service.dart` — New OmniRoute service
- ✅ `docs/OMNIROUTE_SETUP.md` — Setup guide
- ✅ `docs/COACH_ARCHITECTURE.md` — Architecture docs
- ✅ `pubspec.yaml` — Added `http` dependency

### 3. Get AI assistance

Ask Claude Code:
- "Explain the OmniRoute coach service"
- "How does the offline fallback work?"
- "Add caching to OmniRouteCoachService"
- "Write tests for the coach service"

Claude Code uses OmniRoute's 352+ providers to respond.

---

## Common Workflows

### Debug OmniRoute Coach Service

```bash
# 1. Open file in Claude Code
claude lib/features/coach/data/omniroute_coach_service.dart

# 2. Ask Claude Code
# "Why might this fall back to offline?"
# "Add retry logging"
# "Test this with a timeout"

# 3. Claude Code suggests changes using OmniRoute models
```

### Generate Tests

```bash
# In Claude Code, open coach_page.dart and ask:
# "Generate unit tests for OmniRouteCoachService"
# "Create an integration test for the chat modal"

# Claude Code (via OmniRoute) generates code
```

### Refactor Code

```bash
# Ask Claude Code:
# "Refactor OmniRouteCoachService to use async/await instead of .then()"
# "Extract the retry logic into a separate function"
# "Add better error logging"

# Claude Code refactors using OmniRoute models
```

### Understand Architecture

```bash
# Ask Claude Code:
# "Explain how the coach service provider works"
# "Draw a diagram of the coaching flow"
# "What happens if OmniRoute is down?"

# Claude Code explains using OmniRoute models
```

---

## Routing Strategies with Claude Code

Control which AI models Claude Code uses:

| Strategy | Command |
|----------|---------|
| **Default (balanced)** | `omniroute launch` |
| **Fastest** | `OMNIROUTE_MODEL=auto/fast omniroute launch` |
| **Cheapest** | `OMNIROUTE_MODEL=auto/cheap omniroute launch` |
| **Most quota** | `OMNIROUTE_MODEL=auto/offline omniroute launch` |
| **Specific model** | `OMNIROUTE_MODEL=kimi-k3 omniroute launch` |

---

## Dashboard Monitoring

While Claude Code is working:

```bash
# In another terminal
open http://localhost:20128/dashboard
```

Watch real-time:
- 📊 Tokens used by Claude Code
- 💰 Cost savings from compression
- 📈 Which providers Claude Code is using
- 🔄 Fallback events
- ⏱️ Response latency

---

## Keyboard Shortcuts (Claude Code + OmniRoute)

| Action | Shortcut |
|--------|----------|
| Open file | `Cmd+P` (Mac) / `Ctrl+P` (Windows/Linux) |
| Chat with Claude | `Cmd+K` (Mac) / `Ctrl+K` (Windows/Linux) |
| Explain code | Highlight code → right-click → "Ask Claude" |
| Generate tests | `Cmd+Shift+T` (if enabled) |
| Refactor | Select code → `Cmd+K` → "Refactor this" |

---

## Example: Debug Coach Service in Claude Code

### Step 1: Open file
```bash
claude lib/features/coach/data/omniroute_coach_service.dart
```

### Step 2: Chat with Claude Code
```
Q: "Why does _fallbackResponse get called when OmniRoute is running?"

Claude Code (via OmniRoute) responds:
"Looking at the code, _fallbackResponse is called in the catch block when:
1. HTTP request times out (30s limit)
2. Response status is not 200
3. Response body is empty
4. Any network exception occurs

To debug:
- Check http://localhost:20128/dashboard for OmniRoute health
- Add print() statements before the try block
- Test with curl: curl http://localhost:20128/v1/models"
```

### Step 3: Implement suggestions
Claude Code can generate the logging code.

---

## Troubleshooting

### "Connection refused" at localhost:20128

```bash
# Verify OmniRoute is running
curl http://localhost:20128/v1/models

# If not, start it
omniroute
```

### Claude Code is slow

**Try:**
```bash
OMNIROUTE_MODEL=auto/fast omniroute launch
# Forces fastest provider first
```

### Claude Code shows wrong model in picker

Ensure `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`:

```bash
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1
omniroute launch
```

### "Unauthorized" or auth errors

**Fix 1:** Use free tiers (no auth needed):
```bash
omniroute launch
# Claude Code uses OpenCode, Mistral, Groq, etc.
```

**Fix 2:** Add an API key:
```bash
omniroute setup-claude
# Generates profiles with auth
omniroute launch --profile glm52
```

---

## Advanced: Remote OmniRoute

If you're running OmniRoute on a VPS or remote server:

```bash
# Connect to remote OmniRoute
omniroute connect http://your-omniroute-server.com:20128 --api-key oma_live_xxx

# Claude Code now uses the remote gateway
omniroute launch --remote
```

All your development tools (Claude Code, Claude Desktop, FitPulse) route through the same remote gateway.

---

## Free Tier Breakdown (via OmniRoute)

While using Claude Code:

| Provider | Tokens/month | Used for |
|----------|-------------|----------|
| Mistral | ~500M | Quick answers, explanations |
| Groq | ~300M | Fast code generation |
| OpenCode | ~250M | Code refactoring, tests |
| Qwen GLM | ~150M | Long context windows |
| DeepSeek | ~100M | Complex reasoning |
| **Total** | **~1.47B** | All Claude Code requests |

All pooled together. OmniRoute auto-routes to the best available provider.

---

## Integration with FitPulse Development

**Same endpoint for everything:**

```
Claude Code IDE
    ↓
http://localhost:20128/v1
    ↓
├─ FitPulse AI Coach (backend)
├─ Claude Code (IDE assistance)
└─ OmniRoute Dashboard (monitoring)
```

Development and app coaching share the same free token pool. 🎯

---

## Next Steps

1. ✅ Install OmniRoute: `npm install -g omniroute`
2. ✅ Start server: `omniroute`
3. ✅ Set up Claude Code: `omniroute setup-claude`
4. ✅ Launch: `omniroute launch`
5. ✅ Open FitPulse: `cd /path/to/fitpulse && claude`
6. ✅ Monitor: `open http://localhost:20128/dashboard`

---

## Resources

- **OmniRoute:** https://github.com/diegosouzapw/OmniRoute
- **Claude Code docs:** https://github.com/anthropics/claude-code
- **FitPulse OmniRoute integration:** `docs/OMNIROUTE_SETUP.md` and `docs/COACH_ARCHITECTURE.md`
- **OmniRoute setup guide:** https://github.com/diegosouzapw/OmniRoute/blob/main/docs/guides/CLAUDE-CODE-CONFIGURATION.md

---

## Questions?

- **OmniRoute support:** [Discord](https://discord.gg/U47eFqAXCn) | [Telegram](https://t.me/omnirouteOficial)
- **Claude Code issues:** [GitHub Issues](https://github.com/anthropics/claude-code/issues)
- **FitPulse:** [GitHub Issues](https://github.com/HyperspaceArchitecture/fitpulse/issues)

Enjoy coding FitPulse with Claude Code powered by OmniRoute! 🚀
