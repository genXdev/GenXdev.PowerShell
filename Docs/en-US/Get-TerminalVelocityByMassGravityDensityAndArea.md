# Get-TerminalVelocityByMassGravityDensityAndArea

> **SubModule:** GenXdev.Helpers.Physics | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Calculates terminal velocity.

## Description

Uses v = sqrt(2 m g / (ρ A C)).


## Syntax

```powershell
Get-TerminalVelocityByMassGravityDensityAndArea -MassInKilograms <Double> [[-GravityInMetersPerSecondSquared] <Double>] -DensityInKilogramsPerCubicMeter <Double> -AreaInSquareMeters <Double> [[-DragCoefficient] <Double>] [[-As] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-MassInKilograms` | Double | ✅ | Mass in kg |
| `-GravityInMetersPerSecondSquared` | Double | ☐ | Gravity in m/s² (default: 9.81) |
| `-DensityInKilogramsPerCubicMeter` | Double | ✅ | Fluid density in kg/m³ |
| `-AreaInSquareMeters` | Double | ✅ | Cross-sectional area in m² |
| `-DragCoefficient` | Double | ☐ | Drag coefficient (default: 0.5) |
| `-As` | String | ☐ | Output unit for velocity |

## Examples

### Examples 1

```powershell
Get-TerminalVelocityByMassGravityDensityAndArea -MassInKilograms 80 -DensityInKilogramsPerCubicMeter 1.225 -AreaInSquareMeters 0.7 -DragCoefficient 1.0 -As "mph"
```

Calculates the terminal velocity for a mass of 80 kg in air with a drag coefficient of 1.0, outputting the result in mph.

### Examples 2

```powershell
Get-TerminalVelocityByMassGravityDensityAndArea 70 1.225 0.8 0.8
```

Uses positional parameters to calculate terminal velocity.

## Parameter Details

### `-MassInKilograms <Double>`

> Mass in kg

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-GravityInMetersPerSecondSquared <Double>`

> Gravity in m/s² (default: 9.81)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DensityInKilogramsPerCubicMeter <Double>`

> Fluid density in kg/m³

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 2 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AreaInSquareMeters <Double>`

> Cross-sectional area in m²

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 3 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DragCoefficient <Double>`

> Drag coefficient (default: 0.5)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-As <String>`

> Output unit for velocity

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 5 |
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
- [Get-ResonantFrequencyByLengthAndSpeed](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ResonantFrequencyByLengthAndSpeed.md)
- [Get-SoundTravelDistanceByTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SoundTravelDistanceByTime.md)
- [Get-TimeOfFlightByInitialVelocityAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TimeOfFlightByInitialVelocityAndAngle.md)
- [Get-WaveSpeedByFrequencyAndWavelength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WaveSpeedByFrequencyAndWavelength.md)
