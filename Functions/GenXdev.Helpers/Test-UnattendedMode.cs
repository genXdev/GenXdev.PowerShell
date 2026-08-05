using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Detects if PowerShell is running in unattended/automated mode.
.DESCRIPTION
* Analyzes various indicators to determine if PowerShell is running in
  an unattended or automated context.
* Checks pipeline analysis, environment variables, console redirection,
  and invocation context.
* When CallersInvocation is provided, analyzes the pipeline position and
  count to detect automated pipeline or script execution.

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
Test-UnattendedMode
```

Returns a boolean indicating if running in unattended mode.
.EXAMPLE
```powershell
Test-UnattendedMode -CallersInvocation $MyInvocation
```

Analyzes the caller's invocation context and returns a boolean.
.EXAMPLE
```powershell
Test-UnattendedMode -CallersInvocation $MyInvocation -Detailed
```

Returns detailed analysis object with all indicators.
.EXAMPLE
```powershell
function My-Function {
    $isUnattended = Test-UnattendedMode -CallersInvocation $MyInvocation
    if ($isUnattended) {
        Write-Verbose ""Running in unattended mode""
    }
}
```

Example usage in a function to check for unattended mode.
")]
    [Cmdlet(VerbsDiagnostic.Test, "UnattendedMode")]
    [OutputType(typeof(bool), typeof(PSObject))]
    public partial class TestUnattendedModeCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The caller's invocation information for pipeline and automation detection
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "Caller's invocation info for pipeline and automation detection"
        )]
        public InvocationInfo CallersInvocation { get; set; }

        /// <summary>
        /// Return detailed analysis object instead of simple boolean
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Return detailed analysis object instead of simple boolean"
        )]
        public SwitchParameter Detailed { get; set; }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {

            // Initialize list for unattended indicators
            var unattendedIndicators = new List<string>();

            // Check 1: Environment variables indicating CI/CD or automation
            var automationEnvVars = new[]
            {
                "JENKINS_URL", "GITHUB_ACTIONS", "TF_BUILD", "CI", "BUILD_ID",
                "RUNNER_OS", "SYSTEM_TEAMPROJECT", "TEAMCITY_VERSION", "TRAVIS",
                "APPVEYOR", "CIRCLECI", "GITLAB_CI", "AZURE_PIPELINES"
            };

            // Check if any automation environment variables are set
            var hasAutomationEnv = automationEnvVars.Any(envVar =>
                !string.IsNullOrEmpty(System.Environment.GetEnvironmentVariable(envVar)));

            if (hasAutomationEnv)
            {

                unattendedIndicators.Add("AutomationEnvironment");
            }

            // Check 2: Console redirection
            var hasRedirection = false;
            try
            {

                hasRedirection = System.Console.IsInputRedirected || System.Console.IsOutputRedirected;
            }
            catch
            {
                // If checking redirection fails, assume no redirection
            }

            if (hasRedirection)
            {
                unattendedIndicators.Add("ConsoleRedirection");
            }

            // Check 3: Non-interactive environment
            var isNonInteractive = false;
            try
            {

                // Check if we're running in a service or without a window station
                isNonInteractive = string.IsNullOrEmpty(System.Environment.GetEnvironmentVariable("SESSIONNAME")) &&
                                  string.IsNullOrEmpty(System.Environment.GetEnvironmentVariable("USERDOMAIN"));
            }
            catch
            {
                // If check fails, assume interactive
            }

            if (isNonInteractive)
            {
                unattendedIndicators.Add("NonInteractiveEnvironment");
            }

            // Check 4: PowerShell host indicators
            var automationHosts = new[] { "ServerRemoteHost", "Default Host", "BackgroundHost" };

            // Get host name via PowerShell
            var hostName = (string)this.InvokeScript<string>("$Host.Name");

            var isAutomationHost = automationHosts.Contains(hostName);

            if (isAutomationHost)
            {
                unattendedIndicators.Add($"AutomationHost:{hostName}");
            }

            // Check 5: No console window (for GUI apps calling PowerShell)
            var hasNoConsole = false;
            try
            {

                hasNoConsole = System.Console.WindowWidth == 0;
            }
            catch
            {
                hasNoConsole = true;
            }

            if (hasNoConsole)
            {
                unattendedIndicators.Add("NoConsoleWindow");
            }

            // Check 6: PowerShell execution parameters
            var hasNonInteractiveParam = false;
            try
            {

                // Check if NonInteractive was passed
                hasNonInteractiveParam = this.MyInvocation.BoundParameters.ContainsKey("NonInteractive") ||
                                        (bool)this.InvokeScript<bool>(
                                            "$PSBoundParameters.NonInteractive -or " +
                                            "(Get-Variable -Name PSBoundParameters -Scope 1 " +
                                            "-ErrorAction SilentlyContinue -ValueOnly).NonInteractive");
            }
            catch
            {
                // If check fails, assume no non-interactive parameter
            }

            if (hasNonInteractiveParam)
            {
                unattendedIndicators.Add("NonInteractiveParameter");
            }

            // Check 7: Pipeline analysis (if CallersInvocation provided)
            int? pipelinePosition = null;
            int? pipelineLength = null;
            string scriptName = null;
            string commandLine = null;

            if (this.CallersInvocation != null)
            {

                pipelinePosition = this.CallersInvocation.PipelinePosition;
                pipelineLength = this.CallersInvocation.PipelineLength;
                scriptName = this.CallersInvocation.ScriptName;
                commandLine = this.CallersInvocation.Line;

                // If we're in a multi-command pipeline (not just a single command)
                var isInPipeline = pipelineLength > 1;

                // If we're not at the end of the pipeline (suggesting automated processing)
                var isNotPipelineEnd = pipelinePosition < pipelineLength;

                // Check if called from a script file (not interactive)
                var isFromScript = !string.IsNullOrEmpty(scriptName);

                // Check command line context
                var isAutomatedCommand = !string.IsNullOrEmpty(commandLine) &&
                                        (System.Text.RegularExpressions.Regex.IsMatch(commandLine,
                                            @"^\s*(foreach|%|\||;|&)") ||
                                         System.Text.RegularExpressions.Regex.IsMatch(commandLine,
                                            @"(Get-|Set-|Invoke-|Start-|Stop-).+\|") ||
                                         System.Text.RegularExpressions.Regex.IsMatch(commandLine,
                                            @"\$\w+\s*\|\s*"));

                // Only flag as unattended if we have strong indicators
                // Being in a simple function call from console should not count as unattended
                var isInteractiveFunction = hostName == "ConsoleHost" &&
                                           pipelineLength == 1 &&
                                           string.IsNullOrEmpty(scriptName);

                if (isInPipeline && !isInteractiveFunction)
                {

                    unattendedIndicators.Add($"MultiCommandPipeline:{pipelinePosition}/{pipelineLength}");
                }

                if (isNotPipelineEnd && !isInteractiveFunction)
                {

                    unattendedIndicators.Add("NotPipelineEnd");
                }

                if (isAutomatedCommand && !isInteractiveFunction)
                {

                    unattendedIndicators.Add("AutomatedCommandPattern");
                }
            }

            // Final determination
            var isUnattended = unattendedIndicators.Count > 0;

            // Return detailed object or simple boolean
            if (this.Detailed.ToBool())
            {

                var result = new PSObject();
                result.Properties.Add(new PSNoteProperty("IsUnattended", isUnattended));
                result.Properties.Add(new PSNoteProperty("Indicators", unattendedIndicators.ToArray()));
                result.Properties.Add(new PSNoteProperty("IndicatorCount", unattendedIndicators.Count));
                result.Properties.Add(new PSNoteProperty("HostName", hostName));
                result.Properties.Add(new PSNoteProperty("PipelinePosition", pipelinePosition));
                result.Properties.Add(new PSNoteProperty("PipelineLength", pipelineLength));
                result.Properties.Add(new PSNoteProperty("ScriptName", scriptName));
                result.Properties.Add(new PSNoteProperty("CommandLine", commandLine));

                this.WriteObject(result);
            }
            else
            {

                // Return simple boolean by default
                this.WriteObject(isUnattended);
            }
        }
    }
}