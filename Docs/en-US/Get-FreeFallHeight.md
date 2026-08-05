# Get-FreeFallHeight

> **SubModule:** GenXdev.Helpers.Physics | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Calculates the height fallen during free fall for a given time duration.

## Description

Calculates the distance fallen during free fall using a numerical method that accounts for air resistance and terminal velocity.


## Syntax

```powershell
Get-FreeFallHeight -DurationInSeconds <Double> [[-TerminalVelocityInMs] <Double>] [[-As] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-DurationInSeconds` | Double | ✅ | The time duration of the fall in seconds |
| `-TerminalVelocityInMs` | Double | ☐ | The terminal velocity in meters per second<br>(default: 53 m/s for human) |
| `-As` | String | ☐ | The unit for the output height |

## Examples

### Examples 1

```powershell
Get-FreeFallHeight -DurationInSeconds 10 -TerminalVelocityInMs 53
```

Calculates the height fallen in 10 seconds with default human terminal velocity.

### Examples 2

```powershell
Get-FreeFallHeight 5
```

Calculates the height fallen in 5 seconds using positional parameter and default terminal velocity.

### Examples 3

```powershell
Get-FreeFallHeight -DurationInSeconds 10 -As "feet"
```

Calculates the height fallen in 10 seconds and returns the result in feet.

## Parameter Details

### `-DurationInSeconds <Double>`

> The time duration of the fall in seconds

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TerminalVelocityInMs <Double>`

> The terminal velocity in meters per second (default: 53 m/s for human)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-As <String>`

> The unit for the output height

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
