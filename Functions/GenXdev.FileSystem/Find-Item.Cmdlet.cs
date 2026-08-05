using Microsoft.PowerShell.Commands;
using System.Collections;
using System.Management.Automation;
using GenXdev.Helpers;

namespace GenXdev.FileSystem
{

    [Cmdlet(VerbsCommon.Find, "Item", DefaultParameterSetName = "Default")]
    [System.ComponentModel.Description(@"
.SYNOPSIS
Search for files and directories with advanced filtering options.
.DESCRIPTION
* Find files with Find-Item -> l
        * Fast multi-threaded search: utilizes parallel and asynchronous
              IO processing with configurable maximum degree of parallelism
              (default based on CPU cores) for efficient file and directory scanning.
        * Advanced Pattern Matching: Supports wildcards (*, ?), recursive patterns
              like **, and complex path structures for precise file and directory queries.
              **/filename will only recurse until filename is matched. multiple of these
              patterns are allowed, as long as the are preceeded with a filename or
              directoryname to match.
              This pattern parser has the power of Resolve-Path but has recursion
              features, and does only support * and ? as wildcards,
              preventing bugs with paths with [ ] brackets in them, eliminating
              the need for -LiteralPath parameter, while maintaining integrity
              for paths sections without wildcards, unlike a wildcard match on the
              whole full path.
        * Enhanced Content Searching: Comprehensive Select-String integration
              with regular expression patterns within file contents using the
              -Content parameter.
            * Large File Optimization: Handles extremely large files with smart
                  overlapping buffers and minimal heap allocation
            * Multiple Match Options: Find all matches per line (-AllMatches) or
                  just the first match per file(-List)
            * Case Sensitivity Control: Case-sensitive matching(-CaseSensitive)
                  with culture-specific options(-Culture)
            * Context Capture: Show lines before and after matches(-Context) for
                  better understanding
            *Inverse Matching: Find files that don't contain the pattern (-NotMatch)
            * Output Formats: Raw string output(-Raw), quiet boolean response(-Quiet),
                  or full MatchInfo objects
            * Pattern Types: Regular expressions(default) or simple literal string
                  matching(-SimpleMatch)
            * Encoding Support: Specify file encoding(-Encoding) for accurate text
                  processing
        * Path Type Flexibility: Handles relative, absolute, UNC, rooted paths, and
              NTFS alternate data streams(ADS) with optional content search in streams.
        * Multi-Drive Support: Searches across all drives with - AllDrives or specific
              drives via -SearchDrives, including optical disks if specified.
        * Directory and File Filtering: Options to search directories only(-Directory),
              both files and directories(-FilesAndDirectories), or files with content matching.
        * Exclusion and Limits: Exclude patterns with -Exclude, set max recursion depth
              -MaxRecursionDepth), file size limits(-MaxFileSize, -MinFileSize), and modified
              date filters(-ModifiedAfter, -ModifiedBefore).
        * Output Customization: Supports PassThru for FileInfo/DirectoryInfo objects,
              relative paths, hyperlinks in attended mode, or plain paths in unattended mode
              (use -NoLinks in case of mishaps to enforce unattended mode).
        * Performance Optimizations: Skips non-text files by default for content search
              (override with -IncludeNonTextFileMatching), handles long paths(>260 chars),
              and follows symlinks/junctions.
        * Safety Features: Timeout support(-TimeoutSeconds), ignores inaccessible items,
              skips system attributes by default, and prevents infinite loops with visited node tracking.

        * Valid categories for the -Category parameter are: Pictures, Videos, Music, Documents, Spreadsheets, Presentations, Archives, Installers, Executables, Databases, DesignFiles, Ebooks, Subtitles, Fonts, EmailFiles, 3DModels, GameAssets, MedicalFiles, FinancialFiles, LegalFiles, SourceCode, Scripts, MarkupAndData, Configuration, Logs, TextFiles, WebFiles, MusicLyricsAndChords, CreativeWriting, Recipes, ResearchFiles

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.EXAMPLE
```powershell
Find-Item -Content ""translation""

# Short form:
l -mc translation
```

Find files containing a specific word
Search for all files in the current directory and subdirectories that contain the word ""translation"".
.EXAMPLE
```powershell
Find-Item ""*.js"" ""Version == `""\d\d?\.\d\d?\.\d\d?`""""

# Short form:
l *.js ""Version == `""\d\d?\.\d\d?\.\d\d?`""""
```

Find JavaScript files with a version string
Search for JavaScript files containing a version string in the format ""Version == `x.y.z`"".
.EXAMPLE
```powershell
Find-Item -Directory

# Short form:
l -dir
```

List all directories
Find all directories in the current directory and its subdirectories.
.EXAMPLE
```powershell
Find-Item "".\*.xml"" -PassThru | % FullName

# Short form:
l *.xml -pt | % FullName
```

Find XML files and pass objects
Search for all .xml files and pass the results as objects through the pipeline.
.EXAMPLE
```powershell
Find-Item -IncludeAlternateFileStreams

# Short form:
l -ads
```

Include alternate data streams
Search for all files and include their alternate data streams in the results.
.EXAMPLE
```powershell
Find-Item ""*.pdf"" -AllDrives

# Short form:
l *.pdf -alldrives
```

Search across all drives
Search for all PDF files across all available drives.
.EXAMPLE
```powershell
Find-Item ""*.log"" -TimeoutSeconds 300 -MaxDegreeOfParallelism 4

# Short form:
l *.log -maxseconds 300 -threads 4
```

Custom timeout and parallelism
Search for log files with a 5-minute timeout and limited parallelism.
.EXAMPLE
```powershell
Get-ChildItem -Path ""C:\Logs"" | Find-Item -Content ""error""

# Short form:
ls C:\Logs | l -matchcontent ""error""
```

Pipeline input
Pass file paths from Get-ChildItem to search for files containing ""error"".
.EXAMPLE
```powershell
Find-Item ""*.txt"" -MaxRecursionDepth 2

# Short form:
l *.txt -maxdepth 2
```

Limit recursion depth
Search for text files but limit recursion to 2 directory levels.
.EXAMPLE
```powershell
Find-Item -MinFileSize 1048576 -MaxFileSize 10485760

# Short form:
l -minsize 1048576 -maxsize 10485760
```

Filter by file size
Find files larger than 1MB but smaller than 10MB.
.EXAMPLE
```powershell
Find-Item -ModifiedAfter ""2025-01-01""

# Short form:
l -after ""2025-01-01""
```

Filter by modification date
Find files modified after January 1, 2025.
.EXAMPLE
```powershell
Find-Item -Exclude ""*.tmp"", ""*\bin\*""

# Short form:
l -skiplike ""*.tmp"", ""*\bin\*""
```

Exclude specific patterns
Search for all files but exclude temporary files and bin directories.
.EXAMPLE
```powershell
Find-Item ""*.docx"" -SearchDrives ""C:\"", ""D:\""

# Short form:
l *.docx -drives C:\, D:\
```

Search specific drives
Search for .docx files on C: and D: drives only.
.EXAMPLE
```powershell
Find-Item -Content ""Error"" -CaseSensitive

# Short form:
l -mc ""Error"" -CaseSensitive
```

Case-sensitive content search
Search for files containing ""Error"" (case-sensitive) in their content.
.EXAMPLE
```powershell
Find-Item -IncludeAlternateFileStreams -SearchADSContent -Content ""secret""

# Short form:
l -ads -sads -mc ""secret""
```

Search alternate data stream content
Search for files with alternate data streams containing ""secret"".
.EXAMPLE
```powershell
Find-Item ""*.ps1"" -Content ""function"" -AllMatches

# Short form:
l *.ps1 -mc ""function"" -AllMatches
```

Find all matches per line
Search for all occurrences of ""function"" in each line, not just the first match.
.EXAMPLE
```powershell
Find-Item ""*.log"" -Content ""error"" -Context 2,3

# Short form:
l *.log -mc ""error"" -Context 2,3
```

Show context around matches
Display 2 lines before and 3 lines after each match for better understanding.
.EXAMPLE
```powershell
Find-Item ""*.txt"" -Content ""TODO:.*"" -Raw

# Short form:
l *.txt -mc ""TODO:.*"" -Raw
```

Get only matching strings
Return just the matching text strings instead of full match objects.
.EXAMPLE
```powershell
Find-Item ""*.config"" -Content ""database"" -Quiet

# Short form:
l *.config -mc ""database"" -Quiet
```

Simple boolean check
Return true/false instead of match details to check if pattern exists.
.EXAMPLE
```powershell
Find-Item ""*.cs"" -Content ""class.*Controller"" -List

# Short form:
l *.cs -mc ""class.*Controller"" -List
```

Find first match only per file
Stop at the first match in each file for efficient file listing.
.EXAMPLE
```powershell
Find-Item ""*.txt"" -Content ""$variable[0]"" -SimpleMatch

# Short form:
l *.txt -mc ""$variable[0]"" -SimpleMatch
```

Literal string matching
Search for exact text without regex interpretation using SimpleMatch.
.EXAMPLE
```powershell
Find-Item ""*.js"" -Content ""console\.log"" -NotMatch

# Short form:
l *.js -mc ""console\.log"" -NotMatch
```

Find files NOT containing pattern
Use NotMatch to find files that don't contain the specified pattern.
.EXAMPLE
```powershell
Find-Item ""*.txt"" -Content ""café"" -Encoding UTF8

# Short form:
l *.txt -mc ""café"" -Encoding UTF8
```

Specify file encoding
Search files with specific encoding for accurate text processing.
.EXAMPLE
```powershell
Find-Item ""*.txt"" -Content ""Müller"" -SimpleMatch -Culture ""de-DE""

# Short form:
l *.txt -mc ""Müller"" -SimpleMatch -Culture ""de-DE""
```

Cultural text comparison
Use culture-specific matching with SimpleMatch for international text.
.EXAMPLE
```powershell
Find-Item ""*.log"" -Content ""exception"" -MinFileSize 1024 -ModifiedAfter ""2025-01-01"" -MaxRecursionDepth 3

# Short form:
l *.log -mc ""exception"" -minsize 1024 -after ""2025-01-01"" -maxdepth 3
```

Complex content search with file filters
Combine file size, date, and content filters for precise searches.
")]
    [Alias("l")]
    public partial class FindItem : PSGenXdevCmdlet
    {
        /// <summary>
        /// <para type="description">File name or pattern to search for. Supports wildcards (*,?). Default is '*'</para>
        /// </summary>
        [Parameter(Position = 0, Mandatory = false, HelpMessage = "File name or pattern to search for. Default is '*'")]
        [Alias("like", "Path", "LiteralPath", "Query", "SearchMask", "Include")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        public string[] Name { get; set; }

        /// <summary>
        /// <para type="description">File name or pattern to search for from pipeline input. Default is '*'</para>
        /// </summary>
        [Parameter(Mandatory = false, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, HelpMessage = "File name or pattern to search for. Default is '*'")]
        [Alias("FullName")]
        [SupportsWildcards()]
        public object Input { get; set; }

        /// <summary>
        /// <para type="description">Regular expression pattern to search within file contents</para>
        /// </summary>
        [Parameter(Position = 1, Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Regular expression pattern to search within content")]
        [Alias("mc", "matchcontent", "regex", "Pattern")]
        [ValidateNotNull()]
        [SupportsWildcards()]
        public string[] Content { get; set; } = new string[1] { ".*" };

        /// <summary>
        /// <para type="description">Base path for resolving relative paths in output</para>
        /// </summary>
        [Parameter(Position = 2, Mandatory = false, HelpMessage = "Base path for resolving relative paths in output")]
        [Alias("base")]
        [ValidateNotNullOrEmpty()]
        public string RelativeBasePath { get; set; } = ".\\";

        /// <summary>
        /// <para type="description">Only output files belonging to selected categories</para>
        /// </summary>
        [Parameter(Mandatory = false)]
        [Alias("filetype")]
        [ValidateSet(
            "Pictures",
            "Videos",
            "Music",
            "Documents",
            "Spreadsheets",
            "Presentations",
            "Archives",
            "Installers",
            "Executables",
            "Databases",
            "DesignFiles",
            "Ebooks",
            "Subtitles",
            "Fonts",
            "EmailFiles",
            "3DModels",
            "GameAssets",
            "MedicalFiles",
            "FinancialFiles",
            "LegalFiles",
            "SourceCode",
            "Scripts",
            "MarkupAndData",
            "Configuration",
            "Logs",
            "TextFiles",
            "WebFiles",
            "MusicLyricsAndChords",
            "CreativeWriting",
            "Recipes",
            "ResearchFiles"
        )]
        public string[] Category { get; set; }

        /// <summary>
        /// <para type="description">Maximum degree of parallelism for directory tasks</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum degree of parallelism for directory tasks")]
        [Alias("threads")]
        public int MaxDegreeOfParallelism { get; set; } = 0;

        /// <summary>
        /// <para type="description">Optional: cancellation timeout in seconds</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Optional: cancellation timeout in seconds")]
        [Alias("maxseconds")]
        public int? TimeoutSeconds { get; set; }

        /// <summary>
        /// <para type="description">Search across all available drives</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Search across all available drives")]
        public SwitchParameter AllDrives { get; set; }

        /// <summary>
        /// <para type="description">Search for directories only</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Search for directories only")]
        [Alias("dir")]
        public SwitchParameter Directory { get; set; }

        /// <summary>
        /// <para type="description">Include both files and directories</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Include both files and directories")]
        [Alias("both", "DirectoriesAndFiles")]
        public SwitchParameter FilesAndDirectories { get; set; }

        /// <summary>
        /// <para type="description">Output matched items as objects</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Output matched items as objects")]
        [Alias("pt")]
        public SwitchParameter PassThru { get; set; }

        /// <summary>
        /// <para type="description">Include alternate data streams in search results
        /// </para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Include alternate data streams in search results")]
        [Alias("ads")]
        public SwitchParameter IncludeAlternateFileStreams { get; set; }

        /// <summary>
        /// <para type="description">Do not recurse into subdirectories</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Do not recurse into subdirectories")]
        [Alias("nr")]
        public SwitchParameter NoRecurse { get; set; }

        /// <summary>
        /// <para type="description">Follow symlinks and junctions during directory
        /// traversal</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Follow symlinks and junctions during directory traversal")]
        [Alias("symlinks", "sl")]
        public SwitchParameter FollowSymlinkAndJunctions { get; set; }

        /// <summary>
        /// <para type="description">Include optical disk drives</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Include optical disk drives")]
        public SwitchParameter IncludeOpticalDiskDrives { get; set; }

        /// <summary>
        /// <para type="description">Optional: search specific drives</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Optional: search specific drives")]
        [Alias("drives")]
        public string[] SearchDrives { get; set; } = Array.Empty<string>();

        /// <summary>
        /// <para type="description">Optional: search specific drives</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Optional: search specific drives")]
        public char[] DriveLetter { get; set; } = Array.Empty<char>();

        /// <summary>
        /// <para type="description">Optional: search specific base folders combined with provided Names</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Optional: search specific directories")]
        public string[] Root { get; set; } = Array.Empty<string>();

        /// <summary>
        /// <para type="description">Enforces searching only within Root directories by stripping directory components from Name inputs, preventing absolute or relative path escapes</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Enforces searching only within Root directories by stripping directory components from Name inputs")]
        [Alias("limit")]
        public SwitchParameter LimitToRoot { get; set; }

        /// <summary>
        /// <para type="description">Include non-text files (binaries, images, etc.)
        /// when searching file contents</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Include non-text files when searching file contents")]
        [Alias("binary")]
        public SwitchParameter IncludeNonTextFileMatching { get; set; }

        /// <summary>
        /// <para type="description">Forces unattended mode and will not generate
        /// links</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Forces unattended mode and will not generate links")]
        [Alias("nl", "ForceUnattenedMode")]
        public SwitchParameter NoLinks { get; set; }

        /// <summary>Gets or sets the case-sensitivity for files and directories.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Gets or sets the case-sensitivity for files and directories")]
        [Alias("casing", "CaseSearchMaskMatching ")]
        public System.IO.MatchCasing CaseNameMatching { get; set; } = System.IO.MatchCasing.PlatformDefault;

        /// <summary>
        /// <para type="description">
        /// When set, performs content search within alternate data streams (ADS). When
        /// not set,
        /// outputs ADS file info without searching their content.
        /// </para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "When set, performs content search within alternate data streams (ADS). When not set, outputs ADS file info without searching their content.")]
        [Alias("sads")]
        public SwitchParameter SearchADSContent { get; set; }

        /// <summary>
        /// <para type="description">Maximum recursion depth for directory traversal. 0
        /// means unlimited.</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum recursion depth for directory traversal. 0 means unlimited.")]
        [Alias("md", "depth", "maxdepth")]
        public int MaxRecursionDepth { get; set; } = 0;


        /// <summary>
        /// <para type="description">Maximum recursion depth for searching upwards the tree. 0 means disabled.</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum recursion depth for continuing searching upwards the tree for relative searches, while no items are found. 0 means disabled.")]
        [Alias("maxupward")]
        public int MaxSearchUpDepth { get; set; } = 0;

        /// <summary>
        /// <para type="description">Maximum file size in bytes to include in results. 0
        /// means unlimited.</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum file size in bytes to include in results. 0 means unlimited.")]
        [Alias("maxlength", "maxsize")]
        public long MaxFileSize { get; set; } = 0;

        /// <summary>
        /// <para type="description">Minimum file size in bytes to include in results. 0
        /// means no minimum.</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Minimum file size in bytes to include in results. 0 means no minimum.")]
        [Alias("minsize", "minlength")]
        public long MinFileSize { get; set; } = 0;

        /// <summary>
        /// <para type="description">Only include files modified after this date/time
        /// (UTC).</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Only include files modified after this date/time (UTC).")]
        [Alias("ma", "after")]
        public System.DateTime? ModifiedAfter { get; set; }

        /// <summary>
        /// <para type="description">Only include files modified before this date/time
        /// (UTC).</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Only include files modified before this date/time (UTC).")]
        [Alias("before", "mb")]
        public System.DateTime? ModifiedBefore { get; set; }

        /// <summary>Gets or sets the attributes to skip. The default is
        /// <c>FileAttributes.System</c>.</summary>
        [Parameter(Mandatory = false, HelpMessage = "File attributes to skip (e.g., System, Hidden or None).")]
        [Alias("skipattr")]
        public FileAttributes AttributesToSkip { get; set; } = FileAttributes.System;

        /// <summary>
        /// <para type="description">Exclude files or directories matching these
        /// wildcard patterns (e.g., *.tmp, *\bin\*).</para>
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Exclude files or directories matching these wildcard patterns (e.g., *.tmp, *\\bin\\*).")]
        [Alias("skiplike")]
        public string[] Exclude { get; set; } = new string[1] { "*\\.git\\*" };

        /// <summary>
        /// <para type="description">Indicates that the cmdlet searches for more than one match in each line of text. Without this parameter, Select-String finds only the first match in each line of text.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Indicates that the cmdlet searches for more than one match in each line of text. Without this parameter, Select-String finds only the first match in each line of text.")]
        public SwitchParameter AllMatches { get; set; }

        /// <summary>
        /// <para type="description">Indicates that the cmdlet matches are case-sensitive. By default, matches aren't case-sensitive.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Indicates that the cmdlet matches are case-sensitive. By default, matches aren't case-sensitive.")]
        public SwitchParameter CaseSensitive { get; set; }

        /// <summary>
        /// <para type="description">Captures the specified number of lines before and after the line that matches the pattern.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Captures the specified number of lines before and after the line that matches the pattern.")]
        public int[] Context { get; set; } = null;

        /// <summary>
        /// <para type="description">Specifies a culture name to match the specified pattern. The Culture parameter must be used with the SimpleMatch parameter. The default behavior uses the culture of the current PowerShell runspace (session).</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Specifies a culture name to match the specified pattern. The Culture parameter must be used with the SimpleMatch parameter. The default behavior uses the culture of the current PowerShell runspace (session).")]
        public string Culture { get; set; }

        /// <summary>
        /// <para type="description">Specifies the type of encoding for the target file. The default value is utf8NoBOM.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Specifies the type of encoding for the target file. Supports Select-String compatible values and extended .NET encodings.")]
        [ValidateSet("ASCII", "ANSI", "BigEndianUnicode", "BigEndianUTF32", "OEM", "Unicode", "UTF7", "UTF8", "UTF8BOM", "UTF8NoBOM", "UTF32", "Default")]
        public string Encoding { get; set; } = "UTF8NoBOM";

        /// <summary>
        /// <para type="description">Only the first instance of matching text is returned from each input file. This is the most efficient way to retrieve a list of files that have contents matching the regular expression.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Only the first instance of matching text is returned from each input file. This is the most efficient way to retrieve a list of files that have contents matching the regular expression.")]
        public SwitchParameter List { get; set; }

        /// <summary>
        /// <para type="description">
        /// By default, Select-String highlights the string that matches the pattern you
        /// searched for with the Pattern parameter. The NoEmphasis parameter disables
        /// the highlighting. The emphasis uses negative colors based on your PowerShell
        /// background and text colors. For example, if your PowerShell colors are a
        /// black background with white text, the emphasis is a white background with
        /// black text.
        /// </para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Disables highlighting of matching strings in output.")]
        public SwitchParameter NoEmphasis { get; set; }

        /// <summary>
        /// <para type="description">The NotMatch parameter finds text that doesn't match the specified pattern.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "The NotMatch parameter finds text that doesn't match the specified pattern.")]
        public SwitchParameter NotMatch { get; set; }

        /// <summary>
        /// <para type="description">Indicates that the cmdlet returns a simple response instead of a MatchInfo object. The returned value is $true if the pattern is found or $null if the pattern is not found.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Indicates that the cmdlet returns a simple response instead of a MatchInfo object. The returned value is $true if the pattern is found or $null if the pattern is not found.")]
        public SwitchParameter Quiet { get; set; }

        /// <summary>
        /// <para type="description">Causes the cmdlet to output only the matching strings, rather than MatchInfo objects. This is the results in behavior that's the most similar to the Unix grep or Windows findstr.exe commands.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Causes the cmdlet to output only the matching strings, rather than MatchInfo objects. This is the results in behavior that's the most similar to the Unix grep or Windows findstr.exe commands.")]
        public SwitchParameter Raw { get; set; }

        /// <summary>
        /// <para type="description">Indicates that the cmdlet uses a simple match rather than a regular expression match. In a simple match, Select-String searches the input for the text in the Pattern parameter. It doesn't interpret the value of the Pattern parameter as a regular expression statement.</para>
        /// </summary>
        [Parameter(Mandatory = false, ParameterSetName = "WithPattern", HelpMessage = "Indicates that the cmdlet uses a simple match rather than a regular expression match. In a simple match, Select-String searches the input for the text in the Pattern parameter. It doesn't interpret the value of the Pattern parameter as a regular expression statement.")]
        public SwitchParameter SimpleMatch { get; set; }

        // Cmdlet lifecycle methods
        protected override void BeginProcessing()
        {
            // set up verbose logging based on user preference
            InitializeVerboseOutput();

            // configure buffering for large file processing
            InitializeBufferingConfiguration();

            // set up parallelism based on user input or defaults
            InitializeParallelismConfiguration();

            // detect if running in unattended mode for output formatting
            UnattendedMode = NoLinks.ToBool() || UnattendedModeHelper.IsUnattendedMode(MyInvocation);

            // prepare dictionary to track visited nodes for loop prevention
            InitializeVisitedNodes();

            // prepare wildcard matching for exclusions
            InitializeWildcardMatcher();

            // set up exclusion patterns for files and directories
            InitializeExcludePatterns();

            // determine current working directory for relative paths
            InitializeCurrentDirectory();

            // resolve base path for relative output
            InitializeRelativeBaseDir();

            // initialize LimitToRoot allowed paths
            InitializeLimitToRoot();

            // set up cancellation with optional timeout
            InitializeCancellationToken();

            // initialize provided names for searching
            InitializeProvidedNames();

            hadInput = MyInvocation.BoundParameters.ContainsKey("Input") ||
                (MyInvocation.PipelineLength > 1 && MyInvocation.PipelinePosition > 1);
        }

        protected override void ProcessRecord()
        {
            ProcessInputObject(Input);
        }

        private bool ProcessInputObject(object o)
        {
            if (o == null) return false;

            if (UseVerboseOutput)
            {
                VerboseQueue.Enqueue($"Processing input object of type: {o?.GetType().FullName ?? "null"}");
            }

            if (o is System.Management.Automation.PSObject)
            {
                o = (o as System.Management.Automation.PSObject).ImmediateBaseObject;
            }

            if (o is MatchInfo)
            {
                if (processInputString((o as MatchInfo).Path)) return false;
            }

            if (o is string)
            {
                if (processInputString(o as string)) return false;
            }

            if (o is System.IO.FileInfo)
            {
                if (processInputString((o as System.IO.FileInfo).FullName)) return false;
            }

            if (o is System.IO.DirectoryInfo)
            {
                if (processInputString((o as System.IO.DirectoryInfo).FullName)) return false;
            }

            if (o is IEnumerable)
            {
                foreach (var obj in (IEnumerable)o)
                {
                    ProcessInputObject(obj);
                }

                return false;
            }

            return true;
        }

        private bool processInputString(string o)
        {
            if (string.IsNullOrEmpty(o)) return false;
            hadInput = true;

            foreach (var namePart in o.Split(";"))
            {
                // add to visited if new and initialize search
                if (VisitedNodes.TryAdd("start;" + namePart, true))
                {
                    string name = namePart;

                    // Strip directory components when LimitToRoot is enabled
                    if (LimitToRoot.ToBool())
                    {
                        name = Path.GetFileName(name.Replace("/", "\\"));
                        if (UseVerboseOutput)
                        {
                            VerboseQueue.Enqueue($"LimitToRoot: Pipeline input stripped to '{name}'");
                        }
                    }

                    bool hasLongPathPrefix;
                    bool isUncPath;
                    string UncMachineNameToEnumerate;

                    EnsureFullProvidedLocationAndNamePart(
                        ref name,
                        out hasLongPathPrefix,
                        out isUncPath,
                        out UncMachineNameToEnumerate
                    );

                    var fi = new FileInfo(name);

                    if (string.IsNullOrWhiteSpace(UncMachineNameToEnumerate) && fi.Exists)
                    {
                        name = System.IO.Path.GetDirectoryName(name);

                        if (!ShouldFileBeExcluded(fi))
                        {
                            AddToOutputQueue(fi);
                        }
                    }

                    InitializeSearchDirectory(name, false);
                }
                else
                    if (UseVerboseOutput)
                    {
                        // log skipping duplicate mask
                        WriteWarning($"Skipping duplicate name: {namePart}");
                    }
            }

            return true;
        }

        protected override void EndProcessing()
        {
            try
            {
                // check for no params
                if (DirQueue.Count == 0)
                {
                    if (hadInput)
                    {
                        if (UseVerboseOutput)
                        {
                            VerboseQueue.Enqueue("Nothing to do");
                        }
                        return;
                    }
                    if (UseVerboseOutput)
                    {

                        // log skipping duplicate mask
                        VerboseQueue.Enqueue($"No input, adding current directory to the queue: {CurrentDirectory}\\");
                    }

                    InitializeSearchDirectory(CurrentDirectory + "\\", true);
                }

                // allow new workers to be created
                isStarted = true;

                // run the search tasks
                ProcessSearchTasks();

            }
            finally
            {
                // clear all queues
                EmptyQueues();
                MatchContentProcessor p; while (MatchContentProcessors.TryDequeue(out p)) ;
                GC.Collect();

                // create completion progress record
                var completeRecord = new ProgressRecord(0, "FastFileSearch", "Completed")
                {
                    // set completion percentage
                    PercentComplete = 100,

                    // mark as completed
                    RecordType = ProgressRecordType.Completed
                };

                // output completion progress
                WriteProgress(completeRecord);

                // restore configuration
                ThreadPool.SetMaxThreads(this.oldMaxWorkerThread, this.oldMaxCompletionPorts);

                // clean up cancellation source
                cts?.Dispose();
            }
        }

        protected override void StopProcessing()
        {

            // trigger cancellation
            cts?.Cancel();
        }
    }
}