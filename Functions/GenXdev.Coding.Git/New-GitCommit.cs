using System.Management.Automation;

namespace GenXdev.Coding.Git
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Creates and pushes a new git commit with all changes.
.DESCRIPTION
Stages all changes in the current git repository, creates a commit with the specified title, and pushes the changes to the remote origin. Automatically sets up upstream tracking if needed.

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
New-GitCommit -Title ""Added new authentication feature""
```

Create a commit with a custom message ""Added new authentication feature"".

.EXAMPLE
```powershell
commit ""Hotfix for login issue""
```

Create a commit using the 'commit' alias with default message.
")]
    [Cmdlet(VerbsCommon.New, "GitCommit")]
    [Alias("commit")]
    [OutputType(typeof(void))]
    public class NewGitCommitCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The commit message title to use
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            ValueFromRemainingArguments = false,
            HelpMessage = "The commit message title to use")]
        public string Title { get; set; } = "Improved scripts";

        private string branch;

        /// <summary>
        /// Initialize the cmdlet and extract the current branch name
        /// </summary>
        protected override void BeginProcessing()
        {
            // Extract the current branch name from git's symbolic reference
            var branchResult = InvokeCommand.InvokeScript("git symbolic-ref refs/remotes/origin/HEAD");

            if (branchResult.Count > 0 && branchResult[0].BaseObject != null)
            {
                string branchRef = branchResult[0].BaseObject.ToString();
                branch = branchRef.Split('/')[3];
                WriteVerbose($"Operating on git branch: {branch}");
                System.Console.WriteLine($"Current branch: {branch}");
            }
            else
            {
                WriteError(new ErrorRecord(new Exception("Failed to get branch information"), "BranchDetectionFailed", ErrorCategory.OperationStopped, null));
                return;
            }
        }

        /// <summary>
        /// Process the commit operation
        /// </summary>
        protected override void ProcessRecord()
        {
            if (string.IsNullOrEmpty(branch))
            {
                WriteError(new ErrorRecord(
                    new InvalidOperationException("Branch information is not available."),
                    "BranchNotSet",
                    ErrorCategory.InvalidOperation,
                    null));
                return;
            }

            // Add all changed files to git staging area
            WriteVerbose("Staging all modified files...");
            if (ShouldProcess("all changes", "git add"))
            {
                var addScript = ScriptBlock.Create("$gitOutput = git add * 2>&1; $gitOutput; $LASTEXITCODE");
                var addResult = addScript.Invoke();
                int exitCode = 0;
                for (int i = 0; i < addResult.Count; i++)
                {
                    if (i == addResult.Count - 1 && addResult[i].BaseObject is int ec)
                    {
                        exitCode = ec;
                    }
                    else if (addResult[i].BaseObject != null && addResult[i].BaseObject is string output)
                    {
                        System.Console.WriteLine(output);
                    }
                }
                if (exitCode != 0)
                {
                    WriteError(new ErrorRecord(new Exception("Failed to stage changes"), "GitAddFailed", ErrorCategory.OperationStopped, null));
                    return;
                }
            }

            // Create a new commit with the specified title
            WriteVerbose($"Creating commit with message: {Title}");
            if (ShouldProcess($"commit with title: {Title}", "git commit"))
            {
                var commitScript = ScriptBlock.Create("param($title) $gitOutput = git commit -m $title 2>&1; $gitOutput; $LASTEXITCODE");
                var commitResult = commitScript.Invoke(Title);
                int exitCode = 0;
                for (int i = 0; i < commitResult.Count; i++)
                {
                    if (i == commitResult.Count - 1 && commitResult[i].BaseObject is int ec)
                    {
                        exitCode = ec;
                    }
                    else if (commitResult[i].BaseObject != null && commitResult[i].BaseObject is string output)
                    {
                        System.Console.WriteLine(output);
                    }
                }
                if (exitCode != 0)
                {
                    WriteError(new ErrorRecord(new Exception("Failed to create commit"), "GitCommitFailed", ErrorCategory.OperationStopped, null));
                    return;
                }
            }

            // Ensure branch is tracking upstream remote
            WriteVerbose($"Configuring upstream tracking to origin/{branch}");
            if (ShouldProcess($"upstream branch to origin/{branch}", "git push -u"))
            {
                var upstreamScript = ScriptBlock.Create("param($branch) $gitOutput = git push -u origin $branch 2>&1; $gitOutput; $LASTEXITCODE");
                var upstreamResult = upstreamScript.Invoke(branch);
                int exitCode = 0;
                for (int i = 0; i < upstreamResult.Count; i++)
                {
                    if (i == upstreamResult.Count - 1 && upstreamResult[i].BaseObject is int ec)
                    {
                        exitCode = ec;
                    }
                    else if (upstreamResult[i].BaseObject != null && upstreamResult[i].BaseObject is string output)
                    {
                        System.Console.WriteLine(output);
                    }
                }
                if (exitCode != 0)
                {
                    WriteError(new ErrorRecord(new Exception("Failed to set upstream branch"), "GitUpstreamFailed", ErrorCategory.OperationStopped, null));
                    return;
                }
            }

            // Push committed changes to remote repository
            WriteVerbose("Pushing changes to remote repository...");
            if (ShouldProcess("changes to remote", "git push"))
            {
                var pushScript = ScriptBlock.Create("$gitOutput = git push 2>&1; $gitOutput; $LASTEXITCODE");
                var pushResult = pushScript.Invoke();
                int exitCode = 0;
                for (int i = 0; i < pushResult.Count; i++)
                {
                    if (i == pushResult.Count - 1 && pushResult[i].BaseObject is int ec)
                    {
                        exitCode = ec;
                    }
                    else if (pushResult[i].BaseObject != null && pushResult[i].BaseObject is string output)
                    {
                        System.Console.WriteLine(output);
                    }
                }
                if (exitCode != 0)
                {
                    WriteError(new ErrorRecord(new Exception("Failed to push changes"), "GitPushFailed", ErrorCategory.OperationStopped, null));
                    return;
                }
            }
        }

        /// <summary>
        /// Clean up after processing
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}