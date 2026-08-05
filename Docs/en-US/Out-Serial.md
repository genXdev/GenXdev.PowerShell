# Out-Serial

> **SubModule:** GenXdev.Hardware | **Type:** Function | **Aliases:** —

## Synopsis

> Sends a string to a serial port

## Description

Allows you to send a string to a serial communication port


## Syntax

```powershell
Out-Serial [[-Portname] <String>] [[-BaudRate] <Int32>] [[-MaxBytesToRead] <UInt32>] [[-ReadTimeout] <UInt32>] [[-WriteTimeout] <UInt32>] [[-Parity] <String>] [[-DataBits] <Int32>] [[-StopBits] <String>] -Text <Object> [-AddCRLinefeeds] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Portname` | String | ☐ | The port to use (for example, COM1). |
| `-BaudRate` | Int32 | ☐ | The baud rate. |
| `-MaxBytesToRead` | UInt32 | ☐ | Limits the nr of bytes to read. |
| `-ReadTimeout` | UInt32 | ☐ | Enables reading with a specified timeout in<br>milliseconds. |
| `-WriteTimeout` | UInt32 | ☐ | Enables writing with a specified timeout in<br>milliseconds. |
| `-Parity` | String | ☐ | One of the System.IO.Ports.SerialPort.Parity<br>values. |
| `-DataBits` | Int32 | ☐ | The data bits value. |
| `-StopBits` | String | ☐ | One of the<br>System.IO.Ports.SerialPort.StopBits values. |
| `-Text` | Object | ✅ | Text to sent to serial port. |
| `-AddCRLinefeeds` | SwitchParameter | ☐ | Add linefeeds to input text parts. |

## Parameter Details

### `-Portname <String>`

> The port to use (for example, COM1).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `'COM5'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-BaudRate <Int32>`

> The baud rate.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `9600` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxBytesToRead <UInt32>`

> Limits the nr of bytes to read.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReadTimeout <UInt32>`

> Enables reading with a specified timeout in milliseconds.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WriteTimeout <UInt32>`

> Enables writing with a specified timeout in milliseconds.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Parity <String>`

> One of the System.IO.Ports.SerialPort.Parity values.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 5 |
| **Default value** | `'None'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DataBits <Int32>`

> The data bits value.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 6 |
| **Default value** | `8` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-StopBits <String>`

> One of the System.IO.Ports.SerialPort.StopBits values.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 7 |
| **Default value** | `'One'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Text <Object>`

> Text to sent to serial port.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 8 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AddCRLinefeeds`

> Add linefeeds to input text parts.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$false` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md)
- [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md)
- [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md)
- [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md)
- [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md)
- [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md)
