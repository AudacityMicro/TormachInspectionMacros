# Tormach Inspection Macros

This package adds Fusion inspection-result logging to the Tormach PathPilot
probing cycles. It also provides a configurable program-end routine for safe Z
retraction, optional table washdown, optional tool changes, an unload position,
and optional timestamped result archiving.

## Pre-release status

This project is currently intended for controlled development testing. Static
validation passes, but the complete physical-machine matrix has not been signed
off. See [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) for the current release
decision and [MACHINE_TEST_CHECKLIST.md](MACHINE_TEST_CHECKLIST.md) for the
required PathPilot tests.
Remaining release work is tracked in [GitHub issue #1](https://github.com/AudacityMicro/TormachInspectionMacros/issues/1).

Development to date has used PathPilot 2.14.3 and Autodesk post engine 5.370.5.
Those versions are audit context, not a final supported-version guarantee.

## Project documentation

| Document | Purpose |
| --- | --- |
| [README.md](README.md) | Installation, configuration, operation, and troubleshooting. |
| [CHANGELOG.md](CHANGELOG.md) | Notable project changes. |
| [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) | Current readiness decision, blockers, and release procedure. |
| [MACHINE_TEST_CHECKLIST.md](MACHINE_TEST_CHECKLIST.md) | Physical machine test matrix and approval record. |

The post always creates a Fusion-compatible `RESULTS.TXT` when at least one
Fusion probe operation has **Print Results** enabled. The optional `M199` helper
copies each completed report into a timestamped archive so the next run cannot
overwrite the only copy.

> **Machine safety:** These files command real probe, tool-change, spindle,
> coolant, and G53 machine-coordinate motion. Review every generated program,
> verify all G53 positions against the specific machine, and perform the first
> test in Single Block at reduced feed with a hand on Feed Hold and E-stop.

## Contents

| File | Purpose | Install location |
| --- | --- | --- |
| `Tormach_Inspection.cps` | Fusion post processor | Fusion Post Library |
| `initialize_inspection.nc` | Initializes global variables at program start | `~/gcode/subroutines` |
| `probe_*.nc` | Probe motion, measurement, WCS, and result routines | `~/gcode/subroutines` |
| `inspection_program_end.nc` | Safe retract, cleaning, final tool, unload, and archive sequence | `~/gcode/subroutines` |
| `inspection_washdown.nc` | Configurable G53 table-washdown raster | `~/gcode/subroutines` |
| `M199` | Optional timestamped result archive helper | `~/gcode/M199` |
| `Target Format.txt` | Reference example of Fusion result-file formatting | Do not install |
| `scripts/validate_repository.py` | Static repository and macro validation | Development only |
| `tests/test_m199.sh` | Archive-helper integration tests | Development only |

On PathPilot, `~` means `/home/operator`. The PathPilot network share normally
appears in Windows as `\\Tormach\gcode`. If it is mapped as drive `Z:`, then:

| PathPilot path | Windows path |
| --- | --- |
| `/home/operator/gcode` | `Z:\` |
| `/home/operator/gcode/subroutines` | `Z:\subroutines` |
| `/home/operator/gcode/results` | `Z:\results` |

## Requirements

- A Tormach mill running PathPilot.
- A calibrated probe configured as tool 99 with length offset 99. The post
  rejects other probe tool numbers unless its testing-only override is enabled.
- Fusion with access to the Manufacture workspace and Post Library.
- The computer and PathPilot controller on the same network, or another method
  for transferring files to `~/gcode`.
- Known machine-coordinate limits and verified safe G53 locations for the
  program-end options.

## Choose a Results Mode

Choose the mode before posting the first program.

### Standard logging without M199

Use this mode when terminal access is unavailable or automatic archives are not
needed.

1. Install the post and every `.nc` macro as described below.
2. In the Fusion post properties, open **Program End**.
3. Turn off **Archive inspection results with M199**.
4. Do not install `M199`.

Completed inspection data is written to:

```text
/home/operator/gcode/RESULTS.TXT
```

The next program that records inspection results will overwrite this file.
Import it into Fusion or copy it elsewhere before running the next inspected
part. All probing, WCS, washdown, final-tool, and unload functions still work.

### Timestamped archiving with M199

Use this mode to retain every completed report automatically.

1. Install the post, all `.nc` macros, and `M199`.
2. Confirm `M199` is executable on the PathPilot controller.
3. Restart PathPilot. LinuxCNC discovers newly installed user M-codes during
   startup, so this restart is mandatory even when the file is already correct.
4. Leave **Archive inspection results with M199** enabled in the post.

The helper resolves the report from `$HOME/gcode` rather than its process
working directory. The current report remains at `~/gcode/RESULTS.TXT`, and a
copy is created at:

```text
~/gcode/results/<RESULTSFILE>-YYYYMMDD-HHMMSS.TXT
```

If two archives receive the same name in the same second, `M199` adds a numeric
suffix. An aborted or incomplete report is not archived. Archive warnings are
written to `~/gcode/results/archive-errors.log`; every helper invocation is
recorded in `~/gcode/results/archive-events.log`. An archive failure does not
prevent the machine from completing `M30`.

## Download the Files

1. Open [AudacityMicro/TormachInspectionMacros](https://github.com/AudacityMicro/TormachInspectionMacros).
2. Select **Code**, then **Download ZIP**.
3. Extract the ZIP on the Fusion computer.
4. Keep the extracted folder available until both Fusion and PathPilot
   installation are complete.

Do not rename the post, macros, or `M199`. LinuxCNC subroutine names and user
M-code names are case-sensitive.

## Install the Fusion Post

1. Start Fusion and open the **Manufacture** workspace.
2. Open **Manage > Post Library**.
3. Select the local or personal post library where custom posts are stored.
4. Select **Import** and choose `Tormach_Inspection.cps`.
5. Search the library for **Tormach PathPilot Inspection**.
6. When creating or editing an NC Program, select this post instead of the
   standard Tormach PathPilot post.

If an older copy already exists, replace it. Reopen the Post Process dialog, or
restart Fusion if the new Program End properties do not appear.

## Install the PathPilot Macros

1. Make sure PathPilot is running and the controller is connected to the same
   network as the Windows computer.
2. In Windows File Explorer, open `\\Tormach\gcode`. If the share is already
   mapped, open that drive instead.
3. Open the `subroutines` folder. Create it if it does not exist.
4. Copy every `.nc` file from this package into `subroutines`:

```text
initialize_inspection.nc
inspection_program_end.nc
inspection_washdown.nc
probe_bore_three_point_inspection.nc
probe_boss_three_point_inspection.nc
probe_circular_bore_inspection.nc
probe_circular_boss_inspection.nc
probe_x_boss_inspection.nc
probe_x_edge_inspection.nc
probe_x_pocket_inspection.nc
probe_xy_corner_inspection.nc
probe_y_boss_inspection.nc
probe_y_edge_inspection.nc
probe_y_pocket_inspection.nc
probe_z_inspection.nc
```

5. Replace older copies when prompted.
6. Confirm the files are directly inside `subroutines`, not inside another
   extracted folder.

The post emits `o<initialize_inspection> call` near the beginning of every
program and `o<inspection_program_end> call` at the end. These macros are
required even when the program does not record inspection results and even when
`M199` archiving is disabled.

## Install M199 for Archive Mode

Skip this section when using standard logging without M199.

### Copy the helper

Copy `M199` to the root of the PathPilot gcode share:

```text
Windows:   Z:\M199
PathPilot: /home/operator/gcode/M199
```

It must be named exactly `M199`, with an uppercase `M` and no file extension.
Do not put it in the `subroutines` or `results` folder.

### Confirm permissions and restart

PathPilot must restart after a new user M-code is installed. Before restarting,
confirm the Linux executable permission because Windows SMB copies do not
reliably preserve it.

1. Connect a keyboard to the PathPilot controller.
2. Open a Linux terminal. `Ctrl+Alt+T` opens a terminal on typical PathPilot 2
   systems. If PathPilot hides the desktop, use the PathPilot administrator
   display command or the documented Tormach procedure to expose the desktop.
3. Run:

```bash
chmod 755 /home/operator/gcode/M199
ls -l /home/operator/gcode/M199
```

4. Confirm the `ls` output begins with:

```text
-rwxr-xr-x
```

5. Close the terminal and restart PathPilot or restart the controller. LinuxCNC
   builds its user M-code list during startup.

If the program reports `Unknown m code used: M199` immediately after installing
the file, restart PathPilot first. If the error remains after restart, check the
name, location, and executable permission.

## Configure the Post

The custom controls appear in **Tool Breakage Detection** and **Program End** in
Fusion's Post Process properties.

### Tool Breakage Detection

Open **Tool Breakage Detection** in the Fusion post properties.

| Setting | Default | Meaning |
| --- | --- | --- |
| Check every tool | Off | Run G37 after the final operation for every non-probe tool used by the program. |
| Check list of tools | Blank | Comma-separated tool numbers to check, such as `1, 2, 7`. |
| Ignore Fusion tool library break detection flag | Off | Ignore Fusion's per-tool Break Control setting and use only the post selections. |
| Ignore list of tools | Blank | Comma-separated tools that must not receive automatic G37 checks. Overrides every selection source. |
| Fully retract before starting tool break detection | Off | Stop spindle/coolant and output `G53 G0 Z0` immediately before G37. |
| Tool breakage tolerance | `0.1` | G37 P tolerance in the active program units. |

By default, tool selection is additive. A non-probe tool is checked when any of
these are true:

1. Fusion's existing tool **Break Control** option is enabled.
2. **Check every tool** is enabled.
3. Its tool number appears in **Check list of tools**.

When **Ignore Fusion tool library break detection flag** is enabled, item 1 is
ignored. Only **Check every tool** and **Check list of tools** select tools.

**Ignore list of tools** is evaluated first and overrides every selection
source. A tool in that list is not checked even when Fusion Break Control is
enabled, **Check every tool** is enabled, or the tool also appears in **Check
list of tools**.

Spaces around list entries are accepted and duplicate numbers are ignored. Use
whole tool numbers from 1 through 1000 without a `T` prefix. Invalid entries
stop posting with an error. A listed tool that is not used in the program does
nothing.

Each selected tool is checked once after its last operation, immediately before
the next tool change. The final tool in the program is also checked. Probe-type
tools are excluded from the automatic settings and list to prevent sending the
spindle probe to the electronic tool setter.

When **Fully retract before starting tool break detection** is enabled, the
sequence is:

```text
M5 M9
G53 G0 Z0
G37 P<tolerance>
```

`G53 Z0` is a machine coordinate. Confirm it is the safe fully retracted Z
position on the specific machine before enabling this option. The option is
intended for machines whose spindle blocks the electronic tool setter line of
sight unless Z is fully retracted.

### Result archive setting

| Setting | Default | Meaning |
| --- | --- | --- |
| Archive inspection results with M199 | On | Call `M199` after a complete report is closed. Turn this off if `M199` is not installed. |

The archive call is made only when both this setting and at least one probe
operation's **Print Results** option are enabled.

### Unload and final tool settings

| Setting | Default | Meaning |
| --- | --- | --- |
| End load position X | `4.54in` | Final G53 X machine position. |
| End load position Y | `13.43in` | Final G53 Y machine position. |
| Change tool after cleaning cycle | Off | Enables an independent final tool change after cleaning. |
| Final tool number | `1` | Tool loaded when the final tool change is enabled. |

The end macro always stops spindle and coolant, cancels tool compensation, and
executes `G53 G0 Z0` before any cleaning, tool-change, or XY unload motion. The
final unload move occurs after the cleaning cycle and final tool change.

### Washdown settings

| Setting | Default | Meaning |
| --- | --- | --- |
| Program-end table washdown | Off | Enables the G53 raster cleaning cycle. |
| Change tool for cleaning cycle | Off | Loads the cleaning tool before washdown. |
| Cleaning cycle tool number | `1` | Tool used only for cleaning. Independent of the final tool. |
| Washdown X minimum | `0in` | Raster minimum G53 X. |
| Washdown X maximum | `18in` | Raster maximum G53 X. |
| Washdown Y minimum | `0in` | Raster starting G53 Y. |
| Washdown Y maximum | `12in` | Raster ending G53 Y. |
| Washdown Z height | `0in` | G53 Z used during raster motion. |
| Washdown passes | `4` | Number of alternating X traverses. |
| Washdown feed rate | `50in` | Raster feed in distance per minute. |
| Cleaning cycle RPM | `0` | Spindle RPM during washdown; zero keeps it stopped. |
| Cleaning cycle coolant | Coolant | None, flood coolant, through-spindle coolant, or airblast. |

All X, Y, and Z washdown positions are **G53 machine coordinates**, not work
coordinates. The washdown sequence is:

1. Retract to `G53 G0 Z0`.
2. Optionally load the cleaning tool.
3. Move at Z0 to the configured X minimum and Y minimum.
4. Move to the configured washdown Z.
5. Start the selected spindle/coolant mode.
6. Traverse X back and forth while stepping Y across the configured range.
7. Stop coolant and spindle, then retract to `G53 G0 Z0`.
8. Optionally load the independent final tool.
9. Move to the configured unload X and Y.
10. Optionally archive results with `M199`.

The washdown is skipped with a warning if T0, T99, or T1000 is selected or
loaded. This prevents a cleaning raster with no tool, the probe, or the reserved
T1000 tool. Select a normal cleaning tool number if washdown is required.

### Entering inch and metric values

Spatial Program End properties accept either an explicit unit suffix or a bare
number:

```text
4.54in
115.316mm
```

An explicit suffix is recommended because it remains unambiguous if the Fusion
program changes between inch and metric output. The post converts suffixed
values to the active program units. A bare value is interpreted directly in the
active program units. For feed, `50in` means 50 inches per minute and `1270mm`
means 1270 millimeters per minute; a bare `50` means 50 active units per minute.

## Create an Inspection Program in Fusion

1. Create or select a Manufacture setup with the correct stock, orientation,
   origin, and work offset.
2. Confirm the PathPilot work offset matches the setup before running.
3. Add the probe to the Fusion tool library as tool 99 with length offset 99.
4. Verify the probe stylus diameter in Fusion matches the calibrated effective
   diameter used by PathPilot.
5. Add the required **Probe** operations.
6. Select the intended surfaces or feature geometry carefully.
7. Set safe approach, clearance, retract, overtravel, and probe depth values.
8. Enable **Print Results** in every probe operation whose measurement should be
   written to `RESULTS.TXT` and imported into Fusion.
9. Create an NC Program and select **Tormach PathPilot Inspection**.
10. Configure the Program End properties, especially the M199 archive mode and
    every enabled G53 position.
11. Post the program and review the generated `.nc` file before transferring it
    to PathPilot.

If all probe operations have **Print Results** disabled, the probe routines can
still update the WCS, but no `RESULTS.TXT` report is created and `M199` is not
called.

## Supported Fusion Probe Cycles

| Fusion cycle | PathPilot macro behavior |
| --- | --- |
| Probe X, Y, or Z | Measures one surface and can update that WCS axis. |
| X wall / Y wall | Measures an outside width or boss center. |
| X channel / Y channel | Measures an inside width or pocket center. |
| Channel with island | Uses the configured safe retract around the island. |
| Circular boss | Four-direction outside probing. |
| Partial circular boss | Three-point outside probing at Fusion's vectors. |
| Circular hole | Four-direction bore probing. |
| Circular hole with island | Bore probing with the configured safe retract. |
| Partial circular hole | Three-point inside probing at Fusion's vectors. |
| Rectangular hole | Runs independent X-pocket and Y-pocket measurements. |
| Rectangular boss | Runs independent X-boss and Y-boss measurements. |
| Rectangular hole with island | Runs X and Y pocket measurements with safe retract. |
| XY inner or outer corner | Measures both selected corner surfaces. |

X-plane-angle and Y-plane-angle probing are intentionally rejected by the post.

## Controlling WCS Updates

The initialization macro sets:

```text
#<_dont_change_WCS> = 0
```

This means probe operations update their configured work coordinate system by
default. To record measurements without changing the WCS:

1. Add a **Manual NC** operation immediately before the affected probe
   operations.
2. Set its type to **Pass Through**.
3. Enter exactly:

```text
#<_dont_change_WCS> = 1
```

The value is global and remains active for later probe operations. To allow a
later probe to update the WCS again, add another Manual NC Pass Through before
that probe:

```text
#<_dont_change_WCS> = 0
```

Review the posted file and confirm the passthrough line appears before the
intended probe macro call. Do not add a leading `/` unless optional-block
behavior is deliberately required and understood.

## Transfer and First Machine Test

1. Copy the posted `.nc` program into a suitable folder under the PathPilot
   gcode share.
2. Home the machine and verify the active work offset.
3. Confirm the probe is calibrated, seated, and not already triggered.
4. Verify tool 99 and length offset 99 in the PathPilot tool table.
5. Keep **Program-end table washdown** off for the first test.
6. For the first test, use standard logging without M199 or verify M199 with the
   permission procedure before enabling archive mode.
7. Load the program in PathPilot and inspect the preview and estimated motion.
8. Check the beginning of the program contains:

```text
o<initialize_inspection> call
```

9. Check the end contains a value for `#<_inspection_archive_results>`, followed
   by:

```text
o<inspection_program_end> call
M30
```

10. Run a known feature in Single Block at reduced feed. Keep a hand on Feed
    Hold and E-stop.
11. Confirm each direction performs a rough touch, retract, fine touch, and safe
    return without approaching an unexpected wall or fixture.
12. Confirm the machine retracts Z before any end-of-program XY movement.
13. Confirm `RESULTS.TXT` begins with `START` and ends with `END`.
14. Only after this test succeeds should washdown and automatic archives be
    enabled and tested separately.

## Import Results into Fusion

### Standard logging mode

Use the current report:

```text
\\Tormach\gcode\RESULTS.TXT
```

Copy or import it before another inspected program starts.

### Archive mode

Use the required timestamped report from:

```text
\\Tormach\gcode\results
```

The unarchived latest report also remains at `\\Tormach\gcode\RESULTS.TXT`.

In Fusion, open the command for importing inspection results, select the report,
and associate it with the correct inspection setup if Fusion asks. A complete
file must begin with `START`, contain the Fusion transform and measurement
records, and end with `END`.

## Result File Behavior

- The first probe with **Print Results** enabled creates a new `RESULTS.TXT` and
  writes `START`.
- The result name is based on the Fusion job description when available,
  otherwise the probe operation comment, followed by `-RESULTS`.
- Each probe result receives a feature number. A Fusion cycle configured to
  increment components starts a new component; otherwise results increment
  features.
- The post writes `END` and closes the report during normal program completion.
- An aborted program may leave an incomplete file without `END`. Fusion may
  reject that file, and `M199` deliberately refuses to archive it.
- `M199` copies rather than moves the report, so `RESULTS.TXT` always remains the
  latest completed report.

## Troubleshooting

### `#<_dont_change_wcs> is undefined`

The initialization macro was not called or could not be found.

- Confirm `initialize_inspection.nc` is in `~/gcode/subroutines`.
- Confirm the generated program uses the Tormach PathPilot Inspection post.
- Confirm `o<initialize_inspection> call` appears near the program start.

### `Unknown o word` or a probe subroutine cannot be found

- Copy all `.nc` files into `~/gcode/subroutines`.
- Confirm there is no extra folder level.
- Confirm filenames were not changed.
- Reload the G-code after replacing a macro.

### `Unknown m code used: M199`

If `M199` was just installed, restart PathPilot. A correct new user M-code is not
recognized until startup. If the error remains after restart, verify the file:

```bash
chmod 755 /home/operator/gcode/M199
ls -l /home/operator/gcode/M199
```

The expected permission prefix is `-rwxr-xr-x`. The file must be named exactly
`M199`, have no extension, and be located at `/home/operator/gcode/M199`.

To run without the helper, disable **Archive inspection results with M199** and
repost the program.

### One part's results overwrite another part

This is expected in standard logging mode. Enable and install M199 archiving, or
copy/import `RESULTS.TXT` before starting the next inspected program.

### Fusion says the results file is the wrong type or incomplete

- Open the file with a plain-text editor.
- Confirm the first nonblank line is `START`.
- Confirm the final nonblank line is `END`.
- Do not import a report from an aborted program.
- Confirm at least one probe operation had **Print Results** enabled.

### No result file is created

- Confirm **Print Results** is enabled in the Fusion probe operation.
- Confirm the program reached that probe operation.
- Check `~/gcode/RESULTS.TXT`, not the program's subfolder.
- Check the PathPilot log for `LOGOPEN` or file-permission errors.

### Washdown is skipped with a warning

T0, T99, or T1000 is selected or loaded. Configure and load a normal cleaning
tool, or turn off the washdown.

### Post error: unsupported unit `""`

The installed post is outdated. The current post accepts unitless values and
explicit `in` or `mm` suffixes. Replace `Tormach_Inspection.cps` in Fusion's Post
Library, reopen the Post Process dialog, and post again.

### Archive did not appear

- Confirm `RESULTS.TXT` starts with `START` and ends with `END`.
- Confirm M199 archiving is enabled in the post.
- Confirm `M199` is executable.
- Check `~/gcode/results/archive-events.log`. If it does not exist after a run,
  PathPilot did not execute `M199`; reapply executable permission and restart
  PathPilot.
- Check `~/gcode/results/archive-errors.log`.
- Confirm the PathPilot system clock is correct.

### Expected tool does not receive a breakage check

- Confirm the tool is used by the posted program.
- Enable **Check every tool**, enable Fusion's **Break Control** for that tool,
  or add its number to **Check list of tools**.
- If relying on Fusion's flag, confirm **Ignore Fusion tool library break
  detection flag** is disabled.
- Confirm the tool does not appear in **Ignore list of tools**.
- Enter list values as whole numbers separated by commas, such as `1, 2, 7`.
- Probe-type tools are intentionally excluded.

### Tool break detection cannot see the ETS

Enable **Fully retract before starting tool break detection** after confirming
that `G53 Z0` is the machine's safe fully retracted position. The posted program
must show `G53 G0 Z0` immediately before `G37`.

## Updating

1. Download the current repository files.
2. Replace `Tormach_Inspection.cps` in the Fusion Post Library.
3. Replace every `.nc` macro in `~/gcode/subroutines` as one matched set.
4. If `M199` changed, replace it, rerun `chmod 755`, and restart PathPilot.
5. Repost a short test program and repeat the first-machine-test checks.

Do not mix macros and posts from different revisions. The post and macros share
named global-variable contracts and must be updated together.

## Developer validation

Run the cross-platform static checks from the repository root:

```text
python scripts/validate_repository.py
```

On Linux or Git Bash, also run:

```text
bash -n M199 tests/test_m199.sh
bash tests/test_m199.sh
node tests/test_tool_breakage_logic.js
```

GitHub Actions runs these checks on pushes to `main` and on pull requests. The
Autodesk post-engine interrogation and physical PathPilot checklist remain
manual release gates because those runtimes are not available in GitHub Actions.

## Removing the Package

1. Stop posting new programs with **Tormach PathPilot Inspection**.
2. Finish or discard any posted programs that call these macros.
3. Select the standard Tormach post in Fusion.
4. Remove the custom post from the Fusion Post Library if desired.
5. Remove the package `.nc` files from `~/gcode/subroutines` and remove `M199`
   only after no remaining G-code calls them.

Existing result files in `~/gcode/results` are ordinary text files and can be
retained or backed up independently.
