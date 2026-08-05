# Get-ResonantFrequencyByLengthAndSpeed

> **SubModule:** GenXdev.Helpers.Physics | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Calculates resonant frequency for a closed pipe.

## Description

Uses f = v / (4 L) for fundamental frequency.


## Syntax

```powershell
Get-ResonantFrequencyByLengthAndSpeed -LengthInMeters <Double> [[-As] <String>] [<CommonParameters>]

Get-ResonantFrequencyByLengthAndSpeed -SpeedInMetersPerSecond <Double> [<CommonParameters>]

Get-ResonantFrequencyByLengthAndSpeed -Medium <String> [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-LengthInMeters` | Double | ✅ | Length in meters |
| `-SpeedInMetersPerSecond` | Double | ✅ | Wave speed in m/s |
| `-Medium` | String | ✅ | The medium |
| `-As` | String | ☐ | Output unit for frequency |

## Examples

### Examples 1

```powershell
Get-ResonantFrequencyByLengthAndSpeed -LengthInMeters 0.5 -Medium "air" -As "kilohertz"
```

Calculates the resonant frequency for a 0.5 meter pipe in air, output in kilohertz.

### Examples 2

```powershell
Get-ResonantFrequencyByLengthAndSpeed 1 -SpeedInMetersPerSecond 343
```

Calculates the resonant frequency for a 1 meter pipe with wave speed 343 m/s.

## Parameter Details

### `-LengthInMeters <Double>`

> Length in meters

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SpeedInMetersPerSecond <Double>`

> Wave speed in m/s

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | BySpeed |

<hr/>

### `-Medium <String>`

> The medium

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | ByMedium |

<hr/>

### `-As <String>`

> Output unit for frequency

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Convert-PhysicsUnit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-PhysicsUnit.md)
- [Get-ApparentSizeAtArmLength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ApparentSizeAtArmLength.md)
- [Get-AtEyeLengthSizeInMM](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AtEyeLengthSizeInMM.md)
- [Get-BuoyantForceByDisplacedVolumeAndDensity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BuoyantForceByDisplacedVolumeAndDensity.md)
- [Get-CentripetalAccelerationByVelocityAndRadius](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CentripetalAccelerationByVelocityAndRadius.md)
- [Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed.md)
- [Get-DragForceByVelocityDensityAreaAndCoefficient](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DragForceByVelocityDensityAreaAndCoefficient.md)
- [Get-EscapeVelocityByMassAndRadius](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-EscapeVelocityByMassAndRadius.md)
- [Get-FreeFallDistance](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallDistance.md)
- [Get-FreeFallHeight](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallHeight.md)
- [Get-FreeFallTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallTime.md)
- [Get-ImpactVelocityByHeightAndGravity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImpactVelocityByHeightAndGravity.md)
- [Get-KineticEnergyByMassAndVelocity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KineticEnergyByMassAndVelocity.md)
- [Get-LightTravelTimeByDistance](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-LightTravelTimeByDistance.md)
- [Get-MagnificationByObjectDistanceAndImageDistance](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MagnificationByObjectDistanceAndImageDistance.md)
- [Get-MomentumByMassAndVelocity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MomentumByMassAndVelocity.md)
- [Get-OrbitalVelocityByRadiusAndMass](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-OrbitalVelocityByRadiusAndMass.md)
- [Get-PotentialEnergyByMassHeightAndGravity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PotentialEnergyByMassHeightAndGravity.md)
- [Get-ProjectileRangeByInitialSpeedAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ProjectileRangeByInitialSpeedAndAngle.md)
- [Get-RefractionAngleByIncidentAngleAndIndices](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefractionAngleByIncidentAngleAndIndices.md)
- [Get-SoundTravelDistanceByTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SoundTravelDistanceByTime.md)
- [Get-TerminalVelocityByMassGravityDensityAndArea](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TerminalVelocityByMassGravityDensityAndArea.md)
- [Get-TimeOfFlightByInitialVelocityAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TimeOfFlightByInitialVelocityAndAngle.md)
- [Get-WaveSpeedByFrequencyAndWavelength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WaveSpeedByFrequencyAndWavelength.md)
