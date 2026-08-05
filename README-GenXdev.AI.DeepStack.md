# DeepStack Face Recognition Functions

![DeepStack Logo](https://deepstack.cc/static/img/logo.png)

## Overview

This module provides PowerShell functions to interact with DeepStack's face recognition API running in a Docker container. DeepStack offers powerful, privacy-focused AI capabilities including face detection, face recognition, object detection, and image enhancement.

## Prerequisites

- Docker Desktop installed and running
- At least 16GB of available RAM
- GPU with CUDA support (optional, for faster processing)

## Quick Start

```powershell

# make sure you have configured a image processing llm endpoint
Set-AILLMSettings -SessionOnly -LLMQueryType Pictures -ApiEndpoint 'https://generativelanguage.googleapis.com/v1beta/openai/v1/chat/completions' -ApiKey 'your-api-key' -Model 'gemini-2.5-flash'


# manually ensure docker desktop is working
EnsureDockerDesktop -ShowWindow
EnsureDeepStack

# create a directory containing only directories having names of
# each known person, each knownperson folder can contain multiple
# png, jpeg or gif images of that person

# set directories
Set-AIKnownFacesRootpath -FacesDirectory "C:\path\to\dir\with\for\each\person\a\directory\withmultipleiomages.jpg"

# update
Update-AllAIMetadata -ShowWindow
Find-Image -HasNudity -HasExplicitContent -ShowInBrowser -InterActive

# you can keep the output and reuse them
$foundImages = Find-IndexedImage -HasNudity -HasExplicitContent

# all Find-IndexedImage's parameters, except -PathLike, are inclusive
# to truly filter using exclusions, chain commands using pipes |
Set-WindowsPosition -Monitor 0 -Left

$foundImages |
    Find-Image -Objects person, dog |
    Find-Image -StyleType *photography* |
    Show-FoundImagesInBrowser -Monitor 0 -Right -Interactive

```
