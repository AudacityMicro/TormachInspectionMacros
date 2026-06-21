#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT

cp -- "$repo_dir/M199" "$test_dir/M199"
chmod 755 "$test_dir/M199"

mkdir -p -- "$test_dir/bin"
cat > "$test_dir/bin/date" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
  +%Y%m%d-%H%M%S) printf '20260620-120000\n' ;;
  *) printf '2026-06-20 12:00:00\n' ;;
esac
EOF
chmod 755 "$test_dir/bin/date"
export PATH="$test_dir/bin:$PATH"
export M199_GCODE_DIR="$test_dir"

cat > "$test_dir/RESULTS.TXT" <<'EOF'
START
RESULTSFILE Setup 1-RESULTS
TIMESTAMP 260620 120000

TOOLPATHID 1.01001
TOOLPATH Probe Bore
END
EOF
cp -- "$test_dir/RESULTS.TXT" "$test_dir/expected.txt"

"$test_dir/M199"
first_archive="$test_dir/results/Setup-1-RESULTS-20260620-120000.TXT"
test -f "$first_archive"
cmp -- "$test_dir/expected.txt" "$first_archive"
grep -q "M199 invoked; source=$test_dir/RESULTS.TXT" "$test_dir/results/archive-events.log"
grep -q "Archived $first_archive" "$test_dir/results/archive-events.log"

"$test_dir/M199"
test -f "$test_dir/results/Setup-1-RESULTS-20260620-120000-01.TXT"
archive_count="$(find "$test_dir/results" -maxdepth 1 -type f -name '*.TXT' | wc -l | tr -d ' ')"
test "$archive_count" = "2"

cat > "$test_dir/RESULTS.TXT" <<'EOF'
START
RESULTSFILE Incomplete-RESULTS
EOF

"$test_dir/M199" 2> "$test_dir/warning.txt"
archive_count="$(find "$test_dir/results" -maxdepth 1 -type f -name '*.TXT' | wc -l | tr -d ' ')"
test "$archive_count" = "2"
grep -q "does not end with END" "$test_dir/warning.txt"
grep -q "does not end with END" "$test_dir/results/archive-errors.log"

printf 'M199 archive tests passed.\n'
