# Nexus Toolbox Testing Standards

To ensure the reliability and interoperability of atmospheric chemistry processes in the Nexus Toolbox, all new processes and schemes must adhere to the following testing standards.

## Requirements for New Processes

Each new process implementation must include:

1.  **Unit Tests**:
    - Every physical/chemical scheme must have at least one unit test.
    - Tests should be located in `nexus-toolbox/tests/process/<category>/<scheme_name>/`.
    - Tests must cover:
        - Successful initialization.
        - Execution on a single virtual column.
        - Verification of non-zero output for reasonable inputs.
        - Edge cases (e.g., night-time for photolytic processes).

2.  **Compatibility with `ColumnProcessInterface`**:
    - The scheme must be tested through the `run_column` method.
    - All meteorological dependencies must be accessed via the `VirtualMetType` pointer.

3.  **CI Integration**:
    - Tests must be added to the CMake build system using `add_test`.
    - All tests must pass on supported platforms (Intel/GNU compilers).

## Best Practices

- **Zero-Copy Verification**: Ensure that pointers to meteorological data are correctly associated and not copied into local arrays within the process logic.
- **Precision Agnostic**: Use the `fp` kind parameter from `precision_mod` to ensure tests work in both single and double precision builds.
- **Standardized Error Handling**: Use `CC_SUCCESS` and `CC_FAILURE` from `error_mod` for return codes.

## Future Plans

We aim to integrate automated regression testing and validation against reference model outputs (e.g., GEOS-Chem/HEMCO) to ensure scientific accuracy.
