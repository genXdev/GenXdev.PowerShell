###############################################################################
<#
.SYNOPSIS
Maximizes the first video element found in the current browser tab.

.DESCRIPTION
Executes JavaScript code to locate and maximize the first video element on the
current webpage. The video is set to cover the entire viewport with maximum
z-index to ensure visibility. Page scrollbars are hidden for a clean fullscreen
experience.

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
Set-BrowserVideoFullscreen
#>
function Set-BrowserVideoFullscreen {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('fsvideo')]
    param(
        ########################################################################
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Microsoft Edge browser'
        )]
        [switch] $Edge,
        ########################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Google Chrome browser'
        )]
        [switch] $Chrome,
        ########################################################################
        [Alias('c')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [switch] $Chromium,
        ########################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Firefox browser'
        )]
        [switch] $Firefox,
        ########################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use the Playwright-managed WebKit browser'
        )]
        [switch] $Webkit
    )

    begin {

        # prepare the javascript command that will handle video manipulation
        $script = @(
            "window.video = document.getElementsByTagName('video')[0];" +
            "video.setAttribute('style','position:fixed;left:0;top:0;bottom:0;" +
            "right:0;z-index:10000;width:100vw;height:100vh');" +
            'document.body.appendChild(video);' +
            "document.body.setAttribute('style', 'overflow:hidden');"
        ) -join ''

        Microsoft.PowerShell.Utility\Write-Verbose 'Prepared JavaScript code for video fullscreen manipulation'
    }


    process {

        # check if we should proceed with the operation
        if ($PSCmdlet.ShouldProcess('browser video', 'Set to fullscreen mode')) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Executing JavaScript to maximize video element'
            GenXdev\Invoke-WebbrowserEvaluation $script
        }
    }

    end {
    }
}