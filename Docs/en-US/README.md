# GenXdev — Cmdlet Reference

Auto-generated cmdlet reference documentation. Last updated: 2026-08-06.

## GenXdev

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-GenXDevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevCmdlet.md) | gcmds | Retrieves and lists all GenXdev cmdlets and their details. |
| [Show-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdlet.md) | cmds | Displays GenXdev PowerShell modules with their cmdlets and aliases. |

---

## GenXdev.AI

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md) | &nbsp; | Gets the LLM settings for AI operations in GenXdev.AI. |
| [Get-SpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SpeechToText.md) | &nbsp; | Converts audio files to text using OpenAI's Whisper speech recognition model. |
| [Get-TextTranslation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TextTranslation.md) | translate | Translates text to another language using AI. |
| [Get-VectorSimilarity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-VectorSimilarity.md) | &nbsp; | Calculates the cosine similarity between two vectors. |
| [Invoke-AILLMSettingsPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AILLMSettingsPrompt.md) | llmset, promptllmsettings | Launches an interactive Spectre.Console prompt to configure LLM settings. |
| [Invoke-WinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WinMerge.md) | &nbsp; | Launches WinMerge to compare two files side by side. |
| [Merge-TranslationCache](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Merge-TranslationCache.md) | &nbsp; | Manages the persistent translation cache with batched disk writes per language. |
| [New-GenXdevMCPToken](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GenXdevMCPToken.md) | &nbsp; | Generates a secure random Bearer token for GenXdev MCP server     authentication. |
| [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md) | llmaudiochat | Creates an interactive audio chat session with an LLM model. |
| [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md) | llmchat | Starts an interactive text chat session with AI capabilities. |
| [Receive-RealTimeSpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Receive-RealTimeSpeechToText.md) | &nbsp; | Converts real-time audio input to text using Whisper AI model. |
| [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md) | llmsettings | Sets the LLM settings for AI operations in GenXdev.AI. |
| [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md) | &nbsp; | Sets up custom command not found handling with optional AI assistance. |
| [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md) | &nbsp; | &nbsp; |
| [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md) | &nbsp; | Tests if the specified file path is a valid image file with a supported format. |

---

## GenXdev.AI.DeepStack

| Command | Aliases | Description |
|:---|:---|:---|
| [Compare-ImageFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Compare-ImageFaces.md) | comparefaces | Compares faces in two different images and returns their similarity using DeepStack. |
| [Get-ImageDetectedFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedFaces.md) | &nbsp; | Recognizes faces in an uploaded image by comparing to known faces using DeepStack. |
| [Get-ImageDetectedObjects](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedObjects.md) | &nbsp; | Detects and classifies objects in an uploaded image using DeepStack. |
| [Get-ImageDetectedScenes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedScenes.md) | &nbsp; | Classifies an image into one of 365 scene categories using DeepStack. |
| [Get-RegisteredFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RegisteredFaces.md) | &nbsp; | Retrieves a list of all registered face identifiers from DeepStack. |
| [Invoke-ImageEnhancement](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageEnhancement.md) | enhanceimage | Enhances an image by enlarging it 4X while improving quality using DeepStack. |
| [Register-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-AllFaces.md) | UpdateFaces | Updates all face recognition profiles from image files in the faces directory. |
| [Register-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-Face.md) | &nbsp; | Registers a new face with the DeepStack face recognition API. |
| [Unregister-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-AllFaces.md) | &nbsp; | Removes all registered faces from the DeepStack face recognition system. |
| [Unregister-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-Face.md) | &nbsp; | Deletes a registered face by its identifier from DeepStack. |

---

## GenXdev.AI.Queries

| Command | Aliases | Description |
|:---|:---|:---|
| [Add-EmoticonsToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-EmoticonsToText.md) | emojify | Enhances text by adding contextually appropriate emoticons using AI. |
| [ConvertFrom-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-CorporateSpeak.md) | uncorporatize | Converts polite, professional corporate speak into direct, clear language using AI. |
| [ConvertFrom-DiplomaticSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-DiplomaticSpeak.md) | undiplomatize | Converts diplomatic or tactful language into direct, clear, and straightforward language. |
| [ConvertTo-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-CorporateSpeak.md) | corporatize | Converts direct or blunt text into polite, professional corporate speak using AI. |
| [ConvertTo-DiplomaticSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-DiplomaticSpeak.md) | diplomatize | Converts direct or blunt text into polite, tactful diplomatic language. |
| [Find-Image](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Image.md) | findimages, li | Searches for image files and metadata in specified directories with filtering capabilities and optional browser-based gallery display. |
| [Get-AIKnownFacesRootpath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIKnownFacesRootpath.md) | &nbsp; | Gets the configured directory for face image files used in GenXdev.AI operations. |
| [Get-AIMetaLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIMetaLanguage.md) | getimgmetalang | Gets the configured default language for image metadata operations. |
| [Get-Fallacy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Fallacy.md) | dispicetext | Analyzes text to identify logical fallacies using AI-powered detection. |
| [Get-ScriptExecutionErrorFixPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ScriptExecutionErrorFixPrompt.md) | getfixprompt | Captures error messages from various streams and uses LLM to suggest fixes. |
| [Get-SimularMovieTitles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SimularMovieTitles.md) | &nbsp; | Finds similar movie titles based on common properties. |
| [Invoke-AIPowershellCommand](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AIPowershellCommand.md) | hint | Generates and executes PowerShell commands using AI assistance. |
| [Invoke-ImageFacesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageFacesUpdate.md) | imagepeopledetection | Updates face recognition metadata for image files in a specified directory. |
| [Invoke-ImageKeywordUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageKeywordUpdate.md) | imagekeywordgeneration | Updates image metadata with AI-generated descriptions and keywords. |
| [Invoke-ImageMetadataUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageMetadataUpdate.md) | imagepropdetection | Updates EXIF metadata for images in a directory. |
| [Invoke-ImageObjectsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageObjectsUpdate.md) | imageobjectdetection | Updates object detection metadata for image files in a specified directory. |
| [Invoke-ImageScenesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageScenesUpdate.md) | imagescenedetection | Updates scene classification metadata for image files in a specified directory. |
| [Invoke-LLMBooleanEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMBooleanEvaluation.md) | equalstrue | Evaluates a statement using AI to determine if it's true or false. |
| [Invoke-LLMQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMQuery.md) | qllm, llm | Sends queries to an OpenAI compatible Large Language Chat completion API and processes responses. |
| [Invoke-LLMStringListEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMStringListEvaluation.md) | getlist, getstring | Extracts or generates a list of relevant strings from input text using AI analysis. |
| [Invoke-LLMTextTransformation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMTextTransformation.md) | spellcheck | Transforms text using AI-powered processing. |
| [Invoke-QueryImageContent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-QueryImageContent.md) | &nbsp; | Analyzes image content using AI vision capabilities |
| [Remove-ImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-ImageMetaData.md) | removeimagedata | Removes image metadata files from image directories. |
| [Save-FoundImageFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-FoundImageFaces.md) | saveimagefaces | Saves cropped face images from indexed image search results. |
| [Save-Transcriptions](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-Transcriptions.md) | &nbsp; | Generates subtitle files for audio and video files using OpenAI Whisper. |
| [Set-AIKnownFacesRootpath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AIKnownFacesRootpath.md) | &nbsp; | Sets the directory for face image files used in GenXdev.AI operations. |
| [Set-AIMetaLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AIMetaLanguage.md) | &nbsp; | Sets the default language and optionally the image directories for GenXdev.AI image metadata operations. |
| [Show-FoundImagesInBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-FoundImagesInBrowser.md) | showfoundimages | Displays image search results in a masonry layout web gallery. |
| [Start-AudioTranscription](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-AudioTranscription.md) | transcribefile, transcribe | Transcribes an audio file, video file, or a recording device to text |
| [Update-AllImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-AllImageMetaData.md) | updateallimages | Batch updates image keywords, faces, objects, and scenes across multiple system directories. |

---

## GenXdev.Coding

| Command | Aliases | Description |
|:---|:---|:---|
| [Add-FeatureLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-FeatureLineToREADME.md) | feature | Adds a feature line to the README file with a timestamp. |
| [Add-IdeaLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IdeaLineToREADME.md) | idea | Adds an idea item to the README.md file. |
| [Add-IssueLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IssueLineToREADME.md) | issue | Adds an issue item to the README.md file. |
| [Add-LineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-LineToREADME.md) | &nbsp; | Adds a line to a README.md markdown file in a specified section. |
| [Add-ReleaseNoteLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ReleaseNoteLineToREADME.md) | releasenote | Adds a ReleaseNote line to the README file with a timestamp. |
| [Add-TodoLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-TodoLineToREADME.md) | todo | Adds a todo item to the README.md file. |
| [Backup-CompletedFeatures](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedFeatures.md) | archive-features | Archives completed feature items from the README to an external file. |
| [Backup-CompletedIdeas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIdeas.md) | archive-ideas | Archives completed idea items from the README to an external file. |
| [Backup-CompletedIssues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIssues.md) | archive-issues | Archives completed issue items from the README to an external file. |
| [Backup-CompletedReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedReleaseNotes.md) | archive-releasenotes | Archives completed release note items from the README to an external file. |
| [Backup-CompletedTodoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedTodoos.md) | archive-todoos | Archives completed todo items from the README to an external file. |
| [Backup-READMESections](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-READMESections.md) | archive-readme-sections | Archives completed items from all README sections to an external file. |
| [Get-Features](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Features.md) | features | Displays features from a README.md file. |
| [Get-Ideas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Ideas.md) | ideas | Displays ideas from a README.md file. |
| [Get-Issues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Issues.md) | issues | Displays issues from a README.md file. |
| [Get-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Refactor.md) | refactors | Retrieves refactor definitions from GenXdev preferences based on name patterns. |
| [Get-RefactorReport](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefactorReport.md) | refactorreport | Generates a detailed report of refactoring operations and their status. |
| [Get-ReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ReleaseNotes.md) | releasenotes | Displays ReleaseNotes from a README.md file. |
| [Get-Todoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Todoos.md) | todoos | Displays todo items from a README.md file. |
| [New-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-Refactor.md) | newrefactor | Creates a new refactoring set for code transformation tasks. |
| [Open-SourceFileInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SourceFileInIde.md) | editcode | Opens a source file in the preferred IDE (Visual Studio Code or Visual Studio). |
| [Publish-ReleaseNotesToManifest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Publish-ReleaseNotesToManifest.md) | pubrelnotes | Publishes uncompleted release notes from README.md to the module manifest. |
| [Remove-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-Refactor.md) | &nbsp; | Removes refactor sets from GenXdev preferences system. |
| [Start-NextRefactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-NextRefactor.md) | nextrefactor | Continues or restarts a code refactoring session. |
| [Update-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Refactor.md) | updaterefactor | Updates and manages refactoring sets including file selection and processing. |
| [VSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/VSCode.md) | &nbsp; | Opens one or more files in Visual Studio Code. |

---

## GenXdev.Coding.Git

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-GitChangedFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GitChangedFiles.md) | gitchanged | Get the list of changed files in a Git repository. |
| [New-GitCommit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GitCommit.md) | commit | Creates and pushes a new git commit with all changes. |
| [PermanentlyDeleteGitFolders](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/PermanentlyDeleteGitFolders.md) | &nbsp; | Permanently deletes specified folders from all branches in a Git repository. |

---

## GenXdev.Coding.PowerShell.Modules

| Command | Aliases | Description |
|:---|:---|:---|
| [Assert-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdlet.md) | improvecmdlet | Improves GenXdev cmdlet documentation and implementation through AI assistance. |
| [Assert-GenXdevCmdletTests](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdletTests.md) | improvecmdlettests | Asserts and improves unit-tests of a specified GenXdev cmdlet. |
| [Assert-GenXdevTest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevTest.md) | rungenxdevtests | Executesunit tests for GenXdev modules, sub-modules, or cmdlets with intelligent debugging and AI-powered error resolution. |
| [Assert-ModuleDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-ModuleDefinition.md) | &nbsp; | Assists in refactoring PowerShell source code files using AI assistance. |
| [EnsureCopilotKeyboardShortCut](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureCopilotKeyboardShortCut.md) | &nbsp; | Configures the GitHub Copilot Chat keyboard shortcuts in Visual Studio Code. |
| [EnsureDefaultGenXdevRefactors](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDefaultGenXdevRefactors.md) | &nbsp; | Ensures default GenXdev refactoring definitions are available. |
| [Get-CmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CmdletMetaData.md) | &nbsp; | Retrieves metadata for a specified GenXdev cmdlet, optionally translating help text to another language. |
| [Get-GenXDevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModule.md) | &nbsp; | Retrieves all GenXDev modules from a specified path. |
| [Get-GenXDevModuleInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModuleInfo.md) | &nbsp; | Retrieves detailed information about GenXdev PowerShell modules. |
| [Get-GenXDevNewModulesInOrderOfDependency](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevNewModulesInOrderOfDependency.md) | &nbsp; | Retrieves GenXDev modules in dependency order. |
| [Get-ModuleCmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ModuleCmdletMetaData.md) | &nbsp; | Retrieves metadata for all cmdlets in a PowerShell module. |
| [Invoke-GenXdevPSFormatter](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevPSFormatter.md) | &nbsp; | Formats PowerShell script files using PSScriptAnalyzer formatting rules. |
| [Invoke-GenXdevScriptAnalyzer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevScriptAnalyzer.md) | &nbsp; | Invokes PowerShell Script Analyzer to analyze PowerShell scripts for compliance and best practices. |
| [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md) | &nbsp; | Generates rich Markdown help files for any PowerShell module. |
| [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md) | &nbsp; | Generates MAML XML help files for any PowerShell module. |
| [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md) | searchcmdlet | Searches for a GenXdev cmdlet and optionally opens it in an IDE for editing. |
| [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md) | editcmdlet, cmdlet | Opens the specified GenXdev cmdlet in Visual Studio Code. |

---

## GenXdev.Coding.Templating

| Command | Aliases | Description |
|:---|:---|:---|
| [Add-ArrayTemplate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ArrayTemplate.md) | FormatArray | Formats a collection of objects using a template string with property placeholders, producing a single formatted string. |
| [Remove-DoubleEmptyLines](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-DoubleEmptyLines.md) | &nbsp; | Removes double (consecutive) empty lines from a code string, optionally reformatting the output. |

---

## GenXdev.Console

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-IsSpeaking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-IsSpeaking.md) | iss | Returns true if the text-to-speech engine is speaking. |
| [New-MicrosoftShellTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-MicrosoftShellTab.md) | x | Creates a new Windows Terminal tab running PowerShell. |
| [Now](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Now.md) | &nbsp; | Returns the current system date and time as a DateTime object. |
| [Resume-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-TextToSpeech.md) | resumespeech | Resumes text-to-speech output that was previously paused via Suspend-TextToSpeech. |
| [SayDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayDate.md) | &nbsp; | Speaks the current date using text-to-speech synthesis. |
| [SayTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayTime.md) | &nbsp; | Announces the current time using text-to-speech. |
| [secondscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/secondscreen.md) | &nbsp; | Sets default second-monitor configuration. |
| [sidebyside](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/sidebyside.md) | &nbsp; | Sets default side-by-side configuration. |
| [Start-SnakeGame](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-SnakeGame.md) | snake | Starts a simple Snake game in the console. |
| [Start-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-TextToSpeech.md) | say | Converts text to speech using Microsoft Edge's neural TTS engine. |
| [Stop-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-TextToSpeech.md) | sst | Immediately stops any ongoing text-to-speech output. |
| [Suspend-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Suspend-TextToSpeech.md) | pausespeech | Pauses any ongoing text-to-speech output across all synthesizer instances. |
| [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md) | &nbsp; | Gets the current UTC (Coordinated Universal Time) date and time. |

---

## GenXdev.Data.KeyValueStore

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-KeyValueStoreNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KeyValueStoreNames.md) | getstorenames | Retrieves the names of available local key-value stores. |
| [Get-KeyValueStorePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KeyValueStorePath.md) | &nbsp; | Gets the file path for a local key-value store. |
| [Get-StoreKeys](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-StoreKeys.md) | getkeys | Retrieves all key names for a given local key-value store. |
| [Get-ValueByKeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ValueByKeyFromStore.md) | getvalue | Retrieves a value from a local JSON-based key-value store. |
| [Remove-KeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyFromStore.md) | removekey | Removes a key from a local key-value store. |
| [Remove-KeyValueStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyValueStore.md) | &nbsp; | Removes a local key-value store. |
| [Set-ValueByKeyInStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ValueByKeyInStore.md) | setvalue | Manages key-value pairs in a local JSON file-based store. |

---

## GenXdev.Data.Preferences

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreference.md) | getPreference | Retrieves a preference value from the GenXdev preferences store. |
| [Get-GenXdevPreferenceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferenceNames.md) | getPreferenceNames | Gets all preference names from session storage and database stores. |
| [Get-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferencesDatabasePath.md) | &nbsp; | Gets the configured database path for preference data files used in GenXdev.Data operations. |
| [Remove-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-GenXdevPreference.md) | removePreference | Removes a preference value from the GenXdev preferences store. |
| [Set-GenXdevDefaultPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevDefaultPreference.md) | setPreferenceDefault | Sets a default preference value in the GenXdev preferences store. |
| [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md) | setPreference | Sets a preference value in the GenXdev preferences store. |
| [Set-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreferencesDatabasePath.md) | &nbsp; | Sets the database path for preferences used in GenXdev.Data operations. |

---

## GenXdev.Data.SQLite

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-SQLiteSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteSchema.md) | &nbsp; | Retrieves the complete schema information from a SQLite database. |
| [Get-SQLiteTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableColumnData.md) | &nbsp; | Retrieves data from a specific column in a SQLite database table. |
| [Get-SQLiteTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableData.md) | &nbsp; | Retrieves data from a SQLite database table with optional record limiting. |
| [Get-SQLiteTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTables.md) | &nbsp; | Retrieves a list of table names from a SQLite database. |
| [Get-SQLiteTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableSchema.md) | &nbsp; | Retrieves the schema information for a specified SQLite table. |
| [Get-SQLiteTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTransaction.md) | getsqltx, newsqltx | Creates and returns a SQLite transaction object for batch operations. |
| [Get-SQLiteViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewColumnData.md) | &nbsp; | Retrieves column data from a SQLite view with optional record limiting. |
| [Get-SQLiteViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewData.md) | &nbsp; | Retrieves data from a SQLite database view with optional record limiting. |
| [Get-SQLiteViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViews.md) | &nbsp; | Retrieves a list of views from a SQLite database. |
| [Get-SQLiteViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewSchema.md) | &nbsp; | Retrieves the SQL schema definition for a SQLite view. |
| [Invoke-SQLiteQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteQuery.md) | &nbsp; | Executes one or more SQL queries against a SQLite database with transaction support. |
| [Invoke-SQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteStudio.md) | &nbsp; | Executes SQLite database queries with support for parameters and transactions. |
| [New-SQLiteDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLiteDatabase.md) | nsqldb | Creates a new SQLite database file. |

---

## GenXdev.Data.SqlServer

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-SQLServerSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerSchema.md) | &nbsp; | Retrieves the complete schema information from a SQL Server database. |
| [Get-SQLServerTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableColumnData.md) | &nbsp; | Retrieves data from a specific column in a SQL database table. |
| [Get-SQLServerTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableData.md) | &nbsp; | Retrieves data from a SQL database table with optional record limiting. |
| [Get-SQLServerTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTables.md) | &nbsp; | Retrieves a list of table names from a SQL Server database. |
| [Get-SQLServerTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableSchema.md) | &nbsp; | Retrieves the schema information for a specified SQL Server table. |
| [Get-SQLServerTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTransaction.md) | getsqltx, newsqltx | Creates and returns a SQL Server transaction object for batch operations. |
| [Get-SQLServerViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewColumnData.md) | &nbsp; | Retrieves column data from a SQL view with optional record limiting. |
| [Get-SQLServerViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewData.md) | &nbsp; | Retrieves data from a SQL database view with optional record limiting. |
| [Get-SQLServerViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViews.md) | &nbsp; | Retrieves a list of views from a SQL Server database. |
| [Get-SQLServerViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewSchema.md) | &nbsp; | Retrieves the SQL schema definition for a SQL Server view. |
| [Invoke-SQLServerQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerQuery.md) | &nbsp; | Executes one or more SQL queries against a SQL Server database with transaction support. |
| [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md) | ssms, sqlservermanagementstudio | Executes SQL Server database queries with support for parameters and transactions. |
| [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md) | nsqldb | Creates a new SQL Server database. |

---

## GenXdev.FileSystem

| Command | Aliases | Description |
|:---|:---|:---|
| [Copy-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-FilesToDateFolder.md) | &nbsp; | Copies files matching search criteria into date-based subfolders. |
| [Expand-Path](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Expand-Path.md) | ep | Expands any given file reference to a full pathname. |
| [Find-DuplicateFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-DuplicateFiles.md) | fdf | Find duplicate files across multiple directories based on configurable criteria. |
| [Find-Item](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Item.md) | l | Search for files and directories with advanced filtering options. |
| [Invoke-Fasti](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-Fasti.md) | fasti | Extracts archive files in the current directory to their own folders and deletes them afterwards. |
| [Move-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-FilesToDateFolder.md) | &nbsp; | Moves files matching search criteria into date-based subfolders. |
| [Move-ItemWithTracking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-ItemWithTracking.md) | &nbsp; | Moves files and directories while preserving filesystem links and references. |
| [Move-ToRecycleBin](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-ToRecycleBin.md) | &nbsp; | Moves files and directories to the Windows Recycle Bin safely. |
| [ReadJsonWithRetry](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ReadJsonWithRetry.md) | &nbsp; | Reads JSON file with retry logic and automatic lock cleanup. |
| [Remove-AllItems](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-AllItems.md) | sdel | Recursively removes all content from a directory with advanced error handling. |
| [Remove-ItemWithFallback](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-ItemWithFallback.md) | rmf | Removes files or directories with multiple fallback mechanisms for reliable deletion. |
| [Remove-OnReboot](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-OnReboot.md) | &nbsp; | Marks files or directories for deletion during the next system boot. |
| [Rename-InProject](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Rename-InProject.md) | rip | Performs text replacement throughout a project directory. |
| [Set-FoundLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-FoundLocation.md) | lcd | Finds the first matching file or folder and sets the location to it. |
| [Set-LocationParent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent.md) | .. | Changes the current location to the parent directory and lists its contents. |
| [Set-LocationParent2](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent2.md) | ... | Navigates up two directory levels in the file system hierarchy. |
| [Set-LocationParent3](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent3.md) | .... | Navigates up three directory levels in the file system hierarchy. |
| [Set-LocationParent4](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent4.md) | ..... | Navigates up four directory levels in the filesystem hierarchy. |
| [Set-LocationParent5](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent5.md) | ...... | Navigates up five directory levels in the file system hierarchy. |
| [Start-RoboCopy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-RoboCopy.md) | xc, rc | Provides a PowerShell wrapper for Microsoft's Robust Copy (RoboCopy) utility. |
| [Write-FileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-FileAtomic.md) | &nbsp; | Writes bytes to a file atomically to prevent corruption. |
| [Write-JsonFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-JsonFileAtomic.md) | &nbsp; | Writes an object as JSON to a file atomically to prevent corruption. |
| [Write-TextFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-TextFileAtomic.md) | &nbsp; | Writes text to a file atomically to prevent corruption. |

---

## GenXdev.Hardware

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md) | &nbsp; | Retrieves the names of available audio devices for microphone or desktop audio capture. |
| [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md) | &nbsp; | Calculates and returns the total number of logical CPU cores in the system. |
| [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md) | &nbsp; | Determines if a CUDA-capable GPU with sufficient memory is present. |
| [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md) | &nbsp; | Gets the total number of display monitors connected to the system. |
| [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md) | &nbsp; | Calculates and returns the total number of logical CPU cores in the system. |
| [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md) | &nbsp; | Sends a string to a serial port |
| [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md) | &nbsp; | Tests whether the CPU supports AVX and AVX2 instruction sets. |

---

## GenXdev.Helpers

| Command | Aliases | Description |
|:---|:---|:---|
| [alignScript](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/alignScript.md) | &nbsp; | Returns a string (with altered indentation) of a provided scriptblock string |
| [Approve-NewTextFileContent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Approve-NewTextFileContent.md) | &nbsp; | Interactive file content comparison and approval using WinMerge. |
| [Assert-RefactorFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-RefactorFile.md) | &nbsp; | Executes a refactoring operation on a source file using the specified IDE and AI prompt template. |
| [Confirm-InstallationConsent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Confirm-InstallationConsent.md) | &nbsp; | Confirms user consent for installing third-party software, using preferences for persistent choices. |
| [Convert-DotNetTypeToLLMType](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-DotNetTypeToLLMType.md) | &nbsp; | Converts .NET type names to LLM (Language Model) type names. |
| [ConvertTo-HashTable](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-HashTable.md) | &nbsp; | Converts a PSCustomObject to a HashTable recursively. |
| [ConvertTo-LLMOpenAIApiFunctionDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-LLMOpenAIApiFunctionDefinition.md) | &nbsp; | Converts PowerShell functions to LLM OpenAI API function definitions. |
| [Copy-IdenticalParamValues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-IdenticalParamValues.md) | &nbsp; | Copies parameter values from bound parameters to a new hashtable based on another function's possible parameters. |
| [EnsureGenXdev](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureGenXdev.md) | &nbsp; | Ensures all GenXdev modules are properly loaded by invoking all Ensure* cmdlets. |
| [EnsureNuGetAssembly](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureNuGetAssembly.md) | &nbsp; | Downloads and loads .NET assemblies from NuGet packages based on package key or ID. |
| [GenerateMasonryLayoutHtml](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/GenerateMasonryLayoutHtml.md) | &nbsp; | Generates a responsive masonry layout HTML gallery from image data. |
| [Get-AIDefaultLLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIDefaultLLMSettings.md) | &nbsp; | Gets all available default LLM settings configurations for AI operations in GenXdev.AI. |
| [Get-BCP47LanguageDictionary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BCP47LanguageDictionary.md) | &nbsp; | Returns a dictionary of all installed BCP 47 language tags and their display names. |
| [Get-DefaultWebLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebLanguage.md) | &nbsp; | Gets the default web language key based on the system's current language settings. |
| [Get-JsonExampleFromSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-JsonExampleFromSchema.md) | &nbsp; | Generates a human-readable example JSON string from a JSON Schema definition. |
| [Get-LLMJsonOutput](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-LLMJsonOutput.md) | &nbsp; | Extracts valid JSON from LLM response text using best-effort heuristics. |
| [Get-PowerShellRoot](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PowerShellRoot.md) | &nbsp; | Returns the root path of the PowerShell workspace. |
| [Get-WebLanguageDictionary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebLanguageDictionary.md) | &nbsp; | Returns a reversed dictionary for all languages supported by Google Search. |
| [Import-GenXdevModules](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevModules.md) | reloadgenxdev | Imports all GenXdev PowerShell modules into the global scope. |
| [Initialize-SearchPaths](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Initialize-SearchPaths.md) | &nbsp; | Initializes and configures system search paths for package management. |
| [Invoke-CommandFromToolCall](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-CommandFromToolCall.md) | &nbsp; | Executes a tool call function with validation and parameter filtering. |
| [Invoke-OnEachGenXdevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-OnEachGenXdevModule.md) | foreach-genxdev-module-do | Executes a script block on each GenXdev module in the workspace. |
| [Invoke-SpectreAsk](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectreAsk.md) | &nbsp; | Prompts the user for text input using Spectre.Console. |
| [Invoke-SpectreConfirm](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectreConfirm.md) | &nbsp; | Displays a Spectre.Console confirmation prompt and returns the user's choice. |
| [Invoke-SpectrePrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectrePrompt.md) | &nbsp; | Prompts the user for input using a Spectre.Console prompt object. |
| [Remove-JSONComments](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-JSONComments.md) | &nbsp; | Removes comments from JSON content. |
| [resetdefaultmonitor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/resetdefaultmonitor.md) | &nbsp; | Restores default secondary monitor configuration. |
| [ResolveInputObjectFileNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ResolveInputObjectFileNames.md) | &nbsp; | Expands input objects into file and directory names, supporting various filters and output options. |
| [Show-Verb](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-Verb.md) | showverbs | Shows a short alphabetical list of all PowerShell verbs. |
| [Test-RefactorLLMSelection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-RefactorLLMSelection.md) | &nbsp; | Evaluates source files for refactoring eligibility using LLM analysis. |
| [Test-UnattendedMode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-UnattendedMode.md) | &nbsp; | Detects if PowerShell is running in unattended/automated mode. |
| [Write-SpectreLine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-SpectreLine.md) | &nbsp; | Writes a blank line via Spectre.Console. |
| [Write-SpectreMarkupLine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-SpectreMarkupLine.md) | &nbsp; | Writes a Spectre.Console markup-formatted line. |
| [WriteFileOutput](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/WriteFileOutput.md) | &nbsp; | Outputs file information with hyperlinked display names for enhanced user experience. |

---

## GenXdev.Helpers.Physics

| Command | Aliases | Description |
|:---|:---|:---|
| [Convert-PhysicsUnit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-PhysicsUnit.md) | &nbsp; | Converts a value from one physics unit to another within the same category. |
| [Get-ApparentSizeAtArmLength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ApparentSizeAtArmLength.md) | &nbsp; | Calculates the apparent size of an object at arm's length. |
| [Get-AtEyeLengthSizeInMM](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AtEyeLengthSizeInMM.md) | &nbsp; | Calculates the apparent size in mm of an object at arm's length. |
| [Get-BuoyantForceByDisplacedVolumeAndDensity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BuoyantForceByDisplacedVolumeAndDensity.md) | &nbsp; | Calculates buoyant force. |
| [Get-CentripetalAccelerationByVelocityAndRadius](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CentripetalAccelerationByVelocityAndRadius.md) | &nbsp; | Calculates centripetal acceleration. |
| [Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed.md) | &nbsp; | Calculates Doppler shifted frequency. |
| [Get-DragForceByVelocityDensityAreaAndCoefficient](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DragForceByVelocityDensityAreaAndCoefficient.md) | &nbsp; | Calculates drag force. |
| [Get-EscapeVelocityByMassAndRadius](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-EscapeVelocityByMassAndRadius.md) | &nbsp; | Calculates escape velocity. |
| [Get-FreeFallDistance](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallDistance.md) | &nbsp; | Calculates the distance fallen during free fall for a given time duration. |
| [Get-FreeFallHeight](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallHeight.md) | &nbsp; | Calculates the height fallen during free fall for a given time duration. |
| [Get-FreeFallTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallTime.md) | &nbsp; | Calculates the time required for an object to fall a given height during free fall. |
| [Get-ImpactVelocityByHeightAndGravity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImpactVelocityByHeightAndGravity.md) | &nbsp; | Calculates impact velocity from height. |
| [Get-KineticEnergyByMassAndVelocity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KineticEnergyByMassAndVelocity.md) | &nbsp; | Calculates kinetic energy. |
| [Get-LightTravelTimeByDistance](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-LightTravelTimeByDistance.md) | &nbsp; | Calculates time for light to travel a distance. |
| [Get-MagnificationByObjectDistanceAndImageDistance](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MagnificationByObjectDistanceAndImageDistance.md) | &nbsp; | Calculates magnification for a lens. |
| [Get-MomentumByMassAndVelocity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MomentumByMassAndVelocity.md) | &nbsp; | Calculates linear momentum. |
| [Get-OrbitalVelocityByRadiusAndMass](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-OrbitalVelocityByRadiusAndMass.md) | &nbsp; | Calculates orbital velocity. |
| [Get-PotentialEnergyByMassHeightAndGravity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PotentialEnergyByMassHeightAndGravity.md) | &nbsp; | Calculates gravitational potential energy. |
| [Get-ProjectileRangeByInitialSpeedAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ProjectileRangeByInitialSpeedAndAngle.md) | &nbsp; | Calculates the range of a projectile. |
| [Get-RefractionAngleByIncidentAngleAndIndices](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefractionAngleByIncidentAngleAndIndices.md) | &nbsp; | Calculates refraction angle using Snell's law. |
| [Get-ResonantFrequencyByLengthAndSpeed](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ResonantFrequencyByLengthAndSpeed.md) | &nbsp; | Calculates resonant frequency for a closed pipe. |
| [Get-SoundTravelDistanceByTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SoundTravelDistanceByTime.md) | &nbsp; | Calculates the distance sound travels in a given time. |
| [Get-TerminalVelocityByMassGravityDensityAndArea](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TerminalVelocityByMassGravityDensityAndArea.md) | &nbsp; | Calculates terminal velocity. |
| [Get-TimeOfFlightByInitialVelocityAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TimeOfFlightByInitialVelocityAndAngle.md) | &nbsp; | Calculates the time of flight for a projectile. |
| [Get-WaveSpeedByFrequencyAndWavelength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WaveSpeedByFrequencyAndWavelength.md) | &nbsp; | Calculates wave speed. |

---

## GenXdev.Media

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-ImageGeolocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageGeolocation.md) | &nbsp; | Extracts geolocation data from an image file. |
| [Get-ImageMetadata](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageMetadata.md) | &nbsp; | Extracts comprehensive metadata from an image file. |
| [Get-MediaFileCreationDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MediaFileCreationDate.md) | &nbsp; | Extracts the best-effort creation date for media and other files. |
| [Open-MediaFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MediaFile.md) | vlcmedia, media, findmedia | Opens and plays media files using VLC media player with advanced filtering and configuration options. |
| [Open-VlcMediaPlayer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayer.md) | vlc | Launches and controls VLC Media Player with extensive configuration options. |
| [Open-VlcMediaPlayerLyrics](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayerLyrics.md) | vlclyrics | Opens a web browser to search for lyrics of currently playing VLC media. |
| [Set-VLCPlayerFocused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-VLCPlayerFocused.md) | showvlc, vlcf, fvlc | Sets focus to the VLC media player window. |
| [StabilizeVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/StabilizeVideo.md) | &nbsp; | Stabilizes the newest or specified .mp4 file using FFmpeg + vid.stab (no black borders). |
| [Start-VlcMediaPlayerNextInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerNextInPlaylist.md) | vlcnext | Advances VLC Media Player to the next item in the current playlist. |
| [Start-VlcMediaPlayerPreviousInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerPreviousInPlaylist.md) | vlcprev, vlcback | Moves to the previous item in the VLC Media Player playlist. |
| [Switch-VlcMediaPlayerMute](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerMute.md) | vlcmute, vlcunmute | Toggles the mute state of the VLC Media Player. |
| [Switch-VLCMediaPlayerPaused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VLCMediaPlayerPaused.md) | vlcpause, vlcplay | Toggles the pause/play state of the VLC Media Player. |
| [Switch-VlcMediaPlayerRepeat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerRepeat.md) | vlcrepeat | Toggles the repeat mode in VLC Media Player. |

---

## GenXdev.Queries

| Command | Aliases | Description |
|:---|:---|:---|
| [ConvertTo-Uris](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-Uris.md) | &nbsp; | Parses strings for any valid URI. |
| [Open-AllPossibleQueries](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-AllPossibleQueries.md) | qq | Opens all possible query types for given search terms or URLs. |

---

## GenXdev.Queries.AI

| Command | Aliases | Description |
|:---|:---|:---|
| [Open-BingCopilotQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingCopilotQuery.md) | aibc | Opens a Bing CoPilot query in a webbrowser |
| [Open-ChatGPTQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-ChatGPTQuery.md) | aicgpt, askchatgpt | Opens a ChatGPT query in a web browser. |
| [Open-CloudLLMChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-CloudLLMChat.md) | ask | Opens a cloud LLM chat interface for AI queries. |
| [Open-DeepSearchQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-DeepSearchQuery.md) | aideepseek, askdeepsearch | Opens a DeepSeek query in a webbrowser |
| [Open-GithubCopilotQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GithubCopilotQuery.md) | aigc, askghcopilot | Opens a Github CoPilot query in a webbrowser |
| [Open-GoogleGeminiQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleGeminiQuery.md) | aigg, askgemini | Opens a Google Gemini query in a webbrowser |
| [Open-XGrokQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-XGrokQuery.md) | aixg, askxgrok | Opens a X Grok query in a webbrowser |

---

## GenXdev.Queries.Text

| Command | Aliases | Description |
|:---|:---|:---|
| [Get-NextAffirmation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NextAffirmation.md) | WhatAboutIt | Returns a random affirmation text from the affirmations.dev API. |
| [Get-WikipediaSummary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WikipediaSummary.md) | wikitxt | Retrieves a summary of a topic from Wikipedia. |

---

## GenXdev.Queries.Webbrowser

| Command | Aliases | Description |
|:---|:---|:---|
| [Copy-PDFsFromGoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-PDFsFromGoogleQuery.md) | &nbsp; | Downloads PDF files found through Google search results. |
| [Open-BingQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingQuery.md) | bq | Opens a Bing search query in a web browser. |
| [Open-BuiltWithSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BuiltWithSiteInfo.md) | &nbsp; | Opens BuiltWith website queries in a web browser. |
| [Open-GithubQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GithubQuery.md) | qgithub, qgh | Opens a Github repository search query in a web browser or executes advanced searches against the GitHub REST API supporting all available qualifiers and search categories (repositories, code, issues, users, commits, discussions, topics, wikis). |
| [Open-GoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleQuery.md) | &nbsp; | Opens Google queries in a web browser with configurable settings and extensive customization options. |
| [Open-GoogleSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleSiteInfo.md) | &nbsp; | Opens Google site information queries in a web browser. |
| [Open-GrokipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GrokipediaQuery.md) | wiki | Opens a Grokipedia query in a webbrowser. |
| [Open-IMDBQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-IMDBQuery.md) | imdb | Opens an IMDB search query in a web browser. |
| [Open-InstantStreetViewQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-InstantStreetViewQuery.md) | isv | Opens InstantStreetView queries in a web browser. |
| [Open-MovieQuote](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MovieQuote.md) | moviequote | Opens a video of a movie quote in a web browser. |
| [Open-SearchEngine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SearchEngine.md) | q | Opens a search query in the specified search engine using a web browser. |
| [Open-SimularWebSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SimularWebSiteInfo.md) | simularsite | Opens SimilarWeb website information for specified URLs in a web browser. |
| [Open-StackOverflowQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-StackOverflowQuery.md) | qso | Opens Stack Overflow search queries in a web browser. |
| [Open-WaybackMachineSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WaybackMachineSiteInfo.md) | wayback | Opens WaybackMachine site information in a web browser. |
| [Open-WebsiteAndPerformQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebsiteAndPerformQuery.md) | owaq | Opens a webpage in a webbrowser and performs one or more queries. |
| [Open-WhoisHostSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WhoisHostSiteInfo.md) | whois | Opens a Whois host information query in a web browser. |
| [Open-WikipediaNLQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaNLQuery.md) | wikinl | Opens Dutch Wikipedia searches in a web browser. |
| [Open-WikipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaQuery.md) | wikipedia | Opens a Wikipedia query in a webbrowser. |
| [Open-WolframAlphaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WolframAlphaQuery.md) | qalpha | Opens a Wolfram Alpha query in a web browser. |
| [Open-YoutubeQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YoutubeQuery.md) | youtube | Opens YouTube search queries in a web browser. |

---

## GenXdev.Queries.Websites

| Command | Aliases | Description |
|:---|:---|:---|
| [Open-GameOfLife](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GameOfLife.md) | gameoflife, conway | Opens Conway's Game of Life simulation in a web browser. |
| [Open-GenXdevAppCatalog](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GenXdevAppCatalog.md) | appcatalog | Opens the GenXdev progressive webapps catalog in a web browser. |
| [Open-Timeline](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Timeline.md) | timeline | Opens an interactive timeline showing current time, date, century, and millennium. |
| [Open-ViralSimulation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-ViralSimulation.md) | viral | Opens a viral simulation game in a web browser with extensive configuration options. |
| [Open-Yab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Yab.md) | yab | Opens the YAB game in a web browser with configurable settings. |
| [Open-YabAIBattle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YabAIBattle.md) | yabbattle | Opens the YabAI Battle game in a web browser. |

---

## GenXdev.Software

| Command | Aliases | Description |
|:---|:---|:---|
| [Ensure7Zip](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Ensure7Zip.md) | &nbsp; | Ensures 7-Zip is installed and available on the PATH. |
| [EnsureDeepStack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDeepStack.md) | &nbsp; | Ensures DeepStack face recognition service is installed and running. |
| [EnsureDockerDesktop](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDockerDesktop.md) | &nbsp; | Ensures Docker Desktop is installed and available for containerization operations. |
| [EnsureFFMPEG](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureFFMPEG.md) | &nbsp; | Ensures FFmpeg is installed and available on the PATH. |
| [EnsureGithubCLI](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureGithubCLI.md) | &nbsp; | Ensures GitHub CLI is properly installed and configured on the system. |
| [EnsurePaintNet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePaintNet.md) | &nbsp; | Ensures Paint.NET is properly installed and accessible on the system. |
| [EnsurePester](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePester.md) | &nbsp; | Ensures Pester testing framework is available for use. |
| [EnsurePlaywright](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePlaywright.md) | &nbsp; | Ensures the Playwright .NET assembly and browser binaries are available. |
| [EnsurePSTools](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePSTools.md) | &nbsp; | Ensures Sysinternals tools (PSTools) are installed and available. |
| [EnsureSQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureSQLiteStudio.md) | &nbsp; | Ensures SQLiteStudio is installed and accessible from the command line. |
| [EnsureSSMSInstalled](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureSSMSInstalled.md) | &nbsp; | Ensures SSMS is installed and accessible from the command line. |
| [EnsureVSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureVSCode.md) | &nbsp; | Installs and configures Visual Studio Code with recommended extensions. |
| [EnsureWindowsMediaFeaturePack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWindowsMediaFeaturePack.md) | &nbsp; | Ensures the Windows Media Feature Pack is installed. |
| [EnsureWinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWinMerge.md) | &nbsp; | Ensures WinMerge is installed and available for file comparison operations. |

---

## GenXdev.Webbrowser

| Command | Aliases | Description |
|:---|:---|:---|
| [Close-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-Webbrowser.md) | wbc | Closes one or more webbrowser instances selectively. |
| [Close-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-WebbrowserTab.md) | ct, CloseTab | Closes the currently selected webbrowser tab. |
| [Export-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Export-BrowserBookmarks.md) | &nbsp; | Exports browser bookmarks to a JSON file. |
| [Find-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-BrowserBookmark.md) | bookmarks | Finds bookmarks from one or more web browsers. |
| [Get-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BrowserBookmark.md) | gbm | Returns all bookmarks from installed web browsers. |
| [Get-DefaultWebbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebbrowser.md) | &nbsp; | Returns the configured default web browser for the current user. |
| [Get-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Webbrowser.md) | &nbsp; | Returns a collection of installed modern web browsers. |
| [Import-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-BrowserBookmarks.md) | &nbsp; | Imports bookmarks from a file or collection into a web browser. |
| [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md) | &nbsp; | Imports GenXdev JavaScript bookmarklets into browser bookmark collections. |
| [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md) | sites | Opens browser bookmarks that match specified search criteria. |
| [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md) | wb | Opens URLs in one or more browser windows with optional positioning and styling. |
| [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md) | wbn | Launches a new web browser window with specific positioning. |
| [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md) | &nbsp; | Opens a URL in multiple browsers simultaneously in a mosaic layout. |

---

## GenXdev.Webbrowser.Playwright

| Command | Aliases | Description |
|:---|:---|:---|
| [Connect-PlaywrightViaDebuggingPort](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Connect-PlaywrightViaDebuggingPort.md) | &nbsp; | Connects to an existing browser instance via debugging port. |
| [Get-PlaywrightProfileDirectory](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightProfileDirectory.md) | &nbsp; | Gets the Playwright browser profile directory for persistent sessions. |
| [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md) | &nbsp; | Gets a reference to the current Playwright browser session. |
| [Get-WebbrowserTabDomNodes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebbrowserTabDomNodes.md) | wl | Queries and manipulates DOM nodes in the active browser tab using CSS selectors. |
| [Invoke-WebbrowserEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WebbrowserEvaluation.md) | Eval, et | Executes JavaScript code in a selected web browser tab. |
| [Open-PlayWrightBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-PlayWrightBrowser.md) | spb | Starts a Playwright-managed browser with a persistent user profile. |
| [Resume-WebbrowserTabVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-WebbrowserTabVideo.md) | wbvideoplay | Resumes video playback in a YouTube browser tab. |
| [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md) | st | Selects a browser tab from running Playwright-managed browsers. |
| [Set-BrowserVideoFullscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-BrowserVideoFullscreen.md) | fsvideo | Maximizes the first video element found in the current browser tab. |
| [Set-WebbrowserTabLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WebbrowserTabLocation.md) | lt, Nav | Navigates the current webbrowser tab to a specified URL. |
| [Stop-WebbrowserVideos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-WebbrowserVideos.md) | wbsst, ssst, wbvideostop | Pauses video playback in all active browser sessions. |
| [Unprotect-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unprotect-WebbrowserTab.md) | wbctrl | Takes control of a selected web browser tab for interactive manipulation. |

---

## GenXdev.Windows

| Command | Aliases | Description |
|:---|:---|:---|
| [CurrentUserHasElevatedRights](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/CurrentUserHasElevatedRights.md) | &nbsp; | Checks if the current user has elevated rights. |
| [Enable-Screensaver](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Enable-Screensaver.md) | &nbsp; | Starts the configured Windows screensaver. |
| [Get-ActiveUser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ActiveUser.md) | gusers | Retrieves a list of unique usernames from currently active system processes. |
| [Get-ChildProcesses](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ChildProcesses.md) | &nbsp; | Retrieves all processes that are descendants of the current PowerShell process. |
| [Get-ClipboardFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ClipboardFiles.md) | getclipfiles, gcbf | Gets files from the Windows clipboard that were set for file operations like copy/paste. |
| [Get-CurrentFocusedProcess](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CurrentFocusedProcess.md) | &nbsp; | Retrieves the process object of the window that currently has keyboard focus. |
| [Get-DesktopScalingFactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DesktopScalingFactor.md) | &nbsp; | Retrieves the Windows display scaling factor (DPI setting) for a specified monitor. |
| [Get-ForegroundWindow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ForegroundWindow.md) | &nbsp; | Gets the handle of the currently active foreground window. |
| [Get-KnownFolderPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KnownFolderPath.md) | folder | Gets the path of a Windows known folder using the Windows Shell32 API. |
| [Get-MpCmdRunPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MpCmdRunPath.md) | &nbsp; | Gets the path to the Windows Defender MpCmdRun.exe executable. |
| [Get-PowershellMainWindow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PowershellMainWindow.md) | &nbsp; | Returns a window helper object for the PowerShell terminal's main window. |
| [Get-PowershellMainWindowProcess](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PowershellMainWindowProcess.md) | &nbsp; | Returns the process object for the window hosting the PowerShell terminal. |
| [Get-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Window.md) | &nbsp; | Gets window information for specified processes or window handles. |
| [Get-WindowPosition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WindowPosition.md) | gwp | Gets the position and state information of windows. |
| [Initialize-ScheduledTaskScripts](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Initialize-ScheduledTaskScripts.md) | &nbsp; | Creates scheduled tasks that run PowerShell scripts at specified intervals. |
| [Invoke-CommandElevated](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-CommandElevated.md) | &nbsp; | Runs code in an elevated PowerShell session, streaming output back to the original terminal. |
| [Invoke-WindowsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WindowsUpdate.md) | updatewindows | Checks if Windows is up to date and optionally installs available updates. |
| [Pop-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Pop-Window.md) | popw | Pops the last active window helper from the stack with optional modifications. |
| [Push-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Push-Window.md) | pushw | Pushes the current window onto the window stack with optional modifications. |
| [Save-DesktopScreenShot](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-DesktopScreenShot.md) | &nbsp; | Captures a screenshot of the specified monitor and saves it to the specified path. |
| [Send-Key](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Send-Key.md) | sendkeys, invokekeys | Sends simulated keystrokes to a window or process. |
| [Send-WakeOnLan](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Send-WakeOnLan.md) | &nbsp; | Sends a Wake-on-LAN magic packet to wake up remote computers on the network. |
| [Set-ClipboardFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ClipboardFiles.md) | setclipfiles, scbf | Sets files to the Windows clipboard for file operations like copy/paste. |
| [Set-ForegroundWindow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ForegroundWindow.md) | &nbsp; | Brings the specified window to the foreground and makes it the active window. |
| [Set-KnownFolderPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-KnownFolderPath.md) | &nbsp; | Modifies the physical path of a Windows known folder. |
| [Set-MonitorPowerOff](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-MonitorPowerOff.md) | poweroff | Turns off power to all connected monitors. |
| [Set-MonitorPowerOn](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-MonitorPowerOn.md) | wakemonitor, monitoroff | Turns the monitor power on. |
| [Set-TaskbarAlignment](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-TaskbarAlignment.md) | &nbsp; | Configures Windows 11+ taskbar alignment between center and left positions. |
| [Set-WindowPosition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowPosition.md) | wp | Positions and resizes windows when explicit positioning parameters are provided. |
| [Set-WindowPositionForSecondary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowPositionForSecondary.md) | wps | Positions a window on the secondary monitor with specified layout options. |
| [Set-WindowsWallpaper](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowsWallpaper.md) | &nbsp; | Sets a random wallpaper from a specified directory. |
| [Show-ExceptionPanel](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-ExceptionPanel.md) | &nbsp; | Shows an exception in a nice panel using Spectre.Console |
| [Start-ProcessElevated](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-ProcessElevated.md) | &nbsp; | Starts a process with elevated administrator privileges. |
| [Start-ProcessWithPriority](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-ProcessWithPriority.md) | nice | Starts a process with a specified priority level. |
| [Test-PathUsingWindowsDefender](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-PathUsingWindowsDefender.md) | virusscan, HasNoVirus | Scans files or directories for malware using Windows Defender. |
| [Update-Environment](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Environment.md) | &nbsp; | Updates the environment variables in the current session. |

---

## GenXdev.Windows.WireGuard

| Command | Aliases | Description |
|:---|:---|:---|
| [Add-WireGuardPeer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-WireGuardPeer.md) | &nbsp; | Adds a new WireGuard VPN peer (client) configuration to the server. |
| [EnsureWireGuard](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWireGuard.md) | &nbsp; | Ensures WireGuard VPN service is installed and running via Docker container. |
| [Get-WireGuardPeerQRCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardPeerQRCode.md) | &nbsp; | Generates a QR code for a WireGuard VPN peer configuration. |
| [Get-WireGuardPeers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardPeers.md) | &nbsp; | Gets information about all WireGuard VPN peers configured on the system. |
| [Get-WireGuardStatus](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardStatus.md) | &nbsp; | Gets detailed status information about the WireGuard VPN server. |
| [Remove-WireGuardPeer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-WireGuardPeer.md) | &nbsp; | Removes a WireGuard VPN peer configuration. |
| [Reset-WireGuardConfiguration](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Reset-WireGuardConfiguration.md) | &nbsp; | Resets the WireGuard VPN server configuration, removing all peers. |
