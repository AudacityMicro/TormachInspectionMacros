# Release Checklist

## Current decision

**Not ready for a versioned production release.**

The repository is suitable for controlled development testing, but the physical
machine test matrix, public license, supported-version statement, and release
version have not been completed. Do not create a release tag until every blocker
below is resolved and evidence is recorded.

Audit date: 2026-06-20

## Completed repository checks

- [x] Autodesk post engine accepts `Tormach_Inspection.cps` using post engine
  5.370.5.
- [x] Static audit confirms every `G38.2` touch has an explicit preceding G90.
- [x] Circular and three-point targets are calculated from the recorded feature
  center rather than the active XY origin.
- [x] Every probe macro has balanced O-word control flow, result guards, and
  Fusion logging commands.
- [x] The program-end sequence retracts Z before cleaning, tool changes, and XY
  unload motion.
- [x] `M199` validates complete reports, copies rather than moves, handles name
  collisions, and returns success after logging archive failures.
- [x] `M199` is optional through a Fusion post property.
- [x] PathPilot recognizes a newly installed `M199` after PathPilot is restarted.
- [x] Repository validation and M199 integration tests run in GitHub Actions.
- [x] Installation and operator documentation describe both archive modes.

## Release blockers

- [ ] Select and add a public software license approved by the repository owner.
- [ ] Set the GitHub repository description and topics. Recommended description:
  `Fusion inspection post and PathPilot probing macros for Tormach mills.`
  Recommended topics: `fusion-360`, `tormach`, `pathpilot`, `cnc`, `probing`,
  and `inspection`.
- [ ] Choose a release version and document the version in the release notes.
- [ ] Define supported Fusion and PathPilot version ranges.
- [ ] Complete every required test in `MACHINE_TEST_CHECKLIST.md` on the target
  Tormach machine.
- [ ] Test inch and metric output from Fusion using the release candidate post.
- [ ] Verify every supported probe cycle on at least one off-origin feature.
- [ ] Verify positive and negative approach directions where the Fusion cycle
  permits both.
- [ ] Verify WCS updates enabled and suppressed with `#<_dont_change_WCS>`.
- [ ] Import complete reports from the release candidate into Fusion and retain
  representative sanitized fixtures as test evidence.
- [ ] Test program-end washdown at reduced feed using every cleaning-output mode
  that will be documented as supported on the target machine.
- [ ] Verify cleaning-tool and final-tool changes independently, including the
  already-loaded-tool case and T0/T99/T1000 washdown guards.
- [ ] Verify M199 success, same-second collision, incomplete-report warning, and
  archive folder creation on PathPilot itself.
- [ ] Review the final diff and generated G-code with a second qualified person.

## Release procedure

1. Freeze a release-candidate commit on `main`.
2. Run `python scripts/validate_repository.py`.
3. Run `bash -n M199 tests/test_m199.sh`.
4. Run `bash tests/test_m199.sh`.
5. Interrogate the post with Autodesk's installed post engine.
6. Complete and sign the machine test checklist.
7. Resolve every release blocker above.
8. Move the Unreleased changelog entries under the selected version and date.
9. Commit the release metadata.
10. Create an annotated version tag and GitHub release from that exact commit.
11. Attach or link the tested post, macro set, and test evidence.
