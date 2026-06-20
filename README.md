# Tormach Inspection Macros

## PathPilot deployment

Copy the inspection `.nc` files to `/home/operator/gcode/subroutines` and copy
`M199` to `/home/operator/gcode/M199`.

LinuxCNC only recognizes an `M100` through `M199` helper when the file is
executable. A copy through the PathPilot SMB share may remove that Unix
permission even though the repository records it correctly. Open a terminal on
the PathPilot controller and run:

```bash
chmod 755 /home/operator/gcode/M199
ls -l /home/operator/gcode/M199
```

The `ls` output must begin with `-rwxr-xr-x`. Restart the PathPilot GUI after
installing a new user M-code so the interpreter discovers it. If PathPilot
reports `Unknown m code used: M199`, repeat the permission check and restart.
