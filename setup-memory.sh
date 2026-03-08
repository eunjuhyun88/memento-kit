#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  bash setup-memory.sh --target <dir> --agent-name <name> [options]

Options:
  --target <dir>          Target agent workspace path
  --agent-name <name>     Human-readable agent name
  --agent-role <text>     Main role or specialty
  --user-name <text>      Primary human or operator name
  --summary <text>        One-line workspace summary
  --voice-style <text>    Tone or speaking style
  --force                 Overwrite existing files from the template
  -h, --help              Show help
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$ROOT_DIR/templates/agent-memory"

TARGET_DIR=""
AGENT_NAME=""
AGENT_ROLE="generalist"
USER_NAME="Primary user"
SUMMARY="Agent memory workspace."
VOICE_STYLE="Clear, calm, and direct."
FORCE=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--target)
			TARGET_DIR="${2:-}"
			shift 2
			;;
		--agent-name)
			AGENT_NAME="${2:-}"
			shift 2
			;;
		--agent-role)
			AGENT_ROLE="${2:-}"
			shift 2
			;;
		--user-name)
			USER_NAME="${2:-}"
			shift 2
			;;
		--summary)
			SUMMARY="${2:-}"
			shift 2
			;;
		--voice-style)
			VOICE_STYLE="${2:-}"
			shift 2
			;;
		--force)
			FORCE=1
			shift 1
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			usage
			exit 1
			;;
	esac
done

if [ -z "$TARGET_DIR" ] || [ -z "$AGENT_NAME" ]; then
	echo "Missing required flags."
	usage
	exit 1
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TODAY="$(date +%Y-%m-%d)"
AGENT_SLUG="$(printf '%s' "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
DAILY_MEMORY_FILE="memory/$TODAY.md"

copy_file() {
	local src="$1"
	local dest="$2"

	if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
		echo "[setup-memory] keep existing: ${dest#$TARGET_DIR/}"
		return 0
	fi

	mkdir -p "$(dirname "$dest")"
	cp "$src" "$dest"
	echo "[setup-memory] wrote: ${dest#$TARGET_DIR/}"
}

copy_tree() {
	local src_root="$1"
	local rel=""
	while IFS= read -r -d '' file; do
		rel="${file#$src_root/}"
		copy_file "$file" "$TARGET_DIR/$rel"
	done < <(find "$src_root" -type f -print0)
}

replace_placeholders() {
	local file="$1"
	python3 - "$file" "$AGENT_NAME" "$AGENT_SLUG" "$AGENT_ROLE" "$USER_NAME" "$SUMMARY" "$VOICE_STYLE" "$TODAY" "$DAILY_MEMORY_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
replacements = {
    "__AGENT_NAME__": sys.argv[2],
    "__AGENT_SLUG__": sys.argv[3],
    "__AGENT_ROLE__": sys.argv[4],
    "__USER_NAME__": sys.argv[5],
    "__WORKSPACE_SUMMARY__": sys.argv[6],
    "__VOICE_STYLE__": sys.argv[7],
    "__TODAY__": sys.argv[8],
    "__DAILY_MEMORY_FILE__": sys.argv[9],
}
for old, new in replacements.items():
    text = text.replace(old, new)
path.write_text(text)
PY
}

copy_tree "$TEMPLATE_DIR"

while IFS= read -r -d '' file; do
	replace_placeholders "$file"
done < <(find "$TARGET_DIR" -type f -name '*.md' -print0)

if [ ! -f "$TARGET_DIR/$DAILY_MEMORY_FILE" ] || [ "$FORCE" -eq 1 ]; then
	cat > "$TARGET_DIR/$DAILY_MEMORY_FILE" <<EOF
# Daily Memory — $TODAY

## Today

- session start

## Events

- none yet

## Decisions

- none yet

## Carry Forward

- none yet
EOF
	echo "[setup-memory] wrote: $DAILY_MEMORY_FILE"
fi

if [ ! -d "$TARGET_DIR/.git" ]; then
	git -C "$TARGET_DIR" init -q
	echo "[setup-memory] initialized git repository"
fi

echo ""
echo "Memory workspace applied to: $TARGET_DIR"
echo "Next steps:"
echo "  1. Fill SOUL.md, USER.md, and MEMORY.md with real identity and memory rules"
echo "  2. Add today's first real session notes to $DAILY_MEMORY_FILE"
echo "  3. Commit the initial workspace skeleton"
