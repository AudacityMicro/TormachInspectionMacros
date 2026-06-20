# Changelog

All notable changes to this project are documented here. The project has not
yet published a versioned release.

## Unreleased

### Added

- Fusion-compatible inspection result headers, transforms, toolpath records,
  feature numbering, and `START`/`END` framing.
- Initialization of inspection global variables at program start.
- Static program-end and table-washdown PathPilot subroutines.
- Configurable G53 unload and washdown positions, washdown passes, feed, spindle
  speed, cleaning medium, cleaning tool, and independent final tool.
- Optional `M199` timestamped result archiving with collision handling and
  incomplete-report validation.
- Post option to run without `M199` while retaining the latest `RESULTS.TXT`.
- Spatial program-end properties with explicit inch/millimeter conversion and
  active-unit handling for bare numeric values.
- Beginner installation, configuration, operation, import, and troubleshooting
  documentation.
- Automated static macro validation and `M199` integration tests.

### Fixed

- Absolute versus incremental probe-target errors in circular and three-point
  routines.
- Off-origin three-point feature targeting and safe returns.
- Circular-boss X-center averaging.
- Fusion result formatting and component/feature numbering.
- Program-end ordering so cleaning precedes the final tool and unload position.
- Cleaning-cycle guards for T0, T99, and T1000.
- A malformed three-point-boss diagnostic parameter and stray subroutine `M02`
  statements found during release audit.

### Safety

- Program end retracts with `G53 G0 Z0` before tool changes or XY motion.
- Cleaning and unload coordinates are explicitly passed as G53 machine
  coordinates.
- Washdown is disabled by default and can run with no coolant output.
