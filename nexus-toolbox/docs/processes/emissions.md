# Emissions Point Sources and Plume Rise

The Nexus Toolbox includes support for processing point source emissions and calculating their vertical distribution via plume rise.

## Point Sources

Point sources are managed as a batch of coordinates and emission rates. These are represented using the `ESMF_LocStream` class, which allows for efficient mapping from irregular points to the model grid.

### Features
- **ESMF LocStream Integration**: Leverages ESMF for spatial representation of non-contiguous data points.
- **Gridded Transfer**: Provides hooks for regridding point-based emissions back to the Eulerian grid structure.

## Plume Rise (Briggs 1969)

The plume rise module implements the standard Briggs (1969) scheme for calculating the effective height of stack emissions based on buoyancy and momentum.

### Briggs 1969 Formulation
The module considers:
- **Buoyancy Flux**: Driven by the temperature difference between stack gas and ambient air.
- **Atmospheric Stability**: Different formulations for stable, neutral, and unstable conditions.
- **Wind Speed Effects**: Accounts for bent-over plumes in crosswinds.

### Usage
```fortran
use briggs_plume_rise_mod
...
call calculate_plume_rise_briggs(stack_height, stack_diameter, exit_velocity, &
   exit_temp, ambient_temp, wind_speed, stability_param, is_stable, plume_rise)
```
