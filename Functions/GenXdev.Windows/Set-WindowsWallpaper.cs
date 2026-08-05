using System.Management.Automation;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Sets a random wallpaper from a specified directory.
.DESCRIPTION
* Selects a random image file from the specified directory and sets it as
  the Windows desktop wallpaper.
* Supports JPG/JPEG image formats and configures the wallpaper to ""fit""
  the screen by default.

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
Set-WindowsWallpaper -InputObject ""C:\Wallpapers\*.jpg""
```

Sets a random wallpaper from the C:\Wallpapers directory.
.EXAMPLE
```powershell
nextbg
```

Sets a random wallpaper from the default directory using the alias.
")]
    [Cmdlet(VerbsCommon.Set, "WindowsWallpaper")]
    [OutputType(typeof(void))]
    public class SetWindowsWallpaperCommand : PSGenXdevCmdlet
    {
        private List<string> fileNames = new List<string>();

        /// <summary>
        /// The file path pattern to search for wallpaper images. Supports wildcards and
        /// recursive search. This is the path to the directory containing the wallpaper
        /// images. When multiple images are found, one is selected at random.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "Path to the directory containing the wallpaper images",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Alias("Path", "FullName", "FilePath", "Input")]
        public object InputObject { get; set; } = ".\\";

        /// <summary>
        /// Search across all available drives.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Search across all available drives"
        )]
        public SwitchParameter AllDrives { get; set; }

        /// <summary>
        /// Do not recurse into subdirectories.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Do not recurse into subdirectories"
        )]
        public SwitchParameter NoRecurse { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Copy parameters using base method
            var paramsDict = CopyIdenticalParamValues("GenXdev\\ResolveInputObjectFileNames");

            // Call ResolveInputObjectFileNames
            var resolveScript = ScriptBlock.Create("param($params) GenXdev\\ResolveInputObjectFileNames @params");
            var resolveResult = resolveScript.Invoke(paramsDict);

            // Collect file names
            foreach (var item in resolveResult)
            {
                var psObj = item as PSObject;
                if (psObj != null)
                {
                    fileNames.Add(psObj.BaseObject.ToString());
                }
                else
                {
                    fileNames.Add(item.ToString());
                }
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // No processing per record, all done in EndProcessing
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // Select a random file and set wallpaper
            if (fileNames.Count > 0)
            {
                var random = new Random();
                var selectedFile = fileNames[random.Next(fileNames.Count)];

                // Expand the path
                string file = ExpandPath(selectedFile);

                // Write verbose message
                WriteVerbose($"Selected wallpaper: {file}");

                // Check if should process
                if (ShouldProcess(file, "Set Windows wallpaper"))
                {
                    // Set registry values
                    using (var key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true))
                    {
                        if (key != null)
                        {
                            key.SetValue("Wallpaper", file);
                            key.SetValue("WallpaperStyle", "10");
                            key.SetValue("TileWallpaper", "0");
                        }
                    }

                    // Update wallpaper using SystemParametersInfo
                    SystemParametersInfo(20, 0, file, 0x1 | 0x2);

                    // Write verbose message
                    WriteVerbose("Wallpaper has been updated successfully");
                }
            }
        }

        // P/Invoke declaration for SystemParametersInfo
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
}