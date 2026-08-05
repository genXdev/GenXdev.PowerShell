###############################################################################
<#
.SYNOPSIS
Sends simulated keystrokes to a window or process.

.DESCRIPTION
This function sends keyboard input to a target window or process using the
Windows Script Host Shell object. It can target windows by process name,
process ID, or window handle. The function supports special key sequences,
escape characters, and various timing options for reliable key delivery.

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

.PARAMETER KeysToSend
The keyboard input to send as an array of strings. Each string in the
array represents a sequence of keystrokes and is processed sequentially,
with optional delays between them if specified in the cmdlet logic.

The input format for each keystroke string follows the following syntax;

It supports plain characters, special key sequences in braces {},
modifiers for key combinations (SHIFT, CTRL, ALT), and repeat counts.

Keystroke String Details

Plain Characters: Use the character itself (e.g., 'A' for A, 'abc' for a, b, c in sequence).
Special Characters: Characters like +, ^, %, ~, (, ), {, }, [, ] have special meanings. To send them literally,
enclose in braces: '{+}' for plus, '{^}' for caret, etc. For braces: '{{}' for '{' and '{}}' for '}'. For brackets: '{[}' or '{]}'.
Non-Printable/Action Keys: Enclose key codes in braces. Common keys include:

BACKSPACE: {BACKSPACE}, {BS}, {BKSP}
BREAK: {BREAK}
CAPS LOCK: {CAPSLOCK}
DEL/DELETE: {DELETE}, {DEL}
DOWN ARROW: {DOWN}
END: {END}
ENTER: {ENTER}, ~
ESC: {ESC}
HELP: {HELP}
HOME: {HOME}
INS/INSERT: {INSERT}, {INS}
LEFT ARROW: {LEFT}
NUM LOCK: {NUMLOCK}
PAGE DOWN: {PGDN}
PAGE UP: {PGUP}
PRINT SCREEN: {PRTSC}
RIGHT ARROW: {RIGHT}
SCROLL LOCK: {SCROLLLOCK}
TAB: {TAB}
UP ARROW: {UP}
Function-Keys: {F1} to {F16}

Modifiers for Key Combinations:

for SHIFT (e.g., '+A' for Shift+A)
^ for CTRL (e.g., '^C' for Ctrl+C)
% for ALT (e.g., '%F' for Alt+F)

Group combinations with parentheses: '+(EC)' to hold SHIFT while pressing E then C.
Repeating Keys: Use '{key number}' with a space between
e.g., '{A 5}' presses A five times; '{LEFT 10}' presses left arrow 10 times

.PARAMETER SendKeyEscape
When specified, escapes curly braces in the input text so they are sent as
literal characters rather than interpreted as special key sequences.

.PARAMETER ProcessName
The name of the target process to send keys to. Supports wildcard patterns
for flexible process matching.

.PARAMETER ProcessId
The process ID of the target process to send keys to. Provides precise
targeting when multiple processes have similar names.

.PARAMETER WindowHandle
The window handle (HWND) of the target window to send keys to. Offers
direct window targeting when the handle is known.

.PARAMETER SendKeyHoldKeyboardFocus
When specified, keeps keyboard focus on the target window after sending
keys instead of returning focus to the PowerShell window.

.PARAMETER SendKeyUseShiftEnter
When specified, converts newline characters to Shift+Enter key sequences
instead of regular Enter key sequences.

.PARAMETER SendKeyDelayMilliSeconds
The delay in milliseconds between sending different key sequences. Helps
ensure reliable delivery when sending multiple key strings.

.EXAMPLE
Send-Key -KeysToSend "Hello World{ENTER}" -ProcessName "notepad"
Sends text to Notepad followed by Enter key using process name targeting.

.EXAMPLE
Send-Key "Special {F11} key" -SendKeyEscape -ProcessId 1234
Sends literal "{F11}" text rather than F11 key using process ID targeting.

.EXAMPLE
sendkeys "Line 1{ENTER}Line 2" -WindowHandle 123456 -SendKeyDelayMilliSeconds 50
Sends multi-line text with custom delay using window handle targeting.
#>
function Send-Key {

    [CmdletBinding(DefaultParameterSetName = 'ByProcessName')]
    [Alias('sendkeys', 'invokekeys')]
    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            HelpMessage = 'The keyboard input to send as an array of strings'
        )]
        [string[]] $KeysToSend,
        ###############################################################################
        [Parameter(
            ParameterSetName = 'ByProcessName',
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Name of the process to send keys to (supports wildcards)'
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string] $ProcessName,
        ###############################################################################
        [Parameter(
            ParameterSetName = 'ByProcessId',
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'ID of the process to send keys to'
        )]
        [ValidateNotNull()]
        [Alias('Id', 'PID')]
        [int] $ProcessId,
        ###############################################################################
        [Parameter(
            ParameterSetName = 'ByWindowHandle',
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Window handle to send keys to'
        )]
        [ValidateNotNull()]
        [Alias('Handle', 'hWnd')]
        [long] $WindowHandle,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers in input text'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window after sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter for newlines'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay between different input strings in milliseconds'
        )]
        [ValidateRange(0, [int]::MaxValue)]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds = 10
    )

    begin {

        # initialize the windows script host shell object for sending keystrokes
        $helper = Microsoft.PowerShell.Utility\New-Object -ComObject WScript.Shell

        # initialize window variable for target window operations
        $window = $null;

        # attempt to locate the target window if targeting parameters are provided
        if ($null -eq $window) {
            try {
                # copy relevant parameters for get-window cmdlet invocation
                $invocationArguments = GenXdev\Copy-IdenticalParamValues `
                    -FunctionName 'GenXdev\Get-Window' `
                    -BoundParameters $PSBoundParameters `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # check if any window targeting parameters were provided
                if ((-not [string]::IsNullOrWhiteSpace($ProcessName)) -or `
                    ($ProcessId -ne 0) -or `
                    ($WindowHandle -ne 0)) {

                    # retrieve the first matching window for the specified criteria
                    $window = GenXdev\Get-Window @invocationArguments `
                        -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Utility\Select-Object -First 1
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning $_.Exception.Message
            }
        }

        # bring the target window to foreground if one was found
        if ($null -ne $window) {

            $null = $window.SetForeground()

            # allow time for window activation to complete
            Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500
        }
    }

    process {

    }

    end {

        try {
            # iterate through each key sequence string to send
            foreach ($key in $KeysToSend) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Processing key sequence: $key"

                try {
                    # join array elements into a single string for processing
                    $escapedQuery = $key -join ' '

                    # escape curly braces if escape mode is enabled
                    if ($SendKeyEscape) {
                        $escapedQuery = $escapedQuery -replace '(\{)', '{{}'

                        $escapedQuery = $escapedQuery -replace '(\})', '{}}'
                    }

                    # normalize line endings to consistent newline format
                    $escapedQuery = $escapedQuery -replace '`r', '`n'

                    $escapedQuery = $escapedQuery -replace '`n`n', '`n'

                    # convert newlines to appropriate key sequences based on mode
                    if ($SendKeyUseShiftEnter) {
                        $escapedQuery = $escapedQuery -replace '`n', '+{ENTER}'
                    }
                    else {
                        $escapedQuery = $escapedQuery -replace '`n', '{ENTER}'
                    }

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Sending keys: $escapedQuery"

                    if ($key -eq '^v') {
                        Microsoft.PowerShell.Utility\Start-Sleep 2
                    }

                    # send the processed key sequence to the target window
                    $null = $helper.sendKeys($escapedQuery, $true)

                    # apply delay between key sequences if specified
                    if ($SendKeyDelayMilliSeconds -gt 0) {
                        Microsoft.PowerShell.Utility\Start-Sleep `
                            -Milliseconds $SendKeyDelayMilliSeconds
                    }
                    if ($key -eq '^v') {
                        Microsoft.PowerShell.Utility\Start-Sleep 2
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning $_.Exception.Message
                }
            }
        }
        finally {
            # handle window focus restoration after key sending is complete
            if ($null -ne $window) {
                try {

                    # restore powershell window focus unless holding focus was requested
                    if (-not $SendKeyHoldKeyboardFocus) {
                        try {
                            Microsoft.PowerShell.Utility\Write-Verbose `
                                'Restoring PowerShell window focus'

                            GenXdev\Set-WindowPosition -SetForeground -FocusWindow
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning `
                                $_.Exception.Message
                        }
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning $_.Exception.Message
                }
            }
        }
    }

}
###############################################################################