# Nexus Toolbox

The Nexus Toolbox is a modular infrastructure for atmospheric chemistry process-level implementations. It provides a standardized framework for column-based processing, specifically designed for coupling with NOAA's UFS/CAT-Chem.

## Features

- **Standardized Interfaces**: Follows Fortran Scientific Module Standards (FSMS-2026).
- **Column Virtualization**: Efficient processing of individual atmospheric columns.
- **Process Generator**: Automated generation of process stubs and boilerplate code.
- **UFS Integration**: Pre-built NUOPC/ESMF hooks for seamless coupling.

## Directory Structure

- `src/api`: High-level API and NUOPC caps.
- `src/core`: Base modules and abstract interfaces.
- `src/external`: Support for external libraries.
- `src/process`: Implementation of physical and chemical processes (e.g., MEGANv2.1).
- `tools/process_generator`: Tooling for rapid process development.

## Documentation

- [Testing Standards](testing_standards.md)
- [MEGANv2.1 Implementation Details](processes/megan.md)
