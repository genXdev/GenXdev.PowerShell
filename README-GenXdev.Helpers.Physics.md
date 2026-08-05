# GenXdev.Helpers.Physics

## Overview

GenXdev.Helpers.Physics is a physics calculation library in PowerShell. It
covers kinematics, forces, energy, waves, optics, gravitation, and fluid
dynamics — over 25 specialized calculation functions plus a general-purpose
unit converter. I added this for analyzing events seen in online videos,
don't use it for production grade calculations, I am not qualified to check
them for scientific accuracy ;-)

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Convert-PhysicsUnit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-PhysicsUnit.md) | — | Convert values between physics units within the same category |
| [Get-KineticEnergyByMassAndVelocity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KineticEnergyByMassAndVelocity.md) | — | Calculate kinetic energy (½mv²) |
| [Get-PotentialEnergyByMassHeightAndGravity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PotentialEnergyByMassHeightAndGravity.md) | — | Calculate gravitational potential energy (mgh) |
| [Get-MomentumByMassAndVelocity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MomentumByMassAndVelocity.md) | — | Calculate linear momentum (mv) |
| [Get-CentripetalAccelerationByVelocityAndRadius](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CentripetalAccelerationByVelocityAndRadius.md) | — | Calculate centripetal acceleration (v²/r) |
| [Get-ImpactVelocityByHeightAndGravity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImpactVelocityByHeightAndGravity.md) | — | Calculate velocity at impact from a given height |
| [Get-FreeFallTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-FreeFallTime.md) | — | Calculate time to fall a given distance |
| [Get-TerminalVelocityByMassGravityDensityAndArea](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TerminalVelocityByMassGravityDensityAndArea.md) | — | Calculate terminal velocity |
| [Get-ProjectileRangeByInitialSpeedAndAngle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ProjectileRangeByInitialSpeedAndAngle.md) | — | Calculate projectile range |
| [Get-EscapeVelocityByMassAndRadius](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-EscapeVelocityByMassAndRadius.md) | — | Calculate escape velocity for a celestial body |
| [Get-OrbitalVelocityByRadiusAndMass](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-OrbitalVelocityByRadiusAndMass.md) | — | Calculate orbital velocity |
| [Get-WaveSpeedByFrequencyAndWavelength](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WaveSpeedByFrequencyAndWavelength.md) | — | Calculate wave speed (v = fλ) |
| [Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed.md) | — | Calculate Doppler-shifted frequency |
| [Get-RefractionAngleByIncidentAngleAndIndices](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefractionAngleByIncidentAngleAndIndices.md) | — | Calculate refraction angle via Snell's law |

## How It All Comes Together

Physics is a self-contained calculation toolkit. Each `Get-*` cmdlet takes
the physical quantities as parameters and returns the calculated result with
proper units. `Convert-PhysicsUnit` ties them together as the universal
converter — it handles length, mass, time, temperature, velocity, force,
energy, pressure, and more, all within a single cmdlet that resolves the
conversion category from the unit names.

The cmdlets are designed for pipeline use: calculate a value, then feed it
into the next calculation. For example, get the orbital velocity of a
satellite, convert the result to km/s, or calculate escape velocity and
compare it to the orbital velocity at that radius.

## See Also

- [GenXdev.Helpers](README-GenXdev.Helpers.md) — Core utility functions
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevhelpersphysics)
