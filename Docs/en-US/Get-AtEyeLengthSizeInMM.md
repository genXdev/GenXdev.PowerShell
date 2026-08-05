# Get-AtEyeLengthSizeInMM

> **SubModule:** GenXdev.Helpers.Physics | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Calculates the apparent size in mm of an object at arm's length.

## Description

Computes the size an object would appear to be if viewed at average adult arm's length (approximately 0.7 meters), given its actual size and distance. The calculation uses the small angle approximation for angular size.


## Syntax

```powershell
Get-AtEyeLengthSizeInMM -DistanceInMeters <Double> -SizeInMeters <Double> [-EyeToArmLengthInMeters <Double>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-DistanceInMeters` | Double | ✅ | The distance to the object in meters. |
| `-SizeInMeters` | Double | ✅ | The actual size of the object in meters. |
| `-EyeToArmLengthInMeters` | Double | ☐ | The arm's length distance in meters. Default<br>value is 0.7. |

## Examples

### Examples 1

```powershell
Get-AtEyeLengthSizeInMM -DistanceInMeters 10 -SizeInMeters 1
```

Calculates the apparent size at arm's length for an object 1 meter in size at 10 meters distance.

## Parameter Details

### `-DistanceInMeters <Double>`

> The distance to the object in meters.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SizeInMeters <Double>`

> The actual size of the object in meters.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EyeToArmLengthInMeters <Double>`

> The arm's length distance in meters. Default value is 0.7.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Convert-PhysicsUnit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-PhysicsUnit.md)
- [Get-ApparentSizeAtArmLength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ApparentSizeAtArmLength.md)
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
- [Get-ResonantFrequencyByLengthAndSpeed](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ResonantFrequencyByLengthAndSpeed.md)
- [Get-SoundTravelDistanceByTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SoundTravelDistanceByTime.md)
- [Get-TerminalVelocityByMassGravityDensityAndArea](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TerminalVelocityByMassGravityDensityAndArea.md)
- [Get-TimeOfFlightByInitialVelocityAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TimeOfFlightByInitialVelocityAndAngle.md)
- [Get-WaveSpeedByFrequencyAndWavelength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WaveSpeedByFrequencyAndWavelength.md)
