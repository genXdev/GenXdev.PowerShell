# GenXdev.Queries.AI

## Overview

GenXdev.Queries.AI opens AI chat interfaces in your browser with your query
entered using keyboard simulation. It supports ChatGPT, Google Gemini, DeepSeek, GitHub Copilot,
Bing Copilot, X Grok, and a generic cloud LLM chat that routes through
GenXdev's own AI settings. Each cmdlet constructs the provider-specific URL
and opens it in a positioned browser window.
When launching with autotyping, you should not interact yourself of course
for that short moment.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Open-ChatGPTQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-ChatGPTQuery.md) | `aicgpt`, `askchatgpt` | Open a ChatGPT query in a web browser |
| [Open-GoogleGeminiQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleGeminiQuery.md) | `aigg`, `askgemini` | Open a Google Gemini query |
| [Open-DeepSearchQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-DeepSearchQuery.md) | `aideepseek`, `askdeepsearch` | Open a DeepSeek query |
| [Open-GithubCopilotQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GithubCopilotQuery.md) | `aigc`, `askghcopilot` | Open a GitHub Copilot query |
| [Open-BingCopilotQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingCopilotQuery.md) | `aibc` | Open a Bing Copilot query |
| [Open-XGrokQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-XGrokQuery.md) | `aixg`, `askxgrok` | Open an X Grok query |
| [Open-CloudLLMChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-CloudLLMChat.md) | `ask` | Open a cloud LLM chat using GenXdev AI settings |

## How It All Comes Together

Each `Open-*` cmdlet opens the provider's web interface with your query
autotyped into the browser.
They open URLs in a web browser — they do not call APIs directly.

- `Open-ChatGPTQuery` (`askchatgpt`, `aicgpt`) — ChatGPT
- `Open-GoogleGeminiQuery` (`askgemini`, `aigg`) — Google Gemini
- `Open-DeepSearchQuery` (`askdeepsearch`, `aideepseek`) — DeepSeek
- `Open-GithubCopilotQuery` (`askghcopilot`, `aigc`) — GitHub Copilot
- `Open-BingCopilotQuery` (`aibc`) — Bing Copilot
- `Open-XGrokQuery` (`askxgrok`, `aixg`) — X Grok
- `Open-CloudLLMChat` (`ask`) — routes through your configured GenXdev AI
  LLM settings to a cloud chat endpoint

## See Also

- [GenXdev.Queries](README-GenXdev.Queries.md) — `qq` multi-source queries
- [GenXdev.Queries.Webbrowser](README-GenXdev.Queries.Webbrowser.md) — Search engine queries
- [GenXdev.AI](README-GenXdev.AI.md) — LLM provider settings (used by `ask`)
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevqueriesai)
