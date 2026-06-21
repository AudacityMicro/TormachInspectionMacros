# Machine Test Checklist

Use this checklist for the exact commit proposed for release. Testing probing
motion on a different commit does not validate the release candidate.

## Test record

| Field | Value |
| --- | --- |
| Commit SHA | |
| Fusion version | |
| Autodesk post engine version | |
| PathPilot version | |
| Tormach model and serial | |
| Probe model and stylus diameter | |
| Probe tool and length offset | T99 / H99 |
| Inch test program | |
| Metric test program | |
| Operator | |
| Reviewer | |
| Date | |

## Preconditions

- [ ] Machine is homed and axis limits are known.
- [ ] Probe is calibrated and the effective stylus diameter matches Fusion.
- [ ] Probe input changes state correctly before motion testing.
- [ ] T99 and H99 are correct in the PathPilot tool table.
- [ ] Test features are measured independently with calibrated equipment.
- [ ] Initial runs use Single Block, reduced feed, and immediate access to Feed
  Hold and E-stop.
- [ ] Washdown remains disabled during probe-cycle validation.
- [ ] M199 archiving remains disabled until probe motion is validated.

## Probe-cycle matrix

For each row, verify rough touch, retract, fine touch, safe return, measured
value, Fusion import, WCS update, and WCS-suppressed behavior. Repeat in inch and
metric output. Use at least one feature whose center is not X0 Y0.

| Cycle | Inch | Metric | Off-origin | Directions | Results import | WCS modes | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Probe X edge | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Probe Y edge | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Probe Z surface | [ ] | [ ] | [ ] | N/A | [ ] | [ ] | |
| X wall / boss | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Y wall / boss | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| X channel / pocket | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Y channel / pocket | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| X channel with island | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Y channel with island | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Circular bore | [ ] | [ ] | [ ] | 4-axis | [ ] | [ ] | |
| Circular bore with island | [ ] | [ ] | [ ] | 4-axis | [ ] | [ ] | |
| Three-point partial bore | [ ] | [ ] | [ ] | 3 vectors | [ ] | [ ] | |
| Circular boss | [ ] | [ ] | [ ] | 4-axis | [ ] | [ ] | |
| Three-point partial boss | [ ] | [ ] | [ ] | 3 vectors | [ ] | [ ] | |
| Rectangular hole | [ ] | [ ] | [ ] | X and Y | [ ] | [ ] | |
| Rectangular hole with island | [ ] | [ ] | [ ] | X and Y | [ ] | [ ] | |
| Rectangular boss | [ ] | [ ] | [ ] | X and Y | [ ] | [ ] | |
| XY inner corner | [ ] | [ ] | [ ] | X and Y | [ ] | [ ] | |
| XY outer corner | [ ] | [ ] | [ ] | X and Y | [ ] | [ ] | |

## Result behavior

- [ ] First recorded result overwrites and begins a new `RESULTS.TXT`.
- [ ] File begins with `START` and ends with `END` after normal completion.
- [ ] Toolpath IDs and names match the Fusion inspection operations.
- [ ] Features increment within a component.
- [ ] Components increment only when configured in Fusion.
- [ ] Circular, rectangular, edge, corner, and Z records import into Fusion.
- [ ] An aborted program leaves an incomplete report that Fusion does not treat
  as a completed run.

## Program-end behavior

- [ ] Z retracts to `G53 G0 Z0` before any XY movement.
- [ ] Washdown disabled moves directly to the configured unload position.
- [ ] Cleaning tool change disabled uses the loaded normal tool when permitted.
- [ ] Cleaning tool change enabled loads the configured tool.
- [ ] Already-loaded cleaning tool does not cause an unnecessary tool change.
- [ ] Loaded T0, T99, and T1000 each skip washdown with a warning.
- [ ] Washdown X/Y/Z envelope clears fixtures and respects machine limits.
- [ ] Pass count and Y spacing match the post settings.
- [ ] Feed matches the inch and metric post settings.
- [ ] No-output cleaning mode produces no coolant or air command.
- [ ] Flood, through-spindle, and airblast modes are tested if supported.
- [ ] Cleaning RPM zero leaves the spindle stopped.
- [ ] Nonzero cleaning RPM starts and stops the spindle as expected.
- [ ] Independent final tool change disabled leaves the cleaning/current tool.
- [ ] Independent final tool change enabled loads the configured final tool.
- [ ] Final G53 unload X/Y occurs after cleaning and final tool change.

## M199 archive behavior

- [ ] Archive-disabled post runs successfully with no M199 file installed.
- [ ] New M199 is recognized after restarting PathPilot.
- [ ] Complete report is copied to `~/gcode/results`.
- [ ] `RESULTS.TXT` remains byte-identical to the archived copy.
- [ ] Archive filename uses `RESULTSFILE` and machine timestamp.
- [ ] Same-second filename collision receives a numeric suffix.
- [ ] Missing, incomplete, and malformed reports produce warnings without
  preventing M30.
- [ ] Archive failures appear in `results/archive-errors.log`.

## Tool breakage detection

- [ ] With all new settings disabled, Fusion's per-tool Break Control selection
  still emits one G37 check.
- [ ] Ignore Fusion tool library break detection flag suppresses a Fusion
  Break Control selection when neither post selection includes that tool.
- [ ] Every-tool and tool-list selections still work while Fusion flags are
  ignored.
- [ ] Ignore list of tools overrides Fusion Break Control, Check every tool,
  and Check list of tools individually and when they are enabled together.
- [ ] Spaces and duplicate entries in the ignore list are handled correctly.
- [ ] Invalid ignore-list entries stop posting with a clear error.
- [ ] Check every tool emits one G37 check after each non-probe tool's final
  operation.
- [ ] Check list of tools accepts comma-separated values with optional spaces.
- [ ] Only used tools selected by the list receive G37 checks.
- [ ] Duplicate list entries do not produce duplicate checks.
- [ ] Invalid, empty-between-commas, zero, negative, and over-limit entries stop
  posting with a clear error.
- [ ] Probe-type tools do not receive automatic or list-selected G37 checks.
- [ ] A selected final tool receives a G37 check before normal program end.
- [ ] Fully retract disabled preserves the normal PathPilot G37 approach.
- [ ] Fully retract enabled outputs spindle/coolant off and `G53 G0 Z0`
  immediately before G37.
- [ ] G53 Z0 clears the spindle from the ETS line of sight on the target machine.
- [ ] Tool breakage tolerance is correct in inch and metric programs.
- [ ] A passing tool resumes the next tool or program-end sequence correctly.
- [ ] A failed tool produces the expected PathPilot alarm and prevents further
  machining.

## Approval

- [ ] All required rows and checks are complete.
- [ ] Deviations are documented and accepted.
- [ ] Operator approves release: ____________________  Date: __________
- [ ] Reviewer approves release: ____________________  Date: __________
