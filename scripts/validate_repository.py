#!/usr/bin/env python3
"""Static validation for the Tormach inspection post and PathPilot macros."""

from __future__ import annotations

import pathlib
import re
import subprocess
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]

MACRO_FILES = {
    "initialize_inspection.nc",
    "inspection_program_end.nc",
    "inspection_washdown.nc",
    "probe_bore_three_point_inspection.nc",
    "probe_boss_three_point_inspection.nc",
    "probe_circular_bore_inspection.nc",
    "probe_circular_boss_inspection.nc",
    "probe_x_boss_inspection.nc",
    "probe_x_edge_inspection.nc",
    "probe_x_pocket_inspection.nc",
    "probe_xy_corner_inspection.nc",
    "probe_y_boss_inspection.nc",
    "probe_y_edge_inspection.nc",
    "probe_y_pocket_inspection.nc",
    "probe_z_inspection.nc",
}

REQUIRED_FILES = MACRO_FILES | {
    ".github/workflows/validate.yml",
    "CHANGELOG.md",
    "M199",
    "MACHINE_TEST_CHECKLIST.md",
    "README.md",
    "RELEASE_CHECKLIST.md",
    "Target Format.txt",
    "Tormach_Inspection.cps",
    "tests/test_m199.sh",
    "tests/test_tool_breakage_logic.js",
}

TEXT_SUFFIXES = {".cps", ".md", ".nc", ".py", ".sh", ".txt", ".yml"}


class Validation:
    def __init__(self) -> None:
        self.errors: list[str] = []

    def require(self, condition: bool, message: str) -> None:
        if not condition:
            self.errors.append(message)


def tracked_files() -> list[pathlib.Path]:
    return sorted(
        path
        for path in ROOT.rglob("*")
        if path.is_file() and ".git" not in path.relative_to(ROOT).parts
    )


def code_without_comments(line: str) -> str:
    return line.split("(", 1)[0]


def validate_text_files(validation: Validation) -> None:
    for path in tracked_files():
        if path.suffix.lower() not in TEXT_SUFFIXES and path.name != "M199":
            continue
        data = path.read_bytes()
        relative = path.relative_to(ROOT)
        try:
            text = data.decode("ascii")
        except UnicodeDecodeError:
            validation.errors.append(f"{relative}: text file is not ASCII")
            continue
        validation.require(data.endswith(b"\n"), f"{relative}: missing final newline")
        for line_number, line in enumerate(text.splitlines(), 1):
            if line.strip() and line.rstrip(" \t") != line:
                validation.errors.append(
                    f"{relative}:{line_number}: trailing whitespace"
                )


def validate_control_flow(validation: Validation, path: pathlib.Path) -> None:
    stack: list[tuple[str, str, int]] = []
    opening = re.compile(r"^o([^\s]+)\s+(if|while)\b", re.IGNORECASE)
    closing = re.compile(r"^o([^\s]+)\s+(endif|endwhile)\b", re.IGNORECASE)

    for line_number, line in enumerate(path.read_text(encoding="ascii").splitlines(), 1):
        stripped = line.strip()
        match = opening.match(stripped)
        if match:
            stack.append((match.group(1).lower(), match.group(2).lower(), line_number))
            continue
        match = closing.match(stripped)
        if not match:
            continue
        label = match.group(1).lower()
        expected_open = "if" if match.group(2).lower() == "endif" else "while"
        if not stack:
            validation.errors.append(f"{path.name}:{line_number}: unmatched {match.group(2)}")
            continue
        open_label, open_type, open_line = stack.pop()
        if label != open_label or expected_open != open_type:
            validation.errors.append(
                f"{path.name}:{line_number}: closes o{label} {expected_open}, "
                f"but o{open_label} {open_type} opened at line {open_line}"
            )

    for label, block_type, line_number in stack:
        validation.errors.append(
            f"{path.name}:{line_number}: unclosed o{label} {block_type}"
        )


def validate_macro(validation: Validation, path: pathlib.Path) -> None:
    text = path.read_text(encoding="ascii")
    lines = text.splitlines()
    nonblank = [line.strip() for line in lines if line.strip()]
    stem = path.stem

    validation.require(
        bool(nonblank) and nonblank[0].lower() == f"o<{stem}> sub",
        f"{path.name}: first statement must be o<{stem}> sub",
    )
    validation.require(
        bool(nonblank) and nonblank[-1].lower() == f"o<{stem}> endsub",
        f"{path.name}: last statement must be o<{stem}> endsub",
    )

    for line_number, line in enumerate(lines, 1):
        code = code_without_comments(line)
        if re.search(r"\bM(?:0?2|30)\b", code, re.IGNORECASE):
            validation.errors.append(
                f"{path.name}:{line_number}: program-end M-code is not allowed in a subroutine"
            )
        without_valid_parameters = re.sub(r"#<[^>\r\n]+>", "", line)
        if "#<" in without_valid_parameters:
            validation.errors.append(
                f"{path.name}:{line_number}: malformed named parameter"
            )

    validate_control_flow(validation, path)

    if not path.name.startswith("probe_"):
        return

    validation.require(
        "#<_printResults> EQ 1" in text,
        f"{path.name}: missing print-results guard",
    )
    validation.require(
        "(LOGAPPEND,RESULTS.TXT)" in text and "(LOGCLOSE)" in text,
        f"{path.name}: missing result logging commands",
    )

    mode = None
    for line_number, line in enumerate(lines, 1):
        code = code_without_comments(line)
        if re.search(r"\bG90\b", code, re.IGNORECASE):
            mode = "G90"
        if re.search(r"\bG91\b", code, re.IGNORECASE):
            mode = "G91"
        if re.search(r"\bG38\.2\b", code, re.IGNORECASE):
            validation.require(
                mode == "G90",
                f"{path.name}:{line_number}: G38.2 must have an explicit preceding G90",
            )
        if re.search(r"\bG38\.6\b", code, re.IGNORECASE):
            validation.require(
                mode in {"G90", "G91"},
                f"{path.name}:{line_number}: G38.6 has no explicit distance mode",
            )
            if mode == "G90":
                validation.require(
                    path.name == "probe_boss_three_point_inspection.nc"
                    and "position_" in code,
                    f"{path.name}:{line_number}: unexpected absolute G38.6 target",
                )
    validation.require(mode == "G90", f"{path.name}: does not finish in G90")


def validate_call_contract(validation: Validation) -> None:
    sources = [ROOT / "Tormach_Inspection.cps"] + [ROOT / name for name in MACRO_FILES]
    calls: set[str] = set()
    for path in sources:
        calls.update(
            match.group(1)
            for match in re.finditer(
                r"o<([^>]+)>\s+call", path.read_text(encoding="ascii"), re.IGNORECASE
            )
        )
    available = {pathlib.Path(name).stem for name in MACRO_FILES}
    for target in sorted(calls - available):
        validation.errors.append(f"subroutine call has no matching file: o<{target}> call")


def validate_post_contract(validation: Validation) -> None:
    post = (ROOT / "Tormach_Inspection.cps").read_text(encoding="ascii")
    required = [
        'title      : "Archive inspection results with M199"',
        'title      : "Check every tool"',
        'title      : "Check list of tools"',
        'title      : "Ignore Fusion tool library break detection flag"',
        'title      : "Ignore list of tools"',
        'title      : "Fully retract before starting tool break detection"',
        'getProperty("programEndArchiveResults")',
        'parseToolBreakageCheckList();',
        'parseToolBreakageIgnoreList();',
        'shouldCheckToolBreakage(tool)',
        'getProperty("toolBreakageIgnoreFusionFlag")',
        'getProperty("toolBreakageFullyRetract")',
        'writeBlock(gFormat.format(53), gMotionModal.format(0), "Z0")',
        'var isLastOperationForTool = isLastSection()',
        'inspectionLogLine("START")',
        'inspectionLogLine("END")',
        'writeBlock("o<initialize_inspection> call")',
        'writeBlock("o<inspection_program_end> call")',
    ]
    for token in required:
        validation.require(token in post, f"Tormach_Inspection.cps: missing {token}")

    break_control = post[
        post.find("case COMMAND_BREAK_CONTROL:") : post.find("case COMMAND_TOOL_MEASURE:")
    ]
    break_control_order = [
        break_control.find("prepareForToolCheck();"),
        break_control.find('writeBlock(gFormat.format(53), gMotionModal.format(0), "Z0")'),
        break_control.find('writeBlock(gFormat.format(37), "P"'),
    ]
    validation.require(
        all(position >= 0 for position in break_control_order)
        and break_control_order == sorted(break_control_order),
        "Tormach_Inspection.cps: unsafe tool breakage preparation order",
    )

    initialization = (ROOT / "initialize_inspection.nc").read_text(encoding="ascii")
    for variable in (
        "_dont_change_WCS",
        "_inspection_archive_results",
        "_inspection_end_x",
        "_inspection_end_y",
        "_inspection_washdown_enabled",
    ):
        validation.require(
            f"#<{variable}>" in initialization,
            f"initialize_inspection.nc: missing {variable}",
        )


def validate_motion_contracts(validation: Validation) -> None:
    required_tokens = {
        "probe_circular_bore_inspection.nc": (
            "#<positive_x_probe_target> = [#1 + [#<_diameter_to_probe>/2]]",
            "#<negative_x_probe_target> = [#1 - [#<_diameter_to_probe>/2]]",
            "#<_x_center> = [[#<_first_x_touch> + #<_second_x_touch>]/2]",
            "#<_y_center> = [[#<_first_y_touch> + #<_second_y_touch>]/2]",
        ),
        "probe_circular_boss_inspection.nc": (
            "#<_x_center> = [[#<_first_x_touch> + #<_second_x_touch>]/2]",
            "#<_y_center> = [[#<_first_y_touch> + #<_second_y_touch>]/2]",
        ),
        "probe_bore_three_point_inspection.nc": (
            "#<first_vector_x_target> = [#1 + [#<_diameter_to_probe> * COS[#<_first_vector>]]]",
            "#<first_vector_y_target> = [#2 + [#<_diameter_to_probe> * SIN[#<_first_vector>]]]",
            "G1 X#1 Y#2 F#<_probe_rapid_feed_per_min>",
        ),
        "probe_boss_three_point_inspection.nc": (
            "#<first_position_x> = [#1 + [#<_radius_to_position> * COS[#<_first_vector>]]]",
            "#<first_probe_y> = [#2 + [#<_radius_to_probe> * SIN[#<_first_vector>]]]",
            "G1 X#1 Y#2 (retract to original XY position)",
        ),
    }
    for name, tokens in required_tokens.items():
        text = (ROOT / name).read_text(encoding="ascii")
        for token in tokens:
            validation.require(token in text, f"{name}: missing motion contract {token}")

    program_end = (ROOT / "inspection_program_end.nc").read_text(encoding="ascii")
    ordered_tokens = (
        "G53 G0 Z0 (fully retract Z in machine coordinates)",
        "o<inspection_washdown> call",
        "O117 if [#<_inspection_end_change_tool> EQ 1]",
        "G53 G0 X#<_inspection_end_x> Y#<_inspection_end_y>",
        "M199 (archive completed inspection results)",
    )
    positions = [program_end.find(token) for token in ordered_tokens]
    validation.require(
        all(position >= 0 for position in positions) and positions == sorted(positions),
        "inspection_program_end.nc: unsafe program-end operation order",
    )


def validate_archive_helper(validation: Validation) -> None:
    path = ROOT / "M199"
    data = path.read_bytes()
    validation.require(data.startswith(b"#!/bin/bash\n"), "M199: invalid shebang")
    listing = subprocess.check_output(
        ["git", "ls-files", "-s", "M199"], cwd=ROOT, text=True
    )
    validation.require(listing.startswith("100755 "), "M199: Git mode must be 100755")
    text = data.decode("ascii")
    for token in (
        "M199_GCODE_DIR",
        "${HOME:-/home/operator}/gcode",
        "START",
        "END",
        "RESULTSFILE",
        "archive-errors.log",
        "archive-events.log",
    ):
        validation.require(token in text, f"M199: missing {token} handling")


def validate_documentation(validation: Validation) -> None:
    readme = (ROOT / "README.md").read_text(encoding="ascii")
    for token in (
        "Pre-release status",
        "Archive inspection results with M199",
        "Restart PathPilot",
        "RELEASE_CHECKLIST.md",
        "MACHINE_TEST_CHECKLIST.md",
    ):
        validation.require(token in readme, f"README.md: missing {token}")
    validation.require(
        not (ROOT / "Note to self.txt").exists(),
        "Note to self.txt: stale development note must not be released",
    )
    target = (ROOT / "Target Format.txt").read_text(encoding="ascii").splitlines()
    nonblank = [line for line in target if line]
    validation.require(nonblank[0] == "START", "Target Format.txt: must begin with START")
    validation.require(nonblank[-1] == "END", "Target Format.txt: must end with END")


def main() -> int:
    validation = Validation()

    for relative in sorted(REQUIRED_FILES):
        validation.require((ROOT / relative).is_file(), f"missing required file: {relative}")

    validate_text_files(validation)
    for name in sorted(MACRO_FILES):
        path = ROOT / name
        if path.exists():
            validate_macro(validation, path)
    validate_call_contract(validation)
    validate_post_contract(validation)
    validate_motion_contracts(validation)
    validate_archive_helper(validation)
    validate_documentation(validation)

    if validation.errors:
        for error in validation.errors:
            print(f"ERROR: {error}", file=sys.stderr)
        print(f"Validation failed with {len(validation.errors)} error(s).", file=sys.stderr)
        return 1

    print(f"Validation passed for {len(MACRO_FILES)} PathPilot macros and repository contracts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
