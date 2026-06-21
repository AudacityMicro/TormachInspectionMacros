# Changelog

All notable changes to this project are documented here. The project has not
yet published a versioned release.

## Unreleased

### Added

- M199 invocation and successful-archive diagnostics in
  `results/archive-events.log`.
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
- Tool breakage selection for every non-probe tool or a comma-separated tool
  list, while preserving Fusion's existing per-tool Break Control selection.
- Optional suppression of Fusion tool-library Break Control flags when breakage
  selection must be controlled entirely by post settings.
- An overriding comma-separated ignore list that excludes selected tools from
  every automatic break-detection source.
- Optional `G53 G0 Z0` retract immediately before G37 tool break detection for
  machines with electronic tool setter line-of-sight limitations.
- Final-tool break detection at normal program completion.

### Fixed

- Resolve the M199 report path from the PathPilot gcode directory instead of
  the user M-code process working directory.
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
