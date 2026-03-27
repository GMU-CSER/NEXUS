# MEGANv2.1 Biogenic Emissions

This module implements the Model of Emissions of Gases and Aerosols from Nature (MEGAN) version 2.1 in a column-based framework.

## Implementation Details

The implementation provides a modular approach to calculating biogenic VOC emissions, following the algorithms described in Guenther et al. (2012).

### Activity Factors
The model calculates emissions by applying several activity factors to a base emission factor (AEF):
- **Gamma T**: Temperature activity factor.
- **Gamma P**: Light (PPFD) activity factor.
- **Gamma LAI**: Leaf Area Index activity factor.
- **Gamma Age**: Leaf age activity factor.
- **Gamma SM**: Soil moisture activity factor.

### Column Interface
The MEGAN process implements the `run_column` interface, allowing it to be called for individual atmospheric columns. It retrieves meteorological data (TS, SWGDN, LAI) from the `VirtualMetType` container.

## Usage
The process is initialized via the high-level API and can be configured through the nexus-toolbox configuration system.
