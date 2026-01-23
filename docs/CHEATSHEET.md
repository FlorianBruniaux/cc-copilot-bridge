cc-copilot-bridge - Quick Reference v1.4.0
============================================

CORE COMMANDS
  ccd           Anthropic Direct (pay-per-use)
  ccc           Copilot Sonnet 4.5 (1x quota)
  cco           Ollama Local (offline/private)
  ccs           Check provider status

COPILOT MODELS
  ccc-opus      Claude Opus 4.5 (3x quota, best)
  ccc-sonnet    Claude Sonnet 4.5 (1x quota)
  ccc-haiku     Claude Haiku 4.5 (0.33x quota)
  ccc-gpt       GPT-4.1 (0x = free)

OLLAMA MODELS
  cco-devstral  Devstral (default, best agentic)
  cco-granite   Granite4 (long context, less VRAM)

DYNAMIC MODEL OVERRIDE
  COPILOT_MODEL=<model> ccc
  OLLAMA_MODEL=<model> cco

PROVIDER HEALTH
  copilot-api start       Start Copilot proxy
  ollama serve            Start Ollama server
  ollama pull <model>     Download Ollama model

LOGS
  tail ~/.claude/claude-switch.log
  grep "mode=copilot" ~/.claude/claude-switch.log

DECISION (pick first match)
  Offline/Private?  -> cco
  Quick task?       -> ccc-haiku
  Complex/Review?   -> ccc-opus
  Default           -> ccc

Docs: docs/COMMANDS.md | Troubleshooting: docs/TROUBLESHOOTING.md
