using NAudio.CoreAudioApi;
using NAudio.Wave;
using System.Management.Automation;

namespace GenXdev.Hardware
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the names of available audio devices for microphone or desktop audio capture.
.DESCRIPTION
Enumerates audio devices that can be used with other cmdlets that accept an AudioDevice parameter. It supports both microphone devices and desktop audio capture devices.

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
Get-AudioDeviceNames
```

Retrieves a list of available microphone device names.
.EXAMPLE
```powershell
Get-AudioDeviceNames -UseDesktopAudioCapture
```

Retrieves a list of available desktop audio capture device names.
.EXAMPLE
```powershell
Get-AudioDeviceNames -Passthru
```

Retrieves detailed objects containing information about microphone devices.
")]
    [Cmdlet(VerbsCommon.Get, "AudioDeviceNames")]
    public class GetAudioDeviceNames : PSGenXdevCmdlet
    {
        #region Cmdlet Parameters
        /// <summary>
        /// Specifies whether to list desktop audio capture devices instead of microphone devices
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to list desktop audio capture devices instead of microphone devices")]
        public SwitchParameter UseDesktopAudioCapture { get; set; }

        /// <summary>
        /// Returns detailed device objects instead of just names
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Returns detailed device objects instead of just names")]
        public SwitchParameter Passthru { get; set; }
        #endregion

        /// <summary>
        /// Processes each input object and retrieves audio device information
        /// </summary>
        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            try
            {
                // Determine which type of devices to enumerate based on the switch parameter
                if (UseDesktopAudioCapture.ToBool())
                {
                    ListDesktopAudioDevices();
                }
                else
                {
                    ListMicrophoneDevices();
                }
            }
            catch (Exception ex)
            {
                // Handle any unexpected errors during device enumeration
                WriteError(new ErrorRecord(ex, "AudioDeviceEnumerationError", ErrorCategory.OperationStopped, null));
            }
        }

        /// <summary>
        /// Enumerates and lists available microphone devices
        /// </summary>
        private void ListMicrophoneDevices()
        {
            // Inform the user that microphone device enumeration is starting
            WriteVerbose("Enumerating microphone devices...");

            // Loop through all available microphone devices
            for (int i = 0; i < WaveIn.DeviceCount; i++)
            {
                try
                {
                    // Retrieve capabilities for the current device index
                    var deviceInfo = WaveIn.GetCapabilities(i);

                    // Check if detailed objects should be returned
                    if (Passthru.ToBool())
                    {
                        // Create a PowerShell object with detailed device information
                        var deviceObject = new PSObject();
                        deviceObject.Properties.Add(new PSNoteProperty("Index", i));
                        deviceObject.Properties.Add(new PSNoteProperty("Name", deviceInfo.ProductName));
                        deviceObject.Properties.Add(new PSNoteProperty("Guid", deviceInfo.ProductGuid));
                        deviceObject.Properties.Add(new PSNoteProperty("Channels", deviceInfo.Channels));
                        deviceObject.Properties.Add(new PSNoteProperty("Type", "Microphone"));
                        deviceObject.Properties.Add(new PSNoteProperty("WildcardPattern", $"*{deviceInfo.ProductName}*"));

                        // Output the detailed device object
                        WriteObject(deviceObject);
                    }
                    else
                    {
                        // Output just the device name
                        WriteObject(deviceInfo.ProductName);
                    }
                }
                catch (Exception ex)
                {
                    // Log verbose message for devices that cannot be enumerated
                    WriteVerbose($"Could not enumerate device {i}: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// Enumerates and lists available desktop audio capture devices
        /// </summary>
        private void ListDesktopAudioDevices()
        {
            // Inform the user that desktop audio device enumeration is starting
            WriteVerbose("Enumerating desktop audio capture devices...");

            try
            {
                // Create device enumerator for audio endpoints
                using var deviceEnumerator = new MMDeviceEnumerator();

                // Get active render devices (speakers/headphones for capture)
                var devices = deviceEnumerator.EnumerateAudioEndPoints(DataFlow.Render, DeviceState.Active);

                // Initialize index counter for device numbering
                int index = 0;

                // Loop through each active device
                foreach (var device in devices)
                {
                    try
                    {
                        // Check if detailed objects should be returned
                        if (Passthru.ToBool())
                        {
                            // Create a PowerShell object with detailed device information
                            var deviceObject = new PSObject();
                            deviceObject.Properties.Add(new PSNoteProperty("Index", index));
                            deviceObject.Properties.Add(new PSNoteProperty("Name", device.FriendlyName));
                            deviceObject.Properties.Add(new PSNoteProperty("Id", device.ID));
                            deviceObject.Properties.Add(new PSNoteProperty("State", device.State.ToString()));
                            deviceObject.Properties.Add(new PSNoteProperty("Type", "DesktopAudio"));
                            deviceObject.Properties.Add(new PSNoteProperty("WildcardPattern", $"*{device.FriendlyName}*"));

                            // Output the detailed device object
                            WriteObject(deviceObject);
                        }
                        else
                        {
                            // Output just the device name
                            WriteObject(device.FriendlyName);
                        }

                        // Increment the index for the next device
                        index++;
                    }
                    catch (Exception ex)
                    {
                        // Log verbose message for devices that cannot be processed
                        WriteVerbose($"Could not get details for device {device?.ID}: {ex.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle enumeration failure and provide fallback
                WriteWarning($"Desktop audio device enumeration failed: {ex.Message}");
                WriteWarning("Desktop audio device selection by name is not supported in this NAudio version.");

                // Check if detailed objects should be returned
                if (Passthru.ToBool())
                {
                    // Create a default device object as fallback
                    var defaultDevice = new PSObject();
                    defaultDevice.Properties.Add(new PSNoteProperty("Index", 0));
                    defaultDevice.Properties.Add(new PSNoteProperty("Name", "Default Desktop Audio"));
                    defaultDevice.Properties.Add(new PSNoteProperty("Id", "default"));
                    defaultDevice.Properties.Add(new PSNoteProperty("State", "Available"));
                    defaultDevice.Properties.Add(new PSNoteProperty("Type", "DesktopAudio"));
                    defaultDevice.Properties.Add(new PSNoteProperty("WildcardPattern", "*default*"));

                    // Output the default device object
                    WriteObject(defaultDevice);
                }
                else
                {
                    // Output the default device name
                    WriteObject("Default Desktop Audio");
                }
            }
        }
    }
}